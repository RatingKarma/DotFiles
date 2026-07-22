return {
    "akinsho/toggleterm.nvim",
    version = "*",

    opts = {
        size = function(term)
            if term.direction == "horizontal" then
                return math.floor(vim.o.lines * 0.2)
            elseif term.direction == "vertical" then
                return math.floor(vim.o.columns * 0.4)
            end
        end,

        open_mapping = [[<C-\>]],

        start_in_insert = true,
        insert_mappings = true,

        persist_size = true,

        direction = "horizontal",

        hide_numbers = true,

        shade_terminals = false,

        float_opts = {
            border = "rounded",
            winblend = 0,
        },
    },

    config = function(_, opts)
        require("toggleterm").setup(opts)

        local Terminal = require("toggleterm.terminal").Terminal

        local terminal = Terminal:new({
            direction = "horizontal",
            hidden = true,
        })

        vim.keymap.set("n", "<leader>t", function()
            terminal:toggle()
        end, { desc = "Toggle Terminal" })

        vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], {
            desc = "Exit Terminal Mode",
        })
    end,
}
