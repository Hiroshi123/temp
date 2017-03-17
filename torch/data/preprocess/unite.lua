
local UniteT7 =  require 'class'

function UniteT7:init()
   
   cmd = torch.CmdLine()
   cmd:addTime()
   cmd:text()
   cmd:text('image file to .t7 format')
   cmd:text()
   cmd:text('==>Options')
   
   cmd:option('-t7_path','/home/leapmind/project/gfk-deep-insight/torch/data/data/', 'path to t7')
   cmd:option('-saveFilePath', '/home/leapmind/project/gfk-deep-insight/torch/data/data/', 'path of output .t7 data')
   cmd:option('-outFileName','data.t7','output file name')
   cmd:option('resW',64,'resolution width')
   cmd:option('resH',64,'resolution height')
   
   opt = cmd:parse(arg or {})
   
   return opt

end


function UniteT7:run()
   
   local stock = {}
   local count = 0
   local dataN = 0

   --retrieve every .t7 file on designated directory

   for file in paths.files(opt.t7_path) do
      if file:find('.t7' .. '$') then
	 print(file)
	 count = count + 1
	 local a = torch.load(paths.concat(opt.t7_path,file))	 
	 print(a:size()[1])
	 dataN = dataN + a:size()[1]
	 table.insert(stock,a)
      end
   end
   
   --unite every input and create label

   local input = stock[1]
   local label = torch.zeros(dataN,count)
   local cur = 0
   label[{{1,stock[1]:size()[1]},1}] = 1
   
   local cur = stock[1]:size()[1]
   
   if count > 1 then
      for i = 2,count do
	 pre = cur+1
	 cur = cur + stock[i]:size()[1]
	 input = torch.cat(input,stock[i],1)
	 label[ { { pre , cur }, i } ] = 1
      end
   end
   
   local data_table = {
      input = input,
      label = label
   }
   
   torch.save(paths.concat(opt.saveFilePath,opt.outFileName),data_table)

end

local function main()
   
   UniteT7:init()
   UniteT7:run()
   
end

main()

