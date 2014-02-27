local sdl = require 'sdl2'
local ffi = require 'ffi'
local cairo = require 'cairo'
local class = require 'class'

local Widget = require 'widget'
local Window = require 'window'
local Button = require 'button'
local HBox = require 'hbox'
local VBox = require 'vbox'
local Frame = require 'frame'
local Label = require 'label'
local Checkbox = require 'checkbox'
local LineEdit = require 'lineedit'

local W = 250
local H = 250

sdl.init(sdl.INIT_VIDEO)

local event = ffi.new('SDL_Event')

local window = Window.new("salut", {resizable=true})--, {width=800, height=600})
local vertical = VBox.new(window)

local frame = Frame.new(vertical, {hfill=true})

local h1 = HBox.new(frame, {hfill=true, vfill=true}) -- faudrait pas tout mettre comme ca?
for i=1,5 do
   local button = Button.new(h1, 'pouic' .. i, {hfill=true})
   function button:onMouseButton()
      print('CLICKED pouic' .. i)
   end
end
h1.children[3].onMouseButton = function(self)
                                  self:setLabel('CLICKED')
--                                  Button.new(h1, 'pouic')
                               end

h1.children[3].onMouseMotion = function(self, x, y)
                                  if self:__isHover(x, y) then
                                     self:setLabel('HOVERED')
                                  else
                                     self:setLabel('YOU LEFT, BASTERD')
                                  end
                             end

local h2 = HBox.new(vertical, {hfill=true, vfill=true}) -- faudrait pas tout mettre comme ca?
Label.new(h2, 'Choose your destiny:')
for i=1,3 do
   Button.new(h2, 'pouix' .. i, {hfill=true})
end
h2.children[3].onMouseButton = function()
                                  Button.new(h2, 'pouix')
                               end

local vc = VBox.new(h2, {align='left', spacing=0})
Checkbox.new(vc, 'YOU check me if you dare')
Checkbox.new(vc, 'Try me')

local h3 = HBox.new(vertical, {hfill=true})
Label.new(h3, 'Enter your name:')
local le = LineEdit.new(h3, 'salut ma poule', {hfill=true})
function le:onReturn()
   print(string.format('CONTENTS <%s>', self.attr.text))
end

--vertical._objects[3]._hpolicy = 'fixed'

local txt = "th> "
sdl.startTextInput()
while true do

   window:draw()

   sdl.waitEvent(event)
   if event.type == sdl.QUIT then
      break
   elseif event.type == sdl.TEXTINPUT then
      local txt = ffi.string(event.text.text)
      window:__onTextInput(txt)
   elseif event.type == sdl.KEYDOWN then
      local name = ffi.string(sdl.getKeyName( event.key.keysym.sym ))
      local mod = {}
      local keymod = event.key.keysym.mod

      if bit.band(keymod, sdl.KMOD_LSHIFT) > 0 then
         table.insert(mod, 'ls')
      end
      if bit.band(keymod, sdl.KMOD_RSHIFT) > 0 then
         table.insert(mod, 'rs')
      end
      if bit.band(keymod, sdl.KMOD_LCTRL) > 0 then
         table.insert(mod, 'lc')
      end
      if bit.band(keymod, sdl.KMOD_RCTRL) > 0 then
         table.insert(mod, 'rc')
      end
      if bit.band(keymod, sdl.KMOD_LALT) > 0 then
         table.insert(mod, 'la')
      end
      if bit.band(keymod, sdl.KMOD_RALT) > 0 then
         table.insert(mod, 'ra')
      end
      if bit.band(keymod, sdl.KMOD_LGUI) > 0 then
         table.insert(mod, 'lg')
      end
      if bit.band(keymod, sdl.KMOD_RGUI) > 0 then
         table.insert(mod, 'rg')
      end
      if bit.band(keymod, sdl.KMOD_NUM) > 0 then
         table.insert(mod, 'n')
      end
      if bit.band(keymod, sdl.KMOD_CAPS) > 0 then
         table.insert(mod, 'C')
      end
      if bit.band(keymod, sdl.KMOD_MODE) > 0 then
         table.insert(mod, 'm')
      end

      mod = table.concat(mod)
      print('KEY', name, mod)
      window:__onKeyPressed(name, mod)

   elseif event.type == sdl.MOUSEMOTION then
      window:__onMouseMotion(event.motion.x, event.motion.y)
   elseif event.type == sdl.MOUSEBUTTONDOWN then
      window:__onMouseButton(event.button.x, event.button.y)
   elseif event.type == sdl.WINDOWEVENT then
      if event.window.event == sdl.WINDOWEVENT_RESIZED then
         W = event.window.data1
         H = event.window.data2
         window:setGeometry(-1, -1, W, H)
      end
   end

   sdl.updateWindowSurface(win)

end
