local Transform = require (RODA_SRC .. 'component.transform')
local Sprite = require (RODA_SRC .. 'component.sprite')
local Animator = require (RODA_SRC .. 'component.animator')
local Collider = require (RODA_SRC .. 'component.collider')

local life = {}
life.__index = life

function life:new(position)
	local o = {}

	o.name = 'life'
	o.transform = Transform(position)
	o.sprite = Sprite('life', 'assets/textures/life.png', 32, 32, 0, 1)
	o.collider = Collider(Rect(position, Vector(16, 16)), false)
	o.animator = Animator('idle', 0, 12)
	o.bonus = 'health'

	return setmetatable(o, life)
end

return setmetatable(life, { __call = life.new })
