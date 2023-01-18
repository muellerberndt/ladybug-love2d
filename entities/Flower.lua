Flower = Class{__includes = Entity}

function Flower:init(x, y)
    Entity.init(self, x, y)

    self.hitbox = {
        x1 = x,
        x2 = x + 3,
        y1 = y,
        y2 = y + 3
    }
end

function Flower:destroy()
    sounds['eatdot']:stop()
    sounds['eatdot']:play()

    Entity.destroy(self)
end

function Flower:update(dt)
    Entity.update(self, dt)
end

function Flower:draw()

    love.graphics.draw(gTextures['flower'], self.x, self.y)

    Entity.draw(self)
end

return GameObject