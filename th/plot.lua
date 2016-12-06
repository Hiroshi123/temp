


--[[
ErrTrain = 0.1
ErrTest = 0.1
opt = {
   save = ".",
   title = "example",
   chartFileName = "ex1",
   imageFileExtension = "svg"
}
epoch = 20

tableForTrainPlot = {} 
tableForTestPlot  = {}

sum = 0

function inserts()
   sum = sum + 2
   table.insert(tableForTrainPlot,0.1)   
   table.insert(tableForTestPlot,0.1)
   table.insert(tableForTrainPlot,0.3)   
   table.insert(tableForTestPlot,0.4)
end


--]]

require "gnuplot"

function plotChart()

   gnuplot.figure(1)
   gnuplot.title(opt.title)
   
   --local trainA = torch.Tensor(200)
   --local testA  = torch.Tensor(200)
   --trainA = 

   if(opt.imageFileExtension == "png") then
      gnuplot.pngfigure(opt.save .. "/" .. opt.chartFileName .. ".png")
   end
   
   if(opt.imageFileExtension == "eps") then
      gnuplot.pngfigure(opt.save .. "/" .. opt.chartFileName .. ".eps")
   end
   
   if(opt.imageFileExtension == "pdf") then
      gnuplot.epsfigure(opt.save .. "/" .. opt.chartFileName .. ".pdf")
   end
   
   if(opt.imageFileExtension == "svg") then
      gnuplot.svgfigure(opt.save .. "/" .. opt.chartFileName .. ".svg")
   end
   
   gnuplot.plot({'train',trainA[{{1,epoch}}],'-'},{'test',testA[{{1,epoch}}],'-'})
   
   gnuplot.xlabel('Epoch (times)')
   gnuplot.ylabel('Accuracy')
   gnuplot.plotflush()
   
   
end

--str = io.read()
--plotChart()

--[[
inserts()

inserts()
plotChart()
inserts()
plotChart()
--]]
