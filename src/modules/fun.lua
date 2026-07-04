local Core = getgenv().Lunar
local Services = Core.Services

local LINES = {
	"Are you a magician? Because whenever I look at you, everyone else disappears.",
	"Do you have a map? I keep getting lost in your eyes.",
	"Is your name Google? Because you've got everything I've been searching for.",
	"Are you a WiFi signal? Because I'm feeling a connection.",
	"Do you like science? Because I've got my ion you.",
	"Are you French? Because Eiffel for you.",
	"Is your name Autumn? Because you're making me fall for you.",
	"Are you a bank loan? Because you've got my interest.",
	"Do you have a name, or can I call you mine?",
	"Are you a parking ticket? Because you've got fine written all over you.",
	"If you were a vegetable, you'd be a cute-cumber.",
	"Do you believe in love at first sight, or should I walk by again?",
	"Are you a campfire? Because you're hot and I want s'more.",
	"Is your dad a boxer? Because you're a knockout.",
	"Are you a time traveler? Because I can see you in my future.",
}

local function say(line)
	local sent = false
	pcall(function()
		local ts = Services.TextChatService
		local channels = ts and ts:FindFirstChild("TextChannels")
		local general = channels and channels:FindFirstChild("RBXGeneral")
		if general then general:SendAsync(line) sent = true end
	end)
	if not sent then pcall(function() Core.LocalPlayer:Chat(line) end) end
end

Core.Commands:Register{
	names = { "rizz" }, category = "Fun",
	desc = "Send a random pickup line in chat",
	run = function()
		local line = LINES[math.random(1, #LINES)]
		say(line)
		Core.Notify("Rizz sent!", "Success")
	end,
}
Core.Commands:Register{
	names = { "say", "chat" }, category = "Fun", usage = "say <message>",
	desc = "Send a chat message",
	run = function(args)
		if #args == 0 then return end
		say(table.concat(args, " "))
	end,
}
Core.Commands:Register{
	names = { "unload", "destroy" }, category = "Fun",
	desc = "Fully unload Lunar",
	run = function()
		Core.Notify("Unloading Lunar…", "Warn")
		task.wait(0.4)
		Core.destroy()
	end,
}

Core.RegisterModule({ Name = "Fun", Cleanup = function() end })
