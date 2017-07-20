local Transform = require (RODA_SRC .. 'component.transform')
local State = require (RODA_SRC .. 'core.shared.state')
local Skull = require (GAME_SRC .. 'entity.skull')
local Hand = require (GAME_SRC .. 'entity.hand')
local Waterfall = require (GAME_SRC .. 'entity.waterfall')
local Rocks = require (GAME_SRC .. 'entity.rocks')
local Wall = require (GAME_SRC .. 'entity.wall')

local boss = {}
boss.__index = boss

function boss:new(position)
	local o = {}

	o.name = 'boss'
	o.transform = Transform(position)
	o.hand_1 = Hand(position + Vector(-170, 0), Vector(100, 80), 'light')
	o.hand_2 = Hand(position + Vector(170, 0), Vector(100, 80), 'dark')
	o.skull_1 = Skull(position + Vector(-50, 80), Vector(40, 40), 'dark')
	o.skull_2 = Skull(position + Vector(50, 80), Vector(40, 40), 'light')
	o.waterfall = Waterfall(position + Vector(0, -35))
	o.rocks = Rocks(position + Vector(0, -35))
	o.state = State({
		current = 'idle',
		states = {
			idle = {
				enter = function(self, previous)
					o.skull_1.state:switch('intro')
					o.skull_2.state:switch('intro')
					Roda.bus:emit('world/add', o.hand_1)
					Roda.bus:emit('world/add', o.hand_2)
					Roda.bus:emit('world/add', o.skull_1)
					Roda.bus:emit('world/add', o.skull_2)
					Roda.bus:emit('world/add', o.waterfall)
					Roda.bus:emit('world/add', o.rocks)
				end,
				update = function(self, dt)
					if math.abs(Game.sparkle.transform.position.x - o.transform.position.x) < 150 then
						o.state:switch('fighting')
					end
				end
			},
			fighting = {
				enter = function(self, previous)
					o.waterfall.state:switch('showing')
					o.skull_1.state:switch('idle')
					o.skull_2.state:switch('idle')
					Roda.bus:emit('camera/target', o)
					Roda.bus:emit('world/add', Wall(o.transform.position + Vector(-250, 0), Vector(16, 320)))
					Roda.bus:emit('world/add', Wall(o.transform.position + Vector(250, 0), Vector(16, 320)))
				end,
				update = function(self, dt)
					if o.skull_1.health == 0 then
						o.skull_2.berserk = true
						o.skull_2.health = o.skull_2.health + 3
					elseif o.skull_2.health == 0 then
						o.skull_1.berserk = true
						o.skull_1.health = o.skull_1.health + 3
					end

					if o.skull_1.health == 0 and o.skull_2.health == 0 then
						o.state:switch('dying')
					end
				end
			},
			dying = {
				timer = 0,
				emitted = false,
				enter = function(self, previous)
					o.hand_1.state:switch('dying')
					o.hand_2.state:switch('dying')
				end,
				update = function(self, dt)
					self.timer = self.timer + dt

					if self.timer > 2 and self.emitted == false then
						self.emitted = true
						Roda.bus:emit('boss/defeated')
					end
				end
			}
		}
	})

	return setmetatable(o, boss)
end

return setmetatable(boss, { __call = boss.new })
