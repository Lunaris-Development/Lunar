local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local Executor = (identifyexecutor and identifyexecutor()) or (getexecutorname and getexecutorname()) or "Unknown"

local LogoID = "rbxthumb://type=Asset&id=73819038719454&w=420&h=420"

local function GetFont() return Font.fromEnum(Enum.Font.GothamBold) end
local function GetFontBold() return Font.fromEnum(Enum.Font.GothamBold) end

local UI = {}

function UI.Init(Nametags, Commands, ESP, Rizzlines, Animations, ProperFling)
	local isMobile = UserInputService.TouchEnabled

	if game.CoreGui:FindFirstChild("LunarDynamicIsland") then
		game.CoreGui:FindFirstChild("LunarDynamicIsland"):Destroy()
	end

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "LunarDynamicIsland"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.Parent = game.CoreGui

	local function CreateWindow(title, w, contentH)
		local Win = Instance.new("TextButton")
		Win.Size = UDim2.new(0, w, 0, contentH + 40)
		Win.Position = UDim2.new(0.5, -w / 2, 0, 80)
		Win.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		Win.BackgroundTransparency = 0.04
		Win.BorderSizePixel = 0
		Win.Visible = false
		Win.ZIndex = 20
		Win.Text = ""
		Win.AutoButtonColor = false
		Win.SelectionImageObject = Instance.new("Frame")
		Win.Parent = ScreenGui
		Instance.new("UICorner", Win).CornerRadius = UDim.new(0, 12)
		local WinStroke = Instance.new("UIStroke", Win)
		WinStroke.Color = Color3.fromRGB(255, 255, 255)
		WinStroke.Transparency = 0.87
		WinStroke.Thickness = 1

		local TBar = Instance.new("Frame", Win)
		TBar.Size = UDim2.new(1, 0, 0, 40)
		TBar.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
		TBar.BackgroundTransparency = 0
		TBar.BorderSizePixel = 0
		TBar.ZIndex = 21
		Instance.new("UICorner", TBar).CornerRadius = UDim.new(0, 12)
		local TBarFill = Instance.new("Frame", TBar)
		TBarFill.Size = UDim2.new(1, 0, 0, 12)
		TBarFill.Position = UDim2.new(0, 0, 1, -12)
		TBarFill.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
		TBarFill.BorderSizePixel = 0

		local TBarLine = Instance.new("Frame", Win)
		TBarLine.Size = UDim2.new(1, -24, 0, 1)
		TBarLine.Position = UDim2.new(0, 12, 0, 40)
		TBarLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TBarLine.BackgroundTransparency = 0.9
		TBarLine.BorderSizePixel = 0
		TBarLine.ZIndex = 21

		local TitleLbl = Instance.new("TextLabel", TBar)
		TitleLbl.Size = UDim2.new(1, -80, 1, 0)
		TitleLbl.Position = UDim2.new(0, 14, 0, 0)
		TitleLbl.BackgroundTransparency = 1
		TitleLbl.Text = title
		TitleLbl.TextColor3 = Color3.fromRGB(210, 210, 210)
		TitleLbl.FontFace = GetFontBold()
		TitleLbl.TextSize = 12
		TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
		TitleLbl.ZIndex = 22

		local Lights = Instance.new("Frame", TBar)
		Lights.Size = UDim2.new(0, 38, 0, 14)
		Lights.Position = UDim2.new(1, -50, 0.5, -7)
		Lights.BackgroundTransparency = 1
		Lights.ZIndex = 22
		local LL = Instance.new("UIListLayout", Lights)
		LL.FillDirection = Enum.FillDirection.Horizontal
		LL.VerticalAlignment = Enum.VerticalAlignment.Center
		LL.Padding = UDim.new(0, 8)

		local function MakeLight(color)
			local L = Instance.new("TextButton", Lights)
			L.Size = UDim2.new(0, 13, 0, 13)
			L.BackgroundColor3 = color
			L.Text = ""
			L.AutoButtonColor = false
			L.ZIndex = 23
			Instance.new("UICorner", L).CornerRadius = UDim.new(1, 0)
			return L
		end

		local MinBtn = MakeLight(Color3.fromRGB(255, 189, 68))
		local CloseBtn = MakeLight(Color3.fromRGB(255, 95, 87))

		local Content = Instance.new("Frame", Win)
		Content.Size = UDim2.new(1, 0, 1, -41)
		Content.Position = UDim2.new(0, 0, 0, 41)
		Content.BackgroundTransparency = 1
		Content.ClipsDescendants = true
		Content.ZIndex = 20
		local ContentList = Instance.new("UIListLayout", Content)
		ContentList.Padding = UDim.new(0, 6)
		local ContentPad = Instance.new("UIPadding", Content)
		ContentPad.PaddingTop = UDim.new(0, 10)
		ContentPad.PaddingBottom = UDim.new(0, 10)
		ContentPad.PaddingLeft = UDim.new(0, 10)
		ContentPad.PaddingRight = UDim.new(0, 10)

		local minimized = false
		MinBtn.MouseButton1Click:Connect(function()
			minimized = not minimized
			Content.Visible = not minimized
			TweenService:Create(Win, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, w, 0, minimized and 40 or contentH + 40)
			}):Play()
		end)
		local function closeWin()
			TweenService:Create(Win, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
				Size = UDim2.new(0, w * 0.94, 0, (contentH + 40) * 0.94),
				BackgroundTransparency = 0.5,
			}):Play()
			task.delay(0.18, function()
				Win.Visible = false
				minimized = false
				Content.Visible = true
				Win.Size = UDim2.new(0, w, 0, contentH + 40)
				Win.BackgroundTransparency = 0.04
			end)
		end

		local function openWin()
			Win.Size = UDim2.new(0, w * 0.88, 0, (contentH + 40) * 0.88)
			Win.BackgroundTransparency = 0.5
			Win.Visible = true
			TweenService:Create(Win, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, w, 0, contentH + 40),
				BackgroundTransparency = 0.04,
			}):Play()
		end

		CloseBtn.MouseButton1Click:Connect(closeWin)

		local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
		TBar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = Win.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then dragging = false end
				end)
			end
		end)
		TBar.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				local d = input.Position - dragStart
				Win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
			end
		end)

		return Win, Content, function()
			if Win.Visible then closeWin() else openWin() end
		end
	end

	local Bar = Instance.new("Frame", ScreenGui)
	Bar.Name = "LunarBar"
	Bar.Size = UDim2.new(0, 480, 0, 50)
	Bar.AnchorPoint = Vector2.new(1, 0)
	Bar.Position = UDim2.new(1, -10, 0, 8)
	Bar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
	Bar.BackgroundTransparency = 0.3
	Bar.BorderSizePixel = 0
	Bar.ClipsDescendants = true
	Instance.new("UICorner", Bar).CornerRadius = UDim.new(0, 8)

	local BarLogo = Instance.new("ImageLabel", Bar)
	BarLogo.Size = UDim2.new(0, 38, 0, 38)
	BarLogo.Position = UDim2.new(0, 6, 0.5, -19)
	BarLogo.BackgroundTransparency = 1
	BarLogo.Image = LogoID
	BarLogo.ScaleType = Enum.ScaleType.Fit
	BarLogo.ImageTransparency = 0
	local BarGlow = Instance.new("ImageLabel", BarLogo)
	BarGlow.Size = UDim2.new(1.5, 0, 1.5, 0)
	BarGlow.Position = UDim2.new(-0.25, 0, -0.25, 0)
	BarGlow.BackgroundTransparency = 1
	BarGlow.Image = "rbxassetid://6015538162"
	BarGlow.ImageColor3 = Color3.fromRGB(255, 255, 255)
	BarGlow.ImageTransparency = 0.85
	task.spawn(function()
		while ScreenGui.Parent do
			TweenService:Create(BarGlow, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {ImageTransparency = 0.6}):Play()
			task.wait(1.5)
			TweenService:Create(BarGlow, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {ImageTransparency = 0.85}):Play()
			task.wait(1.5)
		end
	end)

	local BarTitle = Instance.new("TextLabel", Bar)
	BarTitle.Size = UDim2.new(0, 96, 0, 22)
	BarTitle.Position = UDim2.new(0, 50, 0, 5)
	BarTitle.BackgroundTransparency = 1
	BarTitle.Text = "LUNAR ADMIN"
	BarTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	BarTitle.FontFace = GetFontBold()
	BarTitle.TextSize = 12
	BarTitle.TextXAlignment = Enum.TextXAlignment.Left

	local BarExec = Instance.new("TextLabel", Bar)
	BarExec.Size = UDim2.new(0, 96, 0, 14)
	BarExec.Position = UDim2.new(0, 50, 0, 24)
	BarExec.BackgroundTransparency = 1
	BarExec.Text = Executor
	BarExec.TextColor3 = Color3.fromRGB(110, 110, 110)
	BarExec.FontFace = GetFontBold()
	BarExec.TextSize = 11
	BarExec.TextXAlignment = Enum.TextXAlignment.Left

	local Sep1 = Instance.new("Frame", Bar)
	Sep1.Size = UDim2.new(0, 1, 1, -16); Sep1.Position = UDim2.new(0, 152, 0, 8)
	Sep1.BackgroundColor3 = Color3.fromRGB(255, 255, 255); Sep1.BackgroundTransparency = 0.88; Sep1.BorderSizePixel = 0

	local FPSLabel = Instance.new("TextLabel", Bar)
	FPSLabel.Size = UDim2.new(0, 88, 0.5, 0)
	FPSLabel.Position = UDim2.new(0, 162, 0, 4)
	FPSLabel.BackgroundTransparency = 1
	FPSLabel.Text = "● FPS: 0"
	FPSLabel.TextColor3 = Color3.fromRGB(120, 255, 140)
	FPSLabel.FontFace = GetFontBold()
	FPSLabel.TextSize = 10
	FPSLabel.TextXAlignment = Enum.TextXAlignment.Left

	local PingLabel = Instance.new("TextLabel", Bar)
	PingLabel.Size = UDim2.new(0, 88, 0.5, 0)
	PingLabel.Position = UDim2.new(0, 162, 0.5, -1)
	PingLabel.BackgroundTransparency = 1
	PingLabel.Text = "● PING: 0ms"
	PingLabel.TextColor3 = Color3.fromRGB(100, 180, 255)
	PingLabel.FontFace = GetFontBold()
	PingLabel.TextSize = 10
	PingLabel.TextXAlignment = Enum.TextXAlignment.Left

	local Sep2 = Instance.new("Frame", Bar)
	Sep2.Size = UDim2.new(0, 1, 1, -16); Sep2.Position = UDim2.new(0, 256, 0, 8)
	Sep2.BackgroundColor3 = Color3.fromRGB(255, 255, 255); Sep2.BackgroundTransparency = 0.88; Sep2.BorderSizePixel = 0

	local Icons = Instance.new("Frame", Bar)
	Icons.Size = UDim2.new(1, -266, 1, 0)
	Icons.Position = UDim2.new(0, 266, 0, 0)
	Icons.BackgroundTransparency = 1
	local UIList = Instance.new("UIListLayout", Icons)
	UIList.FillDirection = Enum.FillDirection.Horizontal
	UIList.HorizontalAlignment = Enum.HorizontalAlignment.Right
	UIList.VerticalAlignment = Enum.VerticalAlignment.Center
	UIList.Padding = UDim.new(0, 8)
	local IconsPad = Instance.new("UIPadding", Icons)
	IconsPad.PaddingRight = UDim.new(0, 10)

	local ColBtn = Instance.new("TextButton", Bar)
	ColBtn.Size = UDim2.new(0, 18, 0, 28)
	ColBtn.AnchorPoint = Vector2.new(0, 0.5)
	ColBtn.Position = UDim2.new(0, 147, 0.5, 0)
	ColBtn.BackgroundTransparency = 1
	ColBtn.Text = "◀"
	ColBtn.TextColor3 = Color3.fromRGB(90, 90, 90)
	ColBtn.FontFace = GetFontBold()
	ColBtn.TextSize = 10
	ColBtn.AutoButtonColor = false
	ColBtn.ZIndex = 40
	local barExpanded = true
	ColBtn.MouseButton1Click:Connect(function()
		barExpanded = not barExpanded
		ColBtn.Text = barExpanded and "◀" or "▶"
		TweenService:Create(Bar, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, barExpanded and 480 or 158, 0, 50)
		}):Play()
	end)
	ColBtn.MouseEnter:Connect(function() ColBtn.TextColor3 = Color3.fromRGB(200,200,200) end)
	ColBtn.MouseLeave:Connect(function() ColBtn.TextColor3 = Color3.fromRGB(90,90,90) end)

	local UISnd = Instance.new("Sound")
	UISnd.SoundId = "rbxassetid://7545317681"
	UISnd.Volume = 0.18
	UISnd.Parent = ScreenGui
	local function UIClick() pcall(function() UISnd:Play() end) end

	local Console = Instance.new("Frame", ScreenGui)
	Console.Size = UDim2.new(0, 540, 0, 44)
	Console.Position = UDim2.new(0.5, -270, 1, 60)
	Console.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
	Console.BackgroundTransparency = 0.08
	Console.BorderSizePixel = 0
	Instance.new("UICorner", Console).CornerRadius = UDim.new(0, 6)
	local ConsoleStroke = Instance.new("UIStroke", Console)
	ConsoleStroke.Color = Color3.fromRGB(80, 80, 80)
	ConsoleStroke.Transparency = 0.5
	ConsoleStroke.Thickness = 1

	local TermBar = Instance.new("Frame", Console)
	TermBar.Size = UDim2.new(1, 0, 0, 18)
	TermBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	TermBar.BackgroundTransparency = 0
	TermBar.BorderSizePixel = 0
	local TermBarCorner = Instance.new("UICorner", TermBar)
	TermBarCorner.CornerRadius = UDim.new(0, 6)
	local TermBarFill = Instance.new("Frame", TermBar)
	TermBarFill.Size = UDim2.new(1, 0, 0, 8)
	TermBarFill.Position = UDim2.new(0, 0, 1, -8)
	TermBarFill.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	TermBarFill.BorderSizePixel = 0

	local function MakeDot(x, col)
		local d = Instance.new("Frame", TermBar)
		d.Size = UDim2.new(0, 9, 0, 9)
		d.Position = UDim2.new(0, x, 0.5, -4)
		d.BackgroundColor3 = col
		d.BorderSizePixel = 0
		Instance.new("UICorner", d).CornerRadius = UDim.new(1, 0)
	end
	MakeDot(8,  Color3.fromRGB(255, 95, 87))
	MakeDot(22, Color3.fromRGB(255, 189, 68))
	MakeDot(36, Color3.fromRGB(40, 200, 80))

	local TermTitle = Instance.new("TextLabel", TermBar)
	TermTitle.Size = UDim2.new(1, 0, 1, 0)
	TermTitle.BackgroundTransparency = 1
	TermTitle.Text = "lunar — bash"
	TermTitle.TextColor3 = Color3.fromRGB(180, 180, 180)
	TermTitle.FontFace = Font.fromEnum(Enum.Font.GothamBold)
	TermTitle.TextSize = 9
	TermTitle.TextXAlignment = Enum.TextXAlignment.Center

	local InputRow = Instance.new("Frame", Console)
	InputRow.Size = UDim2.new(1, 0, 1, -18)
	InputRow.Position = UDim2.new(0, 0, 0, 18)
	InputRow.BackgroundTransparency = 1

	local PromptLbl = Instance.new("TextLabel", InputRow)
	PromptLbl.Position = UDim2.new(0, 10, 0, 0)
	PromptLbl.Size = UDim2.new(0, 0, 1, 0)
	PromptLbl.BackgroundTransparency = 1
	PromptLbl.AutomaticSize = Enum.AutomaticSize.X
	PromptLbl.RichText = true
	PromptLbl.Text = '<font color="rgb(80,200,255)">' .. Player.Name .. '</font>' ..
	                 '<font color="rgb(160,160,160)">@</font>' ..
	                 '<font color="rgb(100,255,120)">Lunar</font>' ..
	                 '<font color="rgb(160,160,160)">:~$</font> '
	PromptLbl.FontFace = Font.fromEnum(Enum.Font.Code)
	PromptLbl.TextSize = 12
	PromptLbl.TextXAlignment = Enum.TextXAlignment.Left

	local ConsoleInput = Instance.new("TextBox", InputRow)
	ConsoleInput.Position = UDim2.new(0, 10, 0, 0)
	ConsoleInput.Size = UDim2.new(1, -15, 1, 0)
	ConsoleInput.BackgroundTransparency = 1
	ConsoleInput.Text = ""
	ConsoleInput.PlaceholderText = ""
	ConsoleInput.PlaceholderColor3 = Color3.fromRGB(70, 70, 70)
	ConsoleInput.TextColor3 = Color3.fromRGB(230, 230, 230)
	ConsoleInput.FontFace = Font.fromEnum(Enum.Font.Code)
	ConsoleInput.TextSize = 12
	ConsoleInput.TextXAlignment = Enum.TextXAlignment.Left

	task.spawn(function()
		task.wait(0.1)
		local pw = PromptLbl.AbsoluteSize.X
		ConsoleInput.Position = UDim2.new(0, 10 + pw, 0, 0)
		ConsoleInput.Size = UDim2.new(1, -(10 + pw + 5), 1, 0)
	end)

	local Prompt = PromptLbl

	local function ToggleConsole()
		local t = Console.Position.Y.Offset == -58 and 60 or -58
		TweenService:Create(Console, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -270, 1, t)}):Play()
		if t == -58 then task.wait(0.1) ConsoleInput:CaptureFocus() end
	end
	UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.KeyCode == Enum.KeyCode.F2 then ToggleConsole() end
		if input.KeyCode == Enum.KeyCode.E then
			if Commands then Commands.HandleChat("fly", UI, ESP) end
		end
	end)
	local CmdCards = {
		fly        = {t="FLY",          d="Toggle free flight. Jump to rise, crouch to descend."},
		fc         = {t="FREECAM",      d="Detach your camera for cinematic free-look."},
		noclip     = {t="NOCLIP",       d="Phase through any wall or solid surface."},
		infjump    = {t="INF JUMP",     d="Jump infinitely — no ground required."},
		god        = {t="GOD MODE",     d="Take zero damage from any source."},
		walkair    = {t="WALK ON AIR",  d="Walk on air as if it were solid ground."},
		invis      = {t="INVISIBLE",    d="Your character becomes hidden to other players."},
		aimlock    = {t="AIM LOCK",     d="Lock your camera onto the nearest player."},
		antiafk    = {t="ANTI AFK",     d="Prevent the server from kicking you for inactivity."},
		lag        = {t="LAG SPOOF",    d="Simulate high ping to confuse detection systems."},
		ftpmobile  = {t="CLICK TP",     d="Click anywhere on screen to teleport there instantly."},
		flip       = {t="FRONTFLIP",    d="Execute a frontflip animation on your character."},
		bflip      = {t="BACKFLIP",     d="Execute a backflip animation on your character."},
		nametag    = {t="NAMETAG",      d="Open the nametag customizer — requires gamepass."},
		rizz       = {t="RIZZLINES",    d="Send a random rizzline in the game chat."},
		serverinfo = {t="SERVER INFO",  d="Display server details: players, ping, and job ID."},
		loopspeed  = {t="LOOP SPEED",   d="Continuously apply a custom walk speed value."},
		reach      = {t="REACH",        d="Extend your hitbox to tag distant players."},
		userspoofer= {t="USER SPOOFER", d="Spoof your username visually to confuse others."},
		shlow      = {t="SHOW LOW HP",  d="Highlight players with low health in the world."},
		shmost     = {t="SHOW MOST HP", d="Highlight the player with the highest health."},
		chat       = {t="LUNAR CHAT",   d="Open the unfiltered Lunar Chat window."},
	}
	ConsoleInput.FocusLost:Connect(function(enter)
		if enter then
			local msg = ConsoleInput.Text; ConsoleInput.Text = ""
			local cmd = msg:lower():split(" ")[1]
			local info = CmdCards[cmd]
			if info and UI.ShowCommandCard then task.spawn(UI.ShowCommandCard, info.t, info.d) end
			if Commands then Commands.HandleChat(msg, UI, ESP) end
		end
		ToggleConsole()
	end)

	local function CreateBtn(parent, label, callback)
		local Btn = Instance.new("TextButton", parent)
		Btn.Name = label
		Btn.Size = UDim2.new(1, 0, 0, 36)
		Btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Btn.BackgroundTransparency = 0.94
		Btn.Text = "  " .. label
		Btn.TextColor3 = Color3.fromRGB(195, 195, 195)
		Btn.FontFace = GetFont()
		Btn.TextSize = 12
		Btn.TextXAlignment = Enum.TextXAlignment.Left
		Btn.AutoButtonColor = false
		Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 7)
		Btn.MouseEnter:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.84, TextColor3 = Color3.fromRGB(255, 255, 255)}):Play() end)
		Btn.MouseLeave:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.94, TextColor3 = Color3.fromRGB(195, 195, 195)}):Play() end)
		Btn.MouseButton1Click:Connect(function() UIClick(); if callback then callback() end end)
		return Btn
	end

	local CmdWin, CmdContent, ToggleCmdWin = CreateWindow("Commands", 290, 320)
	local EspWin, EspContent, ToggleEspWin = CreateWindow("ESP Settings", 240, 280)
	local SpeedWin, SpeedContent, ToggleSpeedWin = CreateWindow("Speed Control", 268, 228)
	local SettingsWin, SettingsContent, ToggleSettingsWin = CreateWindow("Settings", 230, 90)
	local TPWin, TPContent, ToggleTPWin = CreateWindow("Teleport", 268, 320)
	local FlingWin, FlingContent, ToggleFlingWin = CreateWindow("Fling Players", 268, 320)
	local RizzWin, RizzContent, ToggleRizzWin = CreateWindow("Rizzlines", 300, 310)
	local AnimWin, AnimContent, ToggleAnimWin = CreateWindow("Animations", 340, 360)

	local SearchBox = Instance.new("TextBox", CmdContent)
	SearchBox.Size = UDim2.new(1, 0, 0, 34)
	SearchBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	SearchBox.BackgroundTransparency = 0.3
	SearchBox.PlaceholderText = "  Search..."
	SearchBox.Text = ""
	SearchBox.TextColor3 = Color3.fromRGB(220, 220, 220)
	SearchBox.PlaceholderColor3 = Color3.fromRGB(90, 90, 90)
	SearchBox.FontFace = GetFont()
	SearchBox.TextSize = 12
	Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 7)
	local SBPad = Instance.new("UIPadding", SearchBox)
	SBPad.PaddingLeft = UDim.new(0, 8)

	local CmdScroll = Instance.new("ScrollingFrame", CmdContent)
	CmdScroll.Size = UDim2.new(1, 0, 0, 260)
	CmdScroll.BackgroundTransparency = 1
	CmdScroll.BorderSizePixel = 0
	CmdScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	CmdScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	CmdScroll.ScrollBarThickness = 2
	CmdScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
	local CmdList = Instance.new("UIListLayout", CmdScroll)
	CmdList.Padding = UDim.new(0, 4)

	local btns = {}
	local function addBtn(label, action)
		local b = CreateBtn(CmdScroll, label, function()
			if type(action) == "function" then action()
			elseif type(action) == "string" then
				local cmd = action:lower():split(" ")[1]
				local info = CmdCards[cmd]
				if info and UI.ShowCommandCard then task.spawn(UI.ShowCommandCard, info.t, info.d) end
				if Commands then Commands.HandleChat(action, UI, ESP) end
			end
		end)
		table.insert(btns, b)
		return b
	end

	addBtn("Fly", "fly")
	addBtn("Freecam", "fc")
	addBtn("Noclip", "noclip")
	addBtn("Inf Jump", "infjump")
	addBtn("God Mode", "god")
	addBtn("Walk on Air", "walkair")
	addBtn("Invisible", "invis")
	addBtn("Aimlock", "aimlock")
	addBtn("Reach", "reach 20")
	addBtn("Frontflip", "flip")
	addBtn("Backflip", "bflip")
	addBtn("Anti AFK", "antiafk")
	addBtn("Lag Spoof", "lag")
	addBtn("Click TP", "ftpmobile")
	addBtn("Loop Speed", "loopspeed 50")
	addBtn("Spoofer", "userspoofer player")
	addBtn("Low HP", "shlow")
	addBtn("High HP", "shmost")
	addBtn("Lunar Chat", "chat")
	addBtn("Server List", "serverh")
	addBtn("Server Info", "serverinfo")
	addBtn("Anims", function() ToggleAnimWin() end)
	addBtn("Rizz", function() ToggleRizzWin() end)
	addBtn("Fling", function() ToggleFlingWin() end)
	addBtn("Teleport", function() ToggleTPWin() end)
	addBtn("ESP", function() ToggleEspWin() end)
	addBtn("Speed", function() ToggleSpeedWin() end)

	SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
		local q = SearchBox.Text:lower()
		for _, b in pairs(btns) do b.Visible = q == "" or b.Name:lower():find(q) ~= nil end
	end)

	local function CreateToggleRow(parent, label, feature)
		local Row = Instance.new("TextButton", parent)
		Row.Size = UDim2.new(1, 0, 0, 38)
		Row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Row.BackgroundTransparency = 0.94
		Row.Text = ""
		Row.AutoButtonColor = false
		Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 7)
		local Dot = Instance.new("Frame", Row)
		Dot.Size = UDim2.new(0, 8, 0, 8)
		Dot.Position = UDim2.new(0, 12, 0.5, -4)
		Dot.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
		Dot.BorderSizePixel = 0
		Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
		local Lbl = Instance.new("TextLabel", Row)
		Lbl.Size = UDim2.new(1, -28, 1, 0)
		Lbl.Position = UDim2.new(0, 28, 0, 0)
		Lbl.BackgroundTransparency = 1
		Lbl.Text = label
		Lbl.TextColor3 = Color3.fromRGB(155, 155, 155)
		Lbl.FontFace = GetFont()
		Lbl.TextSize = 12
		Lbl.TextXAlignment = Enum.TextXAlignment.Left
		local function refresh(on)
			Dot.BackgroundColor3 = on and Color3.fromRGB(0, 220, 130) or Color3.fromRGB(70, 70, 70)
			Lbl.TextColor3 = on and Color3.fromRGB(230, 230, 230) or Color3.fromRGB(155, 155, 155)
			TweenService:Create(Row, TweenInfo.new(0.15), {BackgroundTransparency = on and 0.87 or 0.94}):Play()
		end
		refresh(ESP and ESP.Settings and ESP.Settings[feature] or false)
		Row.MouseButton1Click:Connect(function()
			if not ESP then return end
			local s = not (ESP.Settings and ESP.Settings[feature])
			ESP.ToggleFeature(feature, s); refresh(s)
		end)
		Row.MouseEnter:Connect(function() TweenService:Create(Row, TweenInfo.new(0.12), {BackgroundTransparency = 0.86}):Play() end)
		Row.MouseLeave:Connect(function()
			local s = ESP and ESP.Settings and ESP.Settings[feature]
			TweenService:Create(Row, TweenInfo.new(0.12), {BackgroundTransparency = s and 0.87 or 0.94}):Play()
		end)
	end

	CreateBtn(EspContent, "Enable / Disable ESP", function()
		if not ESP then return end
		ESP.Toggle(not ESP.Enabled)
		UI.Notify("ESP " .. (ESP.Enabled and "ON" or "OFF"), ESP.Enabled and "Success" or "Warn")
	end)
	local espDiv = Instance.new("Frame", EspContent)
	espDiv.Size = UDim2.new(1, 0, 0, 1)
	espDiv.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	espDiv.BackgroundTransparency = 0.88
	espDiv.BorderSizePixel = 0
	CreateToggleRow(EspContent, "Highlights", "Highlights")
	CreateToggleRow(EspContent, "Box ESP", "Box")
	CreateToggleRow(EspContent, "HP Bars", "HP")
	CreateToggleRow(EspContent, "Skeleton", "Skeleton")
	CreateToggleRow(EspContent, "Names", "Names")

	local speedOn = false
	local speedVal = 50
	local SPToggle = Instance.new("TextButton", SpeedContent)
	SPToggle.Size = UDim2.new(1, 0, 0, 38)
	SPToggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	SPToggle.BackgroundTransparency = 0.94
	SPToggle.Text = "  ○  Speed Boost — OFF"
	SPToggle.TextColor3 = Color3.fromRGB(155, 155, 155)
	SPToggle.FontFace = GetFont()
	SPToggle.TextSize = 12
	SPToggle.TextXAlignment = Enum.TextXAlignment.Left
	SPToggle.AutoButtonColor = false
	Instance.new("UICorner", SPToggle).CornerRadius = UDim.new(0, 7)
	local spDiv = Instance.new("Frame", SpeedContent)
	spDiv.Size = UDim2.new(1, 0, 0, 1)
	spDiv.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	spDiv.BackgroundTransparency = 0.88
	spDiv.BorderSizePixel = 0
	local SPValRow = Instance.new("Frame", SpeedContent)
	SPValRow.Size = UDim2.new(1, 0, 0, 22)
	SPValRow.BackgroundTransparency = 1
	local SPLabel = Instance.new("TextLabel", SPValRow)
	SPLabel.Size = UDim2.new(0.5, 0, 1, 0)
	SPLabel.BackgroundTransparency = 1
	SPLabel.Text = "Walk Speed"
	SPLabel.TextColor3 = Color3.fromRGB(110, 110, 110)
	SPLabel.FontFace = GetFont()
	SPLabel.TextSize = 11
	SPLabel.TextXAlignment = Enum.TextXAlignment.Left
	local SPValLbl = Instance.new("TextLabel", SPValRow)
	SPValLbl.Size = UDim2.new(0.5, 0, 1, 0)
	SPValLbl.Position = UDim2.new(0.5, 0, 0, 0)
	SPValLbl.BackgroundTransparency = 1
	SPValLbl.Text = "50"
	SPValLbl.TextColor3 = Color3.fromRGB(100, 170, 255)
	SPValLbl.FontFace = GetFontBold()
	SPValLbl.TextSize = 11
	SPValLbl.TextXAlignment = Enum.TextXAlignment.Right
	local SPSliderBack = Instance.new("Frame", SpeedContent)
	SPSliderBack.Size = UDim2.new(1, 0, 0, 10)
	SPSliderBack.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
	SPSliderBack.BorderSizePixel = 0
	Instance.new("UICorner", SPSliderBack).CornerRadius = UDim.new(0, 5)
	local SPFill = Instance.new("Frame", SPSliderBack)
	SPFill.Size = UDim2.new(speedVal / 300, 0, 1, 0)
	SPFill.BackgroundColor3 = Color3.fromRGB(100, 170, 255)
	SPFill.BorderSizePixel = 0
	Instance.new("UICorner", SPFill).CornerRadius = UDim.new(0, 5)
	local SPKnob = Instance.new("TextButton", SPSliderBack)
	SPKnob.Size = UDim2.new(0, 18, 0, 18)
	SPKnob.Position = UDim2.new(speedVal / 300, -9, 0.5, -9)
	SPKnob.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
	SPKnob.Text = ""
	SPKnob.AutoButtonColor = false
	Instance.new("UICorner", SPKnob).CornerRadius = UDim.new(1, 0)
	local SPPresetsFrame = Instance.new("Frame", SpeedContent)
	SPPresetsFrame.Size = UDim2.new(1, 0, 0, 30)
	SPPresetsFrame.BackgroundTransparency = 1
	local SPPresetList = Instance.new("UIListLayout", SPPresetsFrame)
	SPPresetList.FillDirection = Enum.FillDirection.Horizontal
	SPPresetList.Padding = UDim.new(0, 5)
	for _, v in ipairs({16, 50, 100, 200, 300}) do
		local pb = Instance.new("TextButton", SPPresetsFrame)
		pb.Size = UDim2.new(0, 42, 1, 0)
		pb.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
		pb.BackgroundTransparency = 0.3
		pb.Text = tostring(v)
		pb.TextColor3 = Color3.fromRGB(170, 170, 170)
		pb.FontFace = GetFont()
		pb.TextSize = 11
		pb.AutoButtonColor = false
		Instance.new("UICorner", pb).CornerRadius = UDim.new(0, 6)
		pb.MouseEnter:Connect(function() TweenService:Create(pb, TweenInfo.new(0.12), {BackgroundTransparency = 0, TextColor3 = Color3.fromRGB(255,255,255)}):Play() end)
		pb.MouseLeave:Connect(function() TweenService:Create(pb, TweenInfo.new(0.12), {BackgroundTransparency = 0.3, TextColor3 = Color3.fromRGB(170,170,170)}):Play() end)
		pb.MouseButton1Click:Connect(function()
			speedVal = v; SPValLbl.Text = tostring(v)
			local r = v / 300; SPFill.Size = UDim2.new(r, 0, 1, 0); SPKnob.Position = UDim2.new(r, -9, 0.5, -9)
			if speedOn and Commands then Commands.HandleChat("ws " .. v, UI, nil, true) end
		end)
	end
	local SPCustomRow = Instance.new("Frame", SpeedContent)
	SPCustomRow.Size = UDim2.new(1, 0, 0, 34)
	SPCustomRow.BackgroundTransparency = 1
	local SPInput = Instance.new("TextBox", SPCustomRow)
	SPInput.Size = UDim2.new(1, -52, 1, 0)
	SPInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	SPInput.BackgroundTransparency = 0.3
	SPInput.PlaceholderText = "Custom speed..."
	SPInput.Text = ""
	SPInput.TextColor3 = Color3.fromRGB(220, 220, 220)
	SPInput.PlaceholderColor3 = Color3.fromRGB(80, 80, 80)
	SPInput.FontFace = GetFont()
	SPInput.TextSize = 11
	Instance.new("UICorner", SPInput).CornerRadius = UDim.new(0, 7)
	local SPInputPad = Instance.new("UIPadding", SPInput); SPInputPad.PaddingLeft = UDim.new(0, 8)
	local SPSetBtn = Instance.new("TextButton", SPCustomRow)
	SPSetBtn.Size = UDim2.new(0, 44, 1, 0)
	SPSetBtn.Position = UDim2.new(1, -44, 0, 0)
	SPSetBtn.BackgroundColor3 = Color3.fromRGB(100, 170, 255)
	SPSetBtn.BackgroundTransparency = 0.25
	SPSetBtn.Text = "SET"
	SPSetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	SPSetBtn.FontFace = GetFontBold()
	SPSetBtn.TextSize = 11
	SPSetBtn.AutoButtonColor = false
	Instance.new("UICorner", SPSetBtn).CornerRadius = UDim.new(0, 7)
	SPSetBtn.MouseButton1Click:Connect(function()
		local n = tonumber(SPInput.Text)
		if not n then return end
		speedVal = math.clamp(math.floor(n), 1, 9999)
		SPValLbl.Text = tostring(speedVal)
		local r = math.min(speedVal / 300, 1); SPFill.Size = UDim2.new(r, 0, 1, 0); SPKnob.Position = UDim2.new(r, -9, 0.5, -9)
		if speedOn and Commands then Commands.HandleChat("ws " .. speedVal, UI, nil, true) end
		SPInput.Text = ""
	end)
	local function refreshSPToggle()
		if speedOn then
			SPToggle.Text = "  ●  Speed Boost — ON"
			SPToggle.TextColor3 = Color3.fromRGB(100, 170, 255)
			TweenService:Create(SPToggle, TweenInfo.new(0.15), {BackgroundTransparency = 0.84}):Play()
			if Commands then Commands.HandleChat("ws " .. speedVal, UI, nil, true) end
		else
			SPToggle.Text = "  ○  Speed Boost — OFF"
			SPToggle.TextColor3 = Color3.fromRGB(155, 155, 155)
			TweenService:Create(SPToggle, TweenInfo.new(0.15), {BackgroundTransparency = 0.94}):Play()
			if Commands then Commands.HandleChat("ws 16", UI, nil, true) end
		end
	end
	SPToggle.MouseButton1Click:Connect(function() speedOn = not speedOn refreshSPToggle() end)
	SPToggle.MouseEnter:Connect(function() TweenService:Create(SPToggle, TweenInfo.new(0.12), {BackgroundTransparency = speedOn and 0.76 or 0.86}):Play() end)
	SPToggle.MouseLeave:Connect(function() TweenService:Create(SPToggle, TweenInfo.new(0.12), {BackgroundTransparency = speedOn and 0.84 or 0.94}):Play() end)
	local spDrag = false
	SPKnob.MouseButton1Down:Connect(function() spDrag = true end)
	SPKnob.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch then spDrag = true end end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then spDrag = false end
	end)
	RunService.RenderStepped:Connect(function()
		if spDrag then
			local r = math.clamp((UserInputService:GetMouseLocation().X - SPSliderBack.AbsolutePosition.X) / SPSliderBack.AbsoluteSize.X, 0, 1)
			SPFill.Size = UDim2.new(r, 0, 1, 0); SPKnob.Position = UDim2.new(r, -9, 0.5, -9)
			speedVal = math.max(1, math.floor(r * 300)); SPValLbl.Text = tostring(speedVal)
			if speedOn and Commands then Commands.HandleChat("ws " .. speedVal, UI, nil, true) end
		end
	end)

	CreateBtn(SettingsContent, "Toggle Nametags", function() if Nametags then Nametags.Unload() end end)
	CreateBtn(SettingsContent, "Unload Script", function() getgenv().LunarLoaded = false ScreenGui:Destroy() end)

	local function BuildPlayerListWindow(scroll, action)
		for _, c in pairs(scroll:GetChildren()) do
			if not c:IsA("UIListLayout") then c:Destroy() end
		end
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= Player then
				local Row = Instance.new("TextButton", scroll)
				Row.Size = UDim2.new(1, 0, 0, 50)
				Row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Row.BackgroundTransparency = 0.94
				Row.Text = ""
				Row.AutoButtonColor = false
				Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 8)
				local Avatar = Instance.new("ImageLabel", Row)
				Avatar.Size = UDim2.new(0, 36, 0, 36)
				Avatar.Position = UDim2.new(0, 7, 0.5, -18)
				Avatar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
				Avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. p.UserId .. "&w=150&h=150"
				Avatar.ScaleType = Enum.ScaleType.Fit
				Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1, 0)
				local NameLbl = Instance.new("TextLabel", Row)
				NameLbl.Size = UDim2.new(1, -110, 1, 0)
				NameLbl.Position = UDim2.new(0, 50, 0, 0)
				NameLbl.BackgroundTransparency = 1
				NameLbl.Text = p.Name
				NameLbl.TextColor3 = Color3.fromRGB(215, 215, 215)
				NameLbl.FontFace = GetFont()
				NameLbl.TextSize = 13
				NameLbl.TextXAlignment = Enum.TextXAlignment.Left
				local ActBtn = Instance.new("TextButton", Row)
				ActBtn.Size = UDim2.new(0, 50, 0, 28)
				ActBtn.Position = UDim2.new(1, -56, 0.5, -14)
				ActBtn.BackgroundColor3 = Color3.fromRGB(100, 170, 255)
				ActBtn.BackgroundTransparency = 0.25
				ActBtn.Text = action.label
				ActBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
				ActBtn.FontFace = GetFontBold()
				ActBtn.TextSize = 11
				ActBtn.AutoButtonColor = false
				Instance.new("UICorner", ActBtn).CornerRadius = UDim.new(0, 6)
				ActBtn.MouseEnter:Connect(function() TweenService:Create(ActBtn, TweenInfo.new(0.12), {BackgroundTransparency = 0}):Play() end)
				ActBtn.MouseLeave:Connect(function() TweenService:Create(ActBtn, TweenInfo.new(0.12), {BackgroundTransparency = 0.25}):Play() end)
				local function doAction() action.fn(p) end
				ActBtn.MouseButton1Click:Connect(doAction)
				Row.MouseButton1Click:Connect(doAction)
				Row.MouseEnter:Connect(function() TweenService:Create(Row, TweenInfo.new(0.12), {BackgroundTransparency = 0.86}):Play() end)
				Row.MouseLeave:Connect(function() TweenService:Create(Row, TweenInfo.new(0.12), {BackgroundTransparency = 0.94}):Play() end)
			end
		end
	end

	local TPSearchBox = Instance.new("TextBox", TPContent)
	TPSearchBox.Size = UDim2.new(1, 0, 0, 34)
	TPSearchBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	TPSearchBox.BackgroundTransparency = 0.3
	TPSearchBox.PlaceholderText = "  Search players..."
	TPSearchBox.Text = ""
	TPSearchBox.TextColor3 = Color3.fromRGB(220, 220, 220)
	TPSearchBox.PlaceholderColor3 = Color3.fromRGB(90, 90, 90)
	TPSearchBox.FontFace = GetFont()
	TPSearchBox.TextSize = 12
	Instance.new("UICorner", TPSearchBox).CornerRadius = UDim.new(0, 7)
	local TPSBPad = Instance.new("UIPadding", TPSearchBox); TPSBPad.PaddingLeft = UDim.new(0, 8)
	local TPScroll = Instance.new("ScrollingFrame", TPContent)
	TPScroll.Size = UDim2.new(1, 0, 0, 256)
	TPScroll.BackgroundTransparency = 1
	TPScroll.BorderSizePixel = 0
	TPScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	TPScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	TPScroll.ScrollBarThickness = 2
	TPScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
	Instance.new("UIListLayout", TPScroll).Padding = UDim.new(0, 5)

	local function RefreshTP(f) BuildPlayerListWindow(TPScroll, {label="TP", fn=function(p)
		if Commands then Commands.HandleChat("tp " .. p.Name, UI, nil, true) end
		UI.Notify("TP → " .. p.Name, "Success")
	end}) end
	local origTP = ToggleTPWin
	ToggleTPWin = function() RefreshTP() origTP() end
	TPSearchBox:GetPropertyChangedSignal("Text"):Connect(function() RefreshTP(TPSearchBox.Text) end)
	Players.PlayerAdded:Connect(function() if TPWin.Visible then RefreshTP() end end)
	Players.PlayerRemoving:Connect(function() task.wait(0.1) if TPWin.Visible then RefreshTP() end end)

	local FlingSearchBox = Instance.new("TextBox", FlingContent)
	FlingSearchBox.Size = UDim2.new(1, 0, 0, 34)
	FlingSearchBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	FlingSearchBox.BackgroundTransparency = 0.3
	FlingSearchBox.PlaceholderText = "  Search players..."
	FlingSearchBox.Text = ""
	FlingSearchBox.TextColor3 = Color3.fromRGB(220, 220, 220)
	FlingSearchBox.PlaceholderColor3 = Color3.fromRGB(90, 90, 90)
	FlingSearchBox.FontFace = GetFont()
	FlingSearchBox.TextSize = 12
	Instance.new("UICorner", FlingSearchBox).CornerRadius = UDim.new(0, 7)
	local FSBPad = Instance.new("UIPadding", FlingSearchBox); FSBPad.PaddingLeft = UDim.new(0, 8)
	local FlingScroll = Instance.new("ScrollingFrame", FlingContent)
	FlingScroll.Size = UDim2.new(1, 0, 0, 256)
	FlingScroll.BackgroundTransparency = 1
	FlingScroll.BorderSizePixel = 0
	FlingScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	FlingScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	FlingScroll.ScrollBarThickness = 2
	FlingScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
	Instance.new("UIListLayout", FlingScroll).Padding = UDim.new(0, 5)

	local function RefreshFling() BuildPlayerListWindow(FlingScroll, {label="Fling", fn=function(p)
		if ProperFling then
			UI.Notify("Flinging " .. p.Name, "Success")
			task.spawn(ProperFling.Fling, p)
		end
	end}) end
	local origFling = ToggleFlingWin
	ToggleFlingWin = function() RefreshFling() origFling() end
	FlingSearchBox:GetPropertyChangedSignal("Text"):Connect(RefreshFling)
	Players.PlayerAdded:Connect(function() if FlingWin.Visible then RefreshFling() end end)
	Players.PlayerRemoving:Connect(function() task.wait(0.1) if FlingWin.Visible then RefreshFling() end end)

	local RizzScroll = Instance.new("ScrollingFrame", RizzContent)
	RizzScroll.Size = UDim2.new(1, 0, 0, 276)
	RizzScroll.BackgroundTransparency = 1
	RizzScroll.BorderSizePixel = 0
	RizzScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	RizzScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	RizzScroll.ScrollBarThickness = 2
	RizzScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
	Instance.new("UIListLayout", RizzScroll).Padding = UDim.new(0, 4)

	if Rizzlines then
		for _, line in ipairs(Rizzlines.Lines) do
			local Row = Instance.new("TextButton", RizzScroll)
			Row.Size = UDim2.new(1, 0, 0, 0)
			Row.AutomaticSize = Enum.AutomaticSize.Y
			Row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Row.BackgroundTransparency = 0.94
			Row.Text = ""
			Row.AutoButtonColor = false
			Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 8)
			local RowPad = Instance.new("UIPadding", Row)
			RowPad.PaddingLeft = UDim.new(0, 10)
			RowPad.PaddingRight = UDim.new(0, 60)
			RowPad.PaddingTop = UDim.new(0, 8)
			RowPad.PaddingBottom = UDim.new(0, 8)
			local LineLbl = Instance.new("TextLabel", Row)
			LineLbl.Size = UDim2.new(1, 0, 0, 0)
			LineLbl.AutomaticSize = Enum.AutomaticSize.Y
			LineLbl.BackgroundTransparency = 1
			LineLbl.Text = line
			LineLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
			LineLbl.FontFace = GetFont()
			LineLbl.TextSize = 11
			LineLbl.TextXAlignment = Enum.TextXAlignment.Left
			LineLbl.TextWrapped = true
			local SendBtn = Instance.new("TextButton", Row)
			SendBtn.Size = UDim2.new(0, 48, 0, 28)
			SendBtn.Position = UDim2.new(1, -54, 0.5, -14)
			SendBtn.BackgroundColor3 = Color3.fromRGB(100, 170, 255)
			SendBtn.BackgroundTransparency = 0.25
			SendBtn.Text = "Send"
			SendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			SendBtn.FontFace = GetFontBold()
			SendBtn.TextSize = 11
			SendBtn.AutoButtonColor = false
			Instance.new("UICorner", SendBtn).CornerRadius = UDim.new(0, 6)
			SendBtn.MouseEnter:Connect(function() TweenService:Create(SendBtn, TweenInfo.new(0.12), {BackgroundTransparency = 0}):Play() end)
			SendBtn.MouseLeave:Connect(function() TweenService:Create(SendBtn, TweenInfo.new(0.12), {BackgroundTransparency = 0.25}):Play() end)
			SendBtn.MouseButton1Click:Connect(function() Rizzlines.SendLine(line, UI) end)
			Row.MouseEnter:Connect(function() TweenService:Create(Row, TweenInfo.new(0.12), {BackgroundTransparency = 0.86}):Play() end)
			Row.MouseLeave:Connect(function() TweenService:Create(Row, TweenInfo.new(0.12), {BackgroundTransparency = 0.94}):Play() end)
		end
	end

	local AnimSearchBox = Instance.new("TextBox", AnimContent)
	AnimSearchBox.Size = UDim2.new(1, 0, 0, 34)
	AnimSearchBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	AnimSearchBox.BackgroundTransparency = 0.3
	AnimSearchBox.PlaceholderText = "  Search animations..."
	AnimSearchBox.Text = ""
	AnimSearchBox.TextColor3 = Color3.fromRGB(220, 220, 220)
	AnimSearchBox.PlaceholderColor3 = Color3.fromRGB(90, 90, 90)
	AnimSearchBox.FontFace = GetFont()
	AnimSearchBox.TextSize = 12
	Instance.new("UICorner", AnimSearchBox).CornerRadius = UDim.new(0, 7)
	local ASBPad = Instance.new("UIPadding", AnimSearchBox); ASBPad.PaddingLeft = UDim.new(0, 8)

	local AnimStopBtn = Instance.new("TextButton", AnimContent)
	AnimStopBtn.Size = UDim2.new(1, 0, 0, 30)
	AnimStopBtn.BackgroundColor3 = Color3.fromRGB(255, 65, 65)
	AnimStopBtn.BackgroundTransparency = 0.4
	AnimStopBtn.Text = "  Stop Current Animation"
	AnimStopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	AnimStopBtn.FontFace = GetFontBold()
	AnimStopBtn.TextSize = 11
	AnimStopBtn.TextXAlignment = Enum.TextXAlignment.Left
	AnimStopBtn.AutoButtonColor = false
	Instance.new("UICorner", AnimStopBtn).CornerRadius = UDim.new(0, 7)
	AnimStopBtn.MouseButton1Click:Connect(function()
		if Animations then Animations.Stop(UI) end
	end)
	AnimStopBtn.MouseEnter:Connect(function() TweenService:Create(AnimStopBtn, TweenInfo.new(0.12), {BackgroundTransparency = 0.1}):Play() end)
	AnimStopBtn.MouseLeave:Connect(function() TweenService:Create(AnimStopBtn, TweenInfo.new(0.12), {BackgroundTransparency = 0.4}):Play() end)

	local AnimScroll = Instance.new("ScrollingFrame", AnimContent)
	AnimScroll.Size = UDim2.new(1, 0, 0, 272)
	AnimScroll.BackgroundTransparency = 1
	AnimScroll.BorderSizePixel = 0
	AnimScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	AnimScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	AnimScroll.ScrollBarThickness = 2
	AnimScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
	local AnimListLayout = Instance.new("UIListLayout", AnimScroll)
	AnimListLayout.Padding = UDim.new(0, 4)

	local animBtns = {}
	if Animations then
		for _, entry in ipairs(Animations.List) do
			local Row = Instance.new("Frame", AnimScroll)
			Row.Size = UDim2.new(1, 0, 0, 34)
			Row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Row.BackgroundTransparency = 0.94
			Row.BorderSizePixel = 0
			Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 7)
			local Lbl = Instance.new("TextLabel", Row)
			Lbl.Size = UDim2.new(1, -68, 1, 0)
			Lbl.Position = UDim2.new(0, 10, 0, 0)
			Lbl.BackgroundTransparency = 1
			Lbl.Text = entry.n
			Lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
			Lbl.FontFace = GetFont()
			Lbl.TextSize = 11
			Lbl.TextXAlignment = Enum.TextXAlignment.Left
			Lbl.TextTruncate = Enum.TextTruncate.AtEnd
			local PlayBtn = Instance.new("TextButton", Row)
			PlayBtn.Size = UDim2.new(0, 52, 0, 24)
			PlayBtn.Position = UDim2.new(1, -58, 0.5, -12)
			PlayBtn.BackgroundColor3 = Color3.fromRGB(100, 170, 255)
			PlayBtn.BackgroundTransparency = 0.25
			PlayBtn.Text = "Play"
			PlayBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			PlayBtn.FontFace = GetFontBold()
			PlayBtn.TextSize = 11
			PlayBtn.AutoButtonColor = false
			Instance.new("UICorner", PlayBtn).CornerRadius = UDim.new(0, 6)
			PlayBtn.MouseEnter:Connect(function() TweenService:Create(PlayBtn, TweenInfo.new(0.12), {BackgroundTransparency = 0}):Play() end)
			PlayBtn.MouseLeave:Connect(function() TweenService:Create(PlayBtn, TweenInfo.new(0.12), {BackgroundTransparency = 0.25}):Play() end)
			local eid = entry.id
			local en  = entry.n
			PlayBtn.MouseButton1Click:Connect(function()
				Animations.Play(eid, UI)
				Lbl.TextColor3 = Color3.fromRGB(100, 220, 150)
				task.delay(1.5, function() Lbl.TextColor3 = Color3.fromRGB(200, 200, 200) end)
			end)
			Row.Name = entry.n
			table.insert(animBtns, Row)
		end
	end

	AnimSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
		local q = AnimSearchBox.Text:lower()
		for _, row in pairs(animBtns) do
			row.Visible = q == "" or row.Name:lower():find(q) ~= nil
		end
	end)

	local function MakeHeaderBadge(parent, z)
		local Badge = Instance.new("Frame", parent)
		Badge.Size = UDim2.new(0, 88, 0, 17)
		Badge.Position = UDim2.new(0, 12, 0, 11)
		Badge.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
		Badge.BackgroundTransparency = 0
		Badge.BorderSizePixel = 0
		Badge.ZIndex = z
		Instance.new("UICorner", Badge).CornerRadius = UDim.new(0, 5)
		local Dot = Instance.new("Frame", Badge)
		Dot.Size = UDim2.new(0, 6, 0, 6)
		Dot.Position = UDim2.new(0, 7, 0.5, -3)
		Dot.BackgroundColor3 = Color3.fromRGB(0, 220, 130)
		Dot.BorderSizePixel = 0
		Dot.ZIndex = z + 1
		Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
		local Lbl = Instance.new("TextLabel", Badge)
		Lbl.Size = UDim2.new(1, -18, 1, 0)
		Lbl.Position = UDim2.new(0, 18, 0, 0)
		Lbl.BackgroundTransparency = 1
		Lbl.Text = "LUNAR ADMIN"
		Lbl.TextColor3 = Color3.fromRGB(150, 150, 150)
		Lbl.FontFace = GetFontBold()
		Lbl.TextSize = 9
		Lbl.TextXAlignment = Enum.TextXAlignment.Left
		Lbl.ZIndex = z + 1
	end

	local NotifyFrame = Instance.new("Frame", ScreenGui)
	NotifyFrame.Size = UDim2.new(0, 262, 0, 84)
	NotifyFrame.Position = UDim2.new(1, 285, 0, 68)
	NotifyFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	NotifyFrame.BackgroundTransparency = 0.05
	NotifyFrame.BorderSizePixel = 0
	NotifyFrame.ZIndex = 100
	Instance.new("UICorner", NotifyFrame).CornerRadius = UDim.new(0, 12)
	MakeHeaderBadge(NotifyFrame, 101)

	local NTypeLabel = Instance.new("TextLabel", NotifyFrame)
	NTypeLabel.Size = UDim2.new(1, -24, 0, 22)
	NTypeLabel.Position = UDim2.new(0, 12, 0, 32)
	NTypeLabel.BackgroundTransparency = 1
	NTypeLabel.Text = "Success"
	NTypeLabel.TextColor3 = Color3.fromRGB(0, 220, 130)
	NTypeLabel.FontFace = GetFontBold()
	NTypeLabel.TextSize = 16
	NTypeLabel.TextXAlignment = Enum.TextXAlignment.Left
	NTypeLabel.ZIndex = 101

	local NDetailLabel = Instance.new("TextLabel", NotifyFrame)
	NDetailLabel.Size = UDim2.new(1, -24, 0, 14)
	NDetailLabel.Position = UDim2.new(0, 12, 0, 58)
	NDetailLabel.BackgroundTransparency = 1
	NDetailLabel.Text = ""
	NDetailLabel.TextColor3 = Color3.fromRGB(105, 105, 105)
	NDetailLabel.FontFace = GetFont()
	NDetailLabel.TextSize = 10
	NDetailLabel.TextXAlignment = Enum.TextXAlignment.Left
	NDetailLabel.ZIndex = 101

	local TutorialCard = Instance.new("Frame", ScreenGui)
	TutorialCard.Size = UDim2.new(0, 290, 0, 96)
	TutorialCard.Position = UDim2.new(1, 315, 0, 166)
	TutorialCard.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	TutorialCard.BackgroundTransparency = 0.05
	TutorialCard.BorderSizePixel = 0
	TutorialCard.ZIndex = 100
	Instance.new("UICorner", TutorialCard).CornerRadius = UDim.new(0, 12)
	MakeHeaderBadge(TutorialCard, 101)

	local TCIconWrap = Instance.new("Frame", TutorialCard)
	TCIconWrap.Size = UDim2.new(0, 46, 0, 46)
	TCIconWrap.Position = UDim2.new(0, 12, 0, 36)
	TCIconWrap.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	TCIconWrap.BackgroundTransparency = 0
	TCIconWrap.BorderSizePixel = 0
	TCIconWrap.ZIndex = 101
	Instance.new("UICorner", TCIconWrap).CornerRadius = UDim.new(0, 10)
	local TCIcon = Instance.new("ImageLabel", TCIconWrap)
	TCIcon.Size = UDim2.new(0, 30, 0, 30)
	TCIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	TCIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
	TCIcon.BackgroundTransparency = 1
	TCIcon.ScaleType = Enum.ScaleType.Fit
	TCIcon.Image = LogoID
	TCIcon.ZIndex = 102

	local TCTitleLbl = Instance.new("TextLabel", TutorialCard)
	TCTitleLbl.Size = UDim2.new(1, -74, 0, 22)
	TCTitleLbl.Position = UDim2.new(0, 68, 0, 36)
	TCTitleLbl.BackgroundTransparency = 1
	TCTitleLbl.Text = "COMMAND"
	TCTitleLbl.TextColor3 = Color3.fromRGB(240, 240, 240)
	TCTitleLbl.FontFace = GetFontBold()
	TCTitleLbl.TextSize = 16
	TCTitleLbl.TextXAlignment = Enum.TextXAlignment.Left
	TCTitleLbl.ZIndex = 101

	local TCDescLbl = Instance.new("TextLabel", TutorialCard)
	TCDescLbl.Size = UDim2.new(1, -74, 0, 32)
	TCDescLbl.Position = UDim2.new(0, 68, 0, 58)
	TCDescLbl.BackgroundTransparency = 1
	TCDescLbl.Text = ""
	TCDescLbl.TextColor3 = Color3.fromRGB(105, 105, 105)
	TCDescLbl.FontFace = GetFont()
	TCDescLbl.TextSize = 10
	TCDescLbl.TextXAlignment = Enum.TextXAlignment.Left
	TCDescLbl.TextWrapped = true
	TCDescLbl.ZIndex = 101

	local _notifyThread = nil
	UI.Notify = function(text, nType)
		if _notifyThread then pcall(task.cancel, _notifyThread); _notifyThread = nil end
		NotifyFrame.Position = UDim2.new(1, 285, 0, 68)
		local typeText, typeColor = "Info", Color3.fromRGB(190, 190, 190)
		if nType == "Success" then typeText = "Success"; typeColor = Color3.fromRGB(0, 220, 130)
		elseif nType == "Warn" then typeText = "Warning"; typeColor = Color3.fromRGB(255, 170, 50)
		elseif nType == "Error" then typeText = "Error"; typeColor = Color3.fromRGB(255, 65, 65)
		end
		NTypeLabel.Text = typeText
		NTypeLabel.TextColor3 = typeColor
		NDetailLabel.Text = text
		TweenService:Create(NotifyFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(1, -275, 0, 68)}):Play()
		_notifyThread = task.delay(3.0, function()
			TweenService:Create(NotifyFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(1, 285, 0, 68)}):Play()
			_notifyThread = nil
		end)
	end

	UI.ShowCommandCard = function(title, desc)
		TCTitleLbl.Text = title:upper()
		TCDescLbl.Text = desc or ""
		TweenService:Create(TutorialCard, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(1, -303, 0, 166)}):Play()
		task.delay(4.5, function()
			TweenService:Create(TutorialCard, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(1, 315, 0, 166)}):Play()
		end)
	end

	local FlightStatus = Instance.new("Frame", ScreenGui)
	FlightStatus.Size = UDim2.new(0, 220, 0, 54)
	FlightStatus.AnchorPoint = Vector2.new(0.5, 1)
	FlightStatus.Position = UDim2.new(0.5, 0, 1, 80)
	FlightStatus.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
	FlightStatus.BackgroundTransparency = 0.12
	FlightStatus.BorderSizePixel = 0
	Instance.new("UICorner", FlightStatus).CornerRadius = UDim.new(0, 14)
	local FStroke = Instance.new("UIStroke", FlightStatus)
	FStroke.Color = Color3.fromRGB(0, 220, 130); FStroke.Transparency = 0.4; FStroke.Thickness = 1

	local FIcon = Instance.new("TextLabel", FlightStatus)
	FIcon.Size = UDim2.new(0, 28, 0, 28); FIcon.Position = UDim2.new(0, 12, 0.5, -14)
	FIcon.BackgroundColor3 = Color3.fromRGB(0, 200, 110); FIcon.BackgroundTransparency = 0.25
	FIcon.Text = "✈"; FIcon.TextColor3 = Color3.fromRGB(255,255,255)
	FIcon.FontFace = GetFontBold(); FIcon.TextSize = 14
	Instance.new("UICorner", FIcon).CornerRadius = UDim.new(0, 7)

	local FTitleLbl = Instance.new("TextLabel", FlightStatus)
	FTitleLbl.Size = UDim2.new(1, -100, 0, 18); FTitleLbl.Position = UDim2.new(0, 48, 0, 9)
	FTitleLbl.BackgroundTransparency = 1; FTitleLbl.Text = "FLY MODE"
	FTitleLbl.TextColor3 = Color3.fromRGB(0, 220, 130); FTitleLbl.FontFace = GetFontBold(); FTitleLbl.TextSize = 11
	FTitleLbl.TextXAlignment = Enum.TextXAlignment.Left

	local FKeyHint = Instance.new("TextLabel", FlightStatus)
	FKeyHint.Size = UDim2.new(1, -100, 0, 14); FKeyHint.Position = UDim2.new(0, 48, 0, 30)
	FKeyHint.BackgroundTransparency = 1; FKeyHint.Text = "Press E to toggle"
	FKeyHint.TextColor3 = Color3.fromRGB(90, 90, 90); FKeyHint.FontFace = GetFont(); FKeyHint.TextSize = 9
	FKeyHint.TextXAlignment = Enum.TextXAlignment.Left

	local FSpeedLbl = Instance.new("TextLabel", FlightStatus)
	FSpeedLbl.Size = UDim2.new(0, 60, 1, 0); FSpeedLbl.Position = UDim2.new(1, -68, 0, 0)
	FSpeedLbl.BackgroundTransparency = 1; FSpeedLbl.Text = "32\nspd"
	FSpeedLbl.TextColor3 = Color3.fromRGB(100, 200, 255); FSpeedLbl.FontFace = GetFontBold(); FSpeedLbl.TextSize = 13
	FSpeedLbl.TextXAlignment = Enum.TextXAlignment.Center

	UI.UpdateFlightStatus = function(active, speed)
		TweenService:Create(FlightStatus, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Position = UDim2.new(0.5, 0, 1, active and -14 or 80)
		}):Play()
		if speed then FSpeedLbl.Text = math.floor(speed) .. "\nspd" end
	end

	local ServerInfoPanel = Instance.new("Frame", ScreenGui)
	ServerInfoPanel.Size = UDim2.new(0, 225, 0, 158)
	ServerInfoPanel.Position = UDim2.new(1, 20, 0.5, -79)
	ServerInfoPanel.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
	ServerInfoPanel.BackgroundTransparency = 0.06
	ServerInfoPanel.BorderSizePixel = 0
	Instance.new("UICorner", ServerInfoPanel).CornerRadius = UDim.new(0, 11)
	local SIPStroke = Instance.new("UIStroke", ServerInfoPanel)
	SIPStroke.Color = Color3.fromRGB(100, 180, 255); SIPStroke.Transparency = 0.55; SIPStroke.Thickness = 1
	local SIPTitle = Instance.new("TextLabel", ServerInfoPanel)
	SIPTitle.Size = UDim2.new(1, -20, 0, 30); SIPTitle.Position = UDim2.new(0, 14, 0, 7)
	SIPTitle.BackgroundTransparency = 1; SIPTitle.Text = "SERVER INFO"
	SIPTitle.TextColor3 = Color3.fromRGB(100, 180, 255); SIPTitle.FontFace = GetFontBold(); SIPTitle.TextSize = 12
	SIPTitle.TextXAlignment = Enum.TextXAlignment.Left
	local SIPDiv = Instance.new("Frame", ServerInfoPanel)
	SIPDiv.Size = UDim2.new(1, -28, 0, 1); SIPDiv.Position = UDim2.new(0, 14, 0, 37)
	SIPDiv.BackgroundColor3 = Color3.fromRGB(255, 255, 255); SIPDiv.BackgroundTransparency = 0.88; SIPDiv.BorderSizePixel = 0
	local siRows = {}
	for i, label in ipairs({"Players", "Ping", "FPS", "Server Age", "Job ID"}) do
		local row = Instance.new("Frame", ServerInfoPanel)
		row.Size = UDim2.new(1, -28, 0, 18); row.Position = UDim2.new(0, 14, 0, 37 + i * 21)
		row.BackgroundTransparency = 1
		local ll = Instance.new("TextLabel", row)
		ll.Size = UDim2.new(0.5, 0, 1, 0); ll.BackgroundTransparency = 1; ll.Text = label
		ll.TextColor3 = Color3.fromRGB(110, 110, 110); ll.FontFace = GetFont(); ll.TextSize = 11; ll.TextXAlignment = Enum.TextXAlignment.Left
		local rv = Instance.new("TextLabel", row)
		rv.Size = UDim2.new(0.5, 0, 1, 0); rv.Position = UDim2.new(0.5, 0, 0, 0); rv.BackgroundTransparency = 1; rv.Text = "—"
		rv.TextColor3 = Color3.fromRGB(220, 220, 220); rv.FontFace = GetFont(); rv.TextSize = 11; rv.TextXAlignment = Enum.TextXAlignment.Right
		siRows[label] = rv
	end
	local siOpen, siConn = false, nil
	UI.ToggleServerInfo = function()
		siOpen = not siOpen
		if siOpen then
			TweenService:Create(ServerInfoPanel, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(1, -240, 0.5, -79)}):Play()
			local fa, ff = 0, 0
			siConn = RunService.RenderStepped:Connect(function(dt)
				fa += dt; ff += 1
				if fa >= 0.5 then
					siRows["Players"].Text = #Players:GetPlayers() .. "/" .. game.Players.MaxPlayers
					siRows["Ping"].Text = math.floor(Player:GetNetworkPing() * 1000) .. "ms"
					siRows["FPS"].Text = tostring(math.floor(ff / fa))
					siRows["Server Age"].Text = math.floor(workspace.DistributedGameTime / 60) .. "m"
					siRows["Job ID"].Text = game.JobId:sub(1, 11) .. "..."
					fa = 0; ff = 0
				end
			end)
		else
			TweenService:Create(ServerInfoPanel, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(1, 20, 0.5, -79)}):Play()
			if siConn then siConn:Disconnect() siConn = nil end
		end
	end

	if Commands then Commands._UI = UI end

	local function CreatePill(label, accent, callback)
		local Btn = Instance.new("TextButton", Icons)
		Btn.Size = UDim2.new(0, 0, 0, 30)
		Btn.AutomaticSize = Enum.AutomaticSize.X
		Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		Btn.BackgroundTransparency = 0.3
		Btn.Text = "  " .. label .. "  "
		Btn.TextColor3 = accent
		Btn.FontFace = GetFontBold()
		Btn.TextSize = 10
		Btn.AutoButtonColor = false
		Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0)
		local s = Instance.new("UIStroke", Btn)
		s.Color = accent; s.Transparency = 0.6; s.Thickness = 1
		Btn.MouseEnter:Connect(function()
			TweenService:Create(Btn, TweenInfo.new(0.12), {BackgroundTransparency = 0.02, TextColor3 = Color3.fromRGB(255,255,255)}):Play()
			TweenService:Create(s, TweenInfo.new(0.12), {Transparency = 0.1}):Play()
		end)
		Btn.MouseLeave:Connect(function()
			TweenService:Create(Btn, TweenInfo.new(0.12), {BackgroundTransparency = 0.3, TextColor3 = accent}):Play()
			TweenService:Create(s, TweenInfo.new(0.12), {Transparency = 0.6}):Play()
		end)
		if callback then Btn.MouseButton1Click:Connect(callback) end
		return Btn
	end

	local function CreateIconBtn(imgId, accent, callback)
		local Btn = Instance.new("TextButton", Icons)
		Btn.Size = UDim2.new(0, 32, 0, 32)
		Btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
		Btn.BackgroundTransparency = 0.25
		Btn.Text = ""
		Btn.AutoButtonColor = false
		Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0)
		local s = Instance.new("UIStroke", Btn)
		s.Color = accent; s.Transparency = 0.65; s.Thickness = 1
		local Img = Instance.new("ImageLabel", Btn)
		Img.Size = UDim2.new(0, 18, 0, 18)
		Img.AnchorPoint = Vector2.new(0.5, 0.5)
		Img.Position = UDim2.new(0.5, 0, 0.5, 0)
		Img.BackgroundTransparency = 1
		Img.Image = "rbxthumb://type=Asset&id=" .. tostring(imgId) .. "&w=150&h=150"
		Img.ImageColor3 = Color3.fromRGB(255, 255, 255)
		Img.ScaleType = Enum.ScaleType.Fit
		Btn.MouseEnter:Connect(function()
			TweenService:Create(Btn, TweenInfo.new(0.12), {BackgroundTransparency = 0.02}):Play()
			TweenService:Create(s, TweenInfo.new(0.12), {Transparency = 0.1}):Play()
		end)
		Btn.MouseLeave:Connect(function()
			TweenService:Create(Btn, TweenInfo.new(0.12), {BackgroundTransparency = 0.25}):Play()
			TweenService:Create(s, TweenInfo.new(0.12), {Transparency = 0.65}):Play()
		end)
		if callback then Btn.MouseButton1Click:Connect(callback) end
		return Btn
	end

	local NetWin, NetContent, ToggleNetWin = CreateWindow("Lunar Network", 280, 310)

	local NetSearchBox = Instance.new("TextBox", NetContent)
	NetSearchBox.Size = UDim2.new(1, 0, 0, 34)
	NetSearchBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	NetSearchBox.BackgroundTransparency = 0.3
	NetSearchBox.PlaceholderText = "  Search users..."
	NetSearchBox.Text = ""
	NetSearchBox.TextColor3 = Color3.fromRGB(220, 220, 220)
	NetSearchBox.PlaceholderColor3 = Color3.fromRGB(90, 90, 90)
	NetSearchBox.FontFace = GetFont()
	NetSearchBox.TextSize = 12
	Instance.new("UICorner", NetSearchBox).CornerRadius = UDim.new(0, 7)
	Instance.new("UIPadding", NetSearchBox).PaddingLeft = UDim.new(0, 8)

	local NetStatusRow = Instance.new("Frame", NetContent)
	NetStatusRow.Size = UDim2.new(1, 0, 0, 22)
	NetStatusRow.BackgroundTransparency = 1
	local NetDot = Instance.new("Frame", NetStatusRow)
	NetDot.Size = UDim2.new(0, 7, 0, 7)
	NetDot.Position = UDim2.new(0, 0, 0.5, -3)
	NetDot.BackgroundColor3 = Color3.fromRGB(0, 220, 130)
	NetDot.BorderSizePixel = 0
	Instance.new("UICorner", NetDot).CornerRadius = UDim.new(1, 0)
	local NetStatusLbl = Instance.new("TextLabel", NetStatusRow)
	NetStatusLbl.Size = UDim2.new(1, -14, 1, 0)
	NetStatusLbl.Position = UDim2.new(0, 14, 0, 0)
	NetStatusLbl.BackgroundTransparency = 1
	NetStatusLbl.Text = "Scanning server..."
	NetStatusLbl.TextColor3 = Color3.fromRGB(100, 100, 100)
	NetStatusLbl.FontFace = GetFont()
	NetStatusLbl.TextSize = 10
	NetStatusLbl.TextXAlignment = Enum.TextXAlignment.Left

	local NetScroll = Instance.new("ScrollingFrame", NetContent)
	NetScroll.Size = UDim2.new(1, 0, 0, 230)
	NetScroll.BackgroundTransparency = 1
	NetScroll.BorderSizePixel = 0
	NetScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	NetScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	NetScroll.ScrollBarThickness = 2
	NetScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
	Instance.new("UIListLayout", NetScroll).Padding = UDim.new(0, 5)

	local HttpService = game:GetService("HttpService")
	local netBtns = {}

	local function MakeUserRow(userId, displayName, username, inServer, canTP)
		local Row = Instance.new("Frame", NetScroll)
		Row.Size = UDim2.new(1, 0, 0, 48)
		Row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Row.BackgroundTransparency = 0.94
		Row.BorderSizePixel = 0
		Row.Name = username
		Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 8)
		local Avatar = Instance.new("ImageLabel", Row)
		Avatar.Size = UDim2.new(0, 34, 0, 34)
		Avatar.Position = UDim2.new(0, 7, 0.5, -17)
		Avatar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		Avatar.BorderSizePixel = 0
		Avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. userId .. "&w=48&h=48"
		Avatar.ScaleType = Enum.ScaleType.Fit
		Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1, 0)
		local Dot = Instance.new("Frame", Avatar)
		Dot.Size = UDim2.new(0, 9, 0, 9)
		Dot.Position = UDim2.new(1, -9, 1, -9)
		Dot.BackgroundColor3 = inServer and Color3.fromRGB(0, 220, 130) or Color3.fromRGB(255, 170, 50)
		Dot.BorderSizePixel = 0
		Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
		local NameLbl = Instance.new("TextLabel", Row)
		NameLbl.Size = UDim2.new(1, -110, 0, 18)
		NameLbl.Position = UDim2.new(0, 48, 0, 8)
		NameLbl.BackgroundTransparency = 1
		NameLbl.Text = displayName
		NameLbl.TextColor3 = Color3.fromRGB(225, 225, 225)
		NameLbl.FontFace = GetFontBold()
		NameLbl.TextSize = 11
		NameLbl.TextXAlignment = Enum.TextXAlignment.Left
		NameLbl.TextTruncate = Enum.TextTruncate.AtEnd
		local UserLbl = Instance.new("TextLabel", Row)
		UserLbl.Size = UDim2.new(1, -110, 0, 14)
		UserLbl.Position = UDim2.new(0, 48, 0, 27)
		UserLbl.BackgroundTransparency = 1
		UserLbl.Text = "@" .. username .. (inServer and "  ●" or "")
		UserLbl.TextColor3 = inServer and Color3.fromRGB(0, 200, 110) or Color3.fromRGB(80, 80, 80)
		UserLbl.FontFace = GetFontBold()
		UserLbl.TextSize = 9
		UserLbl.TextXAlignment = Enum.TextXAlignment.Left
		if canTP then
			local TPBtn = Instance.new("TextButton", Row)
			TPBtn.Size = UDim2.new(0, 48, 0, 26)
			TPBtn.Position = UDim2.new(1, -56, 0.5, -13)
			TPBtn.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
			TPBtn.BackgroundTransparency = 0.3
			TPBtn.Text = "TP"
			TPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			TPBtn.FontFace = GetFontBold()
			TPBtn.TextSize = 10
			TPBtn.AutoButtonColor = false
			Instance.new("UICorner", TPBtn).CornerRadius = UDim.new(0, 6)
			TPBtn.MouseEnter:Connect(function() TweenService:Create(TPBtn, TweenInfo.new(0.12), {BackgroundTransparency = 0}):Play() end)
			TPBtn.MouseLeave:Connect(function() TweenService:Create(TPBtn, TweenInfo.new(0.12), {BackgroundTransparency = 0.3}):Play() end)
			TPBtn.MouseButton1Click:Connect(function()
				if Commands then Commands.HandleChat("tp " .. username, UI, nil, true) end
				UI.Notify("Teleporting to " .. username, "Success")
			end)
		end
		table.insert(netBtns, Row)
	end

	local function RefreshNet()
		for _, c in pairs(NetScroll:GetChildren()) do
			if c:IsA("Frame") then c:Destroy() end
		end
		netBtns = {}
		NetStatusLbl.Text = "Fetching Lunar Network..."
		NetDot.BackgroundColor3 = Color3.fromRGB(255, 170, 50)

		task.spawn(function()
			local Net = getgenv().LunarNet
			if not Net then
				NetStatusLbl.Text = "Lunar Network unavailable"
				NetDot.BackgroundColor3 = Color3.fromRGB(255, 90, 90)
				return
			end

			local seen = {}
			local inServerIds = {}

			local ids = {}
			for _, p in ipairs(Players:GetPlayers()) do
				table.insert(ids, tostring(p.UserId))
			end
			local tags = Net.nametags(ids)

			for _, p in ipairs(Players:GetPlayers()) do
				if tags[tostring(p.UserId)] then
					inServerIds[p.UserId] = true
					seen[p.UserId] = true
					MakeUserRow(p.UserId, p.DisplayName, p.Name, true, true)
				end
			end

			local roster = Net.roster()
			for _, entry in ipairs(roster) do
				local uid = tonumber(entry.robloxId)
				if uid and not seen[uid] then
					seen[uid] = true
					local ok, name = pcall(function() return Players:GetNameFromUserIdAsync(uid) end)
					if ok and name then
						local ok2, display = pcall(function()
							local info = Players:GetUserInfosByUserIdsAsync({uid})
							return info and info[1] and info[1].DisplayName or name
						end)
						MakeUserRow(uid, ok2 and display or name, name, false, false)
					end
				end
			end

			local total = 0
			for _ in pairs(seen) do total += 1 end
			local serverCount = 0
			for _ in pairs(inServerIds) do serverCount += 1 end
			NetStatusLbl.Text = total .. " Lunar user" .. (total ~= 1 and "s" or "") .. " — " .. serverCount .. " here"
			NetDot.BackgroundColor3 = Color3.fromRGB(0, 220, 130)
		end)
	end

	NetSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
		local q = NetSearchBox.Text:lower()
		for _, r in pairs(netBtns) do r.Visible = q == "" or r.Name:lower():find(q) ~= nil end
	end)
	local origNetToggle = ToggleNetWin
	ToggleNetWin = function() RefreshNet() origNetToggle() end
	Players.PlayerAdded:Connect(function() if NetWin.Visible then RefreshNet() end end)
	Players.PlayerRemoving:Connect(function() task.wait(0.1) if NetWin.Visible then RefreshNet() end end)

	CreateIconBtn(134751195905316, Color3.fromRGB(215, 215, 215), function() ToggleCmdWin() end)
	CreateIconBtn(70849156584970,  Color3.fromRGB(100, 230, 130), ToggleConsole)
	CreateIconBtn(87094224829882,  Color3.fromRGB(200, 150, 255), function()
		if Commands then Commands.HandleChat("nametag", UI, ESP) end
	end)
	CreateIconBtn(109654827173212, Color3.fromRGB(100, 200, 255), function() ToggleNetWin() end)
	CreatePill("⚙", Color3.fromRGB(190, 190, 190), function() ToggleSettingsWin() end)

	local _fa, _ff = 0, 0
	RunService.RenderStepped:Connect(function(dt)
		_fa += dt; _ff += 1
		if _fa >= 0.5 then
			FPSLabel.Text = "FPS: " .. math.floor(_ff / _fa)
			PingLabel.Text = "PING: " .. math.floor(Player:GetNetworkPing() * 1000) .. "ms"
			_fa = 0; _ff = 0
		end
	end)
end

return UI
