local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local lp = Players.LocalPlayer
local GlobalChat = {}

local TOPIC    = "lunar-admin-v1-chat-kx9p2m"
local BASE_URL = "https://ntfy.sh/" .. TOPIC
local SECRET   = "LunarAdminMsg::"

local history  = {}
local guiBuilt = false
local Win, MsgScroll, MsgLayout = nil, nil, nil
local lastSince = math.floor(os.time()) - 120
local lastSentText, lastSentUser = nil, nil

local ClickSnd = Instance.new("Sound")
ClickSnd.SoundId = "rbxassetid://7545317681"
ClickSnd.Volume = 0.18
ClickSnd.Parent = game:GetService("CoreGui")
local function Click() pcall(function() ClickSnd:Play() end) end

local function GetFont() return Font.fromEnum(Enum.Font.GothamBold) end

local function TimeStamp()
	return string.format("%02d:%02d", math.floor(os.time()/3600)%24, math.floor(os.time()/60)%60)
end

local function UserColor(name)
	if name == lp.Name then return Color3.fromRGB(120, 255, 165) end
	if name == "lnrs_dev" then return Color3.fromRGB(255, 90, 90) end
	local h = 0
	for i = 1, #name do h = (h * 31 + name:byte(i)) % 360 end
	return Color3.fromHSV(h / 360, 0.7, 1)
end

local function AppendRow(entry)
	if not MsgScroll then return end
	local color = Color3.fromRGB(entry.r or 120, entry.g or 255, entry.b or 165)

	local Row = Instance.new("Frame", MsgScroll)
	Row.Size = UDim2.new(1, 0, 0, 0)
	Row.AutomaticSize = Enum.AutomaticSize.Y
	Row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Row.BackgroundTransparency = 0.96
	Row.BorderSizePixel = 0
	Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6)
	local RP = Instance.new("UIPadding", Row)
	RP.PaddingLeft = UDim.new(0, 8); RP.PaddingRight = UDim.new(0, 8)
	RP.PaddingTop = UDim.new(0, 5); RP.PaddingBottom = UDim.new(0, 5)

	local Header = Instance.new("Frame", Row)
	Header.Size = UDim2.new(1, 0, 0, 16); Header.BackgroundTransparency = 1

	local NameLbl = Instance.new("TextLabel", Header)
	NameLbl.Size = UDim2.new(0, 0, 1, 0); NameLbl.BackgroundTransparency = 1
	NameLbl.Text = entry.user or "?"; NameLbl.TextColor3 = color
	NameLbl.FontFace = GetFont(); NameLbl.TextSize = 11
	NameLbl.TextXAlignment = Enum.TextXAlignment.Left; NameLbl.AutomaticSize = Enum.AutomaticSize.X

	local TimeLbl = Instance.new("TextLabel", Header)
	TimeLbl.Size = UDim2.new(1, 0, 1, 0); TimeLbl.BackgroundTransparency = 1
	TimeLbl.Text = entry.time or ""; TimeLbl.TextColor3 = Color3.fromRGB(65, 65, 65)
	TimeLbl.FontFace = GetFont(); TimeLbl.TextSize = 9
	TimeLbl.TextXAlignment = Enum.TextXAlignment.Right

	local MsgLbl = Instance.new("TextLabel", Row)
	MsgLbl.Size = UDim2.new(1, 0, 0, 0); MsgLbl.Position = UDim2.new(0, 0, 0, 18)
	MsgLbl.AutomaticSize = Enum.AutomaticSize.Y; MsgLbl.BackgroundTransparency = 1
	MsgLbl.Text = entry.text or ""; MsgLbl.TextColor3 = Color3.fromRGB(210, 210, 210)
	MsgLbl.FontFace = GetFont(); MsgLbl.TextSize = 11
	MsgLbl.TextXAlignment = Enum.TextXAlignment.Left; MsgLbl.TextWrapped = true
end

local function AddMessage(username, text, ts)
	local uc = UserColor(username)
	local entry = {
		time = ts or TimeStamp(), user = username, text = text,
		r = math.floor(uc.R*255), g = math.floor(uc.G*255), b = math.floor(uc.B*255),
	}
	table.insert(history, entry)
	while #history > 200 do table.remove(history, 1) end
	AppendRow(entry)
	if MsgScroll and MsgLayout then
		task.wait()
		MsgScroll.CanvasPosition = Vector2.new(0, MsgLayout.AbsoluteContentSize.Y)
	end
end

local function SendGlobal(text)
	local httpFunc = syn and syn.request or request or http_request or (http and http.request)
	if not httpFunc then return end
	pcall(function()
		httpFunc({
			Url = BASE_URL,
			Method = "POST",
			Headers = {["Title"] = lp.Name, ["Content-Type"] = "text/plain"},
			Body = SECRET .. text
		})
	end)
end

local function PollMessages()
	local httpFunc = syn and syn.request or request or http_request or (http and http.request)
	if not httpFunc then return end
	local ok, resp = pcall(function()
		return httpFunc({
			Url = BASE_URL .. "/json?poll=1&since=" .. tostring(lastSince),
			Method = "GET"
		})
	end)
	if not ok or not resp or not resp.Body or resp.Body == "" then return end

	for line in resp.Body:gmatch("[^\n]+") do
		local ok2, data = pcall(function() return HttpService:JSONDecode(line) end)
		if ok2 and data and data.message and data.time and data.time >= lastSince then
			lastSince = data.time + 1
			local msg = data.message
			if msg:sub(1, #SECRET) ~= SECRET then continue end
			msg = msg:sub(#SECRET + 1)
			local username = (data.title and data.title ~= "") and data.title or "Unknown"
			if username == lastSentUser and msg == lastSentText then
				lastSentText = nil; lastSentUser = nil
				continue
			end
			local ts = string.format("%02d:%02d", math.floor(data.time/3600)%24, math.floor(data.time/60)%60)
			AddMessage(username, msg, ts)
		end
	end
end

task.spawn(function()
	PollMessages()
	while true do
		task.wait(4)
		PollMessages()
	end
end)

local function BuildGUI()
	if guiBuilt and Win and Win.Parent then
		Win.Visible = not Win.Visible
		return
	end

	if game.CoreGui:FindFirstChild("LunarGlobalChat") then
		game.CoreGui.LunarGlobalChat:Destroy()
	end

	local SG = Instance.new("ScreenGui")
	SG.Name = "LunarGlobalChat"; SG.ResetOnSpawn = false
	SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; SG.Parent = game.CoreGui

	local W, H = 340, 430
	Win = Instance.new("TextButton")
	Win.Size = UDim2.new(0, W, 0, H); Win.Position = UDim2.new(0, 20, 0.5, -H/2)
	Win.BackgroundColor3 = Color3.fromRGB(12, 12, 12); Win.BackgroundTransparency = 0.05
	Win.BorderSizePixel = 0; Win.ZIndex = 30; Win.Text = ""; Win.AutoButtonColor = false
	Win.SelectionImageObject = Instance.new("Frame"); Win.Parent = SG
	Instance.new("UICorner", Win).CornerRadius = UDim.new(0, 13)
	local WStroke = Instance.new("UIStroke", Win)
	WStroke.Color = Color3.fromRGB(255,255,255); WStroke.Transparency = 0.87; WStroke.Thickness = 1

	local TBar = Instance.new("Frame", Win)
	TBar.Size = UDim2.new(1,0,0,42); TBar.BackgroundColor3 = Color3.fromRGB(18,18,18)
	TBar.BackgroundTransparency = 0; TBar.BorderSizePixel = 0; TBar.ZIndex = 31
	Instance.new("UICorner", TBar).CornerRadius = UDim.new(0,13)
	local TFill = Instance.new("Frame", TBar)
	TFill.Size = UDim2.new(1,0,0,13); TFill.Position = UDim2.new(0,0,1,-13)
	TFill.BackgroundColor3 = Color3.fromRGB(18,18,18); TFill.BorderSizePixel = 0

	local TitleLbl = Instance.new("TextLabel", TBar)
	TitleLbl.Size = UDim2.new(1,-60,1,0); TitleLbl.Position = UDim2.new(0,14,0,0)
	TitleLbl.BackgroundTransparency = 1; TitleLbl.Text = "Lunar Chat"
	TitleLbl.TextColor3 = Color3.fromRGB(220,220,220); TitleLbl.FontFace = GetFont()
	TitleLbl.TextSize = 13; TitleLbl.TextXAlignment = Enum.TextXAlignment.Left; TitleLbl.ZIndex = 32

	local LiveDot = Instance.new("Frame", TBar)
	LiveDot.Size = UDim2.new(0,7,0,7); LiveDot.Position = UDim2.new(0,100,0.5,-3.5)
	LiveDot.BackgroundColor3 = Color3.fromRGB(0,220,130); LiveDot.BorderSizePixel = 0; LiveDot.ZIndex = 32
	Instance.new("UICorner", LiveDot).CornerRadius = UDim.new(1,0)

	local GBadge = Instance.new("TextLabel", TBar)
	GBadge.Size = UDim2.new(0,50,0,17); GBadge.Position = UDim2.new(0,112,0.5,-8)
	GBadge.BackgroundColor3 = Color3.fromRGB(0,120,255); GBadge.BackgroundTransparency = 0.3
	GBadge.Text = "GLOBAL"; GBadge.TextColor3 = Color3.fromRGB(160,200,255)
	GBadge.FontFace = GetFont(); GBadge.TextSize = 8; GBadge.ZIndex = 32
	Instance.new("UICorner", GBadge).CornerRadius = UDim.new(0,4)

	local CloseBtn = Instance.new("TextButton", TBar)
	CloseBtn.Size = UDim2.new(0,13,0,13); CloseBtn.Position = UDim2.new(1,-26,0.5,-6.5)
	CloseBtn.BackgroundColor3 = Color3.fromRGB(255,95,87); CloseBtn.Text = ""
	CloseBtn.AutoButtonColor = false; CloseBtn.ZIndex = 33
	Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1,0)
	CloseBtn.MouseButton1Click:Connect(function() Click(); Win.Visible = false end)

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
			Win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
		end
	end)

	local Div = Instance.new("Frame", Win)
	Div.Size = UDim2.new(1,-24,0,1); Div.Position = UDim2.new(0,12,0,42)
	Div.BackgroundColor3 = Color3.fromRGB(255,255,255); Div.BackgroundTransparency = 0.9; Div.BorderSizePixel = 0; Div.ZIndex = 31

	MsgScroll = Instance.new("ScrollingFrame", Win)
	MsgScroll.Size = UDim2.new(1,-10,1,-98); MsgScroll.Position = UDim2.new(0,5,0,48)
	MsgScroll.BackgroundTransparency = 1; MsgScroll.BorderSizePixel = 0
	MsgScroll.CanvasSize = UDim2.new(0,0,0,0); MsgScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	MsgScroll.ScrollBarThickness = 2; MsgScroll.ScrollBarImageColor3 = Color3.fromRGB(80,80,80)
	MsgScroll.ScrollingDirection = Enum.ScrollingDirection.Y; MsgScroll.ZIndex = 31
	MsgLayout = Instance.new("UIListLayout", MsgScroll)
	MsgLayout.Padding = UDim.new(0,4); MsgLayout.SortOrder = Enum.SortOrder.LayoutOrder
	local MP = Instance.new("UIPadding", MsgScroll)
	MP.PaddingLeft = UDim.new(0,6); MP.PaddingRight = UDim.new(0,6)
	MP.PaddingTop = UDim.new(0,6); MP.PaddingBottom = UDim.new(0,6)

	for _, entry in ipairs(history) do AppendRow(entry) end

	local Div2 = Instance.new("Frame", Win)
	Div2.Size = UDim2.new(1,-24,0,1); Div2.Position = UDim2.new(0,12,1,-52)
	Div2.BackgroundColor3 = Color3.fromRGB(255,255,255); Div2.BackgroundTransparency = 0.9; Div2.BorderSizePixel = 0; Div2.ZIndex = 31

	local InputRow = Instance.new("Frame", Win)
	InputRow.Size = UDim2.new(1,-12,0,40); InputRow.Position = UDim2.new(0,6,1,-48)
	InputRow.BackgroundTransparency = 1; InputRow.ZIndex = 32

	local ChatInput = Instance.new("TextBox", InputRow)
	ChatInput.Size = UDim2.new(1,-44,1,0); ChatInput.BackgroundColor3 = Color3.fromRGB(24,24,24)
	ChatInput.BackgroundTransparency = 0.1; ChatInput.Text = ""
	ChatInput.PlaceholderText = "Message Lunar users globally..."; ChatInput.PlaceholderColor3 = Color3.fromRGB(60,60,60)
	ChatInput.TextColor3 = Color3.fromRGB(225,225,225); ChatInput.FontFace = GetFont()
	ChatInput.TextSize = 12; ChatInput.BorderSizePixel = 0; ChatInput.ZIndex = 33
	Instance.new("UICorner", ChatInput).CornerRadius = UDim.new(0,8)
	Instance.new("UIPadding", ChatInput).PaddingLeft = UDim.new(0,10)

	local SendBtn = Instance.new("TextButton", InputRow)
	SendBtn.Size = UDim2.new(0,36,1,0); SendBtn.Position = UDim2.new(1,-38,0,0)
	SendBtn.BackgroundColor3 = Color3.fromRGB(0,200,120); SendBtn.BackgroundTransparency = 0.2
	SendBtn.Text = "▶"; SendBtn.TextColor3 = Color3.fromRGB(255,255,255)
	SendBtn.FontFace = GetFont(); SendBtn.TextSize = 15; SendBtn.AutoButtonColor = false; SendBtn.ZIndex = 33
	Instance.new("UICorner", SendBtn).CornerRadius = UDim.new(0,8)
	SendBtn.MouseEnter:Connect(function() TweenService:Create(SendBtn, TweenInfo.new(0.12), {BackgroundTransparency=0}):Play() end)
	SendBtn.MouseLeave:Connect(function() TweenService:Create(SendBtn, TweenInfo.new(0.12), {BackgroundTransparency=0.2}):Play() end)

	local function DoSend()
		local txt = ChatInput.Text:match("^%s*(.-)%s*$")
		if txt == "" then return end
		Click(); ChatInput.Text = ""
		lastSentText = txt; lastSentUser = lp.Name
		AddMessage(lp.Name, txt)
		task.spawn(function() SendGlobal(txt) end)
	end

	SendBtn.MouseButton1Click:Connect(DoSend)
	ChatInput.FocusLost:Connect(function(enter) if enter then DoSend() end end)

	MsgLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		MsgScroll.CanvasPosition = Vector2.new(0, MsgLayout.AbsoluteContentSize.Y)
	end)

	guiBuilt = true
end

function GlobalChat.HandleChat(msg, UI)
	local cmd = msg:lower():split(" ")[1]
	if cmd == ".chat" or cmd == "chat" or cmd == "globalchat" then
		BuildGUI()
		if Win then Win.Visible = true end
	end
end

return GlobalChat
