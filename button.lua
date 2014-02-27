local class = require 'class'
local cairo = require 'cairo'
local argcheck = require 'argcheck'

local Button, Widget = class.new('gui.Button', 'gui.Widget')

Button.__init =
   argcheck(
   {{name="self", type="gui.Button"},
    {name="parent", type="gui.Widget"},
    {name="label", type="string"},
    {name="attr", type="table", opt=true}},
   function(self, parent, label, attr)
      Widget.__init(self,
                    parent,
                    false,
                    {hfill=false, vfill=false, label=label, padding=10},
                    attr)
   end
)

function Button:setLabel(label)
   if label ~= self.attr.label then
      self.attr.label = label
      self:updateGeometry()
   end
end

function Button:wishSize()
   local cr = self.window.cr
   cr:setFontSize(self.attr.fontsize)
   local w = cr:textExtents(self.attr.label).width + 2*self.attr.padding
   local h = cr:fontExtents().height + 2*self.attr.padding
   return w, h
end
   
function Button:draw()
   local cr = self.window.cr
   if self.__w > 0 and self.__h > 0 then
      local w, h = self:wishSize()
      w = math.max(self.__w, w)
      h = math.max(self.__h, h)

      cr:save()
      cr:translate(self.__x, self.__y)
      cr:rectangle(0, 0, self.__w, self.__h)
      cr:clip()
      
      cr:setLineWidth(1)
      local pat = cairo.LinearGradientPattern(0, 0, 0, h)
      if self.__hover then
         pat:addColorStopRGB(0, 132/255, 197/255, 253/255)
         pat:addColorStopRGB(1, 118/255, 183/255, 236/255)
      else
         pat:addColorStopRGB(1, 0.8, 0.8, 0.8)
         pat:addColorStopRGB(0, 0.7, 0.7, 0.7)
      end
      cr:rectangle(0, 0, w, h)
      cr:setSource(pat)
      --   cr:setSourceRGB(0.8, 0.8, 0.8)
      cr:fill()
      cr:rectangle(0, 0, w, h)
      cr:setSourceRGB(0.6, 0.6, 0.6)
      cr:stroke()
      --   cr:rectangle(0, 0, w, h)
      --   cr:clip()
      cr:setFontSize(self.attr.fontsize)
      local ex = cr:textExtents(self.attr.label)
      cr:moveTo((w-ex.width)/2, h/2-ex.y_bearing/2)
      cr:setSourceRGB(0, 0, 0)
      cr:showText(self.attr.label)
      cr:restore()
   end
end

function Button:__onMouseMotion(x, y)
   Widget.__onMouseMotion(self, x, y)
   if self:__isHover(x, y) then
      self.__hover = true
   else
      self.__hover = false
   end
end

return Button
