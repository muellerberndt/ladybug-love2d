PlayState = Class{__includes = BaseState}


function PlayState:init()
end

function PlayState:reset()
    self.entityManager:reset()
end

function PlayState:setupLevel(level)

    local data = LevelData[level]

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

    local extra_letter = EXTRA_LETTERS[love.math.random(#EXTRA_LETTERS)]
    local special_letter = SPECIAL_LETTERS[love.math.random(#SPECIAL_LETTERS)]
    local common_letter = COMMON_LETTERS[love.math.random(#COMMON_LETTERS)]

    local idx = math.random(#available_tiles)
    local row = available_tiles[idx][1]
    local col = available_tiles[idx][2]
    local x, y = getPositionForTile(row, col)

    self.entityManager:addEntity(Letter(x - 1, y - 1, extra_letter), EntityTypes.LETTER)
    table.remove(available_tiles, idx)

    idx = math.random(#available_tiles)
    row = available_tiles[idx][1]
    col = available_tiles[idx][2]
    x, y = getPositionForTile(row, col)

    self.entityManager:addEntity(Letter(x - 1, y - 1, special_letter), EntityTypes.LETTER)
    table.remove(available_tiles, idx)

    idx = math.random(#available_tiles)
    row = available_tiles[idx][1]
    col = available_tiles[idx][2]
    x, y = getPositionForTile(row, col)

    self.entityManager:addEntity(Letter(x - 1, y - 1, common_letter), EntityTypes.LETTER)
    table.remove(available_tiles, idx)

    local numSkulls = math.random(3)

    for i=1, numSkulls, 1 do
        idx = math.random(#available_tiles)
        row = available_tiles[idx][1]
        col = available_tiles[idx][2]
        x, y = getPositionForTile(row, col)

        self.entityManager:addEntity(Skull(x - 1, y - 1, common_letter), EntityTypes.LETTER)

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

end


function PlayState:update(dt)
    self.entityManager:update(dt)
end

function PlayState:draw()

    love.graphics.draw(gTextures['playfield'], 0, 0)

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

    --- DEBUG
    local row, col = getTileForPosition(self.entityManager.player.x, self.entityManager.player.y)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(largeFont)
    love.graphics.print("x ".. math.floor(self.entityManager.player.x) .. " y ".. math.floor(self.entityManager.player.y) .. " R ".. row .." C ".. col, 10, 10)

    self.entityManager:draw()
end

--[[
    Called when this state is transitioned to from another state.
]]
function PlayState:enter(params)
    self.level = params.level or 1
    self.score = params.score or 0
    self.lives = params.lives or 3

    self:setupLevel(1)

    self.letterAwardedHandler = Event.on('letterAwarded', function(letter)
        print("Letter awarded: " .. letter.letter)

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

        letter:destroy()
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
    end)


    if PLAY_MUSIC then
        sounds['music']:play()
    end
end

--[[
    Called when this state changes to another state.
]]
function PlayState:exit()
    sounds['music']:stop()
    Timer.clear()
    self.deathHandler:remove()
end