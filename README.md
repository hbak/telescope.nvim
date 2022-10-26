this is a dirty fork of [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)

its sole aim at the moment is to enable a user to move their cursor into the results_window so that they can search within the results to narrow down the result they want, the way that [denite](https://github.com/Shougo/denite.nvim) and [ddu-ui-ff](https://github.com/Shougo/ddu-ui-ff) do.

currently it "seems to work" with caveats:
- having multiple telescopes open may result in jumping to the wrong results window
