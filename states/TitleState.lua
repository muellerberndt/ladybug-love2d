TitleState = Class{__includes = BaseState}


function TitleState:init()
end

function TitleState:update(dt)
    if love.keyboard.isDown('return') then
        gStateMachine:change('play')
    end
end

function TitleState:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(gTextures['title'], 8, 105)
    love.graphics.setColor(1, 0.68, 1, 1)
    love.graphics.print("PRESS ENTER", 60, 170)
end

function TitleState:enter()
end

function TitleState:exit()
end