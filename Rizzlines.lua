local Players = game:GetService("Players")

local lp = Players.LocalPlayer
local Rizzlines = {}

Rizzlines.Lines = {
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

local function send(line, UI)
	local ts = game:GetService("TextChatService")
	local sent = false
	pcall(function()
		local channels = ts:FindFirstChild("TextChannels")
		if channels then
			local general = channels:FindFirstChild("RBXGeneral")
			if general then
				general:SendAsync(line)
				sent = true
			end
		end
	end)
	if not sent then
		pcall(function() lp:Chat(line) end)
	end
	if UI then UI.Notify("Rizz sent!", "Success") end
end

function Rizzlines.SendLine(line, UI) send(line, UI) end

function Rizzlines.HandleChat(msg, UI)
	local cmd = msg:lower():split(" ")[1]
	if cmd == "rizz" then
		send(Rizzlines.Lines[math.random(1, #Rizzlines.Lines)], UI)
	end
end

return Rizzlines
