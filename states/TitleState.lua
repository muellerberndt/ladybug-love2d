TitleState = Class{__includes = BaseState}


function TitleState:init()
end

function TitleState:update(dt)

    self.animation:update(dt)

    if love.keyboard.keyPressed['return'] then
        gStateMachine:change('levelstart',
            {
                level = 1,
                score = 0,
                lives = 3,
                players = 1,
                extraLettersLit = {},
                specialLettersLit = {}
            })
    end

    if love.keyboard.keyPressed['2'] then
        gStateMachine:change('levelstart',
            {
                level = 1,
                score = 0,
                lives = 3,
                players = 2,
                extraLettersLit = {},
                specialLettersLit = {}
            })
    end

    if love.keyboard.keyPressed['space'] then
        gStateMachine:change('highscore')
    end

    if (os.time() - self.time > 5) then
        gStateMachine:change('highscore')
    end
end

function TitleState:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(gTextures['title'], 8, 105)
    love.graphics.setColor(1, 0.68, 1, 1)
    love.graphics.setFont(largeFont)
    love.graphics.print("PRESS ENTER", 60, 180)

    love.graphics.setColor(1, 1, 1, 1)
    self.animation:draw(self.tBeetle, 155, 30, Orientation.LEFT, 1, 1, 8, 8)
    self.animation:draw(self.tHummer, 30, 70, Orientation.RIGHT, 1, 1, 8, 8)
    self.animation:draw(self.tScarab, 60, 20, Orientation.UP, 1, 1, 8, 8)
    self.animation:draw(self.tMantis, 115, 80, Orientation.UP, 1, 1, 8, 8)
    self.animation:draw(gTextures['ladybug'], 30, 175, Orientation.RIGHT, 1, 1, 8, 8)


end

function TitleState:enter()
    self.time = os.time()

    local g = anim8.newGrid(16, 16, 48, 16)
    self.animation = anim8.newAnimation(g('1-3',1), 0.1)

    self.tBeetle = love.graphics.newImage(EnemyTypes.BEETLE.spritesheet)
    self.tHummer = love.graphics.newImage(EnemyTypes.HUMMER.spritesheet)
    self.tMantis= love.graphics.newImage(EnemyTypes.MANTIS.spritesheet)
    self.tScarab = love.graphics.newImage(EnemyTypes.SCARAB.spritesheet)
end

function TitleState:exit()
end
