local Transform = require (RODA_SRC .. 'component.transform')
local Sprite = require (RODA_SRC .. 'component.sprite')
local Collider = require (RODA_SRC .. 'component.collider')
local Animator = require (RODA_SRC .. 'component.animator')
local State = require (RODA_SRC .. 'core.shared.state')

local waterfall = {}
waterfall.__index = waterfall

function waterfall:new(position)
	local o = {}

	o.name = 'waterfall'
	o.transform = Transform(position)
	o.sprite = Sprite('1_waterfall', 'assets/textures/waterfall.png', 263, 205, 0, 3)
	o.animator = Animator('idle', 0, 1)
	o.animator:add_animation('showing', 3, 6)
	o.animator:add_animation('revealed', 10, 1)
	o.state = State({
		current = 'idle',
		states = {
			idle = {
				enter = function(self, previous)
					o.set_animation('idle')
				end,
				update = function(self, dt)
				end
			},
			showing = {
				timer = 0,
				enter = function(self, previous)
					o.animator:set_animation('showing')
				end,
				update = function(self, dt)
					self.timer = self.timer + dt

					if self.timer > 0.8 then
						o.state:switch('revealed')
					end
				end
			},
			revealed = {
				enter = function(self, previous)
					o.animator:set_animation('revealed')
				end,
				update = function(self, dt)
				end
			}
		}
	})

	return setmetatable(o, waterfall)
end

return setmetatable(waterfall, { __call = waterfall.new })
