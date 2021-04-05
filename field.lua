--[[
    field.lua
    luatris version 0.1.0
    author: vaxeral
    april 1 2021
]]

field = {}
field.__index = field
function field.new(width, height)
    local _field = {}
    _field.width = width or 10
    _field.height = height or 40
    for j=1,_field.height,1 do
    	_field[j] = {}
    	for i=1,_field.width,1 do
    		_field[j][i] = 0
    	end
    end
    return setmetatable(_field, field)
end
function field:is_row_full(row)
    for i, v in ipairs(self[row]) do
        if v <= 0 then
            return false
        end
    end
    return true
end
function field:clear_row(row)
    for i in ipairs(self[row]) do
        self[row][i] = 0
    end
end
function field:drop(row, k)
    k = k or 1
    for j = row, 1, -1 do
        for i in ipairs(self[j]) do
            if self[j][i] ~= 0 then
                local temp = self[j][i]
                self[math.min(j + k, self.height)][i] = temp
                self[j][i] = 0
            end
        end
    end
end
