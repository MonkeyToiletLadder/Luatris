--[[
    tetromino.lua
    luatris version 0.1.0
    author: vaxeral
    april 6 2021
]]

local matrix = require "matrix"
local vector = require "vector"

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

local function get_rotations(bitarray)
	bitarray = matrix.new(bitarray)
	local rotations = {
		bitarray:rot90(0),
		bitarray:rot90(1),
		bitarray:rot90(2),
		bitarray:rot90(3)
	}
	return rotations
end
local function get_lowest(bitarray)
    lowest = nil
    for j in ipairs(bitarray) do
        for i in ipairs(bitarray[j]) do
            if bitarray[j][i] ~= 0 and j - 1 > (lowest or 0) then
                lowest = j - 1
            end
        end
    end
    return lowest
end
local function get_highest(bitarray)
    highest = nil
    for j in ipairs(bitarray) do
        for i in ipairs(bitarray[j]) do
            if bitarray[j][i] ~= 0 and j - 1 < (highest or #bitarray) then
                highest = j - 1
            end
        end
    end
    return highest
end
local function get_leftmost(bitarray)
    leftmost = nil
    for j in ipairs(bitarray) do
        for i in ipairs(bitarray[j]) do
            if bitarray[j][i] ~= 0 and i - 1 < (leftmost or #bitarray[j]) then
                leftmost = i - 1
            end
        end
    end
    return leftmost
end
local function get_rightmost(bitarray)
    rightmost = nil
    for j in ipairs(bitarray) do
        for i in ipairs(bitarray[j]) do
            if bitarray[j][i] ~= 0 and i - 1 > (rightmost or 0) then
                rightmost = i - 1
            end
        end
    end
    return rightmost
end
local function get_boundaries(bitarrays)
    local boundaries = {}
    for i in ipairs(bitarrays) do
        boundaries[i] = {
            get_lowest(bitarrays[i]),
            get_highest(bitarrays[i]),
            get_leftmost(bitarrays[i]),
            get_rightmost(bitarrays[i])
        }
    end
    return boundaries
end

local tetromino = {}
tetromino.__index = tetromino
tetromino.shape = {
    i = 1,
    j = 2,
    l = 3,
    o = 4,
    s = 5,
    t = 6,
    z = 7,
}
tetromino.bound = {
    bottom = 1,
    top = 2,
    left = 3,
    right = 4,
}
tetromino.rotation = {
	right_side_up = 1,
	right_side = 2,
	upside_down = 3,
	left_side = 4,
}
tetromino.direction = {
    left = 1,
    right = 2,
}
tetromino.colors = {
    {0/255,255/255,255/255},
    {0/255,0/255,255/255},
    {255/255,128/255,0/255},
    {255/255,255/255,0/255},
    {0/255,255/255,0/255},
    {255/255,0/255,255/255},
    {255/255,0/255,0/255},
}
tetromino.bitarrays = {
    {
		{0,0,0,0},
		{1,1,1,1},
		{0,0,0,0},
		{0,0,0,0},
	},
	{
		{1,0,0},
		{1,1,1},
		{0,0,0}
	},
	{
		{0,0,1},
		{1,1,1},
		{0,0,0},
	},
	{
		{0,0,0,0},
		{0,1,1,0},
		{0,1,1,0},
		{0,0,0,0},
	},
	{
		{0,1,1},
		{1,1,0},
		{0,0,0},
	},
	{
		{0,1,0},
		{1,1,1},
		{0,0,0},
	},
	{
		{1,1,0},
		{0,1,1},
		{0,0,0},
	},
}
tetromino.rotations = {
    get_rotations(tetromino.bitarrays[tetromino.shape.i]),
    get_rotations(tetromino.bitarrays[tetromino.shape.j]),
    get_rotations(tetromino.bitarrays[tetromino.shape.l]),
    get_rotations(tetromino.bitarrays[tetromino.shape.o]),
    get_rotations(tetromino.bitarrays[tetromino.shape.s]),
    get_rotations(tetromino.bitarrays[tetromino.shape.t]),
    get_rotations(tetromino.bitarrays[tetromino.shape.z]),
}
tetromino.boundaries = {
    get_boundaries(tetromino.rotations[tetromino.shape.i]),
    get_boundaries(tetromino.rotations[tetromino.shape.j]),
    get_boundaries(tetromino.rotations[tetromino.shape.l]),
    get_boundaries(tetromino.rotations[tetromino.shape.o]),
    get_boundaries(tetromino.rotations[tetromino.shape.s]),
    get_boundaries(tetromino.rotations[tetromino.shape.t]),
    get_boundaries(tetromino.rotations[tetromino.shape.z]),
}
tetromino.wallkicktests_jlstz = {
    { 0, 0,-1, 0,-1, 1, 0,-2,-1,-2},
    { 0, 0, 1, 0, 1,-1, 0, 2, 1, 2},
    { 0, 0, 1, 0, 1,-1, 0, 2, 1, 2},
    { 0, 0,-1, 0,-1, 1, 0,-2,-1,-2},
    { 0, 0, 1, 0, 1, 1, 0,-2, 1,-2},
    { 0, 0,-1, 0,-1,-1, 0, 2,-1, 2},
    { 0, 0,-1, 0,-1,-1, 0, 2,-1, 2},
    { 0, 0, 1, 0, 1, 1, 0,-2, 1,-2},
}
tetromino.wallkicktests_i = {
    { 0, 0,-2, 0, 1, 0,-2,-1, 1, 2},
    { 0, 0, 2, 0,-1, 0, 2, 1,-1,-2},
    { 0, 0,-1, 0, 2, 0,-1, 2, 2,-1},
    { 0, 0, 1, 0,-2, 0, 1,-2,-2, 1},
    { 0, 0, 2, 0,-1, 0, 2, 1,-1,-2},
    { 0, 0,-2, 0, 1, 0,-2,-1, 1, 2},
    { 0, 0, 1, 0,-2, 0, 1,-2,-2, 1},
    { 0, 0,-1, 0, 2, 0,-1, 2, 2,-1},
}

function tetromino.new(
    field,
    shape,
    position,
    rotation,
    velocity,
    locks,
    delay)
	local _tetromino = {
		field = field,
		shape = shape,
		position = vector.new{position[1], position[2]},
		rotation = rotation,
		velocity = velocity,
		modifier = 1,
		touching = false,
		locks = locks,
		delay = delay,
		timer = 0,
		alive = true,
		mappings = {
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
	    },
		atlas = love.graphics.newImage("blocks.png"),
	}
	_tetromino.quad = love.graphics.newQuad(0, 0, 0, 0, _tetromino.atlas:getWidth(), _tetromino.atlas:getWidth())
	local tetromino = setmetatable(_tetromino, tetromino)

    local state = tetromino.rotations[shape][rotation]

    local overlap = matrix.intersect(state, _tetromino.field, position:to_veci(), vector.new{1, 1}, function(a, b) return a > 0 and b > 0 end)

    return _tetromino
end
function tetromino:get_lower_bound(rotation)
    return self.field.height - tetromino.boundaries[self.shape][rotation][tetromino.bound.bottom]
end
function tetromino:get_upper_bound(rotation)
    return 1 - tetromino.boundaries[self.shape][rotation][tetromino.bound.top]
end
function tetromino:get_left_bound(rotation)
    return 1 - tetromino.boundaries[self.shape][rotation][tetromino.bound.left]
end
function tetromino:get_right_bound(rotation)
    return self.field.width - tetromino.boundaries[self.shape][rotation][tetromino.bound.right]
end
function tetromino:get_rotation()
    return self.rotation
end
function tetromino:get_next_rotation(direction)
    local rotation = self.rotation
    if direction == tetromino.direction.left then
        rotation = rotation - 1
    elseif direction == tetromino.direction.right then
        rotation = rotation + 1
    end
    rotation = rotation % 4 ~= 0 and rotation % 4 or 0
    if rotation < 1 then rotation = rotation + 4 end
    return rotation
end
function tetromino:get_state()
    return tetromino.rotations[self.shape][self:get_rotation()]
end
function tetromino:set_next_rotation(direction)
    self.rotation = self:get_next_rotation(direction)
end
function tetromino:get_wallkicktests(direction)
    local rotation = self:get_next_rotation(direction)
    local tests = 1
    if self.rotation == 1 and rotation == 2 then
        tests = 1
    elseif self.rotation == 2 and rotation == 1 then
        tests = 2
    elseif self.rotation == 2 and rotation == 3 then
        tests = 3
    elseif self.rotation == 3 and rotation == 2 then
        tests = 4
    elseif self.rotation == 3 and rotation == 4 then
        tests = 5
    elseif self.rotation == 4 and rotation == 3 then
        tests = 6
    elseif self.rotation == 4 and rotation == 1 then
        tests = 7
    elseif self.rotation == 1 and rotation == 4 then
        tests = 8
    end

    if self.shape == tetromino.shape.o then
        return {}
    end
    if self.shape == tetromino.shape.i then
        return tetromino.wallkicktests_i[tests]
    end

    return tetromino.wallkicktests_jlstz[tests]
end
function tetromino:drop()
    local test = vector.new{
        self.position[1],
        self.position[2],
    }
    test[2] = math.floor(test[2] + 1)

    local should_drop = true

    if test[2] > self:get_lower_bound(self.rotation) then
        should_drop = false
        if not self.touching then
            self.timer = love.timer.getTime()
            self.touching = true
        end
    end

    local state = tetromino.rotations[self.shape][self.rotation]
    local overlap = matrix.intersect(state, self.field, test:to_veci(), vector.new{1, 1}, function(a, b) return a > 0 and b > 0 end)
    if overlap then
        if not self.touching then
            self.timer = love.timer.getTime()
            self.touching = true
        end
        should_drop = false
    end

    if should_drop then
        -- The speed of a tetromino is maxed at 1 to prevent complex collision logic
        -- Basically the tetromino would need to be tested at all the points between the next state and the starting state
        -- The speed of a tetromino probably doesnt need to exceed 1 anyways
        self.position[2] = self.position[2] + math.min(self.velocity * self.modifier, 1)
    end

    test = vector.new{
        self.position[1],
        self.position[2],
    }
    test[2] = math.floor(test[2] + 1)

    -- test below the piece again to see if its touching the floor or another tetromino
    if test[2] > self:get_lower_bound(self.rotation) then
        if not self.touching then
            self.timer = love.timer.getTime()
            self.touching = true
        end
    end

    overlap = matrix.intersect(state, self.field, test:to_veci(), vector.new{1, 1}, function(a, b) return a > 0 and b > 0 end)
    if overlap then
        if not self.touching then
            self.timer = love.timer.getTime()
            self.touching = true
        end
    end
end
function tetromino:rotate(direction)
    if self.locks <= 0 then
        return
    end

    local rotation = self:get_next_rotation(direction)
    local state = tetromino.rotations[self.shape][rotation]
    local tests = self:get_wallkicktests(direction)

    -- Get the pairs of test coordinates
    for i = 1, #tests, 2 do
        local j = i + 1
        test = vector.new{
            self.position[1],
            self.position[2],
        }
        test[1] = test[1] + tests[i]
        test[2] = test[2] + tests[j]

        local should_move = true
        if test[1] < self:get_left_bound(rotation) then
            should_move = false
        end
        if test[1] > self:get_right_bound(rotation) then
            should_move = false
        end
        if test[2] > self:get_lower_bound(rotation) then
            should_move = false
        end

        local overlap = matrix.intersect(state, self.field, test:to_veci(), vector.new{1, 1}, function(a, b) return a > 0 and b > 0 end)

        if overlap then
            should_move = false
        end

        if should_move then
            if self.touching then
                self.locks = self.locks - 1
                self.touching = false
                self.timer = 0
            end
            self:set_next_rotation(direction)
            self.position[1] = test[1]
            self.position[2] = test[2]
            return
        end
    end
end
function tetromino:move(direction)
    if self.locks <= 0 then
        return
    end

    local step = 0

    if direction == tetromino.direction.left then
        step = -1
    elseif direction == tetromino.direction.right then
        step = 1
    end

    local rotation = self:get_rotation()

    local test = vector.new{
        self.position[1],
        self.position[2],
    }
    test[1] = test[1] + step
    if test[1] < self:get_left_bound(rotation) then
        return
    end
    if test[1] > self:get_right_bound(rotation) then
        return
    end

    local state = tetromino.rotations[self.shape][rotation]

    local overlap = matrix.intersect(state, self.field, test:to_veci(), vector.new{1, 1}, function(a, b) return a > 0 and b > 0 end)

    if overlap then
        return
    end

    if self.touching then
        self.locks = self.locks - 1
		self.touching = false
		self.timer = 0
    end
    self.position[1] = test[1]
    self.position[2] = test[2]
end
function tetromino:insert()
	local rotation = self:get_rotation()
    local state = tetromino.rotations[self.shape][rotation]

	local k = math.floor(self.position[1]) - 1
	local l = math.floor(self.position[2]) - 1

	for j=1,#state,1 do
		for i=1,#state[j],1 do
			if state[j][i] ~= 0 then
				self.field[l + j][k + i] = self.shape
			end
		end
	end
end
function tetromino:update()
	if love.keyboard.isDown("down") then
		self.modifier = 10
	else
		self.modifier = 1
	end
	self:drop()
	if self.touching and love.timer.getTime() - self.timer > self.delay then
		self:insert()
		local rows = 0
		for j = 1, self.field.height, 1 do
			if self.field:is_row_full(j) then
				self.field:clear_row(j)
				self.field:drop(j)
				rows = rows + 1
			end
		end
		self.field.cleared = rows
		self.field.onstack = true
		self.alive = false
	end
end
function tetromino:draw()
    local blocksize = self.field.blocksize
    local offset = self.field.position
    local state = tetromino.rotations[self.shape][self.rotation]
    local position = self.position
    love.graphics.setColor(tetromino.colors[self.shape])
	for j in ipairs(state) do
		for i in ipairs(state[j]) do
			-- test all four sides of the block
			local top = {i,j-1}
			local bottom = {i,j+1}
			local left = {i-1,j}
			local right = {i+1,j}
			-- If the test cell is out of bounds consider it unoccupied
			local occupied = 0
			occupied = bit.bor(occupied, bit.lshift(booltoint(top[2] >= self.field.hidden), 0))
			occupied = bit.bor(occupied, bit.lshift(booltoint(bottom[2] <= self.field.height), 1))
			occupied = bit.bor(occupied, bit.lshift(booltoint(left[1] >= 1), 2))
			occupied = bit.bor(occupied, bit.lshift(booltoint(right[1] <= self.field.width), 3))

			-- Test if the cell is occupied
			if top_occupied(occupied) then
				occupied = setbit(occupied, 0, self.field:get_block(top) == self.field:get_block({i, j}))
			end
			if bottom_occupied(occupied) then
				occupied = setbit(occupied, 1, self.field:get_block(bottom) == self.field:get_block({i, j}))
			end
			if left_occupied(occupied) then
				occupied = setbit(occupied, 2, self.field:get_block(left) == self.field:get_block({i, j}))
			end
			if right_occupied(occupied) then
				occupied = setbit(occupied, 3, self.field:get_block(right) == self.field:get_block({i, j}))
			end
			-- Set the imagedata for the cell
			local imagedata = nil
			if occupied == 0 then -- 0000
				imagedata = "island"
			elseif occupied == 1 then -- 0001
				imagedata = "bottom_end"
			elseif occupied == 2 then -- 0010
				imagedata = "top_end"
			elseif occupied == 3 then -- 0011
				imagedata = "top_bottom"
			elseif occupied == 4 then -- 0100
				imagedata = "right_end"
			elseif occupied == 5 then -- 0101
				imagedata = "bottom_right_corner"
			elseif occupied == 6 then -- 0110
				imagedata = "top_right_corner"
			elseif occupied == 7 then -- 0111
				imagedata = "right_wall"
			elseif occupied == 8 then -- 1000
				imagedata = "left_end"
			elseif occupied == 9 then -- 1001
				imagedata = "bottom_left_corner"
			elseif occupied == 10 then -- 1010
				imagedata = "top_left_corner"
			elseif occupied == 11 then -- 1011
				imagedata = "left_wall"
			elseif occupied == 12 then -- 1100
				imagedata = "left_right"
			elseif occupied == 13 then -- 1101
				imagedata = "bottom_wall"
			elseif occupied == 14 then -- 1110
				imagedata = "top_wall"
			elseif occupied == 15 then -- 1111
				imagedata = "middle"
			end
			if state[j][i] ~= 0 then
				local mapping = self.mappings[imagedata]
				self.quad:setViewport(
					mapping[1] * blocksize,
					mapping[2] * blocksize,
					blocksize,
					blocksize
				)
				love.graphics.draw(self.atlas, self.quad, offset[1] + (i + position[1] - 2) * blocksize, offset[2] + (j + math.floor(position[2]) - 2) * blocksize)
			end
		end
	end
end

return tetromino
