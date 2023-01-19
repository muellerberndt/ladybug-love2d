LevelStartState = Class{__includes = BaseState}

function LevelStartState:init()
    self.transitionAlpha = 0
end

function LevelStartState:update(dt)
end

function LevelStartState:draw()
    love.graphics.setFont(largeFont)
    love.graphics.print("Level " .. self.level .. " start!", 42, 100)
    love.graphics.print(self.extraLetter.. " - ".. self.specialLetter .. " - " .. self.commonLetter, 59, 120)

    if self.transitionAlpha > 0 then
        love.graphics.setColor(0, 0, 0, self.transitionAlpha)
        love.graphics.rectangle("fill", 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
    end
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

    self.extraLettersLit = table.shallow_copy(params.extraLettersLit)
    self.specialLettersLit = table.shallow_copy(params.specialLettersLit)

    Timer.after(2, function()
        Timer.tween(0.5, {
            [self] = {
                transitionAlpha = 1
            }
        }):finish(function()
            gStateMachine:change('play',
            {
                level = self.level,
                score = self.score,
                lives = self.lives ,
                extraLetter = self.extraLetter,
                specialLetter = self.specialLetter,
                commonLetter = self.commonLetter,
                nSkulls = self.nSkulls,
                extraLettersLit = self.extraLettersLit,
                specialLettersLit = self.specialLettersLit
            })
        end
        )
    end)
end

function LevelStartState:exit()
end