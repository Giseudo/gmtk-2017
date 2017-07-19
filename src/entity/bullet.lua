local Transform = require (RODA_SRC .. 'component.transform')
local Collider = require (RODA_SRC .. 'component.collider')
local Sprite = require (RODA_SRC .. 'component.sprite')
local Animator = require (RODA_SRC .. 'component.animator')

local bullet = {}
bullet.__index = bullet

function bullet:new(shooter, name, file, position, rotation, size, direction, speed, polarity)
	local o = {}

	o.shooter = shooter
	o.transform = Transform(position, Vector(1, 1), rotation)
	o.polarity = polarity or 'dark'
	o.collider = Collider(Rect(position, size))
	o.sprite = Sprite(name, file, 16, 16, 0, 1)
	o.animator = Animator('idle', 0, 1)
	o.speed = speed or 500
	o.direction = direction or Vector(1, 0)

	return setmetatable(o, bullet)
end

return setmetatable(bullet, { __call = bullet.new })
