return {
  {
    "folke/tokyonight.nvim",
    priority = 1000,

    config = function()
      -- Read colors from kitty theme
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

      local function apply()
        local k = parse_kitty_theme()

        require("tokyonight").setup({
          style = "night",

          on_colors = function(c)
            local bg = k.background or "#011628"
            local fg = k.foreground or "#CBE0F0"

            -- backgrounds
            c.bg = bg
            c.bg_dark = bg
            c.bg_float = bg
            c.bg_popup = bg
            c.bg_sidebar = bg
            c.bg_statusline = bg

            -- foregrounds
            c.fg = fg
            c.fg_dark = k.color7 or fg
            c.fg_float = fg
            c.fg_sidebar = fg

            -- accents
            c.border = k.color4 or "#547998"
            c.bg_highlight = k.color8 or "#143652"
            c.bg_search = k.color4 or "#0A64AC"
            c.bg_visual = k.color8 or "#275378"
          end,
        })

        -- Apply colorscheme
        vim.cmd.colorscheme("tokyonight")

        -- Cursor line (softer, darker, readable)
        vim.api.nvim_set_hl(0, "CursorLine", {
          bg = "#182131",
        })

        -- Current line number
        vim.api.nvim_set_hl(0, "CursorLineNr", {
          fg = k.color4 or "#89b4fa",
          bold = true,
        })

        -- Make line numbers slightly cleaner
        vim.api.nvim_set_hl(0, "LineNr", {
          fg = "#5c6370",
        })
      end

      -- Apply on startup
      apply()

      -- Re-apply when focus changes or nvim opens
      vim.api.nvim_create_autocmd({
        "VimEnter",
        "FocusGained",
      }, {
        callback = function()
          apply()
        end,
      })
    end,
  },
}
