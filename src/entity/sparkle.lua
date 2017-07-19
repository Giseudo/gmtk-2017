local Transform = require (RODA_SRC .. 'component.transform')
local Body = require (RODA_SRC .. 'component.body')
local Collider = require (RODA_SRC .. 'component.collider')
local Sprite = require (RODA_SRC .. 'component.sprite')
local Animator = require (RODA_SRC .. 'component.animator')
local Controller = require (RODA_SRC .. 'component.controller')
local State = require (RODA_SRC .. 'core.shared.state')

local sparkle = {}
sparkle.__index = sparkle

function sparkle:new(position, size)
	local o = {}

	o.name = 'sparkle'
	o.transform = Transform(position)
	o.body = Body(Vector(0, 0), Vector(0, 0), Vector(-1.5, -1.5), 27)
	o.collider = Collider(Rect(position, size))
	o.controller = Controller(4.3)
	o.sprite = Sprite('2_sparkle', 'assets/textures/sparkle_dark.png', 72, 37, 0, 3)
	o.animator = Animator('idle', 0, 3)
	o.animator:add_animation('moving', 4, 1)
	o.animator:add_animation('flying', 6, 1)
	o.animator:add_animation('dash_1', 8, 5, 0.035)
	o.animator:add_animation('dash_2', 14, 5, 0.05)
	o.animator:add_animation('dying', 20, 12)
	o.state = State({
		current = 'idle',
		states = {
			idle = {
				enter = function(self, previous)
					o.animator:set_animation('idle')
				end,
				update = function(self, dt)
					if o.controller.flying then
						o.state:switch('flying')
					end

					if o.controller.forward or o.controller.backward then
						o.state:switch('walking')
					end

					if o.controller.dashing then
						o.state:switch('dashing')
					end
				end
			},
			walking = {
				enter = function(self, previous)
					o.animator:set_animation('moving')
				end,
				update = function(self, dt)
					if o.controller.flying or o.body.grounded == false then
						o.state:switch('flying')
					end

					if o.controller.forward == false and o.controller.backward == false then
						o.state:switch('idle')
					end

					if o.controller.dashing then

						o.state:switch('dashing')
					end
				end
			},
			dashing = {
				timer = 0,
				enter = function(self, previous)
					o.controller.dashing = true

					if previous == 'flying' then
						o.animator:set_animation('dash_2')
					else
						o.animator:set_animation('dash_1')
					end

					if o.transform.facing == 'forward' then
						o.body.velocity.x = 40
					else
						o.body.velocity.x = -40
					end

					if o.body.velocity.y ~= 0 then
						o.body.velocity.y = 14
					end
				end,
				update = function(self, dt)
					self.timer = self.timer + dt

					if self.timer > 0.25 then
						self.timer = 0
						o.controller.dashing = false
						o.body.velocity.x = 0
						o.body.velocity.y = 0

						if o.controller.flying then
							o.state:switch('flying')
						else
							o.state:switch('idle')
						end
					end
				end
			},
			flying = {
				enter = function(self, previous)
					o.animator:set_animation('flying')
				end,
				update = function(self, dt)
					if o.body.grounded then
						o.state:switch('idle')
					end

					if o.controller.dashing then
						o.state:switch('dashing')
					end
				end
			},
			dying = {
				timer = 0,
				enter = function(self, previous)
					o.animator:set_animation('dying')
					o.body.kinematic = true
				end,
				update = function(self, dt)
					self.timer = self.timer + dt
					o.controller.disabled = true

					if self.timer > 1.4 then
						Roda.bus:emit('player/defeated')
						Roda.bus:emit('world/remove', o)
					end
				end
			}
		}
	})
	o.hurting = false
	o.hurting_blink = false
	o.hurting_timer = 0
	o.health = 4
	o.polarity = 'dark'

	return setmetatable(o, sparkle)
end

return setmetatable(sparkle, { __call = sparkle.new })
