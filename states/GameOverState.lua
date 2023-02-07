GameOverState = Class{__includes = BaseState}


function GameOverState:init()
    self.name = { }
    self.position = { }
	self.keys = {
		{left = "left", right = "right", up = "up", down = "down" },
		{left = "a", right = "d", up = "w", down = "s" }
	}
	self.delay = { 0, 0 }
end

function GameOverState:update(dt)
	for i, _ in pairs(self.score) do
		self.delay[i] = self.delay[i] + dt
		if self.delay[i] > 0.3 then
			if love.keyboard.isDown(self.keys[i].left) then
				if self.position[i] ~= 4 and self.position[i] > 1 then
					self.position[i] = self.position[i] - 1
					self.name[i] = string.sub(self.name[i], 1, self.position[i])
				end
				self.delay[i] = 0
			elseif love.keyboard.isDown(self.keys[i].right) then
				if self.position[i] ~= 4 then
					self.position[i] = self.position[i] + 1
					if self.position[i] ~= 4 then
						self.name[i] = self.name[i] .. " "
					else
						done = true
						local new = {}
						for j, e in pairs(self.position) do
							table.insert(new, {['score'] = self.score[j], ['name'] = self.name[j]})
							if e ~= 4 then
								done = false
							end
						end
						if done then
							gStateMachine:change('highscore', {
								new = new
							})
						end
					end
				end
				self.delay[i] = 0
			elseif love.keyboard.isDown(self.keys[i].up) then
				if self.position[i] ~= 4 then
					lastchar = string.sub(self.name[i], #self.name[i])
					if #self.name[i] == 1 then
						self.name[i] = ''
					else
						self.name[i] = string.sub(self.name[i], 1, #self.name[i] - 1)
					end
					self.name[i] = self.name[i] .. ('ABCDEFGHIJKLMNOPQRSTUVWXYZ A'):match(lastchar..'(.)')
				end
				self.delay[i] = 0
			elseif love.keyboard.isDown(self.keys[i].down) then
				if self.position[i] ~= 4 then
					lastchar = string.sub(self.name[i], #self.name[i])
					if #self.name[i] == 1 then
						self.name[i] = ''
					else
						self.name[i] = string.sub(self.name[i], 1, #self.name[i] - 1)
					end
					self.name[i] = self.name[i] .. (' ZYXWUVTSRQPONMLKJIHGFEDCBA '):match(lastchar..'(.)')
				end
				self.delay[i] = 0
			end
		end
	end
end

function GameOverState:draw()
    w, h = VIRTUAL_WIDTH, VIRTUAL_HEIGHT / table.getn(self.score)
	base = 0
	for i, e in pairs(self.score) do
		love.graphics.setFont(largeFont)
		if (not highscores[10]) or (e > highscores[10][1]) then
			love.graphics.printf({{1, 0, 0}, "New high score!"}, 0, base + h / 3, w, "center")
		end
		-- love.graphics.setFont(smallFont)
		love.graphics.printf({{1, 1, 1}, "Player ", {1, 1, 1}, i, {1, 1, 1}, " Score: ", {0, 1, 0}, e}, 0, base + h - h / 4 - 50 / table.getn(self.score), w, "center")
		if (not highscores[10]) or (e > highscores[10][1]) then
			love.graphics.printf({{1, 1, 0}, "Enter Your Initials"}, 0, base + h - h / 4, w, "center")
			if self.position[i] ~= 4 then
				love.graphics.printf(self.name[i] .. "_", 0, base + h - (h / 4) + 10, w, "center")
			else
				love.graphics.printf(self.name[i], 0, base + h - (h / 4) + 10, w, "center")
			end
		end
		base = base + h
    end
end

function GameOverState:enter(params)
    self.score = params.score
	for i, e in pairs(self.score) do
		table.insert(self.name, ' ')
		if (not highscores[10]) or (e > highscores[10][1]) then
			table.insert(self.position, 1)
		else
			table.insert(self.position, 4)
		end
	end
end

function GameOverState:exit()
end
