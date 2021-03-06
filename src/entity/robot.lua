local Transform = require (RODA_SRC .. 'component.transform')
local Body = require (RODA_SRC .. 'component.body')
local Collider = require (RODA_SRC .. 'component.collider')
local Sprite = require (RODA_SRC .. 'component.sprite')
local Animator = require (RODA_SRC .. 'component.animator')
local Controller = require (RODA_SRC .. 'component.controller')
local Enemy = require (GAME_SRC .. 'component.enemy')
local State = require (RODA_SRC .. 'core.shared.state')
local Bullet = require (GAME_SRC .. 'entity.bullet')

local robot = {}
robot.__index = robot

function robot:new(position, size, polarity)
	local o = {}

	o.name = 'robot'
	o.transform = Transform(position)
	o.polarity = polarity or 'dark'
	o.body = Body(Vector(0, 0), Vector(0, 0), Vector(-0.5, -0.4), 15)
	o.collider = Collider(Rect(position, size))
	o.controller = Controller(0.5)
	o.sprite = Sprite('robot_' .. o.polarity, 'assets/textures/robot_' .. o.polarity .. '.png', 42, 46, 0, 2)
	o.enemy = Enemy('flying')
	o.animator = Animator('moving', 0, 4)
	o.animator:add_animation('dying', 5, 6)
	o.state = State({
		current = 'flying',
		states = {
			flying = {
				enter = function(self, previous)
				end,
				update = function(self, dt)
					if Vector.distance(o.transform.position, Game.sparkle.transform.position) < 200 then
						o.state:switch('chasing')
					end
				end
			},
			chasing = {
				timer = 0,
				first_shoot = true,
				enter = function(self, previous)
					robot.shoot(o)
					self.timer = 0
				end,
				update = function(self, dt)
					self.timer = self.timer + dt

					if o.transform.position.y > 100 then
						o.transform.position.y = 100
					end

					if math.abs(o.transform.position.x - Game.sparkle.transform.position.x) < 130 then
						if o.transform.position.x < Game.sparkle.transform.position.x then
							o.controller:move_right()
						else
							o.controller:move_left()
						end
					end

					o.transform.position.y = o.transform.position.y + math.sin(self.timer * math.pi) * 0.5
					o.transform.position.y = o.transform.position.y + (Game.sparkle.transform.position.y - o.transform.position.y) * 0.4 * dt

					if self.timer > 3 then
						robot.shoot(o)
						self.timer = 0
					end

					if Vector.distance(o.transform.position, Game.sparkle.transform.position) < 15 and o.polarity ~= Game.sparkle.polarity and Game.sparkle.controller.dashing == false then
						Game.sparkle.hurting = true
					end

					if Vector.distance(o.transform.position, Game.sparkle.transform.position) > 300 then
						o.state:switch('flying')
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

					if self.timer > 0.7 then
						Roda.bus:emit('world/remove', o)
					end
				end
			}
		}
	})
	o.hurting = false
	o.hurting_blink = false
	o.hurting_timer = 0
	o.weapon = nil
	o.health = 2

	o.body.kinematic = true

	return setmetatable(o, robot)
end

function robot:shoot()
	local file = 'assets/textures/enemy_bullet_' .. self.polarity .. '.png'
	local target = Game.sparkle.transform.position
	local position = self.transform.position
	local direction = Vector(target.x - position.x, target.y - position.y)

	Roda.bus:emit('world/add', Bullet(
		'enemy',
		'enemy_bullet' .. self.polarity,
		file,
		position,
		rotation,
		Vector(4, 4),
		direction:normalized(),
		100,
		self.polarity
	))
end

return setmetatable(robot, { __call = robot.new })
