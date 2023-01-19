PlayFieldScore = Class{__includes = Entity}

function PlayFieldScore:init(x, y, score)
    Entity.init(self, x, y, score)

    self.yScale = 1
    self.score = score

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
    love.graphics.setColor(1, 1, 1, self.alpha)
    love.graphics.print(self.score, self.x, self.y, 0)

    Entity.draw(self)
end
