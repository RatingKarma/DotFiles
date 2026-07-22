return {
    "mfussenegger/nvim-dap",

    dependencies = {
        "rcarriga/nvim-dap-ui",
        "nvim-neotest/nvim-nio",
        "theHamsta/nvim-dap-virtual-text",
        "williamboman/mason.nvim",
        "jay-babu/mason-nvim-dap.nvim",
    },

    config = function()
        local dap = require("dap")
        local dapui = require("dapui")

        dapui.setup({
            layouts = {
                {
                    position = "left",
                    size = 25,
                    elements = {
                        { id = "scopes",      size = 0.5 },
                        { id = "breakpoints", size = 0.2 },
                        { id = "stacks",      size = 0.15 },
                        { id = "watches",     size = 0.15 },
                    },
                },
                {
                    position = "bottom",
                    size = 5, -- 高度(行)
                    elements = {
                        { id = "repl",    size = 0.5 },
                        { id = "console", size = 0.5 },
                    },
                },
            },

        })

        require("mason").setup()

        require("mason-nvim-dap").setup({
            ensure_installed = {
                "codelldb",
            },
            automatic_installation = true,
        })

        require("nvim-dap-virtual-text").setup({
            enabled = true,

            enabled_commands = true,

            highlight_changed_variables = true,
            highlight_new_as_changed = false,

            show_stop_reason = true,

            commented = false,

            virt_text_pos = "eol",

            all_references = false,

            clear_on_continue = false,
        })

        -- CodeLLDB
        local mason_path = vim.fn.stdpath("data") .. "/mason/packages"

        dap.adapters.codelldb = {
            type = "server",
            port = "${port}",
            executable = {
                command = mason_path .. "/codelldb/extension/adapter/codelldb",
                args = { "--port", "${port}" },
            },
        }

        dap.configurations.cpp = {
            {
                name = "Launch file",
                type = "codelldb",
                request = "launch",
                program = function()
                    return vim.fn.input(
                        "Executable: ",
                        vim.fn.getcwd() .. "/build/",
                        "file"
                    )
                end,
                cwd = "${workspaceFolder}",
                stopOnEntry = false,
            },
        }

        dap.configurations.c = dap.configurations.cpp

        local tree_api = require("nvim-tree.api")
        local tree_was_open = false

        local function close_tree()
            tree_was_open = tree_api.tree.is_visible()
            if tree_was_open then
                tree_api.tree.close()
            end
        end

        local function open_tree()
            if tree_was_open then
                tree_api.tree.open()
            end
        end

        dap.listeners.after.event_initialized["dapui_config"] = function()
            close_tree()
            dapui.open()
        end

        dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close()
            open_tree()
        end

        dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close()
            open_tree()
        end

        local map = vim.keymap.set
        local dapui_open = false

        map("n", "<F5>", dap.continue, { desc = "Debug Continue" })
        map("n", "<F10>", dap.step_over, { desc = "Step Over" })
        map("n", "<F11>", dap.step_into, { desc = "Step Into" })
        map("n", "<F12>", dap.step_out, { desc = "Step Out" })

        map("n", "<Leader>b", dap.toggle_breakpoint, { desc = "Breakpoint" })
        map("n", "<Leader>B", function()
            dap.set_breakpoint(vim.fn.input("Condition: "))
        end)

        map("n", "<Leader>dr", dap.repl.open, { desc = "DAP REPL" })
        vim.keymap.set("n", "<leader>du", function()
            dapui_open = not dapui_open

            if dapui_open then
                if tree_api.tree.is_visible() then
                    tree_api.tree.close()
                end
                dapui.open()
            else
                dapui.close()
                tree_api.tree.open()
            end
        end, { desc = "Toggle DAP UI" })
    end,
}
