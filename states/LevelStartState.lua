LevelStartState = Class{__includes = BaseState}

function LevelStartState:init()
end

function LevelStartState:update(dt)
end

function LevelStartState:draw()
    love.graphics.setFont(largeFont)
    love.graphics.print("Level " .. self.level .. " start!", 42, 100)
    love.graphics.print(self.extraLetter.. " - ".. self.specialLetter .. " - " .. self.commonLetter, 59, 120)
end

function LevelStartState:enter(params)
    self.level = params.level or 1
    self.lives = params.lives or 3
    self.score = params.score or 0

    -- RNG stuff

    self.extraLetter = EXTRA_LETTERS[love.math.random(#EXTRA_LETTERS)]
    self.specialLetter = SPECIAL_LETTERS[love.math.random(#SPECIAL_LETTERS)]
    self.commonLetter = COMMON_LETTERS[love.math.random(#COMMON_LETTERS)]
    self.nSkulls = love.math.random(3)

    Timer.after(2, function()
        gStateMachine:change('play',
            {
                level = self.level,
                score = self.score,
                lives = self.lives ,
                extraLetter = self.extraLetter,
                specialLetter = self.specialLetter,
                commonLetter = self.commonLetter,
                nSkulls = self.nSkulls
            })
    end)
end

function LevelStartState:exit()
end