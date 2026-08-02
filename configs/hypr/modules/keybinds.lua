--[[
--
██╗  ██╗███████╗██╗   ██╗██████╗ ██╗███╗   ██╗██████╗ ███████╗
██║ ██╔╝██╔════╝╚██╗ ██╔╝██╔══██╗██║████╗  ██║██╔══██╗██╔════╝
█████╔╝ █████╗   ╚████╔╝ ██████╔╝██║██╔██╗ ██║██║  ██║███████╗
██╔═██╗ ██╔══╝    ╚██╔╝  ██╔══██╗██║██║╚██╗██║██║  ██║╚════██║
██║  ██╗███████╗   ██║   ██████╔╝██║██║ ╚████║██████╔╝███████║
╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═════╝ ╚═╝╚═╝  ╚═══╝╚═════╝ ╚══════╝
--
--]]

---------------------
---- MY PROGRAMS ----
---------------------

local terminal = "kitty"
local fileManager = "thunar"
local mainMod = "SUPER"
local browser = "helium-browser"
local players = "spotify"
local notes = "obsidian"
local editor = "vscodium"

------------------------
---- NOCTALIA Binds ----
------------------------

hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("noctalia msg session lock"))
hl.bind(mainMod .. " + Comma", hl.dsp.exec_cmd("noctalia msg panel-toggle wallpaper"))
hl.bind(mainMod .. " + Period", hl.dsp.exec_cmd('noctalia msg panel-toggle launcher "/emo "'))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("noctalia msg panel-toggle clipboard"))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("noctalia msg panel-toggle control-center"))
hl.bind("ALT + Space", hl.dsp.exec_cmd("noctalia msg panel-toggle launcher"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("noctalia msg panel-toggle control-center notifications"))
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("noctalia msg panel-toggle session"))
hl.bind(mainMod .. " + ALT + I", hl.dsp.exec_cmd("noctalia msg settings-toggle"))
hl.bind("ALT + TAB", hl.dsp.exec_cmd("noctalia msg window-switcher"))

--------------------
---- APPLICATION ---
--------------------

hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal), { description = "Open Terminal: kitty" })
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser), { description = "Open Browser: Helium" })
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager), { description = "Open File Manager" })
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd(players), { description = "Open Media Player" })
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd(notes), { description = "Open Notes App" })
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd(editor), { description = "Open Code Editor" })

----------------------------
---- WINDOW MANAGEMENT ----
----------------------------

hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind("CTRL + SUPER + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))

-- Focusing Windows
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Moving Windows
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "down" }))

----------------------------
---- WORKSPACE & SCROLL ----
----------------------------

for i = 1, 9 do
	local key = tostring(i)
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scroll through existing workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Mouse window dragging & resizing
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-----------------------------
---- SCREENSHOT UTILITIES ---
-----------------------------

hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m region"))
hl.bind("CTRL + Print", hl.dsp.exec_cmd("hyprshot -m output"))
hl.bind("ALT + Print", hl.dsp.exec_cmd("hyprshot -m window"))

-----------------------
---- HARDWARE KEYS ----
-----------------------

hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)

hl.bind(
	"XF86MonBrightnessUp",
	hl.dsp.exec_cmd("brightnessctl --class=backlight set +10%"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86MonBrightnessDown",
	hl.dsp.exec_cmd("brightnessctl --class=backlight set 10%-"),
	{ locked = true, repeating = true }
)

hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

--------------------
--- Lid Closing ---
--------------------
-- Bind lid close event to lock and suspend
hl.bind(
	"switch:on:Lid Switch",
	hl.dsp.exec_cmd("noctalia msg session lock-and-suspend"),
	{ locked = true } -- 'locked = true' is equivalent to 'bindl'
)

-----------------------
---- EXIT / QUIT ------
-----------------------

hl.bind(
	"CTRL + ALT + Delete",
	hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'")
)

---------------
--- Testing ---
---------------
hl.bind(
	"SUPER + ALT + F12",
	hl.dsp.exec_cmd(
		"notify-send -u low -i dialog-information-symbolic 'Test notification' "
			.. [["Here's a really long message to test truncation and wrapping\nYou can middle click or flick this notification to dismiss it!"]]
			.. " -a 'Shell' -A 'Test1=I got it!' -A 'Test2=Another action'"
	)
)
