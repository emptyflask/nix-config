-- File renaming function
local function rename_file()
  local old_name = vim.fn.expand('%')
  local new_name = vim.fn.input('New file name: ', vim.fn.expand('%'))

  if new_name ~= '' and new_name ~= old_name then
    -- Save file with new name
    vim.cmd(string.format(':saveas %s', new_name))
    -- Remove old file
    vim.fn.system(string.format('rm %s', old_name))
    -- Redraw screen
    vim.cmd('redraw!')
  end
end

-- Map the rename function to leader-n
vim.keymap.set('n', '<leader>n', rename_file, { silent = true })
