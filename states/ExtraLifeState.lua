ExtraLifeState = Class{__includes = BaseState}


function ExtraLifeState:init()
end

function ExtraLifeState:update(dt)
end

function ExtraLifeState:draw()
    love.graphics.setFont(largeFont)
    love.graphics.printf("CONGRATULATIONS!", 0, 100, VIRTUAL_WIDTH, "center")
    love.graphics.printf("YOU WIN", 0, 115, VIRTUAL_WIDTH, "center")

    love.graphics.setColor(1, 1, 0)
    love.graphics.printf("EXTRA LADY BUG", 0, 130, VIRTUAL_WIDTH, "center")
end

function ExtraLifeState:enter(params)
    self.level = params.level
    self.players = params.players
    self.specialLettersLit = params.specialLettersLit
	for index, e in pairs(self.players) do
		e.lives = e.lives + 1
	end

    Timer.after(5, function ()
        gStateMachine:change('levelstart',
            {
                level = self.level + 1,
                players = self.players,
                extraLettersLit = {},
                specialLettersLit = self.specialLettersLit
            })
    end)

    sounds['extramusic']:play()


end

function ExtraLifeState:exit()
end
