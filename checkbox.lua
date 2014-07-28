local class = require 'class'
local cairo = require 'cairo'
local argcheck = require 'argcheck'

local Checkbox, Widget = class.new('gui.Checkbox', 'gui.Widget')

Checkbox.__init = argcheck{
   {name="self", type="gui.Checkbox"},
   {name="parent", type="gui.Widget"},
   {name="label", type="string"},
   {name="attr", type="table", opt=true},
   call =
      function(self, parent, label, attr)
         Widget.__init(self,
                       parent,
                       {hfill=false, vfill=false, label=label, padding=5, size=10, checked=false},
                       attr)
      end
}

function Checkbox:setLabel(label)
   if label ~= self.attr.label then
      self.attr.label = label
      self:updateGeometry()
   end
end

function Checkbox:sizeRequest()
   local cr = self.window.drv.cr
   cr:setFontSize(self.attr.fontsize)
   local w = cr:textExtents(self.attr.label).width + 2*self.attr.padding + self.attr.size + cr:textExtents('X').width
   local h = math.max(self.attr.size, cr:fontExtents().height) + 2*self.attr.padding
   return w, h
end
   
function Checkbox:onDraw()
   local cr = self.window.drv.cr
   if self.w > 0 and self.h > 0 then
      local rw, rh = self:sizeRequest()
      local w = math.max(self.w, rw)
      local h = math.max(self.h, rh)
      local size = self.attr.size
      local padding = self.attr.padding

      cr:save()
      cr:translate(self.x, self.y)
      cr:rectangle(0, 0, self.w, self.h)
      cr:clip()

      if self.debug then
         cr:rectangle(0, 0, self.w, self.h)
         cr:setSourceRGBA(1, 0, 0, 0.5)
         cr:stroke()
      end
      cr:setLineWidth(1)
      cr:setSourceRGB(0.8, 0.8, 0.8)

      self.cx = w/2-rw/2+padding+self.x
      self.cy = h/2-size/2+self.y

      cr:rectangle(w/2-rw/2+padding, h/2-size/2, size, size)
      cr:stroke()

      cr:setSourceRGB(1, 1, 1)
      cr:rectangle(w/2-rw/2+padding, h/2-size/2, size, size)
      cr:fill()

      if self.attr.checked then
         cr:setSourceRGB(118/255, 183/255, 236/255)
         cr:rectangle(w/2-rw/2+padding+2, h/2-size/2+2, size-4, size-4)
         cr:fill()
      end

      cr:setSourceRGB(0, 0, 0)
      local ex = cr:textExtents(self.attr.label)
      cr:moveTo(w/2-rw/2+padding+size+cr:textExtents('X').width, h/2-ex.y_bearing/2)
--      cr:moveTo(w/2+size/2+self.attr.padding, h/2-ex.y_bearing/2)
      cr:showText(self.attr.label)
      cr:restore()
   end
end

function Checkbox:onMouseButton(x, y)
   Widget.onMouseButton(self, x, y)
   if self:isArea(x, y) then
      if x >= self.cx and x <= self.cx+self.attr.size and
         y >= self.cy and y <= self.cy+self.attr.size then
         self.attr.checked = not self.attr.checked
         self:redraw()
      end
   end
end

return Checkbox
