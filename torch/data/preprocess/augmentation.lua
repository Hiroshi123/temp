
require 'image'

local Augmentation =  require 'class'


function Augmentation:init()

   torch.manualSeed(0)

end

function Augmentation:randomCrop(img,resW,resH)
   
   image.crop(img, 0, 0 ,torch.random() % resW, torch.random() % resH)
   
   return img
   
end

function Augmentation:randomTranslate(img)
   
   image.translate(img)
   
end

function Augmentation:randomRotate(img)

   image.rotate(img)

end

function Augmentation:run()
   
end



return Augmentation

