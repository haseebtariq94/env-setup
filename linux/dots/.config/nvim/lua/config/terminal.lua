vim.api.nvim_command('autocmd TermOpen * startinsert')
vim.api.nvim_command('autocmd TermOpen * setlocal nonu')
vim.api.nvim_command('autocmd TermOpen * setlocal nornu')
vim.api.nvim_command('autocmd TermOpen * setlocal nocursorline')
vim.api.nvim_command('autocmd TermOpen * setlocal signcolumn=no')

vim.keymap.set('t', '<esc>', '<C-\\><C-n>')
