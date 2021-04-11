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
    bag = require "bag",
    preview = require "preview",
}

local game = {}
game.__index = game
function game.new()
    local _game = {}

    local blocksize = 16
    local hidden = 20
    local width = 10
    local height = 40
    local scale = 1

    local count = 0
    for _, _ in pairs(tetris.tetromino.shape) do
        count = count + 1
    end

    local array = tetris.tetromino.array.new()

    _game.bag = tetris.bag.new()
    _game.score = 0

    _game.field = {}
    _game.field.core = tetris.field.core.new(vector.new{0, 0}, blocksize, hidden, width, height, scale)
    _game.field.background = tetris.field.background.new(_game.field.core)
    _game.field.border = tetris.field.border.new(_game.field.core, love.graphics.newImage("border.png"), 16, 16)
    _game.field.grid = tetris.field.grid.new(_game.field.core)

    _game.preview = {}
    _game.preview.core = tetris.preview.core.new(array, vector.new{_game.field.core.border.width, 0}, blocksize, 4, 4*5, scale)
    _game.preview.background = tetris.preview.background.new(_game.preview.core)
    _game.preview.border = tetris.preview.border.new(_game.preview.core, love.graphics.newImage("border.png"), 16, 16)

    _game.spawn = vector.new{4, 18}
    _game.delay = .75
    _game.locks = 8
    _game.velocity = vector.new{.175, .05}

    _game.ntetrominos = count
    _game.store = nil
    _game.current_tetromino = false
    _game = setmetatable(_game, game)

    _game.bag:fill()

    for i = 1, 5, 1 do
        _game.preview.core:push(_game.bag:draw())
    end

    _game.current_tetromino = _game:new_tetromino()

    return _game
end
function game:new_tetromino()
    self.preview.core:push(self.bag:draw())
    return tetris.tetromino.piece.new(
                self.field.core,
                self.preview.core:pop_front(),
                self.spawn,
                tetris.tetromino.rotation.right_side_up,
                self.velocity,
                self.locks,
                self.delay
            )
end
function game:update()
    if not self.current_tetromino then
        -- For now just return
        return
    end
    if #self.bag.pieces == 0 then
        self.bag:fill()
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
                self.store.touching = false
                self.store.timer = 0
            else
                self.current_tetromino.position = {
                    self.spawn[1],
                    self.spawn[2],
                }
                self.store, self.current_tetromino = self.current_tetromino, self.store
                self.store.touching = false
                self.store.timer = 0
            end
            self.field.core.onstack = false
        end
    end
	if self.current_tetromino.alive then
		self.current_tetromino:update()
	end
    if self.field.core.cleared ~= 0 then
        self.score = self.score + math.pow(2, self.field.core.cleared)
        self.field.core.cleared = 0
    end
    if not self.current_tetromino.alive then
		self.current_tetromino = self:new_tetromino()
	end
end
function game:draw()
	love.graphics.clear(0,0,0)
    self.field.border:draw()
    self.field.background:draw()
    self.field.grid:draw()
	self.field.core:draw()
	if self.current_tetromino and self.current_tetromino.alive then
		self.current_tetromino:draw()
	end
    -- self.preview.border:draw()
    self.preview.background:draw()
    self.preview.core:draw()
	love.graphics.setColor(1,1,1)
	love.graphics.print("score: " .. self.score, 0, self.field.core.blocksize * 20)
end

return game
