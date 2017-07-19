local Tiny = require 'tiny'

local item = {}
item.__index = item

function item:new()
	local o = setmetatable({
		filter = Tiny.requireAll('bonus', 'transform'),
		isUpdateSystem = true
	}, item)

	return Tiny.processingSystem(o)
end

function item:process(e, dt)
	if e == nil then
		return
	end

	if Vector.distance(e.transform.position, Game.sparkle.transform.position) < 20 then
		if Game.sparkle.health < 4 then
			if e.bonus == 'health' then
				Game.sparkle.health = Game.sparkle.health + 1
			end

			Roda.bus:emit('world/remove', e)
		end
	end
end

return setmetatable(item, {
	__call = item.new
})
