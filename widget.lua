local class = require 'class'
local argcheck = require 'argcheck'

local Widget = class.new('gui.Widget')

-- attr are inherited
-- flags are not

Widget.__init =
   argcheck(
   {{name="self", type="gui.Widget"},
    {name="parent", type="gui.Widget"}, 
    {name="attr", type="table"},
    {name="attrset", type="table", opt=true}},
   function(self, parent, attr, attrset)
      self.flags = {nochild=false, onechild=false, hidden=false, undersized=false, dirty=false}
      self.children = {}
      self.parent = parent
      self.window = self.parent.window
      self:__initAttributes{fontsize=12}
      self:__initAttributes(attr)
      if attrset then
         self:setAttributes(attrset)
      end
      parent:attach(self)
   end
)

Widget.attach =
   argcheck(
   {{name="self", type="gui.Widget"},
    {name="child", type="gui.Widget"}},
   function(self, child)
      if self.flags.nochild then
         error('cannot attach a child to <%s>', class.type(self))
      end
      if self.flags.onechild and #self.children > 0 then
         error('cannot attach more than one child to <%s>', class.type(self))
      end
      table.insert(self.children, child)
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

Widget.isArea =
   argcheck(
   {{name="self", type="gui.Widget"},
    {name="x", type="number"},
    {name="y", type="number"}},
   function(self, x, y)
      if not self:isGeometryReady() then
         return false
      else
         return (x >= self.x and x <= self.x+self.w and y >= self.y and y <= self.y+self.h)
      end
   end
)

function Widget:onMouseMotion()
end

Widget.mouseMotion =
   argcheck(
   {{name="self", type="gui.Widget"},
    {name="x", type="number"},
    {name="y", type="number"}},
   function(self, x, y)
      self:onMouseMotion(x, y)
      for _, child in ipairs(self.children) do
         child:mouseMotion(x, y)
      end
   end
)

function Widget:onTextInput()
end

Widget.textInput =
   argcheck(
   {{name="self", type="gui.Widget"},
    {name="text", type="string"}},
   function(self, text)
      self:onTextInput(text)
      for _, child in ipairs(self.children) do
         child:textInput(text)
      end
   end
)

function Widget:onKeyPressed()
end

Widget.keyPressed =
   argcheck(
   {{name="self", type="gui.Widget"},
    {name="name", type="string"},
    {name="mod", type="string"}},
   function(self, name, mod)
      self:onKeyPressed(name, mod)
      for _, child in ipairs(self.children) do
         child:keyPressed(name, mod)
      end
   end
)

function Widget:onMouseButton()
end

Widget.mouseButton =
   argcheck(
   {{name="self", type="gui.Widget"},
    {name="x", type="number"},
    {name="y", type="number"}},
   function(self, x, y)
      self:onMouseButton(x, y)
      for _, child in ipairs(self.children) do
         child:mouseButton(x, y)
      end
   end
)

function Widget:onDraw()
end

function Widget:draw(force)
  if self.flags.hidden or self.flags.undersized then
     return
  end

   if force or self.flags.dirty then
      print('drawing', class.type(self))
      self:onDraw()
   end

   for _, child in ipairs(self.children) do
      child:draw(force or self.flags.dirty)
   end

   self.flags.dirty = false
end

-- must set its child
function Widget:onSetGeometry()
end

function Widget:setGeometry(x, y, w, h)
   x = math.floor(x)
   y = math.floor(y)
   w = math.floor(w)
   h = math.floor(h)

   if w <= 0 or h <= 0 then
      w = 0
      h = 0
      self.flags.undersized = true
   else
      self.flags.undersized = false
   end

   if x ~= self.x or y ~= self.y or w ~= self.w or h ~= self.h then
      self:redraw()
   end

   self.x = x
   self.y = y
   self.w = w
   self.h = h

   self:onSetGeometry(x, y, w, h)
end


function Widget:redraw()
--   self.window:redraw()
   self.flags.dirty = true
end

function Widget:show()
   self.flags.hidden = false
   self:redraw()
end

function Widget:hide()
   self.flags.hidden = true
end
