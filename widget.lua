local class = require 'class'
local argcheck = require 'argcheck'

local Widget = class.new('gui.Widget')

Widget.__init =
   argcheck(
   {{name="self", type="gui.Widget"},
    {name="parent", type="gui.Widget"}, 
    {name="iscontainer", type="boolean"},
    {name="attr", type="table"},
    {name="attrset", type="table", opt=true}},
   function(self, parent, iscontainer, attr, attrset)
      self.parent = parent
      self.window = self.parent.window
      self:__initAttributes{fontsize=12}
      self:__initAttributes(attr)
      if attrset then
         self:setAttributes(attrset)
      end
      if iscontainer then
         self.children = {}
      end
      parent:setChild(self)
   end
)

Widget.setChild =
   argcheck(
   {{name="self", type="gui.Widget"},
    {name="child", type="gui.Widget"}},
   function(self, child)
      if self.children then
         table.insert(self.children, child)
      else
         self.child = child
      end
      self:updateGeometry()
   end
)

Widget.__initAttributes =
   argcheck(
   {{name="self", type="gui.Widget"},
    {name="attr", type="table"}},
   function(self, attr)
      self.attr = self.attr or {}
      for k,v in pairs(attr) do
         if not type(k) == 'string' then
            error(string.format('%s: attribute name must be a string', class.type(self)))
         end
         self.attr[k] = v
      end
   end
)

Widget.setAttributes =
   argcheck(
   {{name="self", type="gui.Widget"},
    {name="attr", type="table"}},
   function(self, attr)
      for k,v in pairs(attr) do
         if self.attr[k] == nil then
            error(string.format('%s: invalid attribute <%s>', class.type(self), k))
         end
         self.attr[k] = v
      end
   end
)

Widget.setGeometry =
   argcheck(
   {{name="self", type="gui.Widget"},
    {name="x", type="number"},
    {name="y", type="number"},
    {name="w", type="number", opt=true},
    {name="h", type="number", opt=true}},
   function(self, x, y, w, h)
      self.__x = x
      self.__y = y
      if w then
         self.__w = w
      end
      if h then
         self.__h = h
      end
   end
)

Widget.updateGeometry =
   argcheck(
   {{name="self", type="gui.Widget"}},
   function(self)
      self.window:updateGeometry()
   end
)

Widget.isGeometryReady =
   argcheck(
   {{name="self", type="gui.Widget"}},
   function(self)
      return self.window:isGeometryReady()
   end
)

Widget.__isHover =
   argcheck(
   {{name="self", type="gui.Widget"},
    {name="x", type="number"},
    {name="y", type="number"}},
   function(self, x, y)
      if not self:isGeometryReady() then
         return false
      else
         return (x >= self.__x and x <= self.__x+self.__w and y >= self.__y and y <= self.__y+self.__h)
      end
   end
)

Widget.__onMouseMotion =
   argcheck(
   {{name="self", type="gui.Widget"},
    {name="x", type="number"},
    {name="y", type="number"}},
   function(self, x, y, flag)
      if self.onMouseMotion then
         self:onMouseMotion(x, y)
      end
      local children = self.children and self.children or {self.child}
      for _, child in ipairs(children) do         
         child:__onMouseMotion(x, y)
      end
   end
)

Widget.__onTextInput =
   argcheck(
   {{name="self", type="gui.Widget"},
    {name="text", type="string"}},
   function(self, text)
      if self.onTextInput then
         self:onTextInput(text)
      end
      local children = self.children and self.children or {self.child}
      for _, child in ipairs(children) do         
         child:__onTextInput(text)
      end
   end
)

Widget.__onKeyPressed =
   argcheck(
   {{name="self", type="gui.Widget"},
    {name="name", type="string"},
    {name="mod", type="string"}},
   function(self, name, mod)
      if self.onKeyPressed then
         self:onKeyPressed(name, mod)
      end
      local children = self.children and self.children or {self.child}
      for _, child in ipairs(children) do         
         child:__onKeyPressed(name, mod)
      end
   end
)

Widget.__onMouseButton =
   argcheck(
   {{name="self", type="gui.Widget"},
    {name="x", type="number"},
    {name="y", type="number"}},
   function(self, x, y)
      if not self:isGeometryReady() then
         return
      end
      if x >= self.__x and x <= self.__x+self.__w and y >= self.__y and y <= self.__y+self.__h then
         if self.onMouseButton then
            self:onMouseButton(x, y)
         end
         if self.child then
            self.child:__onMouseButton(x, y)
         end
         if self.children then
            for _, child in ipairs(self.children) do
               child:__onMouseButton(x, y)
            end
         end
      end
   end
)

Widget.draw =
   argcheck(
   {{name="self", type="gui.Widget"}},
   function(self)
      local children = self.children or {self.child}
      for _, child in ipairs(children) do
         child:draw()
      end
   end
)


