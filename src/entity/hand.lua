local Transform = require (RODA_SRC .. 'component.transform')
local Body = require (RODA_SRC .. 'component.body')
local Collider = require (RODA_SRC .. 'component.collider')
local Sprite = require (RODA_SRC .. 'component.sprite')
local Animator = require (RODA_SRC .. 'component.animator')
local Controller = require (RODA_SRC .. 'component.controller')
local Enemy = require (GAME_SRC .. 'component.enemy')
local State = require (RODA_SRC .. 'core.shared.state')
local Bullet = require (GAME_SRC .. 'entity.bullet')

local hand = {}
hand.__index = hand

function hand:new(position, size, polarity)
	local o = {}

	o.name = 'hand'
	o.index = 4
	o.transform = Transform(position)
	o.polarity = polarity or 'dark'
	o.body = Body(Vector(0, 0), Vector(0, 0), Vector(-1, -1), 15)
	o.collider = Collider(Rect(position, size), true)
	o.controller = Controller(1.5)
	o.sprite = Sprite('hand_' .. o.polarity, 'assets/textures/hand_' .. o.polarity .. '.png', 195, 195, 0, 3, 1)
	o.animator = Animator('idle', 0, 0)
	o.animator:add_animation('attacking', 1, 13)
	o.state = State({
		current = 'moving',
		states = {
			idle = {
				enter = function(self, previous)
					o.animator:set_animation('idle')
				end,
				update = function(self, dt)
				end
			},
			moving = {
				timer = 0,
				position = o.transform.position,
				enter = function(self, previous)
					o.animator:set_animation('idle')
					self.timer = 0
				end,
				update = function(self, dt)
					self.timer = self.timer + dt

					if o.polarity == 'light' then
						o.transform.position.y = o.transform.position.y + math.sin(self.timer * math.pi);
					else
						o.transform.position.y = o.transform.position.y - math.sin(self.timer * math.pi);
					end
					o.transform.position = o.transform.position + (self.position - o.transform.position) * dt

					if self.timer > 6 then
						o.state:switch('attacking')
					end
				end
			},
			attacking = {
				timer = 0,
				enter = function(self, previous)
					o.animator:set_animation('attacking')
					self.timer = 0
				end,
				update = function(self, dt)
					self.timer = self.timer + dt

					if Game.sparkle.polarity ~= o.polarity then
						if Vector.distance(Game.sparkle.transform.position, o.transform.position) < 70 then
							if self.timer > 1 then
								Game.sparkle.hurting = true
							end
						end
					end

					if self.timer > 1.5 then
						o.state:switch('moving')
					end
				end
			},
			dying = {
				enter = function(self, previous)
				end,
				update = function(self, dt)
					o.transform.position.y = o.transform.position.y + -300 * dt
				end
			}
		}
	})
	o.body.kinematic = true

	return setmetatable(o, hand)
end

return setmetatable(hand, { __call = hand.new })
