local Tiny = require 'tiny'

local projectile = {}
projectile.__index = projectile

function projectile:new()
	local o = setmetatable({
		filter = Tiny.requireAll('shooter', 'speed', 'transform', 'direction'),
		isUpdateSystem = true
	}, projectile)

	return Tiny.processingSystem(o)
end

function projectile:onAdd(e)
end

function projectile:onRemove(e)
	e.sprite.batch:set(e.sprite.id, 0, 0, 0, 0)
end

function projectile:process(e, dt)
	if e == nil then
		return
	end

	e.transform.position = e.transform.position + e.direction * e.speed * dt

	for _, other in pairs(Roda.physics.quadtree) do
		if other.shooter == nil then
			local half = other.collider.shape:get_half()
			local dx = e.transform.position.x - other.transform.position.x
			local px = half.x - math.abs(dx)
			local dy = e.transform.position.y - other.collider.shape.position.y
			local py = half.y - math.abs(dy)

			if px > 0 and py > 0 then
				if other.controller ~= nil then
					if e.shooter == 'enemy' and other.controller.player or e.shooter == 'player' and other.controller.player == false then
						if e.polarity ~= other.polarity then
							other.hurting = true
							Roda.bus:emit('world/remove', e)
						end
					end
				else
					Roda.bus:emit('world/remove', e)
				end
			end
		end
	end

	if Vector.distance(e.transform.position, Game.sparkle.transform.position) > 400 then
		Roda.bus:emit('world/remove', e)
	end
end

return setmetatable(projectile, {
	__call = projectile.new
})
