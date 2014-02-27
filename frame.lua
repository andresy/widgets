local class = require 'class'
local cairo = require 'cairo'
local argcheck = require 'argcheck'

local Frame, Widget = class.new('gui.Frame', 'gui.Widget')

Frame.__init =
   argcheck(
   {{name="self", type="gui.Frame"},
    {name="parent", type="gui.Widget"},
    {name="label", type="string", opt=true},
    {name="attr", type="table", opt=true}},
   function(self, parent, label, attr)
      Widget.__init(self,
                    parent,
                    false,
                    {hfill=false, vfill=false, label="Une Grosse Boite", padding=10, halign='center', valign='center'},
                    attr)
   end
)

function Frame:setLabel(label)
   if label ~= self.attr.label then
      self.attr.label = label
      self:updateGeometry()
   end
end

function Frame:wishSize()
   local cr = self.window.cr
   local w, h = 0, 0
   if self.child then
      w, h = self.child:wishSize()
   end
   w = w + self.attr.padding*4
   h = h + self.attr.padding*4
   return w, h
end

Frame.setGeometry =
   argcheck(
   {{name="self", type="gui.Frame"},
    {name="x", type="number"},
    {name="y", type="number"},
    {name="w", type="number", opt=true},
    {name="h", type="number", opt=true}},
   function(self, x, y, w, h)
      Widget.setGeometry(self, x, y, w, h)

      if self.child then
         local padding = self.attr.padding
         local rw, rh = self:wishSize()
         local wleft = math.max(0, w-rw)
         local hleft = math.max(0, h-rh)
         rw, rh = self.child:wishSize()
         
         if wleft > 0 and self.child.attr.hfill then
            rw = rw+wleft
            wleft = 0
         end
         
         if hleft > 0 and self.child.attr.hfill then
            rh = rh+hleft
            hleft = 0
         end

         local rx = x + self.attr.padding*2
         local ry = y + self.attr.padding*2
         if self.attr.halign == 'center' then
            rx = rx + wleft/2
         elseif self.attr.halign == 'left' then
         elseif  self.attr.halign == 'right' then
            rx = rx + wleft
         else
            error(string.format('%s: invalid align attribute value <%s> (valid are: center, right, left)', class.type(self), self.attr.align))
         end

         if self.attr.valign == 'center' then
            ry = ry + hleft/2
         elseif self.attr.valign == 'top' then
         elseif  self.attr.valign == 'bottom' then
            ry = ry + hleft
         else
            error(string.format('%s: invalid align attribute value <%s> (valid are: center, top, bottom)', class.type(self), self.attr.align))
         end

         self.child:setGeometry(rx, ry, rw, rh)
      end
   end
)

function Frame:draw()
   local cr = self.window.cr
   if self.__w > 0 and self.__h > 0 then
      local w, h = self:wishSize()
      w = math.max(self.__w, w)
      h = math.max(self.__h, h)

      cr:save()
      cr:translate(self.__x, self.__y)
      cr:rectangle(0, 0, self.__w, self.__h)
      cr:clip()

      local padding = self.attr.padding
      if self.attr.label then
         cr:setFontSize(10) -- DEBUG
         local shift = cr:textExtents('X').width
         local ex = cr:textExtents(self.attr.label)
         local height = cr:fontExtents().height
         cr:moveTo(2*padding+2, padding+2)
         cr:lineTo(padding+2, padding+2)
         cr:lineTo(padding+2, padding+2+h-padding*2-2)
         cr:lineTo(padding+2+w-padding*2-2, padding+2+h-padding*2-2)
         cr:lineTo(padding+2+w-padding*2-2, padding+2)
         cr:lineTo(2*padding+2+ex.width+2*shift, padding+2)
         cr:setLineWidth(4)
         cr:setSourceRGB(0.5, 0.5, 0.5)
         cr:stroke()
         cr:moveTo(2*padding+2+shift, padding+2+height+ex.y_bearing)
         cr:showText(self.attr.label)
      else
         cr:rectangle(padding+2, padding+2, w-padding*2-2, h-padding*2-2)
         cr:setLineWidth(4)
         cr:setSourceRGB(0.5, 0.5, 0.5)
         cr:stroke()
      end

      cr:restore()
   end
   Widget.draw(self)
end

function Frame:__onMouseMotion(x, y)
   Widget.__onMouseMotion(self, x, y)
   if self:__isHover(x, y) then
      self.__hover = true
   else
      self.__hover = false
   end
end

return Frame
