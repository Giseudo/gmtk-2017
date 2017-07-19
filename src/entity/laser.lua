local Transform = require (RODA_SRC .. 'component.transform')
local Sprite = require (RODA_SRC .. 'component.sprite')
local Animator = require (RODA_SRC .. 'component.animator')

local laser = {}
laser.__index = laser

function laser:new(position, polarity)
	local o = {}

	o.transform = Transform(position)
	o.sprite = Sprite('laser_' .. polarity .. '_01', 'assets/textures/laser_' .. polarity .. '.png', 200, 340, 0, 5)
	o.animator = Animator('idle', 0, 14)
	o.timeout = 2.1
	o.timer = 0

	return setmetatable(o, laser)
end

return setmetatable(laser, { __call = laser.new })
