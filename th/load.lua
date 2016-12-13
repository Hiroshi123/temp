require 'cunn'
require 'cudnn'
require 'Models/cudnnBinarySpatialConvolution'
require 'Models/SpatialBatchNormalizationShiftPow2'
require 'Models/BatchNormalizationShiftPow2'
require 'Models/BinarizedNeurons'
require 'Models/BinaryLinear'
--require 'itorch'

cmd = torch.CmdLine()
cmd:option('-pass','./Results/Cifar100/model06','pass')
cmd:option('-nGPU',1,'')
cmd:option('-GPU',1,'')

opt = cmd:parse(arg or {})

dir = opt.pass

ps = paths.concat(opt.pass,'Net')

cutorch.setDevice(1)
cutorch.setHeapTracking(true)

if opt.GPU == 1 then
   TensorType = 'torch.CudaTensor'
   if opt.nGPU > 1 then
      model = nn.DataParallelTable(1)
      for i = 1, opt.nGPU do
	 cutorch.setDevice(i)
	 --model:add(net:clone():cuda(), i)  -- Use the ith GPU
      end
    end
end

local obj =  torch.load(ps)

function containsValue(value)
    return _secondaryTable.value ~= nil
end

--int(obj)

print(obj:size())

function makeDataParallel(model, nGPU)

      print('converting module to nn.DataParallelTable')
      assert(nGPU <= cutorch.getDeviceCount(), 'number of GPUs less than nGPU specified')
      local model_single = model
      
      model = nn.DataParallelTable(1)
      for i=1, nGPU do
         cutorch.setDevice(i)
         model:add(model_single:clone():cuda(), i)
      end      

   --cutorch.setDevice(opt.GPU)
   return model
end


if torch.type(obj) == 'nn.DataParallelTable' then
   print("huuuuuu")
   obj = obj:get(1):float()
   --obj = 
   makeDataParallel(obj:get(1):float(), opt.nGPU)
   print(obj:size())
end


weightN = 0


storeW = {}

print(obj)

--local net = model


for i=1,obj:size() do
   
   --int(weights:size())
   --print(obj:get(i))
   --print(type(obj:get(i).weight))-- ~= nil
   --print(type(obj:get(i).weightB))

   
   if(type(obj:get(i).weight) == "userdata") then
      print("weight",obj:get(i))
      weightN = weightN + 1
      print(obj:get(i).weight:size())
   end
   
   if(type(obj:get(i).weightB) == "userdata") then
      print("b",obj:get(i))
      --itorch.image(obj:get(i).weightB)
      --weightN = weightN + 1
      table.insert(storeW,obj:get(i).weightB:byte())
      if(i == 1) then
	 local filters = obj:get(i).weightB:float()
	 filters = filters:transpose(1,2)
	 print(filters:size())
	 --[[
	 for j=1,3 do

	    filter = filters[j]

	    filter = torch.reshape(filter,filter:size()[1],1,filter:size()[2],filter:size()[3])
	    if(j == 1) then
	       image.save("filters1.png", image.toDisplayTensor{input=filter})
	    end

	    if( j == 2) then
	       image.save("filters2.png", image.toDisplayTensor{input=filter})
	    end
	    if( j == 3) then
	       image.save("filters3.png", image.toDisplayTensor{input=filter})
	    end
	    
	 end
	 
	 --print("DEDDDDDDDDDDDDDDDDDDDDD",filters:size())
	 --]]
      end

      print(obj:get(i).weight:size())
   end
   

   --[[
   if (string.find(obj:get(i).name, 'cudnn')) then
      print("cudnn")
   end
   --]]
   --print(obj:get(i))
   --if(obj:get(i).containsValue == "weight") then
   --   print("hi")
   --end

end

local weights, gradients = obj:getParameters()

print(weightN)

print(weights:size())
print(gradients:size())

--print(obj:listModules())


--thin_nn = obj:clone('weightB')
--print(thin_nn:size())
print(storeW)

saveDir = paths.concat(dir,'weightB.t7')

torch.save(saveDir,storeW)


--thin_nn = obj:clone('weight', 'bias', 'gradWeight', 'gradBias')

--thin_nn = obj:clone('weight','bias')
--print(thin_nn:size())


