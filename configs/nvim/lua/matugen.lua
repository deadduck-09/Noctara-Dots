 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#1c110e',
    base01 = '#291d19',
    base02 = '#342723',
    base03 = '#a68b83',
    base04 = '#dfc0b7',
    base05 = '#f4ded8',
    base06 = '#f4ded8',
    base07 = '#f4ded8',
    base08 = '#ffb4ab',
    base09 = '#e5c35d',
    base0A = '#ffb59f',
    base0B = '#ffb59f',
    base0C = '#e5c35d',
    base0D = '#ffb59f',
    base0E = '#ffb59f',
    base0F = '#93000a',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  hi('TelescopeNormal',         { fg = '#f4ded8',          bg = '#1c110e' })
  hi('TelescopeBorder',         { fg = '#a68b83',             bg = '#1c110e' })
  hi('TelescopePromptNormal',   { fg = '#f4ded8',          bg = '#1c110e' })
  hi('TelescopePromptBorder',   { fg = '#a68b83',             bg = '#1c110e' })
  hi('TelescopePromptPrefix',   { fg = '#ffb59f',             bg = '#1c110e' })
  hi('TelescopePromptCounter',  { fg = '#dfc0b7',  bg = '#1c110e' })
  hi('TelescopePromptTitle',    { fg = '#1c110e',             bg = '#ffb59f' })
  hi('TelescopePreviewTitle',   { fg = '#1c110e',             bg = '#ffb59f' })
  hi('TelescopeResultsTitle',   { fg = '#1c110e',             bg = '#e5c35d' })
  hi('TelescopeSelection',      { fg = '#f4ded8',          bg = '#342723' })
  hi('TelescopeSelectionCaret', { fg = '#ffb59f',             bg = '#342723' })
  hi('TelescopeMatching',       { fg = '#ffb59f',             bold = true })
end

 -- Register a signal handler for SIGUSR1 (matugen updates)
 local signal = vim.uv.new_signal()
 signal:start(
   'sigusr1',
   vim.schedule_wrap(function()
     package.loaded['matugen'] = nil
     require('matugen').setup()
   end)
 )

 return M
