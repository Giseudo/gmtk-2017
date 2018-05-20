love.graphics.setDefaultFilter('nearest', 'nearest', 1)

require "env"
require "roda"
require "src.game"

local currentTime = love.timer.getTime()
local acumulator = 0.0
local frameTime = 0
local delta = 1 / 60

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

	acumulator = acumulator + frameTime
	currentTime = newTime

	while acumulator >= delta do
		Roda:update(delta)
		Game:update(delta)
		acumulator = acumulator - delta
	end

	if dt < delta then
		love.timer.sleep(delta - dt)
	end
end

function love.draw()
	Game:draw()
	Roda:draw()
end

function love.quit()
end
