
require 'nn'

require 'model'
require 'train'



cmd = torch.CmdLine()
cmd:text()
cmd:text()
cmd:text('Training a simple network')
cmd:text()
cmd:text('Options')
cmd:option('-lr',0.0002,'learning rate')
cmd:option('-bs',1,'batch size')
cmd:option('-ac',100,'accuracy measurement interval')
cmd:option('-ds','cifar10','data set')
cmd:option('-model','model4','model name')
cmd:option('-epoch',1,'epoch times')
cmd:option('-dir','results','a name of output directory')
cmd:option('-threads',1,'number of threads')
cmd:option('-plot',1,'plot')
cmd:option('-title','Accuracy per epoch','title for chart')
cmd:option('-usingSampleN',100,'how many data among dataset you are going to iterate')
cmd:option('-imageFileExtension','svg','image file extension, among png,svg,eps,pdf')
cmd:option('-chartFileName','chart1','when you save a plot, what do you call it?')
cmd:option('-GPU',0,'if you make use of gpu or not')
cmd:text()

opt = cmd:parse(arg)

--folllowing is loading data
if(opt.ds == "mnist") then
   print("mnist is loaded")
   require './data/mnist'
end

require 'load'

setData()
inputs  = torch.reshape(dataset.trainInput,torch.LongStorage{60000,1,28,28})

print(dataset)

--print(torch.load())

--targets = dataset.trainTeacher

--targets = torch.Tensor(10,10):fill(0)


--print(dataset)

--model = createModel(1)

--model = createSimplerModel()
--criterion = nn.MSECriterion()

--print(model)

--require 'train'

--teacher = torch.Tensor(1,10):fill(0)

--print(inputs:size())


--train(dataset.trainInput,dataset.trainTeacher)
--train(inputs,teacher)
--train()
   


--print(dataset)

print("hello world!")



