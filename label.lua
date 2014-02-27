local class = require 'class'
local cairo = require 'cairo'
local argcheck = require 'argcheck'

local Label, Widget = class.new('gui.Label', 'gui.Widget')

Label.__init =
   argcheck(
   {{name="self", type="gui.Label"},
    {name="parent", type="gui.Widget"},
    {name="label", type="string"},
    {name="attr", type="table", opt=true}},
   function(self, parent, label, attr)
      Widget.__init(self,
                    parent,
                    false,
                    {hfill=false, vfill=false, label=label, padding=0, valign='center', halign='center'},
                    attr)
   end
)

function Label:setLabel(label)
   if label ~= self.attr.label then
      self.attr.label = label
      self:updateGeometry()
   end
end

function Label:wishSize()
   local cr = self.window.cr
   cr:setFontSize(self.attr.fontsize)
   local w = cr:textExtents(self.attr.label).width + 2*self.attr.padding
   local h = cr:fontExtents().height + 2*self.attr.padding
   return w, h
end
   
function Label:draw()
   local cr = self.window.cr
   if self.__w > 0 and self.__h > 0 then
      local w, h = self:wishSize()
      w = math.max(self.__w, w)
      h = math.max(self.__h, h)

      cr:save()
      cr:translate(self.__x, self.__y)
      cr:rectangle(0, 0, self.__w, self.__h)
      cr:clip()

      if self.__debug then
         cr:setSourceRGBA(1, 0, 0, 0.5)
         cr:rectangle(0, 0, self.__w, self.__h)
         cr:stroke()
      end

      cr:setFontSize(self.attr.fontsize)
      local ex = cr:textExtents(self.attr.label)

      local x
      if self.attr.halign == 'center' then
         x = (w-ex.width)/2
      elseif self.attr.halign == 'left' then
         x = self.attr.padding
      elseif self.attr.halign == 'right' then
         x = w - ex.width - self.attr.padding
      else
         error(string.format('%s: invalid halign attribute value <%s> (valid are: center, left, right)', class.type(self), self.attr.align))
      end

      local y
      if self.attr.valign == 'center' then
         y = h/2-ex.y_bearing/2
      elseif self.attr.valign == 'top' then
         y = self.attr.padding-ex.y_bearing
      elseif self.attr.valign == 'bottom' then
         y = h - ex.height - ex.y_bearing - self.attr.padding
      else
         error(string.format('%s: invalid valign attribute value <%s> (valid are: center, top, bottom)', class.type(self), self.attr.align))
      end

      cr:moveTo(x, y)
      cr:setSourceRGB(0, 0, 0)
      cr:showText(self.attr.label)
      cr:restore()
   end
end

return Label
