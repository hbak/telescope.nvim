local actions = require "telescope.actions"
local a = vim.api

local mappings = {}
-- TODO: merge with user configuration?
mappings.results_win_mappings = {
	n = {
		["<CR>"] = actions.results_win_select,
		["<C-v>"] = actions.results_win_vertical_select,
		["<C-t>"] = actions.results_win_tab_select,
		i = actions.move_to_prompt_win,
		a = actions.move_to_prompt_win,
		["<esc>"] = actions.results_win_close,
	}
}

mappings.prompt_win_mappings = {
	n = {
		["<CR>"] = actions.move_to_results_window,
	},
	i = {
		["<CR>"] = actions.move_to_results_window,
	}
}

-- straight copy from mappings.lua
local get_desc_for_keyfunc = function(v)
  if type(v) == "table" then
    local name = ""
    for _, action in ipairs(v) do
      if type(action) == "string" then
        name = name == "" and action or name .. " + " .. action
      end
    end
    return "telescope|" .. name
  elseif type(v) == "function" then
    local info = debug.getinfo(v)
    return "telescopej|" .. vim.json.encode { source = info.source, linedefined = info.linedefined }
  end
end

-- adapted from mappings.lua telescope_map()
-- importantly takes in both results_bufnr and prompt_bufnr
-- results_bufnr is what we bind the keymap to
-- but prompt_bufnr is what we pass to the action (key_func)
local telescope_map_results_win = function(results_bufnr, prompt_bufnr, mode, key_bind, key_func, opts)
  if not key_func then
    return
  end

  opts = opts or {}
  if opts.noremap == nil then
    opts.noremap = true
  end
  if opts.silent == nil then
    opts.silent = true
  end
  if type(key_func) == "string" then
    key_func = actions[key_func]
  elseif type(key_func) == "table" then
    if key_func.type == "command" then
      vim.keymap.set(
        mode,
        key_bind,
        key_func[1],
        vim.tbl_extend("force", opts or {
          silent = true,
        }, { buffer = results_bufnr })
      )
      return
    elseif key_func.type == "action_key" then
      key_func = actions[key_func[1]]
    elseif key_func.type == "action" then
      key_func = key_func[1]
    end
  end

  vim.keymap.set(mode, key_bind, function()
		-- key_func is actions.results_win_select for example
		-- these functions need the prompt_bufnr to get the full
		-- Telescope context,
    local ret = key_func(prompt_bufnr)
		vim.api.nvim_exec_autocmds("User", { pattern = "TelescopeKeymap" })
		return ret
  end, vim.tbl_extend("force", opts, { buffer = results_bufnr, desc = get_desc_for_keyfunc(key_func) }))
		-- ^ but we bind the keymap to the results_bufnr
end

-- straight copy from mappings.lua
local extract_keymap_opts = function(key_func)
  if type(key_func) == "table" and key_func.opts ~= nil then
    -- we can't clear this because key_func could be a table from the config.
    -- If we clear it the table ref would lose opts after the first bind
    -- We need to copy it so noremap and silent won't be part of the table ref after the first bind
    return vim.deepcopy(key_func.opts)
  end
  return {}
end

-- adapted from mappings.apply_keymap()
-- only difference is that it takes in both results_bufnr and prompt_bufnr
-- to call telescope_map_results_win instead of telescope_map
-- TODO:  what are "attach_mappings" for?
mappings.apply_results_win_keymap = function(results_bufnr, prompt_bufnr, attach_mappings, buffer_keymap)
  local applied_mappings = { n = {}, i = {} }
  local map = function(mode, key_bind, key_func, opts)
    mode = string.lower(mode)
    local key_bind_internal = a.nvim_replace_termcodes(key_bind, true, true, true)
    applied_mappings[mode][key_bind_internal] = true
    telescope_map_results_win(results_bufnr, prompt_bufnr, mode, key_bind, key_func, opts)
  end

	if attach_mappings then
		vim.pretty_print(attach_mappings)
		local attach_results = attach_mappings(results_bufnr, map)
		if attach_results == nil then
			error(
				"Attach mappings must always return a value. `true` means use default mappings, "
					.. "`false` means only use attached mappings"
			)
		end
		if not attach_results then
			return
		end
	end

  for mode, mode_map in pairs(buffer_keymap or {}) do
    for key_bind, key_func in pairs(mode_map) do
      local key_bind_internal = a.nvim_replace_termcodes(key_bind, true, true, true)
      if not applied_mappings[mode][key_bind_internal] then
        applied_mappings[mode][key_bind_internal] = true
				-- telescope_map(results_bufnr, mode, key_bind, key_func, extract_keymap_opts(key_func))
				telescope_map_results_win(results_bufnr, prompt_bufnr, mode, key_bind, key_func, extract_keymap_opts(key_func))
      end
    end
  end
  -- TODO: Probably should not overwrite any keymaps
  for mode, mode_map in pairs(mappings.results_win_mappings) do
    mode = string.lower(mode)
    for key_bind, key_func in pairs(mode_map) do
      local key_bind_internal = a.nvim_replace_termcodes(key_bind, true, true, true)
      if not applied_mappings[mode][key_bind_internal] then
        applied_mappings[mode][key_bind_internal] = true
				-- telescope_map(results_bufnr, mode, key_bind, key_func, extract_keymap_opts(key_func))
				telescope_map_results_win(results_bufnr, prompt_bufnr, mode, key_bind, key_func, extract_keymap_opts(key_func))
      end
    end
  end
end
return mappings
