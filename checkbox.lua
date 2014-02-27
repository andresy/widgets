local class = require 'class'
local cairo = require 'cairo'
local argcheck = require 'argcheck'

local Checkbox, Widget = class.new('gui.Checkbox', 'gui.Widget')

Checkbox.__init =
   argcheck(
   {{name="self", type="gui.Checkbox"},
    {name="parent", type="gui.Widget"},
    {name="label", type="string"},
    {name="attr", type="table", opt=true}},
   function(self, parent, label, attr)
      Widget.__init(self,
                    parent,
                    false,
                    {hfill=false, vfill=false, label=label, padding=5, size=10, checked=false},
                    attr)
   end
)

function Checkbox:setLabel(label)
   if label ~= self.attr.label then
      self.attr.label = label
      self:updateGeometry()
   end
end

function Checkbox:wishSize()
   local cr = self.window.cr
   cr:setFontSize(self.attr.fontsize)
   local w = cr:textExtents(self.attr.label).width + 2*self.attr.padding + self.attr.size + cr:textExtents('X').width
   local h = math.max(self.attr.size, cr:fontExtents().height) + 2*self.attr.padding
   return w, h
end
   
function Checkbox:draw()
   local cr = self.window.cr
   if self.__w > 0 and self.__h > 0 then
      local rw, rh = self:wishSize()
      local w = math.max(self.__w, rw)
      local h = math.max(self.__h, rh)
      local size = self.attr.size
      local padding = self.attr.padding

      cr:save()
      cr:translate(self.__x, self.__y)
      cr:rectangle(0, 0, self.__w, self.__h)
      cr:clip()

      if self.__debug then
         cr:rectangle(0, 0, self.__w, self.__h)
         cr:setSourceRGBA(1, 0, 0, 0.5)
         cr:stroke()
      end
      cr:setLineWidth(1)
      cr:setSourceRGB(0.8, 0.8, 0.8)

      self.__cx = w/2-rw/2+padding+self.__x
      self.__cy = h/2-size/2+self.__y

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

function Checkbox:__onMouseButton(x, y)
   Widget.__onMouseButton(self, x, y)
   if self:__isHover(x, y) then
      if x >= self.__cx and x <= self.__cx+self.attr.size and
         y >= self.__cy and y <= self.__cy+self.attr.size then
         self.attr.checked = not self.attr.checked
      end
   end
end

return Checkbox
