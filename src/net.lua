local Core = getgenv().Lunar
local HttpService = Core.Services.HttpService

local Net = {}
Net.Base = "https://lnrs.dev/api/lunar"
Net.Secret = "c09b6c66590eded28f0301d51269501c917b2c2f6e3b76632819651d281cb69b"
Net.Access = false
Net.Role = "user"
Net.Label = nil
Net.Color = nil
Net.Identity = {
	userId = tostring(Core.LocalPlayer.UserId),
	username = Core.LocalPlayer.Name,
}

local function decode(body)
	if type(body) ~= "string" or body == "" then return nil end
	local ok, v = pcall(function() return HttpService:JSONDecode(body) end)
	return ok and v or nil
end

local function headers()
	local h = { ["Content-Type"] = "application/json" }
	if Net.Secret ~= "" then h["x-lunar-secret"] = Net.Secret end
	return h
end

function Net.post(path, body)
	local req = Core.Exploit.request
	if not req then return nil, "no_http" end
	local ok, res = pcall(req, {
		Url = Net.Base .. path,
		Method = "POST",
		Headers = headers(),
		Body = HttpService:JSONEncode(body or {}),
	})
	if not ok or not res then return nil, "request_failed" end
	return decode(res.Body), res.StatusCode or res.Status or 0
end

function Net.get(path)
	local req = Core.Exploit.request
	if req then
		local ok, res = pcall(req, { Url = Net.Base .. path, Method = "GET", Headers = headers() })
		if ok and res then return decode(res.Body), res.StatusCode or res.Status or 0 end
	end
	local ok, body = pcall(game.HttpGet, game, Net.Base .. path)
	if ok then return decode(body), 200 end
	return nil, "request_failed"
end

local function hwid()
	if typeof(gethwid) == "function" then
		local ok, v = pcall(gethwid)
		if ok then return v end
	end
	return nil
end

function Net.auth()
	local data = Net.post("/auth", {
		userId = Net.Identity.userId,
		username = Net.Identity.username,
		hwid = hwid(),
	})
	if not data then return { access = false, reason = "offline" } end
	Net.Access = data.access == true
	if Net.Access then
		Net.Role = data.role or "user"
		Net.Label = data.label
		Net.Color = data.color
	end
	return data
end

function Net.nametags(userIds)
	local data = Net.post("/nametags", { userIds = userIds })
	return (data and data.tags) or {}
end

function Net.saveConfig(tbl)
	return Net.post("/config", { userId = Net.Identity.userId, data = tbl or {} })
end

Core.Net = Net
return Net
