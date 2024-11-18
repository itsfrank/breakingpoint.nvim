local dap = require("dap")
local dap_breakpoints = require("dap.breakpoints")

local function safe_require(module)
    local ok, result = pcall(require, module)
    return ok and result or nil
end
-- QoL if dapui exists
local maybe_dapui = safe_require("dapui")

local m_brkp = {}

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

return m_brkp
