--[[
    tetromino.lua
    luatris version 0.1.0
    author: vaxeral
    april 6 2021
]]

local matrix = require "matrix"
local vector = require "vector"

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
-- The wikis chart has 1 for up and -1 for down while this chart is the inverse
tetromino.wallkicktests_jlstz = {
    { 0, 0,-1, 0,-1,-1, 0, 2,-1, 2},
    { 0, 0, 1, 0, 1, 1, 0,-2, 1,-2},
    { 0, 0, 1, 0, 1, 1, 0,-2, 1,-2},
    { 0, 0,-1, 0,-1,-1, 0, 2,-1, 2},
    { 0, 0, 1, 0, 1,-1, 0, 2, 1, 2},
    { 0, 0,-1, 0,-1, 1, 0,-2,-1,-2},
    { 0, 0,-1, 0,-1, 1, 0,-2,-1,-2},
    { 0, 0, 1, 0, 1,-1, 0, 2, 1, 2},
}
tetromino.wallkicktests_i = {
    { 0, 0,-2, 0, 1, 0,-2, 1, 1,-2},
    { 0, 0, 2, 0,-1, 0, 2,-1,-1, 2},
    { 0, 0,-1, 0, 2, 0,-1,-2, 2, 1},
    { 0, 0, 1, 0,-2, 0, 1, 2,-2,-1},
    { 0, 0, 2, 0,-1, 0, 2,-1,-1, 2},
    { 0, 0,-2, 0, 1, 0,-2, 1, 1,-2},
    { 0, 0, 1, 0,-2, 0, 1, 2,-2,-1},
    { 0, 0,-1, 0, 2, 0,-1,-2, 2, 1},
}

tetromino.piece = {}
tetromino.piece.__index = tetromino.piece
function tetromino.piece.new(
    field,
    shape,
    position,
    rotation,
    velocity,
    locks,
    delay)
	local _piece = {
		field = field,
		shape = shape,
		position = vector.new{position[1], position[2]},
		rotation = rotation,
		velocity = vector.new{velocity[1], velocity[2]},
		modifier = 1,
		touching = false,
		locks = locks,
		lock_delay = delay,
		lock_timer = 0,
		alive = true,
		block = love.graphics.newImage("blocks.png"),
		rotation_delay = .25,
		rotation_timer = 0,
		last_block = position[1],
	}
	_piece.quad = love.graphics.newQuad(0, 0, field.blocksize, field.blocksize, _piece.block:getWidth(), _piece.block:getWidth())
	local _piece = setmetatable(_piece, tetromino.piece)

    local state = tetromino.rotations[shape][rotation]

    local overlap = matrix.intersect(state, _piece.field, position:to_veci(), vector.new{1, 1}, function(a, b) return a > 0 and b > 0 end)

	if overlap then
		return nil
	end

    return _piece
end
function tetromino.piece:get_lower_bound(rotation)
    return self.field.height - tetromino.boundaries[self.shape][rotation][tetromino.bound.bottom]
end
function tetromino.piece:get_upper_bound(rotation)
    return 1 - tetromino.boundaries[self.shape][rotation][tetromino.bound.top]
end
function tetromino.piece:get_left_bound(rotation)
    return 1 - tetromino.boundaries[self.shape][rotation][tetromino.bound.left]
end
function tetromino.piece:get_right_bound(rotation)
    return self.field.width - tetromino.boundaries[self.shape][rotation][tetromino.bound.right]
end
function tetromino.piece:get_rotation()
    return self.rotation
end
function tetromino.piece:get_next_rotation(direction)
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
function tetromino.piece:get_state()
    return tetromino.rotations[self.shape][self:get_rotation()]
end
function tetromino.piece:set_next_rotation(direction)
    self.rotation = self:get_next_rotation(direction)
end
function tetromino.piece:get_wallkicktests(direction)
    local rotation = self:get_next_rotation(direction)
    local tests = 1
    if self.rotation == 1 and rotation == 2 then
        tests = 1
    elseif self.rotation == 2 and rotation == 1 then
		print("test 2")
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
function tetromino.piece:drop()
    local test = vector.new{
        self.position[1],
        self.position[2],
    }
    test[2] = math.floor(test[2] + 1)

    local should_drop = true

    if test[2] > self:get_lower_bound(self.rotation) then
        should_drop = false
        if not self.touching then
            self.lock_timer = love.timer.getTime()
            self.touching = true
        end
    end

    local state = tetromino.rotations[self.shape][self.rotation]
    local overlap = matrix.intersect(state, self.field, test:to_veci(), vector.new{1, 1}, function(a, b) return a > 0 and b > 0 end)
    if overlap then
        if not self.touching then
            self.lock_timer = love.timer.getTime()
            self.touching = true
        end
        should_drop = false
    end

    if should_drop then
        -- The speed of a tetromino is maxed at 1 to prevent complex collision logic
        -- Basically the tetromino would need to be tested at all the points between the next state and the starting state
        -- The speed of a tetromino probably doesnt need to exceed 1 anyways
        self.position[2] = self.position[2] + math.min(self.velocity[2] * self.modifier, 1)
    end

    test = vector.new{
        self.position[1],
        self.position[2],
    }
    test[2] = math.floor(test[2] + 1)

    -- test below the piece again to see if its touching the floor or another tetromino
    if test[2] > self:get_lower_bound(self.rotation) then
        if not self.touching then
            self.lock_timer = love.timer.getTime()
            self.touching = true
        end
    end

    overlap = matrix.intersect(state, self.field, test:to_veci(), vector.new{1, 1}, function(a, b) return a > 0 and b > 0 end)
    if overlap then
        if not self.touching then
            self.lock_timer = love.timer.getTime()
            self.touching = true
        end
    end
end
function tetromino.piece:rotate(direction)
	if love.timer.getTime() - self.rotation_timer <= self.rotation_delay then
		return
	end
    if self.locks <= 0 then
        return
    end

	self.rotation_timer = love.timer.getTime()

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
        if math.floor(test[1]) < self:get_left_bound(rotation) then
            should_move = false
        end
        if math.floor(test[1]) > self:get_right_bound(rotation) then
            should_move = false
        end
        if math.floor(test[2]) > self:get_lower_bound(rotation) then
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
                self.lock_timer = 0
            end
            self:set_next_rotation(direction)
            self.position[1] = test[1]
            self.position[2] = test[2]
            return
        end
    end
end
function tetromino.piece:move(direction)
    if self.locks <= 0 then
        return
    end

    local step = 0

    if direction == tetromino.direction.left then
        step = -1 * self.velocity[1]
    elseif direction == tetromino.direction.right then
        step = 1 * self.velocity[1]
    end

    local rotation = self:get_rotation()

    local test = vector.new{
        self.position[1],
        self.position[2],
    }
	local should_move = true
    test[1] = test[1] + step

    local state = tetromino.rotations[self.shape][rotation]

    local overlap = matrix.intersect(state, self.field, test:to_veci(), vector.new{1, 1}, function(a, b) return a > 0 and b > 0 end)

    if overlap then
        should_move = false
    end

    if self.touching and self.last_block ~= math.floor(self.position[1]) then
        self.locks = self.locks - 1
		self.touching = false
		self.lock_timer = 0
		self.last_block = math.floor(self.position[1])
    end
	if should_move then
    	self.position[1] = test[1]
    	self.position[2] = test[2]
		if test[1] < self:get_left_bound(rotation) then
			self.position[1] = self:get_left_bound(rotation)
	    end
	    if test[1] > self:get_right_bound(rotation) then
	        self.position[1] = self:get_right_bound(rotation)
	    end
	end
end
function tetromino.piece:insert()
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
function tetromino.piece:update()
	if love.keyboard.isDown("left") then
		self:move(tetromino.direction.left)
	elseif love.keyboard.isDown("right") then
		self:move(tetromino.direction.right)
	elseif love.keyboard.isDown("a") then
		self:rotate(tetromino.direction.left)
	elseif love.keyboard.isDown("s") then
		self:rotate(tetromino.direction.right)
	end
	if love.keyboard.isDown("down") then
		self.modifier = 10
	else
		self.modifier = 1
	end
	self:drop()
	if self.touching and love.timer.getTime() - self.lock_timer > self.lock_delay then
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
function tetromino.piece:draw()
    local blocksize = self.field.blocksize
    local offset = self.field.position
    local state = tetromino.rotations[self.shape][self.rotation]
    local position = self.position
    love.graphics.setColor(tetromino.colors[self.shape])
	for j in ipairs(state) do
		for i in ipairs(state[j]) do
			if state[j][i] ~= 0 then
				love.graphics.draw(self.block, self.quad, offset[1] + (i + math.floor(position[1]) - 2) * blocksize, offset[2] + (j + math.floor(position[2]) - 2) * blocksize)
			end
		end
	end
end

tetromino.array = {}
tetromino.array.__index = tetromino.array
function tetromino.array.new()
	local _array = {}

	_array.pieces = {}

	return setmetatable(_array, tetromino.array)
end
function tetromino.array:pop_front()
	return table.remove(self.pieces, 1)
end
function tetromino.array:push(piece)
	table.insert(self.pieces, piece)
end

return tetromino
