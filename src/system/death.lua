local Tiny = require 'tiny'

local death = {}
death.__index = death

function death:new()
	local o = setmetatable({
		filter = Tiny.requireAll('health', 'sprite', 'transform', 'hurting'),
		isDrawingSystem = true
	}, death)

	return Tiny.processingSystem(o)
end

function death:preProcess(dt)
	Roda.bus:emit('camera/set')
end

function death:onAdd(e)
	Roda.bus:register('entity/dropped', function(entity)
		entity.health = 0
	end)
end

function death:process(e, dt)
	if e == nil then
		return
	end

	if e.hurting then
		if e.hurting_timer == 0 and e.health > 0 then
			e.health = e.health - 1
		end

		e.hurting_timer = e.hurting_timer + dt

		if e.hurting_blink then
			e.hurting_blink = false
		else
			if e.hurting_timer < 0.2 then
				e.hurting_blink = true
				Roda:set_shader('blink')
				love.graphics.draw(
					e.sprite.batch:getTexture(),
					e.sprite.quads[e.sprite.frame],
					e.transform.position.x,
					e.transform.position.y,
					e.transform.rotation,
					e.transform.scale.x,
					e.transform.scale.y,
					e.sprite.width / 2,
					e.sprite.height / 2
				)
				Roda:set_shader('default')
			end
		end

		if e.hurting_timer > 0.8 or e.hurting_timer > 0.4 and e ~= Game.sparkle then
			e.hurting_timer = 0
			e.hurting = false
		end
	end

	if e.health == 0 then
		e.state:switch('dying')
	end
end

function death:postProcess(dt)
	Roda.bus:emit('camera/unset')
end

return setmetatable(death, {
	__call = death.new
})
