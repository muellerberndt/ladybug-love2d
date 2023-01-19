LevelStartState = Class{__includes = BaseState}

function LevelStartState:init()
end

function LevelStartState:update(dt)
end

function LevelStartState:draw()
    love.graphics.setFont(largeFont)
    love.graphics.print("Level " .. self.level .. " start!", 40, 100)
end

function LevelStartState:enter(params)
    self.level = params.level or 1

    Timer.after(1, function()
        gStateMachine:change('play',
            {
                level = self.level,
                score = 0,
                lives = 3
            })
    end)
end

function LevelStartState:exit()
end