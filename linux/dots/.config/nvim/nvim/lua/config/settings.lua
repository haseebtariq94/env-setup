vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

vim.opt.nu = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv('HOME') .. '/.vim/undodir'
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = 'yes'
vim.opt.isfname:append('@-@')

vim.opt.updatetime = 50

vim.api.nvim_create_autocmd('FileType', {
	pattern = { '*' },
	callback = function(args)
		local ft = vim.bo[args.buf].filetype
		if ft == 'c' then
			vim.opt.tabstop = 8
			vim.opt.softtabstop = 8
			vim.opt.shiftwidth = 8
			
            vim.opt.colorcolumn = '80'
		end
	end
})
