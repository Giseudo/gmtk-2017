local Tiny = require 'tiny'

local explosion = {}
explosion.__index = explosion

function explosion:new()
	local o = setmetatable({
		filter = Tiny.requireAll('timeout', 'timer', 'sprite'),
		isUpdateSystem = true
	}, explosion)

	return Tiny.processingSystem(o)
end

function explosion:onAdd(e)
end

function explosion:onRemove(e)
	e.sprite.batch:set(e.sprite.id, 0, 0, 0, 0, 0)
end

function explosion:process(e, dt)
	if e == nil then
		return
	end

	e.timer = e.timer + dt

	if e.timer >= e.timeout then
		Roda.bus:emit('world/remove', e)
	end
end

return setmetatable(explosion, {
	__call = explosion.new
})
