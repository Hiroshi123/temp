

--command line option --

local Opt = require 'class'

function Opt:__init()
   
end

function Opt:get()
   
   cmd = torch.CmdLine()
   cmd:addTime()
   cmd:text()
   cmd:text('Training a convolutional network for visual classification')
   cmd:text()
   cmd:text('==>Options')
   
   cmd:option('-trainDataRate',0.8,          'rate of training data')
   cmd:option('-validationDataRate',0.1,     'rate of validation data')
   
   cmd:text('===>options for data-set')
   
   cmd:option('-dataDir',     '/home/leapmind/project/gfk-deep-insight/torch/data/data/united/','path to data.t7')
   cmd:option('-dataFileName', 'data.t7',    'name of data files')

   cmd:option('-cuda',1, 'cuda')

   cmd:text('===>options for model setting')

   cmd:option('-modelsFolder',       './Models/',            'Models Folder')

   cmd:text('===>options for model parameters')   
   
   cmd:option('-layerN',       2,            'number of layer')
   cmd:option('-stcNeurons',         true,   'batch size')
   cmd:option('-stcWeights',         false,  'batch size')   
   
   cmd:option('-inputW',       64,            'resolution width')
   cmd:option('-inputH',       64,            'resolution height')
   cmd:option('-widthRate',    1.0,            'resolution width')
   cmd:option('-layerN',       5,            'resolution height')
   
   cmd:text('===>options for running')
   
   cmd:option('-LR',                 0.1,                    'learning rate')
   cmd:option('-LRDecay',            0,                     'learning rate decay (in # samples)')
   cmd:option('-weightDecay',        0.0,                   'L2 penalty on the weights')
   cmd:option('-momentum',           0.0,                    'momentum')

   cmd:option('-batchSize',          2,                    'batch size')
   cmd:option('-SBN',                true,                   'shift based batch-normalization')
   cmd:option('-runningVal',         true,                    'use running mean and std')
   cmd:option('-iterationN',          10,                     'iteration N')
   cmd:option('-epochN',              10,                     'number of epochs to train, -1 for unbounded')
   cmd:option('-optimization',       'adam',                  'optimization method')
   

   cmd:text("====> option for plotting")
   cmd:option('-plotDir',               '/home/leapmind/project/gfk-deep-insight/torch/result', 'save directory')
   cmd:option('-visualize',1,'visualizing results')
   cmd:option('-title','model1','a name of title of a chart')
   cmd:option('-imageFileExtension','svg','image file extension, among png,svg,eps,pdf')
   cmd:option('-chartFileName','chart1','when you save a plot, what do you call it?')
   
   local opt = cmd:parse(arg or {})

   return opt

end

return Opt
