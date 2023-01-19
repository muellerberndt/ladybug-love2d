PlayFieldScore = Class{__includes = Entity}

function PlayFieldScore:init(x, y, score, multiplier)
    Entity.init(self, x, y, score)
    self.score = score
    self.multiplier = multiplier

    Timer.tween(0.4, {
        [self] = {
            y = y - 15
    }
    }):finish(function()
        self.isDestroyed = true
    end)
end

function PlayFieldScore:update(dt)
    Entity.update(self, dt)
end

function PlayFieldScore:draw()

    love.graphics.setFont(smallFont)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(self.score, self.x, self.y, 0)
    love.graphics.print("x" .. self.multiplier, self.x + 2, self.y + 6, 0)

    Entity.draw(self)
end
