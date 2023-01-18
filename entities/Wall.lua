Wall = Class{__includes = Entity}

function Wall:init(x, y)
    Entity.init(self, x, y)
    self.hitbox = {
        x1 = x + 2,
        x2 = x + 4,
        y1 = y + 2,
        y2 = y + 4
    }
end

function Wall:update(dt)
    Entity.update(self, dt)
end

function Wall:draw()
    Entity.draw(self)
end

return Wall