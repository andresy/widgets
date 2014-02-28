local class = require 'class'
local cairo = require 'cairo'
local argcheck = require 'argcheck'
local sdl = require 'sdl2'

local Window, Widget = class.new('gui.Window', 'gui.Widget')

Window.__init =
   argcheck(
   {{name="self", type="gui.Window"},
    {name="title", type="string"},
    {name="attr", type="table", opt=true}},
   function(self, parent, attr)
      self.window = self
      self.children = {}
      self.drv = {}
      self.flags = {nochild=false, onechild=true, hidden=false, undersized=false, dirty=false, updategeometry=false} -- DEBUG
      self:__initAttributes({fullscreen=false, title="", resizable=false, color={r=0.9, g=0.9, b=0.9}})
      self:setAttributes({title=title})
      if attr then
         self:setAttributes(attr)
      end
   end
)

Window.onSetGeometry =
   argcheck(
   {{name="self", type="gui.Widget"},
    {name="x", type="number"},
    {name="y", type="number"},
    {name="w", type="number"},
    {name="h", type="number"}},
   function(self, x, y, w, h)
      if x >= 0 and y >= 0 and self.drv.window then
         sdl.setWindowPosition(self.drv.window, x, y)
      end
      if self.children[1] then
         self.children[1]:setGeometry(0, 0, w, h)
      end
   end
)

function Window:sizeRequest()
   if self.attr.resizable and self.w and self.h then
      return self.w, self.h
   else
      if self.children[1] then
         return self.children[1]:sizeRequest()
      else
         return 0, 0
      end
   end
end

Window.onDraw =
   argcheck(
   {{name="self", type="gui.Window"}},
   function(self)
      print('geometry update?', self.flags.updategeometry)
      if self.flags.updategeometry then

         if not self.drv.window then
            local imgsurf = cairo.ImageSurface("rgb24", 800, 600) -- dummy
            self.drv.cr = cairo.Context(imgsurf)
         end

         local w, h = self:sizeRequest()

         self:setGeometry(-1, -1, w, h)
      end

      local color = self.attr.color
      self.drv.cr:setSourceRGB(color.r, color.g, color.b)
      self.drv.cr:rectangle(0, 0, self.w, self.h)
      self.drv.cr:fill()
   end
)

function Window:setGeometry(x, y, w, h)
   if self.drv.window then
      sdl.setWindowSize(self.drv.window, w, h)
   else
      local flags = 0
      if self.attr.fullscreen then
         flags = bit.bor(flags, sdl.WINDOW_FULLSCREEN)
      end
      if self.attr.resizable then
         flags = bit.bor(flags, sdl.WINDOW_RESIZABLE)
      end
      self.drv.window = sdl.createWindow(self.attr.title, sdl.WINDOWPOS_CENTERED, sdl.WINDOWPOS_CENTERED, w, h, flags)
   end

   local surf = sdl.getWindowSurface(self.drv.window)
   local cairosurf = cairo.ImageSurface(surf.pixels,
                                        "rgb24",
                                        w,
                                        h,
                                        surf.pitch)

   self.drv.cr = cairo.Context(cairosurf)

   Widget.setGeometry(self, x, y, w, h)
   self.flags.updategeometry = false
end

Window.updateGeometry =
   argcheck(
   {{name="self", type="gui.Window"}},
   function(self)
      self.flags.updategeometry = true
      self:redraw()
   end
)

Window.isGeometryReady =
   argcheck(
   {{name="self", type="gui.Window"}},
   function(self)
      return (not self.flags.updategeometry)
   end
)

function Window:redraw()
   self.flags.dirty = true
end

return Window
