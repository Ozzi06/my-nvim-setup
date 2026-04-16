local function apply_my_theme()
    local white = '#EAECF0'
    local blue = '#6FB7FD'
    local purple = '#bc63e9'
    local lblue_desat = '#79d2d2'
    local bg_dark = '#1F1F1E'
    local bg_medium = '#252524'
    local bg_light = '#2C2C2A'
    local highlight = '#3B3B39'
    local orange_deep = '#C6613F'
    local orange_yellowish = '#FBAD60'
    local tsoding_orange = '#B9855A'
    local gray = '#838389'
    local lgray = '#C6C7CB'
    local tsoding_yellow = '#ffdd33'
    local green = '#88c85b'
    local blue_desat = '#85b3e0'
    local lblue = '#5EECEC'
    vim.cmd('highlight clear')

    -- Fix: vim.fn.exists returns 0 or 1. In Lua, 0 is truthy,
    -- so we must explicitly check if it equals 1.
    if vim.fn.exists('syntax_on') == 1 then
        vim.cmd('syntax reset')
    end

    -- 1. Explicitly name your colorscheme
    vim.g.colors_name = 'my-minimal-theme'

    local hl = function(group, opts)
        vim.api.nvim_set_hl(0, group, opts)
    end

    -- Syntax
    hl('Comment', { fg = tsoding_orange, italic = true })
    hl('Keyword', { fg = tsoding_yellow, bold = false })
    hl('Conditional', { fg = tsoding_yellow, bold = true })
    hl('DiagnosticUnnecessary', { fg = gray })
    hl('Repeat', { fg = tsoding_yellow, bold = true })
    hl('Function', { fg = blue_desat })
    hl('String', { fg = green })
    hl('Number', { fg = lgray })
    hl('Float', { fg = lgray })
    hl('Boolean', { fg = lgray })
    hl('Identifier', { fg = lgray })
    hl('Operator', { fg = lgray })
    hl('Delimiter', { fg = lgray })
    hl('Constant', { fg = lgray })
    hl('Variable', { fg = lgray })
    hl('Type', { fg = gray })
    hl('Special', { fg = lgray })

    hl('@string.documentation', { fg = tsoding_orange, italic = true })

    -- Tree-sitter specific groups (The "@" groups)
    -- You can link them to the standard groups you already defined:
    hl('@keyword.conditional', { link = 'Conditional' })
    hl('@keyword.repeat', { link = 'Repeat' })
    hl('@keyword.operator', { link = 'Operator' })
    hl('@variable', { link = 'Variable' })

    hl('Directory', { fg = gray, bold = true })
    hl('NeoTreeGitAdded', { fg = green })
    hl('NeoTreeGitModified', { fg = orange_yellowish })
    hl('NeoTreeGitDeleted', { fg = orange_deep })
    hl('NeoTreeGitRenamed', { fg = lblue })
    hl('NeoTreeGitUntracked', { fg = orange_yellowish, italic = true })
    hl('NeoTreeGitIgnored', { fg = highlight }) -- Makes ignored files dim/blend in
    hl('NeoTreeGitConflict', { fg = orange_deep, bold = true })
    hl('NeoTreeGitStaged', { fg = green })

    -- UI
    hl('Normal', { fg = gray, bg = bg_medium })
    hl('NormalFloat', { fg = lgray, bg = bg_medium })
    hl('LineNr', { fg = gray })
    hl('CursorLine', { bg = bg_light })
    hl('CursorLineNr', { fg = lgray, bg = bg_light })
    hl('Visual', { bg = highlight })
    hl('StatusLine', { fg = gray, bg = bg_medium })
    hl('StatusLineNC', { fg = gray, bg = bg_dark })
    hl('VertSplit', { fg = orange_deep })
    hl('SignColumn', { bg = bg_light })
    hl('Pmenu', { fg = lgray, bg = bg_medium })
    hl('PmenuSel', { fg = lgray, bg = bg_light })

    -- Todo
    hl('Todo', { fg = bg_dark, bg = orange_yellowish, bold = true })

    -- 2. Trigger the ColorScheme event to alert plugins (mini.hipatterns, Telescope, etc.)
    -- that they need to clear their caches and recreate their dynamic highlights.
    vim.api.nvim_exec_autocmds('ColorScheme', { pattern = 'my-minimal-theme' })
end

apply_my_theme()

return {
    {
        dir = vim.fn.stdpath('config'),
        name = 'my-minimal-theme',
        priority = 1000,
        config = function()
            apply_my_theme()
        end,
    },
    {
        'folke/todo-comments.nvim',
        event = 'VimEnter',
        dependencies = { 'nvim-lua/plenary.nvim' },
        opts = { signs = false },
    },
    {
        'echasnovski/mini.hipatterns',
        version = false,
        config = function()
            local hipatterns = require('mini.hipatterns')
            hipatterns.setup({
                highlighters = {
                    -- 1. Standard hex colors (#ffffff)
                    hex_color = hipatterns.gen_highlighter.hex_color(),

                    -- 2. Hyprland rgba hex colors (rgba(ffffff55))
                    hyprland_color = {
                        pattern = 'rgba?%(%x%x%x%x%x%x%x*%)',
                        group = function(_, match)
                            local hex = match:match('rgba?%((%x%x%x%x%x%x)')
                            return hex and hipatterns.compute_hex_color_group('#' .. hex, 'bg') or nil
                        end,
                    },

                    -- 3. CSS/Waybar rgba colors (rgba(26, 27, 38, 0.5))
                    css_rgba = {
                        pattern = 'rgba?%(%s*%d+%s*,%s*%d+%s*,%s*%d+%s*[,%s%d%.]*%)',
                        group = function(_, match)
                            -- Extract the R, G, and B decimal values
                            local r, g, b = match:match('rgba?%(%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)')
                            if not r or not g or not b then
                                return nil
                            end

                            -- Convert decimal R,G,B to a hex string
                            local hex = string.format('#%02x%02x%02x', tonumber(r), tonumber(g), tonumber(b))
                            return hipatterns.compute_hex_color_group(hex, 'bg')
                        end,
                    },
                },
            })
        end,
    },
}
