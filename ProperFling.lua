local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer
local ProperFling = {}

function ProperFling.Fling(targetPlayer)
	local char = lp.Character
	local hum  = char and char:FindFirstChildOfClass("Humanoid")
	local hrp  = char and char:FindFirstChild("HumanoidRootPart")
	if not char or not hum or not hrp then return end

	local tChar = targetPlayer.Character
	if not tChar then return end
	local tHum = tChar:FindFirstChildOfClass("Humanoid")
	local tHrp = tChar:FindFirstChild("HumanoidRootPart")
	if not tHum or not tHrp then return end

	local savedCF = hrp.CFrame
	workspace.FallenPartsDestroyHeight = 0/0

	local bv = Instance.new("BodyVelocity")
	bv.Velocity  = Vector3.new(-9e9, 9e9, -9e9)
	bv.MaxForce  = Vector3.new(9e9, 9e9, 9e9)
	bv.Parent    = hrp

	local bg = Instance.new("BodyGyro")
	bg.D         = 9e8
	bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
	bg.P         = -9e9
	bg.CFrame    = CFrame.new(hrp.Position)
	bg.Parent    = hrp

	local bp = Instance.new("BodyPosition")
	bp.Position  = hrp.Position
	bp.D         = 9e8
	bp.MaxForce  = Vector3.new(9e9, 9e9, 9e9)
	bp.P         = -9e9
	bp.Parent    = hrp

	local function snap(yOff)
		if not tHrp.Parent then return end
		hrp.CFrame = CFrame.new(tHrp.Position + Vector3.new(0, yOff, 0)) * CFrame.Angles(
			math.random() > 0.5 and math.pi or 0,
			math.random() > 0.5 and math.pi or 0,
			math.random() > 0.5 and math.pi or 0
		)
		hrp.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
	end

	local prevVel  = 0
	local launched = false
	local t0       = tick()

	repeat
		if not hrp.Parent or not tHrp.Parent then break end

		local vel = tHrp.AssemblyLinearVelocity.Magnitude
		local delta = vel - prevVel
		prevVel = vel

		if delta > 350 and vel > 400 then
			launched = true
			break
		end

		if vel < 60 then
			snap(1.5)
			RunService.Heartbeat:Wait()
			snap(-1.5)
			RunService.Heartbeat:Wait()
			snap(1.5)
			RunService.Heartbeat:Wait()
		elseif vel < 250 then
			snap(0)
			RunService.Heartbeat:Wait()
			snap(1.5)
			RunService.Heartbeat:Wait()
		else
			snap(-2)
			RunService.Heartbeat:Wait()
		end

	until launched
		or tHrp.AssemblyLinearVelocity.Magnitude > 900
		or tHrp.Parent ~= tChar
		or targetPlayer.Parent ~= Players
		or hum.Health <= 0
		or tick() - t0 > 8

	bv:Destroy(); bg:Destroy(); bp:Destroy()

	for _, p in ipairs(char:GetDescendants()) do
		if p:IsA("BasePart") then
			p.AssemblyLinearVelocity  = Vector3.zero
			p.AssemblyAngularVelocity = Vector3.zero
		end
	end

	hum:ChangeState(Enum.HumanoidStateType.GettingUp)
	task.wait(0.05)
	hrp.CFrame = savedCF
end

function ProperFling.HandleChat() end

return ProperFling
