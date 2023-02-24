PlayState = Class{__includes = BaseState}


function PlayState:init()
end

function PlayState:reset()
    self.entityManager:reset()
end

function PlayState:update(dt)
    self.entityManager:update(dt)

    Timer.update(dt, self.gameClockTimer)

    -- Check win conditions

    if #self.entityManager.flowers == 0 and #self.entityManager.letters == 0 then
        sounds['stageclear']:play()
        gStateMachine:change(
            "levelstart",
            {
                level = self.level + 1,
                players = self.players,
                extraLettersLit = self.extraLettersLit,
                specialLettersLit = self.specialLettersLit
            }
    )
    end

    local collected = 0

    for letter, status in pairs(self.extraLettersLit) do
        if status == true then
            collected = collected + 1
        end
    end

    if collected == 5 then
        gStateMachine:change('extralife',
            {
                level = self.level,
                players = self.players,
                specialLettersLit = self.specialLettersLit
            })
    end

    collected = 0

    for letter, status in pairs(self.specialLettersLit) do
        if status == true then
            collected = collected + 1
        end
    end

    if collected == 7 then
        gStateMachine:change('special',
            {
                level = self.level,
                players = self.players,
                extraLettersLit = self.extraLettersLit
            })
    end

end

function PlayState:advanceMultiplier()
    if self.multiplier == 1 then self.multiplier = 2
    elseif self.multiplier == 2 then self.multiplier = 3
    else self.multiplier = 5
    end
end

function PlayState:draw()

    love.graphics.draw(gTextures['playfield'], 0, 0)
    love.graphics.draw(gTextures['top'], 1, 1)

    love.graphics.setFont(largeFont)
    love.graphics.setColor(0.68, 0.68, 0.68, 1)
    love.graphics.print("SPECIAL", 9, 9)
    love.graphics.print("EXTRA", 81, 9)
    love.graphics.print("x2x3x5", 137, 9)

    love.graphics.setColor(0, 0.68, 1, 1)

    if self.multiplier >= 2 then love.graphics.print("x2", 137, 9) end
    if self.multiplier >= 3 then love.graphics.print("x3", 153, 9) end
    if self.multiplier >= 5 then love.graphics.print("x5", 169, 9) end

    love.graphics.setColor(1, 1, 0, 1)

    for i, letter in ipairs({'e', 'x', 't', 'r', 'a'}) do
        if self.extraLettersLit[letter] then
            love.graphics.print(letter, 73 + i * 8, 9)
        end
    end

    love.graphics.setColor(1, 0.32, 0, 1)

    for i, letter in ipairs({'s', 'p', 'e', 'c', 'i', 'a', 'l'}) do
        if self.specialLettersLit[letter] then
            love.graphics.print(letter, 1 + i * 8, 9)
        end
    end

    love.graphics.setColor(1, 1, 1, 1)

    for i = 1, self.players[1].lives - 1, 1 do
        love.graphics.draw(gTextures['life'], 6 + (i - 1) * 16, 212)
    end
    if table.getn(self.players) == 2 then
		for i = 1, self.players[2].lives - 1, 1 do
			love.graphics.draw(gTextures['life2'], 170 - (i - 1) * 16, 212)
		end
    end

    love.graphics.draw(self.plantTexture, 8, 224)

    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.print("=" .. LevelData[self.level].fruitScore, 24, 230)

    if SHOW_TILES then
        for y, row in pairs(self.entityManager.tilemap) do
            for x, col in pairs(row) do
                if col == 0 then
                    love.graphics.setColor(0, 0, 1, 0.2)
                elseif col == 1 then
                    love.graphics.setColor(1, 0, 0, 0.2)
                elseif col == 2 then
                    love.graphics.setColor(0, 1, 0, 0.2)
                end
                love.graphics.rectangle("fill", 4 + (x - 1) * 8, 13 + y * 8, 8, 8)
            end
        end
    end

    Clock.draw(self.tick)

    self.entityManager:draw()

    love.graphics.setFont(largeFont)
    love.graphics.printf(self.players[1].score, 6, 210, 101, "left" )
    if table.getn(self.players) == 2 then
		love.graphics.printf(self.players[2].score, 90, 210, 101, "right" )
	end

    if self.transitionAlpha > 0 then
        love.graphics.setColor(0, 0, 0, self.transitionAlpha)
        love.graphics.rectangle("fill", 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
    end
end

--[[
    Called when this state is transitioned to from another state.
]]
function PlayState:enter(params)
    self.level = params.level
    self.players = params.players
    local extraLetter = params.extraLetter
    local specialLetter = params.specialLetter
    local commonLetter = params.commonLetter
    local nSkulls = params.nSkulls

    self.extraLettersLit = params.extraLettersLit
    self.specialLettersLit = params.specialLettersLit

    self.multiplier = 1

    self.transitionAlpha = 1
    self.gameClockTimer = {}

    -- Set up the level

    local data = LevelData[self.level]

    self.plantTexture = love.graphics.newImage(data.fruitFile)

    self.entityManager = EntityManager()
	for index, e in pairs(self.players) do
		if e.lives > 0 then
			self.entityManager:addEntity(Player(index, e), EntityTypes.PLAYER)
		end
	end

    local available_tiles = {}

    for y, row in pairs(tilemap) do
        for x, col in pairs(row) do
            if col == 0 and x % 2 == 0 and y % 2 == 0
            and not (y > 17 and x == 12)
            and not (y == 12 and x == 12)
            and not (y == 10 and x == 12)
            then
                table.insert(available_tiles, {y, x})
            elseif col == 1 then
                local wall = Wall(5 + (x - 1) * 8, 14 + y * 8)
                self.entityManager:addEntity(wall, EntityTypes.WALL)
            end
        end
    end

    local idx = math.random(#available_tiles)
    local row = available_tiles[idx][1]
    local col = available_tiles[idx][2]
    local x, y = getPositionForTile(row, col)

    self.entityManager:addEntity(Letter(x - 1, y - 1, extraLetter), EntityTypes.LETTER)
    table.remove(available_tiles, idx)

    idx = math.random(#available_tiles)
    row = available_tiles[idx][1]
    col = available_tiles[idx][2]
    x, y = getPositionForTile(row, col)

    self.entityManager:addEntity(Letter(x - 1, y - 1, specialLetter), EntityTypes.LETTER)
    table.remove(available_tiles, idx)

    idx = math.random(#available_tiles)
    row = available_tiles[idx][1]
    col = available_tiles[idx][2]
    x, y = getPositionForTile(row, col)

    self.entityManager:addEntity(Letter(x - 1, y - 1, commonLetter), EntityTypes.LETTER)
    table.remove(available_tiles, idx)

    for i=1, 3, 1 do
        idx = math.random(#available_tiles)
        row = available_tiles[idx][1]
        col = available_tiles[idx][2]
        x, y = getPositionForTile(row, col)

        self.entityManager:addEntity(Letter(x - 1, y - 1, "heart"), EntityTypes.LETTER)
        table.remove(available_tiles, idx)
    end

    for i=1, nSkulls, 1 do
        idx = math.random(#available_tiles)

        row = available_tiles[idx][1]
        col = available_tiles[idx][2]
        x, y = getPositionForTile(row, col)

        self.entityManager:addEntity(Skull(x - 1, y - 1), EntityTypes.GAMEOBJECT)
        table.remove(available_tiles, idx)
    end

    for i, tile in pairs(available_tiles) do
        local row = available_tiles[i][1]
        local col = available_tiles[i][2]

        local x, y = getPositionForTile(row, col)

        local flower = Flower(
            x + 2,
            y + 2
        )
        self.entityManager:addEntity(flower, EntityTypes.FLOWER)
    end

    local x, y = getPositionForTile(10, 12)

    self.entityManager:addEntity(Flower(x + 2, y + 2), EntityTypes.FLOWER)

    for _, turnstile in pairs(turnstiles) do
        self.entityManager:addEntity(Turnstile(turnstile.row, turnstile.col, turnstile.orientation), EntityTypes.TURNSTILE)
    end

    self.trappedEnemies = {}

    for _, e in pairs(data.enemies) do

        local enemy = Enemy(e, data.enemySpeed, self.entityManager)

        self.entityManager:addEntity(
            enemy,
            EntityTypes.ENEMY
        )

        table.insert(self.trappedEnemies, enemy)
    end

    self.tick = 0
    self:startClockTick()

    self.awardPointsHandler = Event.on('awardPoints', function(points, player)

        self:awardPoints(points, player)
    end
    )

    self.letterAwardedHandler = Event.on('letterAwarded', function(letter, player)

        self:freeze(0.25)

        local score

        if letter.behavior.state == "red" then
            score = 800
        elseif letter.behavior.state == "yellow" then
            score = 300
        else
            score = 100
        end

        self.entityManager:addEntity(
            PlayFieldScore(letter.x - 5, letter.y + 2, score, self.multiplier),
            EntityTypes.GAMEOBJECT
        )

        if letter.letter == "heart" and letter.behavior.state == "default" then
            self:advanceMultiplier()
        end

        if table.contains({'e', 'x', 't', 'r', 'a'}, letter.letter) and letter.behavior.state == "yellow" then
            self.extraLettersLit[letter.letter] = true
        elseif table.contains({'s', 'p', 'e', 'c', 'i', 'a', 'l'}, letter.letter) and letter.behavior.state == "red" then
            self.specialLettersLit[letter.letter] = true
        end

        self:awardPoints(score, player)

        letter:destroy()
    end
    )

    self.enemyTrappedHandler = Event.on('enemyTrapped', function(enemy)
        table.insert(self.trappedEnemies, enemy)
    end
    )

    self.plantEatenHandler = Event.on('plantEaten', function(plant, player)
        sounds['veggieeaten']:play()
        player.stat.score = player.stat.score + plant.points
        self:freezeEnemies(5)
    end
    )

    self.deathHandler = Event.on('playerDeath', function(player)

        Timer.clear(self.gameClockTimer)

        local data = LevelData[self.level]

        for _, enemy in pairs(self.entityManager.enemies) do
            enemy:destroy()
        end

		player.stat.lives = player.stat.lives - 1

		local dead = true
		for _, e in pairs(self.players) do
			if e.lives ~= 0 then
				dead = false
			end
		end

        if dead then

            highscores = getHighScores(HIGH_SCORES_FILE)

            changed = false

			if (not highscores[10]) or (self.players[1].score > highscores[10][1]) then
				changed = true
			elseif (table.getn(self.players) == 2) and (self.players[2].score > highscores[10][1]) then
				changed = true
			end
            for i=1,10 do
                if (not highscores[i]) or (self.players[1].score > highscores[i][1]) then
                    changed = true
                    break
                end
            end

            if not changed then gStateMachine:change('title')
            else
				local score = {}
				for _, e in pairs(self.players) do
					table.insert(score, e.score)
				end
				gStateMachine:change("gameover", {
					score = score
				})
            end
        end

		self.entityManager.player = {}
		for i, e in pairs(self.players) do
			if e.lives > 0 then
				self.entityManager:addEntity(Player(i, e), EntityTypes.PLAYER)
			end
		end

        self.trappedEnemies = {}

        for _, e in pairs(data.enemies) do

            local enemy = Enemy(e, data.enemySpeed, self.entityManager)

            self.entityManager:addEntity(
                enemy,
                EntityTypes.ENEMY
            )

            table.insert(self.trappedEnemies, enemy)
        end

        self.tick = 0

        self:startClockTick()

    end)

    if PLAY_MUSIC then
        sounds['music']:play()
    end

    Timer.tween(0.5, {
        [self] = {
            transitionAlpha = 0
        }
    })
end

--[[
    Called when this state changes to another state.
]]
function PlayState:exit()
    sounds['music']:stop()
    Timer.clear()
    Timer.clear(self.gameClockTimer)
    self.deathHandler:remove()
    self.letterAwardedHandler:remove()
    self.enemyTrappedHandler:remove()
    self.awardPointsHandler:remove()
    self.plantEatenHandler:remove()
end

function PlayState:awardPoints(points, player)
    player.stat.score = player.stat.score + points * self.multiplier
end

function PlayState:startClockTick()

    local data = LevelData[self.level]

    Timer.every(data.tick, function()
        self.tick = self.tick + 1

        if (self.tick == 82 or self.tick == 174) and #self.trappedEnemies > 0 then
            sounds['enemylaunch']:play()
        end
        if (self.tick == 92 or self.tick == 184) and #self.trappedEnemies > 0 then
            local idx = #self.trappedEnemies
            self.trappedEnemies[idx].state = "roaming"
            table.remove(self.trappedEnemies, idx)

            if  #self.trappedEnemies == 0 then

                local hasPlant = false

                for _, e in pairs(self.entityManager.gameObjects) do
                    if e.type == "plant" then
                        hasPlant = true
                        break
                    end
                end

                if not hasPlant then
                    self.entityManager:addEntity(Plant(
                        11 * 8,
                        16 + 11 * 8,
                        LevelData[self.level].fruitFile,
                        LevelData[self.level].fruitScore
                        ),
                        EntityTypes.GAMEOBJECT
                    )
                end
            end
        end
        if self.tick == 184 then
            self.tick = 0
        end
    end):group(self.gameClockTimer)
end

function PlayState:freezeEnemies(seconds)
    self.entityManager:freezeEnemies()
    Timer.after(seconds, function()
        self.entityManager:unfreezeEnemies()
    end)

end

function PlayState:freeze(seconds)
    Timer.clear(self.gameClockTimer)
    self.entityManager:freezeGame()
    Timer.after(seconds, function()
        self.entityManager:unfreezeGame()
        self:startClockTick()
    end)

end
