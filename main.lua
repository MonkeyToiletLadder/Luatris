local tetris = require "tetromino"
require "vector"
require "field"


field = field.new(10, 40)

new_tetromino = true
tetromino = nil
math.randomseed(love.timer.getTime())

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
			love.graphics.rectangle("fill", (i - 1) * 25, j * 25 - 25 * 20, 25, 25)
			love.graphics.setColor(0,0,0)
			love.graphics.rectangle("line", (i - 1) * 25, j * 25 - 25 * 20, 25, 25)
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
				love.graphics.rectangle("fill", position[1] * 25 + (i - 2)*25, math.floor(position[2]) * 25 + (j - 1)*25 - 25 * 20,25,25)
			end
		end
	end
	for j=1,field.height,1 do
		for i=1,field.width,1 do
			love.graphics.setColor(0,0,0)
			love.graphics.rectangle("line", (i - 1) * 25, j * 25 - 25 * 20, 25, 25)
		end
	end
end
love.keyboard.setKeyRepeat(true)
function love.update()
	if new_tetromino then
		tetromino = tetris.tetromino.new(field, math.random(1,7), vector.new{4, 17}, 1, .05, 8, .75)
		new_tetromino = false
	end
	if tetromino then
		if love.keyboard.isDown("down") then
			tetromino.modifier = 4
		else
			tetromino.modifier = 1
		end
		tetromino:drop()
	end
	if tetromino.touching and love.timer.getTime() - tetromino.timer > tetromino.delay then
		tetromino:insert()
		new_tetromino = true
		local rows = 0
		local lowest = 0
		for j = 1, field.height, 1 do
			if field:is_row_full(j) then
				field:clear_row(j)
				field:drop(j, 1)
			end
		end
	end
end

function love.keypressed(key, scancode, isrepeat)
	if key == "left" then
		tetromino:move(tetris.directions.left)
	elseif key == "right" then
		tetromino:move(tetris.directions.right)
	elseif key == "a" then
		tetromino:rotate(tetris.directions.left)
	elseif key == "s" then
		tetromino:rotate(tetris.directions.right)
	end
end
