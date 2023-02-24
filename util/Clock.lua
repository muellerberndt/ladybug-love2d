Clock = {}

function drawTick(n)
    if n < 11 then
        love.graphics.rectangle("fill", 96 + n * 8, 19, 7, 4)
    elseif n == 11 then
        love.graphics.rectangle("fill", 184, 19, 6, 4)
        love.graphics.rectangle("fill", 186, 19, 4, 5)
    elseif n > 11 and n < 34 then
        love.graphics.rectangle("fill", 186, 17 + (n - 11) * 8, 4, 7)
    elseif n == 35 then
        love.graphics.rectangle("fill", 186, 201, 4, 6)
        love.graphics.rectangle("fill", 184, 203, 4, 4)
    elseif n > 35 and n < 58 then
        love.graphics.rectangle("fill", 184 - (n - 35) * 8, 203, 7, 4)
    elseif n == 58 then
        love.graphics.rectangle("fill", 2, 203, 5, 4)
        love.graphics.rectangle("fill", 2, 201, 4, 5)
    elseif n > 58 and n < 81 then
        love.graphics.rectangle("fill", 2, 201 - (n - 58) * 8, 4, 7)
    elseif n == 81 then
        love.graphics.rectangle("fill", 2, 19, 5, 4)
        love.graphics.rectangle("fill", 2, 19, 4, 5)
    elseif n > 81 and n < 94 then
        love.graphics.rectangle("fill", (n - 81) * 8, 19, 7, 4)
    end
end

function Clock.draw(ticks)
    local i = 0

    love.graphics.setColor(0, 1, 0, 1)

    while ticks > 0 and i < 93 do
        drawTick(i)
        i = i + 1
        ticks = ticks - 1
    end

    ticks = ticks % 93
    i = 0

    love.graphics.setColor(0.98, 0.93, 0.25, 1)

    while ticks > 0 and i < 93 do
        drawTick(i)
        i = i + 1
        ticks = ticks - 1
    end

    love.graphics.setColor(0.99, 0.99, 0.99, 1)

end


return Clock
