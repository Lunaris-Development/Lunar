local Core = getgenv().Lunar
local Services = Core.Services
local Players = Services.Players
local UserInputService = Services.UserInputService

local State = { clicktp = false }
local clickMaid = Core.Maid()

local function tpTo(query)
	local p = Core.findPlayer(query)
	if not p then Core.Notify("Player not found: " .. tostring(query), "Error") return end
	local tHrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
	local myHrp = Core.getHRP()
	if tHrp and myHrp then
		myHrp.CFrame = tHrp.CFrame * CFrame.new(3, 0, 0)
		Core.Notify("TP → " .. p.Name, "Success")
	else
		Core.Notify("Character not loaded", "Error")
	end
end

local function listPlayers()
	local names = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= Core.LocalPlayer then table.insert(names, p.Name) end
	end
	print("[Lunar] Players: " .. (next(names) and table.concat(names, ", ") or "none"))
	Core.Notify(#names .. " player(s) printed to console (F9)", "Success")
end

local function setClickTP(on)
	State.clicktp = on
	clickMaid:Clean()
	if on then
		clickMaid:Give(UserInputService.InputBegan:Connect(function(input, gpe)
			if gpe then return end
			local click = input.UserInputType == Enum.UserInputType.MouseButton1
			local touch = input.UserInputType == Enum.UserInputType.Touch
			if not click and not touch then return end
			local pos = UserInputService:GetMouseLocation()
			local ray = workspace.CurrentCamera:ScreenPointToRay(pos.X, pos.Y)
			local params = RaycastParams.new()
			params.FilterDescendantsInstances = { Core.getChar() }
			params.FilterType = Enum.RaycastFilterType.Exclude
			local result = workspace:Raycast(ray.Origin, ray.Direction * 2000, params)
			if result then
				local hrp = Core.getHRP()
				if hrp then hrp.CFrame = CFrame.new(result.Position + Vector3.new(0, 3, 0)) end
			end
		end))
		Core.Notify("Click TP: ON", "Success")
	else
		Core.Notify("Click TP: OFF", "Warn")
	end
end

Core.Commands:Register{
	names = { "tp", "goto" }, category = "Teleport", usage = "tp <player>",
	desc = "Teleport to a player (no args = list players)",
	run = function(args)
		if args[1] then tpTo(args[1]) else listPlayers() end
	end,
}
Core.Commands:Register{
	names = { "clicktp", "ctp", "ftpmobile" }, category = "Teleport", toggle = true,
	desc = "Click/tap anywhere to teleport there",
	isOn = function() return State.clicktp end,
	run = function() setClickTP(not State.clicktp) end,
}

Core.RegisterModule({
	Name = "Teleport",
	Cleanup = function() setClickTP(false) end,
})
