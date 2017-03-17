
require 'image'
local Converter =  require 'class'


function Converter:init()
   
   cmd = torch.CmdLine()
   cmd:addTime()
   cmd:text()
   cmd:text('image file to .t7 format')
   cmd:text()
   cmd:text('==>Options')
   
   cmd:option('-imageFilePath','/home/leapmind/data/others/', 'path of image')
   cmd:option('-saveFilePath', '/home/leapmind/project/gfk-deep-insight/torch/data/data/', 'path of output .t7 data')
   cmd:option('-outFileName','image.t7','output file name')
   cmd:option('resW',64,'resolution width')
   cmd:option('resH',64,'resolution height')
   cmd:option('fileExtension','.jpg','image flle extension')
   cmd:option('','.jpg','image flle extension')
   
   opt = cmd:parse(arg or {})
   
   --opt.saveFilePath = opt.imageFilePath
   --return opt

end

function Converter:convert()

   imageStock = {}

   print("--detect--")

   local count = 0
   for file in paths.files(opt.imageFilePath) do
      if file:find(opt.fileExtension .. '$') then
	 print(file)
	 count = count + 1
	 table.insert(imageStock,file)
      end
   end

   if count == 0 then
      print("No dir detected called ", opt.imageFilePath)
      return 
   end
   
   local ten = torch.Tensor(count,3,opt.resW,opt.resH)
   
   for i = 1,count do
      ten[i] = image.scale(image.load(paths.concat(opt.imageFilePath,imageStock[i])),opt.resW,opt.resH)
   end

   torch.save(paths.concat(opt.saveFilePath,opt.outFileName),ten)

   print("-------")
   print("saved on " , opt.saveFilePath)
   print("-------")

end


local function main()

   Converter:init()
   Converter:convert()

end

main()


