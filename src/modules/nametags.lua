local Core = getgenv().Lunar
local Net = Core.Net
local Players = Core.Services.Players
local RunService = Core.Services.RunService

if not Net then return end

local State = { on = true }
local tags = {}
local roster = {}
local maid = Core.Maid()
local gui = Core.new("ScreenGui", { Name = "LunarTags", ResetOnSpawn = false })
Core.parentProtected(gui)
maid:Give(gui)

local function hexColor(hex)
	if type(hex) ~= "string" then return Color3.fromRGB(196, 181, 253) end
	hex = hex:gsub("#", "")
	local r = tonumber(hex:sub(1, 2), 16) or 196
	local g = tonumber(hex:sub(3, 4), 16) or 181
	local b = tonumber(hex:sub(5, 6), 16) or 253
	return Color3.fromRGB(r, g, b)
end

local function buildTag(player, info)
	local color = hexColor(info.color)
	local bb = Core.new("BillboardGui", {
		Name = "Tag_" .. player.UserId,
		Size = UDim2.new(0, 220, 0, 42),
		StudsOffset = Vector3.new(0, 3.4, 0),
		AlwaysOnTop = true,
		LightInfluence = 0,
		MaxDistance = 500,
	}, gui)
	local frame = Core.new("Frame", {
		Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(14, 14, 20),
		BackgroundTransparency = 0.15, BorderSizePixel = 0,
	}, bb)
	Core.new("UICorner", { CornerRadius = UDim.new(0, 10) }, frame)
	local stroke = Core.new("UIStroke", { Color = color, Thickness = 1.4, Transparency = 0.1 }, frame)
	Core.new("UIGradient", {
		Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, color),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
		},
		Rotation = 25,
	}, stroke)
	Core.new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 16), Position = UDim2.new(0, 0, 0, 5),
		BackgroundTransparency = 1, Text = info.label or "MEMBER", TextColor3 = color,
		Font = Enum.Font.GothamBold, TextSize = 12,
	}, frame)
	Core.new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 15), Position = UDim2.new(0, 0, 0, 21),
		BackgroundTransparency = 1, Text = "@" .. player.Name, TextColor3 = Color3.fromRGB(235, 235, 245),
		Font = Enum.Font.Gotham, TextSize = 12,
	}, frame)
	return bb
end

local function clearTag(player)
	local t = tags[player]
	if t then pcall(function() t:Destroy() end); tags[player] = nil end
end

local function updateTag(player, info)
	local char = player.Character
	local head = char and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))
	if not head then clearTag(player); return end
	local t = tags[player]
	if not t or not t.Parent or t:GetAttribute("role") ~= info.role then
		clearTag(player)
		t = buildTag(player, info)
		t:SetAttribute("role", info.role)
		tags[player] = t
	end
	t.Adornee = head
	t.Enabled = State.on
end

local function refresh()
	if not State.on then return end
	local ids, byId = {}, {}
	for _, p in ipairs(Players:GetPlayers()) do
		table.insert(ids, tostring(p.UserId))
		byId[tostring(p.UserId)] = p
	end
	if #ids == 0 then return end

	local map = Net.nametags(ids)
	local newRoster = {}

	for id, info in pairs(map) do
		local p = byId[id]
		if p then
			newRoster[id] = { player = p, role = info.role, label = info.label, color = info.color }
			if not roster[id] and p ~= Core.LocalPlayer then
				Core.Notify(("%s (%s) is on Lunar"):format(p.Name, info.label or info.role), "Success")
			end
			updateTag(p, info)
		end
	end

	for p in pairs(tags) do
		if not newRoster[tostring(p.UserId)] then clearTag(p) end
	end
	roster = newRoster
end

local Nametags = { Roster = function() return roster end }

function Nametags.set(on)
	State.on = on
	for _, t in pairs(tags) do t.Enabled = on end
	if on then refresh() end
	Core.Notify("Nametags: " .. (on and "ON" or "OFF"), on and "Success" or "Warn")
end

maid:Give(Players.PlayerRemoving:Connect(function(p) clearTag(p) end))
maid:Give(task.spawn(function()
	while true do
		pcall(refresh)
		task.wait(6)
	end
end))
task.defer(refresh)

Core.Commands:Register{
	names = { "nametags", "tags" }, category = "Lunar", toggle = true,
	desc = "Show role nametags above Lunar users",
	isOn = function() return State.on end,
	run = function() Nametags.set(not State.on) end,
}
Core.Commands:Register{
	names = { "lunars", "network" }, category = "Lunar",
	desc = "List Lunar users in this server",
	run = function()
		local names = {}
		for _, r in pairs(roster) do
			if r.player ~= Core.LocalPlayer then table.insert(names, r.player.Name .. " (" .. (r.label or r.role) .. ")") end
		end
		if #names == 0 then Core.Notify("No other Lunar users here", "Warn")
		else Core.Notify(#names .. " Lunar user(s): " .. table.concat(names, ", "), "Success") end
	end,
}
Core.Commands:Register{
	names = { "tplunar", "tpl" }, category = "Lunar",
	desc = "Teleport to the nearest Lunar user",
	run = function()
		local myHrp = Core.getHRP()
		if not myHrp then return end
		local best, bestDist
		for _, r in pairs(roster) do
			local p = r.player
			if p ~= Core.LocalPlayer and p.Character then
				local hrp = p.Character:FindFirstChild("HumanoidRootPart")
				if hrp then
					local d = (hrp.Position - myHrp.Position).Magnitude
					if not bestDist or d < bestDist then best, bestDist = p, d end
				end
			end
		end
		if best and best.Character then
			myHrp.CFrame = best.Character.HumanoidRootPart.CFrame * CFrame.new(3, 0, 0)
			Core.Notify("TP → " .. best.Name, "Success")
		else
			Core.Notify("No Lunar users to teleport to", "Warn")
		end
	end,
}

Core.RegisterModule({ Name = "Nametags", Cleanup = function() maid:Clean() end })
