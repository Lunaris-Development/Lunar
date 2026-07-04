local Core = getgenv().Lunar
local Services = Core.Services
local Players = Services.Players
local RunService = Services.RunService
local HttpService = Services.HttpService
local TeleportService = Services.TeleportService
local VirtualUser = Services.VirtualUser

local State = { antiafk = false, lagspoof = false }
local afkMaid = Core.Maid()
local lagMaid = Core.Maid()

local function setAntiAFK(on)
	State.antiafk = on
	afkMaid:Clean()
	if on then
		afkMaid:Give(Core.LocalPlayer.Idled:Connect(function()
			VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
			task.wait(0.1)
			VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
		end))
		Core.Notify("Anti-AFK: ON", "Success")
	else
		Core.Notify("Anti-AFK: OFF", "Warn")
	end
end

local function setLagSpoof(on)
	State.lagspoof = on
	lagMaid:Clean()
	if on then
		local lastCF, frame = nil, 0
		lagMaid:Give(RunService.Heartbeat:Connect(function()
			local hrp = Core.getHRP()
			if not hrp then return end
			frame += 1
			if frame % 2 == 0 then
				if lastCF then hrp.CFrame = lastCF end
			else
				lastCF = hrp.CFrame
			end
		end))
		Core.Notify("Lag Spoof: ON", "Success")
	else
		Core.Notify("Lag Spoof: OFF", "Warn")
	end
end

local function rejoin()
	Core.Notify("Rejoining…", "Success")
	local ok = pcall(function()
		TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Core.LocalPlayer)
	end)
	if not ok then
		pcall(function() TeleportService:Teleport(game.PlaceId, Core.LocalPlayer) end)
	end
end

local function serverHop()
	Core.Notify("Finding a new server…", "Success")
	task.spawn(function()
		local ok, raw = pcall(game.HttpGet, game,
			("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(game.PlaceId))
		if not ok then Core.Notify("Server list unavailable", "Error") return end
		local ok2, data = pcall(function() return HttpService:JSONDecode(raw) end)
		if not ok2 or not data or not data.data then Core.Notify("No server data", "Error") return end
		for _, s in ipairs(data.data) do
			if s.playing and s.maxPlayers and s.playing < s.maxPlayers and s.id ~= game.JobId then
				pcall(function()
					TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, Core.LocalPlayer)
				end)
				return
			end
		end
		Core.Notify("No open servers found", "Warn")
	end)
end

local function serverList()
	Core.Notify("Fetching servers…", "Success")
	task.spawn(function()
		local ok, raw = pcall(game.HttpGet, game,
			("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(game.PlaceId))
		if not ok then Core.Notify("Server list unavailable", "Error") return end
		local ok2, data = pcall(function() return HttpService:JSONDecode(raw) end)
		if not ok2 or not data or not data.data then Core.Notify("No server data", "Error") return end
		local servers = data.data
		table.sort(servers, function(a, b) return (a.ping or 999) < (b.ping or 999) end)
		print("[Lunar] Server List (best ping first):")
		for i = 1, math.min(#servers, 15) do
			local s = servers[i]
			print(("  #%d | %sms | %d/%d | %s"):format(
				i, tostring(s.ping or 0), s.playing or 0, s.maxPlayers or 0, tostring(s.id):sub(1, 8)))
		end
		local best = servers[1]
		if best then
			Core.Notify(("Best: %sms (%d/%d)"):format(tostring(best.ping or 0), best.playing or 0, best.maxPlayers or 0), "Success")
		end
	end)
end

Core.Commands:Register{
	names = { "antiafk", "afk" }, category = "Server", toggle = true,
	desc = "Prevent AFK kick",
	isOn = function() return State.antiafk end,
	run = function() setAntiAFK(not State.antiafk) end,
}
Core.Commands:Register{
	names = { "lagspoof", "lag" }, category = "Server", toggle = true,
	desc = "Simulate lag by holding position",
	isOn = function() return State.lagspoof end,
	run = function() setLagSpoof(not State.lagspoof) end,
}
Core.Commands:Register{
	names = { "spoof", "userspoofer" }, category = "Server", usage = "spoof <name>",
	desc = "Change your display name locally",
	run = function(args)
		local name = args[1] or "player"
		pcall(function() Core.LocalPlayer.DisplayName = name end)
		Core.Notify("Spoofed display name: " .. name, "Success")
	end,
}
Core.Commands:Register{
	names = { "serverinfo", "sinfo" }, category = "Server",
	desc = "Toggle the server info panel",
	run = function()
		if Core.UI and Core.UI.ToggleServerInfo then
			Core.UI.ToggleServerInfo()
		else
			print(("[Lunar] Players: %d | Ping: %dms | Job: %s"):format(
				#Players:GetPlayers(), math.floor(Core.LocalPlayer:GetNetworkPing() * 1000), game.JobId))
		end
	end,
}
Core.Commands:Register{
	names = { "serverlist", "slist", "serverh" }, category = "Server",
	desc = "Print the best-ping servers to console",
	run = serverList,
}
Core.Commands:Register{
	names = { "serverhop", "shop" }, category = "Server",
	desc = "Teleport to another server",
	run = serverHop,
}
Core.Commands:Register{
	names = { "rejoin", "rj" }, category = "Server",
	desc = "Rejoin the current server",
	run = rejoin,
}
Core.Commands:Register{
	names = { "shlow" }, category = "Server",
	desc = "Show the player with the lowest HP",
	run = function()
		local low, lowHp = nil, math.huge
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= Core.LocalPlayer and p.Character then
				local hum = p.Character:FindFirstChildOfClass("Humanoid")
				if hum and hum.Health < lowHp then lowHp, low = hum.Health, p end
			end
		end
		if low then Core.Notify(("Lowest HP: %s (%dhp)"):format(low.Name, math.floor(lowHp)), "Warn")
		else Core.Notify("No targets found", "Error") end
	end,
}
Core.Commands:Register{
	names = { "shmost" }, category = "Server",
	desc = "Show the player with the highest HP",
	run = function()
		local high, highHp = nil, 0
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= Core.LocalPlayer and p.Character then
				local hum = p.Character:FindFirstChildOfClass("Humanoid")
				if hum and hum.Health > highHp then highHp, high = hum.Health, p end
			end
		end
		if high then Core.Notify(("Most HP: %s (%dhp)"):format(high.Name, math.floor(highHp)), "Success")
		else Core.Notify("No targets found", "Error") end
	end,
}

Core.RegisterModule({
	Name = "Server",
	Cleanup = function() setAntiAFK(false); setLagSpoof(false) end,
})
