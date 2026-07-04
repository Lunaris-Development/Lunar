local Players = game:GetService("Players")

local lp = Players.LocalPlayer
local Invisible = {}
local active = false
local charConn = nil

local function apply(char, on)
	for _, d in ipairs(char:GetDescendants()) do
		if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" then
			d.Transparency = on and 1 or 0
		elseif d:IsA("Decal") or d:IsA("SpecialMesh") then
			if d:IsA("Decal") then d.Transparency = on and 1 or 0 end
		end
	end
end

local function toggle(UI)
	active = not active
	if lp.Character then apply(lp.Character, active) end
	if active then
		charConn = lp.CharacterAdded:Connect(function(char)
			task.wait(0.5)
			if active then apply(char, true) end
		end)
	else
		if charConn then charConn:Disconnect() charConn = nil end
	end
	if UI then UI.Notify("Invisible: " .. (active and "ON" or "OFF"), active and "Success" or "Warn") end
end

function Invisible.HandleChat(msg, UI)
	local cmd = msg:lower():split(" ")[1]
	if cmd == "invis" or cmd == "invisible" or cmd == "inv" then toggle(UI) end
end

return Invisible
