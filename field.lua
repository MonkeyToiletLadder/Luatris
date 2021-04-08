--[[
    field.lua
    luatris version 0.1.0
    author: vaxeral
    april 1 2021
]]

tetromino = require "tetromino"
vector = require "vector"

local field = {}

field.core = {}
field.core.__index = field.core
function field.core.new(position, blocksize, hidden, width, height)
    local _core = {}
    _core.position = position - vector.new{0, hidden * blocksize}
    _core.blocksize = blocksize
    _core.hidden = hidden or 20
    _core.width = width or 10
    _core.height = height or 40
    _core.cleared = 0
    for j=1,_core.height,1 do
    	_core[j] = {}
    	for i=1,_core.width,1 do
    		_core[j][i] = 0
    	end
    end
    return setmetatable(_core, field.core)
end
function field.core:is_row_full(row)
    for i, v in ipairs(self[row]) do
        if v <= 0 then
            return false
        end
    end
    return true
end
function field.core:clear_row(row)
    for i in ipairs(self[row]) do
        self[row][i] = 0
    end
end
function field.core:drop(row)
    for j = row, 1, -1 do
        for i in ipairs(self[j]) do
            if self[j][i] ~= 0 then
                local temp = self[j][i]
                self[math.min(j + 1, self.height)][i] = temp
                self[j][i] = 0
            end
        end
    end
end
function field.core:get_position()
    return self.position + vector.new{0, self.hidden * self.blocksize}
end
function field.core:set_position(position)
    self.position = position - vector.new{0, self.hidden * self.blocksize}
end
function field.core:draw()
    local offset = self.position
	for j=self.hidden+1,self.height,1 do
		for i=1,self.width,1 do
            local shape = self[j][i]
            local color = tetromino.colors[shape]
            if color then
                love.graphics.setColor(unpack(color))
			    love.graphics.rectangle("fill", offset[1] + (i - 1) * self.blocksize, offset[2] + (j - 1) * self.blocksize, self.blocksize, self.blocksize)
            end
		end
	end
end

field.grid = {}
field.grid.__index = field.grid
function field.grid.new(core)
    local _grid = {}
    _grid.core = core
    return setmetatable(_grid, field.grid)
end
function field.grid:draw()
    local offset = self.core:get_position()
    local blocksize = self.core.blocksize
    love.graphics.setColor(0, 0, 0)
    for j=1,self.core.height,1 do
		for i=1,self.core.width,1 do
            local shape = self.core[j][i]
			love.graphics.rectangle("line", offset[1] + (i - 1) * blocksize, offset[2] + (j - 1) * blocksize, blocksize, blocksize)
        end
    end
end

field.background = {}
field.background.__index = field.background
function field.background.new(core)
    local _background = {}
    _background.core = core
    return setmetatable(_background, field.background)
end
function field.background:draw()
    local position = self.core:get_position()
    local blocksize = self.core.blocksize
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", position[1], position[2], blocksize * self.core.width, blocksize * (self.core.height - self.core.hidden))
end

field.border = {}
field.border.__index = field.border
function field.border.new(core)
    local _border = {}
    _border.core = core
    return setmetatable(_border, field.border)
end
function field.border:draw()
    local position = self.core:get_position()
    local blocksize = self.core.blocksize
    love.graphics.setColor(1,0,0)
    love.graphics.rectangle("line", position[1], position[2], blocksize * self.core.width, blocksize * (self.core.height - self.core.hidden))
end

return field
