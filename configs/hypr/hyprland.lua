--[[
--
███╗   ██╗ ██████╗  ██████╗████████╗ █████╗ ██████╗  █████╗       ██████╗  ██████╗ ████████╗███████╗ 
████╗  ██║██╔═══██╗██╔════╝╚══██╔══╝██╔══██╗██╔══██╗██╔══██╗      ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝ 
██╔██╗ ██║██║   ██║██║        ██║   ███████║██████╔╝███████║█████╗██║  ██║██║   ██║   ██║   ███████╗ 
██║╚██╗██║██║   ██║██║        ██║   ██╔══██║██╔══██╗██╔══██║╚════╝██║  ██║██║   ██║   ██║   ╚════██║ 
██║ ╚████║╚██████╔╝╚██████╗   ██║   ██║  ██║██║  ██║██║  ██║      ██████╔╝╚██████╔╝   ██║   ███████║ 
╚═╝  ╚═══╝ ╚═════╝  ╚═════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝      ╚═════╝  ╚═════╝    ╚═╝   ╚══════╝ 
--
--]]
--
-- This is mostly made by keeping noctalia-shell in mind.

---------------
--- MODULES ---
---------------

-- Core (Its recommended to check these files to make changes according to your hardware)
require("modules.input") -- Mouse and input devices
require("modules.monitors") -- Monitors and output devices
require("modules.env") -- Environment variables

-- Startups
require("modules.autostarts")

-- Appearance
require("modules.animations")
require("modules.decorations") -- Blur and gap settings
require("modules.layer-rules") -- Shell rules

-- Behavior
require("modules.keybinds") -- Change them to your default apps
require("modules.layout") -- Tilling layout
require("modules.window-rules") -- Windows behavior

-- Misc
require("modules.misc") -- Default wallpapers and logo

-- For Noctalia Color templates
require("noctalia").apply_theme()
