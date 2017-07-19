local Transform = require (RODA_SRC .. 'component.transform')
local Sprite = require (RODA_SRC .. 'component.sprite')
local Collider = require (RODA_SRC .. 'component.collider')

local rocks = {}
rocks.__index = rocks

function rocks:new(position)
	local o = {}

	o.name = 'rocks'
	o.transform = Transform(position)
	o.sprite = Sprite('0_rocks', 'assets/textures/rocks.png', 486, 211, 0, 1)

	return setmetatable(o, rocks)
end

return setmetatable(rocks, { __call = rocks.new })
