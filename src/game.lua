-- Engine Systems
local CollisionSystem = require (RODA_SRC .. 'system.collision')
local CollisionDebugSystem = require (RODA_SRC .. 'system.collision_debug')
local MovementSystem = require (RODA_SRC .. 'system.movement')
local GravitySystem = require (RODA_SRC .. 'system.gravity')
local RenderSystem = require (RODA_SRC .. 'system.render')
local AnimationSystem = require (RODA_SRC .. 'system.animation')
local CharacterSystem = require (RODA_SRC .. 'system.character')
local CameraFollowSystem = require (RODA_SRC .. 'system.camera_follow')

-- Game Systems
local ProjectileSystem = require (GAME_SRC .. 'system.projectile')
local ExplosionSystem = require (GAME_SRC .. 'system.explosion')
local DeathSystem = require (GAME_SRC .. 'system.death')
local EnemySystem = require (GAME_SRC .. 'system.enemy')
local ItemSystem = require (GAME_SRC .. 'system.item')

-- Entities
local Rocks = require (GAME_SRC .. 'entity.rocks')
local Waterfall = require (GAME_SRC .. 'entity.waterfall')
local Sparkle = require (GAME_SRC .. 'entity.sparkle')
local Skeleton = require (GAME_SRC .. 'entity.skeleton')
local Bomb = require (GAME_SRC .. 'entity.bomb')
local Robot = require (GAME_SRC .. 'entity.robot')
local Wall = require (GAME_SRC .. 'entity.wall')
local Flash = require (GAME_SRC .. 'entity.flash')
local Bullet = require (GAME_SRC .. 'entity.bullet')
local Boss = require (GAME_SRC .. 'entity.boss')

local Sprite = require (RODA_SRC .. 'component.sprite')

local intro_timer = 0
local intro_index = 0
local menu_index = 0

Game = {}

function Game:run()
	Roda.resources:load_shader('default', 'default/vertex.glsl', 'default/fragment.glsl')
	Roda.resources:load_shader('glitch', 'default/vertex.glsl', 'glitch/fragment.glsl')
	Roda.resources:load_shader('blink', 'default/vertex.glsl', 'blink/fragment.glsl')
	Roda.physics.gravity = Vector(0.0, -4.0)

	Roda.bus:emit('scene/load', 'entities')

	-- Systems
	Roda.bus:emit('world/add', ItemSystem())
	Roda.bus:emit('world/add', RenderSystem())
	Roda.bus:emit('world/add', AnimationSystem())
	Roda.bus:emit('world/add', ProjectileSystem())
	Roda.bus:emit('world/add', ExplosionSystem())
	Roda.bus:emit('world/add', EnemySystem())
	Roda.bus:emit('world/add', CharacterSystem())
	Roda.bus:emit('world/add', GravitySystem())
	Roda.bus:emit('world/add', MovementSystem())
	Roda.bus:emit('world/add', DeathSystem())
	Roda.bus:emit('world/add', CollisionSystem())
	Roda.bus:emit('world/add', CollisionDebugSystem())

	Roda.bus:emit('camera/follow', 'horizontal')
	Roda.bus:emit('camera/background', 'bg_jungle_02.png')

	Roda.scene.camera.transform.position.x = -3700

	Roda.bus:register('input/keyboard/pressed', function(key)
		if key == 'p' then
			if Roda.state == 'game' then
				Roda.state = 'editor'
				Roda.debug = true
				Roda.bus:emit('scene/save', 'temp')
				self:unbind()
			else
				Roda.bus:emit('scene/save', 'temp')
				Roda.state = 'game'
				Roda.debug = false
				self:bind()
			end
		end

		if key == 'return' then
			if Roda.state == 'intro' then
				if menu_index == 0 then
					Roda.state = 'game'
					Roda.bus:emit('scene/save', 'entities')
					self:bind()
				else
					love.event.quit()
				end
			end
		end

	end)

	Roda.bus:register('input/keyboard/pressed', function(key)
		if Roda.state == 'intro' then
			if key == 'down' or key == 'up' then
				if menu_index == 0 then
					menu_index = 1
				else
					menu_index = 0
				end
			end

			if key == 'space' or key == 'return' then
				if menu_index == 0 then
					intro_index = 0
					intro_timer = 0
					Roda.state = 'game'
					self:bind()
				else
					love.event.quit()
				end
			end
		end
	end)

	Roda.bus:register('player/defeated', function()
		Roda.retry = true
	end)

	Roda.bus:register('boss/defeated', function()
		self.sparkle.body.kinematic = true
		self.sparkle.controller.disabled = true
		Roda.state = 'ending'
	end)

	self.hud = Sprite('hud', 'assets/textures/hud.png', 40, 40, 0, 1)
	self.intro = Sprite('intro', 'assets/textures/intro.png', 480, 100, 0, 1)
	self.menu = Sprite('menu', 'assets/textures/menu.png', 64, 64, 0, 1)
	self.retry = Sprite('retry', 'assets/textures/retry.png', 80, 80, 0, 1)
	self.ending = Sprite('ending', 'assets/textures/ending.png', 240, 240, 0, 9)
	self.gameover = Sprite('gameover', 'assets/textures/gameover.png', 128, 128, 0, 1)
end

function player_pressed(button)
	local e = Game.sparkle

	if e.controller.disabled then
		return
	end

	if button == 'turn' then
		if e.polarity == 'dark' then
			e.polarity = 'light'
			e.sprite:set_texture('assets/textures/sparkle_light.png')
		elseif e.polarity == 'light' then
			e.polarity = 'dark'
			e.sprite:set_texture('assets/textures/sparkle_dark.png')
		end

		Roda.bus:emit('world/add', Flash(e.transform.position, e.polarity))
	end

	if button == 'fire' then
		if e.polarity == 'dark' then
			if e.state.current ~= 'dashing' then
				e.controller:dash()
			end
		elseif e.polarity == 'light' then
			local position = Vector(e.transform.position.x, e.transform.position.y)
			local direction = Vector(1, 0)
			local rotation = 0

			if e.transform.facing == 'backward' then
				rotation = 180 * math.pi / 180
				direction.x = direction.x * - 1
			end

			Roda.bus:emit('world/add', Bullet(
				'player',
				'bullet_light',
				'assets/textures/bullet_light.png',
				position,
				rotation,
				Vector(4, 4),
				direction,
				500,
				'light'
			))
		end
	end
end

function player_pressing(button)
	local e = Game.sparkle

	if Roda.state ~= 'game' or e.controller.disabled then
		return
	end

	if button == 'left' then
		e.controller:move_left()
	end
	if button == 'right' then
		e.controller:move_right()
	end

	if button == 'fire' then
		if e.polarity == 'dark' then

		elseif e.polarity == 'light' then
			e.controller:move_up()
			e.controller:fly()
		end
	end
end

function Game:bind()
	Roda.bus:register('input/pressed', player_pressed)
	Roda.bus:register('input/pressing', player_pressing)
end

function Game:unbind()
	Roda.bus:remove('input/pressed', player_pressed)
	Roda.bus:remove('input/pressing', player_pressing)
end

function Game:place_entities()
	-- Create entities
	self.waterfall = Waterfall(Vector(-3700, -35))
	self.rocks = Rocks(Vector(-3700, -30))
	self.boss = Boss(Vector(1500, 0))
	self.sparkle = Sparkle(Vector(-3700, 0), Vector(16, 32))
	self.sparkle.controller.player = true

	-- Entities
	Roda.bus:emit('world/add', self.rocks)
	Roda.bus:emit('world/add', self.sparkle)
	Roda.bus:emit('world/add', self.waterfall)
	Roda.bus:emit('world/add', self.boss)
	Roda.bus:emit('camera/target', self.sparkle)

	self.boss.state:switch('idle')
end

function Game:update(dt)
	if Roda.state == 'editor' then
		if love.keyboard.isDown('lctrl') == false then
			if love.keyboard.isDown('q') then
				Roda.scene.camera.transform.position.x = Roda.scene.camera.transform.position.x - 500 * love.timer.getDelta()
			end
			if love.keyboard.isDown('e') then
				Roda.scene.camera.transform.position.x = Roda.scene.camera.transform.position.x + 500 * love.timer.getDelta()
			end
		end
	end

	intro_timer = intro_timer + dt
end

function Game:draw()
	-- Reset graphics
	love.graphics.setColor(255, 255, 255, 255)
	Roda:set_shader('default')

	if Roda.state == 'intro' then
		love.graphics.clear(100, 100, 120, 255)
		love.graphics.draw(
			self.intro.batch:getTexture(),
			self.intro.quads[intro_index],
			love.graphics.getWidth() / 2,
			love.graphics.getHeight() / 3,
			0,
			2, -2,
			self.intro.width / 2,
			self.intro.height / 2
		)

		love.graphics.draw(
			self.menu.batch:getTexture(),
			self.menu.quads[menu_index],
			love.graphics.getWidth() / 2, love.graphics.getHeight() - 150,
			0,
			2, -2,
			self.menu.width / 2,
			self.menu.height / 2
		)

		if intro_timer > 0.08 then
			intro_index = intro_index + 1
			intro_timer = 0
		end

		if intro_index > 18 then
			intro_index = 14
		end
	elseif Roda.state == 'game' or Roda.state == 'editor' then
		if self.sparkle then
			if self.sparkle.hurting then
				Roda:set_shader('glitch')
				Roda.shader:send('channel0', Roda.glitch)
				Roda.shader:send('time', Roda.time)
			else
				Roda.time = 0
			end

			love.graphics.draw(Roda.canvas)

			love.graphics.draw(
				self.hud.batch:getTexture(),
				self.hud.quads[self.sparkle.health],
				75, 40,
				0,
				3, -3,
				self.hud.width / 2,
				self.hud.height / 2
			)
		else
			love.graphics.draw(Roda.canvas)
		end
	end
end
