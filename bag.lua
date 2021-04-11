--[[
    bag.lua
    luatris version 0.1.0
    author: vaxeral
    april 9 2021
    Description: Random Generator for tetromino pieces
]]

local tetris = {
    tetromino = require "tetromino"
}

local function find(t, value)
    for i, v in ipairs(t) do
        if v == value then
            return i
        end
    end
    return -1
end

local bag = {}
bag.__index = bag

function bag.new()
    local _bag = {}

    _bag.i_absence = 0
    _bag.pieces = {}

    return setmetatable(_bag, bag)
end
function bag:fill()
    for i, v in pairs(tetris.tetromino.shape) do
        table.insert(self.pieces, v)
    end
    print("fill bag")
end
function bag:draw()
    print("draw" .. love.timer.getTime())
    if #self.pieces == 0 then
        return nil
    end
    if self.i_absence > 12 then
        self.i_absence = 0
        print(self.pieces[candidate])
        return table.remove(self.pieces, find(self.pieces, tetris.tetromino.shape.i))
    end

    local candidate = math.random(1, #self.pieces)
    if self.pieces[candidate] == tetris.tetromino.shape.i then
        self.i_absence = 0
        print(self.pieces[candidate])
        return table.remove(self.pieces, candidate)
    else
        self.i_absence = self.i_absence + 1
    end
    print(self.pieces[candidate])
    return table.remove(self.pieces, candidate)
end

return bag
