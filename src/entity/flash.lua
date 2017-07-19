local Transform = require (RODA_SRC .. 'component.transform')
local Collider = require (RODA_SRC .. 'component.collider')
local Sprite = require (RODA_SRC .. 'component.sprite')
local Animator = require (RODA_SRC .. 'component.animator')

local flash = {}
flash.__index = flash

function flash:new(position, polarity, scale)
	local o = {}

	o.transform = Transform(position, Vector(scale or 1, scale or 1))
	o.sprite = Sprite('flash_' .. polarity .. '_01', 'assets/textures/flash_' .. polarity .. '.png', 64, 64, 0, 1)
	o.animator = Animator('idle', 0, 3, 0.03)
	o.timeout = 0.16
	o.timer = 0

	return setmetatable(o, flash)
end

return setmetatable(flash, { __call = flash.new })
