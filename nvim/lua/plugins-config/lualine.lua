return {
    "nvim-lualine/lualine.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    opts = {
        options = {
            theme = "auto",
        },
        sections = {
            lualine_a = {
                "mode",
                "location",
            },

            lualine_b = {
                "branch",
            },

            lualine_c = {
                "filename",
            },

            lualine_x = {
                function()
                    local enc = vim.bo.fileencoding
                    if enc == "" then
                        enc = vim.o.encoding
                    end
                    return enc:upper()
                end,
                function()
                    return vim.bo.fileformat:upper()
                end,
                "filetype",
            },

            lualine_y = {},

            lualine_z = {},
        },
    },
}
