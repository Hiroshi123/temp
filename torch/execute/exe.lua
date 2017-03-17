
local Train =  require 'class' --torch.class('')


function Train:init(model,data)
   
   if opt.cuda == 1 then
      self.model = model:cuda()
   else 
      self.model = model
   end
   
   if opt.cuda == 1 then
      self.criterion = nn.MSECriterion():cuda()
   else
      self.criterion = nn.MSECriterion()
   end
   
   self.train_input = data.train.input
   self.train_label = data.train.label
   self.validation_input = data.validation.input
   self.validation_label = data.validation.label   
   self.test_input = data.test.input
   self.test_label = data.test.label

   self.batchSize = opt.batchSize

   self.iterationN = 10
   self.epochN = opt.epoch

   self.LR = opt.LR
   
   --print(self.input:size()[1] / self.batchSize)
   
   self.trainLog = torch.Tensor(self.epochN)
   self.validationLog = torch.Tensor(self.epochN)
   self.testLog = torch.Tensor(self.epochN)   
   self.log = torch.Tensor(self.epochN)
   
end

function Train:run(epoch,mode)
   
   if(mode == "train") then
      self.input = self.train_input --:cuda()
      self.label = self.train_label --:cuda()
      self.log = self.trainLog
      print("==== TRAIN =====")
      print("epoch ", epoch)
      print("")

   elseif (mode == "validation") then
      self.input = self.validation_input
      self.label = self.validation_label
      self.log = self.validationLog
      print("==== VALIDATION =====")
      print("epoch ", epoch)
      print("")

   elseif (mode == "test") then
      self.input = self.test_input
      self.label = self.test_label
      self.log = self.testLog
      print("==== TEST =====")
      print("epoch ", epoch)
      print("")
      
   end   

   print(self.input:size()[1] / self.batchSize)
   
   local iteration = torch.floor(self.input:size()[1] / self.batchSize)
   
   local errors = 0
   local errorN = 0

   for i = 1,iteration do
      
      local input_batch = self.input[{{1 + (i-1)*self.batchSize ,i*self.batchSize}}]
      local label_batch = self.label[{{1 + (i-1)*self.batchSize ,i*self.batchSize}}]

      --set to cuda tensor if gpu mode      
      
      if opt.cuda == 1 then
	 input_batch = input_batch:cuda()
	 label_batch = label_batch:cuda()
      end

      --print(input_batch)

      local loss_x = self.criterion:forward(self.model:forward(input_batch),label_batch)
      errors = errors + loss_x
      
      local maxV,indexX   = torch.max(self.model.output,2)
      local labelV,indexY = torch.max(label_batch,2)
      
      for i = 1,self.batchSize do
	 if(indexX[{i,1}] ~= indexY[{i,1}]) then
	    errorN = errorN + 1
	 end
      end
      
      -- print(indexX,indexY)
      --self.model:zeroGradParameters()

      if(mode == "train") then
	 self.model:zeroGradParameters()
   	 self.model:backward(input_batch, self.criterion:backward(self.model.output, label_batch))
   	 self.model:updateParameters(self.LR)
      end
   end
   
   print("errors : ",errors)
   
   local errorRate = errorN / self.input:size()[1]
   local accuracy  = 1 - errorRate
   
   print("rate : ",  accuracy)
   
   self.log[epoch] = accuracy
   
   return self.log
   
end


return Train


