local Core = getgenv().Lunar
local Services = Core.Services
local RunService = Services.RunService
local UserInputService = Services.UserInputService
local Debris = Services.Debris

local State = { god = false, invis = false, freecam = false }
local godMaid = Core.Maid()
local invisMaid = Core.Maid()
local freecamMaid = Core.Maid()

local function applyGod(char)
	local hum = char:WaitForChild("Humanoid", 5)
	if not hum then return end
	pcall(function() hum.MaxHealth = math.huge end)
	pcall(function() hum.Health = math.huge end)
	godMaid:Give(hum.HealthChanged:Connect(function()
		if State.god then pcall(function() hum.Health = math.huge end) end
	end))
end

local function setGod(on)
	State.god = on
	godMaid:Clean()
	if on then
		local char = Core.getChar()
		if char then applyGod(char) end
		godMaid:Give(Core.onCharacter(function(c) if State.god then applyGod(c) end end))
		Core.Notify("God Mode: ON", "Success")
	else
		local hum = Core.getHum()
		if hum then pcall(function() hum.MaxHealth = 100; hum.Health = 100 end) end
		Core.Notify("God Mode: OFF", "Warn")
	end
end

local function applyInvis(char, on)
	for _, d in ipairs(char:GetDescendants()) do
		if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" then
			d.Transparency = on and 1 or 0
		elseif d:IsA("Decal") then
			d.Transparency = on and 1 or 0
		end
	end
end

local function setInvis(on)
	State.invis = on
	invisMaid:Clean()
	local char = Core.getChar()
	if char then applyInvis(char, on) end
	if on then
		invisMaid:Give(Core.onCharacter(function(c) if State.invis then applyInvis(c, true) end end))
	end
	Core.Notify("Invisible: " .. (on and "ON" or "OFF"), on and "Success" or "Warn")
end

local fcKeys = {}
local fcSpeed = 1.2
local fcRotating = false
local fcTouchPos, fcTouchDelta = nil, Vector2.new()

local function setFreecam(on)
	State.freecam = on
	freecamMaid:Clean()
	local cam = workspace.CurrentCamera
	local char = Core.getChar()
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local mobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

	if on then
		if hum then hum.PlatformStand = true end
		if hrp then hrp.Anchored = true end
		cam.CameraType = Enum.CameraType.Scriptable
		freecamMaid:Give(function()
			pcall(function() if hum then hum.PlatformStand = false end end)
			pcall(function() if hrp then hrp.Anchored = false end end)
			cam.CameraType = Enum.CameraType.Custom
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		end)
		freecamMaid:Give(RunService.RenderStepped:Connect(function()
			if not State.freecam then return end
			local spd = fcSpeed
			if fcRotating then
				local delta
				if mobile then
					delta = fcTouchDelta
					fcTouchDelta = Vector2.new()
				else
					delta = UserInputService:GetMouseDelta()
					UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
				end
				local cf = cam.CFrame
				cf = cf * CFrame.Angles(-math.rad(delta.Y * 0.3), 0, 0)
				cf = CFrame.Angles(0, -math.rad(delta.X * 0.3), 0) * (cf - cf.Position) + cf.Position
				cam.CFrame = cf
			elseif not mobile then
				UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			end
			if fcKeys[Enum.KeyCode.W] then cam.CFrame = cam.CFrame * CFrame.new(0, 0, -spd) end
			if fcKeys[Enum.KeyCode.S] then cam.CFrame = cam.CFrame * CFrame.new(0, 0, spd) end
			if fcKeys[Enum.KeyCode.A] then cam.CFrame = cam.CFrame * CFrame.new(-spd, 0, 0) end
			if fcKeys[Enum.KeyCode.D] then cam.CFrame = cam.CFrame * CFrame.new(spd, 0, 0) end
			if fcKeys[Enum.KeyCode.E] then cam.CFrame = cam.CFrame * CFrame.new(0, spd, 0) end
			if fcKeys[Enum.KeyCode.Q] then cam.CFrame = cam.CFrame * CFrame.new(0, -spd, 0) end
		end))
		Core.Notify("Freecam: ON (RMB/drag rotate, B faster)", "Success")
	else
		Core.Notify("Freecam: OFF", "Warn")
	end
end

Core._maid:Give(UserInputService.InputBegan:Connect(function(input, gpe)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		fcKeys[input.KeyCode] = true
		if State.freecam and not gpe and input.KeyCode == Enum.KeyCode.B then
			fcSpeed = math.min(fcSpeed + 1, 50)
			Core.Notify("FC Speed: " .. fcSpeed, "Success")
		end
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
		fcRotating = true
	elseif input.UserInputType == Enum.UserInputType.Touch then
		fcTouchPos = input.Position
		if State.freecam then fcRotating = true end
	end
end))
Core._maid:Give(UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch and State.freecam and fcRotating and fcTouchPos then
		fcTouchDelta = Vector2.new(input.Position.X - fcTouchPos.X, input.Position.Y - fcTouchPos.Y)
		fcTouchPos = input.Position
	end
end))
Core._maid:Give(UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		fcKeys[input.KeyCode] = false
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
		fcRotating = false
	elseif input.UserInputType == Enum.UserInputType.Touch then
		fcRotating = false
		fcTouchPos = nil
		fcTouchDelta = Vector2.new()
	end
end))

local function doFlip(forward)
	local hrp, hum = Core.getHRP(), Core.getHum()
	if not hrp or not hum then return end
	local axis = hrp.CFrame.RightVector
	hum.PlatformStand = true
	local bv = Core.new("BodyVelocity", {
		Velocity = Vector3.new(0, 85, 0), MaxForce = Vector3.new(0, math.huge, 0),
	}, hrp)
	Debris:AddItem(bv, 0.17)
	local bav = Core.new("BodyAngularVelocity", {
		AngularVelocity = axis * (forward and -24 or 24),
		MaxTorque = Vector3.new(math.huge, math.huge, math.huge),
	}, hrp)
	Debris:AddItem(bav, 0.62)
	task.delay(0.72, function()
		local h = Core.getHum()
		if h then h.PlatformStand = false end
	end)
	Core.Notify((forward and "Front" or "Back") .. "flip!", "Success")
end

Core.Commands:Register{
	names = { "god", "godmode" }, category = "Player", toggle = true,
	desc = "Infinite health",
	isOn = function() return State.god end,
	run = function() setGod(not State.god) end,
}
Core.Commands:Register{
	names = { "invis", "invisible", "inv" }, category = "Player", toggle = true,
	desc = "Turn your character transparent",
	isOn = function() return State.invis end,
	run = function() setInvis(not State.invis) end,
}
Core.Commands:Register{
	names = { "freecam", "fc" }, category = "Player", toggle = true,
	desc = "Detached camera (WASD/EQ, RMB rotate, B faster)",
	isOn = function() return State.freecam end,
	run = function() setFreecam(not State.freecam) end,
}
Core.Commands:Register{
	names = { "flip", "frontflip", "ff" }, category = "Player",
	desc = "Do a frontflip",
	run = function() doFlip(true) end,
}
Core.Commands:Register{
	names = { "backflip", "bflip", "bf" }, category = "Player",
	desc = "Do a backflip",
	run = function() doFlip(false) end,
}

Core.RegisterModule({
	Name = "Player",
	Cleanup = function() setGod(false); setInvis(false); setFreecam(false) end,
})
