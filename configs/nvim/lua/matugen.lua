 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#17130a',
    base01 = '#231f15',
    base02 = '#2e2a1f',
    base03 = '#9a9079',
    base04 = '#d1c5ad',
    base05 = '#ebe1d1',
    base06 = '#ebe1d1',
    base07 = '#ebe1d1',
    base08 = '#ffb4ab',
    base09 = '#c0e768',
    base0A = '#dec482',
    base0B = '#ffd455',
    base0C = '#aed458',
    base0D = '#f0c126',
    base0E = '#dec482',
    base0F = '#93000a',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  hi('TelescopeNormal',         { fg = '#ebe1d1',          bg = '#17130a' })
  hi('TelescopeBorder',         { fg = '#9a9079',             bg = '#17130a' })
  hi('TelescopePromptNormal',   { fg = '#ebe1d1',          bg = '#17130a' })
  hi('TelescopePromptBorder',   { fg = '#9a9079',             bg = '#17130a' })
  hi('TelescopePromptPrefix',   { fg = '#ffd455',             bg = '#17130a' })
  hi('TelescopePromptCounter',  { fg = '#d1c5ad',  bg = '#17130a' })
  hi('TelescopePromptTitle',    { fg = '#17130a',             bg = '#ffd455' })
  hi('TelescopePreviewTitle',   { fg = '#17130a',             bg = '#dec482' })
  hi('TelescopeResultsTitle',   { fg = '#17130a',             bg = '#c0e768' })
  hi('TelescopeSelection',      { fg = '#ebe1d1',          bg = '#2e2a1f' })
  hi('TelescopeSelectionCaret', { fg = '#ffd455',             bg = '#2e2a1f' })
  hi('TelescopeMatching',       { fg = '#ffd455',             bold = true })
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
