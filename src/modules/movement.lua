local Core = getgenv().Lunar
local Services = Core.Services
local RunService = Services.RunService
local UserInputService = Services.UserInputService

local State = { fly = false, noclip = false, air = false, infjump = false, loopspeed = false }
local flyMaid = Core.Maid()
local noclipMaid = Core.Maid()
local airMaid = Core.Maid()
local jumpMaid = Core.Maid()
local speedMaid = Core.Maid()

local loopSpeedValue = 50

local function isMobile()
	return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

local function setFly(on)
	State.fly = on
	flyMaid:Clean()
	if not on then
		local hum = Core.getHum()
		if hum then pcall(function() hum.PlatformStand = false end) end
		Core.Notify("Fly: OFF", "Warn")
		if Core.UI then Core.UI.UpdateFlightStatus(false) end
		return
	end

	local hrp, hum = Core.getHRP(), Core.getHum()
	if not hrp or not hum then State.fly = false return end

	local bodyPos = Core.new("BodyPosition", {
		Name = "LunarFlyPos", MaxForce = Vector3.new(math.huge, math.huge, math.huge),
		P = 20000, D = 500, Position = hrp.Position,
	}, hrp)
	local bodyGyro = Core.new("BodyGyro", {
		Name = "LunarFlyGyro", MaxTorque = Vector3.new(9e9, 9e9, 9e9),
		P = 9e4, CFrame = hrp.CFrame,
	}, hrp)
	flyMaid:Give(bodyPos)
	flyMaid:Give(bodyGyro)
	hum.PlatformStand = true

	Core.Notify("Fly: ON", "Success")
	if Core.UI then Core.UI.UpdateFlightStatus(true) end

	local topSpeed = 2
	local accel = topSpeed / 25
	local curSpeed = 1

	local thread = task.spawn(function()
		while State.fly do
			local h = Core.getHRP()
			local humNow = Core.getHum()
			if not h or not humNow or not bodyPos.Parent or not bodyGyro.Parent then break end
			local cam = workspace.CurrentCamera
			local fwd = UserInputService:IsKeyDown(Enum.KeyCode.W)
			local back = UserInputService:IsKeyDown(Enum.KeyCode.S)
			local left = UserInputService:IsKeyDown(Enum.KeyCode.A)
			local right = UserInputService:IsKeyDown(Enum.KeyCode.D)
			local up = UserInputService:IsKeyDown(Enum.KeyCode.Space)
			local down = UserInputService:IsKeyDown(Enum.KeyCode.Q)
				or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)

			if isMobile() and humNow.MoveDirection.Magnitude > 0.1 then fwd = true end

			local target = bodyGyro.CFrame.Rotation + bodyPos.Position
			if not (fwd or back or up or down or left or right) then
				curSpeed = 1
			else
				if up then target = target * CFrame.new(0, curSpeed, 0) end
				if down then target = target * CFrame.new(0, -curSpeed, 0) end
				if fwd then target = target + cam.CFrame.LookVector * curSpeed end
				if back then target = target - cam.CFrame.LookVector * curSpeed end
				if left then target = target * CFrame.new(-curSpeed, 0, 0) end
				if right then target = target * CFrame.new(curSpeed, 0, 0) end
				curSpeed = math.min(curSpeed + accel, topSpeed)
			end

			humNow.PlatformStand = true
			bodyPos.Position = target.Position
			if fwd then
				bodyGyro.CFrame = cam.CFrame * CFrame.Angles(-math.rad(curSpeed * 7.5), 0, 0)
			elseif back then
				bodyGyro.CFrame = cam.CFrame * CFrame.Angles(math.rad(curSpeed * 7.5), 0, 0)
			else
				bodyGyro.CFrame = cam.CFrame
			end
			RunService.RenderStepped:Wait()
		end
	end)
	flyMaid:Give(thread)
	flyMaid:Give(Core.LocalPlayer.CharacterAdded:Connect(function()
		if State.fly then setFly(false) end
	end))
end

local function setNoclip(on)
	State.noclip = on
	noclipMaid:Clean()
	if on then
		noclipMaid:Give(RunService.Stepped:Connect(function()
			local char = Core.getChar()
			if not char then return end
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") and part.CanCollide then
					part.CanCollide = false
				end
			end
		end))
		Core.Notify("Noclip: ON", "Success")
	else
		local char = Core.getChar()
		if char then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
					pcall(function() part.CanCollide = true end)
				end
			end
		end
		Core.Notify("Noclip: OFF", "Warn")
	end
end

local function setAir(on)
	State.air = on
	airMaid:Clean()
	if on then
		local hrp = Core.getHRP()
		if not hrp then State.air = false return end
		local bp = Core.new("BodyPosition", {
			Name = "LunarAir", MaxForce = Vector3.new(0, math.huge, 0),
			P = 10000, D = 1000, Position = hrp.Position,
		}, hrp)
		airMaid:Give(bp)
		airMaid:Give(RunService.Heartbeat:Connect(function()
			local h = Core.getHRP()
			if not h or not bp.Parent then return end
			if h.Position.Y > bp.Position.Y + 0.5 then
				bp.Position = Vector3.new(bp.Position.X, h.Position.Y, bp.Position.Z)
			end
		end))
		Core.Notify("Walk on Air: ON", "Success")
	else
		Core.Notify("Walk on Air: OFF", "Warn")
	end
end

local function setInfJump(on)
	State.infjump = on
	jumpMaid:Clean()
	if on then
		jumpMaid:Give(UserInputService.JumpRequest:Connect(function()
			local hum = Core.getHum()
			if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
		end))
		Core.Notify("Infinite Jump: ON", "Success")
	else
		Core.Notify("Infinite Jump: OFF", "Warn")
	end
end

local function setSpeed(value)
	local hum = Core.getHum()
	if not hum then return end
	value = value or 16
	hum.WalkSpeed = value
	Core.Notify("WalkSpeed: " .. value, "Success")
end

local function setLoopSpeed(value)
	speedMaid:Clean()
	if value then loopSpeedValue = value end
	State.loopspeed = not State.loopspeed
	if State.loopspeed then
		speedMaid:Give(Core.onCharacter(function(char)
			local hum = char:WaitForChild("Humanoid", 5)
			if hum then hum.WalkSpeed = loopSpeedValue end
		end))
		Core.Notify("Loop Speed: " .. loopSpeedValue, "Success")
	else
		local hum = Core.getHum()
		if hum then hum.WalkSpeed = 16 end
		Core.Notify("Loop Speed: OFF", "Warn")
	end
end

Core.Commands:Register{
	names = { "fly" }, category = "Movement", toggle = true,
	desc = "Camera-relative smooth flight (WASD + Space/Shift)",
	isOn = function() return State.fly end,
	run = function() setFly(not State.fly) end,
}
Core.Commands:Register{
	names = { "noclip", "nc" }, category = "Movement", toggle = true,
	desc = "Walk through walls",
	isOn = function() return State.noclip end,
	run = function() setNoclip(not State.noclip) end,
}
Core.Commands:Register{
	names = { "walkair", "wa", "walkonair" }, category = "Movement", toggle = true,
	desc = "Stand on invisible ground at current height",
	isOn = function() return State.air end,
	run = function() setAir(not State.air) end,
}
Core.Commands:Register{
	names = { "infjump", "ij" }, category = "Movement", toggle = true,
	desc = "Jump infinitely in mid-air",
	isOn = function() return State.infjump end,
	run = function() setInfJump(not State.infjump) end,
}
Core.Commands:Register{
	names = { "speed", "ws" }, category = "Movement", usage = "speed <number>",
	desc = "Set WalkSpeed once",
	run = function(args) setSpeed(tonumber(args[1])) end,
}
Core.Commands:Register{
	names = { "loopspeed", "lspeed" }, category = "Movement", toggle = true,
	usage = "loopspeed <number>", desc = "Persistent WalkSpeed across respawns",
	isOn = function() return State.loopspeed end,
	run = function(args) setLoopSpeed(tonumber(args[1])) end,
}
Core.Commands:Register{
	names = { "jumppower", "jp" }, category = "Movement", usage = "jumppower <number>",
	desc = "Set JumpPower / JumpHeight",
	run = function(args)
		local hum = Core.getHum()
		if not hum then return end
		local n = tonumber(args[1]) or 50
		pcall(function() hum.UseJumpPower = true end)
		pcall(function() hum.JumpPower = n end)
		pcall(function() hum.JumpHeight = n / 10 end)
		Core.Notify("JumpPower: " .. n, "Success")
	end,
}

Core.RegisterModule({
	Name = "Movement",
	Cleanup = function()
		setFly(false); setNoclip(false); setAir(false); setInfJump(false)
		if State.loopspeed then setLoopSpeed() end
	end,
})
