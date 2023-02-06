LevelStartState = Class{__includes = BaseState}

function LevelStartState:init()
    self.transitionAlpha = 0
end

function LevelStartState:update(dt)
end

function LevelStartState:draw()
    love.graphics.setFont(largeFont)
    love.graphics.setColor(0, 0.68, 1, 1)
    love.graphics.printf("PART " .. self.level, 46, 50, 100, "center")

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(love.graphics.newImage(LevelData[self.level].fruitFile), 63, 68)

    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.printf(" =" .. LevelData[self.level].fruitScore, 46, 75, 100, "center")

    love.graphics.setColor(1, 1, 0, 1)
    love.graphics.printf(LevelData[self.level].fruitName, 46, 92, 100, "center")

    love.graphics.setColor(1, 1, 1, 1)

    for i=0, self.nSkulls - 1, 1 do
        love.graphics.draw(gTextures['skull'], VIRTUAL_WIDTH / 2 - (8 * (self.nSkulls - 1)) + i * 16 - 8, 112)
    end

    local quad = love.graphics.newQuad(0, 0, 9, 9, 27, 9)

    love.graphics.draw(gTextures[self.extraLetter], quad, 72, 138)
    love.graphics.draw(gTextures[self.specialLetter], quad, 88, 138)
    love.graphics.draw(gTextures[self.commonLetter], quad, 104, 138)

    love.graphics.draw(gTextures["heart"], quad, 72, 164)
    love.graphics.draw(gTextures["heart"], quad, 88, 164)
    love.graphics.draw(gTextures["heart"], quad, 104, 164)

    --  love.graphics.print(self.extraLetter.. " - ".. self.specialLetter .. " - " .. self.commonLetter, 59, 120)

    love.graphics.setColor(1, 0.32, 0, 1)
    love.graphics.printf("GOOD LUCK", 46, 188, 100, "center")

    if self.transitionAlpha > 0 then
        love.graphics.setColor(0, 0, 0, self.transitionAlpha)
        love.graphics.rectangle("fill", 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
    end
end

function LevelStartState:enter(params)
    self.level = params.level or 1
    self.lives = params.lives or 3
    self.score = params.score or 0
    self.players = params.players

    -- RNG stuff

    self.extraLetter = EXTRA_LETTERS[love.math.random(#EXTRA_LETTERS)]
    self.specialLetter = SPECIAL_LETTERS[love.math.random(#SPECIAL_LETTERS)]
    self.commonLetter = COMMON_LETTERS[love.math.random(#COMMON_LETTERS)]
    self.nSkulls = love.math.random(LevelData[self.level].maxSkulls)

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
                lives = self.lives,
                players = self.players,
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
