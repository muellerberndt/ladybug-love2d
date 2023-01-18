Turnstile = Class{__includes = Entity}

function Turnstile:init(row, col, orientation)
    Entity.init(self, col * 8 - 1, 16 + row * 8)

    self.row = row
    self.col = col
    self.orientation = orientation

    self.quadHorizontal = love.graphics.newQuad(0, 0, 32, 32, gTextures['turnstile'])
    self.quadVertical = love.graphics.newQuad(64, 0, 32, 32, gTextures['turnstile'])
end

function Turnstile:switchToVertical()
    self.orientation = "vertical"
end

function Turnstile:switchToHorizontal()
    self.orientation = "horizontal"
end

function Turnstile:update(playerRow, playerColumn, playerOrientation)

    if self.orientation == "horizontal" then
        if playerRow == self.row and (playerColumn >= self.col - 2 and playerColumn <= self.col + 1)
        and (playerOrientation == Orientation.UP or playerOrientation == Orientation.DOWN) then
                sounds['turnstile']:stop()
                sounds['turnstile']:play()
                self:switchToVertical()
        end
    else
        if playerColumn == self.col and (playerRow >= self.row -2 and playerRow <= self.row + 1)
        and (playerOrientation == Orientation.LEFT or playerOrientation == Orientation.RIGHT) then
                sounds['turnstile']:stop()
                sounds['turnstile']:play()
                self:switchToHorizontal()
        end
    end

    Entity.update(self, dt)
end

function Turnstile:draw()

    if self.orientation == "horizontal" then
        love.graphics.draw(gTextures['turnstile'], self.quadHorizontal, self.x - 15, self.y - 15)
    else
        love.graphics.draw(gTextures['turnstile'], self.quadVertical, self.x - 15, self.y - 15)
    end

    Entity.draw(self)
end
