return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },

  config = function()
    local lualine = require("lualine")
    local lazy_status = require("lazy.status")

    -- Read colors from the Matugen-generated Kitty theme
    local function parse_kitty_theme()
      local path = vim.fn.expand("~/.config/kitty/current-theme.conf")
      local file = io.open(path, "r")

      if not file then
        return {}
      end

      local colors = {}

      for line in file:lines() do
        local key, value = line:match("^%s*([%w_]+)%s+(#%x%x%x%x%x%x)")

        if key and value then
          colors[key] = value
        end
      end

      file:close()
      return colors
    end

    local function setup_lualine()
      local k = parse_kitty_theme()

      -- Dynamic colors with safe fallbacks
      local colors = {
        bg = k.background or "#011628",
        fg = k.foreground or "#CBE0F0",
        inactive_bg = k.color0 or "#112638",
        inactive_fg = k.color8 or "#5c6370",

        red = k.color1 or "#FF4A4A",
        green = k.color2 or "#3EFFDC",
        yellow = k.color3 or "#FFDA7B",
        blue = k.color4 or "#65D1FF",
        violet = k.color5 or "#FF61EF",
        cyan = k.color6 or "#65D1FF",

        bright_red = k.color9 or k.color1 or "#FF4A4A",
        bright_green = k.color10 or k.color2 or "#3EFFDC",
        bright_yellow = k.color11 or k.color3 or "#FFDA7B",
        bright_blue = k.color12 or k.color4 or "#65D1FF",
        bright_violet = k.color13 or k.color5 or "#FF61EF",
        bright_cyan = k.color14 or k.color6 or "#65D1FF",
      }

      local my_lualine_theme = {
        normal = {
          a = {
            bg = colors.blue,
            fg = colors.bg,
            gui = "bold",
          },
          b = {
            bg = colors.bg,
            fg = colors.fg,
          },
          c = {
            bg = colors.bg,
            fg = colors.fg,
          },
        },

        insert = {
          a = {
            bg = colors.green,
            fg = colors.bg,
            gui = "bold",
          },
          b = {
            bg = colors.bg,
            fg = colors.fg,
          },
          c = {
            bg = colors.bg,
            fg = colors.fg,
          },
        },

        visual = {
          a = {
            bg = colors.violet,
            fg = colors.bg,
            gui = "bold",
          },
          b = {
            bg = colors.bg,
            fg = colors.fg,
          },
          c = {
            bg = colors.bg,
            fg = colors.fg,
          },
        },

        command = {
          a = {
            bg = colors.yellow,
            fg = colors.bg,
            gui = "bold",
          },
          b = {
            bg = colors.bg,
            fg = colors.fg,
          },
          c = {
            bg = colors.bg,
            fg = colors.fg,
          },
        },

        replace = {
          a = {
            bg = colors.red,
            fg = colors.bg,
            gui = "bold",
          },
          b = {
            bg = colors.bg,
            fg = colors.fg,
          },
          c = {
            bg = colors.bg,
            fg = colors.fg,
          },
        },

        inactive = {
          a = {
            bg = colors.inactive_bg,
            fg = colors.inactive_fg,
            gui = "bold",
          },
          b = {
            bg = colors.inactive_bg,
            fg = colors.inactive_fg,
          },
          c = {
            bg = colors.inactive_bg,
            fg = colors.inactive_fg,
          },
        },
      }

      lualine.setup({
        options = {
          theme = my_lualine_theme,
          component_separators = "",
          section_separators = "",
        },

        sections = {
          lualine_x = {
            {
              lazy_status.updates,
              cond = lazy_status.has_updates,
              color = {
                fg = colors.yellow,
              },
            },
            { "encoding" },
            { "fileformat" },
            { "filetype" },
          },
        },
      })
    end

    -- Apply on startup
    setup_lualine()

    -- Re-read Kitty colors when Neovim gains focus
    local group = vim.api.nvim_create_augroup("DynamicLualineColors", { clear = true })

    vim.api.nvim_create_autocmd("FocusGained", {
      group = group,
      callback = function()
        setup_lualine()
      end,
    })
  end,
}
