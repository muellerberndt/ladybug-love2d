LevelStartState = Class{__includes = BaseState}

function LevelStartState:init()
    self.level = 1
end

function LevelStartState:update(dt)
end

function LevelStartState:draw()
    love.graphics.print("Level " .. self.level .. " start!", 30, 100)
end

function LevelStartState:enter(params)
    self.level = params.level

    Timer.after(1, function()
        gStateMachine:change('play',
            {
                level = 1,
                score = 0,
                lives = 3
            })
    end)
end

function LevelStartState:exit()
end