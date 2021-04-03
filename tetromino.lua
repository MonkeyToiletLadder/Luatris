--[[
    tetromino.lua
    luatris version 0.1.0
    author: vaxeral
    april 2 2021
]]

require "matrix"
require "vector"

local tetris = {}

tetris.shapes = {
    i = 1,
    j = 2,
    l = 3,
    o = 4,
    s = 5,
    t = 6,
    z = 7,
}

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

local bitarrays = {
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
	}
}

local rotations = {
    get_rotations(bitarrays[tetris.shapes.i]),
    get_rotations(bitarrays[tetris.shapes.j]),
    get_rotations(bitarrays[tetris.shapes.l]),
    get_rotations(bitarrays[tetris.shapes.o]),
    get_rotations(bitarrays[tetris.shapes.s]),
    get_rotations(bitarrays[tetris.shapes.t]),
    get_rotations(bitarrays[tetris.shapes.z]),
}

local boundaries = {
    get_boundaries(rotations[tetris.shapes.i]),
    get_boundaries(rotations[tetris.shapes.j]),
    get_boundaries(rotations[tetris.shapes.l]),
    get_boundaries(rotations[tetris.shapes.o]),
    get_boundaries(rotations[tetris.shapes.s]),
    get_boundaries(rotations[tetris.shapes.t]),
    get_boundaries(rotations[tetris.shapes.z]),
}

local wallkicktests_jlstz = {
    { 0, 0,-1, 0,-1, 1, 0,-2,-1,-2},
    { 0, 0, 1, 0, 1,-1, 0, 2, 1, 2},
    { 0, 0, 1, 0, 1,-1, 0, 2, 1, 2},
    { 0, 0,-1, 0,-1, 1, 0,-2,-1,-2},
    { 0, 0, 1, 0, 1, 1, 0,-2, 1,-2},
    { 0, 0,-1, 0,-1,-1, 0, 2,-1, 2},
    { 0, 0,-1, 0,-1,-1, 0, 2,-1, 2},
    { 0, 0, 1, 0, 1, 1, 0,-2, 1,-2},
}

local wallkicktests_i = {
    { 0, 0,-2, 0, 1, 0,-2,-1, 1, 2},
    { 0, 0, 2, 0,-1, 0, 2, 1,-1,-2},
    { 0, 0,-1, 0, 2, 0,-1, 2, 2,-1},
    { 0, 0, 1, 0,-2, 0, 1,-2,-2, 1},
    { 0, 0, 2, 0,-1, 0, 2, 1,-1,-2},
    { 0, 0,-2, 0, 1, 0,-2,-1, 1, 2},
    { 0, 0, 1, 0,-2, 0, 1,-2,-2, 1},
    { 0, 0,-1, 0, 2, 0,-1, 2, 2,-1},
}

tetris.directions = {
    left = 1,
    right = 2,
}

tetris.tetromino = {
    bounds = {
        lowest = 1,
        highest = 2,
        leftmost = 3,
        rightmost = 4,
    }
}
tetris.tetromino.__index = tetris.tetromino
function tetris.tetromino.new(
    field,
    shape,
    position,
    rotation,
    velocity,
    locks,
    delay)
	local tetromino = {
		field = field,
		shape = shape,
		position = position,
		rotation = rotation,
		velocity = velocity,
		modifier = 1,
		touching = false,
		locks = locks,
		delay = delay,
		timer = 0
	}
	return setmetatable(tetromino, tetris.tetromino)
end
function tetris.tetromino:get_lower_bound(rotation)
    return self.field.height - boundaries[self.shape][rotation][self.bounds.lowest]
end
function tetris.tetromino:get_upper_bound(rotation)
    return 1 - boundaries[self.shape][rotation][self.bounds.highest]
end
function tetris.tetromino:get_left_bound(rotation)
    return 1 - boundaries[self.shape][rotation][self.bounds.leftmost]
end
function tetris.tetromino:get_right_bound(rotation)
    return self.field.width - boundaries[self.shape][rotation][self.bounds.rightmost]
end
function tetris.tetromino:get_rotation()
    return self.rotation
end
function tetris.tetromino:get_next_rotation(direction)
    rotation = self.rotation
    if direction == tetris.directions.left then
        rotation = rotation - 1
    elseif direction == tetris.directions.right then
        rotation = rotation + 1
    end
    rotation = rotation % 4 ~= 0 and rotation % 4 or 0
    if rotation < 1 then rotation = rotation + 4 end
    return rotation
end
function tetris.tetromino:get_state()
    return rotations[self.shape][self:get_rotation()]
end
function tetris.tetromino:set_next_rotation(direction)
    self.rotation = self:get_next_rotation(direction)
end
function tetris.tetromino:get_wallkicktests(direction)
    rotation = self:get_next_rotation(direction)
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

    if self.shape == tetris.shapes.o then
        return {}
    end
    if self.shape == tetris.shapes.i then
        return wallkicktests_i[tests]
    end

    return wallkicktests_jlstz[tests]
end
function tetris.tetromino:drop()
    local test = vector.new{
        self.position[1],
        self.position[2],
    }
    test[2] = math.floor(test[2] + 1)

    should_drop = true

    if test[2] > self:get_lower_bound(self.rotation) then
        should_drop = false
        if not self.touching then
            self.timer = love.timer.getTime()
            self.touching = true
        end
    end

    local state = rotations[self.shape][self.rotation]
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
function tetris.tetromino:rotate(direction)
    if self.locks <= 0 then
        return
    end

    local rotation = self:get_next_rotation(direction)
    local state = rotations[self.shape][rotation]
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
function tetris.tetromino:move(direction)
    if self.locks <= 0 then
        return
    end

    local step = 0

    if direction == tetris.directions.left then
        step = -1
    elseif direction == tetris.directions.right then
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

    local state = rotations[self.shape][rotation]

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
function tetris.tetromino:insert()
	local rotation = self:get_rotation()
    local state = rotations[self.shape][rotation]

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

return tetris
