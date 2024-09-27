vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

local function open_diagnostic_float()
    local bufnr = vim.api.nvim_get_current_buf()
    if vim.api.nvim_buf_is_valid(bufnr) and
       vim.api.nvim_get_option_value('buftype', { buf = bufnr }) ~= "nofile" and
       vim.api.nvim_get_mode().mode == 'n' then
        local cursor_pos = vim.api.nvim_win_get_cursor(0)
        local line = cursor_pos[1] - 1
        local diagnostics = vim.diagnostic.get(bufnr, { lnum = line })
        if diagnostics and #diagnostics > 1 then
            local opts = {
                focusable = false,
                close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
                scope = "line",
            }
            vim.diagnostic.open_float(nil, opts)
        end
    end
end

vim.api.nvim_create_autocmd("CursorHold", { pattern = "*", callback = open_diagnostic_float })
vim.api.nvim_create_autocmd("DiagnosticChanged", { pattern = "*", callback = open_diagnostic_float })
