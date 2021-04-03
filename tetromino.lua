--[[
    tetromino.lua
    luatris version 0.1.0
    author: vaxeral
    april 2 2021
]]

require "matrix"

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

return tetris
