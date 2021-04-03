#!/usr/local/bin/lua

local tetris = require "tetromino"
require "vector"

field = {
	width = 10,
	height = 40
}

new_tetromino = true
tetromino = nil

for j=1,field.height,1 do
	field[j] = {}
	for i=1,field.width,1 do
		field[j][i] = 0
	end
end

function love.draw()
	love.graphics.clear(0,0,0)
	for j=1,field.height,1 do
		for i=1,field.width,1 do
			local color = {0,0,0}
			if field[j][i] == tetris.shapes.i then
				color = {0,1,1}
			elseif field[j][i] == tetris.shapes.j then
				color = {1,165.0/255,0}
			elseif field[j][i] == tetris.shapes.l then
				color = {0,0,1}
			elseif field[j][i] == tetris.shapes.o then
				color = {1,1,0}
			elseif field[j][i] == tetris.shapes.s then
				color = {1,0,0}
			elseif field[j][i] == tetris.shapes.t then
				color = {128.0/255,0,128.0/255}
			elseif field[j][i] == tetris.shapes.z then
				color = {0,1,0}
			else
				color = {1,1,1}
			end
			love.graphics.setColor(unpack(color))
			love.graphics.rectangle("fill", i * 25, j * 25 - 25 * 20, 25, 25)
			love.graphics.setColor(0,0,0)
			love.graphics.rectangle("line", i * 25, j * 25 - 25 * 20, 25, 25)
		end
	end
	local position = tetromino.position
	local state = tetromino:get_state()
	local color = {0,0,0}
	if tetromino.shape == tetris.shapes.i then
		color = {0,1,1}
	elseif tetromino.shape == tetris.shapes.j then
		color = {1,165.0/255,0}
	elseif tetromino.shape == tetris.shapes.l then
		color = {0,0,1}
	elseif tetromino.shape == tetris.shapes.o then
		color = {1,1,0}
	elseif tetromino.shape == tetris.shapes.s then
		color = {1,0,0}
	elseif tetromino.shape == tetris.shapes.t then
		color = {128.0/255,0,128.0/255}
	elseif tetromino.shape == tetris.shapes.z then
		color = {0,1,0}
	else
		color = {1,1,1}
	end
	love.graphics.setColor(unpack(color))
	for j=1,#state,1 do
		for i=1,#state[j],1 do
			if state[j][i] ~= 0 then
				love.graphics.rectangle("fill", position[1] * 25 + (i - 1)*25, math.floor(position[2]) * 25 + (j - 1)*25 - 25 * 20,25,25)
			end
		end
	end
end
love.keyboard.setKeyRepeat(false)
function love.update()
	if new_tetromino then
		tetromino = tetris.tetromino.new(field, 1, vector.new{1, 21}, 4, .1, 4, .01)
		new_tetromino = false
	end
	if tetromino then
		if love.keyboard.isDown("left") then
			tetromino:move(tetris.direction.left)
		elseif love.keyboard.isDown("right") then
			tetromino:move(tetris.direction.right)
		elseif love.keyboard.isDown("a") then
			tetromino:rotate(tetris.direction.left)
		elseif love.keyboard.isDown("s") then
			tetromino:rotate(tetris.direction.right)
		end
		tetromino:drop()
	end
	if tetromino.touching then
		tetromino:insert()
		new_tetromino = true
	end
end
