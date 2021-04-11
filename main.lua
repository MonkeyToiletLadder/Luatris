--[[
    main.lua
    luatris version 0.1.0
    author: vaxeral
    april 2 2021

	Highscores
	vaxeral: 164
    spacebar64:

	TODO: Random Generator Beta
		No streaks of s or z greater than four
		I appears at least every 12 pieces
		Randomly selects from bag of 7
	TODO: Show held piece and next pieces
	TODO: quick drop and highlight contact area (need lowest points structure)
	TODO: add controller support.
	TODO: Add settings and sensitivities
	TODO: Get beta testers
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
