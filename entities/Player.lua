Player = Class{__includes = Entity}

function Player:init(n)
    Entity.init(self, VIRTUAL_WIDTH / 2 - 8, 184)

    self.number = n
    if (n == 1) then
	self.left = "left"
	self.right = "right"
	self.up = "up"
	self.down = "down"
    else
	self.left = "a"
	self.right = "d"
	self.up = "w"
	self.down = "s"
    end
    self.hitbox = {}

    self.hitbox.x1 = self.x + 4
    self.hitbox.x2 = self.x + 12
    self.hitbox.y1 = self.y + 4
    self.hitbox.y2 = self.y + 12

    local g = anim8.newGrid(16, 16, 48, 16)
    self.animation = anim8.newAnimation(g('1-3',1), 0.1)

    g = anim8.newGrid(16, 16, 224, 16)
    self.deathAnimation = anim8.newAnimation(g('1-14', 1), 0.1, function()
        self.deathAnimation:pauseAtEnd()
        self.state = "goingtoheaven"
        self.tick = 0
        self.baseX = self.x
    end)

    self.state = "alive"
    self.frozen = false
    self.orientation = Orientation.UP
end

function Player:freezeIfAlive()
    self.frozen = true
end

function Player:unfreeze()
    self.frozen = false
end

function Player:resetPosition()
    self.x = self.lastX
    self.y = self.lastY

    self.hitbox.x1 = self.x + 4
    self.hitbox.x2 = self.x + 12
    self.hitbox.y1 = self.y + 4
    self.hitbox.y2 = self.y + 12
end

function Player:die()
    sounds['die']:play()
    -- sounds['playerdeath']:play()
    self.state = "dead"
end

function Player:update(dt)

    if self.state == "alive" and not self.frozen then
        self.lastX = self.x
        self.lastY = self.y

        if love.keyboard.isDown(self.left) then
            self.orientation = Orientation.LEFT
            self:move(-PLAYER_SPEED * dt, 0)
        elseif love.keyboard.isDown(self.right) then
            self.orientation = Orientation.RIGHT
            self:move(PLAYER_SPEED * dt, 0)
        elseif love.keyboard.isDown(self.up) then
            self.orientation = Orientation.UP
            self:move(0, -PLAYER_SPEED * dt)
        elseif love.keyboard.isDown(self.down) then
            self.orientation = Orientation.DOWN
            self:move(0, PLAYER_SPEED * dt, 0)
        end

        self.animation:update(dt)
    elseif self.state == "dead" then
        self.deathAnimation:update(dt)
    elseif self.state == "goingtoheaven" then
        self.tick = self.tick + dt

        if self.tick > 2 then
            Event.dispatch("playerDeath")
        end

        self.x = self.baseX + 15 * math.sin(self.tick * 10)
        self.y = self.y - 30 * dt
    end

    Entity.update(self)
end

function Player:draw()

    love.graphics.setColor(1, 1, 1, 1)

    if self.state == "alive" then
        --- Draw from center
        self.animation:draw(gTextures['ladybug'], self.x + 8, self.y + 8, self.orientation, 1, 1, 8, 8)
        Entity.draw(self)
    elseif self.state == "dead" or self.state == "goingtoheaven" then
        self.deathAnimation:draw(gTextures['ghost'], self.x, self.y)
        Entity.draw(self)
    end
end
