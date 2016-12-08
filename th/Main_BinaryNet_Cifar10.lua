require 'torch'
require 'xlua'
require 'optim'
--require 'gnuplot'
require 'pl'
require 'trepl'
require 'adaMax_binary_clip_shift'
require 'adam_binary_clip_b'
require 'nn'
require 'SqrHingeEmbeddingCriterion'
----------------------------------------------------------------------

cmd = torch.CmdLine()
cmd:addTime()
cmd:text()
cmd:text('Training a convolutional network for visual classification')
cmd:text()
cmd:text('==>Options')

cmd:text('===>Model And Training Regime')
cmd:option('-modelsFolder',       './Models/',            'Models Folder')
cmd:option('-network',            'Model.lua',            'Model file - must return valid network.')
cmd:option('-LR',                 2^-6,                   'learning rate')
cmd:option('-LRDecay',            0.0,                    'learning rate decay (in # samples)')
cmd:option('-LRDecayPerEpoch',    0.0001,                'learning rate decay (in # samples)')
cmd:option('-weightDecay',        0.0,                    'L2 penalty on the weights')
cmd:option('-momentum',           0.0,                    'momentum')
cmd:option('-batchSize',          64,                    'batch size')
cmd:option('-stcNeurons',         true,                   'use stochastic binarization for the neurons')
cmd:option('-stcWeights',         false,                  'use stochastic binarization for the weights')
cmd:option('-optimization',       'adam',                 'optimization method')
cmd:option('-SBN',                true,                   'shift based batch-normalization')
cmd:option('-runningVal',         false,                  'use running mean and std')
cmd:option('-epoch',              -1,                     'number of epochs to train, -1 for unbounded')

cmd:text('===>Platform Optimization')
cmd:option('-threads',            8,                      'number of threads')
cmd:option('-type',               'cuda',                 'float or cuda')
cmd:option('-devid',              1,                      'device ID (if using CUDA)')
cmd:option('-nGPU',               1,                      'num of gpu devices used')
cmd:option('-constBatchSize',     false,                  'do not allow varying batch sizes - e.g for ccn2 kernel')

cmd:text('===>Save/Load Options')
cmd:option('-load',               '',                     'load existing net weights')
cmd:option('-save',               'model00001', 'save directory')
--cmd:option('-save',               os.date():gsub(' ',''), 'save directory')

cmd:text('===>Data Options')
cmd:option('-dataset',            'Cifar10',              'Dataset - Cifar10, Cifar100, STL10, SVHN, MNIST')
cmd:option('-normalization',      'simple',               'simple - whole sample, channel - by image channel, image - mean and std images')
cmd:option('-format',             'rgb',                  'rgb or yuv')
cmd:option('-whiten',             true,                   'whiten data')
cmd:option('-dp_prepro',          false,                   'preprocessing using dp lib')
cmd:option('-augment',            false,                  'Augment training data')
cmd:option('-preProcDir',         './PreProcData/',       'Data for pre-processing (means,P,invP)')
cmd:text('===>Misc')
cmd:option('-visualize',          1,                      'visualizing results')
cmd:option('-title','model1','a name of title of a chart')
cmd:option('-imageFileExtension','svg','image file extension, among png,svg,eps,pdf')
cmd:option('-chartFileName','chart1','when you save a plot, what do you call it?')

cmd:option('-numHid',1024,'number of hidden layers on fully connected layer')
cmd:option('-convLayerN',6,'number of layers')
cmd:option('-channel',1,'number of channel with respect to default channel')


torch.manualSeed(432)
opt = cmd:parse(arg or {})
opt.network = opt.modelsFolder .. paths.basename(opt.network, '.lua')
outputDir = paths.concat('./Results',opt.dataset)
opt.save  = paths.concat(outputDir, opt.save)
opt.preProcDir = paths.concat(opt.preProcDir, opt.dataset .. '/')

-- If you choose to use exponentialy decaying learning rate use uncomment this line
--opt.LRDecay=torch.pow((2e-6/opt.LR),(1./500));
--

os.execute('mkdir -p ' .. opt.preProcDir)
torch.setnumthreads(opt.threads)

torch.setdefaulttensortype('torch.FloatTensor')
if opt.augment then
    require 'image'
end

----------------------------------------------------------------------
-- Model + Loss:

outputN = 10
if opt.dataset == 'Cifar100' then
   outputN = 100
end
print("outputN",outputN)

local modelAll = require(opt.network)

model=modelAll.model
GLRvec=modelAll.lrs
clipV=modelAll.clipV

local loss = SqrtHingeEmbeddingCriterion(1)
local data = require 'Data'
local classes = data.Classes

----------------------------------------------------------------------
-- This matrix records the current confusion across classes

local confusion = optim.ConfusionMatrix(classes)

local AllowVarBatch = not opt.constBatchSize

----------------------------------------------------------------------

-- Output files configuration
os.execute('mkdir -p ' .. opt.save)
cmd:log(opt.save .. '/Log.txt', opt)
local netFilename = paths.concat(opt.save, 'Net')
local logFilename = paths.concat(opt.save,'ErrorRate.log')
local optStateFilename = paths.concat(opt.save,'optState')
local Log = optim.Logger(logFilename)


----------------------------------------------------------------------

local TensorType = 'torch.FloatTensor'
if paths.filep(opt.load) then
    model = torch.load(opt.load)
    print('==>Loaded model from: ' .. opt.load)
    print(model)
end
if opt.type =='cuda' then
    require 'cutorch'
    cutorch.setDevice(opt.devid)
    cutorch.setHeapTracking(true)
    model:cuda()
    GLRvec=GLRvec:cuda()
    clipV=clipV:cuda()
    loss = loss:cuda()
    TensorType = 'torch.CudaTensor'
end

---Support for multiple GPUs - currently data parallel scheme
if opt.nGPU > 1 then
    local net = model
    model = nn.DataParallelTable(1)
    --for i = 1, opt.nGPU do
    for i = opt.devid, opt.devid + opt.nGPU - 1 do
        cutorch.setDevice(i)
        model:add(net:clone():cuda(), i)  -- Use the ith GPU
    end
    cutorch.setDevice(opt.devid)
end

-- Optimization configuration
local Weights,Gradients = model:getParameters()


----------------------------------------------------------------------
print '==> Network'
print(model)
print('==>' .. Weights:nElement() ..  ' Parameters')

print '==> Loss'
print(loss)


------------------Optimization Configuration--------------------------
local optimState = {
    learningRate = opt.LR,
    momentum = opt.momentum,
    weightDecay = opt.weightDecay,
    learningRateDecay = opt.LRDecay,
    GLRvec=GLRvec,
    clipV=clipV
}

----------------------------------------------------------------------


local function SampleImages(images,labels)
    if not opt.augment then
        return images,labels
    else

        local sampled_imgs = images:clone()
        for i=1,images:size(1) do
            local sz = math.random(9) - 1
            local hflip = math.random(2)==1

            local startx = math.random(sz)
            local starty = math.random(sz)
            local img = images[i]:narrow(2,starty,32-sz):narrow(3,startx,32-sz)
            if hflip then
                img = image.hflip(img)
            end
            img = image.scale(img,32,32)
            sampled_imgs[i]:copy(img)
        end
        return sampled_imgs,labels
    end
end

------------------------------

local function Forward(Data, train)
   
  local MiniBatch = DataProvider.Container{
    Name = 'GPU_Batch',
    MaxNumItems = opt.batchSize,
    Source = Data,
    ExtractFunction = SampleImages,
    TensorType = TensorType
  }
  
  local yt = MiniBatch.Labels
  local x = MiniBatch.Data
  local SizeData = Data:size()
  if not AllowVarBatch then SizeData = math.floor(SizeData/opt.batchSize)*opt.batchSize end

  local NumSamples = 0
  local NumBatches = 0
  local lossVal = 0

  while NumSamples < SizeData do
    MiniBatch:getNextBatch()
    local y, currLoss
    NumSamples = NumSamples + x:size(1)
    NumBatches = NumBatches + 1
    if opt.nGPU > 1 then
      model:syncParameters()
    end
    y = model:forward(x)
    one_hot_yt=torch.zeros(yt:size(1),outputN)
    one_hot_yt:scatter(2, yt:long():view(-1,1), 1)
    one_hot_yt=one_hot_yt:mul(2):float():add(-1)
    if opt.type == 'cuda' then
      one_hot_yt=one_hot_yt:cuda()
    end

    currLoss = loss:forward(y,one_hot_yt)
    
    if train then
       function feval()
	  model:zeroGradParameters()
	  local dE_dy = loss:backward(y, one_hot_yt)
	  model:backward(x, dE_dy)
	  return currLoss, Gradients
       end
      --_G.optim[opt.optimization](feval, Weights, optimState) -- If you choose to use different optimization remem
      --ber to clip the weights
       adaMax_binary_clip_shift(feval, Weights, optimState)
    end
    
    lossVal = currLoss + lossVal
    
    if type(y) == 'table' then --table results - always take first prediction
      y = y[1]
    end
    confusion:batchAdd(y,one_hot_yt)
    xlua.progress(NumSamples, SizeData)
    if math.fmod(NumBatches,100)==0 then
      collectgarbage()
    end
  end
  return(lossVal/math.ceil(SizeData/opt.batchSize))
end

------------------------------

local function Train(Data)
  model:training()
  return Forward(Data, true)
end

local function Test(Data)
  model:evaluate()
  return Forward(Data, false)
end

------------------------------

epoch = 1

print '\n==> Starting Training\n'
--require 'plot' 

--trainP = {}
--testP  = {}

trainA = torch.Tensor(500)
testA  = torch.Tensor(500)

while epoch ~= opt.epoch do   

    data.TrainData:shuffleItems()
    print('Epoch ' .. epoch)
    --Train
    confusion:zero()
    
    local LossTrain = Train(data.TrainData)
    if epoch%10==0 then
       torch.save(netFilename, model)
    end
    confusion:updateValids()
    
    local ErrTrain = (1-confusion.totalValid)

    if #classes <= 10 then
        print(confusion)
    end
    
    print('Training Error = ' .. ErrTrain)
    print('Training Loss = ' .. LossTrain)
    
    --validation
    confusion:zero()
    local LossValid = Test(data.ValidData)
    confusion:updateValids()
    local ErrValid = (1-confusion.totalValid)
    
    if #classes <= 10 then
        print(confusion)
    end
    
    print('Valid Error = ' .. ErrValid)
    print('Valid Loss = ' .. LossValid)
    
    --Test
    
    confusion:zero()
    local LossTest = Test(data.TestData)
    confusion:updateValids()
    local ErrTest = (1-confusion.totalValid)    
    
    if #classes <= 10 then
        print(confusion)
    end
    
    print('Test Error = ' .. ErrTest)
    print('Test Loss = ' .. LossTest)
    
    --table.insert(train1,ErrTrain)
    --table.insert(test1,ErrTest)
    
    trainA[epoch] = ErrTrain
    testA [epoch] = ErrTest
    
    --if (epoch % 10 == 0) then
    --plotChart()
    --end
    
    Log:add{['Training Error']= ErrTrain, ['Valid Error'] = ErrValid, ['Test Error'] = ErrTest}
    --Log:add{['Training Error']= LossTrain, ['Valid Error'] = LossValid, ['Test Error'] = LossTest}

    -- if opt.visualize == 1 then
    --     Log:style{['Training Error'] = '-',['Validation Error'] = '-', ['Test Error'] = '-'}
    -- 	--Log:setNames(opt.title)
    --     Log:plot()
    -- end
    
    --optimState.learningRate=optimState.learningRate*opt.LRDecay
    
    if epoch%20==0 then
      optimState.learningRate=optimState.learningRate*0.5
    else
      optimState.learningRate=optimState.learningRate
    end
    
    
    -- if optimState.learningRate - opt.LRDecayPerEpoch <= 0  then
    --    print("no update for learning rate")
    --    --optimState.learningRate=optimState.learningRate - opt.LRDecayPerEpoch --0.5
    -- else
    --   optimState.learningRate=optimState.learningRate - opt.LRDecayPerEpoch
    -- end

    print('-------------------LR-------------------')
    print(optimState.learningRate)
    
    epoch = epoch + 1    

end
