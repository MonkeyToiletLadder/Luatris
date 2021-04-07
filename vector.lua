--[[
    vector.lua
    luatris version 0.1.0
    author: vaxeral
    april 1 2021
]]

local vector = {}
vector.__index = vector
function vector.new(values)
    return setmetatable(values, vector)
end
function vector:__add(other)
    if #self ~= #other then
        error("adding vectors of unequal length")
    end
    local output = vector.new{unpack(self)}
    for i, v in ipairs(self) do
        output[i] = v + other[i]
    end
    return output
end
function vector:__sub(other)
    if #self ~= #other then
        error("subtracting vectors of unequal length")
    end
    local output = vector.new{unpack(self)}
    for i, v in ipairs(self) do
        output[i] = v - other[i]
    end
    return output
end
function vector:__mul(scalar)
    if type(scalar) ~= "number" then
        error("scaling vector with non numeric value")
    end
    local elements = {}
    for i,v in ipairs(self) do
        elements[i] = v * scalar
    end
    return vector.new(table.unpack(elements))
end
function vector:to_veci()
    return vector.new{
        math.floor(self[1]),
        math.floor(self[2])
    }
end

return vector
