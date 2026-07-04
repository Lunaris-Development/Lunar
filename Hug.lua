local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer
local Hug = {}

local FRAMES = {
	{Time = 0, Data = {
		["Head"]         = CFrame.new(-0.000002,-0.000004,0.000004,0.985443,0.096246,-0.140140,-0.063813,0.973450,0.219825,0.157576,-0.207682,0.965421),
		["LeftHand"]     = CFrame.new(-0.000000,-0.000004,0.000001,1,0,0,0,1,0,0,0,1),
		["LeftLowerArm"] = CFrame.new(0.000001,0.000008,-0.000000,0.957031,-0.289985,-0.000019,0.289980,0.957014,0.006018,-0.001727,-0.005765,0.999982),
		["LeftUpperArm"] = CFrame.new(0.119543,-0.073067,0.000000,0.981637,0.004363,0.190706,0.162694,0.502803,-0.848952,-0.099592,0.864390,0.492860),
		["RightHand"]    = CFrame.new(-0.000000,0.000000,0.000001,1,0,0,0,0.999967,-0.008114,0,0.008114,0.999967),
		["RightLowerArm"]= CFrame.new(-0.000000,0.000004,0.000000,0.885155,0.465296,0.000024,-0.465296,0.885155,-0.000984,-0.000479,0.000860,1),
		["RightUpperArm"]= CFrame.new(-0.219006,-0.091167,-0.000011,0.910038,-0.193741,-0.366464,-0.151102,0.668190,-0.728485,0.386005,0.718323,0.578803),
		["UpperTorso"]   = CFrame.new(0,0,0,0.998957,0,0.045652,0,1,0,-0.045652,0,0.998957),
	}},
	{Time = 3.6, Data = {
		["LeftUpperArm"] = CFrame.new(0.119543,-0.073067,0,0.990187,0.037175,0.134713,0.098414,0.498898,-0.861055,-0.099218,0.865863,0.490344),
		["RightUpperArm"]= CFrame.new(-0.219006,-0.091168,-0.000015,0.901773,-0.161710,-0.400819,-0.195131,0.675153,-0.711401,0.385655,0.719735,0.577280),
		["UpperTorso"]   = CFrame.new(0,0.010918,0,0.999966,0,-0.008287,0,1,0,0.008287,0,0.999966),
	}},
	{Time = 7, Data = {
		["Head"]         = CFrame.new(-0.000002,-0.000004,0.000004,0.985443,0.096246,-0.140140,-0.063813,0.973450,0.219825,0.157576,-0.207682,0.965421),
		["LeftHand"]     = CFrame.new(-0.000000,-0.000004,0.000001,1,0,0,0,1,0,0,0,1),
		["LeftLowerArm"] = CFrame.new(0.000001,0.000008,-0.000000,0.957031,-0.289985,-0.000019,0.289980,0.957014,0.006018,-0.001727,-0.005765,0.999982),
		["LeftUpperArm"] = CFrame.new(0.119543,-0.073067,0,0.981637,0.004363,0.190706,0.162694,0.502803,-0.848952,-0.099592,0.864390,0.492860),
		["RightHand"]    = CFrame.new(-0.000000,0.000000,0.000001,1,0,0,0,0.999967,-0.008114,0,0.008114,0.999967),
		["RightLowerArm"]= CFrame.new(-0.000000,0.000004,0.000000,0.885155,0.465296,0.000024,-0.465296,0.885155,-0.000984,-0.000479,0.000860,1),
		["RightUpperArm"]= CFrame.new(-0.219006,-0.091167,-0.000011,0.910038,-0.193741,-0.366464,-0.151102,0.668190,-0.728485,0.386005,0.718323,0.578803),
		["UpperTorso"]   = CFrame.new(0,0,0,0.998957,0,0.045652,0,1,0,-0.045652,0,0.998957),
	}},
}

local function getJoints(char)
	local j = {}
	for _, d in ipairs(char:GetDescendants()) do
		if d:IsA("Motor6D") and d.Part1 then j[d.Part1.Name] = d end
	end
	return j
end

local function hugTarget(target, UI)
	local myHrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
	local myHum = lp.Character and lp.Character:FindFirstChild("Humanoid")
	local tHrp  = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
	if not myHrp or not myHum or not tHrp then return end

	myHrp.CFrame = tHrp.CFrame * CFrame.new(1.8, 0, 0)

	local char   = lp.Character
	local joints = getJoints(char)

	local animator = myHum:FindFirstChild("Animator")
	if animator then
		for _, t in ipairs(animator:GetPlayingAnimationTracks()) do t:Stop(0) end
	end
	local animScript = char:FindFirstChild("Animate")
	if animScript then animScript.Enabled = false end
	myHum.PlatformStand = true

	for partName, cf in pairs(FRAMES[1].Data) do
		if joints[partName] then joints[partName].Transform = cf end
	end

	for i = 1, #FRAMES - 1 do
		local dur = FRAMES[i + 1].Time - FRAMES[i].Time
		for partName, cf in pairs(FRAMES[i + 1].Data) do
			if joints[partName] then
				TweenService:Create(joints[partName], TweenInfo.new(dur, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transform = cf}):Play()
			end
		end
		task.wait(dur)
	end

	myHum.PlatformStand = false
	if animScript then animScript.Enabled = true end
	if UI then UI.Notify("Hugged " .. target.Name .. "!", "Success") end
end

local function nearest()
	local myHrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
	if not myHrp then return end
	local best, bestD = nil, math.huge
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= lp and p.Character then
			local h = p.Character:FindFirstChild("HumanoidRootPart")
			if h then
				local d = (h.Position - myHrp.Position).Magnitude
				if d < bestD then bestD = d best = p end
			end
		end
	end
	return best
end

function Hug.HandleChat(msg, UI)
	local parts = msg:lower():split(" ")
	if parts[1] ~= "hug" then return end
	if parts[2] then
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= lp and p.Name:lower():find(parts[2], 1, true) then
				task.spawn(hugTarget, p, UI); return
			end
		end
		if UI then UI.Notify("Player not found", "Error") end
	else
		local t = nearest()
		if t then task.spawn(hugTarget, t, UI)
		else if UI then UI.Notify("No players nearby", "Error") end
		end
	end
end

Hug._hugTarget = hugTarget
return Hug
