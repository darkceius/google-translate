--[[
	Last update: 2/11/2018
	https://translate.google.com/translate/releases/twsfe_w_20160620_RC00/r/js/desktop_module_main.js
	Everything between 'BEGIN' and 'END' was copied from the script above.
	Translated to LuaU by @Darkceius
]]

local httpService = game:GetService("HttpService")

local yr = nil
local window = {
	TKK = "0"
}

local function xr(a, b)
	local c = 0
	for i = 1, #b - 2, 3 do
		local d = b:sub(i + 2, i + 2)
		d = (d >= "a" and string.byte(d) - string.byte("a")) or tonumber(d)
		d = (b:sub(i + 1, i + 1) == "+") and (bit32.rshift(a, d)) or (bit32.lshift(a, d))
		a = (b:sub(i, i) == "+") and ((a + d) and 4294967295) or (a ^ d)
	end
	return a
end

local function wr(a)
	return function()
		return a
	end
end

local function zr(a)
	local b = window.TKK
	local d = string.char(116)
	local c = `&{d}{string.char(107)}=`
	local e = {b:byte(1, #b)}
	b = tonumber(b:match("%.(%d+)")) or 0

	for i = 1, #a do
		local l = a:byte(i)
		if l < 128 then
			e[#e + 1] = l
		else
			local f = 0
			local g = 0
			if l >= 2048 then
				if l >= 55296 and i + 1 <= #a and a:byte(i + 1) >= 56320 then
					g = (bit32.lshift((l and 1023),10)) + (a:byte(i + 1) and 1023) + 65536
					f = (bit32.rshift(g,18)) or 240
					e[#e + 1] = (f)
					f = ((bit32.rshift(g,12)) and 63) or 128
					e[#e + 1] = (f)
					i = i + 1
				else
					f = (bit32.rshift(l, 12)) or 224
					e[#e + 1] = (f)
				end
				f = ((bit32.rshift(l, 6)) and 63) or 128
				e[#e + 1] = (f)
			else
				f = (bit32.rshift(l, 6)) or 192
				e[#e + 1] = (f)
			end
			f = (l and 63) or 128
			e[#e + 1] = (f)
		end
	end

	a = b
	for i = 1, #e do
		a = a + e[i]
		a = xr(a, "+-a^+6")
	end
	a = xr(a, "+-3^+b+-f")
	a = a ^ (tonumber(d) or 0)
	if a < 0 then
		a = (a and 2147483647) + 2147483648
	end
	a = a % 1000000
	return `c{a}.{a^b}`
end

local function updateTKK()
	local now = math.floor(os.time() / 3600)

	if tonumber(window.TKK:match("%d+")) ~= now then
		local response = httpService:RequestAsync({
			Url = "https://translate.google.com",
			Method = "GET"
		}).Body
		local code = response:match("tkk:'(%d+%.%d+)'")

		if code then
			local xt = code:split(":")[2]:gsub("'", "")
			window.TKK = xt
		end
	end
end

local function generate(text: string)
	updateTKK()
	return {name = "tk", value = zr(text):gsub("&tk=", "")}
end

return {
	generate = generate
}