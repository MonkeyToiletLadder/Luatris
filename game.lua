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
    _game.current_tetromino = tetris.tetromino.new(
        _game.field.core,
        math.random(1, _game.ntetrominos),
        _game.spawn,
        tetris.tetromino.rotation.right_side_up,
        _game.velocity,
        _game.locks,
        _game.delay
    )

    for i = 1, 5, 1 do
        table.insert(_game.tetrominos, math.random(1, _game.ntetrominos))
    end

    return setmetatable(_game, game)
end
function game:new_tetromino()
    table.insert(self.tetrominos, math.random(1, self.ntetrominos))
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
