local class = require 'class'
local cairo = require 'cairo'
local argcheck = require 'argcheck'

local HBox, Widget = class.new('gui.HBox', 'gui.Widget')

HBox.__init =
   argcheck(
   {{name="self", type="gui.HBox"},
    {name="parent", type="gui.Widget"},
    {name="attr", type="table", opt=true}},
   function(self, parent, attr)
      Widget.__init(self,
                    parent,
                    {hfill=false, vfill=false, padding=10, spacing=10, align='center', autospacing=true},
                    attr)
   end
)

HBox.sizeRequest =
   argcheck(
   {{name="self", type="gui.HBox"}},
   function(self)
      local w = 0
      local h = 0
      for _, widget in ipairs(self.children) do
         local ww, wh = widget:sizeRequest()
         w = w + ww
         h = math.max(h, wh)
      end
      w = w + 2*self.attr.padding + (#self.children-1)*self.attr.spacing
      h = h + 2*self.attr.padding
      return w, h
   end
)

HBox.onSetGeometry =
   argcheck(
   {{name="self", type="gui.HBox"},
    {name="x", type="number"},
    {name="y", type="number"},
    {name="w", type="number", opt=true},
    {name="h", type="number", opt=true}},
   function(self, x, y, w, h)
      local rw, rh = self:sizeRequest()
      local spacing = self.attr.spacing
      local padding = self.attr.padding
      local leftw = math.max(0, w-rw)
      local leftn = 0
      if leftw > 0 then
         for _, widget in ipairs(self.children) do
            if widget.attr.hfill then
               leftn = leftn + 1
            end
         end
         if leftn == 0 and self.attr.autospacing then
            spacing = spacing + leftw/(#self.children+1)
            padding = padding + leftw/(#self.children+1)
         else
            leftw = leftw/leftn
         end
      end
      x = x + padding
      y = y + self.attr.padding
      w = w - 2*padding
      h = h - 2*self.attr.padding
      for _, widget in ipairs(self.children) do
         local rw, rh = widget:sizeRequest()
         if widget.attr.hfill and leftw > 0 then
            rw = rw + leftw
         end
         if rh < h and widget.attr.vfill then
            rh = h
         end
         rw = math.min(rw, w)
         rh = math.min(rh, h)

         if self.attr.align == 'top' then
            widget:setGeometry(x, y, rw, rh)
         elseif self.attr.align == 'bottom' then
            widget:setGeometry(x, y+h-rh, rw, rh)
         elseif self.attr.align == 'center' then
            widget:setGeometry(x, y+(h-rh)/2, rw, rh)
         else
            error(string.format('%s: invalid align attribute value <%s> (valid are: center, top, bottom)', class.type(self), self.attr.align))
         end

         x = x + rw + spacing
         w = math.max(0, w - spacing - rw)
      end
   end
)

function HBox:onDraw()
   if self.__debug then
      local cr = self.window.drv.cr
      cr:setLineWidth(2)
      cr:setSourceRGBA(1, 0, 0, 0.5)
      cr:rectangle(self.x, self.y, self.w, self.h)
      cr:stroke()
   end
end

return HBox
