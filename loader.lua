if getgenv().Lunar and getgenv().LunarReady then
	warn("[Lunar] already running")
	getgenv().Lunar.Notify("Lunar is already loaded", "Warn")
	return getgenv().Lunar
end
getgenv().LunarLoaded = true

local USER = "Lunaris-Development"
local REPO = "Lunar"
local BRANCH = "main"
local BASE = ("https://raw.githubusercontent.com/%s/%s/%s/"):format(USER, REPO, BRANCH)

local qot = queue_on_teleport or queueonteleport
if qot then
	pcall(qot, ('loadstring(game:HttpGet("%sloader.lua"))()'):format(BASE))
end

local function fetch(path)
	local url = BASE .. path .. "?v=" .. tostring(tick())
	local ok, body = pcall(game.HttpGet, game, url)
	if not ok or type(body) ~= "string" or body == "" then
		error(("fetch failed: %s (%s)"):format(path, tostring(body)), 0)
	end
	return body
end

local function run(path, ...)
	local src = fetch(path)
	local chunk, err = loadstring(src, "=" .. path)
	if not chunk then
		error(("compile %s: %s"):format(path, tostring(err)), 0)
	end
	return chunk(...)
end

local ok, Core = pcall(run, "src/core.lua")
if not ok then
	warn("[Lunar] core failed to load: " .. tostring(Core))
	getgenv().LunarLoaded = false
	return
end
getgenv().Lunar = Core

local MODULES = {
	"src/modules/movement.lua",
	"src/modules/player.lua",
	"src/modules/combat.lua",
	"src/modules/teleport.lua",
	"src/modules/visuals.lua",
	"src/modules/server.lua",
	"src/modules/fun.lua",
}

local loaded, failed = 0, {}
for _, path in ipairs(MODULES) do
	local success, err = pcall(run, path)
	if success then
		loaded += 1
	else
		table.insert(failed, path)
		warn(("[Lunar] module failed: %s -> %s"):format(path, tostring(err)))
	end
end

local uiOk, UI = pcall(run, "src/ui.lua")
if uiOk and UI then
	Core.UI = UI
	pcall(UI.Mount)
else
	warn("[Lunar] UI failed to load: " .. tostring(UI))
end

Core._maid:Give(Core.LocalPlayer.Chatted:Connect(function(msg)
	pcall(function() Core.Commands:Dispatch(msg, { source = "chat" }) end)
end))

Core.Notify(("Lunar v%s loaded — %d/%d modules"):format(Core.Version, loaded, #MODULES), "Success")
if #failed > 0 then
	Core.Notify(#failed .. " module(s) failed, see console (F9)", "Warn")
end

getgenv().LunarReady = true
return Core
