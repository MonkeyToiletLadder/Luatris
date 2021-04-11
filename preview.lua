tetromino = require "tetromino"

preview = {}

preview.core = {}
preview.core.__index = preview.core
function preview.core.new(array, position, blocksize, width, height, scale)
	local _core = {}

    _core.width = width
    _core.height = height
    _core.position = position
	_core.array = array
	_core.blocksize = blocksize
	_core.scale = scale
    _core.block = love.graphics.newImage("blocks.png")
    _core.quad = love.graphics.newQuad(0, 0, _core.block:getWidth(), _core.block:getHeight(), _core.block:getWidth(), _core.block:getHeight())

	return setmetatable(_core, preview.core)
end
function preview.core:get_block_size()
    return self.blocksize * self.scale
end
function preview.core:get_inner_position()
	return self.position + vector.new{self.border:get_left_margin(), self.border:get_top_margin()}
end
function preview.core:get_outer_position()
	return self.position
end
function preview.core:push(piece)
    self.array:push(piece)
end
function preview.core:pop_front()
    return self.array:pop_front()
end
function preview.core:draw()
	local offset = self:get_inner_position()
	local blocksize = self:get_block_size()
	for k, shape in ipairs(self.array.pieces) do
        local state = tetromino.bitarrays[shape]
        local color = tetromino.colors[shape]
        for j=1,#state,1 do
			for i=1,#state[j],1 do
	            if color and state[j][i] ~= 0 then
	                love.graphics.setColor(unpack(color))
				    love.graphics.draw(
	                    self.block,
	                    self.quad,
	                    (i - 1) * blocksize + offset[1],
	                    (j - 1) * blocksize + offset[2] + (k - 1) * 4 * blocksize,
	                    0,
	                    self.scale,
	                    self.scale
	                )
	            end
			end
		end
	end
end

preview.background = {}
preview.background.__index = preview.background
function preview.background.new(core)
	local _background = {}

	_background.core = core
	_background.core.background = _background

	return setmetatable(_background, preview.background)
end
function preview.background:draw()
    local offset = self.core:get_inner_position()
    local blocksize = self.core:get_block_size()
    love.graphics.setColor(1,1,1)
    love.graphics.rectangle(
        "fill",
        offset[1],
        offset[2],
        blocksize * self.core.width,
        blocksize * self.core.height
    )
end

preview.border = {}
preview.border.__index = preview.border
function preview.border.new(core, image, left_margin, top_margin)
	local _border = {}

	_border.core = core
    _border.image = image
    _border.quad = love.graphics.newQuad(0, 0, image:getWidth(), image:getHeight(), image:getWidth(), image:getHeight())
	_border.core.border = _border
	_border.left_margin = left_margin
	_border.top_margin = top_margin

	return setmetatable(_border, preview.border)
end
function preview.border:get_left_margin()
	return self.left_margin * self.core.scale
end
function preview.border:get_top_margin()
	return self.top_margin * self.core.scale
end
function preview.border:draw()
    local position = self.core:get_outer_position()
    local blocksize = self.core:get_block_size()
    love.graphics.setColor(1,1,1)
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

return preview
