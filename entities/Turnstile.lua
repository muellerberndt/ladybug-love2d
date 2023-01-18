Turnstile = Class{__includes = Entity}

function Turnstile:init(row, col, orientation)
    Entity.init(self, col * 8 - 1, 16 + row * 8)

    self.row = row
    self.col = col
    self.orientation = orientation

    self.state = "still"
    self.rotation = 0

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
        if playerRow == self.row and (playerColumn >= self.col - 2 and playerColumn <= self.col -1) then
            sounds['turnstile']:play()

            self.state = "rotating"

            if playerOrientation == Orientation.UP then
                self.rotation = 0
                Timer.tween(0.1, {
                    [self] = {rotation = math.pi / 2}
                }):finish(function()
                    self.orientation = "vertical"
                    self.state = "still"
                end
                )
            elseif playerOrientation == Orientation.DOWN then
                self.rotation = 0
                Timer.tween(0.1, {
                    [self] = {rotation = - math.pi / 2 }
                }):finish(function()
                    self.orientation = "vertical"
                    self.state = "still"
                end
                )
            end
        elseif playerRow == self.row and (playerColumn >= self.col and playerColumn <= self.col + 1) then
            sounds['turnstile']:play()

            self.state = "rotating"

            if playerOrientation == Orientation.UP then
                self.rotation = 0
                Timer.tween(0.1, {
                    [self] = {rotation = - math.pi / 2}
                }):finish(function()
                    self.orientation = "vertical"
                    self.state = "still"
                end
                )
            elseif playerOrientation == Orientation.DOWN then
                self.rotation = 0
                Timer.tween(0.1, {
                    [self] = {rotation = math.pi / 2 }
                }):finish(function()
                    self.orientation = "vertical"
                    self.state = "still"
                end
                )
            end
        end
    elseif self.orientation == "vertical" then
        if playerColumn == self.col and (playerRow >= self.row -2 and playerRow <= self.row -1) then
            sounds['turnstile']:play()
            self.state = "rotating"
            if playerOrientation == Orientation.LEFT then
                -- self:switchToHorizontal()
                -- self.state = "still"
                self.rotation = math.pi / 2
                Timer.tween(0.1, {
                    [self] = {rotation = 0}
                }):finish(function()
                    self.orientation = "horizontal"
                    self.state = "still"
                end)
            elseif playerOrientation == Orientation.RIGHT then
                -- self:switchToHorizontal()
                -- self.state = "still"
                self.rotation = - math.pi / 2
                Timer.tween(0.1, {
                    [self] = {rotation = 0}
                }):finish(function()
                    self.orientation = "horizontal"
                    self.state = "still"
                end)
            end
        elseif playerColumn == self.col and (playerRow >= self.row and playerRow <= self.row + 1) then
            sounds['turnstile']:play()
            self.state = "rotating"
            if playerOrientation == Orientation.LEFT then
                self.rotation = - math.pi / 2
                Timer.tween(0.1, {
                    [self] = {rotation = 0}
                }):finish(function()
                    self.orientation = "horizontal"
                    self.state = "still"
                end)
            elseif playerOrientation == Orientation.RIGHT then
                -- self:switchToHorizontal()
                -- self.state = "still"
                self.rotation = math.pi / 2
                Timer.tween(0.1, {
                    [self] = {rotation = 0}
                }):finish(function()
                    self.orientation = "horizontal"
                    self.state = "still"
                end)
            end
        end
    end



    Entity.update(self, dt)
end

function Turnstile:draw()

    if self.state == "still" then
        if self.orientation == "horizontal" then
            love.graphics.draw(gTextures['turnstile'], self.quadHorizontal, self.x - 15, self.y - 15)
        else
            love.graphics.draw(gTextures['turnstile'], self.quadVertical, self.x - 15, self.y - 15)
        end
    else
        love.graphics.draw(gTextures['turnstile'], self.quadHorizontal, self.x + 1, self.y + 1, self.rotation, 1, 1, 16, 16)
    end

    Entity.draw(self)
end
