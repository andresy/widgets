local class = require 'class'
local cairo = require 'cairo'
local argcheck = require 'argcheck'

local VBox, Widget = class.new('gui.VBox', 'gui.Widget')

VBox.__init =
   argcheck(
   {{name="self", type="gui.VBox"},
    {name="parent", type="gui.Widget"},
    {name="attr", type="table", opt=true}},
   function(self, parent, attr)
      Widget.__init(self,
                    parent,
                    {hfill=false, vfill=false, padding=10, spacing=10, align='center', autospacing=true},
                    attr)
   end
)

VBox.sizeRequest =
   argcheck(
   {{name="self", type="gui.VBox"}},
   function(self)
      local w = 0
      local h = 0
      for _, widget in ipairs(self.children) do
         local ww, wh = widget:sizeRequest()
         w = math.max(w, ww)
         h = h + wh
      end
      w = w + 2*self.attr.padding
      h = h + 2*self.attr.padding + (#self.children-1)*self.attr.spacing
      return w, h
   end
)

VBox.onSetGeometry =
   argcheck(
   {{name="self", type="gui.VBox"},
    {name="x", type="number"},
    {name="y", type="number"},
    {name="w", type="number", opt=true},
    {name="h", type="number", opt=true}},
   function(self, x, y, w, h)
      local rw, rh = self:sizeRequest()
      local spacing = self.attr.spacing
      local padding = self.attr.padding
      local lefth = math.max(0, h-rh)
      local leftn = 0
      if lefth > 0 then
         for _, widget in ipairs(self.children) do
            if widget.attr.vfill then
               leftn = leftn + 1
            end
         end
         if leftn == 0 and self.attr.autospacing then
            spacing = spacing + lefth/(#self.children+1)
            padding = padding + lefth/(#self.children+1)
         else
            lefth = lefth/leftn
         end
      end
      x = x + self.attr.padding
      y = y + padding
      w = w - 2*self.attr.padding
      h = h - 2*padding
      for _, widget in ipairs(self.children) do
         local rw, rh = widget:sizeRequest()
         if rw < w and widget.attr.hfill then
            rw = w
         end
         if widget.attr.vfill and lefth > 0 then
            rh = rh + lefth
         end
         rw = math.min(rw, w)
         rh = math.min(rh, h)

         if self.attr.align == 'left' then
            widget:setGeometry(x, y, rw, rh)
         elseif self.attr.align == 'right' then
            widget:setGeometry(x+w-rw, y, rw, rh)
         elseif self.attr.align == 'center' then
            widget:setGeometry(x+(w-rw)/2, y, rw, rh)
         else
            error(string.format('%s: invalid align attribute value <%s> (valid are: center, right, left)', class.type(self), self.attr.align))
         end

         y = y + rh + spacing
         h = math.max(0, h - spacing - rh)
      end
   end
)

function VBox:onDraw()
   if self.__debug then
      local cr = self.window.drv.cr
      cr:setLineWidth(2)
      cr:setSourceRGBA(1, 0, 0, 0.5)
      cr:rectangle(self.x, self.y, self.w, self.h)
      cr:stroke()
   end
end

return VBox
