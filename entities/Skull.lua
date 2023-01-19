Skull = Class{__includes = Entity}

function Skull:init(x, y)
    Entity.init(self, x, y)

    self.type = "skull"

    self.hitbox = {
        x1 = x,
        x2 = x + 3,
        y1 = y,
        y2 = y + 3
    }
end

function Skull:destroy()
    Entity.destroy(self)
end

function Skull:update(dt)
    Entity.update(self, dt)
end

function Skull:draw()

    love.graphics.draw(gTextures['skull'], self.x, self.y)

    Entity.draw(self)
end
