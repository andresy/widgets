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
      self:__initAttributes({width=0, height=0, fullscreen=false, title="", resizable=false, color={r=0.9, g=0.9, b=0.9}})
      self:setAttributes({title=title})
      if attr then
         self:setAttributes(attr)
      end
   end
)

Window.setGeometry =
   argcheck(
   {{name="self", type="gui.Widget"},
    {name="x", type="number"},
    {name="y", type="number"},
    {name="w", type="number"},
    {name="h", type="number"}},
   function(self, x, y, w, h)
      Widget.setGeometry(self, x, y, w, h)
      if x >= 0 and y >= 0 and self.__win then
         sdl.setWindowPosition(self.__win, x, y)
      end
      self.attr.width=w
      self.attr.height=h
      self:updateGeometry()
   end
)

Window.draw =
   argcheck(
   {{name="self", type="gui.Window"}},
   function(self)
      if self.__updategeometry and self.child then
         if not self.__win then
            local imgsurf = cairo.ImageSurface("rgb24", 800, 600) -- dummy
            self.cr = cairo.Context(imgsurf)
         end

         local w, h
         if self.attr.width > 0 and self.attr.height > 0 then
            w, h = self.attr.width, self.attr.height
         else
            w, h = self.child:wishSize()
         end

         if self.__win then
            sdl.setWindowSize(self.__win, w, h)
         else
            local flags = 0
            if self.attr.fullscreen then
               flags = bit.bor(flags, sdl.WINDOW_FULLSCREEN)
            end
            if self.attr.resizable then
               flags = bit.bor(flags, sdl.WINDOW_RESIZABLE)
            end
            self.__win = sdl.createWindow(self.attr.title, sdl.WINDOWPOS_CENTERED, sdl.WINDOWPOS_CENTERED, w, h, flags)
         end

         local surf = sdl.getWindowSurface(self.__win)
         local cairosurf = cairo.ImageSurface(surf.pixels,
                                              "rgb24",
                                              w,
                                              h,
                                              surf.pitch)

         self.cr = cairo.Context(cairosurf)

         self.child:setGeometry(0, 0, w, h)

         self.__x = 0
         self.__y = 0
         self.__w = w
         self.__h = h
         self.__updategeometry = false
      end

      local color = self.attr.color
      self.cr:setSourceRGB(color.r, color.g, color.b)
      self.cr:rectangle(0, 0, self.__w, self.__h)
      self.cr:fill()

      self.child:draw()

      if self.__win then
         sdl.updateWindowSurface(self.__win)
      end
   end
)

Window.updateGeometry =
   argcheck(
   {{name="self", type="gui.Window"}},
   function(self)
      self.__updategeometry = true
   end
)

Window.isGeometryReady =
   argcheck(
   {{name="self", type="gui.Window"}},
   function(self)
      return (not self.__updategeometry)
   end
)

return Window
