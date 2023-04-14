return {
    "monaqa/dial.nvim",
    keys = { "<C-a>", { "<C-x>", mode = "n" } },
    config = function()
        local augend = require("dial.augend")
        require("dial.config").augends:register_group {
            -- default augends used when no group name is specified
            default = {
                augend.integer.alias.decimal, -- nonnegative decimal number (0, 1, 2, 3, ...)
                augend.integer.alias.hex, -- nonnegative hex number  (0x01, 0x1a1f, etc.)
                augend.date.alias["%Y/%m/%d"], -- date (2022/02/19, etc.)
            },

            -- augends used when group with name `mygroup` is specified
            mygroup = {
                augend.integer.alias.decimal,
                augend.constant.alias.bool, -- boolean value (true <-> false)
                augend.date.alias["%m/%d/%Y"], -- date (02/19/2022, etc.)
            }
        }

        require("dial.config").augends:register_group {
            default = {
                -- date with format `yyyy/mm/dd`
                augend.date.new {
                    pattern = "%Y/%m/%d",
                    default_kind = "day",
                    -- if true, it does not match dates which does not exist, such as 2022/05/32
                    only_valid = true,
                    -- if true, it only matches dates with word boundary
                    word = false,
                },
            },
        }
    end
}

