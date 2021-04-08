--[[
    field.lua
    luatris version 0.1.0
    author: vaxeral
    april 1 2021

    Only update field when piece is set
]]

tetromino = require "tetromino"
vector = require "vector"

local field = {}

local function booltoint(value)
    return value and 1 or 0
end

local function setbit(num, n, val)
    if val then
        return bit.bor(num, bit.lshift(1, n))
    else
        return bit.band(num, bit.bnot(bit.lshift(1, n)))
    end
end

local function top_occupied(occupied)
    return bit.band(occupied, 1) ~= 0
end
local function bottom_occupied(occupied)
    return bit.band(occupied, 2) ~= 0
end
local function left_occupied(occupied)
    return bit.band(occupied, 4) ~= 0
end
local function right_occupied(occupied)
    return bit.band(occupied, 8) ~= 0
end

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
    _core.onstack = false
    _core.atlas = love.graphics.newImage("blocks.png")
    _core.imagedata = {}
    _core.mappings = {
        left_end = {1, 0},
        right_end = {3, 0},
        top_end = {0, 1},
        bottom_end = {0, 3},
        left_wall = {1, 2},
        right_wall = {3, 2},
        top_wall = {2, 1},
        bottom_wall = {2, 3},
        top_bottom = {0, 2},
        left_right = {2, 0},
        bottom_left_corner = {1, 3},
        bottom_right_corner = {3, 3},
        top_left_corner = {1, 1},
        top_right_corner = {3, 1},
        middle = {2, 2},
        island = {0, 0},
    }
    _core.quad = love.graphics.newQuad(0, 0, _core.blocksize, _core.blocksize, _core.atlas:getWidth(), _core.atlas:getHeight())
    for j=1,_core.height,1 do
    	_core[j] = {}
        _core.imagedata[j] = {}
    	for i=1,_core.width,1 do
    		_core[j][i] = 0
            _core.imagedata[j][i] = 0
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
function field.core:get_block(tuple)
    return self[tuple[2]][tuple[1]]
end
function field.core:update()
    if self.onstack then
        --Recalculate the entire tetris fields images
        for j in ipairs(self) do
            for i in ipairs(self[j]) do
                -- test all four sides of the block
                local top = {i,j-1}
                local bottom = {i,j+1}
                local left = {i-1,j}
                local right = {i+1,j}
                -- If the test cell is out of bounds consider it unoccupied
                local occupied = 0
                occupied = bit.bor(occupied, bit.lshift(booltoint(top[2] >= self.hidden), 0))
                occupied = bit.bor(occupied, bit.lshift(booltoint(bottom[2] <= self.height), 1))
                occupied = bit.bor(occupied, bit.lshift(booltoint(left[1] >= 1), 2))
                occupied = bit.bor(occupied, bit.lshift(booltoint(right[1] <= self.width), 3))

                -- Test if the cell is occupied
                if top_occupied(occupied) then
                    occupied = setbit(occupied, 0, self:get_block(top) == self:get_block({i, j}))
                end
                if bottom_occupied(occupied) then
                    occupied = setbit(occupied, 1, self:get_block(bottom) == self:get_block({i, j}))
                end
                if left_occupied(occupied) then
                    occupied = setbit(occupied, 2, self:get_block(left) == self:get_block({i, j}))
                end
                if right_occupied(occupied) then
                    occupied = setbit(occupied, 3, self:get_block(right) == self:get_block({i, j}))
                end
                -- Set the imagedata for the cell
                if occupied == 0 then -- 0000
                    self.imagedata[j][i] = "island"
                elseif occupied == 1 then -- 0001
                    self.imagedata[j][i] = "bottom_end"
                elseif occupied == 2 then -- 0010
                    self.imagedata[j][i] = "top_end"
                elseif occupied == 3 then -- 0011
                    self.imagedata[j][i] = "top_bottom"
                elseif occupied == 4 then -- 0100
                    self.imagedata[j][i] = "right_end"
                elseif occupied == 5 then -- 0101
                    self.imagedata[j][i] = "bottom_right_corner"
                elseif occupied == 6 then -- 0110
                    self.imagedata[j][i] = "top_right_corner"
                elseif occupied == 7 then -- 0111
                    self.imagedata[j][i] = "right_wall"
                elseif occupied == 8 then -- 1000
                    self.imagedata[j][i] = "left_end"
                elseif occupied == 9 then -- 1001
                    self.imagedata[j][i] = "bottom_left_corner"
                elseif occupied == 10 then -- 1010
                    self.imagedata[j][i] = "top_left_corner"
                elseif occupied == 11 then -- 1011
                    self.imagedata[j][i] = "left_wall"
                elseif occupied == 12 then -- 1100
                    self.imagedata[j][i] = "left_right"
                elseif occupied == 13 then -- 1101
                    self.imagedata[j][i] = "bottom_wall"
                elseif occupied == 14 then -- 1110
                    self.imagedata[j][i] = "top_wall"
                elseif occupied == 15 then -- 1111
                    self.imagedata[j][i] = "middle"
                end
            end
        end
        self.onstack = false
    end
end
function field.core:draw()
    local offset = self.position
	for j=self.hidden+1,self.height,1 do
		for i=1,self.width,1 do
            local shape = self[j][i]
            local color = tetromino.colors[shape]
            if color then
                local mapping = self.mappings[self.imagedata[j][i]]
                self.quad:setViewport(
                    mapping[1] * self.blocksize,
                    mapping[2] * self.blocksize,
                    self.blocksize,
                    self.blocksize
                )
                love.graphics.setColor(unpack(color))
			    love.graphics.draw(self.atlas, self.quad, offset[1] + (i - 1) * self.blocksize, offset[2] + (j - 1) * self.blocksize)
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
    love.graphics.setColor(.9, .9, .9)
    for j=1,self.core.height - self.core.hidden,1 do
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
    love.graphics.setColor(220/255, 205/255, 220/255)
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
