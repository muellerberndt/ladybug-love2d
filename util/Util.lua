function getTileForPosition(x, y)
    local row = math.floor((y - 15) / 8) + 1
    local col = math.floor(x / 8) + 1

    -- local row = math.floor((y - 21) / 8) + 1
    -- local col = math.floor((x - 3) / 8) + 1

    return row, col
end

function getPositionForTile(row, col)
    local x = 5 + (col - 1) * 8
    local y = 21 + (row - 1) * 8

    return x, y
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
