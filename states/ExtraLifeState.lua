ExtraLifeState = Class{__includes = BaseState}


function ExtraLifeState:init()
end

function ExtraLifeState:update(dt)
end

function ExtraLifeState:draw()
    love.graphics.setFont(largeFont)
    love.graphics.print("Extra life awarded! Starting next level...", 42, 100)
end

function ExtraLifeState:enter(params)
    self.level = params.level
    self.score = params.score
    self.lives = params.lives
    self.specialLettersLit = params.specialLettersLit

    Timer.after(2, function ()
        gStateMachine:change('levelstart',
            {
                level = self.level + 1,
                score = self.score,
                lives = self.lives + 1,
                extraLettersLit = {},
                specialLettersLit = self.specialLettersLit
            })
    end)
end

function ExtraLifeState:exit()
end