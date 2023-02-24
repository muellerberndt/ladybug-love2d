SpecialState = Class{__includes = BaseState}


function SpecialState:init()
end

function SpecialState:update(dt)
end

function SpecialState:draw()
    love.graphics.setFont(largeFont)
    love.graphics.printf("CONGRATULATIONS!", 0, 100, VIRTUAL_WIDTH, "center")
    love.graphics.printf("YOU WIN", 0, 115, VIRTUAL_WIDTH, "center")

    love.graphics.setColor(1, 1, 0)
    love.graphics.printf("2 EXTRA LADY BUGS", 0, 130, VIRTUAL_WIDTH, "center")
end

function SpecialState:enter(params)
    self.level = params.level
    self.players = params.players
    self.extraLettersLit = params.extraLettersLit
	for index, e in pairs(self.players) do
		e.lives = e.lives + 2
	end

    Timer.after(5, function ()
        gStateMachine:change('levelstart',
            {
                level = self.level + 1,
                players = self.players,
                extraLettersLit = self.extraLettersLit,
                specialLettersLit = {}
            })
    end)

    sounds['specialmusic']:play()


end

function SpecialState:exit()
end
