GameOverState = Class{__includes = BaseState}


function GameOverState:init()
    self.name = ''
end

function GameOverState:textinput(text)
    if #self.name < 3 then
        self.name = self.name .. text
    end
end

function GameOverState:update(dt)
    if love.keyboard.keyPressed['return'] then
        if #self.name ~= 0 then
            gStateMachine:change('highscore', {
                new = {['score'] = self.score, ['name'] = self.name}
            })
        end
    end
    if love.keyboard.keyPressed['backspace'] then
        if #self.name ~= 0 then
            self.name = string.sub(self.name, 1, #self.name - 1)
        end
    end
end

function GameOverState:draw()
    w, h = VIRTUAL_WIDTH, VIRTUAL_HEIGHT
    love.graphics.setFont(largeFont)
    love.graphics.printf({{1, 0, 0}, "New high score!"}, 0, h / 3, w, "center")
    -- love.graphics.setFont(smallFont)
    love.graphics.printf({{1, 1, 1}, "Your Score: ", {0, 1, 0}, self.score}, 0, h - h / 4 - 50, w, "center")
    love.graphics.printf({{1, 1, 0}, "Enter Your Initials"}, 0, h - h / 4, w, "center")
    love.graphics.printf(self.name, 0, h - (h / 4) + 10, w, "center")
end

function GameOverState:enter(params)
    self.score = params.score
end

function GameOverState:exit()
end