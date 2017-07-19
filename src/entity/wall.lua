local Transform = require (RODA_SRC .. 'component.transform')
local Collider = require (RODA_SRC .. 'component.collider')

local wall = {}
wall.__index = wall

function wall:new(position, size)
	local o = {}

	o.transform = Transform(position)
	o.collider = Collider(Rect(position, size), true)

	return setmetatable(o, wall)
end

return setmetatable(wall, { __call = wall.new })
