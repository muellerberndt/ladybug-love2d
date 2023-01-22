TitleState = Class{__includes = BaseState}


function TitleState:init()
end

function TitleState:update(dt)
    if love.keyboard.keyPressed['return'] then
        gStateMachine:change('levelstart',
            {
                level = 1,
                score = 0,
                lives = 3,
                extraLettersLit = {},
                specialLettersLit = {}
            })
    end

    if love.keyboard.keyPressed['space'] then
        gStateMachine:change('highscore')
    end

    if (os.time() - self.time > 5) then
        gStateMachine:change('highscore')
    end
end

function TitleState:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(gTextures['title'], 8, 105)
    love.graphics.setColor(1, 0.68, 1, 1)
    love.graphics.setFont(largeFont)
    love.graphics.print("PRESS ENTER", 60, 170)
end

function TitleState:enter()
    self.time = os.time()
end

function TitleState:exit()
end