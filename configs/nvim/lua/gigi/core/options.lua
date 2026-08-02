vim.cmd("let g:netrw_liststyle =3")

local opt = vim.opt

opt.relativenumber = true
opt.number = true

-- tabs & indentation 
opt.tabstop = 2 -- 2 spaces for tabs
opt.shiftwidth = 2 --2 spaces for indent width
opt.expandtab = true --expand tab to spaces
opt.autoindent = true --copy indent from the current line when starting a new one

opt.wrap = false

-- search settings 
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you incluse mixed case in your seach, assumes you want case-sensitive

opt.cursorline = true

--backspace
opt.backspace = "indent,eol,start" 

-- clipboard 
opt.clipboard:append("unnamedplus") -- use system clipboard as default 

-- split windows 
opt.splitright = true --split vertical window to the right
opt.splitbelow = true --split horizontal window to the bottom
