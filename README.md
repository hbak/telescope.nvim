this is a dirty, hasty fork of [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)

# changes
- Enable a user to move their cursor into the results_window so that they can search within the results to narrow down the result they want, the way that [denite](https://github.com/Shougo/denite.nvim) and [ddu-ui-ff](https://github.com/Shougo/ddu-ui-ff) do.
	- caveat: having multiple telescopes open may result in jumping to the wrong results window
		- TODO: major refactor to save references to not just the prompt win but also the results win (a win object) 

- you can live swap between different layouts with a keymap
	- changed __internal.resume() so that it reads the layout_strategy live from the config
	- your map would change the config.layout_strategy then builtin.resume to achieve a live swap

- width and height config values equal to 1 mean 100% instead of 1%, which enables full screen popups.


# later goals:
- hotkey to resize the results and preview windows in relation to each other
- no padding on results lists
	- sometimes when you jump from prompt win to results win, it lands on a blank line 30 lines up from the last result
