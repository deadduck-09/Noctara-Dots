return {
  {
    "folke/tokyonight.nvim",
    priority = 1000,

    config = function()
      -- Read the current Matugen-generated Kitty palette
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

      local function apply_theme()
        local k = parse_kitty_theme()

        -- Safe fallback colors if the Kitty theme file is unavailable
        local bg = k.background or "#011628"
        local fg = k.foreground or "#CBE0F0"

        require("tokyonight").setup({
          style = "night",

          on_colors = function(c)
            -- =========================
            -- Backgrounds
            -- =========================
            c.bg = bg
            c.bg_dark = k.color0 or bg
            c.bg_float = bg
            c.bg_popup = bg
            c.bg_sidebar = bg
            c.bg_statusline = k.color0 or bg

            -- =========================
            -- Foregrounds
            -- =========================
            c.fg = fg
            c.fg_dark = k.color8 or fg
            c.fg_float = fg
            c.fg_sidebar = fg

            -- =========================
            -- Dynamic syntax colors
            -- =========================
            c.red = k.color1 or c.red
            c.green = k.color2 or c.green
            c.yellow = k.color3 or c.yellow
            c.blue = k.color4 or c.blue
            c.magenta = k.color5 or c.magenta
            c.cyan = k.color6 or c.cyan

            -- Bright variants
            c.orange = k.color9 or k.color3 or c.orange
            c.green1 = k.color10 or k.color2 or c.green1
            c.yellow1 = k.color11 or k.color3 or c.yellow1
            c.blue1 = k.color12 or k.color4 or c.blue1
            c.magenta2 = k.color13 or k.color5 or c.magenta2
            c.teal = k.color14 or k.color6 or c.teal

            -- TokyoNight uses several blue shades internally.
            -- Override them so the theme follows Matugen instead
            -- of keeping TokyoNight's default blue palette.
            c.blue0 = k.color0 or c.blue0
            c.blue2 = k.color6 or k.color4 or c.blue2
            c.blue5 = k.color12 or k.color4 or c.blue5
            c.blue6 = k.color6 or k.color4 or c.blue6
            c.blue7 = k.color4 or c.blue7

            -- Purple and additional accents
            c.purple = k.color13 or k.color5 or c.purple

            -- =========================
            -- UI colors
            -- =========================
            c.border = k.color8 or c.border
            c.border_highlight = k.color4 or c.border_highlight
            c.bg_highlight = k.color0 or c.bg_highlight
            c.bg_search = k.color4 or c.bg_search
            c.bg_visual = k.color8 or c.bg_visual

            -- Comments and muted text
            c.comment = k.color8 or c.comment
            c.dark3 = k.color0 or c.dark3
            c.dark5 = k.color8 or c.dark5
          end,
        })

        -- Apply the configured colorscheme
        vim.cmd.colorscheme("tokyonight")

        -- =========================
        -- Custom highlights
        -- =========================

        -- Current line
        vim.api.nvim_set_hl(0, "CursorLine", {
          bg = k.color0 or bg,
        })

        -- Current line number
        vim.api.nvim_set_hl(0, "CursorLineNr", {
          fg = k.color4 or fg,
          bold = true,
        })

        -- Normal line numbers
        vim.api.nvim_set_hl(0, "LineNr", {
          fg = k.color8 or fg,
        })
      end

      -- Apply on startup
      apply_theme()

      -- Re-read the generated Kitty palette when Neovim gains focus.
      -- This allows wallpaper/theme changes to update the colors
      -- without restarting Neovim.
      local group = vim.api.nvim_create_augroup("DynamicKittyColors", { clear = true })

      vim.api.nvim_create_autocmd({
        "VimEnter",
        "FocusGained",
      }, {
        group = group,
        callback = function()
          apply_theme()
        end,
      })
    end,
  },
}
