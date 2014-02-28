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
                    {hfill=false, vfill=false, label=label, padding=10},
                    attr)
      self.flags.hover = false
      self.flags.pressed = false
   end
)

function Button:setLabel(label)
   if label ~= self.attr.label then
      self.attr.label = label
      self:updateGeometry()
   end
end

function Button:sizeRequest()
   local cr = self.window.drv.cr
   cr:setFontSize(self.attr.fontsize)
   local w = cr:textExtents(self.attr.label).width + 2*self.attr.padding
   local h = cr:fontExtents().height + 2*self.attr.padding
   return w, h
end
   
function Button:onDraw()
   local cr = self.window.drv.cr
   if self.w > 0 and self.h > 0 then
      local w, h = self:sizeRequest()
      w = math.max(self.w, w)
      h = math.max(self.h, h)

      cr:save()
      cr:translate(self.x, self.y)
      cr:rectangle(0, 0, self.w, self.h)
      cr:clip()
      
      cr:setLineWidth(1)
      local pat = cairo.LinearGradientPattern(0, 0, 0, h)
      if self.flags.hover then
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

function Button:onButtonHovered()
end

function Button:onButtonUnHovered()
end

function Button:onMouseMotion(x, y)
   local hover = self.flags.hover
   if self:isArea(x, y) then
      if not hover then
         self.flags.hover = true
         self:onButtonHovered()
         self:redraw()
      end
   else
      if hover then
         self.flags.hover = false
         self:onButtonUnHovered()
         self:redraw()
      end
   end
end

function Button:onButtonPressed()
end

function Button:onMouseButton(x, y)
   if self:isArea(x, y) then
      self:onButtonPressed()
   elseif self.flags.pressed then
      self.flags.pressed = false
   end
end

return Button
