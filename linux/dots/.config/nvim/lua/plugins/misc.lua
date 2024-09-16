return {
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        opts = {
            ensure_installed = { 'c', 'lua', 'vim', 'vimdoc', 'query', 'markdown', 'markdown_inline' },
            sync_install = false,
            auto_install = true,
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
        },
    },

    {
        'nvim-treesitter/playground',
        dependencies = { 'nvim-treesitter/nvim-treesitter' },
    },

    {
        'mbbill/undotree',
        keys = {
            { '<leader>u', '<cmd>UndotreeToggle<cr>', desc='Toggle Undotree UI' },
        },
    },

    {'tpope/vim-fugitive'},
}

