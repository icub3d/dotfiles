-- Pull in the wezterm API
local wezterm = require 'wezterm'
local mux = wezterm.mux
local act = wezterm.action

-- Colors --
local colors = {
	black = '#19181a',
	light_black = '#221f22',
	background = '#2d2a2e',
	darker_gray = '#403e41',
	dark_gray = '#5b595c',
	gray = '#727072',
	light_gray = '#939293',
	ligher_gray = '#c1c0c0',
	white = '#fcfcfa',
	blue = '#78dce8',
	green = '#a9dc76',
	violet = '#ab9df2',
	orange = '#fc9867',
	red = '#ff6188',
	yellow = '#ffd866',
}


------------ Helper Functions ------------
local git_branch_name = function(cwd)
	-- Get our branch name
	local rev = io.popen("git -C " .. cwd .. " rev-parse --abbrev-ref HEAD")
	if not rev then
		return false
	end
	local branch = rev:read("*l")

	-- If we're not on a branch, return false
	if not branch then
		return false
	end

	-- If the command failed, return false
	if branch:sub(1, 5) == "fatal" then
		return false
	end

	-- Otherwise, return the branch name
	return branch
end

local git_status = function(cwd)
	-- Get our statuses
	local status = io.popen("git -C " .. cwd .. " status --porcelain")
	if not status then
		return false
	end

	-- Combine them into counts
	local entries = {}
	for line in status:lines() do
		local part = string.sub(line, 1, 2)
		part = string.gsub(part, " ", "_")
		entries[part] = (entries[part] or 0) + 1
	end

	-- If there are no entries, return false
	if next(entries) == nil then
		return false
	end

	-- Otherwise, build a string of the entries
	local result = ""
	for k, v in pairs(entries) do
		result = result .. v .. " " .. k .. " | "
	end
	return result.sub(result, 1, -4)
end

local spawn_workspace = function(name, cwd, title, text, tabs)
	-- create the new workspace
	local tab, pane, window = mux.spawn_window({
		workspace = name,
		cwd = cwd,
	})

	-- Set values if we are given them.
	if title ~= "" and title ~= nil then
		tab:set_title(title)
	end
	if text ~= "" and text ~= nil then
		pane:send_text(text .. "\n")
	end

	-- Do the same for each additional tab
	for _, tab_info in ipairs(tabs) do
		local new_tab, _, _ = window:spawn_tab {}

		if tab_info.title ~= "" and tab_info.title ~= nil then
			new_tab:set_title(tab_info.title)
		end
		if tab_info.text ~= "" and tab_info.text ~= nil then
			new_tab:send_text(tab_info.text .. "\n")
		end
	end

	-- Return the originals
	return tab, pane, window
end

-- This function will return the title for a tab.
local tab_title = function(index, tab_info)
	local title = tab_info.tab_title
	-- if the tab title is explicitly set, take that
	if title and #title > 0 then
		return index .. ":" .. title
	end
	-- Otherwise, use the title from the active pane
	-- in that tab
	return index .. ":" .. tab_info.active_pane.title
end


---------- General Config ----------

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- use the simple prompt because we'll have a status bar
config.set_environment_variables = {
	SIMPLE_PROMPT = "true",
}

-- Keybindings
config.leader = { key = "o", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
	{
		key = "o",
		mods = "LEADER|CTRL",
		action = act.ActivateLastTab,
	},
	{
		key = "|",
		mods = "LEADER|SHIFT",
		action = act.SplitHorizontal { domain = "CurrentPaneDomain" },
	},
	{
		key = "-",
		mods = "LEADER",
		action = act.SplitVertical { domain = "CurrentPaneDomain" },
	},
	{
		key = "o",
		mods = "LEADER",
		action = act.ActivatePaneDirection "Next",
	},
	{
		key = "c",
		mods = "LEADER",
		action = act.EmitEvent 'my-spawn-tab',
	},
	{
		key = "k",
		mods = "LEADER",
		action = act.CloseCurrentPane { confirm = true },
	},
	{
		key = "m",
		mods = "LEADER",
		action = act.TogglePaneZoomState,
	},
	{
		key = "Space",
		mods = "LEADER",
		action = act.RotatePanes "Clockwise",
	},
	{
		key = "s",
		mods = "LEADER",
		action = act.ShowLauncherArgs { flags = "FUZZY|LAUNCH_MENU_ITEMS|WORKSPACES|DOMAINS" },
	},
	{
		key = "a",
		mods = "LEADER",
		action = act.PromptInputLine {
			description = "name",
			action = wezterm.action_callback(function(window, pane, text)
				if text then
					window:active_tab():set_title(text)
				end
			end),
		},
	},
	{
		key = "[",
		mods = "LEADER",
		action = act.ActivateCopyMode,
	},
	{
		key = "{",
		mods = "LEADER|SHIFT",
		action = act.ActivateTabRelative(-1),
	},
	{
		key = "}",
		mods = "LEADER|SHIFT",
		action = act.ActivateTabRelative(1),
	}
}

-- Copy mode key bindings to work like emacs
config.key_tables = {
	copy_mode = {
		{ key = "Escape", mods = "NONE",      action = wezterm.action { CopyMode = "Close" } },
		{ key = "g",      mods = "CTRL",      action = wezterm.action { CopyMode = "Close" } },
		{ key = "b",      mods = "CTRL",      action = wezterm.action { CopyMode = "MoveLeft" } },
		{ key = "f",      mods = "CTRL",      action = wezterm.action { CopyMode = "MoveRight" } },
		{ key = "p",      mods = "CTRL",      action = wezterm.action { CopyMode = "MoveUp" } },
		{ key = "n",      mods = "CTRL",      action = wezterm.action { CopyMode = "MoveDown" } },
		{ key = "b",      mods = "ALT",       action = wezterm.action { CopyMode = "MoveBackwardWord" } },
		{ key = "f",      mods = "ALT",       action = wezterm.action { CopyMode = "MoveForwardWord" } },
		{ key = "a",      mods = "CTRL",      action = wezterm.action { CopyMode = "MoveToStartOfLine" } },
		{ key = "e",      mods = "CTRL",      action = wezterm.action { CopyMode = "MoveToEndOfLineContent" } },
		{ key = "m",      mods = "ALT",       action = wezterm.action { CopyMode = "MoveToStartOfLineContent" } },
		{ key = "v",      mods = "CTRL",      action = wezterm.action { CopyMode = "PageDown" } },
		{ key = "v",      mods = "ALT",       action = wezterm.action { CopyMode = "PageUp" } },
		{ key = "<",      mods = "ALT|SHIFT", action = wezterm.action { CopyMode = "MoveToScrollbackTop" } },
		{ key = ">",      mods = "ALT|SHIFT", action = wezterm.action { CopyMode = "MoveToScrollbackBottom" } },
		{ key = "Space",  mods = "CTRL",      action = act.CopyMode { SetSelectionMode = 'Cell' } },
		{ key = "r",      mods = "",          action = act.CopyMode { SetSelectionMode = 'Block' } },
		{
			key = "w",
			mods = "ALT",
			action = act.Multiple {
				{ CopyTo = 'ClipboardAndPrimarySelection' },
				{ CopyMode = 'Close' },
			}
		},
	}
}

-- Use leader + [0-9] to select tabs.
for i = 0, 9 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = "LEADER",
		action = act.ActivateTab(i),
	})
end


-- Color Palette - Monokai Pro
config.colors = {
	background = colors.background,
	foreground = colors.white,
	cursor_bg = colors.white,
	cursor_fg = colors.background,
	cursor_border = colors.lighter_gray,
	selection_fg = colors.darker_gray,
	selection_bg = colors.white,
	split = colors.lighter_gray,
	ansi = {
		colors.darker_gray,
		colors.red,
		colors.green,
		colors.orange,
		colors.blue,
		colors.violet,
		colors.blue,
		colors.white,
	},
	brights = {
		colors.gray,
		colors.red,
		colors.green,
		colors.orange,
		colors.blue,
		colors.violet,
		colors.blue,
		colors.white,
	},
	tab_bar = {
		background = colors.dark_gray,
		new_tab = {
			bg_color = colors.dark_gray,
			fg_color = colors.green,
			intensity = 'Bold',
		}
	},
}

-- Don't darken inactive panes
config.inactive_pane_hsb = {
	saturation = 1.0,
	brightness = 0.85,
}

-- Font
config.font = wezterm.font 'JetBrains Mono'
config.font_size = 17.0

-- Window
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}
config.window_frame = {
	font = wezterm.font {
		family = "JetBrains Mono",
	},
	font_size = 14.0,
	active_titlebar_bg = colors.background,
	inactive_titlebar_bg = colors.background,
	button_bg = colors.background,
	button_fg = colors.green,
	button_hover_fg = colors.red,
	button_hover_bg = colors.light_black
}
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false

-- Launcher
local launch_menu = {}

if wezterm.target_triple == "x86_64-apple-darwin" or wezterm.target_triple == "x86_64-unknown-linux-gnu" then
	table.insert(launch_menu, {
		label = "top",
		args = { "fish", "-c", "top" },
	})
end

table.insert(launch_menu, {
	label = "nw (new workspace)",
	args = { "fish", "-c", "nw" },
})

config.launch_menu = launch_menu

-- Startup Behavior
wezterm.on('gui-startup', function(_)
	-- home
	local _, _, window = spawn_workspace("home",
		wezterm.home_dir,
		"fish",
		"",
		{})

	-- dotfiles
	spawn_workspace("dot",
		wezterm.home_dir .. '/dev/dotfiles',
		"editor",
		"v .",
		{ { title = "fish", } })

	-- work stuff
	if os.getenv("ATWORK") == "true" then
		spawn_workspace("oti",
			wezterm.home_dir .. '/dev/oti-azure',
			"editor",
			"v .",
			{ { title = "logs", }, { title = "fish", } })
		spawn_workspace("otvm",
			wezterm.home_dir .. '/dev/edi-oti-otvm_containerized',
			"editor",
			"v .",
			{ { title = "logs", }, { title = "fish", } })
	end

	-- Not sure why these don't work yet.
	-- window:gui_window():maximize()
	-- window:gui_window():perform_action(act.ActivateTab(0))
end)

---------- Tab Bar ----------
config.status_update_interval = 2000
local SOLID_LEFT_ARROW = ' '
local SOLID_RIGHT_ARROW = ' '

wezterm.on(
	'format-tab-title',
	function(tab, tabs, _, _, hover, max_width)
		local edge_background = colors.dark_gray
		local background = colors.blue
		local foreground = colors.background
		if tab.is_active then
			background = colors.orange
			foreground = colors.background
		elseif hover then
			background = colors.red
			foreground = colors.background
		end

		local edge_foreground = background

		local title = tab_title(tab.tab_index, tab)

		-- ensure that the titles fit in the available space,
		-- and that we have room for the edges.
		title = " " .. wezterm.truncate_right(title, max_width - 6) .. " "

		return {
			{ Background = { Color = edge_background } },
			{ Foreground = { Color = edge_foreground } },
			{ Text = SOLID_LEFT_ARROW },
			{ Background = { Color = background } },
			{ Foreground = { Color = foreground } },
			{ Text = title },
			{ Background = { Color = edge_background } },
			{ Foreground = { Color = edge_foreground } },
			{ Text = SOLID_RIGHT_ARROW },
		}
	end

)

---------- Status Bar ----------
wezterm.on('update-status', function(window, pane)
	-- domain name
	local name = mux.get_domain():name()
	if name == "local" then
		name = " " .. wezterm.hostname() .. " "
	else
		name = " " .. name .. " "
	end

	-- workspace name
	local workspace = window:active_workspace()
	workspace = workspace .. " "

	local left_format = wezterm.format({
		{ Foreground = { Color = colors.background } },
		{ Background = { Color = colors.red } },
		{ Text = name },
		{ Foreground = { Color = colors.red } },
		{ Background = { Color = colors.green } },
		{ Text = SOLID_RIGHT_ARROW },
		{ Foreground = { Color = colors.background } },
		{ Background = { Color = colors.green } },
		{ Text = workspace },
		{ Foreground = { Color = colors.green } },
		{ Background = { Color = colors.dark_gray } },
		{ Text = SOLID_RIGHT_ARROW },

	})
	window:set_left_status(left_format)

	-- current path
	local cwd = pane:get_current_working_dir()
	if not cwd then
		return
	end
	cwd = cwd:gsub("file://", "")
	cwd = cwd:gsub(wezterm.hostname(), "")

	local entries = {}
	local cur_bg = colors.dark_gray

	-- git information
	local branch = git_branch_name(cwd)

	if branch then
		branch = " " .. branch
		table.insert(entries, { Background = { Color = cur_bg } })
		table.insert(entries, { Foreground = { Color = colors.violet } })
		table.insert(entries, { Text = SOLID_LEFT_ARROW })
		table.insert(entries, { Background = { Color = colors.violet } })
		table.insert(entries, { Foreground = { Color = colors.background } })
		table.insert(entries, { Text = branch })
		cur_bg = colors.violet
	end

	local status = git_status(cwd)
	if status then
		status = " " .. status
		table.insert(entries, { Background = { Color = cur_bg } })
		table.insert(entries, { Foreground = { Color = colors.yellow } })
		table.insert(entries, { Text = SOLID_LEFT_ARROW })
		table.insert(entries, { Background = { Color = colors.yellow } })
		table.insert(entries, { Foreground = { Color = colors.background } })
		table.insert(entries, { Text = status })
		cur_bg = colors.yellow
	end

	-- After we've done the git stuf, replace the home dir with ~
	cwd = cwd:gsub(wezterm.home_dir, "~")
	cwd = " " .. cwd
	table.insert(entries, { Background = { Color = cur_bg } })
	table.insert(entries, { Foreground = { Color = colors.blue } })
	table.insert(entries, { Text = SOLID_LEFT_ARROW })
	table.insert(entries, { Background = { Color = colors.blue } })
	table.insert(entries, { Foreground = { Color = colors.background } })
	table.insert(entries, { Text = cwd })

	local right_format = wezterm.format(entries)
	window:set_right_status(right_format)
end)


---------- Custom Events ----------
wezterm.on("user-var-changed", function(window, pane, name, value)
	if name == "WORKSPACE_CHANGED" and string.len(value) > 0 then
		-- This one currently doesn't work well. I just use the
		-- launcher.
		wezterm.GLOBAL.last_open_workspace = window:active_workspace()
		window:perform_action(
			wezterm.action.SwitchToWorkspace {
				name = value,
			},
			pane
		)
	elseif name == "CREATE_WORKSPACE" and string.len(value) > 0 then
		-- This one is sent from the `nw` script.
		wezterm.GLOBAL.last_open_workspace = window:active_workspace()
		local window_name, new_cwd = string.gmatch(value, "(%w+)|(.*)")()
		local _, new_pane, _ = spawn_workspace(window_name,
			new_cwd,
			"e️️macs",
			"e .",
			{ { title = "fish", } })
		window:perform_action(
			wezterm.action.SwitchToWorkspace {
				name = window_name,
			},
			new_pane
		)
	end
end)

wezterm.on('my-spawn-tab', function(window, pane)
	-- The key bind will trigger this and we change the
	-- title to "fish" for the shell name.
	local tab, p, w = window:mux_window():spawn_tab {}
	tab:set_title("fish")
end)

-- Return the configuration to wezterm
return config
