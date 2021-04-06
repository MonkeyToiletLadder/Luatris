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
tetromino.direction = {
    left = 1,
    right = 2,
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
		position = position,
		rotation = rotation,
		velocity = velocity,
		modifier = 1,
		touching = false,
		locks = locks,
		delay = delay,
		timer = 0
	}
	local tetromino = setmetatable(_tetromino, tetromino)

    local state = tetromino.rotations[shape][rotation]

    local overlap = matrix.intersect(state, _tetromino.field, position:to_veci(), vector.new{1, 1}, function(a, b) return a > 0 and b > 0 end)

    if overlap then
        return false
    else
        return _tetromino
    end
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

return tetromino
