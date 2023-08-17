This is a fork of [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) with the specific things I wanted:
1) `<CR>` moves to results list so I can /search among the results
2) `-` key lets me swap from vertical to horizontal layout instantly with results intact -- so if the preview win was too skinny in vertical mode, I can make it horizontal so that I can see full lines of text
3) allow the layout to span entire window


# changes
- Enable a user to move their cursor into the results_window so that they can search within the results to narrow down the result they want, the way that [denite](https://github.com/Shougo/denite.nvim) and [ddu-ui-ff](https://github.com/Shougo/ddu-ui-ff) do.
	- `<CR>` moves the cursor to the results window, and from there `<CR>` selects the result your cursor is over
	- `<C-CR>` and `<S-CR>` do what `<CR>` did before, which is directly go to the highlighted (bottom-most) result


- you can live swap between different layouts with a keymap
	- changed __internal.resume() so that it reads the layout_strategy live from the config
	- your map would change the config.layout_strategy then builtin.resume to achieve a live swap.  Example:
  ```
  function M.rotateTelescopeLayout()
    local telescope = require('telescope')
    require('telescope.actions').close(vim.api.nvim_get_current_buf())
    if (M.current_layout == 'horizontal') then
      M.current_layout = 'vertical'
    else
      M.current_layout = 'horizontal'
    end
    telescope.setup({
      defaults = {
        layout_strategy = M.current_layout,
        layout_config = M.layout_config
      }
    })
    builtin.resume()
  end

  vim.api.nvim_create_autocmd({"FileType"}, {
    pattern = "TelescopePrompt",
    callback = function()
      vim.api.nvim_buf_set_keymap(0, 'n', '0', ':lua require("conf/telescope_config").rotateTelescopeLayout()<CR>', { noremap=true })
      vim.api.nvim_buf_set_keymap(0, 'n', '-', ':lua require("conf/telescope_config").rotateTelescopeLayout()<CR>', { noremap=true })

    end
  })
	```

- width and height config values equal to 1 mean 100% instead of 1%, which enables full screen popups.
```
  telescope.setup({
    defaults = {
      layout_config = {
        horizontal = { width = 1, height = 1, preview_width = .5 },
        vertical = { width = 1, height = 1 }
      }
  }
```

# later goals:
- hotkey to resize the results and preview windows in relation to each other
- no padding on results lists
	- sometimes when you jump from prompt win to results win, it lands on a blank line 30 lines up from the last result
