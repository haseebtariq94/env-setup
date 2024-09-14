return {
    {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release',
    },

    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.8',
        dependencies = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope-fzf-native.nvim' },
        opts = {
            defaults = {
                layout_strategy = "horizontal",
                layout_config = {
                    horizontal = {
                        preview_width = 0.5,
                    }
                }
            }
        },
        config = function(_, opts)
            local telescope = require('telescope')
            telescope.setup(opts)
            telescope.load_extension('fzf')
        end,
        keys = {
            { '<leader>ff', '<cmd>Telescope find_files<cr>', desc = 'List files' },
            { '<leader>fG', '<cmd>Telescope git_files<cr>', desc = 'Search output of git ls-files'},
            { '<leader>fg', '<cmd>Telescope live_grep<cr>', desc = 'Live grep search' },
            { '<leader>fs', '<cmd>Telescope grep_string<cr>', desc = 'Search string' },
            { '<leader>fs', function()
                local s_start = vim.fn.getpos('v')
                local s_end = vim.fn.getcurpos()
                local n_lines = math.abs(s_end[2] - s_start[2]) + 1
                local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
                lines[1] = string.sub(lines[1], s_start[3], -1)
                if n_lines == 1 then
                    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
                else
                    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
                end
                require("telescope.builtin").grep_string({ search = table.concat(lines, '\n') })
            end, mode = { 'v' }, desc = 'Search selection' },
            { '<leader>fb', '<cmd>Telescope buffers<cr>', desc = 'List open buffers' },
            { '<leader>fo', '<cmd>Telescope oldfiles<cr>', desc = 'List previously opened files' },
            { '<leader>fl', '<cmd>Telescope current_buffer_fuzzy_find<cr>', desc = 'Search current buffer' },
        },
    },
}
