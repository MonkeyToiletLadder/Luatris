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

    -- _bag.bag_resets = 0
    -- _bag.sz_streak = 0
    _bag.i_absence = 0
    _bag.pieces = {}

    return setmetatable(_bag, bag)
end
function bag:fill()
    for i, v in pairs(tetris.tetromino.shape) do
        table.insert(self.pieces, v)
    end
    -- self.bag_resets = self.bag_resets + 1
    print("Bag reset")
end
function bag:draw()
    if self.i_absence > 12 then
        self.i_absence = 0
        print("i piece 12 streak")
        return table.remove(self.pieces, find(self.pieces, tetris.tetromino.shape.i))
    end

    local candidate = math.random(1, #self.pieces)
    if self.pieces[candidate] == tetris.tetromino.shape.i then
        self.i_absence = 0
        print("i piece")
        return table.remove(self.pieces, candidate)
    else
        self.i_absence = self.i_absence + 1
    end
    -- if self.bag_resets > 2 then
    --     self.sz_streak = 0
    --     self.bag_resets = 0
    -- end
    -- if self.pieces[candidate] == tetris.tetromino.shape.s or self.pieces[candidate] == tetris.tetromino.shape.z then
    --     self.sz_streak = self.sz_streak + 1
    -- end
    -- NOTE: this is an intrisic property of the bag this is not needed :D Yay
    -- if self.sz_streak > 4 then
    --     print("after sz streak")
    --     self.sz_streak = 0 -- sz_streak - 1
    --     for i, v in ipairs(self.pieces) do
    --         if v ~= tetris.tetromino.shape.s and v ~= tetris.tetromino.shape.z then
    --             return table.remove(self.pieces, i)
    --         end
    --     end
    -- end
    print("normal peice " .. self.pieces[candidate])
    return table.remove(self.pieces, candidate)
end

return bag
