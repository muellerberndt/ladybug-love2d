ExtraLifeState = Class{__includes = BaseState}


function ExtraLifeState:init()
end

function ExtraLifeState:update(dt)
end

function ExtraLifeState:draw()
    love.graphics.setFont(mediumFont)
    love.graphics.printf("CONGRATULATIONS!", 0, 100, VIRTUAL_WIDTH, "center")
    love.graphics.printf("YOU WIN", 0, 115, VIRTUAL_WIDTH, "center")

    love.graphics.setColor(1, 1, 0)
    love.graphics.printf("EXTRA LADY BUG", 0, 130, VIRTUAL_WIDTH, "center")
end

function ExtraLifeState:enter(params)
    self.level = params.level
    self.score = params.score
    self.lives = params.lives
    self.specialLettersLit = params.specialLettersLit

    Timer.after(5, function ()
        gStateMachine:change('levelstart',
            {
                level = self.level + 1,
                score = self.score,
                lives = self.lives + 1,
                extraLettersLit = {},
                specialLettersLit = self.specialLettersLit
            })
    end)

    sounds['extramusic']:play()


end

function ExtraLifeState:exit()
end