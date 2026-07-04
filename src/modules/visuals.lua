local Core = getgenv().Lunar
local Services = Core.Services
local Players = Services.Players
local RunService = Services.RunService
local Lighting = Services.Lighting

local ESP = { Enabled = false }
local Settings = { Highlights = true, Box = false, HP = false, Names = false, Skeleton = false }
local espMaid = Core.Maid()
local PlayerData = {}

local BONE_PAIRS = {
	{ "Head", "UpperTorso" }, { "UpperTorso", "LowerTorso" },
	{ "UpperTorso", "LeftUpperArm" }, { "LeftUpperArm", "LeftLowerArm" }, { "LeftLowerArm", "LeftHand" },
	{ "UpperTorso", "RightUpperArm" }, { "RightUpperArm", "RightLowerArm" }, { "RightLowerArm", "RightHand" },
	{ "LowerTorso", "LeftUpperLeg" }, { "LeftUpperLeg", "LeftLowerLeg" }, { "LeftLowerLeg", "LeftFoot" },
	{ "LowerTorso", "RightUpperLeg" }, { "RightUpperLeg", "RightLowerLeg" }, { "RightLowerLeg", "RightFoot" },
}

local function removeESP(player)
	local data = PlayerData[player]
	if not data then return end
	if data.maid then data.maid:Clean() end
	PlayerData[player] = nil
end

local function createESP(player)
	if player == Core.LocalPlayer then return end
	removeESP(player)
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local data = { maid = Core.Maid() }
	PlayerData[player] = data

	local color = Color3.fromRGB(150, 100, 250)
	pcall(function() if player.Team then color = player.TeamColor.Color end end)

	data.Highlight = data.maid:Give(Core.new("Highlight", {
		FillColor = color, FillTransparency = 0.5, OutlineColor = Color3.fromRGB(255, 255, 255),
		OutlineTransparency = 0, Adornee = char, Enabled = Settings.Highlights,
	}, char))

	data.Box = data.maid:Give(Core.new("SelectionBox", {
		Color3 = Color3.fromRGB(255, 60, 60), LineThickness = 0.04, SurfaceTransparency = 1,
		Adornee = char, Visible = Settings.Box,
	}, workspace))

	local hpGui = Core.new("BillboardGui", {
		Size = UDim2.new(4, 0, 0.35, 0), StudsOffset = Vector3.new(0, 3.5, 0),
		AlwaysOnTop = true, Adornee = hrp, Enabled = Settings.HP,
	}, workspace)
	data.maid:Give(hpGui)
	local hpBack = Core.new("Frame", {
		Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(30, 30, 30), BorderSizePixel = 0,
	}, hpGui)
	Core.new("UICorner", { CornerRadius = UDim.new(1, 0) }, hpBack)
	local hpFill = Core.new("Frame", {
		Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(0, 220, 80), BorderSizePixel = 0,
	}, hpBack)
	Core.new("UICorner", { CornerRadius = UDim.new(1, 0) }, hpFill)
	data.HPGui, data.HPFill = hpGui, hpFill

	local nameGui = Core.new("BillboardGui", {
		Size = UDim2.new(6, 0, 1.2, 0), StudsOffset = Vector3.new(0, 4.5, 0),
		AlwaysOnTop = true, Adornee = hrp, Enabled = Settings.Names,
	}, workspace)
	data.maid:Give(nameGui)
	Core.new("TextLabel", {
		Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = player.Name,
		TextColor3 = Color3.fromRGB(255, 255, 255), TextStrokeTransparency = 0.2,
		Font = Enum.Font.GothamBold, TextSize = 14,
	}, nameGui)
	data.NameGui = nameGui

	data.Bones = {}
	for _, pair in ipairs(BONE_PAIRS) do
		local p0, p1 = char:FindFirstChild(pair[1]), char:FindFirstChild(pair[2])
		if p0 and p1 then
			local a0 = data.maid:Give(Core.new("Attachment", {}, p0))
			local a1 = data.maid:Give(Core.new("Attachment", {}, p1))
			local beam = data.maid:Give(Core.new("Beam", {
				Attachment0 = a0, Attachment1 = a1, Width0 = 0.05, Width1 = 0.05,
				FaceCamera = true, Color = ColorSequence.new(Color3.fromRGB(255, 255, 255)),
				LightInfluence = 1, Enabled = Settings.Skeleton,
			}, workspace))
			table.insert(data.Bones, beam)
		end
	end

	data.maid:Give(RunService.Heartbeat:Connect(function()
		if not char.Parent or not hpGui.Enabled then return end
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			local pct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
			hpFill.Size = UDim2.new(pct, 0, 1, 0)
			hpFill.BackgroundColor3 = Color3.fromRGB(math.floor((1 - pct) * 255), math.floor(pct * 220), 40)
		end
	end))
end

local function setESP(on)
	ESP.Enabled = on
	espMaid:Clean()
	if on then
		for _, p in ipairs(Players:GetPlayers()) do
			if p.Character then createESP(p) end
			espMaid:Give(p.CharacterAdded:Connect(function()
				task.wait(0.5)
				if ESP.Enabled then createESP(p) end
			end))
		end
		espMaid:Give(Players.PlayerAdded:Connect(function(p)
			espMaid:Give(p.CharacterAdded:Connect(function()
				task.wait(0.5)
				if ESP.Enabled then createESP(p) end
			end))
		end))
		espMaid:Give(Players.PlayerRemoving:Connect(removeESP))
		espMaid:Give(function()
			for p in pairs(PlayerData) do removeESP(p) end
		end)
		Core.Notify("ESP: ON", "Success")
	else
		Core.Notify("ESP: OFF", "Warn")
	end
end

local function toggleFeature(feature)
	Settings[feature] = not Settings[feature]
	local on = Settings[feature]
	for _, data in pairs(PlayerData) do
		if feature == "Highlights" and data.Highlight then data.Highlight.Enabled = on
		elseif feature == "Box" and data.Box then data.Box.Visible = on
		elseif feature == "HP" and data.HPGui then data.HPGui.Enabled = on
		elseif feature == "Names" and data.NameGui then data.NameGui.Enabled = on
		elseif feature == "Skeleton" and data.Bones then
			for _, b in ipairs(data.Bones) do b.Enabled = on end
		end
	end
	Core.Notify("ESP " .. feature .. ": " .. (on and "ON" or "OFF"), on and "Success" or "Warn")
end

Core.Commands:Register{
	names = { "esp" }, category = "Visuals", toggle = true,
	desc = "Master ESP (highlights/box/hp/names/skeleton)",
	isOn = function() return ESP.Enabled end,
	run = function() setESP(not ESP.Enabled) end,
}
for cmd, feature in pairs({
	esphighlight = "Highlights", espbox = "Box", esphp = "HP",
	espnames = "Names", espskeleton = "Skeleton",
}) do
	Core.Commands:Register{
		names = { cmd }, category = "Visuals", toggle = true,
		desc = "Toggle ESP " .. feature:lower(),
		isOn = function() return Settings[feature] end,
		run = function() toggleFeature(feature) end,
	}
end

local fullbright = false
local savedLighting = {}
Core.Commands:Register{
	names = { "fullbright", "fb" }, category = "Visuals", toggle = true,
	desc = "Remove darkness / fog",
	isOn = function() return fullbright end,
	run = function()
		fullbright = not fullbright
		if fullbright then
			savedLighting = {
				Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime,
				FogEnd = Lighting.FogEnd, GlobalShadows = Lighting.GlobalShadows,
				Ambient = Lighting.Ambient,
			}
			Lighting.Brightness = 2
			Lighting.ClockTime = 14
			Lighting.FogEnd = 1e9
			Lighting.GlobalShadows = false
			Lighting.Ambient = Color3.fromRGB(180, 180, 180)
			Core.Notify("Fullbright: ON", "Success")
		else
			for k, v in pairs(savedLighting) do pcall(function() Lighting[k] = v end) end
			Core.Notify("Fullbright: OFF", "Warn")
		end
	end,
}

Core.RegisterModule({
	Name = "Visuals",
	Cleanup = function() setESP(false) end,
})
