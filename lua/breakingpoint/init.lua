local dap = require("dap")
local dap_breakpoints = require("dap.breakpoints")

local function safe_require(module)
    local ok, result = pcall(require, module)
    return ok and result or nil
end
-- QoL if dapui exists
local maybe_dapui = safe_require("dapui")

local m_brkp = {}

local function is_local_dev()
    local ok, res = pcall(function()
        local plugin_spec = require("lazy.core.config").spec.plugins["breakingpoint-nvim"]
        local is_local = plugin_spec ~= nil and plugin_spec.dir ~= nil and plugin_spec.dir ~= ""
        return is_local
    end)
    return ok and res == true
end

--- returns first bp at line for buf
local function get_bp_info(line, bufnr)
    if bufnr == 0 or bufnr == nil then
        bufnr = vim.api.nvim_get_current_buf()
    end
    for _, bp in ipairs(dap_breakpoints.get(bufnr)[bufnr]) do
        if bp.line == line then
            return bp
        end
    end
end

local function get_cursor_bp_info()
    local cursor_pos = vim.fn.getpos(".")
    return get_bp_info(cursor_pos[2], cursor_pos[1])
end

-- creates or edits logpoint on cursor line
function m_brkp.create_or_edit_logppoint()
    local initial_message = ""
    local current_bp = get_cursor_bp_info()
    if current_bp and current_bp.logMessage then
        initial_message = current_bp.logMessage
    end
    vim.ui.input({
        prompt = "Log message - interpoloate with {var}",
        default = initial_message,
    }, function(input)
        if input == nil or input == "" then
            return -- aborted or empty string: do nothing
        end
        dap.toggle_breakpoint(nil, nil, input, true)
        if maybe_dapui then
            maybe_dapui.elements.breakpoints.render()
        end
    end)
end

-- creates or edits conditional breakpoint on cursor line
function m_brkp.create_or_edit_cndpoint()
    local initial_cnd = ""
    local current_bp = get_cursor_bp_info()
    if current_bp and current_bp.condition then
        initial_cnd = current_bp.condition
    end
    vim.ui.input({
        prompt = "Condition",
        default = initial_cnd,
    }, function(input)
        if input == nil or input == "" then
            return -- aborted or empty string: do nothing
        end
        dap.toggle_breakpoint(input, nil, nil, true)
        if maybe_dapui then
            maybe_dapui.elements.breakpoints.render()
        end
    end)
end

function m_brkp.setup()
    if is_local_dev() then
        vim.keymap.set("n", "<leader>rp", ":Lazy reload breakingpoint-nvim<cr>", { silent = true })
    end

    vim.api.nvim_create_user_command("Bmisc", function(opts)
        local bufnr = vim.api.nvim_get_current_buf()
        vim.wo.virtualedit = "all"
        local cursor_pos = vim.fn.getpos(".")
        vim.api.nvim_buf_set_extmark(bufnr, vim.api.nvim_create_namespace("virtual_lines"), cursor_pos[2], vim.fn.col('$') - 1, {
            virt_lines = { { { "", "" } } },
        })
    end, {})

    vim.api.nvim_create_user_command("Blogpt", function(opts)
        m_brkp.create_or_edit_logppoint()
    end, {})

    vim.api.nvim_create_user_command("Bcndpt", function(opts)
        m_brkp.create_or_edit_cndpoint()
    end, {})

    vim.api.nvim_create_user_command("Blistbp", function(opts)
        local dap_brk = require("dap.breakpoints")
        local bufnr = vim.api.nvim_get_current_buf()
        print(vim.inspect(dap_brk.get(bufnr)))
    end, {})

    vim.api.nvim_create_user_command("Bbpinfo", function(opts)
        local cursor_pos = vim.fn.getpos(".")
        print(vim.inspect(get_bp_info(cursor_pos[2], cursor_pos[1])))
    end, {})
end

return m_brkp
