return {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    opts = {
        sort_by = "case_sensitive",
        git = {
            enable = true,
        },
        filters = {
            dotfiles = true,
            custom = { "node_modules" },
        },
        view = {
            side = "left",
            number = true,
            relativenumber = true,
            signcolumn = "yes",
            width = 30,
        },
        renderer = {
            group_empty = true,
        },
    },
}
