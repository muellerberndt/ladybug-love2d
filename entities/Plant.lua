Plant = Class{__includes = Entity}

function Plant:init(x, y, imageFile, points)

    Entity.init(self, x, y)

    self.type = "plant"

    self.hitbox = {
        x1 = x,
        x2 = x + 16,
        y1 = y,
        y2 = y + 16
    }

    self.texture = love.graphics.newImage(imageFile)
    self.points = points
end

function Plant:destroy()
    Entity.destroy(self)
end

function Plant:update(dt)
    Entity.update(self, dt)
end

function Plant:draw()

    love.graphics.draw(self.texture, self.x, self.y)

    Entity.draw(self)
end
