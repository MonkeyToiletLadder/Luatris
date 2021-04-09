--[[
    tetromino.lua
    luatris version 0.1.0
    author: vaxeral
    april 8 2021
]]

local vector = require "vector"

local tetris = {
    field = require "field",
    tetromino = require "tetromino",
}

local function find(t, value)
    for i, v in ipairs(t) do
        if v == value then
            return i
        end
    end
    return -1
end

local game = {}
game.__index = game
function game.new()
    local _game = {}

    local blocksize = 32
    local hidden = 20
    local width = 10
    local height = 40

    local count = 0
    for _, _ in pairs(tetris.tetromino.shape) do
        count = count + 1
    end

    -- Could make seperate class for this
    _game.sz_streak = 0
    _game.i_absence = 0
    _game.bag = {}
    _game.bag_resets = 0

    _game.score = 0
    _game.field = {}
    _game.field.core = tetris.field.core.new(vector.new{0, 0}, blocksize, hidden, width, height)
    _game.field.background = tetris.field.background.new(_game.field.core)
    _game.field.border = tetris.field.border.new(_game.field.core)
    _game.field.grid = tetris.field.grid.new(_game.field.core)
    _game.spawn = vector.new{4, 17}
    _game.delay = .75
    _game.locks = 8
    _game.velocity = vector.new{.25, .05}
    _game.tetrominos = {} -- Next pieces
    _game.ntetrominos = count
    _game.store = nil
    _game.current_tetromino = false
    _game = setmetatable(_game, game)

    _game:fill_bag()

    for i = 1, 5, 1 do
        table.insert(_game.tetrominos, _game:from_bag())
    end

    _game.current_tetromino = _game:new_tetromino()

    return _game
end
function game:fill_bag()
    for i, v in pairs(tetris.tetromino.shape) do
        table.insert(self.bag, v)
    end
    self.bag_resets = self.bag_resets + 1
end
function game:from_bag()
    if self.i_absence > 12 then
        self.i_absence = 0
        return table.remove(self.bag, find(self.bag, tetris.tetromino.shape.i))
    end

    local candidate = math.random(1, #self.bag)
    if self.bag[candidate] == tetris.tetromino.shape.i then
        self.i_absence = 0
        return table.remove(self.bag, candidate)
    else
        self.i_absence = self.i_absence + 1
    end
    if self.bag_resets > 2 then
        self.sz_streak = 0
        self.bag_resets = 0
    end
    if self.bag[candidate] == tetris.tetromino.shape.s or self.bag[candidate] == tetris.tetromino.shape.z then
        self.sz_streak = self.sz_streak + 1
    end
    if self.sz_streak > 4 then
        self.sz_streak = self.sz_streak - 1
        for i, v in ipairs(self.bag) do
            if v ~= tetris.tetromino.shape.s and v ~= tetris.tetromino.shape.z then
                return table.remove(self.bag, i)
            end
        end
    end
    return table.remove(self.bag, candidate)
end
function game:new_tetromino()
    table.insert(self.tetrominos, self:from_bag())
    return tetris.tetromino.new(
                self.field.core,
                table.remove(self.tetrominos, 1), -- tetris.tetromino.random(),
                self.spawn,
                tetris.tetromino.rotation.right_side_up,
                self.velocity,
                self.locks,
                self.delay
            )
end
function game:update()
    if #self.bag == 0 then
        self:fill_bag()
    end
    if love.keyboard.isDown("x") then -- Swap if "onstack" requirement met
        if self.field.core.onstack then
            if not self.store then
                self.current_tetromino.position = {
                    self.spawn[1],
                    self.spawn[2],
                }
                self.store = self.current_tetromino
                self.current_tetromino = self:new_tetromino()
            else
                self.current_tetromino.position = {
                    self.spawn[1],
                    self.spawn[2],
                }
                local temp = self.store
                self.store = self.current_tetromino
                self.current_tetromino = temp
            end
            self.field.core.onstack = false
        end
    end
    if not self.current_tetromino.alive then
		self.current_tetromino = self:new_tetromino()
	end
	if self.current_tetromino.alive then
		self.current_tetromino:update()
	end
    if self.field.core.cleared ~= 0 then
        self.score = self.score + math.pow(2, self.field.core.cleared)
        self.field.core.cleared = 0
    end
end
function game:draw()
	love.graphics.clear(0,0,0)
    self.field.background:draw()
	self.field.core:draw()
	if self.current_tetromino.alive then
		self.current_tetromino:draw()
	end
	self.field.grid:draw()
	self.field.border:draw()
	love.graphics.setColor(1,1,1)
	love.graphics.print("score: " .. self.score, 0, self.field.core.blocksize * 20)
end

return game
