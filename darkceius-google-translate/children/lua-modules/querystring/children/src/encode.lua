local httpService = game:GetService("HttpService")
return function(data)
	local parts = {}
	for i, v in pairs(data) do
		if type(v) == "table" then
			for _, it in ipairs(v) do
				table.insert(parts, httpService:UrlEncode(i) .. "=" .. httpService:UrlEncode(tostring(it)))
			end
		else
			table.insert(parts, httpService:UrlEncode(i) .. "=" .. httpService:UrlEncode(tostring(v)))
		end
	end
	return "?".. table.concat(parts, "&")
end