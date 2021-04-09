--[[
    tetris.tetromino.lua
    luatris version 0.1.0
    author: vaxeral
    april 2 2021

	TODO: Generate pieces methodicaly to let the player win
	TODO: Show held piece and next pieceses
]]

tetris = {
	game = require "game",
}

math.randomseed(love.timer.getTime())
love.keyboard.setKeyRepeat(true)

game = tetris.game.new()

function love.draw()
	game:draw()
end
function love.update()
	game:update()
end
