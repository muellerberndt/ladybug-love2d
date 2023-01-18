--- Doors are walls that enemies but don't block the player.
--- The player can change the location of doors on the map by operating the turnstiles.

Door = Class{__includes = Entity}

function Door:init(x, y)
    Entity.init(self, x, y)
    self.hitbox = {
        x1 = x + 2,
        x2 = x + 4,
        y1 = y + 2,
        y2 = y + 4
    }
end

function Door:update(dt)
    Entity.update(self, dt)
end

function Door:draw()
    Entity.draw(self)
end

return Wall