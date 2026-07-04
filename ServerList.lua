local HttpService = game:GetService("HttpService")

local ServerList = {}

local function fetch(UI)
	if UI then UI.Notify("Fetching servers...", "Success") end
	local ok, raw = pcall(game.HttpGet, game, "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
	if not ok then
		if UI then UI.Notify("Server list unavailable", "Error") end
		return
	end
	local ok2, data = pcall(HttpService.JSONDecode, HttpService, raw)
	if not ok2 or not data or not data.data then
		if UI then UI.Notify("No server data", "Error") end
		return
	end
	local servers = data.data
	table.sort(servers, function(a, b) return (a.ping or 999) < (b.ping or 999) end)
	print("[Lunar] Server List (best to worst ping):")
	for i = 1, math.min(#servers, 15) do
		local s = servers[i]
		print(string.format("  #%d | %dms | %d/%d players | %s", i, s.ping or 0, s.playing or 0, s.maxPlayers or 0, tostring(s.id):sub(1, 8)))
	end
	local best = servers[1]
	if best and UI then
		UI.Notify("Best: " .. (best.ping or 0) .. "ms (" .. (best.playing or 0) .. "/" .. (best.maxPlayers or 0) .. ")", "Success")
	end
end

function ServerList.HandleChat(msg, UI)
	local cmd = msg:lower():split(" ")[1]
	if cmd == "serverh" or cmd == "slist" then task.spawn(fetch, UI) end
end

return ServerList
