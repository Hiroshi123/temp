
require 'torch'
require 'nn'
require 'cutorch'
require 'cudnn'
require 'xlua'
require 'optim'
require 'trepl'
require 'pl'
require 'cunn'


--paths.dofile('util.lua')

cmd = torch.CmdLine()
cmd:option('-nGPU',1,'')
cmd:option('-model','Net','')

opt = cmd:parse(arg or {})

--nGPU = opt.nGPU

cutorch.setDevice(1)
cutorch.setHeapTracking(true)
--model:cuda()
--GLRvec=GLRvec:cuda()
--clipV=clipV:cuda()
--loss = loss:cuda()
TensorType = 'torch.CudaTensor'

if opt.nGPU > 1 then
    --local net = model
    model = nn.DataParallelTable(1)
    for i = 1, opt.nGPU do
        cutorch.setDevice(i)
        --model:add(net:clone():cuda(), i)  -- Use the ith GPU
    end
    --cutorch.setDevice(1)
end


function loadDataParallel(filename, nGPU)
   if opt.backend == 'cudnn' then
      require 'cudnn'
   end
   local model = torch.load(filename)
   print(model)
   if torch.type(model) == 'nn.DataParallelTable' then
      print("huuuuuu")
      return makeDataParallel(model:get(1):float(), nGPU)
      
   elseif torch.type(model) == 'nn.Sequential' then
      for i,module in ipairs(model.modules) do
         if torch.type(module) == 'nn.DataParallelTable' then
            model.modules[i] = makeDataParallel(module:get(1):float(), nGPU)
         end
      end
      return model
   else
      error('The loaded model is not a Sequential or DataParallelTable module.')
   end
end

function makeDataParallel(model, nGPU)
   if nGPU > 1 then
      print('converting module to nn.DataParallelTable')
      assert(nGPU <= cutorch.getDeviceCount(), 'number of GPUs less than nGPU specified')
      local model_single = model
      --[[
      model = nn.DataParallelTable(1)
      for i=1, nGPU do
         cutorch.setDevice(i)
         model:add(model_single:clone():cuda(), i)
      end
      --]]
   end
   --cutorch.setDevice(opt.GPU)

   return model
end

model = loadDataParallel(opt.model, opt.nGPU)
