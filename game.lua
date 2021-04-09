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
    _game.speed = .05
    _game.tetrominos = count
    _game.current_tetromino = tetris.tetromino.new(
        _game.field.core,
        math.random(1, _game.tetrominos),
        _game.spawn,
        tetris.tetromino.rotation.right_side_up,
        _game.speed,
        _game.locks,
        _game.delay
    )

    return setmetatable(_game, game)
end
function game:on_keypressed(key)
    if self.current_tetromino.alive then
		if key == "left" then
			self.current_tetromino:move(tetris.tetromino.direction.left)
		elseif key == "right" then
			self.current_tetromino:move(tetris.tetromino.direction.right)
		elseif key == "a" then
			self.current_tetromino:rotate(tetris.tetromino.direction.left)
		elseif key == "s" then
			self.current_tetromino:rotate(tetris.tetromino.direction.right)
		end
	end
end
function game:update()
    if not self.current_tetromino.alive then
		self.current_tetromino = tetris.tetromino.new(
            self.field.core,
            math.random(1, self.tetrominos), -- tetris.tetromino.random(),
            self.spawn,
            tetris.tetromino.rotation.right_side_up,
            self.speed,
            self.locks,
            self.delay
        )
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
