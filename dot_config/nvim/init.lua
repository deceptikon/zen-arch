-- [1. ГЛОБАЛЬНЫЕ НАСТРОЙКИ]
local opt = vim.opt
opt.number, opt.relativenumber = true, true
opt.mouse, opt.clipboard = 'a', 'unnamedplus'
opt.termguicolors, opt.signcolumn = true, "yes"
opt.tabstop, opt.shiftwidth, opt.expandtab = 4, 4, true
vim.g.mapleader = " "

-- [2. ФИКС КИРИЛЛИЦЫ] 
opt.langmap = 'ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz'

-- [2.5] WHITESPACES
opt.list = true
opt.listchars = { 
    tab = '→ ',
    space = '·',
    trail = '•',
    extends = '⟩', 
    precedes = '⟨' 
}

-- [3. ПРЕДОХРАНИТЕЛЬ ДЛЯ HEADLESS]
local is_headless = #vim.api.nvim_list_uis() == 0

-- [4. LAZY.NVIM BOOTSTRAP]
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- [5. ПЛАГИНЫ]
require("lazy").setup({
    -- Интерфейс
    { "folke/tokyonight.nvim", lazy = false, priority = 1000, config = function() vim.cmd.colorscheme "tokyonight" end },
    { "nvim-lualine/lualine.nvim", opts = { options = { theme = "tokyonight" } } },
    { "folke/which-key.nvim", event = "VeryLazy" },
    
    -- Инструменты
    { "stevearc/oil.nvim", opts = {} },
    { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

    -- УЛЬТРА-СТАБИЛЬНЫЙ LSP БЛОК (v2.0.0+ Ready)
    {
        "neovim/nvim-lspconfig",
        dependencies = { 
            "williamboman/mason.nvim", 
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp" 
        },
        config = function()
            if is_headless then return end

            require("mason").setup()
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            require("mason-lspconfig").setup({ 
                -- Убрали pyright, оставили только нужные сервера
                ensure_installed = { "lua_ls", "ts_ls", "rust_analyzer" },
                handlers = {
                    function(server_name)
                        require("lspconfig")[server_name].setup({
                            capabilities = capabilities,
                        })
                    end,
                }
            })
        end
    },

    -- Автодополнение
    {
        "hrsh7th/nvim-cmp",
        dependencies = { "L3MON4D3/LuaSnip", "hrsh7th/cmp-nvim-lsp" },
        config = function()
            if is_headless then return end
            local cmp = require("cmp")
            cmp.setup({
                snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
                mapping = cmp.mapping.preset.insert({
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                }),
                sources = cmp.config.sources({ { name = "nvim-lsp" } }),
            })
        end
    },
})

-- [6. ГОРЯЧИЕ КЛАВИШИ]
local map = vim.keymap.set

local function duo_map(mode, key_en, key_ru, target, desc)
    map(mode, "<leader>" .. key_en, target, { desc = desc })
    map(mode, "<leader>" .. key_ru, target, { desc = desc .. " (RU)" })
end

-- Поиск (Telescope) (f=а, g=п, b=и)
duo_map("n", "ff", "аа", function() require('telescope.builtin').find_files() end, "Find Files")
duo_map("n", "fg", "ап", function() require('telescope.builtin').live_grep() end, "Search Text")
duo_map("n", "fb", "аи", function() require('telescope.builtin').buffers() end, "Buffers")

-- Проводник (Oil) (e=у)
duo_map("n", "e", "у", ":Oil<CR>", "Explorer")

-- Код (LSP) (d=в)
map("n", "gd", function() vim.lsp.buf.definition() end, { desc = "Go to Definition" })
map("n", "пв", function() vim.lsp.buf.definition() end, { desc = "Go to Definition (RU)" })
