require 'cunn'
require 'cudnn'
require 'Models/cudnnBinarySpatialConvolution'
require 'Models/SpatialBatchNormalizationShiftPow2'
require 'Models/BatchNormalizationShiftPow2'
require 'Models/BinarizedNeurons'
require 'Models/BinaryLinear'

require 'itorch'


local obj =  torch.load('./Results/model06/Net')

function containsValue(value)
    return _secondaryTable.value ~= nil
end

--int(obj)

print(obj:size())

weightN = 0


storeW = {}

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


thin_nn = obj:clone('weightB')

print(thin_nn:size())

print(storeW)

torch.save('weightB.t7',storeW)

--thin_nn = obj:clone('weight', 'bias', 'gradWeight', 'gradBias')

--thin_nn = obj:clone('weight','bias')
--print(thin_nn:size())


