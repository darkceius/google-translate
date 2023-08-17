--!nocheck

local src = script.Parent
local modules = script.Parent.Parent["lua-modules"]

local languages = require(src["languages.lua"])
local tokenGenerator = require(src["tokenGenerator.lua"])

local querystring = require(modules.querystring)

local httpService = game:GetService("HttpService")

function boolean(i)
	if i then
		return true
	end
	return false
end

function translate(text: string, options: { to: string?, from: string?, raw: boolean? }?)
	if typeof(options) ~= "table" then
		options = {}
	end
	
	text = tostring(text)
	
	local err
	for i, v in pairs(options) do
		if table.find({"to", "from"}, i) then
			if not languages.isSupported(v) then
				err = `The language '{v}' is not supported.`
			end
		end
	end
	
	if err then
		error(err)
	end
	
	if typeof(options.from) ~= "string" then options.from = "auto" end
	if typeof(options.to) ~= "string" then options.to = "en" end
	options.raw = boolean(options.raw)
	
	local token = tokenGenerator.generate(text)
	local baseUrl = "https://translate.google.com/translate_a/single"
	
	local data = {
		client = "gtx",
		sl = options.from,
		tl = options.to,
		hl = options.to,
		dt = {"at", "bd", "ex", "ld", "md", "qca", "rw", "rm", "ss", "t"},
		ie = "UTF-8",
		oe = "UTF-8",
		otf = 1,
		ssel = 0,
		tsel = 0,
		kc = 7,
		q = text,
		[token.name] = token.value
	}
	
	local url = `{baseUrl}{querystring.stringify(data)}`
	local requestOptions
	
	if #url > 2048 then
		data.q = nil
		requestOptions = {
			Url = url,
			Method = "POST",
			Body = querystring.stringify({ q = text }),
			Headers = {
				["Content-Type"] = "application/x-www-form-urlencoded;charset=UTF-8"
			}
		}
	else
		requestOptions = {
			Url = url,
			Method = "GET"
		}
	end
	
	local response = httpService:RequestAsync(requestOptions)
	if not (response.StatusCode > 199 and response.StatusCode < 201) then
		warn(response)
		error(`Request failed, check warning above.`)
	end
	
	local body = httpService:JSONDecode(response.Body)
	
	local result = {
		text = "",
		from = {
			language = {
				didYouMean = false,
				iso = ""
			},
			text = {
				autoCorrected = false,
				value = "",
				didYouMean = false,
			}
		}
	}
	
	if options.raw then
		result.raw = body
	end
	
	for i, obj in pairs(body[1]) do
		if obj[1] then
			result.text ..= obj[1]
		end
	end
	
	if (body[3] == body[9][1][1]) then
		result.from.language.iso = body[3]
	else
		result.from.language.didYouMean = true
		result.from.language.iso = body[9][1][1]
	end
	
	if (body[8] and body[8][1]) then
		local str = body[8][1]
		
		str = str:gsub("<b><i>", "[")
		str = str:gsub("<i><b>", "]")
		
		result.from.text.value = str
		
		if (body[8][6] == true) then
			result.from.text.autoCorrected = true
		else
			result.from.text.didYouMean = true
		end
	end
	
	return result
end

return setmetatable({}, {
	__call = function(self, ...)
		return translate(...)
	end,
	__index = function(self, i)
		if i == "languages" then
			return languages
		end
	end,
	__metatable = "This metatable is locked"
})