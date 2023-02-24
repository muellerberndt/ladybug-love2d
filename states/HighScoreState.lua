HighScoreState = Class{__includes = BaseState}


function HighScoreState:init()
    self:getHighScores()
end

function HighScoreState:getHighScores()
    self.highscores = getHighScores(HIGH_SCORES_FILE)
end

function HighScoreState:saveHighScores()
    serialize(self.highscores, HIGH_SCORES_FILE)
end

function HighScoreState:newHighScore(new)
	for _, next in pairs(new) do
		score = next['score']
		name = next['name']

		for i=1,10 do
			if (not self.highscores[i]) then
				self.highscores[i] = {score, name}
				break
			end
			if score > self.highscores[i][1] then
				if i == 10 then
					self.highscores[i] = {score, name}
				else
					for j=9,i,-1 do
						self.highscores[j+1] = self.highscores[j]
					end
					self.highscores[i] = {score, name}
				end
				break
			end
		end

		self:saveHighScores()
		self:getHighScores()
	end
end

function HighScoreState:update(dt)
    if love.keyboard.keyPressed['return'] or love.keyboard.keyPressed['1'] then
        gStateMachine:change('levelstart',
            {
                level = 1,
                players = { PlayerStat(3, 0) },
                extraLettersLit = {},
                specialLettersLit = {}
            })
    end
    if love.keyboard.keyPressed['2'] then
        gStateMachine:change('levelstart',
            {
                level = 1,
                players = { PlayerStat(3, 0), PlayerStat(3, 0) },
                extraLettersLit = {},
                specialLettersLit = {}
            })
    end

    if love.keyboard.keyPressed['space'] then
        gStateMachine:change('title')
    end

    if (os.time() - self.time > 5) then
        gStateMachine:change('title')
    end
end

function HighScoreState:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(largeFont)

    w, h = VIRTUAL_WIDTH, VIRTUAL_HEIGHT
    y = h / 14

    love.graphics.printf({{1, 1, 1}, "High Scores"}, 0, y, w, "center")

    --  love.graphics.setFont(smallFont)

    y = y + h / 14

    for i, info in ipairs(self.highscores) do
        y = y + h / 14
        love.graphics.printf({{1, 0, 0}, "#" .. i .. "   ", {0.68, 0.68, 0.68}, info[2] .. " - " .. info[1]}, w / 6, y, w, "left")
    end
end

function HighScoreState:enter(params)
    if (params and params.new) then
        self:newHighScore(params.new)
    end
    self.time = os.time()
end

function HighScoreState:exit()
end
