--[[
    tetris.tetromino.lua
    luatris version 0.1.0
    author: vaxeral
    april 2 2021

	highscores
	mason 324
	flynn 22
	dylan 502
]]

vector = require "vector"
tetris = {
	tetromino = require "tetromino",
	field = require "field",
}

field = tetris.field.new(vector.new{0, 0}, 25, 19, 10, 40)

new_tetromino = true
current_tetromino = nil
held = nil
math.randomseed(love.timer.getTime())
score = 0
function love.draw()
	love.graphics.clear(0,0,0)
	field:draw()
	if current_tetromino then
		current_tetromino:draw()
	end
	love.graphics.setColor(1,1,1)
	love.graphics.print("score: " .. score, 0, 25 * 21)
end
love.keyboard.setKeyRepeat(true)
function love.update()
	if new_tetromino then
		current_tetromino = tetris.tetromino.new(field, math.random(1,7), vector.new{4, 17}, 1, .05, 8, .75)
		new_tetromino = false
	end
	if current_tetromino then
		if love.keyboard.isDown("down") then
			current_tetromino.modifier = 10
		else
			current_tetromino.modifier = 1
		end
		current_tetromino:drop()
		if current_tetromino.touching and love.timer.getTime() - current_tetromino.timer > current_tetromino.delay then
			current_tetromino:insert()
			new_tetromino = true
			local rows = 0
			local lowest = 0
			for j = 1, field.height, 1 do
				if field:is_row_full(j) then
					field:clear_row(j)
					field:drop(j, 1)
					rows = rows + 1
				end
			end
			score = score + math.pow(2, rows)
		end
	end
end

function love.keypressed(key, scancode, isrepeat)
	if current_tetromino then
		if key == "left" then
			current_tetromino:move(tetris.tetromino.direction.left)
		elseif key == "right" then
			current_tetromino:move(tetris.tetromino.direction.right)
		elseif key == "a" then
			current_tetromino:rotate(tetris.tetromino.direction.left)
		elseif key == "s" then
			current_tetromino:rotate(tetris.tetromino.direction.right)
		end
	end
end
