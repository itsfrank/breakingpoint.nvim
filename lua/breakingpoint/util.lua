local m_util = {}

function m_util.multiline_float_input()
    local function get_text_width()
        local win_width = vim.fn.winwidth(0)
        local nr_width = vim.fn.getwinvar(0, "&numberwidth")
        local sign_width = vim.fn.getwinvar(0, "&signcolumn") == "yes" and 2 or 0
        return win_width - nr_width - sign_width
    end

    local ft = vim.api.nvim_buf_get_option(0, "filetype")
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf, "filetype", ft)

    local width = get_text_width()
    local height = 4
    local buf_row, _ = unpack(vim.api.nvim_win_get_cursor(0))
    local win_top = vim.fn.line("w0")
    local win_row = buf_row - win_top + 1

    local col = vim.fn.winwidth(0) - width
    local row = win_row

    vim.api.nvim_create_autocmd("BufLeave", {
        buffer = buf,
        callback = function()
            vim.schedule(function()
                if vim.api.nvim_buf_is_valid(buf) then
                    vim.api.nvim_buf_delete(buf, { force = true })
                end
            end)
        end,
    })

    vim.api.nvim_open_win(buf, true, {
        relative = "win",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "none",
    })
end

function m_util.get_cmd_range(opts)
    local function get_visual_text()
        return vim.fn.getregion(vim.fn.getpos("'<"), vim.fn.getpos("'>"))
    end

    --- hacky way to tell if the currently executing user command was called with a visual range
    local function is_visual_cmd()
        return string.sub(vim.fn.histget("cmd", -1), 1, 5) == "'<,'>"
    end

    local lines = { "" }
    if opts.range == 0 then
        lines = { vim.api.nvim_get_current_line() }
    elseif is_visual_cmd() then
        lines = get_visual_text()
    else
        lines = vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, false)
    end
    return lines
end

return m_util
