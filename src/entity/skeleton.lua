local Transform = require (RODA_SRC .. 'component.transform')
local Body = require (RODA_SRC .. 'component.body')
local Collider = require (RODA_SRC .. 'component.collider')
local Sprite = require (RODA_SRC .. 'component.sprite')
local Animator = require (RODA_SRC .. 'component.animator')
local Controller = require (RODA_SRC .. 'component.controller')
local Enemy = require (GAME_SRC .. 'component.enemy')
local State = require (RODA_SRC .. 'core.shared.state')

local skeleton = {}
skeleton.__index = skeleton

function skeleton:new(position, size, polarity)
	local o = {}

	o.name = 'skeleton'
	o.transform = Transform(position)
	o.polarity = polarity or 'dark'
	o.body = Body(Vector(0, 0), Vector(0, 0), Vector(-1.5, -1.5), 15)
	o.collider = Collider(Rect(position, size))
	o.controller = Controller(2)
	o.sprite = Sprite('skeleton_' .. o.polarity, 'assets/textures/skeleton_' .. o.polarity .. '.png', 44, 40, 0, 2)
	o.enemy = Enemy('skeleton')
	o.animator = Animator('moving', 0, 3)
	o.animator:add_animation('attacking', 4, 3)
	o.animator:add_animation('dying', 8, 3)
	o.state = State({
		current = 'idle',
		states = {
			idle = {
				enter = function(self, previous)
					o.animator:set_animation('moving')
				end,
				update = function(self, dt)
					if math.abs(Game.sparkle.transform.position.y - o.transform.position.y) < 80 then
						if math.abs(Game.sparkle.transform.position.x - o.transform.position.x) < 200 then
							o.state:switch('walking')
						end
					end
				end
			},
			walking = {
				enter = function(self, previous)
					o.animator:set_animation('moving')
				end,
				update = function(self, dt)
					if math.abs(Game.sparkle.transform.position.y - o.transform.position.y) > 100 then
						o.state:switch('idle')
					end

					if math.abs(Game.sparkle.transform.position.x - o.transform.position.x) > 200 then
						o.state:switch('idle')
					end

					if Vector.distance(o.transform.position, Game.sparkle.transform.position) > 30 then
						if o.transform.position.x < Game.sparkle.transform.position.x then
							o.controller:move_right()
						else
							o.controller:move_left()
						end
					else
						o.state:switch('attacking')
					end

					if math.abs(Game.sparkle.transform.position.x - o.transform.position.x) < 30 then
						o.controller.forward = false
						o.controller.backward = false
					end

					for _, other in pairs(Roda.physics.quadtree) do
						if other.tiles == nil then
							if other.name ~= 'bomb' then
								if Vector.distance(other.transform.position, o.transform.position) < 20 then
									if o.transform.facing == 'forward' then
										if o.transform.position.x < other.transform.position.x then
											o.controller.forward = false
										end
									else
										if o.transform.position.x > other.transform.position.x then
											o.controller.backward = false
										end
									end
								end
							end
						end
					end
				end
			},
			attacking = {
				enter = function(self, previous)
					o.animator:set_animation('attacking')
				end,
				update = function(self, dt)
					if Game.sparkle.controller.dashing == false then
						if o.polarity ~= Game.sparkle.polarity then
							Game.sparkle.hurting = true
						end
					end

					if Vector.distance(o.transform.position, Game.sparkle.transform.position) > 30 then
						o.state:switch('walking')
					end
				end
			},
			dying = {
				timer = 0,
				enter = function(self, previous)
					o.animator:set_animation('dying')
				end,
				update = function(self, dt)
					self.timer = self.timer + dt

					if self.timer > 0.45 then
						Roda.bus:emit('world/remove', o)
					end
				end
			}
		}
	})
	o.hurting = false
	o.hurting_blink = false
	o.hurting_timer = 0
	o.health = 3

	return setmetatable(o, skeleton)
end

return setmetatable(skeleton, { __call = skeleton.new })
