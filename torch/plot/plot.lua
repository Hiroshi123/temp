
require "gnuplot"


local Plot = require 'class'


function Plot:plot(epoch,trainLog,validLog,testLog)
   
   --local train = data.train
   
   gnuplot.figure(1)
   gnuplot.title(opt.title)
   
   if(opt.imageFileExtension == "png") then
      gnuplot.pngfigure(opt.plotDir .. "/" .. opt.chartFileName .. ".png")
   end
   
   if(opt.imageFileExtension == "eps") then
      gnuplot.pngfigure(opt.plotDir .. "/" .. opt.chartFileName .. ".eps")
   end
   
   if(opt.imageFileExtension == "pdf") then
      gnuplot.epsfigure(opt.plotDir .. "/" .. opt.chartFileName .. ".pdf")
   end
   
   if(opt.imageFileExtension == "svg") then
      gnuplot.svgfigure(opt.plotDir .. "/" .. opt.chartFileName .. ".svg")
   end
   
   
   gnuplot.plot(
      {'train',trainLog[{{1,epoch}}],'-'},
      {'validation',validLog[{{1,epoch}}],'-'},
      {'test',testLog[{{1,epoch}}],'-'})
   
   
   gnuplot.xlabel('Epoch (times)')
   gnuplot.ylabel('Accuracy')
   gnuplot.plotflush()   
   
end

return Plot

