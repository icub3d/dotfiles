local wezterm = require 'wezterm'
local mux = wezterm.mux
local act = wezterm.action



local NU = "nu"

-- Initialize Config
local config = {}
if wezterm.config_builder then
  config = wezterm.config_builder()
end

if wezterm.target_triple:find("windows") then
  config.default_domain = "WSL:archlinux"
end

-- General Setup
config.automatically_reload_config = true
config.default_prog = { NU, "-l" }
config.scrollback_lines = 100000

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
    key = "p",
    mods = "LEADER",
    action = act.ActivateKeyTable {
      name = 'activate_pane',
      one_shot = false,
    }
  },
  {
    key = "r",
    mods = "LEADER",
    action = act.ActivateKeyTable {
      name = 'resize_pane',
      one_shot = false,
    }
  },
  {
    key = "o",
    mods = "LEADER",
    action = act.ActivatePaneDirection "Next",
  },
  {
    key = "c",
    mods = "LEADER",
    action = act.SpawnCommandInNewTab {
      args = { NU, "-l", "-c", "wezterm cli set-tab-title nu; nu" }
    }
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
    key = "]",
    mods = "LEADER",
    action = act.Search { CaseInSensitiveString = '' },
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
  },
  { key = 'PageUp',   mods = 'SHIFT', action = act.ScrollByPage(-1) },
  { key = 'PageDown', mods = 'SHIFT', action = act.ScrollByPage(1) },
}

config.key_tables = {
  resize_pane = {
    { key = 'LeftArrow',  action = act.AdjustPaneSize { 'Left', 1 } },
    { key = 'h',          action = act.AdjustPaneSize { 'Left', 1 } },

    { key = 'RightArrow', action = act.AdjustPaneSize { 'Right', 1 } },
    { key = 'l',          action = act.AdjustPaneSize { 'Right', 1 } },

    { key = 'UpArrow',    action = act.AdjustPaneSize { 'Up', 1 } },
    { key = 'k',          action = act.AdjustPaneSize { 'Up', 1 } },

    { key = 'DownArrow',  action = act.AdjustPaneSize { 'Down', 1 } },
    { key = 'j',          action = act.AdjustPaneSize { 'Down', 1 } },

    -- Cancel the mode by pressing escape
    { key = 'Escape',     action = 'PopKeyTable' },
  },

  activate_pane = {
    { key = 'LeftArrow',  action = act.ActivatePaneDirection 'Left' },
    { key = 'h',          action = act.ActivatePaneDirection 'Left' },

    { key = 'RightArrow', action = act.ActivatePaneDirection 'Right' },
    { key = 'l',          action = act.ActivatePaneDirection 'Right' },

    { key = 'UpArrow',    action = act.ActivatePaneDirection 'Up' },
    { key = 'k',          action = act.ActivatePaneDirection 'Up' },

    { key = 'DownArrow',  action = act.ActivatePaneDirection 'Down' },
    { key = 'j',          action = act.ActivatePaneDirection 'Down' },

    -- Cancel the mode by pressing escape
    { key = 'Escape',     action = 'PopKeyTable' },
  },
}

-- Use leader + [0-9] to select tabs.
for i = 0, 9 do
  table.insert(config.keys, {
    key = tostring(i),
    mods = "LEADER",
    action = act.ActivateTab(i),
  })
end

-- Setup color scheme
local scheme = wezterm.color.get_builtin_schemes()["Catppuccin Mocha"]
config.color_scheme = "Catppuccin Mocha"
config.font = wezterm.font 'JetBrains Mono'
config.font_size = 12.0

-- Window Frame
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

---------- Tab Bar ----------
config.status_update_interval = 2000
local SOLID_RIGHT_SIDE = wezterm.nerdfonts.pl_left_hard_divider .. ' '
local SOLID_LEFT_SIDE = ' ' .. wezterm.nerdfonts.pl_right_hard_divider

-- This function will return the title for a tab.
local tab_title = function(index, tab_info)
  local title = string.gsub(tab_info.tab_title, ".exe", "")
  -- if the tab title is explicitly set, take that
  if title and #title > 0 then
    return index .. ":" .. title
  end
  -- Otherwise, use the title from the active pane
  -- in that tab
  title = string.gsub(tab_info.active_pane.title, ".exe", "")
  return index .. ":" .. title
end


wezterm.on(
  'format-tab-title',
  function(tab, _, _, _, hover, max_width)
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
      { Text = SOLID_LEFT_SIDE },
      { Background = { Color = background } },
      { Foreground = { Color = foreground } },
      { Text = title },
      { Background = { Color = edge_background } },
      { Foreground = { Color = edge_foreground } },
      { Text = SOLID_RIGHT_SIDE },
    }
  end
)


---------- Status Bar ----------
local function uri_to_path(cwd_uri)
  if not cwd_uri then
    return nil
  end
  local s = tostring(cwd_uri)

  -- Strip the "file://" prefix
  s = s:gsub("^file://", "")

  if wezterm.target_triple:find("windows") then
    -- Remove leading slash before drive letter (e.g. /C:/ -> C:/)
    s = s:gsub("^/", "")
    s = s:gsub("/", "\\")
  end

  return s
end
local function get_git_info(cwd_uri)
  if not cwd_uri then
    return nil
  end

  local cwd = uri_to_path(cwd_uri)

  -- Run `git rev-parse --is-inside-work-tree` to check if it's a git repo
  local success, stdout = wezterm.run_child_process({
    'git', '-C', cwd, 'rev-parse', '--is-inside-work-tree'
  })

  if not success or not stdout:match('true') then
    return nil
  end

  -- Use porcelain v2 for structured output
  success, stdout, stderr = wezterm.run_child_process({
    'git', '-C', cwd, 'status', '--porcelain=2', '--branch'
  })
  if not success then
    return nil
  end

  local branch, ahead, behind = nil, 0, 0
  local staged, modified, untracked = 0, 0, 0

  for line in stdout:gmatch("[^\r\n]+") do
    -- Example: "# branch.head main"
    local head = line:match("^# branch%.head (.+)")
    if head then branch = head end

    -- Example: "# branch.ab +1 -2"
    local a, b = line:match("^# branch%.ab %+(%d+) %-(%d+)")
    if a or b then
      ahead = tonumber(a) or 0
      behind = tonumber(b) or 0
    end

    -- Parse file statuses: "1 XY ..." lines (tracked files)
    local xy = line:match("^1%s(..)%s")
    if xy then
      local x, y = xy:sub(1, 1), xy:sub(2, 2)
      if x ~= '.' then staged = staged + 1 end
      if y ~= '.' then modified = modified + 1 end
    end

    -- Parse untracked files: lines starting with '?'
    if line:match("^%?%s") then
      untracked = untracked + 1
    end
  end

  if not branch then
    return nil
  end

  -- Build a short, readable summary
  local parts = {}
  table.insert(parts, "  " .. branch)

  if ahead > 0 or behind > 0 then
    table.insert(parts, string.format("⇡%d ⇣%d", ahead, behind))
  end

  local changes = {}
  if staged > 0 then table.insert(changes, "+" .. staged) end
  if modified > 0 then table.insert(changes, "~" .. modified) end
  if untracked > 0 then table.insert(changes, "?" .. untracked) end

  if #changes > 0 then
    table.insert(parts, table.concat(changes, " "))
  end

  return table.concat(parts, " ")
end

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
    { Text = SOLID_RIGHT_SIDE },
    { Foreground = { Color = scheme.cursor_fg } },
    { Background = { Color = scheme.ansi[3] } },
    { Text = workspace },
    { Foreground = { Color = scheme.ansi[3] } },
    { Background = { Color = scheme.cursor_fg } },
    { Text = SOLID_RIGHT_SIDE },

  })
  window:set_left_status(left_format)

  local git_info = get_git_info(pane:get_current_working_dir()) or " nogit"
  local right_format = wezterm.format({
    { Foreground = { Color = scheme.ansi[4] } },
    { Background = { Color = scheme.cursor_fg } },
    { Text = SOLID_LEFT_SIDE },
    { Background = { Color = scheme.ansi[4] } },
    { Foreground = { Color = scheme.cursor_fg } },
    { Text = git_info },

  })
  window:set_right_status(right_format)
end)

-- Startup Behavior
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
wezterm.on('gui-startup', function(_)
  -- home
  spawn_workspace("home",
    wezterm.home_dir,
    NU,
    nil,
    {})

  -- dotfiles
  spawn_workspace("dot",
    wezterm.home_dir .. '/dev/dotfiles',
    "nv",
    { NU, "-e", "v ." },
    { { title = NU, } })
end)

return config
