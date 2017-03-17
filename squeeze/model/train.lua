

--trainer = nn.StochasticGradient(model, criterion)
--trainer:train(inputs)

params, gradParams = model:getParameters()

print(params:size())
print(gradParams:size())

learningRate = 0.1

--function train(model,criterion,inputData,targets)

function train()

   print(targets[1])
   output = model:forward(inputs[1])   
   local f = criterion:forward(output, targets[1])
   model:zeroGradParameters()
   local gradCriterion = criterion:backward(output, targets[1])
   --print(gradCriterion)
   model:backward(inputs[1], gradCriterion)
   --print(gradParams[10])
   --print(params[10])
   params:add(-learningRate, gradParams)
   
   --model:updateParameters(learningRate)
   
end


