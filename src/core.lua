local Core = {}
Core.__index = Core
Core.Version = "2.0.0"
Core.Name = "Lunar"

local Services = setmetatable({}, {
	__index = function(self, name)
		local ok, service = pcall(game.GetService, game, name)
		if ok and service then
			rawset(self, name, service)
			return service
		end
		return nil
	end,
})
Core.Services = Services

local Players = Services.Players
local RunService = Services.RunService
local UserInputService = Services.UserInputService
local HttpService = Services.HttpService

Core.LocalPlayer = Players.LocalPlayer
Core.Camera = workspace.CurrentCamera

local function identity(...) return ... end

Core.Exploit = {
	hui = (typeof(gethui) == "function") and gethui or nil,
	protect = (typeof(syn) == "table" and syn.protect_gui)
		or (typeof(protectgui) == "function" and protectgui)
		or nil,
	writefile = (typeof(writefile) == "function") and writefile or nil,
	readfile = (typeof(readfile) == "function") and readfile or nil,
	isfile = (typeof(isfile) == "function") and isfile or nil,
	makefolder = (typeof(makefolder) == "function") and makefolder or nil,
	isfolder = (typeof(isfolder) == "function") and isfolder or nil,
	setclipboard = (typeof(setclipboard) == "function") and setclipboard or function() end,
	request = (typeof(syn) == "table" and syn.request)
		or (typeof(request) == "function" and request)
		or (typeof(http_request) == "function" and http_request)
		or (typeof(http) == "table" and http.request)
		or nil,
	queueteleport = (typeof(queue_on_teleport) == "function" and queue_on_teleport)
		or (typeof(queueonteleport) == "function" and queueonteleport)
		or nil,
}

function Core.getgui()
	local target
	if Core.Exploit.hui then
		local ok, gui = pcall(Core.Exploit.hui)
		if ok and gui then target = gui end
	end
	target = target or Services.CoreGui
	return target
end

function Core.parentProtected(screenGui)
	local parent = Core.getgui()
	if Core.Exploit.protect then
		pcall(Core.Exploit.protect, screenGui)
	end
	screenGui.Parent = parent
	return screenGui
end

function Core.new(class, props, parent)
	local inst = Instance.new(class)
	if props then
		for k, v in pairs(props) do
			if k ~= "Parent" then
				pcall(function() inst[k] = v end)
			end
		end
	end
	if parent then inst.Parent = parent end
	return inst
end

local Maid = {}
Maid.__index = Maid
function Maid.new()
	return setmetatable({ _tasks = {} }, Maid)
end
function Maid:Give(item)
	if item == nil then return end
	table.insert(self._tasks, item)
	return item
end
Maid.GiveTask = Maid.Give
function Maid:Clean()
	local tasks = self._tasks
	self._tasks = {}
	for i = #tasks, 1, -1 do
		local item = tasks[i]
		local t = typeof(item)
		if t == "RBXScriptConnection" then
			pcall(function() item:Disconnect() end)
		elseif t == "Instance" then
			pcall(function() item:Destroy() end)
		elseif t == "function" then
			pcall(item)
		elseif t == "thread" then
			pcall(task.cancel, item)
		elseif t == "table" then
			if typeof(item.Disconnect) == "function" then
				pcall(function() item:Disconnect() end)
			elseif typeof(item.Destroy) == "function" then
				pcall(function() item:Destroy() end)
			elseif typeof(item.Clean) == "function" then
				pcall(function() item:Clean() end)
			end
		end
	end
end
Maid.DoCleaning = Maid.Clean
Maid.Destroy = Maid.Clean
function Core.Maid() return Maid.new() end

local Signal = {}
Signal.__index = Signal
function Signal.new()
	return setmetatable({ _handlers = {} }, Signal)
end
function Signal:Connect(fn)
	local handlers = self._handlers
	handlers[fn] = true
	return {
		Disconnect = function() handlers[fn] = nil end,
		Connected = true,
	}
end
function Signal:Fire(...)
	for fn in pairs(self._handlers) do
		task.spawn(fn, ...)
	end
end
function Signal:Destroy()
	self._handlers = {}
end
function Core.Signal() return Signal.new() end

function Core.getChar()
	return Core.LocalPlayer.Character
end
function Core.getHRP()
	local char = Core.LocalPlayer.Character
	return char and char:FindFirstChild("HumanoidRootPart")
end
function Core.getHum()
	local char = Core.LocalPlayer.Character
	return char and char:FindFirstChildOfClass("Humanoid")
end

function Core.onCharacter(fn, maid)
	local player = Core.LocalPlayer
	if player.Character then
		task.spawn(fn, player.Character)
	end
	local conn = player.CharacterAdded:Connect(function(char)
		task.wait(0.2)
		fn(char)
	end)
	if maid then maid:Give(conn) end
	return conn
end

function Core.nearestPlayer(fromPos, maxDist)
	fromPos = fromPos or (Core.getHRP() and Core.getHRP().Position) or Core.Camera.CFrame.Position
	local closest, bestDist = nil, maxDist or math.huge
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= Core.LocalPlayer and p.Character then
			local hrp = p.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				local d = (hrp.Position - fromPos).Magnitude
				if d < bestDist then
					bestDist = d
					closest = p
				end
			end
		end
	end
	return closest, bestDist
end

function Core.findPlayer(query)
	if not query or query == "" then return nil end
	query = query:lower()
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= Core.LocalPlayer then
			if p.Name:lower() == query or p.DisplayName:lower() == query then return p end
		end
	end
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= Core.LocalPlayer then
			if p.Name:lower():sub(1, #query) == query then return p end
		end
	end
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= Core.LocalPlayer then
			if p.Name:lower():find(query, 1, true) or p.DisplayName:lower():find(query, 1, true) then
				return p
			end
		end
	end
	return nil
end

local Config = {}
Config.__index = Config
Config.folder = "Lunar"
Config.file = "Lunar/config.json"
Config._data = {}

function Config:_ensureFolder()
	local ex = Core.Exploit
	if ex.makefolder and ex.isfolder then
		pcall(function()
			if not ex.isfolder(self.folder) then ex.makefolder(self.folder) end
		end)
	end
end

function Config:Load()
	local ex = Core.Exploit
	if ex.isfile and ex.readfile and ex.isfile(self.file) then
		local ok, decoded = pcall(function()
			return HttpService:JSONDecode(ex.readfile(self.file))
		end)
		if ok and type(decoded) == "table" then
			self._data = decoded
		end
	end
	return self._data
end

function Config:Save()
	local ex = Core.Exploit
	if not ex.writefile then return false end
	self:_ensureFolder()
	local ok, encoded = pcall(function()
		return HttpService:JSONEncode(self._data)
	end)
	if ok then
		pcall(ex.writefile, self.file, encoded)
		return true
	end
	return false
end

function Config:Get(key, default)
	local v = self._data[key]
	if v == nil then return default end
	return v
end

function Config:Set(key, value)
	self._data[key] = value
	self:Save()
end

Core.Config = setmetatable(Config, Config)
Core.Config:Load()

Core._notifyHandler = nil
function Core.Notify(text, kind)
	if Core._notifyHandler then
		pcall(Core._notifyHandler, text, kind or "Info")
	else
		print(("[%s] %s"):format(Core.Name, tostring(text)))
	end
end
function Core.SetNotifyHandler(fn)
	Core._notifyHandler = fn
end

local Commands = {}
Commands.__index = Commands
Commands._list = {}
Commands._lookup = {}
Commands.Prefixes = { "l?", ";", ".", "/", "!" }

function Commands:Register(def)
	assert(type(def) == "table" and def.names, "command def requires names")
	local entry = {
		names = def.names,
		run = def.run,
		desc = def.desc or "",
		usage = def.usage,
		category = def.category or "Misc",
		toggle = def.toggle == true,
		isOn = def.isOn,
	}
	table.insert(self._list, entry)
	for _, name in ipairs(def.names) do
		self._lookup[name:lower()] = entry
	end
	return entry
end

function Commands:_strip(msg)
	local lowered = msg:lower()
	for _, pre in ipairs(self.Prefixes) do
		if lowered:sub(1, #pre) == pre then
			return msg:sub(#pre + 1)
		end
	end
	return msg
end

function Commands:Dispatch(rawMsg, opts)
	if type(rawMsg) ~= "string" then return false end
	local msg = self:_strip(rawMsg):gsub("^%s+", "")
	if msg == "" then return false end
	local args = msg:split(" ")
	local cmd = table.remove(args, 1):lower()
	local entry = self._lookup[cmd]
	if not entry or not entry.run then return false end
	opts = opts or {}
	local ok, err = pcall(entry.run, args, opts)
	if not ok then
		Core.Notify("Error in '" .. cmd .. "': " .. tostring(err), "Error")
		warn("[Lunar] command '" .. cmd .. "' failed: " .. tostring(err))
	end
	return true, entry
end

function Commands:List()
	return self._list
end

Core.Commands = setmetatable(Commands, Commands)

Core.Modules = {}
function Core.RegisterModule(def)
	table.insert(Core.Modules, def)
	return def
end

function Core.destroy()
	if Core._maid then Core._maid:Clean() end
	for _, mod in ipairs(Core.Modules) do
		if type(mod.Cleanup) == "function" then
			pcall(mod.Cleanup)
		end
	end
	getgenv().Lunar = nil
	getgenv().LunarLoaded = false
end

Core._maid = Maid.new()

return Core
