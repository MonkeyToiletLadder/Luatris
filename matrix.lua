--[[
    matrix.lua
    luatris version 0.1.0
    author: vaxeral
    april 1 2021
]]

matrix = {}
matrix.__index = matrix
function matrix.new(_matrix)
    return setmetatable(_matrix, matrix)
end
function matrix:rot90(k)
    k = k or 1
    k = k % 4
	if k < 0 then k = k + 4 end
	if k == 0 then
		return self
	else
		local rows = #self[1]
		local columns = #self
		local output = {}
		for j=1,rows,1 do
			output[j] = {}
			for i=1,columns,1 do
				output[j][i] = 0
			end
		end
		for j=1,rows,1 do
			for i=1,columns,1 do
				output[j][i] = self[#self - (i - 1)][j]
			end
		end
		setmetatable(output, matrix)
		return output:rot90(k - 1)
	end
end
function matrix:intersection(other, spos, opos, comparison)
    for j in ipairs(self) do
        for i in ipairs(self[j]) do
            local si = spos[1] + (i - 1)
            local sj = spos[2] + (j - 1)
            local oi = opos[1] + (i - 1)
            local oj = opos[2] + (j - 1)
            local continue = false
            if si < 1 or sj < 1 or oi < 1 or oj < 1 then
                continue = true
            end
            if si > #other[1] or sj > #other or oi > #self[1] or oj > #self then
                continue = true
            end
            if not continue then
                local es = self[oj][oi]
                local eo = other[sj][si]
                if comparison(es, eo) then
                    return true
                end
            end
        end
    end
    return false
end
