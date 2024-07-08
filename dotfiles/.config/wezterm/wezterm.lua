-- Pull in the wezterm API
local wezterm = require 'wezterm'
local mux = wezterm.mux
local act = wezterm.action

local nu = "nu"
if wezterm.target_triple == "aarch64-apple-darwin" then
  nu = "/opt/homebrew/bin/nu"
end


-- Colors --
local scheme = wezterm.color.get_builtin_schemes()["Catppuccin Mocha"]

------------ Helper Functions ------------
local git_info = function(cwd)
  local info = io.popen("git-status-tracker get -p \"" .. cwd .. "\"")
  if not info then
    return false
  end
  local lines = {}
  for line in info:lines() do
    table.insert(lines, line)
  end
  return lines[1], lines[2]
end

local spawn_workspace = function(name, cwd, title, args, tabs)
  -- create the new workspace
  local tab, pane, window = mux.spawn_window({
    workspace = name,
    cwd = cwd,
    args = args,
  })

  -- Set values if we are given them.
  if title ~= "" and title ~= nil then
    tab:set_title(title)
  end

  -- Do the same for each additional tab
  for _, tab_info in ipairs(tabs) do
    local new_tab, _, _ = window:spawn_tab {
      cwd = cwd,
      args = tab_info.args,
    }

    if tab_info.title ~= "" and tab_info.title ~= nil then
      new_tab:set_title(tab_info.title)
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

-- default values
config.default_prog = { nu, "-l" }

-- Keybindings
config.leader = { key = "o", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
  {
    key = "F11",
    mods = "SHIFT",
    action = act.ToggleFullScreen,
  },
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
      action = wezterm.action_callback(function(window, _, text)
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

-- Use leader + [0-9] to select tabs.
for i = 0, 9 do
  table.insert(config.keys, {
    key = tostring(i),
    mods = "LEADER",
    action = act.ActivateTab(i),
  })
end

-- Color Palette
config.color_scheme = "Catppuccin Mocha"

-- Don't darken inactive panes
config.inactive_pane_hsb = {
  saturation = 1.0,
  brightness = 0.85,
}

-- Font
config.font = wezterm.font 'JetBrains Mono'
config.font_size = 17.0

-- Window
-- config.window_background_image = wezterm.home_dir .. "/Pictures/marshians-green-background-2k.png"
-- config.window_background_opacity = 0.9
-- config.text_background_opacity = 0.9
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
  active_titlebar_bg = scheme.background,
  inactive_titlebar_bg = scheme.background,
  button_bg = scheme.background,
  button_fg = scheme.ansi[3],
  button_hover_fg = scheme.background,
  button_hover_bg = scheme.ansi[3]
}
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false

-- Launcher
local launch_menu = {}

if wezterm.target_triple == "aarch64-apple-darwin" or wezterm.target_triple == "x86_64-unknown-linux-gnu" then
  table.insert(launch_menu, {
    label = "top",
    args = { nu, "-c", "bpytop" },
  })
end

table.insert(launch_menu, {
  label = "nw (new workspace)",
  args = { nu, "-l", "-c", "nw" },
})

config.launch_menu = launch_menu

-- Startup Behavior
wezterm.on('gui-startup', function(_)
  -- home
  local _, _, window = spawn_workspace("home",
    wezterm.home_dir,
    nu,
    nil,
    {})

  -- dotfiles
  spawn_workspace("dot",
    wezterm.home_dir .. '/dev/dotfiles',
    "nv",
    { nu, "-e", "v ." },
    { { title = "nu", } })

  -- work stuff
  if os.getenv("ATWORK") == "true" then
    spawn_workspace("oti",
      wezterm.home_dir .. '/dev/oti-azure',
      "nv",
      { nu, "-e", "v ." },
      { { title = "logs", }, { title = "nu", } })
    spawn_workspace("otvm",
      wezterm.home_dir .. '/dev/edi-oti-otvm_containerized',
      "nv",
      { nu, "-e", "v ." },
      { { title = "logs", }, { title = "nu", } })
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
    local edge_background = scheme.cursor_fg
    local background = scheme.ansi[7]
    local foreground = scheme.cursor_fg
    if tab.is_active then
      background = scheme.indexed[16]
      foreground = scheme.cursor_fg
    elseif hover then
      background = scheme.ansi[2]
      foreground = scheme.cursor_fg
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
  local hostname = string.lower(wezterm.hostname())

  -- domain name
  local name = mux.get_domain():name()
  if name == "local" then
    name = " " .. hostname .. " "
  else
    name = " " .. name .. " "
  end

  -- workspace name
  local workspace = window:active_workspace()
  workspace = workspace .. " "

  local left_format = wezterm.format({
    { Foreground = { Color = scheme.cursor_fg } },
    { Background = { Color = scheme.ansi[2] } },
    { Text = name },
    { Foreground = { Color = scheme.ansi[2] } },
    { Background = { Color = scheme.ansi[3] } },
    { Text = SOLID_RIGHT_ARROW },
    { Foreground = { Color = scheme.cursor_fg } },
    { Background = { Color = scheme.ansi[3] } },
    { Text = workspace },
    { Foreground = { Color = scheme.ansi[3] } },
    { Background = { Color = scheme.cursor_fg } },
    { Text = SOLID_RIGHT_ARROW },

  })
  window:set_left_status(left_format)

  -- current path
  local cwd = pane:get_current_working_dir()
  if not cwd then
    return
  end
  local file_path = cwd.file_path
  if string.find(file_path, "/%u:/") == 1 then
    file_path = file_path:sub(2)
  end

  local entries = {}
  local cur_bg = scheme.cursor_fg

  -- git information
  local branch, status = git_info(file_path)

  if branch then
    branch = " " .. branch
    table.insert(entries, { Background = { Color = cur_bg } })
    table.insert(entries, { Foreground = { Color = scheme.ansi[5] } })
    table.insert(entries, { Text = SOLID_LEFT_ARROW })
    table.insert(entries, { Background = { Color = scheme.ansi[5] } })
    table.insert(entries, { Foreground = { Color = scheme.cursor_fg } })
    table.insert(entries, { Text = branch })
    cur_bg = scheme.ansi[5]
  end

  if status then
    status = " " .. status
    table.insert(entries, { Background = { Color = cur_bg } })
    table.insert(entries, { Foreground = { Color = scheme.ansi[4] } })
    table.insert(entries, { Text = SOLID_LEFT_ARROW })
    table.insert(entries, { Background = { Color = scheme.ansi[4] } })
    table.insert(entries, { Foreground = { Color = scheme.cursor_fg } })
    table.insert(entries, { Text = status })
    cur_bg = scheme.ansi[4]
  end

  -- After we've done the git stuff, replace the home dir with ~
  local path = cwd
  cwd = cwd.path
  if cwd:gmatch(wezterm.home_dir) then
    cwd = cwd:gsub(wezterm.home_dir, "~")
  end
  -- If there are more than 2 directors, truncate the middle
  -- ones.
  local dirs = {}
  for dir in cwd:gmatch("[^/]+") do
    table.insert(dirs, dir)
  end
  if #dirs > 2 then
    local middle = ""
    for i = 2, #dirs - 1 do
      middle = middle .. dirs[i]:sub(1, 1) .. "/"
    end
    cwd = dirs[1] .. "/" .. middle .. dirs[#dirs]
  end

  -- Add the host if it's not our host.
  if path.host ~= nil and string.lower(path.host) ~= wezterm.hostname() then
    cwd = string.lower(path.host) .. ":" .. cwd
  end
  cwd = " " .. cwd

  table.insert(entries, { Background = { Color = cur_bg } })
  table.insert(entries, { Foreground = { Color = scheme.ansi[7] } })
  table.insert(entries, { Text = SOLID_LEFT_ARROW })
  table.insert(entries, { Background = { Color = scheme.ansi[7] } })
  table.insert(entries, { Foreground = { Color = scheme.cursor_fg } })
  table.insert(entries, { Text = cwd })

  local right_format = wezterm.format(entries)
  window:set_right_status(right_format)
end)


---------- Custom Events ----------
wezterm.on("user-var-changed", function(window, pane, name, value)
  wezterm.log_info("user-var-changed: " .. name .. " = " .. value)
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
      "nv",
      { nu, "-e", "v ." },
      { { title = "nu", } })
    window:perform_action(
      wezterm.action.SwitchToWorkspace {
        name = window_name,
      },
      new_pane
    )
  end
end)

wezterm.on('my-spawn-tab', function(window, _)
  -- The key bind will trigger this and we change the
  -- title to "nu" for the shell name.
  local tab, _, _ = window:mux_window():spawn_tab {}
  tab:set_title("nu")
end)

-- Return the configuration to wezterm
return config
