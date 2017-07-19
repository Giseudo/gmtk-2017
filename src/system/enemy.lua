local Tiny = require 'tiny'

local enemy = {}
enemy.__index = enemy

function enemy:new()
	local o = setmetatable({
		filter = Tiny.requireAll('enemy', 'transform', 'polarity', 'health'),
		isUpdateSystem = true
	}, enemy)

	return Tiny.processingSystem(o)
end

function enemy:onAdd(e)
end

function enemy:onRemove(e)
	e.sprite.batch:set(e.sprite.id, 0, 0, 0, 0, 0)
end

function enemy:process(e, dt)
	if Game.sparkle.controller.dashing then
		if Vector.distance(e.transform.position, Game.sparkle.transform.position) < 50 then
			if Game.sparkle.polarity == 'dark' and e.polarity == 'light' then
				e.hurting = true
			end
		end
	end
end

return setmetatable(enemy, {
	__call = enemy.new
})

