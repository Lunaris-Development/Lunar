local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local ESP = {}
ESP.Enabled = false
ESP.Settings = {
	Highlights = true,
	Box = false,
	HP = false,
	Skeleton = false,
	Names = false,
}

local Connections = {}
local PlayerData = {}

local BONE_PAIRS = {
	{"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
	{"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
	{"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
	{"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
	{"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
}

local function RemoveESP(player)
	local data = PlayerData[player]
	if not data then return end
	pcall(function() if data.Highlight then data.Highlight:Destroy() end end)
	pcall(function() if data.Box then data.Box:Destroy() end end)
	pcall(function() if data.HPGui then data.HPGui:Destroy() end end)
	pcall(function() if data.NameGui then data.NameGui:Destroy() end end)
	pcall(function()
		for _, b in ipairs(data.Bones or {}) do
			b.beam:Destroy(); b.a0:Destroy(); b.a1:Destroy()
		end
	end)
	if data.HPConn then data.HPConn:Disconnect() end
	PlayerData[player] = nil
end

local function CreateESP(player)
	if player == Players.LocalPlayer then return end
	RemoveESP(player)
	local char = player.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local data = {}
	PlayerData[player] = data

	local color = Color3.fromRGB(150, 100, 250)
	pcall(function() if player.Team then color = player.TeamColor.Color end end)

	local hl = Instance.new("Highlight")
	hl.FillColor = color
	hl.FillTransparency = 0.5
	hl.OutlineColor = Color3.fromRGB(255, 255, 255)
	hl.OutlineTransparency = 0
	hl.Adornee = char
	hl.Parent = char
	hl.Enabled = ESP.Settings.Highlights
	data.Highlight = hl

	local sb = Instance.new("SelectionBox")
	sb.Color3 = Color3.fromRGB(255, 60, 60)
	sb.LineThickness = 0.04
	sb.SurfaceTransparency = 1
	sb.Adornee = char
	sb.Parent = workspace
	sb.Visible = ESP.Settings.Box
	data.Box = sb

	local hpGui = Instance.new("BillboardGui")
	hpGui.Size = UDim2.new(4, 0, 0.35, 0)
	hpGui.StudsOffset = Vector3.new(0, 3.5, 0)
	hpGui.AlwaysOnTop = true
	hpGui.Adornee = hrp
	hpGui.Parent = workspace
	hpGui.Enabled = ESP.Settings.HP
	local hpBack = Instance.new("Frame", hpGui)
	hpBack.Size = UDim2.new(1, 0, 1, 0)
	hpBack.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	hpBack.BorderSizePixel = 0
	Instance.new("UICorner", hpBack).CornerRadius = UDim.new(1, 0)
	local hpFill = Instance.new("Frame", hpBack)
	hpFill.Size = UDim2.new(1, 0, 1, 0)
	hpFill.BackgroundColor3 = Color3.fromRGB(0, 220, 80)
	hpFill.BorderSizePixel = 0
	Instance.new("UICorner", hpFill).CornerRadius = UDim.new(1, 0)
	data.HPGui = hpGui
	data.HPFill = hpFill

	local nameGui = Instance.new("BillboardGui")
	nameGui.Size = UDim2.new(6, 0, 1.2, 0)
	nameGui.StudsOffset = Vector3.new(0, 4.5, 0)
	nameGui.AlwaysOnTop = true
	nameGui.Adornee = hrp
	nameGui.Parent = workspace
	nameGui.Enabled = ESP.Settings.Names
	local nameLbl = Instance.new("TextLabel", nameGui)
	nameLbl.Size = UDim2.new(1, 0, 1, 0)
	nameLbl.BackgroundTransparency = 1
	nameLbl.Text = player.Name
	nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLbl.TextStrokeTransparency = 0.2
	nameLbl.Font = Enum.Font.GothamBold
	nameLbl.TextSize = 14
	data.NameGui = nameGui

	data.Bones = {}
	for _, pair in ipairs(BONE_PAIRS) do
		local p0 = char:FindFirstChild(pair[1])
		local p1 = char:FindFirstChild(pair[2])
		if p0 and p1 then
			local a0 = Instance.new("Attachment", p0)
			local a1 = Instance.new("Attachment", p1)
			local beam = Instance.new("Beam")
			beam.Attachment0 = a0
			beam.Attachment1 = a1
			beam.Width0 = 0.05
			beam.Width1 = 0.05
			beam.FaceCamera = true
			beam.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
			beam.LightInfluence = 1
			beam.Enabled = ESP.Settings.Skeleton
			beam.Parent = workspace
			table.insert(data.Bones, {beam = beam, a0 = a0, a1 = a1})
		end
	end

	data.HPConn = RunService.Heartbeat:Connect(function()
		if not char or not char.Parent then return end
		if not data.HPGui.Enabled then return end
		local hum = char:FindFirstChild("Humanoid")
		if hum then
			local pct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
			data.HPFill.Size = UDim2.new(pct, 0, 1, 0)
			data.HPFill.BackgroundColor3 = Color3.fromRGB(math.floor((1 - pct) * 255), math.floor(pct * 220), 40)
		end
	end)
end

function ESP.Toggle(state)
	ESP.Enabled = state
	if state then
		for _, p in ipairs(Players:GetPlayers()) do
			if p.Character then CreateESP(p) end
			table.insert(Connections, p.CharacterAdded:Connect(function()
				task.wait(0.5)
				if ESP.Enabled then CreateESP(p) end
			end))
		end
		table.insert(Connections, Players.PlayerAdded:Connect(function(p)
			table.insert(Connections, p.CharacterAdded:Connect(function()
				task.wait(0.5)
				if ESP.Enabled then CreateESP(p) end
			end))
		end))
		table.insert(Connections, Players.PlayerRemoving:Connect(function(p)
			RemoveESP(p)
		end))
	else
		for _, c in ipairs(Connections) do c:Disconnect() end
		for p in pairs(PlayerData) do RemoveESP(p) end
		Connections = {}
	end
end

function ESP.ToggleFeature(feature, state)
	ESP.Settings[feature] = state
	for _, data in pairs(PlayerData) do
		if feature == "Highlights" and data.Highlight then
			data.Highlight.Enabled = state
		elseif feature == "Box" and data.Box then
			data.Box.Visible = state
		elseif feature == "HP" and data.HPGui then
			data.HPGui.Enabled = state
		elseif feature == "Names" and data.NameGui then
			data.NameGui.Enabled = state
		elseif feature == "Skeleton" and data.Bones then
			for _, b in ipairs(data.Bones) do
				b.beam.Enabled = state
			end
		end
	end
end

return ESP
