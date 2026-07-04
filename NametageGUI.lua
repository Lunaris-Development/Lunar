local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local GAMEPASS_ID = 9339207514
local lp = Players.LocalPlayer

local LogoID = "rbxthumb://type=Asset&id=73819038719454&w=420&h=420"

local NametageGUI = {}

local Config = {
	text          = "LUNAR USER",
	font          = Enum.Font.GothamBold,
	effect        = "Typewriter",
	decalId       = "",
	bgColor       = Color3.fromRGB(10, 10, 10),
	bgTransparency = 0.2,
	textColor     = Color3.fromRGB(150, 255, 150),
	textSize      = 14,
}

local function safeEnum(name)
	local ok, v = pcall(function() return Enum.Font[name] end)
	return ok and v or nil
end

local _fontDefs = {
	{"Gotham Bold",        "GothamBold"},
	{"Gotham Semibold",    "GothamSemibold"},
	{"Gotham Medium",      "GothamMedium"},
	{"Gotham",             "Gotham"},
	{"Gotham Black",       "GothamBlack"},
	{"Source Sans Bold",   "SourceSansBold"},
	{"Source Sans",        "SourceSans"},
	{"Source Sans Light",  "SourceSansLight"},
	{"Roboto",             "Roboto"},
	{"Roboto Condensed",   "RobotoCondensed"},
	{"Roboto Mono",        "RobotoMono"},
	{"Arial Bold",         "ArialBold"},
	{"Arial",              "Arial"},
	{"Code",               "Code"},
	{"Cartoon",            "Cartoon"},
	{"Fantasy",            "Fantasy"},
	{"Arcade",             "Arcade"},
	{"Antique",            "Antique"},
	{"Highway",            "Highway"},
	{"SciFi",              "SciFi"},
	{"Bodoni",             "Bodoni"},
	{"Garamond",           "Garamond"},
	{"Indie Flower",       "IndieFlower"},
	{"Fredoka One",        "FredokaOne"},
	{"Grenze Gotisch",     "GrenzeGotisch"},
	{"Jura",               "Jura"},
	{"Kalam",              "Kalam"},
	{"Luckiest Guy",       "LuckiestGuy"},
	{"Merriweather",       "Merriweather"},
	{"Merriweather Light", "MerriweatherLight"},
	{"Michroma",           "Michroma"},
	{"Nunito",             "Nunito"},
	{"Oswald",             "Oswald"},
	{"Patrick Hand",       "PatrickHand"},
	{"Permanent Marker",   "PermanentMarker"},
	{"Sarpanch",           "Sarpanch"},
	{"Special Elite",      "SpecialElite"},
	{"Titillium Web",      "TitilliumWeb"},
	{"Ubuntu",             "Ubuntu"},
	{"Bangers",            "Bangers"},
	{"Denk One",           "DenkOne"},
	{"Fondamento",         "Fondamento"},
}

local Fonts = {}
for _, def in ipairs(_fontDefs) do
	local e = safeEnum(def[2])
	if e then table.insert(Fonts, {n = def[1], e = e}) end
end

local Effects = {"None", "Typewriter", "Glitch"}

local ClickSound = Instance.new("Sound")
ClickSound.SoundId = "rbxassetid://7545317681"
ClickSound.Volume = 0.18
ClickSound.Parent = game:GetService("CoreGui")
local function Click() pcall(function() ClickSound:Play() end) end

local function SaveConfig()
	local Net = getgenv().LunarNet
	if not Net then return end
	task.spawn(function()
		pcall(function()
			local serverCfg = Net.get("/config?userId=" .. Net.Identity.userId)
			local full = (serverCfg and serverCfg.config) or {}
			full.nametag = {
				text   = Config.text,
				font   = tostring(Config.font),
				effect = Config.effect,
				decalId = Config.decalId,
				bgR = math.floor(Config.bgColor.R * 255),
				bgG = math.floor(Config.bgColor.G * 255),
				bgB = math.floor(Config.bgColor.B * 255),
				bgT = Config.bgTransparency,
				ts  = Config.textSize,
				tcR = math.floor(Config.textColor.R * 255),
				tcG = math.floor(Config.textColor.G * 255),
				tcB = math.floor(Config.textColor.B * 255),
			}
			Net.saveConfig(full)
		end)
	end)
end

local function LoadConfig()
	local Net = getgenv().LunarNet
	if not Net then return false end
	local ok, result = pcall(function()
		local data, status = Net.get("/config?userId=" .. Net.Identity.userId)
		return status == 200 and data and data.config and data.config.nametag or nil
	end)
	if not ok or not result then return false end
	local d = result
	if d.text   then Config.text   = d.text end
	if d.effect then Config.effect = d.effect end
	if d.decalId then Config.decalId = d.decalId end
	if d.bgR    then Config.bgColor = Color3.fromRGB(d.bgR, d.bgG, d.bgB) end
	if d.bgT    then Config.bgTransparency = d.bgT end
	if d.tcR    then Config.textColor = Color3.fromRGB(d.tcR, d.tcG, d.tcB) end
	if d.ts     then Config.textSize = d.ts end
	if d.font   then
		local name = d.font:match("Font%.(.+)")
		if name then
			local ok2, fe = pcall(function() return Enum.Font[name] end)
			if ok2 and fe then Config.font = fe end
		end
	end
	return true
end

LoadConfig()

local customActive = false
local customCharConn = nil
local guiBuilt = false
local Win = nil

local function ApplyTag(UI)
	if customCharConn then customCharConn:Disconnect() end
	customActive = true
	local function build()
		local char = lp.Character
		if not char or not char:FindFirstChild("Head") then return end
		local Head = char.Head
		if Head:FindFirstChild("LunarTag") then Head.LunarTag:Destroy() end

		local ts = 10
		local rawId = (Config.decalId or ""):match("^%s*(.-)%s*$")
		rawId = rawId:match("%d+") or rawId
		local imgUrl = rawId ~= "" and ("rbxthumb://type=Asset&id=" .. rawId .. "&w=420&h=420") or LogoID

		local displayText = Config.text ~= "" and Config.text or "LUNAR USER"
		local TS = game:GetService("TextService")
		local textW = TS:GetTextSize(displayText, 13, Enum.Font.GothamBold, Vector2.new(300, 54)).X
		local tagW = math.clamp(textW + 44 + 28, 120, 240)

		local Tag = Instance.new("BillboardGui")
		Tag.Name = "LunarTag"
		Tag.Size = UDim2.new(0, tagW, 0, 54)
		Tag.StudsOffset = Vector3.new(0, 3.5, 0)
		Tag.AlwaysOnTop = false
		Tag.MaxDistance = 150
		Tag.Parent = Head

		local TagFrame = Instance.new("Frame", Tag)
		TagFrame.Size = UDim2.new(1, 0, 1, 0)
		TagFrame.BackgroundColor3 = Config.bgColor
		TagFrame.BackgroundTransparency = Config.bgTransparency
		TagFrame.BorderSizePixel = 0
		TagFrame.ZIndex = 2
		Instance.new("UICorner", TagFrame).CornerRadius = UDim.new(0, 10)
		local TagStroke = Instance.new("UIStroke", TagFrame)
		TagStroke.Color = Config.textColor
		TagStroke.Transparency = 0.5
		TagStroke.Thickness = 1

		local Img = Instance.new("ImageLabel", TagFrame)
		Img.Size = UDim2.new(0, 32, 0, 32)
		Img.Position = UDim2.new(0, 8, 0.5, -16)
		Img.BackgroundTransparency = 1
		Img.ScaleType = Enum.ScaleType.Fit
		Img.ZIndex = 3
		Img.Image = imgUrl

		local TL = Instance.new("TextLabel", TagFrame)
		TL.Size = UDim2.new(1, -48, 0, 22)
		TL.Position = UDim2.new(0, 44, 0, 8)
		TL.BackgroundTransparency = 1
		TL.Text = Config.text
		TL.TextColor3 = Config.textColor
		TL.FontFace = Font.fromEnum(Config.font)
		TL.TextSize = 13
		TL.TextXAlignment = Enum.TextXAlignment.Left
		TL.TextTruncate = Enum.TextTruncate.AtEnd
		TL.ZIndex = 3

		local SL = Instance.new("TextLabel", TagFrame)
		SL.Size = UDim2.new(1, -48, 0, 14)
		SL.Position = UDim2.new(0, 44, 1, -20)
		SL.BackgroundTransparency = 1
		SL.Text = "@" .. lp.Name
		SL.TextColor3 = Color3.fromRGB(170, 170, 170)
		SL.FontFace = Font.fromEnum(Config.font)
		SL.TextSize = 10
		SL.TextXAlignment = Enum.TextXAlignment.Left
		SL.ZIndex = 3

		if Config.effect == "Typewriter" then
			task.spawn(function()
				task.wait(1)
				while Tag.Parent do
					for i = #Config.text, 0, -1 do
						if not Tag.Parent then return end
						TL.Text = Config.text:sub(1, i); task.wait(0.06)
					end
					task.wait(0.25)
					for i = 1, #Config.text do
						if not Tag.Parent then return end
						TL.Text = Config.text:sub(1, i); task.wait(0.1)
					end
					task.wait(2.5)
				end
			end)
		elseif Config.effect == "Glitch" then
			local gc = "!@#$%^&*<>?{}~█▓░"
			task.spawn(function()
				while Tag.Parent do
					task.wait(2.5 + math.random())
					for _ = 1, 6 do
						if not Tag.Parent then return end
						local g = ""
						for i = 1, #Config.text do
							g = g .. (math.random() < 0.35 and gc:sub(math.random(1,#gc),math.random(1,#gc)) or Config.text:sub(i,i))
						end
						TL.Text = g; task.wait(0.055)
					end
					TL.Text = Config.text
				end
			end)
		end

		local c1 = Config.textColor
		local c2 = Config.bgColor
		for _ = 1, 5 do
			task.spawn(function()
				task.wait(math.random() * 1.2)
				while Tag and Tag.Parent do
					local sz = math.random(3, 8)
					local p = Instance.new("Frame", Tag)
					p.Size = UDim2.new(0, sz, 0, sz)
					p.Position = UDim2.new(math.random() * 0.75 + 0.1, 0, math.random() * 0.3 + 0.65, 0)
					p.BackgroundColor3 = math.random() > 0.5 and c1 or Color3.fromRGB(255, 255, 255)
					p.BackgroundTransparency = 0
					p.BorderSizePixel = 0
					p.ZIndex = 10
					Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)
					local dur = math.random(9, 18) / 10
					TweenService:Create(p, TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Position = UDim2.new(p.Position.X.Scale + (math.random()-0.5)*0.35, 0, -0.55, 0),
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
	build()
	customCharConn = lp.CharacterAdded:Connect(function()
		task.wait(1)
		if customActive then build() end
	end)
	SaveConfig()
	if UI then UI.Notify("Nametag applied!", "Success") end
end

local function BuildGUI(UI)
	if guiBuilt and Win and Win.Parent then
		Click()
		Win.Visible = not Win.Visible
		return
	end

	if game.CoreGui:FindFirstChild("LunarNametage") then
		game.CoreGui.LunarNametage:Destroy()
	end
	local SG = Instance.new("ScreenGui")
	SG.Name = "LunarNametage"
	SG.ResetOnSpawn = false
	SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	SG.Parent = game.CoreGui

	local W, H = 500, 480

	Win = Instance.new("TextButton")
	Win.Size = UDim2.new(0, W, 0, H)
	Win.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
	Win.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
	Win.BackgroundTransparency = 0.04
	Win.BorderSizePixel = 0
	Win.ZIndex = 30
	Win.Text = ""
	Win.AutoButtonColor = false
	Win.SelectionImageObject = Instance.new("Frame")
	Win.Parent = SG
	Instance.new("UICorner", Win).CornerRadius = UDim.new(0, 14)
	local WStroke = Instance.new("UIStroke", Win)
	WStroke.Color = Color3.fromRGB(255,255,255); WStroke.Transparency = 0.87; WStroke.Thickness = 1

	local TBar = Instance.new("Frame", Win)
	TBar.Size = UDim2.new(1,0,0,40); TBar.BackgroundColor3 = Color3.fromRGB(24,24,24)
	TBar.BackgroundTransparency = 0; TBar.BorderSizePixel = 0; TBar.ZIndex = 31
	Instance.new("UICorner", TBar).CornerRadius = UDim.new(0,14)
	local TBarFill = Instance.new("Frame", TBar)
	TBarFill.Size = UDim2.new(1,0,0,14); TBarFill.Position = UDim2.new(0,0,1,-14)
	TBarFill.BackgroundColor3 = Color3.fromRGB(24,24,24); TBarFill.BorderSizePixel = 0
	local TBarLine = Instance.new("Frame", Win)
	TBarLine.Size = UDim2.new(1,-24,0,1); TBarLine.Position = UDim2.new(0,12,0,40)
	TBarLine.BackgroundColor3 = Color3.fromRGB(255,255,255)
	TBarLine.BackgroundTransparency = 0.9; TBarLine.BorderSizePixel = 0; TBarLine.ZIndex = 31

	local TitleLbl = Instance.new("TextLabel", TBar)
	TitleLbl.Size = UDim2.new(1,-90,1,0); TitleLbl.Position = UDim2.new(0,16,0,0)
	TitleLbl.BackgroundTransparency = 1; TitleLbl.Text = "Nametag Customizer"
	TitleLbl.TextColor3 = Color3.fromRGB(220,220,220); TitleLbl.FontFace = Font.fromEnum(Enum.Font.GothamBold)
	TitleLbl.TextSize = 13; TitleLbl.TextXAlignment = Enum.TextXAlignment.Left; TitleLbl.ZIndex = 32

	local PassBadge = Instance.new("TextLabel", TBar)
	PassBadge.Size = UDim2.new(0,72,0,20); PassBadge.Position = UDim2.new(0,188,0.5,-10)
	PassBadge.BackgroundColor3 = Color3.fromRGB(255,200,80); PassBadge.BackgroundTransparency = 0.3
	PassBadge.Text = "GAMEPASS"; PassBadge.TextColor3 = Color3.fromRGB(255,230,150)
	PassBadge.FontFace = Font.fromEnum(Enum.Font.GothamBold); PassBadge.TextSize = 9; PassBadge.ZIndex = 32
	Instance.new("UICorner", PassBadge).CornerRadius = UDim.new(0,5)

	local Lights = Instance.new("Frame", TBar)
	Lights.Size = UDim2.new(0,38,0,14); Lights.Position = UDim2.new(1,-52,0.5,-7)
	Lights.BackgroundTransparency = 1; Lights.ZIndex = 32
	local LL = Instance.new("UIListLayout", Lights)
	LL.FillDirection = Enum.FillDirection.Horizontal
	LL.VerticalAlignment = Enum.VerticalAlignment.Center; LL.Padding = UDim.new(0,8)

	local function MakeLight(col)
		local L = Instance.new("TextButton", Lights)
		L.Size = UDim2.new(0,13,0,13); L.BackgroundColor3 = col; L.Text = ""
		L.AutoButtonColor = false; L.ZIndex = 33
		Instance.new("UICorner", L).CornerRadius = UDim.new(1,0)
		return L
	end
	MakeLight(Color3.fromRGB(255,189,68))
	MakeLight(Color3.fromRGB(255,95,87)).MouseButton1Click:Connect(function() Click(); Win.Visible = false end)

	local dragging, dragStart, startPos = false, nil, nil
	TBar.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true; dragStart = i.Position; startPos = Win.Position
			i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging = false end end)
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local d = i.Position - dragStart
			Win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)

	local CA = Instance.new("Frame", Win)
	CA.Size = UDim2.new(1,0,1,-48); CA.Position = UDim2.new(0,0,0,48)
	CA.BackgroundTransparency = 1; CA.ZIndex = 31

	local leftW, centerW = 155, 195
	local rightW = W - leftW - centerW

	local function Sect(x, w)
		local F = Instance.new("Frame", CA)
		F.Position = UDim2.new(0,x,0,0); F.Size = UDim2.new(0,w,1,0)
		F.BackgroundTransparency = 1; F.ZIndex = 31; return F
	end
	local LeftP   = Sect(0, leftW)
	local CenterP = Sect(leftW, centerW)
	local RightP  = Sect(leftW + centerW, rightW)

	local function VDiv(x)
		local D = Instance.new("Frame", CA)
		D.Size = UDim2.new(0,1,1,-20); D.Position = UDim2.new(0,x,0,10)
		D.BackgroundColor3 = Color3.fromRGB(255,255,255); D.BackgroundTransparency = 0.9
		D.BorderSizePixel = 0; D.ZIndex = 31
	end
	VDiv(leftW); VDiv(leftW + centerW)

	local function SLabel(p, t, y)
		local L = Instance.new("TextLabel", p)
		L.Size = UDim2.new(1,-16,0,14); L.Position = UDim2.new(0,8,0,y)
		L.BackgroundTransparency = 1; L.Text = t
		L.TextColor3 = Color3.fromRGB(85,85,85); L.FontFace = Font.fromEnum(Enum.Font.GothamBold)
		L.TextSize = 9; L.TextXAlignment = Enum.TextXAlignment.Left; L.ZIndex = 32; return L
	end

	local function MakeSlider(parent, y, color, initRatio)
		local Track = Instance.new("Frame", parent)
		Track.Size = UDim2.new(1,-16,0,6); Track.Position = UDim2.new(0,8,0,y+4)
		Track.BackgroundColor3 = Color3.fromRGB(35,35,35); Track.BorderSizePixel = 0; Track.ZIndex = 32
		Instance.new("UICorner", Track).CornerRadius = UDim.new(0,3)
		local Fill = Instance.new("Frame", Track)
		Fill.Size = UDim2.new(initRatio,0,1,0); Fill.BackgroundColor3 = color
		Fill.BorderSizePixel = 0; Fill.ZIndex = 33
		Instance.new("UICorner", Fill).CornerRadius = UDim.new(0,3)
		local Knob = Instance.new("TextButton", Track)
		Knob.Size = UDim2.new(0,14,0,14); Knob.Position = UDim2.new(initRatio,-7,0.5,-7)
		Knob.BackgroundColor3 = Color3.fromRGB(240,240,240); Knob.Text = ""
		Knob.AutoButtonColor = false; Knob.ZIndex = 34; Knob.BorderSizePixel = 0
		Instance.new("UICorner", Knob).CornerRadius = UDim.new(1,0)
		return Track, Fill, Knob
	end

	local function MakePicker(parent, yStart, initColor, onChange)
		local rv = math.floor(initColor.R*255)
		local gv = math.floor(initColor.G*255)
		local bv = math.floor(initColor.B*255)

		local Swatch = Instance.new("Frame", parent)
		Swatch.Size = UDim2.new(1,-16,0,20)
		Swatch.Position = UDim2.new(0,8,0,yStart)
		Swatch.BackgroundColor3 = initColor; Swatch.BorderSizePixel = 0; Swatch.ZIndex = 32
		Instance.new("UICorner", Swatch).CornerRadius = UDim.new(0,6)
		local SwatchStroke = Instance.new("UIStroke", Swatch)
		SwatchStroke.Color = Color3.fromRGB(255,255,255); SwatchStroke.Transparency = 0.85; SwatchStroke.Thickness = 1

		local sliderColors = {Color3.fromRGB(255,80,80), Color3.fromRGB(80,210,80), Color3.fromRGB(80,120,255)}
		local vals = {rv, gv, bv}
		local tracks, fills, knobs = {}, {}, {}
		local activeSlider = nil

		local function refresh()
			local c = Color3.fromRGB(vals[1], vals[2], vals[3])
			Swatch.BackgroundColor3 = c
			onChange(c)
		end

		for i = 1, 3 do
			local rowY = yStart + 26 + (i-1) * 20
			local lbl = Instance.new("TextLabel", parent)
			lbl.Size = UDim2.new(0,10,0,14); lbl.Position = UDim2.new(0,8,0,rowY+2)
			lbl.BackgroundTransparency = 1; lbl.Text = ({"R","G","B"})[i]
			lbl.TextColor3 = sliderColors[i]; lbl.FontFace = Font.fromEnum(Enum.Font.GothamBold)
			lbl.TextSize = 9; lbl.ZIndex = 32

			local valLbl = Instance.new("TextLabel", parent)
			valLbl.Size = UDim2.new(0,24,0,14); valLbl.Position = UDim2.new(1,-30,0,rowY+2)
			valLbl.BackgroundTransparency = 1; valLbl.Text = tostring(vals[i])
			valLbl.TextColor3 = Color3.fromRGB(160,160,160); valLbl.FontFace = Font.fromEnum(Enum.Font.Gotham)
			valLbl.TextSize = 9; valLbl.TextXAlignment = Enum.TextXAlignment.Right; valLbl.ZIndex = 32

			local tr, fi, kn = MakeSlider(parent, rowY, sliderColors[i], vals[i]/255)
			tr.Size = UDim2.new(1,-44,0,6); tr.Position = UDim2.new(0,20,0,rowY+4)

			tracks[i] = tr; fills[i] = fi; knobs[i] = kn

			local idx = i
			kn.MouseButton1Down:Connect(function() activeSlider = idx end)
			kn.InputBegan:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.Touch then activeSlider = idx end
			end)

			local function doUpdate(posX)
				if activeSlider ~= idx then return end
				local r = math.clamp((posX - tr.AbsolutePosition.X) / tr.AbsoluteSize.X, 0, 1)
				vals[idx] = math.floor(r * 255)
				fi.Size = UDim2.new(r,0,1,0); kn.Position = UDim2.new(r,-7,0.5,-7)
				valLbl.Text = tostring(vals[idx])
				refresh()
			end

			UserInputService.InputEnded:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
					if activeSlider == idx then activeSlider = nil end
				end
			end)
			UserInputService.InputChanged:Connect(function(inp)
				if activeSlider == idx and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
					doUpdate(inp.Position.X)
				end
			end)
		end

		return function()
			return Color3.fromRGB(vals[1], vals[2], vals[3])
		end
	end

	SLabel(LeftP, "DECAL ID", 10)
	local DecalBox = Instance.new("TextBox", LeftP)
	DecalBox.Size = UDim2.new(1,-16,0,28); DecalBox.Position = UDim2.new(0,8,0,26)
	DecalBox.BackgroundColor3 = Color3.fromRGB(30,30,30); DecalBox.BackgroundTransparency = 0.2
	DecalBox.Text = Config.decalId; DecalBox.PlaceholderText = "Asset ID..."
	DecalBox.TextColor3 = Color3.fromRGB(220,220,220); DecalBox.PlaceholderColor3 = Color3.fromRGB(70,70,70)
	DecalBox.FontFace = Font.fromEnum(Enum.Font.Gotham); DecalBox.TextSize = 10
	DecalBox.ZIndex = 33; DecalBox.BorderSizePixel = 0
	Instance.new("UICorner", DecalBox).CornerRadius = UDim.new(0,7)
	Instance.new("UIPadding", DecalBox).PaddingLeft = UDim.new(0,8)

	local RefreshPreview  -- forward declaration so color pickers can call it

	SLabel(LeftP, "BACKGROUND", 64)
	local getBGColor = MakePicker(LeftP, 80, Config.bgColor, function(c)
		Config.bgColor = c
		if RefreshPreview then RefreshPreview() end
	end)

	SLabel(LeftP, "OPACITY", 168)
	local BGSliderBack = Instance.new("Frame", LeftP)
	BGSliderBack.Size = UDim2.new(1,-16,0,6); BGSliderBack.Position = UDim2.new(0,8,0,184)
	BGSliderBack.BackgroundColor3 = Color3.fromRGB(35,35,35); BGSliderBack.BorderSizePixel = 0; BGSliderBack.ZIndex = 32
	Instance.new("UICorner", BGSliderBack).CornerRadius = UDim.new(0,3)
	local opacityInit = 1 - Config.bgTransparency
	local BGFill = Instance.new("Frame", BGSliderBack)
	BGFill.Size = UDim2.new(opacityInit,0,1,0); BGFill.BackgroundColor3 = Color3.fromRGB(100,180,255)
	BGFill.BorderSizePixel = 0; BGFill.ZIndex = 33
	Instance.new("UICorner", BGFill).CornerRadius = UDim.new(0,3)
	local BGKnob = Instance.new("TextButton", BGSliderBack)
	BGKnob.Size = UDim2.new(0,14,0,14); BGKnob.Position = UDim2.new(opacityInit,-7,0.5,-7)
	BGKnob.BackgroundColor3 = Color3.fromRGB(240,240,240); BGKnob.Text = ""
	BGKnob.AutoButtonColor = false; BGKnob.ZIndex = 34; BGKnob.BorderSizePixel = 0
	Instance.new("UICorner", BGKnob).CornerRadius = UDim.new(1,0)
	local bgSliding = false
	BGKnob.MouseButton1Down:Connect(function() bgSliding = true end)
	BGKnob.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch then bgSliding = true end end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then bgSliding = false end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if bgSliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local r = math.clamp((i.Position.X - BGSliderBack.AbsolutePosition.X) / BGSliderBack.AbsoluteSize.X, 0, 1)
			BGFill.Size = UDim2.new(r,0,1,0); BGKnob.Position = UDim2.new(r,-7,0.5,-7)
			Config.bgTransparency = 1 - r
			if RefreshPreview then RefreshPreview() end
		end
	end)

	SLabel(LeftP, "TEXT COLOR", 202)
	local getTCColor = MakePicker(LeftP, 218, Config.textColor, function(c)
		Config.textColor = c
		if RefreshPreview then RefreshPreview() end
	end)

	SLabel(CenterP, "PREVIEW", 10)
	local PreviewContainer = Instance.new("Frame", CenterP)
	PreviewContainer.Size = UDim2.new(1,-20,0,72); PreviewContainer.Position = UDim2.new(0,10,0,28)
	PreviewContainer.BackgroundColor3 = Color3.fromRGB(22,22,22)
	PreviewContainer.BackgroundTransparency = 0.4; PreviewContainer.BorderSizePixel = 0; PreviewContainer.ZIndex = 32
	Instance.new("UICorner", PreviewContainer).CornerRadius = UDim.new(0,10)

	local PBorder = Instance.new("Frame", PreviewContainer)
	PBorder.Size = UDim2.new(0,190,0,50); PBorder.AnchorPoint = Vector2.new(0.5,0.5)
	PBorder.Position = UDim2.new(0.5,0,0.5,0); PBorder.BackgroundColor3 = Config.textColor
	PBorder.BorderSizePixel = 0; PBorder.ZIndex = 33
	Instance.new("UICorner", PBorder).CornerRadius = UDim.new(0,14)

	local PTagFrame = Instance.new("Frame", PreviewContainer)
	PTagFrame.Size = UDim2.new(0,188,0,48); PTagFrame.AnchorPoint = Vector2.new(0.5,0.5)
	PTagFrame.Position = UDim2.new(0.5,0,0.5,0)
	PTagFrame.BackgroundColor3 = Config.bgColor; PTagFrame.BackgroundTransparency = Config.bgTransparency
	PTagFrame.BorderSizePixel = 0; PTagFrame.ZIndex = 34
	Instance.new("UICorner", PTagFrame).CornerRadius = UDim.new(0,13)

	local PImg = Instance.new("ImageLabel", PTagFrame)
	PImg.Size = UDim2.new(0,26,0,26); PImg.Position = UDim2.new(0,8,0.5,-13)
	PImg.BackgroundTransparency = 1; PImg.ScaleType = Enum.ScaleType.Fit; PImg.ZIndex = 35
	PImg.Image = ((Config.decalId or ""):match("%d+") or "") ~= "" and ("rbxthumb://type=Asset&id="..(Config.decalId:match("%d+") or "").."&w=420&h=420") or LogoID

	local PTL = Instance.new("TextLabel", PTagFrame)
	PTL.Size = UDim2.new(1,-42,0,22); PTL.Position = UDim2.new(0,38,0,8)
	PTL.BackgroundTransparency = 1; PTL.Text = Config.text ~= "" and Config.text or "LUNAR USER"
	PTL.TextColor3 = Config.textColor; PTL.FontFace = Font.fromEnum(Config.font)
	PTL.TextSize = 13; PTL.TextXAlignment = Enum.TextXAlignment.Left; PTL.ZIndex = 35
	PTL.TextTruncate = Enum.TextTruncate.AtEnd

	local PSL = Instance.new("TextLabel", PTagFrame)
	PSL.Size = UDim2.new(1,-42,0.5,0); PSL.Position = UDim2.new(0,38,0.5,-2)
	PSL.BackgroundTransparency = 1; PSL.Text = "@"..lp.Name
	PSL.TextColor3 = Color3.fromRGB(160,160,160); PSL.FontFace = Font.fromEnum(Enum.Font.Gotham)
	PSL.TextSize = 8; PSL.TextXAlignment = Enum.TextXAlignment.Left; PSL.ZIndex = 35

	RefreshPreview = function()
		local bc = getBGColor()
		local tc = getTCColor()
		PTagFrame.BackgroundColor3 = bc
		PTagFrame.BackgroundTransparency = Config.bgTransparency
		PBorder.BackgroundColor3 = tc
		PTL.TextColor3 = tc
		PTL.FontFace = Font.fromEnum(Config.font)
		PTL.Text = Config.text ~= "" and Config.text or "LUNAR USER"
		PImg.Image = ((Config.decalId or ""):match("%d+") or "") ~= "" and ("rbxthumb://type=Asset&id="..(Config.decalId:match("%d+") or "").."&w=420&h=420") or LogoID
	end

	task.spawn(function()
		while Win and Win.Parent do
			local t = Config.text ~= "" and Config.text or "LUNAR USER"
			if Config.effect == "Typewriter" then
				PTL.Text = "|"; task.wait(0.3)
				for i = 1, #t do
					if not (Win and Win.Parent) then return end
					PTL.Text = t:sub(1,i) .. "|"; task.wait(0.09)
				end
				for _ = 1, 3 do
					if not (Win and Win.Parent) then return end
					PTL.Text = t; task.wait(0.4)
					PTL.Text = t .. "|"; task.wait(0.4)
				end
				for i = #t, 0, -1 do
					if not (Win and Win.Parent) then return end
					PTL.Text = t:sub(1,i) .. "|"; task.wait(0.055)
				end
				PTL.Text = ""; task.wait(0.3)
			elseif Config.effect == "Glitch" then
				local gc = "!@#$%^&*<>?{}~█"
				for _ = 1, 5 do
					if not (Win and Win.Parent) then return end
					local g = ""
					for i = 1, #t do
						g = g .. (math.random()<0.35 and gc:sub(math.random(1,#gc),math.random(1,#gc)) or t:sub(i,i))
					end
					PTL.Text = g; task.wait(0.07)
				end
				PTL.Text = t; task.wait(2.5 + math.random())
			else
				PTL.Text = t; task.wait(0.5)
			end
		end
	end)

	UserInputService.InputChanged:Connect(function(i)
		if bgSliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			RefreshPreview()
		end
	end)

	SLabel(CenterP, "YOUR TEXT", 110)
	local TextInput = Instance.new("TextBox", CenterP)
	TextInput.Size = UDim2.new(1,-20,0,30); TextInput.Position = UDim2.new(0,10,0,126)
	TextInput.BackgroundColor3 = Color3.fromRGB(30,30,30); TextInput.BackgroundTransparency = 0.2
	TextInput.Text = Config.text; TextInput.PlaceholderText = "Nametag text..."
	TextInput.TextColor3 = Color3.fromRGB(220,220,220); TextInput.PlaceholderColor3 = Color3.fromRGB(70,70,70)
	TextInput.FontFace = Font.fromEnum(Enum.Font.Gotham); TextInput.TextSize = 11
	TextInput.ZIndex = 33; TextInput.BorderSizePixel = 0
	Instance.new("UICorner", TextInput).CornerRadius = UDim.new(0,8)
	Instance.new("UIPadding", TextInput).PaddingLeft = UDim.new(0,10)

	local EffectBadge = Instance.new("TextLabel", CenterP)
	EffectBadge.Size = UDim2.new(1,-20,0,18); EffectBadge.Position = UDim2.new(0,10,0,164)
	EffectBadge.BackgroundTransparency = 1; EffectBadge.Text = "Effect: "..Config.effect
	EffectBadge.TextColor3 = Color3.fromRGB(100,180,255); EffectBadge.FontFace = Font.fromEnum(Enum.Font.Gotham)
	EffectBadge.TextSize = 10; EffectBadge.TextXAlignment = Enum.TextXAlignment.Center; EffectBadge.ZIndex = 32

	local ApplyBtn = Instance.new("TextButton", CenterP)
	ApplyBtn.Size = UDim2.new(1,-20,0,38); ApplyBtn.Position = UDim2.new(0,10,1,-50)
	ApplyBtn.BackgroundColor3 = Color3.fromRGB(0,200,120); ApplyBtn.BackgroundTransparency = 0.2
	ApplyBtn.Text = "Apply Nametag"; ApplyBtn.TextColor3 = Color3.fromRGB(255,255,255)
	ApplyBtn.FontFace = Font.fromEnum(Enum.Font.GothamBold); ApplyBtn.TextSize = 13
	ApplyBtn.AutoButtonColor = false; ApplyBtn.ZIndex = 33
	Instance.new("UICorner", ApplyBtn).CornerRadius = UDim.new(0,10)
	ApplyBtn.MouseEnter:Connect(function() TweenService:Create(ApplyBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play() end)
	ApplyBtn.MouseLeave:Connect(function() TweenService:Create(ApplyBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.2}):Play() end)
	ApplyBtn.MouseButton1Click:Connect(function()
		Click()
		Config.bgColor = getBGColor()
		Config.textColor = getTCColor()
		ApplyTag(UI)
	end)

	TextInput:GetPropertyChangedSignal("Text"):Connect(function()
		Config.text = TextInput.Text; RefreshPreview()
	end)
	DecalBox:GetPropertyChangedSignal("Text"):Connect(function()
		Config.decalId = DecalBox.Text; RefreshPreview()
	end)


	SLabel(RightP, "FONT", 10)
	local FontScroll = Instance.new("ScrollingFrame", RightP)
	FontScroll.Size = UDim2.new(1,-8,0,258); FontScroll.Position = UDim2.new(0,4,0,28)
	FontScroll.BackgroundTransparency = 1; FontScroll.BorderSizePixel = 0
	FontScroll.CanvasSize = UDim2.new(0,0,0,0); FontScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	FontScroll.ScrollBarThickness = 2; FontScroll.ScrollBarImageColor3 = Color3.fromRGB(80,80,80); FontScroll.ZIndex = 32
	Instance.new("UIListLayout", FontScroll).Padding = UDim.new(0,3)

	local selFontBtn = nil
	for _, f in ipairs(Fonts) do
		local FB = Instance.new("TextButton", FontScroll)
		FB.Size = UDim2.new(1,0,0,26); FB.BackgroundColor3 = Color3.fromRGB(255,255,255)
		FB.BackgroundTransparency = 0.94; FB.Text = f.n
		FB.TextColor3 = Color3.fromRGB(175,175,175); FB.FontFace = Font.fromEnum(f.e)
		FB.TextSize = 11; FB.AutoButtonColor = false; FB.ZIndex = 33
		Instance.new("UICorner", FB).CornerRadius = UDim.new(0,7)
		if f.e == Config.font then
			FB.BackgroundTransparency = 0.82; FB.TextColor3 = Color3.fromRGB(255,255,255); selFontBtn = FB
		end
		FB.MouseButton1Click:Connect(function()
			Click()
			Config.font = f.e
			if selFontBtn then TweenService:Create(selFontBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.94, TextColor3 = Color3.fromRGB(175,175,175)}):Play() end
			selFontBtn = FB
			TweenService:Create(FB, TweenInfo.new(0.15), {BackgroundTransparency = 0.82, TextColor3 = Color3.fromRGB(255,255,255)}):Play()
			RefreshPreview()
		end)
		FB.MouseEnter:Connect(function() if FB ~= selFontBtn then TweenService:Create(FB, TweenInfo.new(0.12), {BackgroundTransparency = 0.87}):Play() end end)
		FB.MouseLeave:Connect(function() if FB ~= selFontBtn then TweenService:Create(FB, TweenInfo.new(0.12), {BackgroundTransparency = 0.94}):Play() end end)
	end

	SLabel(RightP, "EFFECT", 298)
	local EffectFrame = Instance.new("Frame", RightP)
	EffectFrame.Size = UDim2.new(1,-8,0,106); EffectFrame.Position = UDim2.new(0,4,0,316)
	EffectFrame.BackgroundTransparency = 1; EffectFrame.ZIndex = 32
	Instance.new("UIListLayout", EffectFrame).Padding = UDim.new(0,4)

	local selEffBtn = nil
	for _, ef in ipairs(Effects) do
		local EB = Instance.new("TextButton", EffectFrame)
		EB.Size = UDim2.new(1,0,0,28); EB.BackgroundColor3 = Color3.fromRGB(255,255,255)
		EB.BackgroundTransparency = 0.94; EB.Text = ef
		EB.TextColor3 = Color3.fromRGB(175,175,175); EB.FontFace = Font.fromEnum(Enum.Font.Gotham)
		EB.TextSize = 11; EB.AutoButtonColor = false; EB.ZIndex = 33
		Instance.new("UICorner", EB).CornerRadius = UDim.new(0,7)
		if ef == Config.effect then
			EB.BackgroundTransparency = 0.82; EB.TextColor3 = Color3.fromRGB(100,180,255); selEffBtn = EB
		end
		EB.MouseButton1Click:Connect(function()
			Click()
			Config.effect = ef; EffectBadge.Text = "Effect: "..ef
			if selEffBtn then TweenService:Create(selEffBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.94, TextColor3 = Color3.fromRGB(175,175,175)}):Play() end
			selEffBtn = EB
			TweenService:Create(EB, TweenInfo.new(0.15), {BackgroundTransparency = 0.82, TextColor3 = Color3.fromRGB(100,180,255)}):Play()
		end)
		EB.MouseEnter:Connect(function() if EB ~= selEffBtn then TweenService:Create(EB, TweenInfo.new(0.12), {BackgroundTransparency = 0.87}):Play() end end)
		EB.MouseLeave:Connect(function() if EB ~= selEffBtn then TweenService:Create(EB, TweenInfo.new(0.12), {BackgroundTransparency = 0.94}):Play() end end)
	end

	guiBuilt = true
end

function NametageGUI.HandleChat(msg, UI)
	local cmd = msg:lower():split(" ")[1]
	if cmd ~= "nametag" then return end

	local Net = getgenv().LunarNet
	local staffRoles = { owner = true, dev = true, admin = true }
	local hasAccess = Net and staffRoles[Net.Role] or false
	if not hasAccess then
		local ok, owns = pcall(function()
			return MarketplaceService:UserOwnsGamePassAsync(lp.UserId, GAMEPASS_ID)
		end)
		hasAccess = ok and owns
	end

	if not hasAccess then
		if UI then UI.Notify("Nametag requires the Gamepass!", "Error") end
		task.spawn(function()
			pcall(function() MarketplaceService:PromptGamePassPurchase(lp, GAMEPASS_ID) end)
		end)
		return
	end

	BuildGUI(UI)
	if Win then Win.Visible = true end
end

task.spawn(function()
	task.wait(2)
	if LoadConfig() then
		ApplyTag(nil)
		lp.CharacterAdded:Connect(function()
			task.wait(1.5)
			ApplyTag(nil)
		end)
	end
end)

return NametageGUI
