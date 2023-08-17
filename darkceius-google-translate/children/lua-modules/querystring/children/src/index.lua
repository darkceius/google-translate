local src = script.Parent
local encode = require(src["encode.lua"])

-- TODO: work on decode/parse

return {
	stringify = encode,
	encode = encode,
}