Enemy = Class{__includes = Entity}


function Enemy:getNextStep(ownRow, ownCol, playerRow, playerCol, tilemap)

    -- Most of the time we don't change direction unless there's a wall in the way
    -- Otherwise we generally want to turn into the direction of the player
    -- a value of "0" in the tilemap means the field is free of obstacles

    -- print("Orientation: " .. self.orientation .. ", own pos ".. ownRow .. ", " .. ownCol .. " / player pos " .. playerRow .. ", " .. playerCol)

    if self.orientation == Orientation.UP then
        if tilemap[ownRow - 1][ownCol] == 0 and (playerRow < ownRow or love.math.random() > 0.5) then
            return ownRow - 1, ownCol
        elseif playerCol > ownCol and tilemap[ownRow][ownCol + 1] == 0 then
            return ownRow, ownCol + 1
        elseif playerCol < ownCol and tilemap[ownRow][ownCol - 1] == 0 then
            return ownRow, ownCol -1
        end
    end
    if self.orientation == Orientation.DOWN then
        if tilemap[ownRow + 1][ownCol] == 0 and (playerRow > ownRow or love.math.random() > 0.5) then
            return ownRow + 1, ownCol
        elseif playerCol > ownCol and tilemap[ownRow][ownCol + 1] == 0 then
            return ownRow, ownCol + 1
        elseif playerCol < ownCol and tilemap[ownRow][ownCol -1] == 0 then
            return ownRow, ownCol -1
        end
    end
    if self.orientation == Orientation.LEFT then
        if tilemap[ownRow][ownCol - 1] == 0 and (playerCol < ownCol or love.math.random() > 0.5) then
            return ownRow, ownCol - 1
        elseif playerRow < ownRow and tilemap[ownRow - 1][ownCol] == 0 then
            return ownRow - 1, ownCol
        elseif playerRow > ownRow and tilemap[ownRow + 1][ownCol] == 0 then
            return ownRow + 1, ownCol
        end
    end
    if self.orientation == Orientation.RIGHT then
        if tilemap[ownRow][ownCol + 1] == 0 and (playerCol > ownCol or love.math.random() > 0.5) then
            return ownRow, ownCol + 1
        elseif playerRow < ownRow and tilemap[ownRow - 1][ownCol] == 0 then
            return ownRow - 1, ownCol
        elseif playerRow > ownRow and tilemap[ownRow + 1][ownCol] == 0 then
            return ownRow + 1, ownCol
        end
    end

    -- If not take a random direction

    local freeTiles = {}

    if tilemap[ownRow][ownCol + 1] == 0 then table.insert(freeTiles, {ownRow, ownCol + 1}) end
    if tilemap[ownRow][ownCol - 1] == 0 then table.insert(freeTiles, {ownRow, ownCol - 1}) end
    if tilemap[ownRow + 1][ownCol] == 0 then table.insert(freeTiles, {ownRow + 1, ownCol}) end
    if tilemap[ownRow - 1][ownCol] == 0 then table.insert(freeTiles, {ownRow - 1, ownCol}) end

    local rand = love.math.random(#freeTiles)

    return freeTiles[rand][1], freeTiles[rand][2]

end


-- Path finding for enemies
-- This doesn't work properly
local function getNextStepBFS(ownRow, ownCol, destRow, destCol, tilemap)
    local queue = {}
    local visited = {}

    for i = 1,23,1 do
        visited[i] = {}
    end

    local currentRow = ownRow
    local currentCol = ownCol

    while not (currentRow == destRow and currentCol == destCol) do
        if currentRow > 1 and tilemap[currentRow - 1][currentCol] == 0 and not visited[currentRow - 1][currentCol] then
            table.insert(queue, {currentRow - 1, currentCol})
            visited[currentRow - 1][currentCol] = {currentRow, currentCol}
        end
        if tilemap[currentRow + 1][currentCol] == 0 and not visited[currentRow + 1][currentCol] then
            table.insert(queue, {currentRow + 1, currentCol})
            visited[currentRow + 1][currentCol] = {currentRow, currentCol}
        end
        if currentCol > 1 and tilemap[currentRow][currentCol - 1] == 0 and not visited[currentRow][currentCol - 1] then
            table.insert(queue, {currentRow, currentCol - 1})
            visited[currentRow][currentCol - 1] = {currentRow, currentCol}
        end
        if tilemap[currentRow][currentCol + 1] == 0 and not visited[currentRow][currentCol + 1] then
            table.insert(queue, {currentRow, currentCol + 1})
            visited[currentRow][currentCol + 1] = {currentRow, currentCol}
        end

        if #queue > 0 then
            currentRow = queue[1][1]
            currentCol = queue[1][2]

            table.remove(queue, 1)
        else
            break
        end
    end

    local previousRow
    local previousCol

    while not (currentRow == ownRow and currentCol == ownCol) do
        previousRow = currentRow
        previousCol = currentCol

        local _currentRow = visited[currentRow][currentCol][1]
        currentCol = visited[currentRow][currentCol][2]
        currentRow = _currentRow
    end

    return previousRow, previousCol

end


function Enemy:init(enemyDef, speed, entityManager)

    Entity.init(self, 11 * 8, 16 + 11 * 8, type)

    self.desiredX = self.x
    self.desiredY = self.y

    self.entityManager = entityManager

    self.texture = love.graphics.newImage(enemyDef.spritesheet)

    self.speed = speed

    local g = anim8.newGrid(16, 16, 48, 16)
    self.animation = anim8.newAnimation(g('1-3',1), 0.1)

    self.orientation = Orientation.UP

    self.hitbox = {}

    self.hitbox.x1 = self.x + 2
    self.hitbox.x2 = self.x + 14
    self.hitbox.y1 = self.y + 2
    self.hitbox.y2 = self.y + 14

    self.state = "trapped"

    self.movedBy = 0
	if (table.getn(entityManager.player) == 2 and love.math.random() > 0.5) then
		self.target = 2
	else
		self.target = 1
	end
end

function Enemy:moveTo(row, col)
    self.desiredX = (col - 1) * 8
    self.desiredY = 16 + (row - 1) * 8
end

function Enemy:update(dt)

    self.animation:update(dt)

    if self.state == "roaming" and not self.isFrozen then

        local distance = math.sqrt((self.desiredX - self.x) ^ 2 + (self.desiredY - self.y) ^ 2)

        if distance > 1 then
            local dx = (self.desiredX - self.x) / distance
            local dy = (self.desiredY - self.y) / distance

            if dy > 0 then self.orientation = Orientation.DOWN
            elseif dy < 0  then self.orientation = Orientation.UP
            elseif dx > 0 then self.orientation = Orientation.RIGHT
            elseif dx < 0 then self.orientation = Orientation.LEFT
            end

            self:move(dx * dt * self.speed, dy * dt * self.speed)
        else
            self.x = self.desiredX
            self.y = self.desiredY

            self.hitbox.x1 = self.x + 2
            self.hitbox.x2 = self.x + 14
            self.hitbox.y1 = self.y + 2
            self.hitbox.y2 = self.y + 14

		if (table.getn(self.entityManager.player) == 2 and love.math.random() > 0.95) then
			if self.target == 1 then
				self.target = 2
			else
				self.target = 1
			end
		end
            local ownRow, ownCol = getTileForPosition(self.x, self.y)
            local playerRow, playerCol = getTileForPosition(self.entityManager.player[self.target].x, self.entityManager.player[self.target].y)

            local row, col = self:getNextStep(ownRow, ownCol, playerRow, playerCol, self.entityManager.tilemap)
            self:moveTo(row, col)
        end
    end
    Entity.update(self)

end

function Enemy:draw()
    love.graphics.setColor(1, 1, 1, 1)
    self.animation:draw(self.texture, self.x + 8, self.y + 8, self.orientation, 1, 1, 8, 8)
    Entity.draw(self)
end

function Enemy:reset()
    self.x = 11 * 8
    self.y = 16 + 11 * 8

    self.desiredX = self.x
    self.desiredY = self.y

    self.orientation = Orientation.UP
    self.state = "trapped"

    self.hitbox.x1 = self.x + 2
    self.hitbox.x2 = self.x + 14
    self.hitbox.y1 = self.y + 2
    self.hitbox.y2 = self.y + 14

    self.movedBy = 0

    sounds['die']:play()

    Event.dispatch("enemyTrapped", self)

end

function Enemy:destroy()
    self.isDestroyed = true
end

function Enemy:freeze()
    self.state = "trapped"
end

function Enemy:unfreeze()
    self.state = "roaming"
end


return Enemy
