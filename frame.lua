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

function Frame:sizeRequest()
   local cr = self.window.drv.cr
   local w, h = 0, 0
   if self.children[1] then
      w, h = self.children[1]:sizeRequest()
   end
   w = w + self.attr.padding*4
   h = h + self.attr.padding*4
   return w, h
end

Frame.onSetGeometry =
   argcheck(
   {{name="self", type="gui.Frame"},
    {name="x", type="number"},
    {name="y", type="number"},
    {name="w", type="number", opt=true},
    {name="h", type="number", opt=true}},
   function(self, x, y, w, h)
      if self.children[1] then
         local padding = self.attr.padding
         local rw, rh = self:sizeRequest()
         local wleft = math.max(0, w-rw)
         local hleft = math.max(0, h-rh)
         rw, rh = self.children[1]:sizeRequest()
         
         if wleft > 0 and self.children[1].attr.hfill then
            rw = rw+wleft
            wleft = 0
         end
         
         if hleft > 0 and self.children[1].attr.hfill then
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

         self.children[1]:setGeometry(rx, ry, rw, rh)
      end
   end
)

function Frame:onDraw()
   local cr = self.window.drv.cr
   if self.w > 0 and self.h > 0 then
      local w, h = self:sizeRequest()
      w = math.max(self.w, w)
      h = math.max(self.h, h)

      cr:save()
      cr:translate(self.x, self.y)
      cr:rectangle(0, 0, self.w, self.h)
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
end

return Frame
