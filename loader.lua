if getgenv().LunarLoaded and game:GetService("CoreGui"):FindFirstChild("LunarDynamicIsland") then
	warn("Lunar is already running!")
	return
end
getgenv().LunarLoaded = true

local BaseURL = "https://raw.githubusercontent.com/Lunaris-Development/Lunar/main/"
local function GetBust() return "?t=" .. tostring(tick()) end

local function Load(file)
	local content = game:HttpGet(BaseURL .. file .. GetBust())
	return loadstring(content)()
end

local qot = queue_on_teleport or queueonteleport
if qot then
	pcall(qot, ('loadstring(game:HttpGet("%sloader.lua"))()'):format(BaseURL))
end

local Net = Load("net.lua")

local function denyAndStop(reason, banReason)
	local msg = (reason == "banned" and ("You are banned from Lunar." .. (banReason and (" (" .. banReason .. ")") or "")))
		or (reason == "expired" and "Your Lunar access has expired.")
		or (reason == "inactive" and "Your Lunar access is disabled.")
		or (reason == "offline" and "Could not reach Lunar servers. Try again shortly.")
		or "You don't have access to Lunar."
	warn("[Lunar] " .. msg)
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = "Lunar", Text = msg, Duration = 8,
		})
	end)
	getgenv().LunarLoaded = false
end

local auth = Net.auth()
if not auth or not auth.access then
	denyAndStop(auth and auth.reason, auth and auth.banReason)
	return
end

local UI = Load("UI.lua")
local Nametags = Load("Nametags.lua")
local ESP = Load("ESP.lua")
local Freecam = Load("Freecam.lua")
local AntiAFK = Load("AntiAFK.lua")
local ClickTP = Load("ClickTP.lua")
local LagSpoof = Load("LagSpoof.lua")
local UserSpoofer = Load("UserSpoofer.lua")
local ServerInfo = Load("ServerInfo.lua")
local ServerList = Load("ServerList.lua")
local LoopSpeed = Load("LoopSpeed.lua")

local ShLow = Load("ShLow.lua")
local ShMost = Load("ShMost.lua")
local Noclip = Load("Noclip.lua")
local InfJump = Load("InfJump.lua")
local GodMode = Load("GodMode.lua")
local PlayerTP = Load("PlayerTP.lua")
local WalkOnAir = Load("WalkOnAir.lua")
local Invisible = Load("Invisible.lua")
local Reach = Load("Reach.lua")
local AimLock = Load("AimLock.lua")
local Hug = Load("Hug.lua")
local Flip = Load("Flip.lua")
local Rizzlines = Load("Rizzlines.lua")
local ProperFling = Load("ProperFling.lua")
local Animations = Load("Animations.lua")
local NametageGUI = Load("NametageGUI.lua")
local GlobalChat = Load("GlobalChat.lua")

local allModules = {
	Freecam, AntiAFK, ClickTP, LagSpoof, UserSpoofer,
	ServerInfo, ServerList, LoopSpeed,
	ShLow, ShMost, Noclip, InfJump, GodMode, PlayerTP,
	WalkOnAir, Invisible, Reach, AimLock, Hug, Flip,
	Rizzlines, ProperFling, Animations, NametageGUI, GlobalChat
}

local Commands = {}
setmetatable(Commands, {
	__newindex = function(t, k, v)
		rawset(t, k, v)
		if k == "_UI" then Freecam._UI = v end
	end
})

function Commands.HandleChat(msg, UI_ref, ESP_ref, silent)
	for _, mod in ipairs(allModules) do
		if mod.HandleChat then
			pcall(mod.HandleChat, msg, UI_ref or Commands._UI, ESP_ref, silent)
		end
	end
end

Commands.ToggleFreecam = function(UI_ref)
	if Freecam.ToggleFreecam then Freecam.ToggleFreecam(UI_ref) end
end

UI.Init(Nametags, Commands, ESP, Rizzlines, Animations, ProperFling)
Nametags.Init()

game:GetService("Players").LocalPlayer.Chatted:Connect(function(msg)
	pcall(function()
		Commands.HandleChat(msg, UI, ESP)
	end)
end)

UI.Notify(("Welcome back, %s — %s"):format(game:GetService("Players").LocalPlayer.Name, Net.Label or Net.Role), "Success")

getgenv().LunarReady = true
