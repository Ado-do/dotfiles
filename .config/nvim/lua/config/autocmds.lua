local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Highlight yanked text briefly
autocmd("TextYankPost", {
  group = augroup("YankHighlight", { clear = true }),
  callback = function()
    vim.hl.on_yank({ higroup = "IncSearch", timeout = 150 })
  end,
})

-- Equalize splits in every tab on terminal resize, staying on the current tab
autocmd("VimResized", {
  group = augroup("ResizeSplits", { clear = true }),
  callback = function()
    local tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd.tabnext(tab)
  end,
})

-- Restore last cursor position when opening a file
local last_loc_group = augroup("LastLoc", { clear = true })
autocmd("BufReadPost", {
  group = last_loc_group,
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].last_loc then
      return
    end
    vim.b[buf].last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Filetype plugins reset formatoptions; disable comment auto-continuation again
autocmd("FileType", {
  group = augroup("NoAutoComment", { clear = true }),
  callback = function()
    vim.opt_local.formatoptions:remove({ "o", "r" })
  end,
})
