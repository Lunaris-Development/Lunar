local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local lp = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Commands = { _UI = nil }

local isMobile = UserInputService.TouchEnabled

local freecamActive = false
local freecamConn = nil
local fcKeysDown = {}
local fcRotating = false
local fcSpeed = 1.2
local touchPos = nil
local touchDelta = Vector2.new(0, 0)

local function toggleFreecam(UI)
	freecamActive = not freecamActive
	local char = lp.Character
	local hum = char and char:FindFirstChild("Humanoid")
	local hrp = char and char:FindFirstChild("HumanoidRootPart")

	if freecamActive then
		if hum then hum.PlatformStand = true end
		if hrp then hrp.Anchored = true end
		Camera.CameraType = Enum.CameraType.Scriptable

		freecamConn = RunService.RenderStepped:Connect(function()
			if not freecamActive then return end
			local spd = fcSpeed

			if fcRotating then
				local delta
				if isMobile then
					delta = touchDelta
					touchDelta = Vector2.new(0, 0)
				else
					delta = UserInputService:GetMouseDelta()
					UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
				end
				local cf = Camera.CFrame
				cf = cf * CFrame.Angles(-math.rad(delta.Y * 0.3), 0, 0)
				cf = CFrame.Angles(0, -math.rad(delta.X * 0.3), 0) * (cf - cf.Position) + cf.Position
				Camera.CFrame = cf
			else
				if not isMobile then
					UserInputService.MouseBehavior = Enum.MouseBehavior.Default
				end
			end

			if isMobile then
				local md = (lp.Character and lp.Character:FindFirstChild("Humanoid") and lp.Character.Humanoid.MoveDirection) or Vector3.zero
				if md.Magnitude > 0.1 then
					Camera.CFrame = Camera.CFrame * CFrame.new(md.X * spd, 0, md.Z * spd)
				end
			else
				if fcKeysDown[Enum.KeyCode.W] then Camera.CFrame = Camera.CFrame * CFrame.new(0, 0, -spd) end
				if fcKeysDown[Enum.KeyCode.S] then Camera.CFrame = Camera.CFrame * CFrame.new(0, 0, spd) end
				if fcKeysDown[Enum.KeyCode.A] then Camera.CFrame = Camera.CFrame * CFrame.new(-spd, 0, 0) end
				if fcKeysDown[Enum.KeyCode.D] then Camera.CFrame = Camera.CFrame * CFrame.new(spd, 0, 0) end
				if fcKeysDown[Enum.KeyCode.E] then Camera.CFrame = Camera.CFrame * CFrame.new(0, spd, 0) end
				if fcKeysDown[Enum.KeyCode.Q] then Camera.CFrame = Camera.CFrame * CFrame.new(0, -spd, 0) end
			end
		end)
		if UI and UI.Notify then UI.Notify("Freecam: ON" .. (isMobile and " (drag to rotate)" or ""), "Success") end
	else
		if freecamConn then freecamConn:Disconnect() freecamConn = nil end
		if hum then hum.PlatformStand = false end
		if hrp then hrp.Anchored = false end
		Camera.CameraType = Enum.CameraType.Custom
		if not isMobile then UserInputService.MouseBehavior = Enum.MouseBehavior.Default end
		if UI and UI.Notify then UI.Notify("Freecam: OFF", "Warn") end
	end
end

local flyActive = false
local flyDebounce = false
local _flyPos, _flyGyro = nil, nil

local function stopFly(hrp, hum, UI)
	if _flyPos then pcall(function() _flyPos.MaxForce = Vector3.new(0,0,0) end) end
	if _flyGyro then pcall(function() _flyGyro.MaxTorque = Vector3.new(0,0,0) end) end
	pcall(function() if hrp:FindFirstChild("LunarFlyPos") then hrp.LunarFlyPos:Destroy() end end)
	pcall(function() if hrp:FindFirstChild("LunarFlyGyro") then hrp.LunarFlyGyro:Destroy() end end)
	_flyPos = nil; _flyGyro = nil
	pcall(function() hum.PlatformStand = false end)
	if UI and UI.Notify then UI.Notify("Fly: OFF", "Warn") end
	if UI and UI.UpdateFlightStatus then UI.UpdateFlightStatus(false) end
end

local function toggleFly(UI)
	if flyDebounce then return end
	flyDebounce = true
	flyActive = not flyActive

	local char = lp.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChild("Humanoid")

	if not hrp or not hum then
		flyActive = not flyActive
		flyDebounce = false
		return
	end

	if flyActive then
		pcall(function() if hrp:FindFirstChild("LunarFlyPos") then hrp.LunarFlyPos:Destroy() end end)
		pcall(function() if hrp:FindFirstChild("LunarFlyGyro") then hrp.LunarFlyGyro:Destroy() end end)

		_flyPos = Instance.new("BodyPosition")
		_flyPos.Name = "LunarFlyPos"
		_flyPos.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		_flyPos.Position = hrp.Position
		_flyPos.Parent = hrp

		_flyGyro = Instance.new("BodyGyro")
		_flyGyro.Name = "LunarFlyGyro"
		_flyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		_flyGyro.CFrame = hrp.CFrame
		_flyGyro.Parent = hrp

		hum.PlatformStand = true
		if UI and UI.Notify then UI.Notify("Fly: ON", "Success") end
		if UI and UI.UpdateFlightStatus then UI.UpdateFlightStatus(true) end

		task.delay(0.5, function() flyDebounce = false end)

		local topSpeed = 2
		local speedInc = topSpeed / 25
		local curSpeed = 0
		local bPos = _flyPos
		local bGyro = _flyGyro

		task.spawn(function()
			while flyActive and hrp.Parent do
				if not bPos.Parent or not bGyro.Parent then break end
				local camera = workspace.CurrentCamera
				local fwd   = UserInputService:IsKeyDown(Enum.KeyCode.W)
				local back  = UserInputService:IsKeyDown(Enum.KeyCode.S)
				local left  = UserInputService:IsKeyDown(Enum.KeyCode.A)
				local right = UserInputService:IsKeyDown(Enum.KeyCode.D)
				local up    = UserInputService:IsKeyDown(Enum.KeyCode.Space)
				local down  = UserInputService:IsKeyDown(Enum.KeyCode.Q) or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)

				if isMobile then
					local md = hum.MoveDirection
					if md.Magnitude > 0.1 then fwd = true end
				end

				local new = bGyro.CFrame.Rotation + bPos.Position

				if not (fwd or back or up or down or left or right) then
					curSpeed = 1
				else
					if up    then new = new * CFrame.new(0,  curSpeed, 0); curSpeed = curSpeed + speedInc end
					if down  then new = new * CFrame.new(0, -curSpeed, 0); curSpeed = curSpeed + speedInc end
					if fwd   then new = new + camera.CFrame.LookVector * curSpeed;  curSpeed = curSpeed + speedInc end
					if back  then new = new - camera.CFrame.LookVector * curSpeed;  curSpeed = curSpeed + speedInc end
					if left  then new = new * CFrame.new(-curSpeed, 0, 0); curSpeed = curSpeed + speedInc end
					if right then new = new * CFrame.new( curSpeed, 0, 0); curSpeed = curSpeed + speedInc end
					if curSpeed > topSpeed then curSpeed = topSpeed end
				end

				hum.PlatformStand = true
				bPos.Position = new.p

				if fwd then
					bGyro.CFrame = camera.CFrame * CFrame.Angles(-math.rad(curSpeed * 7.5), 0, 0)
				elseif back then
					bGyro.CFrame = camera.CFrame * CFrame.Angles(math.rad(curSpeed * 7.5), 0, 0)
				else
					bGyro.CFrame = camera.CFrame
				end

				RunService.RenderStepped:Wait()
			end
			pcall(function() bPos:Destroy() end)
			pcall(function() bGyro:Destroy() end)
			pcall(function() hum.PlatformStand = false end)
		end)
	else
		stopFly(hrp, hum, UI)
		task.delay(0.5, function() flyDebounce = false end)
	end
end

UserInputService.InputBegan:Connect(function(input, gpe)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		fcKeysDown[input.KeyCode] = true
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
		fcRotating = true
	elseif input.UserInputType == Enum.UserInputType.Touch then
		touchPos = input.Position
		if freecamActive then fcRotating = true end
	end

	if freecamActive and not gpe then
		if input.KeyCode == Enum.KeyCode.B then
			fcSpeed = math.min(fcSpeed + 1, 50)
			if Commands._UI then Commands._UI.Notify("FC Speed: " .. fcSpeed, "Success") end
		end
	end

	if not gpe and input.KeyCode == Enum.KeyCode.P and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
		toggleFreecam(Commands._UI)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch and freecamActive and fcRotating and touchPos then
		touchDelta = Vector2.new(input.Position.X - touchPos.X, input.Position.Y - touchPos.Y)
		touchPos = input.Position
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		fcKeysDown[input.KeyCode] = false
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
		fcRotating = false
	elseif input.UserInputType == Enum.UserInputType.Touch then
		fcRotating = false
		touchPos = nil
		touchDelta = Vector2.new(0, 0)
	end
end)

function Commands.ToggleFreecam(UI) toggleFreecam(UI) end

function Commands.HandleChat(msg, UI, ESP, silent)
	local cleanMsg = msg:lower()
	local args = cleanMsg:split(" ")
	local cmd = args[1]

	if cmd:sub(1, 2) == "l?" then
		cmd = cmd:sub(3)
	end

	if cmd == "freecam" or cmd == "fc" then
		toggleFreecam(UI)
	elseif cmd == "fly" then
		toggleFly(UI)
	elseif cmd == "speed" or cmd == "ws" then
		local num = tonumber(args[2])
		if num and lp.Character and lp.Character:FindFirstChild("Humanoid") then
			lp.Character.Humanoid.WalkSpeed = num
			if UI and not silent then
				UI.Notify("Speed: " .. num, "Success")
			end
			if UI and UI.UpdateFlightStatus and flyActive then
				UI.UpdateFlightStatus(true, num)
			end
		elseif not num then
			fcSpeed = 1.2
			if UI and not silent then UI.Notify("FC Speed Reset", "Warn") end
		end
	elseif cmd == "esp" then
		if ESP then
			ESP.Toggle(not ESP.Enabled)
			if UI then UI.Notify("ESP " .. (ESP.Enabled and "ON" or "OFF"), ESP.Enabled and "Success" or "Warn") end
		end
	elseif cmd == "cmds" then
		if UI and UI.ToggleMenu then UI.ToggleMenu() end
	end
end

return Commands
