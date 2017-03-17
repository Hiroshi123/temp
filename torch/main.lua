

require 'torch'
require 'xlua'
require 'optim'
require 'gnuplot'
require 'nn'
require 'class'


function modelSet()
   
   VGG = require 'model/vgg'
   VGG:init(opt)
   local vgg = VGG:create()   
   return vgg
   
end

function dataSet()
   local Loader = require 'data/loader'
   return Loader:load()
end

function run(data,model)

   opt.epoch = 20
   
   local Train = require 'execute/exe'
   Train:init(model,data)

   local Plot = require 'plot/plot'
   
   for i = 1,opt.epoch do

      local trainLog = Train:run(i,"train")
      local validLog = Train:run(i,"validation")
      local testLog  = Train:run(i,"test")
      
      Plot:plot(i,trainLog,validLog,testLog)
      
   end
   
   --Train:run("validation")
   --Train:run("test")
   
end


function main()

   -- parameter setting --

   Opt = require 'cmd_option/opts'
   opt = Opt:get()      
   print(opt)

   -- data setting --

   local data = dataSet()
   print(data)

   -- model setting -- 
   
   local model = modelSet()
   print(model)
   
   -- run!!! --

   run(data,model)
   
end

main()
