--[[
--
██╗      █████╗ ██╗   ██╗███████╗██████╗       ██████╗ ██╗   ██╗██╗     ███████╗███████╗
██║     ██╔══██╗╚██╗ ██╔╝██╔════╝██╔══██╗      ██╔══██╗██║   ██║██║     ██╔════╝██╔════╝
██║     ███████║ ╚████╔╝ █████╗  ██████╔╝█████╗██████╔╝██║   ██║██║     █████╗  ███████╗
██║     ██╔══██║  ╚██╔╝  ██╔══╝  ██╔══██╗╚════╝██╔══██╗██║   ██║██║     ██╔══╝  ╚════██║
███████╗██║  ██║   ██║   ███████╗██║  ██║      ██║  ██║╚██████╔╝███████╗███████╗███████║
╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝      ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚══════╝╚══════╝
--
--]]

-- Noctalia Shell Elements (Bar, Notification, Dock, Panels, OSD)
hl.layer_rule({
	name = "noctalia-ui-elements",
	match = {
		namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd)$",
	},
	blur = true,
	xray = false,
})

-- Noctalia Window Switcher Blur
hl.layer_rule({
	name = "noctalia-window-switcher-blur",
	match = { namespace = "noctalia-window-switcher" },
	blur = true,
	xray = false,
})
