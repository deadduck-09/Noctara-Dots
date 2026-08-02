--[[
--
██╗    ██╗██╗███╗   ██╗██████╗  ██████╗ ██╗    ██╗      ██████╗ ██╗   ██╗██╗     ███████╗███████╗
██║    ██║██║████╗  ██║██╔══██╗██╔═══██╗██║    ██║      ██╔══██╗██║   ██║██║     ██╔════╝██╔════╝
██║ █╗ ██║██║██╔██╗ ██║██║  ██║██║   ██║██║ █╗ ██║█████╗██████╔╝██║   ██║██║     █████╗  ███████╗
██║███╗██║██║██║╚██╗██║██║  ██║██║   ██║██║███╗██║╚════╝██╔══██╗██║   ██║██║     ██╔══╝  ╚════██║
╚███╔███╔╝██║██║ ╚████║██████╔╝╚██████╔╝╚███╔███╔╝      ██║  ██║╚██████╔╝███████╗███████╗███████║
 ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝╚═════╝  ╚═════╝  ╚══╝╚══╝       ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚══════╝╚══════╝
 --
--]]

-- Default helper rules
hl.window_rule({
	name = "suppress-maximize-events",
	match = { class = ".*" },
	suppress_event = "maximize",
})

hl.window_rule({
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},
	no_focus = true,
})

hl.window_rule({
	name = "move-hyprland-run",
	match = { class = "hyprland-run" },
	move = "20 monitor_h-120",
	float = true,
})

--------------
---- RULES ---
--------------

-- 1. Firefox Picture-in-Picture Floating Rule
hl.window_rule({
	name = "firefox-pip-floating",
	match = {
		class = "firefox",
		title = "^Picture-in-Picture$",
	},
	float = true,
})

-- 2. Block Password Managers from Screen Capture
hl.window_rule({
	name = "keepassxc-screen-share-block",
	match = { class = "org.keepassxc.KeePassXC" },
	no_screen_share = true,
})

hl.window_rule({
	name = "secrets-screen-share-block",
	match = { class = "org.gnome.World.Secrets" },
	no_screen_share = true,
})

-- 3. Noctalia Floating Settings Window with Custom Size
hl.window_rule({
	name = "noctalia-settings-float",
	match = { class = "dev.noctalia.Noctalia" },
	float = true,
	size = { 850, 700 }, -- Adjust acc to your choice
	center = true,
})

-------------------------------
---- PERSISTENT WORKSPACES ----
-------------------------------

-- Replace "eDP-1" with your monitor name if different
local monitorName = "eDP-1"

for i = 1, 5 do
	hl.workspace_rule({
		workspace = tostring(i),
		monitor = monitorName,
		persistent = true,
	})
end
