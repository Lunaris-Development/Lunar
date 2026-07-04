local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LogoID = "rbxthumb://type=Asset&id=73819038719454&w=420&h=420"

local function GetFont() return Font.fromEnum(Enum.Font.GothamBold) end
local function GetFontSub() return Font.fromEnum(Enum.Font.Gotham) end

local Nametags = {}
local Connections = {}
local Active = true

local function hexColor(hex)
	if type(hex) ~= "string" then return Color3.fromRGB(120, 255, 165) end
	hex = hex:gsub("#", "")
	local r = tonumber(hex:sub(1, 2), 16) or 120
	local g = tonumber(hex:sub(3, 4), 16) or 255
	local b = tonumber(hex:sub(5, 6), 16) or 165
	return Color3.fromRGB(r, g, b)
end

local ROLE_PRESETS = {
	owner = {
		accent = ColorSequence.new{
			ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 60, 60)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 130, 40)),
			ColorSequenceKeypoint.new(1,   Color3.fromRGB(255, 210, 60)),
		},
		glitch = true,
	},
	dev = {
		accent = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(168, 85, 247)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(217, 70, 239)),
		},
		glitch = true,
	},
	admin = {
		accent = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(245, 158, 11)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(251, 191, 36)),
		},
		glitch = false,
	},
	vip = {
		accent = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(56, 189, 248)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(125, 211, 252)),
		},
		glitch = false,
	},
	premium = {
		accent = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(34, 211, 238)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(103, 232, 249)),
		},
		glitch = false,
	},
	user = {
		accent = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 180, 110)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 255, 200)),
		},
		glitch = false,
	},
}

local function spawnParticles(Tag, tagFrame, rank)
	local c1 = rank.accent.Keypoints[1].Value
	local c2 = rank.accent.Keypoints[#rank.accent.Keypoints].Value
	for _ = 1, 6 do
		task.spawn(function()
			task.wait(math.random() * 1.2)
			while Tag and Tag.Parent do
				local sz = math.random(4, 9)
				local p = Instance.new("Frame")
				p.Size = UDim2.new(0, sz, 0, sz)
				p.Position = UDim2.new(math.random() * 0.75 + 0.1, 0, math.random() * 0.3 + 0.65, 0)
				p.BackgroundColor3 = math.random() > 0.5 and c1 or c2
				p.BackgroundTransparency = 0
				p.BorderSizePixel = 0
				p.ZIndex = 10
				p.Parent = Tag
				Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)
				local g = Instance.new("UIGradient", p)
				g.Color = rank.accent
				g.Rotation = math.random(0, 360)

				local dur = math.random(9, 18) / 10
				local drift = (math.random() - 0.5) * 0.35
				TweenService:Create(p, TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Position = UDim2.new(p.Position.X.Scale + drift, 0, -0.55, 0),
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 0, 0, 0),
				}):Play()

				task.wait(dur)
				if p and p.Parent then p:Destroy() end
				task.wait(math.random(5, 18) / 100)
			end
		end)
	end
end

local function runGlitch(label, text)
	local gc = "!@#$%^&*<>?{}~█▓░▒"
	task.spawn(function()
		while label and label.Parent do
			task.wait(2.2 + math.random())
			for _ = 1, 6 do
				if not label.Parent then return end
				local g = ""
				for i = 1, #text do
					g = g .. (math.random() < 0.35 and gc:sub(math.random(1, #gc), math.random(1, #gc)) or text:sub(i, i))
				end
				label.Text = g
				task.wait(0.055)
			end
			label.Text = text
		end
	end)
end

local function runTypewriter(label, text)
	task.spawn(function()
		while label and label.Parent and Active do
			label.Text = "|"
			task.wait(0.3)
			for i = 1, #text do
				if not (label.Parent and Active) then return end
				label.Text = text:sub(1, i) .. "|"
				task.wait(0.11)
			end
			for _ = 1, 3 do
				if not (label.Parent and Active) then return end
				label.Text = text; task.wait(0.4)
				label.Text = text .. "|"; task.wait(0.4)
			end
			for i = #text, 0, -1 do
				if not (label.Parent and Active) then return end
				label.Text = text:sub(1, i) .. "|"
				task.wait(0.065)
			end
			label.Text = ""; task.wait(0.35)
		end
	end)
end

function Nametags.Create(player, tagInfo)
	if not (player.Character and player.Character:FindFirstChild("Head")) then return end
	local Head = player.Character.Head
	if Head:FindFirstChild("LunarTag") then Head.LunarTag:Destroy() end

	tagInfo = tagInfo or {}
	local preset = ROLE_PRESETS[tagInfo.role] or ROLE_PRESETS.user
	local rank = {
		label = tagInfo.label or "LUNAR USER",
		color = hexColor(tagInfo.color),
		accent = preset.accent,
		glitch = preset.glitch,
	}

	local TS = game:GetService("TextService")
	local textW = TS:GetTextSize(rank.label, 13, Enum.Font.GothamBold, Vector2.new(300, 54)).X
	local tagW = math.clamp(textW + 44 + 28, 120, 230)

	local Tag = Instance.new("BillboardGui")
	Tag.Name = "LunarTag"
	Tag.Size = UDim2.new(0, tagW, 0, 54)
	Tag.StudsOffset = Vector3.new(0, 3.5, 0)
	Tag.AlwaysOnTop = false
	Tag.MaxDistance = 150
	Tag:SetAttribute("role", tagInfo.role)
	Tag.Parent = Head

	local TagFrame = Instance.new("Frame", Tag)
	TagFrame.Name = "TagContainer"
	TagFrame.Size = UDim2.new(1, 0, 1, 0)
	TagFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 13)
	TagFrame.BackgroundTransparency = 0.08
	TagFrame.BorderSizePixel = 0
	TagFrame.ZIndex = 2
	Instance.new("UICorner", TagFrame).CornerRadius = UDim.new(0, 10)
	local TagStroke = Instance.new("UIStroke", TagFrame)
	TagStroke.Color = rank.accent.Keypoints[1].Value
	TagStroke.Transparency = 0.5
	TagStroke.Thickness = 1

	local Glow = Instance.new("ImageLabel", TagFrame)
	Glow.Size = UDim2.new(1.2, 0, 1.6, 0)
	Glow.Position = UDim2.new(-0.1, 0, -0.3, 0)
	Glow.BackgroundTransparency = 1
	Glow.Image = "rbxassetid://6015538162"
	Glow.ImageColor3 = rank.accent.Keypoints[1].Value
	Glow.ImageTransparency = 0.88
	Glow.ZIndex = 2

	local TagLogo = Instance.new("ImageLabel", TagFrame)
	TagLogo.Size = UDim2.new(0, 32, 0, 32)
	TagLogo.Position = UDim2.new(0, 8, 0.5, -16)
	TagLogo.BackgroundTransparency = 1
	TagLogo.Image = LogoID
	TagLogo.ScaleType = Enum.ScaleType.Fit
	TagLogo.ImageTransparency = 0
	TagLogo.ZIndex = 5

	local TagText = Instance.new("TextLabel", TagFrame)
	TagText.Size = UDim2.new(1, -48, 0, 22)
	TagText.Position = UDim2.new(0, 44, 0, 8)
	TagText.BackgroundTransparency = 1
	TagText.Text = rank.label
	TagText.TextColor3 = rank.color
	TagText.FontFace = GetFont()
	TagText.TextSize = 13
	TagText.TextXAlignment = Enum.TextXAlignment.Left
	TagText.TextTruncate = Enum.TextTruncate.AtEnd
	TagText.ZIndex = 4

	local SubText = Instance.new("TextLabel", TagFrame)
	SubText.Size = UDim2.new(1, -48, 0, 14)
	SubText.Position = UDim2.new(0, 44, 1, -20)
	SubText.BackgroundTransparency = 1
	SubText.Text = "@" .. player.Name
	SubText.TextColor3 = Color3.fromRGB(140, 140, 140)
	SubText.FontFace = GetFontSub()
	SubText.TextSize = 10
	SubText.TextXAlignment = Enum.TextXAlignment.Left
	SubText.TextTruncate = Enum.TextTruncate.AtEnd
	SubText.ZIndex = 4

	spawnParticles(Tag, TagFrame, rank)

	if rank.glitch then
		runGlitch(TagText, rank.label)
	else
		runTypewriter(TagText, rank.label)
	end

	task.spawn(function()
		while Tag.Parent do
			TweenService:Create(Glow, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {ImageTransparency = 0.72}):Play()
			task.wait(1.8)
			TweenService:Create(Glow, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {ImageTransparency = 0.92}):Play()
			task.wait(1.8)
		end
	end)

	if player ~= Players.LocalPlayer then
		local Ind = Instance.new("BillboardGui")
		Ind.Name = "LunarIndicator"
		Ind.StudsOffset = Vector3.new(0, 7, 0)
		Ind.AlwaysOnTop = true
		Ind.MaxDistance = math.huge
		Ind.LightInfluence = 0
		Ind.ResetOnSpawn = false
		Ind.Active = true
		Ind.Enabled = false
		Ind.Parent = Head

		local IndBtn = Instance.new("ImageButton", Ind)
		IndBtn.Size = UDim2.new(1, 0, 1, 0)
		IndBtn.BackgroundColor3 = rank.accent.Keypoints[1].Value
		IndBtn.BackgroundTransparency = 0.1
		IndBtn.Image = LogoID
		IndBtn.ImageTransparency = 0.15
		IndBtn.ScaleType = Enum.ScaleType.Fit
		IndBtn.AutoButtonColor = false
		Instance.new("UICorner", IndBtn).CornerRadius = UDim.new(1, 0)
		local IndGrad = Instance.new("UIGradient", IndBtn)
		IndGrad.Color = rank.accent
		IndGrad.Rotation = 135

		IndBtn.MouseButton1Click:Connect(function()
			local myHrp = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			local theirHrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			if myHrp and theirHrp then
				myHrp.CFrame = theirHrp.CFrame + Vector3.new(3, 0, 3)
			end
		end)

		local cam = workspace.CurrentCamera
		local rConn = RunService.RenderStepped:Connect(function()
			if not Head.Parent then rConn:Disconnect() return end
			local dist = (cam.CFrame.Position - Head.Position).Magnitude
			local show = dist > 300
			if Ind.Enabled ~= show then Ind.Enabled = show end
			if show then
				local fov = math.rad(cam.FieldOfView)
				local studsPerPixel = 2 * dist * math.tan(fov * 0.5) / cam.ViewportSize.Y
				local sz = math.clamp(46 * studsPerPixel, 0.3, 8)
				Ind.Size = UDim2.new(sz, 0, sz, 0)
			end
		end)

		Tag.AncestryChanged:Connect(function()
			if not Tag.Parent then rConn:Disconnect() end
		end)
	end
end

function Nametags.Unload()
	Active = false
	for _, v in pairs(Connections) do v:Disconnect() end
	for _, p in pairs(Players:GetPlayers()) do
		if p.Character and p.Character:FindFirstChild("Head") and p.Character.Head:FindFirstChild("LunarTag") then
			p.Character.Head.LunarTag:Destroy()
		end
	end
end

function Nametags.Init()
	Active = true

	local currentTags = {}

	local function refresh()
		local Net = getgenv().LunarNet
		if not Net then return end

		local ids = {}
		for _, p in ipairs(Players:GetPlayers()) do
			table.insert(ids, tostring(p.UserId))
		end
		local ok, tags = pcall(Net.nametags, ids)
		if not ok then return end
		currentTags = tags or {}

		for _, p in ipairs(Players:GetPlayers()) do
			local info = currentTags[tostring(p.UserId)]
			local head = p.Character and p.Character:FindFirstChild("Head")
			if not head then continue end
			local existing = head:FindFirstChild("LunarTag")
			if info then
				if not existing or existing:GetAttribute("role") ~= info.role then
					Nametags.Create(p, info)
				end
			elseif existing then
				existing:Destroy()
			end
		end
	end

	task.spawn(function()
		while Active do
			refresh()
			task.wait(6)
		end
	end)
end

return Nametags
