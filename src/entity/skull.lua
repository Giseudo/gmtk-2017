local Transform = require (RODA_SRC .. 'component.transform')
local Body = require (RODA_SRC .. 'component.body')
local Collider = require (RODA_SRC .. 'component.collider')
local Sprite = require (RODA_SRC .. 'component.sprite')
local Animator = require (RODA_SRC .. 'component.animator')
local Controller = require (RODA_SRC .. 'component.controller')
local Enemy = require (GAME_SRC .. 'component.enemy')
local State = require (RODA_SRC .. 'core.shared.state')
local Bullet = require (GAME_SRC .. 'entity.bullet')
local Flash = require (GAME_SRC .. 'entity.flash')
local Laser = require (GAME_SRC .. 'entity.laser')

local skull = {}
skull.__index = skull

function skull:new(position, size, polarity)
	local o = {}

	o.name = 'skull'
	o.transform = Transform(position)
	o.polarity = polarity or 'dark'
	o.body = Body(Vector(0, 0), Vector(0, 0), Vector(-0.5, -0.4), 15)
	o.collider = Collider(Rect(position, size), false)
	o.controller = Controller(0.15)
	o.sprite = Sprite('2_skull_' .. o.polarity, 'assets/textures/skull_' .. o.polarity .. '.png', 240, 275, 0, 7)
	o.enemy = true
	o.animator = Animator('idle', 0, 1)
	o.animator:add_animation('attacking', 2, 3, 0.06)
	o.animator:add_animation('shooting', 6, 1)
	o.animator:add_animation('dying', 8, 18)
	o.animator:add_animation('shine', 28, 11)
	o.state = State({
		current = 'idle',
		states = {
			idle = {
				position = o.transform.position,
				timer = 0,
				delay = 0,
				enter = function(self, previous)
					self.timer = 0
					o.animator:set_animation('idle')
				end,
				update = function(self, dt)
					self.timer = self.timer + dt

					o.transform.position.y = o.transform.position.y + math.sin(self.timer * math.pi);
					o.transform.position.x = o.transform.position.x + math.cos(self.timer * math.pi);

					o.transform.position = o.transform.position + (self.position - o.transform.position) * dt

					if self.timer > 4 then
						o.state:switch('attacking')
					end
				end
			},
			attacking = {
				chain = 0,
				timer = 0,
				target = Vector(0, 0),
				direction = Vector(0, 0),
				enter = function(self, previous)
					self.target = Game.sparkle.transform.position
					self.direction = Vector(self.target.x - o.transform.position.x, self.target.y - o.transform.position.y)
					self.chain = self.chain + 1
					self.timer = 0

					o.animator:set_animation('attacking')
				end,
				update = function(self, dt)
					local sparkle = Game.sparkle
					local blade = o.transform.position:clone()

					blade.y = blade.y - 30
					self.timer = self.timer + dt

					if Vector.distance(o.transform.position, self.target) > 10 then
						o.transform.position = o.transform.position + (self.direction:normalized() * 100) * dt
					end

					if sparkle.polarity ~= o.polarity then
						if Vector.distance(sparkle.transform.position, blade) < 40 then
							Game.sparkle.hurting = true
						end
					end

					if self.timer > 1.35 and self.chain < 2 then
						o.state:switch('idle')
					elseif self.timer > 1.35 then
						self.chain = 0
						o.state:switch('shooting')
					end
				end
			},
			shooting = {
				timer = 0,
				firing = false,
				enter = function(self, previous)
					self.position = o.state.states['idle'].position
					self.timer = 0
					self.firing = false
					o.animator:set_animation('shooting')

				end,
				update = function(self, dt)
					o.transform.position = o.transform.position + (self.position - o.transform.position) * 3 * dt

					if Vector.distance(o.transform.position, self.position) < 5 then
						if self.firing == false then
							Roda.bus:emit('world/add', Laser(Vector(position.x, position.y - 155), o.polarity))
						end

						self.firing = true
						self.timer = self.timer + dt

						if self.timer > 2.5 then
							o.state:switch('shifting')
						end
					end

					if self.firing and self.timer < 2 then
						if Game.sparkle.polarity ~= o.polarity then
							if math.abs(Game.sparkle.transform.position.x - o.transform.position.x) < 10 then
								Game.sparkle.hurting = true
							end
						end
					end
				end
			},
			shifting = {
				enter = function(self, previous)
					if o.polarity == 'dark' then
						o.polarity = 'light'
						o.sprite:set_texture('assets/textures/skull_light.png')
					elseif o.polarity == 'light' then
						o.polarity = 'dark'
						o.sprite:set_texture('assets/textures/skull_dark.png')
					end

					Roda.bus:emit('world/add', Flash(o.transform.position, o.polarity, 2))
					o.state:switch('idle')
				end,
				update = function(self, dt)
				end
			},
			dying = {
				timer = 0,
				enter = function(self, previous)
					if previous ~= 'dying' then
						o.animator:set_animation('dying')
					end
				end,
				update = function(self, dt)
					self.timer = self.timer + dt

					if self.timer > 2 then
						o.animator:set_animation('shine')
					end

					if self.timer > 4 then
						Roda.bus:emit('world/remove', o)
					end
				end
			},
		}
	})
	o.health = 15
	o.hurting = false
	o.hurting_blink = false
	o.hurting_timer = 0
	o.body.kinematic = true

	return setmetatable(o, skull)
end

return setmetatable(skull, { __call = skull.new })
