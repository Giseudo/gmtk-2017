local Transform = require (RODA_SRC .. 'component.transform')
local Body = require (RODA_SRC .. 'component.body')
local Collider = require (RODA_SRC .. 'component.collider')
local Sprite = require (RODA_SRC .. 'component.sprite')
local Animator = require (RODA_SRC .. 'component.animator')
local Controller = require (RODA_SRC .. 'component.controller')
local Enemy = require (GAME_SRC .. 'component.enemy')
local State = require (RODA_SRC .. 'core.shared.state')

local bomb = {}
bomb.__index = bomb

function bomb:new(position, size, polarity)
	local o = {}

	o.name = 'bomb'
	o.transform = Transform(position)
	o.polarity = polarity or 'dark'
	o.body = Body(Vector(0, 0), Vector(0, 0), Vector(-1.5, -1.5), 15)
	o.collider = Collider(Rect(position, size))
	o.controller = Controller(2)
	o.sprite = Sprite('bomb_' .. o.polarity, 'assets/textures/bomb_' .. o.polarity .. '.png', 60, 65, 0, 2)
	o.enemy = Enemy('explosive')
	o.animator = Animator('moving', 0, 7)
	o.animator:add_animation('exploding', 8, 9)
	o.state = State({
		current = 'idle',
		states = {
			idle = {
				enter = function(self, previous)
					o.animator:set_animation('moving')
				end,
				update = function(self, dt)
					if math.abs(Game.sparkle.transform.position.y - o.transform.position.y) < 200 then
						if math.abs(Game.sparkle.transform.position.x - o.transform.position.x) < 200 then
							o.state:switch('rolling')
						end
					end
				end
			},
			rolling = {
				enter = function(self, previous)
				end,
				update = function(self, dt)
					local position = Game.sparkle.transform.position:clone()

					if math.abs(Game.sparkle.transform.position.y - o.transform.position.y) > 100 then
						o.state:switch('idle')
					end

					if math.abs(Game.sparkle.transform.position.x - o.transform.position.x) > 200 then
						o.state:switch('idle')
					end

					if Game.sparkle.transform.facing == 'forward' then
						position.x = position.x + 50
					else
						position.x = position.x - 50
					end

					if o.transform.position.x < position.x then
						o.controller:move_right()
					elseif o.transform.position.x > position.x then
						o.controller:move_left()
					end

					if math.abs(position.x - o.transform.position.x) < 30 then
						o.controller.forward = false
						o.controller.backward = false
					end

					for _, other in pairs(Roda.physics.quadtree) do
						if other.tiles == nil then
							if other.name ~= 'skeleton' then
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

					if Vector.distance(o.transform.position, Game.sparkle.transform.position) < 55 then
						o.state:switch('exploding')
					end
				end
			},
			exploding = {
				timer = 0,
				enter = function(self, previous)
					o.animator:set_animation('exploding')
				end,
				update = function(self, dt)
					self.timer = self.timer + dt

					if self.timer > 0.3 and self.timer < 0.4 then
						if Vector.distance(o.transform.position, Game.sparkle.transform.position) < 55 then
							if o.polarity ~= Game.sparkle.polarity then
								Game.sparkle.hurting = true
							end
						end
					end

					if self.timer > 1.1 then
						o.sprite.batch:set(o.sprite.id, 0, 0, 0, 0)
						Roda.bus:emit('world/remove', o)
					end
				end
			}
		}
	})
	o.weapon = nil
	o.health = 5

	return setmetatable(o, bomb)
end

return setmetatable(bomb, { __call = bomb.new })
