function getTileForPosition(x, y)
    -- local row = math.floor((y - 15) / 8) + 1
    -- local col = math.floor(x / 8) + 1

    local row = math.floor((y - 14) / 8) + 1
    local col = math.floor((x + 3) / 8) + 1

    return row, col
end

function getPositionForTile(row, col)
    local x = 5 + (col - 1) * 8
    local y = 21 + (row - 1) * 8

    return x, y
end

function table.contains(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function table.shallow_copy(t)
    local t2 = {}
    for k,v in pairs(t) do
      t2[k] = v
    end
    return t2
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function file_exists(name)
    local f = io.open(name, "r")
    return f ~= nil and io.close(f)
 end

function split(inputstr, sep)  -- Splits a string
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

function serialize(o, file)  -- Writes highscores to a file
    file = io.open(file, 'w')
    if type(o) == "number" then
        file:write(o)
        file:close()
    elseif type(o) == "string" then
        file:write(string.format("%q", o))
        file:close()
    elseif type(o) == "table" then
        -- io.write("{\n")
        for _,v in pairs(o) do
            file:write(v[1] .. ',' .. v[2] .. '\n')
        end
        file:close()
    else
        file:close()
        error("cannot serialize a " .. type(o))
    end
end

function getHighScores(highscoresFile)
    highscores = {}
    i = 1
    for line in io.lines(highscoresFile) do
        score, name = unpack(split(line, ','))
        highscores[i] = {[1] = tonumber(score), [2] = name}
        i = i + 1
    end
    return highscores
end