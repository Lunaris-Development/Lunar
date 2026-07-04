local Core = getgenv().Lunar
local new = Core.new
local Services = Core.Services
local TweenService = Services.TweenService
local RunService = Services.RunService
local UserInputService = Services.UserInputService
local Players = Services.Players
local LocalPlayer = Core.LocalPlayer

local UI = {}
UI.Theme = {
	bg = Color3.fromRGB(15, 15, 20),
	panel = Color3.fromRGB(22, 22, 30),
	row = Color3.fromRGB(28, 28, 38),
	rowHover = Color3.fromRGB(36, 36, 48),
	text = Color3.fromRGB(235, 235, 245),
	sub = Color3.fromRGB(150, 150, 165),
	accentA = Color3.fromRGB(138, 43, 226),
	accentB = Color3.fromRGB(30, 144, 255),
	on = Color3.fromRGB(0, 220, 130),
	off = Color3.fromRGB(70, 70, 85),
	warn = Color3.fromRGB(255, 170, 50),
	error = Color3.fromRGB(255, 65, 65),
}
local T = UI.Theme

local function tween(inst, props, time, style, dir)
	local ti = TweenInfo.new(time or 0.25, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
	local tw = TweenService:Create(inst, ti, props)
	tw:Play()
	return tw
end

local function gradient(parent, rot)
	return new("UIGradient", {
		Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, T.accentA),
			ColorSequenceKeypoint.new(1, T.accentB),
		},
		Rotation = rot or 45,
	}, parent)
end

local ScreenGui = new("ScreenGui", {
	Name = "LunarHub",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	IgnoreGuiInset = true,
	DisplayOrder = 9999,
})
for _, g in ipairs(Core.getgui():GetChildren()) do
	if g.Name == "LunarHub" then pcall(function() g:Destroy() end) end
end
Core.parentProtected(ScreenGui)
Core._maid:Give(ScreenGui)

local NotifyHolder = new("Frame", {
	Name = "Notifications",
	Size = UDim2.new(0, 300, 1, -80),
	Position = UDim2.new(1, -12, 0, 12),
	AnchorPoint = Vector2.new(1, 0),
	BackgroundTransparency = 1,
}, ScreenGui)
new("UIListLayout", {
	Padding = UDim.new(0, 8),
	HorizontalAlignment = Enum.HorizontalAlignment.Right,
	VerticalAlignment = Enum.VerticalAlignment.Top,
	SortOrder = Enum.SortOrder.LayoutOrder,
}, NotifyHolder)

function UI.Notify(text, kind)
	kind = kind or "Info"
	local color = T.sub
	local head = "Info"
	if kind == "Success" then color = T.on; head = "Success"
	elseif kind == "Warn" then color = T.warn; head = "Warning"
	elseif kind == "Error" then color = T.error; head = "Error" end

	local slot = new("Frame", {
		Size = UDim2.new(0, 300, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	}, NotifyHolder)

	local card = new("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = T.panel,
		BackgroundTransparency = 0.05,
		Position = UDim2.new(1, 320, 0, 0),
	}, slot)
	new("UICorner", { CornerRadius = UDim.new(0, 10) }, card)
	local stroke = new("UIStroke", { Color = color, Transparency = 0.4, Thickness = 1 }, card)
	new("UIPadding", {
		PaddingTop = UDim.new(0, 9), PaddingBottom = UDim.new(0, 9),
		PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 12),
	}, card)
	new("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }, card)
	new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 15), BackgroundTransparency = 1,
		Text = head, TextColor3 = color, Font = Enum.Font.GothamBold, TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 1,
	}, card)
	new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1, Text = tostring(text), TextColor3 = T.text,
		Font = Enum.Font.Gotham, TextSize = 13, TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 2,
	}, card)

	tween(card, { Position = UDim2.new(0, 0, 0, 0) }, 0.35, Enum.EasingStyle.Back)
	task.delay(3.2, function()
		tween(stroke, { Transparency = 0.9 }, 0.3)
		tween(card, { Position = UDim2.new(1, 320, 0, 0) }, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		task.wait(0.32)
		pcall(function() slot:Destroy() end)
	end)
end
Core.SetNotifyHandler(UI.Notify)

local ToggleBtn = new("TextButton", {
	Name = "Launcher",
	Size = UDim2.new(0, 46, 0, 46),
	Position = UDim2.new(0, 14, 0, 90),
	BackgroundColor3 = T.bg,
	Text = "",
	AutoButtonColor = false,
}, ScreenGui)
new("UICorner", { CornerRadius = UDim.new(1, 0) }, ToggleBtn)
local launchStroke = new("UIStroke", { Thickness = 1.5 }, ToggleBtn)
gradient(launchStroke, 45)
new("ImageLabel", {
	Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(0.5, 0, 0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1,
	Image = "rbxthumb://type=Asset&id=73819038719454&w=150&h=150",
}, ToggleBtn)

local Window = new("Frame", {
	Name = "Window",
	Size = UDim2.new(0, 360, 0, 440),
	Position = UDim2.new(0, 70, 0, 90),
	BackgroundColor3 = T.bg,
	BorderSizePixel = 0,
	Visible = false,
	ClipsDescendants = true,
}, ScreenGui)
new("UICorner", { CornerRadius = UDim.new(0, 14) }, Window)
local winStroke = new("UIStroke", { Transparency = 0.4, Thickness = 1 }, Window)
gradient(winStroke, 90)

local Header = new("Frame", {
	Size = UDim2.new(1, 0, 0, 52), BackgroundColor3 = T.panel, BorderSizePixel = 0,
}, Window)
new("UICorner", { CornerRadius = UDim.new(0, 14) }, Header)
new("Frame", {
	Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 1, -14),
	BackgroundColor3 = T.panel, BorderSizePixel = 0,
}, Header)
new("TextLabel", {
	Size = UDim2.new(0, 200, 0, 22), Position = UDim2.new(0, 18, 0, 8),
	BackgroundTransparency = 1, Text = "LUNAR", TextColor3 = T.text,
	Font = Enum.Font.GothamBold, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left,
}, Header)
new("TextLabel", {
	Size = UDim2.new(0, 200, 0, 14), Position = UDim2.new(0, 19, 0, 30),
	BackgroundTransparency = 1, Text = "v" .. Core.Version .. "  •  " .. #Core.Commands:List() .. " commands",
	TextColor3 = T.sub, Font = Enum.Font.Gotham, TextSize = 11,
	TextXAlignment = Enum.TextXAlignment.Left,
}, Header)
local CloseBtn = new("TextButton", {
	Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(1, -38, 0, 12),
	BackgroundColor3 = T.row, Text = "✕", TextColor3 = T.sub,
	Font = Enum.Font.GothamBold, TextSize = 13, AutoButtonColor = false,
}, Header)
new("UICorner", { CornerRadius = UDim.new(0, 8) }, CloseBtn)

local Search = new("TextBox", {
	Size = UDim2.new(1, -28, 0, 32), Position = UDim2.new(0, 14, 0, 60),
	BackgroundColor3 = T.row, PlaceholderText = "Search commands…",
	PlaceholderColor3 = T.sub, Text = "", TextColor3 = T.text,
	Font = Enum.Font.Gotham, TextSize = 13, ClearTextOnFocus = false,
	TextXAlignment = Enum.TextXAlignment.Left,
}, Window)
new("UICorner", { CornerRadius = UDim.new(0, 9) }, Search)
new("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }, Search)

local List = new("ScrollingFrame", {
	Size = UDim2.new(1, -20, 1, -150), Position = UDim2.new(0, 10, 0, 100),
	BackgroundTransparency = 1, BorderSizePixel = 0,
	ScrollBarThickness = 3, ScrollBarImageColor3 = T.accentA,
	CanvasSize = UDim2.new(0, 0, 0, 0),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ScrollingDirection = Enum.ScrollingDirection.Y,
}, Window)
local listLayout = new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, List)
new("UIPadding", { PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 2) }, List)

local Console = new("TextBox", {
	Size = UDim2.new(1, -28, 0, 34), Position = UDim2.new(0, 14, 1, -44),
	BackgroundColor3 = T.panel, PlaceholderText = "› type a command and press Enter",
	PlaceholderColor3 = T.sub, Text = "", TextColor3 = T.text,
	Font = Enum.Font.Code, TextSize = 13, ClearTextOnFocus = true,
	TextXAlignment = Enum.TextXAlignment.Left,
}, Window)
new("UICorner", { CornerRadius = UDim.new(0, 9) }, Console)
local consoleStroke = new("UIStroke", { Color = T.accentA, Transparency = 0.6, Thickness = 1 }, Console)
new("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }, Console)

local rows = {}

local function makeRow(entry)
	local row = new("Frame", {
		Size = UDim2.new(1, 0, 0, 44), BackgroundColor3 = T.row,
		BorderSizePixel = 0, LayoutOrder = 1,
	}, List)
	new("UICorner", { CornerRadius = UDim.new(0, 9) }, row)
	new("TextLabel", {
		Size = UDim2.new(1, -70, 0, 16), Position = UDim2.new(0, 12, 0, 6),
		BackgroundTransparency = 1, Text = entry.names[1], TextColor3 = T.text,
		Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, row)
	new("TextLabel", {
		Size = UDim2.new(1, -70, 0, 14), Position = UDim2.new(0, 12, 0, 23),
		BackgroundTransparency = 1, Text = entry.desc ~= "" and entry.desc or table.concat(entry.names, ", "),
		TextColor3 = T.sub, Font = Enum.Font.Gotham, TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
	}, row)

	local control
	if entry.toggle then
		control = new("Frame", {
			Size = UDim2.new(0, 42, 0, 22), Position = UDim2.new(1, -54, 0.5, -11),
			BackgroundColor3 = T.off,
		}, row)
		new("UICorner", { CornerRadius = UDim.new(1, 0) }, control)
		local knob = new("Frame", {
			Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 3, 0.5, -8),
			BackgroundColor3 = Color3.fromRGB(240, 240, 245),
		}, control)
		new("UICorner", { CornerRadius = UDim.new(1, 0) }, knob)
		local btn = new("TextButton", {
			Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "",
		}, control)
		local function refresh()
			local on = entry.isOn and entry.isOn() or false
			tween(control, { BackgroundColor3 = on and T.on or T.off }, 0.18)
			tween(knob, { Position = on and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8) }, 0.18)
		end
		btn.MouseButton1Click:Connect(function()
			Core.Commands:Dispatch(entry.names[1], { source = "ui" })
			task.wait(0.05)
			refresh()
		end)
		row._refresh = refresh
		refresh()
	else
		control = new("TextButton", {
			Size = UDim2.new(0, 48, 0, 26), Position = UDim2.new(1, -60, 0.5, -13),
			BackgroundColor3 = T.accentA, Text = "Run", TextColor3 = T.text,
			Font = Enum.Font.GothamBold, TextSize = 11, AutoButtonColor = false,
		}, row)
		new("UICorner", { CornerRadius = UDim.new(0, 7) }, control)
		control.MouseButton1Click:Connect(function()
			if entry.usage then
				Console.Text = entry.names[1] .. " "
				Console:CaptureFocus()
			else
				Core.Commands:Dispatch(entry.names[1], { source = "ui" })
			end
		end)
	end

	row.MouseEnter:Connect(function() tween(row, { BackgroundColor3 = T.rowHover }, 0.15) end)
	row.MouseLeave:Connect(function() tween(row, { BackgroundColor3 = T.row }, 0.15) end)

	rows[#rows + 1] = { frame = row, entry = entry }
end

function UI.BuildList()
	for _, r in ipairs(rows) do pcall(function() r.frame:Destroy() end) end
	rows = {}
	local list = Core.Commands:List()
	table.sort(list, function(a, b)
		if a.category == b.category then return a.names[1] < b.names[1] end
		return a.category < b.category
	end)
	for _, entry in ipairs(list) do
		if entry.run then makeRow(entry) end
	end
end

local function refreshToggles()
	for _, r in ipairs(rows) do
		if r.frame._refresh then r.frame._refresh() end
	end
end

Search:GetPropertyChangedSignal("Text"):Connect(function()
	local q = Search.Text:lower()
	for _, r in ipairs(rows) do
		local match = q == ""
		if not match then
			for _, n in ipairs(r.entry.names) do
				if n:lower():find(q, 1, true) then match = true break end
			end
			if not match and r.entry.desc:lower():find(q, 1, true) then match = true end
		end
		r.frame.Visible = match
	end
end)

Console.FocusLost:Connect(function(enter)
	if enter and Console.Text ~= "" then
		local ok = Core.Commands:Dispatch(Console.Text, { source = "console" })
		if not ok then UI.Notify("Unknown command: " .. Console.Text, "Error") end
		Console.Text = ""
		task.wait(0.05)
		refreshToggles()
	end
end)

local menuOpen = false
function UI.ToggleMenu(force)
	if force ~= nil then menuOpen = not force end
	menuOpen = not menuOpen
	if menuOpen then
		Window.Visible = true
		Window.Size = UDim2.new(0, 360, 0, 0)
		refreshToggles()
		tween(Window, { Size = UDim2.new(0, 360, 0, 440) }, 0.32, Enum.EasingStyle.Back)
	else
		tween(Window, { Size = UDim2.new(0, 360, 0, 0) }, 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		task.delay(0.26, function() if not menuOpen then Window.Visible = false end end)
	end
end
ToggleBtn.MouseButton1Click:Connect(function() UI.ToggleMenu() end)
CloseBtn.MouseButton1Click:Connect(function() if menuOpen then UI.ToggleMenu() end end)

Core.Commands:Register{
	names = { "cmds", "menu", "gui" }, category = "Lunar",
	desc = "Open / close the Lunar menu",
	run = function() UI.ToggleMenu() end,
}

do
	local dragging, dragStart, startPos
	local function begin(input)
		dragging = true
		dragStart = input.Position
		startPos = Window.Position
	end
	Header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			begin(input)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			Window.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

local FlightStatus = new("Frame", {
	Size = UDim2.new(0, 220, 0, 54), AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, 80), BackgroundColor3 = T.panel,
	BackgroundTransparency = 0.08, BorderSizePixel = 0,
}, ScreenGui)
new("UICorner", { CornerRadius = UDim.new(0, 14) }, FlightStatus)
new("UIStroke", { Color = T.on, Transparency = 0.4, Thickness = 1 }, FlightStatus)
local FIcon = new("TextLabel", {
	Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(0, 12, 0.5, -14),
	BackgroundColor3 = T.on, BackgroundTransparency = 0.25, Text = "✈",
	TextColor3 = T.text, Font = Enum.Font.GothamBold, TextSize = 14,
}, FlightStatus)
new("UICorner", { CornerRadius = UDim.new(0, 7) }, FIcon)
new("TextLabel", {
	Size = UDim2.new(1, -100, 0, 18), Position = UDim2.new(0, 48, 0, 9),
	BackgroundTransparency = 1, Text = "FLY MODE", TextColor3 = T.on,
	Font = Enum.Font.GothamBold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
}, FlightStatus)
local FSpeed = new("TextLabel", {
	Size = UDim2.new(0, 60, 1, 0), Position = UDim2.new(1, -68, 0, 0),
	BackgroundTransparency = 1, Text = "2\nspd", TextColor3 = Color3.fromRGB(100, 200, 255),
	Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Center,
}, FlightStatus)
new("TextLabel", {
	Size = UDim2.new(1, -100, 0, 14), Position = UDim2.new(0, 48, 0, 30),
	BackgroundTransparency = 1, Text = "type  fly  to toggle", TextColor3 = T.sub,
	Font = Enum.Font.Gotham, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left,
}, FlightStatus)

function UI.UpdateFlightStatus(active, speed)
	tween(FlightStatus, {
		Position = UDim2.new(0.5, 0, 1, active and -14 or 80),
	}, 0.45, Enum.EasingStyle.Back)
	if speed then FSpeed.Text = math.floor(speed) .. "\nspd" end
end

local ServerPanel = new("Frame", {
	Size = UDim2.new(0, 225, 0, 160), Position = UDim2.new(1, 20, 0.5, -80),
	BackgroundColor3 = T.panel, BackgroundTransparency = 0.06, BorderSizePixel = 0,
}, ScreenGui)
new("UICorner", { CornerRadius = UDim.new(0, 11) }, ServerPanel)
new("UIStroke", { Color = T.accentB, Transparency = 0.55, Thickness = 1 }, ServerPanel)
new("TextLabel", {
	Size = UDim2.new(1, -20, 0, 30), Position = UDim2.new(0, 14, 0, 7),
	BackgroundTransparency = 1, Text = "SERVER INFO", TextColor3 = T.accentB,
	Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
}, ServerPanel)
local siRows = {}
for i, label in ipairs({ "Players", "Ping", "FPS", "Server Age", "Job ID" }) do
	local row = new("Frame", {
		Size = UDim2.new(1, -28, 0, 18), Position = UDim2.new(0, 14, 0, 16 + i * 21),
		BackgroundTransparency = 1,
	}, ServerPanel)
	new("TextLabel", {
		Size = UDim2.new(0.5, 0, 1, 0), BackgroundTransparency = 1, Text = label,
		TextColor3 = T.sub, Font = Enum.Font.Gotham, TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, row)
	siRows[label] = new("TextLabel", {
		Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0.5, 0, 0, 0),
		BackgroundTransparency = 1, Text = "—", TextColor3 = T.text,
		Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right,
	}, row)
end
local siOpen, siConn = false, nil
function UI.ToggleServerInfo(force)
	siOpen = (force ~= nil) and force or (not siOpen)
	if siOpen then
		tween(ServerPanel, { Position = UDim2.new(1, -240, 0.5, -80) }, 0.45, Enum.EasingStyle.Back)
		local acc, frames = 0, 0
		siConn = RunService.RenderStepped:Connect(function(dt)
			acc += dt; frames += 1
			if acc >= 0.5 then
				siRows["Players"].Text = #Players:GetPlayers() .. "/" .. Players.MaxPlayers
				siRows["Ping"].Text = math.floor(LocalPlayer:GetNetworkPing() * 1000) .. "ms"
				siRows["FPS"].Text = tostring(math.floor(frames / acc))
				siRows["Server Age"].Text = math.floor(workspace.DistributedGameTime / 60) .. "m"
				siRows["Job ID"].Text = (game.JobId ~= "" and game.JobId:sub(1, 10) .. "…") or "local"
				acc, frames = 0, 0
			end
		end)
		Core._maid:Give(siConn)
	else
		tween(ServerPanel, { Position = UDim2.new(1, 20, 0.5, -80) }, 0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		if siConn then siConn:Disconnect() siConn = nil end
	end
end

local CommandCard = new("Frame", {
	Size = UDim2.new(0, 280, 0, 70), Position = UDim2.new(1, 320, 0, 170),
	AnchorPoint = Vector2.new(1, 0), BackgroundColor3 = T.panel,
	BackgroundTransparency = 0.05, BorderSizePixel = 0,
}, ScreenGui)
new("UICorner", { CornerRadius = UDim.new(0, 10) }, CommandCard)
local ccStroke = new("UIStroke", { Color = T.accentA, Transparency = 0.9, Thickness = 1 }, CommandCard)
local ccTitle = new("TextLabel", {
	Size = UDim2.new(1, -24, 0, 18), Position = UDim2.new(0, 12, 0, 10),
	BackgroundTransparency = 1, Text = "", TextColor3 = T.accentB,
	Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
}, CommandCard)
local ccDesc = new("TextLabel", {
	Size = UDim2.new(1, -24, 0, 34), Position = UDim2.new(0, 12, 0, 30),
	BackgroundTransparency = 1, Text = "", TextColor3 = T.sub,
	Font = Enum.Font.Gotham, TextSize = 11, TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
}, CommandCard)
function UI.ShowCommandCard(title, desc)
	ccTitle.Text = tostring(title):upper()
	ccDesc.Text = desc or ""
	tween(ccStroke, { Transparency = 0.5 }, 0.2)
	tween(CommandCard, { Position = UDim2.new(1, -12, 0, 170) }, 0.5, Enum.EasingStyle.Back)
	task.delay(4.5, function()
		tween(ccStroke, { Transparency = 0.9 }, 0.3)
		tween(CommandCard, { Position = UDim2.new(1, 320, 0, 170) }, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
	end)
end

function UI.Mount()
	UI.BuildList()
	UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.RightControl then
			UI.ToggleMenu()
		end
	end)
	return UI
end

function UI.Init()
	return UI.Mount()
end

return UI
