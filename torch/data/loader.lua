
local Loader = require 'class'

function Loader:shuffle(tensor)

   local input = tensor.input
   local label = tensor.label
   
   local shuffle_indexes = torch.randperm(input:size(1))
   
   local input_shuffled = torch.Tensor(input:size())
   local label_shuffled = torch.Tensor(label:size())
   
   for i=1,input:size(1),1 do
      input_shuffled[i] = input[shuffle_indexes[i]]
      label_shuffled[i] = label[shuffle_indexes[i]]
   end
   
   --tensor.input = input_shuffled
   --tensor.label = label_shuffled
   
   return input_shuffled,label_shuffled
   

end


function Loader:splitDataSet(input,label)

   local trainN = torch.floor(input:size(1)*opt.trainDataRate)
   local valN   = torch.floor(input:size()[1]*opt.validationDataRate)
   local testN  = input:size()[1] - (valN + trainN)
   
   
   local data = {
      train = {
	 input = input[{{1,trainN}}],
	 label = label[{{1,trainN}}]
      },
      validation = {
	 input = input[{{trainN+1,trainN + valN}}],
	 label = label[{{trainN+1,trainN + valN}}]
      },
      test = {
	 input = input[{{trainN + valN + 1, trainN + valN + testN}}],
	 label = label[{{trainN + valN + 1, trainN + valN + testN}}]
      }
   }
   
   return data
   
end


function Loader:load()
   
   local data = torch.load(paths.concat(opt.dataDir , opt.dataFileName))
   
   opt.inputW = data.input:size()[3]
   opt.inputH = data.input:size()[4]
   opt.teacherN = data.label:size()[2]

   local input,label = Loader:shuffle(data)   
   local data = Loader:splitDataSet(input,label)

   return data

end

return Loader



