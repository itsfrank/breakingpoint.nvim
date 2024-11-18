# breakingpoint.nvim

> [!WARNING] Warning
> Very much WIP, anything could change at any time, no stability expected!

Simple utilities to make setting and editing conditional breakpoints better.

## Setup

Using lazy:
```lua
{
    "itsfrank/breakingpoint.nvim",
    dependencies = {
        "mfussenegger/nvim-dap",
    },
    config = function()
        local brkp = require("breakingpoint")
        -- set your keybinds, these are just samples, I use a custom debug layer made with https://github.com/Iron-E/nvim-libmodal
        vim.keymap.set("n", "<leader>dB", brkp.create_or_edit_cndpoint, { desc = "[d]ebug: toggle conditional [B]reakpoint" })
        vim.keymap.set("n", "<leader>dL", brkp.create_or_edit_logppoint, { desc = "[d]ebug: toggle [L]ogpoint" })
    end,
}
```
