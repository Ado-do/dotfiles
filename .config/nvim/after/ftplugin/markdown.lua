-- Set conceallevel to 2 specifically for markdown files
vim.opt_local.conceallevel = 2

vim.opt_local.textwidth = 80
vim.opt_local.spell = true

vim.keymap.set("n", "<leader>cp", "<cmd>MarkdownPreview<cr>", { buffer = true, desc = "Start Markdown Preview" })
