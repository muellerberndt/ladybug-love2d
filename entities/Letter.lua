Letter = Class{__includes = Entity}

function Letter:init(x, y, letter)
    Entity.init(self, x, y)

    self.letter = letter

    self.hitbox = {
        x1 = x,
        x2 = x + 3,
        y1 = y,
        y2 = y + 3
    }

    local states = {
        default = {
            {
                duration = 5,
                quad = love.graphics.newQuad(0, 0, 9, 9, 27, 9),
                after = "red"
            },
        },
        yellow = {
            {
                duration = 2,
                quad = love.graphics.newQuad(18, 0, 9, 9, 27, 9),
                after = "default"
             },
        },
        red = {
            {
                duration = 1,
                quad = love.graphics.newQuad(9, 0, 9, 9, 27, 9),
                after = "yellow"
            },
        },
    }

    self.behavior = Behavior(states)

end

function Letter:onCollide()
    sounds['eatitem']:play()
    Event.dispatch('letterAwarded', self)
end


function Letter:destroy()
    sounds['eatdot']:stop()
    sounds['eatdot']:play()

    Entity.destroy(self)
end

function Letter:update(dt)
    self.behavior:update(dt)
    Entity.update(self, dt)
end

function Letter:draw()

    love.graphics.draw(gTextures[self.letter], self.behavior.frame.quad, self.x, self.y)

    Entity.draw(self)
end
