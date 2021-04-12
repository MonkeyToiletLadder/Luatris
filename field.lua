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
function field.core.new(position, blocksize, hidden, width, height, scale)
    local _core = {}
    _core.position = position - vector.new{0, hidden * blocksize * scale}
    _core.blocksize = blocksize
    _core.hidden = hidden or 20
    _core.width = width or 10
    _core.height = height or 40
    _core.scale = scale or 1
    _core.cleared = 0
    _core.onstack = true -- Use for detecting when a piece can be swapped
    _core.block = love.graphics.newImage("blocks.png")
    _core.quad = love.graphics.newQuad(0, 0, _core.blocksize, _core.blocksize, _core.block:getWidth(), _core.block:getHeight())
    _core.background = {}
    _core.border = {}
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
function field.core:get_outer_position()
    return self.position + vector.new{0, self.hidden * self:get_block_size()}
end
function field.core:get_inner_position()
    return self:get_outer_position() + vector.new{self.border:get_left_margin(), self.border:get_top_margin()}
end
function field.core:set_position(position)
    self.position = position - vector.new{0, self.hidden * self.blocksize * self.scale}
end
function field.core:get_block_size()
    return self.blocksize * self.scale
end
function field.core:draw()
    local offset = self:get_inner_position()
    local blocksize = self:get_block_size()
	for j=1,self.height,1 do
		for i=1,self.width,1 do
            local shape = self[j][i]
            local color = tetromino.colors[shape]
            if color and j > self.hidden then
                k = j - self.hidden
                love.graphics.setColor(unpack(color))
			    love.graphics.draw(
                    self.block,
                    self.quad,
                    (i - 1) * blocksize + offset[1],
                    (k - 1) * blocksize + offset[2],
                    0,
                    self.scale,
                    self.scale
                )
            end
		end
	end
end

field.grid = {}
field.grid.__index = field.grid
function field.grid.new(core)
    local _grid = {}
    _grid.core = core
    _grid.core.grid = _grid
    return setmetatable(_grid, field.grid)
end
function field.grid:draw()
    local offset = self.core:get_inner_position()
    local blocksize = self.core:get_block_size()
    love.graphics.setColor(.9, .9, .9, .2)
    for j=1,self.core.height - self.core.hidden,1 do
		for i=1,self.core.width,1 do
            local shape = self.core[j][i]
			love.graphics.rectangle(
                "line",
                offset[1] + (i - 1) * blocksize,
                offset[2] + (j - 1) * blocksize,
                blocksize,
                blocksize)
        end
    end
end

field.background = {}
field.background.__index = field.background
function field.background.new(core)
    local _background = {}
    _background.core = core
    _background.core.background = _background
    return setmetatable(_background, field.background)
end
function field.background:draw()
    local offset = self.core:get_inner_position()
    local blocksize = self.core:get_block_size()
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle(
        "fill",
        offset[1],
        offset[2],
        blocksize * self.core.width,
        blocksize * (self.core.height - self.core.hidden)
    )
end

-- left_margin and top_margin are the border width of the original scaled image
field.border = {}
field.border.__index = field.border
function field.border.new(core, image, left_margin, top_margin)
    local _border = {}
    _border.core = core
    _border.core.border = _border
    _border.width = image:getWidth()
    _border.height = image:getHeight()
    _border.image = image
    _border.left_margin = left_margin
    _border.top_margin = top_margin
    _border.quad = love.graphics.newQuad(0, 0, image:getWidth(), image:getHeight(), image:getWidth(), image:getHeight())

    return setmetatable(_border, field.border)
end
function field.border:get_width()
    return self.width * self.core.scale
end
function field.border:get_height()
    return self.height * self.core.scale
end
function field.border:get_left_margin()
    return self.left_margin * self.core.scale
end
function field.border:get_top_margin()
    return self.top_margin * self.core.scale
end
function field.border:draw()
    local position = self.core:get_outer_position()
    local blocksize = self.core:get_block_size()
    love.graphics.setColor(1,1,1)
    -- love.graphics.rectangle("line", position[1], position[2], blocksize * self.core.width, blocksize * (self.core.height - self.core.hidden))
    love.graphics.draw(
        self.image,
        self.quad,
        position[1],
        position[2],
        0,
        self.core.scale,
        self.core.scale
    )
end

return field
