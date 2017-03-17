
-- opt.layerN = 10

VGG =  require 'class' --torch.class('')

--VGG = MM()

function VGG:__init()
   --self.default = {3,128,128,256,256,512,512}
end


function VGG:init()

   self.model = nn.Sequential()
   
   self.inputW = opt.inputW
   self.inputH = opt.inputH
   self.resW = self.inputW
   self.resH = self.inputH
   
   self.fcH = 3
   
   -- opt.inputW = 64
   -- opt.inputH = 64
   -- opt.widthRate = 1.0
   -- opt.layerN = 5
   
   self.fcStructure = {512,100,opt.teacherN}
   
   --self.fcW = 512   
   --self.structure = {}
   
   self.structure = {3,128 * opt.widthRate,128* opt.widthRate,256* opt.widthRate,
		     256* opt.widthRate,512* opt.widthRate,512* opt.widthRate,512* opt.widthRate}

   -- for i in 1,opt.layerN do   
   -- end
   --opt.type = 'cuda'

   opt.cuda = 1
   
   print("cuda",opt.cuda)
   
   if(opt.cuda == 1) then
      require 'cunn'
      require 'cudnn'
      print("cuda is true")
      self.SC = cudnn.SpatialConvolution
      self.SM = cudnn.SpatialMaxPooling
      self.SB = cudnn.SpatialBatchNormalization
      self.BN = cudnn.BatchNormalization
      self.ReLU = cudnn.ReLU()
   else 
      self.SC = nn.SpatialConvolution
      self.SM = nn.SpatialMaxPooling
      self.SB = nn.SpatialBatchNormalization
      self.BN = nn.BatchNormalization
      self.ReLU = nn.ReLU()
   end
   
end

function VGG:create()
      
   -- convolution layer
   
   for i = 1,opt.layerN do
      
      self.model:add(self.SC(self.structure[i], self.structure[i+1],3,3,1,1,1,1))

      --insert max pooling
      if i % 2 == 0 then
	 self.model:add(self.SM(2, 2))
	 self.resW = self.resW / 2
	 self.resH = self.resH / 2
      end
      
      self.model:add(self.SB(self.structure[i+1]))
      self.model:add(nn.ReLU())
      featureN = self.structure[i+1]      
   end

   -- fully connected layer
   
   self.model:add(nn.View(featureN*self.resW*self.resH))
   self.model:add(nn.Linear(featureN*self.resW*self.resH,self.fcStructure[1]))
   self.model:add(nn.Sigmoid())

   for i = 1,2 do
      
      self.model:add(nn.Linear(self.fcStructure[i],self.fcStructure[i+1]))
      self.model:add(self.BN(self.fcStructure[i+1]))
      self.model:add(nn.Sigmoid())
      
   end
   
   --model:add(nn.SoftMax)   
   
   return self.model
   
end

return VGG
