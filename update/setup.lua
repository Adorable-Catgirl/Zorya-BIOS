--setup.lua
--Zorya Init Modules
--...this doesn't get installed, by the way...
local args = {...}

local component = component or require("component")
local proxy, list=component.proxy, component.list

--Time to actually get some display, thanks to our trusty GPU.
local gpu = proxy(list("gpu")())
local screen = proxy(list("screen")())

gpu.bind(screen)
--And now we have output.

--Some GPU setup code...
local w, h = gpu.getResolution()
gpu.setResolution(w, h)
gpu.setBackground(0)
gpu.setForeground(0xFFFFFF)
gpu.fill(1, 1, w, h, " ")

--A few things for nice printing of things...
local cls = function()gpu.fill(1,1,w,h," ")end
local y = 1
local function status(msg)
    if gpu and screen then
    	gpu.set(1, y, msg)
        if y == h then
        	gpu.copy(1, 2, w, h-1, 0, -1)
        	gpu.fill(1, h, w, 1, " ")
        else
            y = y + 1
        end
    end
end

status("Zorya Init setup.")
local dl_files = {
	{"https://raw.githubusercontent.com/Adorable-Catgirl/Zorya-BIOS/master/zorya-modules/boot.lua", "zorya-modules/boot.lua"},
	{"https://raw.githubusercontent.com/Adorable-Catgirl/Zorya-BIOS/master/zorya-modules/tsukiboot.lua", "zorya-modules/tsukiboot.lua"},
	{"https://raw.githubusercontent.com/Adorable-Catgirl/Zorya-BIOS/master/zorya-modules/netboot.lua", "zorya-modules/netboot.lua"},
	{"https://raw.githubusercontent.com/Adorable-Catgirl/Zorya-BIOS/master/zorya-modules/p9kboot.lua", "zorya-modules/p9kboot.lua"},
	{"https://raw.githubusercontent.com/Adorable-Catgirl/Zorya-BIOS/master/zorya-modules/openosboot.lua", "zorya-modules/openosboot.lua"},
	{"https://raw.githubusercontent.com/Adorable-Catgirl/Zorya-BIOS/master/zorya-modules/config.lua", "zorya-modules/config.lua"},
	{"https://raw.githubusercontent.com/Adorable-Catgirl/Zorya-BIOS/master/zorya-modules/zorya_menu.lua", "zorya-modules/zorya_menu.lua"},
	--{"https://raw.githubusercontent.com/Adorable-Catgirl/Zorya-BIOS/master/zorya-cfg/zorya-cfg.lua", "zorya-cfg/zorya-cfg.lua"},
	{"https://raw.githubusercontent.com/rxi/json.lua/master/json.lua","zorya-cfg/json.lua"},
	{"https://raw.githubusercontent.com/bungle/lua-resty-prettycjson/master/lib/resty/prettycjson.lua", "zorya-cfg/pretty.lua"}
}

status("Setting up internet card.")
local net = proxy(list("internet")())
local fs = proxy(args[1])
fs.mkdir("zorya-modules")
fs.mkdir("zorya-cfg")

status("Downloading required libraries...")
for i=1, #dl_files do
	status("> "..dl_files[i][2])
	local req = net.request(dl_files[i][1])
	if (req.finishConnect()) then
		local data = req.read() --So we aren't killed.
		status("Installing "..dl_files[i])
		local hand = fs.open(dl_files[i][2]), "w")
		fs.write(hand, data)
		fs.close(hand)
	else
		status("Error downloading "..dl_files[i][2]..", stopping...")
		fs.remove("zorya-modules")
		fs.remove("zorya-cfg")
		local eeprom = proxy(list("eeprom"))
		eeprom.setData()
		status(string.rep("-", w))
		status("")
		status("PANIC: Download failed, rebooting in 10 seconds...")
		status("")
		status(string.rep("-", w))
		local start = os.clock()
		while true do if (os.clock() > start+10) then computer.shutdown(true) end end
	end
end

status("Setup complete! Rebooting in 5 seconds...")
local start = os.clock()
while true do if (os.clock() > start+5) then computer.shutdown(true) end end