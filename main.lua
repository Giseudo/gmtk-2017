love.graphics.setDefaultFilter('nearest', 'nearest', 1)

require "env"
require "roda"
require "src.game"

local currentTime = love.timer.getTime()
local acumulator = 0.0
local frameTime = 0

function love.load()
	Roda:run()
	Game:run()
end

function love.update(dt)
	local newTime = love.timer.getTime()
	frameTime = newTime - currentTime

	if frameTime > 0.25 then
		frameTime = 0.25
	end

	currentTime = newTime

	acumulator = acumulator + frameTime

	while acumulator >= dt do
		Roda:update(dt)
		Game:update(dt)
		acumulator = acumulator - dt
	end
end

function love.draw()
	Game:draw()
	Roda:draw()
end

function love.quit()
end
