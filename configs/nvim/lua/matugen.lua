 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#121315',
    base01 = '#1f2022',
    base02 = '#292a2c',
    base03 = '#8e9198',
    base04 = '#c4c6ce',
    base05 = '#e4e2e4',
    base06 = '#e4e2e4',
    base07 = '#e4e2e4',
    base08 = '#ffb4ab',
    base09 = '#dfbbde',
    base0A = '#c0c7d5',
    base0B = '#b4c8e8',
    base0C = '#dfbbde',
    base0D = '#b4c8e8',
    base0E = '#c0c7d5',
    base0F = '#dce3f1',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- telescope.nvim
  hi('TelescopeNormal',         { fg = '#e4e2e4',          bg = '#121315' })
  hi('TelescopeBorder',         { fg = '#8e9198',             bg = '#121315' })
  hi('TelescopePromptNormal',   { fg = '#e4e2e4',          bg = '#121315' })
  hi('TelescopePromptBorder',   { fg = '#8e9198',             bg = '#121315' })
  hi('TelescopePromptPrefix',   { fg = '#b4c8e8',             bg = '#121315' })
  hi('TelescopePromptCounter',  { fg = '#c4c6ce',  bg = '#121315' })
  hi('TelescopePromptTitle',    { fg = '#121315',             bg = '#b4c8e8' })
  hi('TelescopePreviewTitle',   { fg = '#121315',             bg = '#c0c7d5' })
  hi('TelescopeResultsTitle',   { fg = '#121315',             bg = '#dfbbde' })
  hi('TelescopeSelection',      { fg = '#e4e2e4',          bg = '#292a2c' })
  hi('TelescopeSelectionCaret', { fg = '#b4c8e8',             bg = '#292a2c' })
  hi('TelescopeMatching',       { fg = '#b4c8e8',             bold = true })

  -- mini.pick
  hi('MiniPickNormal',         { fg = '#e4e2e4',          bg = '#121315' })
  hi('MiniPickBorder',         { fg = '#8e9198',             bg = '#121315' })
  hi('MiniPickPrompt',   { fg = '#e4e2e4',          bg = '#121315' })
  hi('MiniPickPromptPrefix',   { fg = '#b4c8e8',             bg = '#121315' })
  hi('MiniPickBorderText',    { fg = '#121315',             bg = '#b4c8e8' })
  hi('MiniPickMatchCurrent',      { fg = '#e4e2e4',          bg = '#292a2c' })
  hi('MiniPickPromptCaret', { fg = '#b4c8e8',             bg = '#292a2c' })
  hi('MiniPickMatchRanges',       { fg = '#b4c8e8',             bold = true })
end

-- Register a signal handler for SIGUSR1 (matugen updates).
-- The handler re-requires this module, which re-runs the code below, so the
-- previous handle is stopped first; otherwise handlers double on every signal.
if _G.__matugen_signal then
  _G.__matugen_signal:stop()
  _G.__matugen_signal:close()
end

local signal = vim.uv.new_signal()
_G.__matugen_signal = signal
signal:start(
  'sigusr1',
  vim.schedule_wrap(function()
    package.loaded['matugen'] = nil
    require('matugen').setup()
  end)
)

return M
