EntityTypes = {
	PLAYER = 1,
	ENEMY = 2,
    LETTER = 3,
    FLOWER = 4,
    TURNSTILE = 5,
    WALL = 6,
    GAMEOBJECT = 7
}

EntityManager = Class{}

function EntityManager:init()
    self.player = {}
    self.enemies = {}
    self.walls = {}
    self.letters = {}
    self.flowers = {}
    self.turnstiles = {}
    self.gameObjects = {}

    self.size = 0
    self.gameFrozen = false

    self.tilemap = {}
end

function EntityManager:addEntity(entity, type)
	if type == EntityTypes.PLAYER then
		table.insert(self.player, entity)
	elseif type == EntityTypes.ENEMY then
		table.insert(self.enemies, entity)
	elseif type == EntityTypes.WALL then
		table.insert(self.walls, entity)
	elseif type == EntityTypes.LETTER then
		table.insert(self.letters, entity)
	elseif type == EntityTypes.FLOWER then
		table.insert(self.flowers, entity)
	elseif type == EntityTypes.TURNSTILE then
		table.insert(self.turnstiles, entity)
	elseif type == EntityTypes.GAMEOBJECT then
		table.insert(self.gameObjects, entity)
	end
	self.size = self.size + 1
end

function EntityManager:getCount()
	return self.size
end

function EntityManager:updateTable(entityTable, dt)

    local i = 1
	while i <= #entityTable do
		entityTable[i]:update(dt)
		if entityTable[i].isDestroyed then
			table.remove(entityTable, i)
			self.size = self.size - 1
		else
			i = i + 1
		end
	end
end

function EntityManager:freezeEnemies()
    for _, e in pairs(self.enemies) do
        e:freeze()
    end
end

function EntityManager:unfreezeEnemies()
    for _, e in pairs(self.enemies) do
        e:unfreeze()
    end
end

function EntityManager:freezeGame()
	self.gameFrozen = true
	for _, e in pairs(self.player) do
		e:freezeIfAlive()
	end
end

function EntityManager:unfreezeGame()
	self.gameFrozen = false
	for _, e in pairs(self.player) do
		e:unfreeze()
	end
end

function EntityManager:update(dt)

	for _, e in pairs(self.player) do
		e:update(dt)
	end

	if not self.gameFrozen then

	for _, e in pairs(self.player) do
		if e.state == "alive" then

			for i,v in ipairs(self.walls) do
				if v:collide(e) then
					e:resetPosition()
				end
			end

			for i,v in ipairs(self.enemies) do
				if v:collide(e) and e.state == "alive" then
					e:die()
				end
			end

			for i,v in ipairs(self.flowers) do
				if v:collide(e) then
					v:onCollide(e)
				end
			end

			for _, t in pairs(self.turnstiles) do
				local row, col = getTileForPosition(e.x, e.y)
				t:update(
					row,
					col,
					e.orientation
				)
			end

			for i,v in ipairs(self.gameObjects) do
				if v.type == "skull" and v:collide(e) then
					v:destroy()
					e:die()
				elseif v.type == "plant" and v:collide(e) then
					Event.dispatch("plantEaten", v, e)
					v:destroy()
				end
			end
		end

	end

        --- Update door positions based on turnstiles & their respective orientation

        self.tilemap = deepcopy(tilemap)

        for _, t in pairs(self.turnstiles) do
            if t.orientation == "horizontal" then
                self.tilemap[t.row][t.col - 1] = 2
                self.tilemap[t.row][t.col + 1] = 2
            else
                self.tilemap[t.row - 1][t.col] = 2
                self.tilemap[t.row + 1][t.col] = 2
            end
        end

        self:updateTable(self.letters, dt)
        self:updateTable(self.flowers, dt)
        self:updateTable(self.enemies, dt)

        for i,e in ipairs(self.enemies) do
            for i,v in ipairs(self.gameObjects) do
                if v.type == "skull" and v:collide(e) then
                    v:destroy()
                    e:reset()
                end
            end
        end

	for i,v in ipairs(self.letters) do
		for _, e in pairs(self.player) do
			if v:collide(e) then
				v:onCollide(e)
			end
		end
	end

        self:updateTable(self.gameObjects, dt)
    end
end

function EntityManager:drawTable(entityTable)
	for i,v in ipairs(entityTable) do v:draw() end
end

function EntityManager:draw()
    self:drawTable(self.walls)
	self:drawTable(self.gameObjects)
	self:drawTable(self.turnstiles)
	self:drawTable(self.flowers)
	self:drawTable(self.letters)
	self:drawTable(self.enemies)
	self:drawTable(self.player)
end


function EntityManager:resetForNewStage()
    self.player = {}
    self.enemies = {}
    self.letters = {}
    self.flowers = {}
    self.turnstiles = {}
    self.gameObjects = {}

	self.size = 0
end
