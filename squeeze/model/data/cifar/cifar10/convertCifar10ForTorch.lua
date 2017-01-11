
--local dl = require 'dataload'

--train, valid, test = dl.loadCIFAR10([datapath, validratio, scale, srcurl])

--obj = torch.load('./data_batch_' .. (0+1) .. '.bin')

--for i = 0,4 do
--   subset = torch.load('./data_batch_' .. (i+1) .. '.bin', 'ascii')
--   trainData.data[{ {i*10000+1, (i+1)*10000} }] = subset.data:t()
--   trainData.labels[{ {i*10000+1, (i+1)*10000} }] = subset.labels
--end

--print(trainData)

require 'torch'

local function convertCifar10BinToTorchTensor(inputFnames, outputFname)
   local nSamples = 0
   for i=1,#inputFnames do
      local inputFname = inputFnames[i]
      local m=torch.DiskFile(inputFname, 'r'):binary()
      m:seekEnd()
      local length = m:position() - 1
      local nSamplesF = length / 3073 -- 1 label byte, 3072 pixel bytes
      assert(nSamplesF == math.floor(nSamplesF), 'expecting numSamples to be an exact integer')
      nSamples = nSamples + nSamplesF
      m:close()
   end

   local label = torch.ByteTensor(nSamples)
   local data = torch.ByteTensor(nSamples, 3, 32, 32)

   local index = 1
   for i=1,#inputFnames do
      local inputFname = inputFnames[i]
      local m=torch.DiskFile(inputFname, 'r'):binary()
      m:seekEnd()
      local length = m:position() - 1
      local nSamplesF = length / 3073 -- 1 label byte, 3072 pixel bytes
      m:seek(1)
      for j=1,nSamplesF do
	 label[index] = m:readByte()
	 local store = m:readByte(3072)
	 data[index]:copy(torch.ByteTensor(store))
	 index = index + 1
      end
      m:close()
   end

   local out = {}
   out.data = data
   out.label = label
   print(out)
   torch.save(outputFname, out)
end

convertCifar10BinToTorchTensor({'./data_batch_1.bin',
				'./data_batch_2.bin',
				'./data_batch_3.bin',
				'./data_batch_4.bin',
				'./data_batch_5.bin'},
   'cifar10-train.t7')


convertCifar10BinToTorchTensor({'./test_batch.bin'},
   'cifar10-test.t7')

