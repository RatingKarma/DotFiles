return {
    "stevearc/conform.nvim",
    opts = {
        formatters_by_ft = {
            c = { "clang_format" },
            cpp = { "clang_format" },
        },

        format_on_save = {
            lsp_format = "fallback",
            timeout_ms = 500,
        },
    },
}
