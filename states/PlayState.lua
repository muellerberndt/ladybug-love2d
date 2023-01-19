PlayState = Class{__includes = BaseState}


function PlayState:init()
    self.transitionAlpha = 1
end

function PlayState:reset()
    self.entityManager:reset()
end

function PlayState:update(dt)
    self.entityManager:update(dt)

    -- Check win condition

    if #self.entityManager.flowers == 0 and #self.entityManager.letters == 0 then
        sounds['stageclear']:play()
        gStateMachine:change(
            "levelstart",
            {
                level = self.level + 1,
                score = self.score,
                lives = self.lives ,
            }
    )
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

    -- --- DEBUG
    -- local row, col = getTileForPosition(self.entityManager.player.x, self.entityManager.player.y)

    -- love.graphics.setColor(1, 1, 1, 1)
    -- love.graphics.setFont(largeFont)
    -- love.graphics.print("x ".. math.floor(self.entityManager.player.x) .. " y ".. math.floor(self.entityManager.player.y) .. " R ".. row .." C ".. col, 10, 10)

    self.entityManager:draw()

    love.graphics.setFont(largeFont)
    love.graphics.printf(self.score, 90, 210, 101, "right" )

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
    self.score = params.score
    self.lives = params.lives
    local extraLetter = params.extraLetter
    local specialLetter = params.specialLetter
    local commonLetter = params.commonLetter
    local nSkulls = params.nSkulls

    self.multiplier = 1

    -- Set up the level

    local data = LevelData[self.level]

    self.entityManager = EntityManager()
    self.entityManager:addEntity(Player(), EntityTypes.PLAYER)

    local available_tiles = {}

    for y, row in pairs(tilemap) do
        for x, col in pairs(row) do
            if col == 0 and x % 2 == 0 and y % 2 == 0
            and not (y > 17 and x == 12)
            and not (y == 12 and x == 12)
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

    Timer.every(data.tick, function()
        self.tick = self.tick + 1

        if (self.tick == 82 or self.tick == 174) and #self.trappedEnemies > 0 then
            sounds['enemylaunch']:play()
        end
        if (self.tick == 92 or self.tick == 184) and #self.trappedEnemies > 0 then
            local idx = #self.trappedEnemies
            self.trappedEnemies[idx].state = "roaming"
            table.remove(self.trappedEnemies, idx)
        end
        if self.tick == 184 then
            self.tick = 0
        end
    end)

    self.awardPointsHandler = Event.on('awardPoints', function(points)

        self:awardPoints(points)
    end
    )

    self.letterAwardedHandler = Event.on('letterAwarded', function(letter)

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
            PlayFieldScore(letter.x - 5, letter.y + 2, score),
            EntityTypes.GAMEOBJECT
        )

        self:awardPoints(score)

        letter:destroy()
    end
    )

    self.enemyTrappedHandler = Event.on('enemyTrapped', function(enemy)
        table.insert(self.trappedEnemies, enemy)
    end
    )

    self.deathHandler = Event.on('playerDeath', function(dt)

        Timer.clear()

        local data = LevelData[self.level]

        for _, enemy in pairs(self.entityManager.enemies) do
            enemy:destroy()
        end

        self.entityManager.player:destroy()

        self.lives = self.lives - 1

        if self.lives == 0 then
            gStateMachine:change("title")
        end

        self.entityManager:addEntity(Player(), EntityTypes.PLAYER)

        self.trappedEnemies = {}

        for _, e in pairs(data.enemies) do

            local enemy = Enemy(e, data.enemySpeed, self.entityManager)

            self.entityManager:addEntity(
                enemy,
                EntityTypes.ENEMY
            )

            table.insert(self.trappedEnemies, enemy)
        end

        if PLAY_MUSIC then
            sounds['music']:play()
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
    self.deathHandler:remove()
    self.letterAwardedHandler:remove()
    self.enemyTrappedHandler:remove()
    self.awardPointsHandler:remove()
end


function PlayState:awardPoints(points)
    self.score = self.score + points * self.multiplier
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
        end
        if self.tick == 184 then
            self.tick = 0
        end
    end)
end

function PlayState:freeze(seconds)
    Timer.clear()
    self.entityManager:freezeGame()
    Timer.after(seconds, function()
        self.entityManager:unfreezeGame()
        self:startClockTick()
    end)

end