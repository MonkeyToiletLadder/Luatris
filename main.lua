--[[
    tetromino.lua
    luatris version 0.1.0
    author: vaxeral
    april 2 2021

	highscores
	mason 324
	flynn 22
	dylan 502
]]

require "tetromino"
require "vector"
require "field"

field = field.new(10, 40)

new_tetromino = true
current_tetromino = nil
held = nil
math.randomseed(love.timer.getTime())
score = 0
function love.draw()
	love.graphics.clear(0,0,0)
	for j=1,field.height,1 do
		for i=1,field.width,1 do
			local color = {0,0,0}
			if field[j][i] == tetromino.shape.i then
				color = {0,1,1}
			elseif field[j][i] == tetromino.shape.j then
				color = {1,165.0/255,0}
			elseif field[j][i] == tetromino.shape.l then
				color = {0,0,1}
			elseif field[j][i] == tetromino.shape.o then
				color = {1,1,0}
			elseif field[j][i] == tetromino.shape.s then
				color = {1,0,0}
			elseif field[j][i] == tetromino.shape.t then
				color = {128.0/255,0,128.0/255}
			elseif field[j][i] == tetromino.shape.z then
				color = {0,1,0}
			else
				color = {1,1,1}
			end
			love.graphics.setColor(unpack(color))
			love.graphics.rectangle("fill", (i - 1) * 25, j * 25 - 25 * 20, 25, 25)
			love.graphics.setColor(0,0,0)
			love.graphics.rectangle("line", (i - 1) * 25, j * 25 - 25 * 20, 25, 25)
		end
	end
	if current_tetromino then
		local position = current_tetromino.position
		local state = current_tetromino:get_state()
		local color = {0,0,0}
		if current_tetromino.shape == tetromino.shape.i then
			color = {0,1,1}
		elseif current_tetromino.shape == tetromino.shape.j then
			color = {1,165.0/255,0}
		elseif current_tetromino.shape == tetromino.shape.l then
			color = {0,0,1}
		elseif current_tetromino.shape == tetromino.shape.o then
			color = {1,1,0}
		elseif current_tetromino.shape == tetromino.shape.s then
			color = {1,0,0}
		elseif current_tetromino.shape == tetromino.shape.t then
			color = {128.0/255,0,128.0/255}
		elseif current_tetromino.shape == tetromino.shape.z then
			color = {0,1,0}
		else
			color = {1,1,1}
		end
		love.graphics.setColor(unpack(color))
		for j=1,#state,1 do
			for i=1,#state[j],1 do
				if state[j][i] ~= 0 then
					love.graphics.rectangle("fill", position[1] * 25 + (i - 2)*25, math.floor(position[2]) * 25 + (j - 1)*25 - 25 * 20,25,25)
				end
			end
		end
	end
	for j=1,field.height,1 do
		for i=1,field.width,1 do
			love.graphics.setColor(0,0,0)
			love.graphics.rectangle("line", (i - 1) * 25, j * 25 - 25 * 20, 25, 25)
		end
	end
	love.graphics.setColor(1,1,1)
	love.graphics.print("score: " .. score, 0, 25 * 21)
end
love.keyboard.setKeyRepeat(true)
function love.update()
	if new_tetromino then
		current_tetromino = tetromino.new(field, math.random(1,7), vector.new{4, 17}, 1, .05, 8, .75)
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
			current_tetromino:move(tetromino.direction.left)
		elseif key == "right" then
			current_tetromino:move(tetromino.direction.right)
		elseif key == "a" then
			current_tetromino:rotate(tetromino.direction.left)
		elseif key == "s" then
			current_tetromino:rotate(tetromino.direction.right)
		end
	end
end
