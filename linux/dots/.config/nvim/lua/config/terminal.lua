vim.api.nvim_command('autocmd TermOpen * startinsert')
vim.api.nvim_command('autocmd TermOpen * setlocal nonumber')
vim.api.nvim_command('autocmd TermOpen * setlocal signcolumn=no')

vim.keymap.set('t', '<esc>', '<C-\\><C-n>')
