local Core = getgenv().Lunar
local Services = Core.Services
local Players = Services.Players
local RunService = Services.RunService
local Debris = Services.Debris

local State = { aimlock = false, reach = false, touchfling = false }
local aimMaid = Core.Maid()
local reachMaid = Core.Maid()
local touchMaid = Core.Maid()
local reachDist = 20

local function setAimlock(on)
	State.aimlock = on
	aimMaid:Clean()
	if on then
		aimMaid:Give(RunService.RenderStepped:Connect(function()
			local cam = workspace.CurrentCamera
			local target = Core.nearestPlayer(cam.CFrame.Position)
			if target and target.Character then
				local hrp = target.Character:FindFirstChild("HumanoidRootPart")
				if hrp then
					cam.CFrame = CFrame.new(cam.CFrame.Position, hrp.Position + Vector3.new(0, 1.5, 0))
				end
			end
		end))
		Core.Notify("Aim Lock: ON", "Success")
	else
		Core.Notify("Aim Lock: OFF", "Warn")
	end
end

local function setReach(dist, on)
	if dist then reachDist = dist end
	State.reach = (on == nil) and (not State.reach) or on
	reachMaid:Clean()
	if State.reach then
		reachMaid:Give(RunService.Heartbeat:Connect(function()
			local hrp = Core.getHRP()
			if not hrp then return end
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= Core.LocalPlayer and p.Character then
					local tHrp = p.Character:FindFirstChild("HumanoidRootPart")
					if tHrp and (tHrp.Position - hrp.Position).Magnitude <= reachDist then
						local bv = Core.new("BodyVelocity", {
							Velocity = (tHrp.Position - hrp.Position).Unit * 180 + Vector3.new(0, 80, 0),
							MaxForce = Vector3.new(math.huge, math.huge, math.huge),
						}, tHrp)
						Debris:AddItem(bv, 0.12)
					end
				end
			end
		end))
		Core.Notify("Reach: ON (" .. reachDist .. " studs)", "Success")
	else
		Core.Notify("Reach: OFF", "Warn")
	end
end

local function fling(target)
	local char = Core.getChar()
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hum or not hrp then return end
	local tChar = target and target.Character
	local tHrp = tChar and tChar:FindFirstChild("HumanoidRootPart")
	if not tHrp then Core.Notify("Target not found", "Error") return end

	Core.Notify("Flinging " .. target.Name, "Success")
	local savedCF = hrp.CFrame
	pcall(function() workspace.FallenPartsDestroyHeight = 0 / 0 end)

	local bv = Core.new("BodyVelocity", {
		Velocity = Vector3.new(-9e9, 9e9, -9e9), MaxForce = Vector3.new(9e9, 9e9, 9e9),
	}, hrp)
	local bg = Core.new("BodyGyro", {
		D = 9e8, MaxTorque = Vector3.new(9e9, 9e9, 9e9), P = -9e9, CFrame = CFrame.new(hrp.Position),
	}, hrp)
	local bp = Core.new("BodyPosition", {
		Position = hrp.Position, D = 9e8, MaxForce = Vector3.new(9e9, 9e9, 9e9), P = -9e9,
	}, hrp)

	local function snap(yOff)
		if not tHrp.Parent then return end
		hrp.CFrame = CFrame.new(tHrp.Position + Vector3.new(0, yOff, 0)) * CFrame.Angles(
			math.random() > 0.5 and math.pi or 0,
			math.random() > 0.5 and math.pi or 0,
			math.random() > 0.5 and math.pi or 0
		)
		hrp.AssemblyAngularVelocity = Vector3.new(9e8, 9e8, 9e8)
	end

	local prevVel, launched, t0 = 0, false, tick()
	repeat
		if not hrp.Parent or not tHrp.Parent then break end
		local vel = tHrp.AssemblyLinearVelocity.Magnitude
		local delta = vel - prevVel
		prevVel = vel
		if delta > 350 and vel > 400 then launched = true break end
		if vel < 60 then
			snap(1.5); RunService.Heartbeat:Wait()
			snap(-1.5); RunService.Heartbeat:Wait()
			snap(1.5); RunService.Heartbeat:Wait()
		elseif vel < 250 then
			snap(0); RunService.Heartbeat:Wait()
			snap(1.5); RunService.Heartbeat:Wait()
		else
			snap(-2); RunService.Heartbeat:Wait()
		end
	until launched
		or tHrp.AssemblyLinearVelocity.Magnitude > 900
		or tHrp.Parent ~= tChar
		or target.Parent ~= Players
		or hum.Health <= 0
		or tick() - t0 > 8

	pcall(function() bv:Destroy() end)
	pcall(function() bg:Destroy() end)
	pcall(function() bp:Destroy() end)
	for _, p in ipairs(char:GetDescendants()) do
		if p:IsA("BasePart") then
			p.AssemblyLinearVelocity = Vector3.zero
			p.AssemblyAngularVelocity = Vector3.zero
		end
	end
	hum:ChangeState(Enum.HumanoidStateType.GettingUp)
	task.wait(0.05)
	hrp.CFrame = savedCF
end

local function setTouchFling(on)
	State.touchfling = on
	touchMaid:Clean()
	local function applySpin(hrp)
		if hrp:FindFirstChild("LunarSpin") then return end
		local bav = Core.new("BodyAngularVelocity", {
			Name = "LunarSpin", AngularVelocity = Vector3.new(0, 9999, 0),
			MaxTorque = Vector3.new(0, math.huge, 0),
		}, hrp)
		touchMaid:Give(bav)
	end
	if on then
		local hrp = Core.getHRP()
		if hrp then applySpin(hrp) end
		touchMaid:Give(Core.onCharacter(function(c)
			local h = c:WaitForChild("HumanoidRootPart", 5)
			if h and State.touchfling then applySpin(h) end
		end))
		Core.Notify("Touch Fling: ON — walk into players", "Success")
	else
		Core.Notify("Touch Fling: OFF", "Warn")
	end
end

Core.Commands:Register{
	names = { "aimlock", "al" }, category = "Combat", toggle = true,
	desc = "Snap camera to nearest player",
	isOn = function() return State.aimlock end,
	run = function() setAimlock(not State.aimlock) end,
}
Core.Commands:Register{
	names = { "reach" }, category = "Combat", toggle = true, usage = "reach <studs>",
	desc = "Push nearby players away",
	isOn = function() return State.reach end,
	run = function(args) setReach(tonumber(args[1])) end,
}
Core.Commands:Register{
	names = { "fling" }, category = "Combat", usage = "fling <player>",
	desc = "Fling a specific player",
	run = function(args)
		local target = args[1] and Core.findPlayer(args[1]) or Core.nearestPlayer()
		fling(target)
	end,
}
Core.Commands:Register{
	names = { "touchfling", "tfling" }, category = "Combat", toggle = true,
	desc = "Fling anyone you touch",
	isOn = function() return State.touchfling end,
	run = function() setTouchFling(not State.touchfling) end,
}

Core.RegisterModule({
	Name = "Combat",
	Cleanup = function() setAimlock(false); setReach(nil, false); setTouchFling(false) end,
})
