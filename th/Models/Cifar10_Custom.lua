--[[This code specify the model for CIFAR 10 dataset. This model uses the Shift based batch-normalization algorithm.
In this file we also secify the Glorot learning parameter and the which of the learnable parameter we clip ]]
require 'nn'
require './BinaryLinear.lua'
require './BinarizedNeurons'

local SpatialConvolution
local SpatialMaxPooling
if opt.type =='cuda' then
  require 'cunn'
  require 'cudnn'
  require './cudnnBinarySpatialConvolution.lua'
  --SpatialConvolution = cudnn.SpatialConvolution
  SpatialMaxPooling = cudnn.SpatialMaxPooling
  --following is a cudnn version
  SpatialConvolution = cudnnBinarySpatialConvolution
  --SpatialMaxPooling = cudnn.SpatialMaxPooling
else
  require './BinarySpatialConvolution.lua'
  SpatialConvolution = BinarySpatialConvolution
  SpatialMaxPooling = nn.SpatialMaxPooling
end
if opt.SBN == true then
  require './BatchNormalizationShiftPow2.lua'
  require './SpatialBatchNormalizationShiftPow2.lua'
  BatchNormalization = BatchNormalizationShiftPow2
  SpatialBatchNormalization = SpatialBatchNormalizationShiftPow2
else
  BatchNormalization = nn.BatchNormalization
  SpatialBatchNormalization = nn.SpatialBatchNormalization
end

lastNodeN = 10
if opt.dataset == 'Cifar100' then 
   lastNodeN = 100
end 

numHid = opt.numHid  --1024;

local model = nn.Sequential()

-- Convolution Layers

initChannel = 64
channelIncr = 0

channelNum = {}

table.insert(channelNum,3)

for i=1,opt.convLayerN do
   
   if i % 2 == 1 then
      if initChannel == 512 then
      
      else
	 initChannel = initChannel * 2
      end
      --channelIncr = channelIncr + 1
   end
   
   table.insert(channelNum,torch.floor(initChannel * opt.channel) )   

end

-- {
-- 3,
-- torch.floor( 128 * opt.channel ),torch.floor( 128 * opt.channel ),
-- torch.floor( 256 * opt.channel ),torch.floor( 256 * opt.channel ),
-- torch.floor( 512 * opt.channel ),torch.floor( 512 * opt.channel )
-- }

--poolingN = 0

poolingSize = 32

for l=1,opt.convLayerN do
   if l == 1 then
      
      model:add(SpatialConvolution( channelNum[l], channelNum[l+1] , 3, 3 ,1,1,1,1,opt.stcWeights ))
      model:add(SpatialBatchNormalization(channelNum[2] , opt.runningVal))
      model:add(nn.HardTanh())
      model:add(BinarizedNeurons(opt.stcNeurons))
      
   else
      model:add(SpatialConvolution(channelNum[l], channelNum[l+1], 3, 3,1,1,1,1,opt.stcWeights ))
      
      if l % 2 == 0 then 
	 --poolingN = poolingN + 1
	 if poolingSize == 1 then
	 else
	    model:add(SpatialMaxPooling(2, 2))
	    poolingSize = poolingSize / 2
	 end
      end
      
      model:add(SpatialBatchNormalization(channelNum[l+1] , opt.runningVal))
      model:add(nn.HardTanh())
      model:add(BinarizedNeurons(opt.stcNeurons))
      
   end
   
end

--following is fully connected layer

fullyN = channelNum[opt.convLayerN+1] * poolingSize * poolingSize

model:add(nn.View( fullyN ))
model:add(BinaryLinear(fullyN,numHid,opt.stcWeights))
model:add(BatchNormalization(numHid))
model:add(nn.HardTanh())
model:add(BinarizedNeurons(opt.stcNeurons))

model:add(BinaryLinear(numHid,numHid,opt.stcWeights))
model:add(BatchNormalization(numHid, opt.runningVal))
model:add(nn.HardTanh())
model:add(BinarizedNeurons(opt.stcNeurons))

model:add(BinaryLinear(numHid,lastNodeN,opt.stcWeights))
model:add(nn.BatchNormalization(lastNodeN))

local dE, param = model:getParameters()
local weight_size = dE:size(1)
local learningRates = torch.Tensor(weight_size):fill(0)
local clipvector = torch.Tensor(weight_size):fill(1)
local counter = 0
for i, layer in ipairs(model.modules) do
   if layer.__typename == 'BinaryLinear' then
      local weight_size = layer.weight:size(1)*layer.weight:size(2)
      local size_w=layer.weight:size();   GLR=1/torch.sqrt(1.5/(size_w[1]+size_w[2]))
      GLR=(math.pow(2,torch.round(math.log(GLR)/(math.log(2)))))
      learningRates[{{counter+1, counter+weight_size}}]:fill(GLR)
      clipvector[{{counter+1, counter+weight_size}}]:fill(1)
      counter = counter+weight_size
      local bias_size = layer.bias:size(1)
      learningRates[{{counter+1, counter+bias_size}}]:fill(GLR)
      clipvector[{{counter+1, counter+bias_size}}]:fill(0)
      counter = counter+bias_size
    elseif layer.__typename == 'BatchNormalizationShiftPow2' then
        local weight_size = layer.weight:size(1)
        local size_w=layer.weight:size();   GLR=1/torch.sqrt(1.5/(size_w[1]))
        learningRates[{{counter+1, counter+weight_size}}]:fill(1)
        clipvector[{{counter+1, counter+weight_size}}]:fill(0)
        counter = counter+weight_size
        local bias_size = layer.bias:size(1)
        learningRates[{{counter+1, counter+bias_size}}]:fill(1)
        clipvector[{{counter+1, counter+bias_size}}]:fill(0)
        counter = counter+bias_size
    elseif layer.__typename == 'nn.BatchNormalization' then
      local weight_size = layer.weight:size(1)
      learningRates[{{counter+1, counter+weight_size}}]:fill(1)
      clipvector[{{counter+1, counter+weight_size}}]:fill(0)
      counter = counter+weight_size
      local bias_size = layer.bias:size(1)
      learningRates[{{counter+1, counter+bias_size}}]:fill(1)
      clipvector[{{counter+1, counter+bias_size}}]:fill(0)
      counter = counter+bias_size
    elseif layer.__typename == 'SpatialBatchNormalizationShiftPow2' then
        local weight_size = layer.weight:size(1)
        local size_w=layer.weight:size();   GLR=1/torch.sqrt(1.5/(size_w[1]))
        learningRates[{{counter+1, counter+weight_size}}]:fill(1)
        clipvector[{{counter+1, counter+weight_size}}]:fill(0)
        counter = counter+weight_size
        local bias_size = layer.bias:size(1)
        learningRates[{{counter+1, counter+bias_size}}]:fill(1)
        clipvector[{{counter+1, counter+bias_size}}]:fill(0)
        counter = counter+bias_size
    elseif layer.__typename == 'nn.SpatialBatchNormalization' then
            local weight_size = layer.weight:size(1)
            local size_w=layer.weight:size();   GLR=1/torch.sqrt(1.5/(size_w[1]))
            learningRates[{{counter+1, counter+weight_size}}]:fill(1)
            clipvector[{{counter+1, counter+weight_size}}]:fill(0)
            counter = counter+weight_size
            local bias_size = layer.bias:size(1)
            learningRates[{{counter+1, counter+bias_size}}]:fill(1)
            clipvector[{{counter+1, counter+bias_size}}]:fill(0)
            counter = counter+bias_size
    elseif layer.__typename == 'cudnnBinarySpatialConvolution' then
      local size_w=layer.weight:size();
      local weight_size = size_w[1]*size_w[2]*size_w[3]*size_w[4]
      local filter_size=size_w[3]*size_w[4]
      GLR=1/torch.sqrt(1.5/(size_w[1]*filter_size+size_w[2]*filter_size))
      GLR=(math.pow(2,torch.round(math.log(GLR)/(math.log(2)))))
      learningRates[{{counter+1, counter+weight_size}}]:fill(GLR)
      clipvector[{{counter+1, counter+weight_size}}]:fill(1)
      counter = counter+weight_size
      local bias_size = layer.bias:size(1)
      learningRates[{{counter+1, counter+bias_size}}]:fill(GLR)
      clipvector[{{counter+1, counter+bias_size}}]:fill(0)
      counter = counter+bias_size
      elseif layer.__typename == 'BinarySpatialConvolution' then
        local size_w=layer.weight:size();
        local weight_size = size_w[1]*size_w[2]*size_w[3]*size_w[4]

        local filter_size=size_w[3]*size_w[4]
        GLR=1/torch.sqrt(1.5/(size_w[1]*filter_size+size_w[2]*filter_size))
        GLR=(math.pow(2,torch.round(math.log(GLR)/(math.log(2)))))
        learningRates[{{counter+1, counter+weight_size}}]:fill(GLR)
        clipvector[{{counter+1, counter+weight_size}}]:fill(1)
        counter = counter+weight_size
        local bias_size = layer.bias:size(1)
        learningRates[{{counter+1, counter+bias_size}}]:fill(GLR)
        clipvector[{{counter+1, counter+bias_size}}]:fill(0)
        counter = counter+bias_size

  end
end
-- clip all parameter
clipvector:fill(1)
--
print(learningRates:eq(0):sum())
print(learningRates:ne(0):sum())
print(clipvector:ne(0):sum())
print(counter)

return {
     model = model,
     lrs = learningRates,
     clipV =clipvector,
  }
