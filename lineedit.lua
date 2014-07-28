local class = require 'class'
local cairo = require 'cairo'
local argcheck = require 'argcheck'
local utf8 = require 'utf8'
local sdl = require 'sdl2'
local ffi = require 'ffi'

local LineEdit, Widget = class.new('gui.LineEdit', 'gui.Widget')

LineEdit.__init = argcheck{
   {name="self", type="gui.LineEdit"},
   {name="parent", type="gui.Widget"},
   {name="text", type="string"},
   {name="attr", type="table", opt=true},
   call =
      function(self, parent, text, attr)
         Widget.__init(self,
                       parent,
                       {hfill=false, vfill=false, text=text, padding=10, textpadding=5, size=20},
                       attr)
         
         self.__idx = utf8.len(self.attr.text)
         self.__shift = 0
      end
}

function LineEdit:setText(text)
   if text ~= self.attr.text then
      self.attr.text = text
      self:updateGeometry()
   end
end

function LineEdit:sizeRequest()
   local cr = self.window.drv.cr
--   cr:selectFontFace('monospace', 'normal', 'normal')
   cr:setFontSize(self.attr.fontsize)
   local w = cr:textExtents(string.rep('X', self.attr.size)).width + 2*self.attr.padding + 2*self.attr.textpadding
   local h = cr:fontExtents().height + 2*self.attr.padding + 2*self.attr.textpadding
   return w, h
end
   
function LineEdit:onDraw()
   local cr = self.window.drv.cr
   if self.w > 0 and self.h > 0 then
      local padding = self.attr.padding
      local textpadding = self.attr.textpadding
      local w, h = self:sizeRequest()
      local text = self.attr.text
      local idx = self.__idx

      w = math.max(self.w, w)
      h = math.max(self.h, h)

      cr:save()
      cr:translate(self.x, self.y)
      cr:rectangle(0, 0, self.w, self.h)
      cr:clip()
      
      cr:rectangle(padding, padding, w-padding*2, h-padding*2)
      cr:setSourceRGB(1, 1, 1)
      cr:fill()

      cr:rectangle(padding, padding, w-padding*2, h-padding*2)
      cr:setLineWidth(2)
      cr:setSourceRGB(0.8, 0.8, 0.8)
      cr:stroke()

      cr:rectangle(padding+textpadding, padding, w-2*textpadding-2*padding, h-2*padding)
      cr:clip()

      local cx = cr:textExtents(utf8.sub(text, 1, self.__idx)).x_advance+1
      
      if cx+self.__shift > w-padding*2-textpadding*2 then
         self.__shift = w-padding*2-textpadding*2-cx
      end

      if cx+self.__shift < 0 then
         self.__shift = -cx
      end

--      cr:selectFontFace('', 'normal', 'normal')
      cr:setFontSize(self.attr.fontsize)
      local ex = cr:textExtents(text)
      local fe = cr:fontExtents()
      cr:moveTo(padding+textpadding+self.__shift, math.floor((h-fe.ascent-fe.descent)/2)+fe.ascent)
      cr:setSourceRGB(0, 0, 0)
      cr:showText(text)

      cr:moveTo(padding+textpadding+cx+self.__shift, math.floor(padding+textpadding/2))
      cr:lineTo(padding+textpadding+cx+self.__shift, math.floor(h-padding-textpadding/2))
      cr:setLineWidth(1)
      cr:setSourceRGBA(0.2, 0.4, 0.6, 0.9)
      cr:stroke()

      cr:restore()
   end
end

function LineEdit:onTextInput(str)
   local text = self.attr.text
   local idx = self.__idx
   self.attr.text = utf8.sub(text, 1, idx) .. str .. utf8.sub(text, idx+1, utf8.len(text))
   self.__idx = self.__idx + utf8.len(str)
   self:redraw()
end

function LineEdit:onKeyPressed(key, mod)
   local text = self.attr.text
   local idx = self.__idx
   local len = utf8.len(text)
   if key == 'Backspace' then
      if idx >= 1 then
         self.attr.text = utf8.sub(text, 1, idx-1) .. utf8.sub(text, idx+1, len)
         self.__idx = idx-1
         self:redraw()
      end
   elseif key == 'Left' then
      if idx >= 1 then
         self.__idx = idx-1
         self:redraw()
      end
   elseif key == 'Right' then
      if idx < len then
         self.__idx = idx+1
         self:redraw()
      end
   elseif key == 'Return' then
      if self.onReturn then
         self:onReturn()
         self:redraw()
      end
   elseif key == 'Delete' then
      if idx+1 >= 1 and idx < len then
         self.attr.text = utf8.sub(text, 1, idx) .. utf8.sub(text, idx+2, len)
         self:redraw()
      end
   elseif key == 'Home' then
      self.__idx = 0
      self:redraw()
   elseif key == 'End' then
      self.__idx = len
      self:redraw()
   elseif key == 'V' and mod:match('g') then
      if sdl.hasClipboardText() then
         local clipboard = ffi.string(sdl.getClipboardText())
         self:onTextInput(clipboard)
      end
   elseif key == 'C' and mod:match('g') then
      sdl.setClipboardText(self.attr.text)
   end
end

return LineEdit
