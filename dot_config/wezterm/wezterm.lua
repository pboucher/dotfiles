-- Awesome intro to WezTerm configuration and other config examples and resources
-- https://alexplescan.com/posts/2024/08/10/wezterm/
-- https://mwop.net/blog/2024-07-04-how-i-use-wezterm.html

local wezterm = require 'wezterm'
local projects = require 'projects'

local config = wezterm.config_builder()
local FONT = 'CommitMono Nerd Font Mono'
-- local FONT = 'GeistMono Nerd Font Mono'

-- Theme
config.color_scheme = 'catppuccin-mocha'

-- Font
config.font = wezterm.font({ family = FONT })
config.font_size = 15
config.window_frame = {
  font = wezterm.font({ family = FONT, weight = 'Bold' }),
  font_size = 13,
}
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }
config.adjust_window_size_when_changing_font_size = false
config.scrollback_lines = 5000
-- config.pane_focus_follows_mouse = true
config.use_fancy_tab_bar = true
config.switch_to_last_active_tab_when_closing_tab = true
config.tab_bar_at_bottom = true
config.window_padding = {
    left = 20,
    right = 20,
    top = 10,
    bottom = 10,
}
config.window_close_confirmation = "NeverPrompt"

-- Slightly transparent and blurred background
config.window_background_opacity = 0.98
config.macos_window_background_blur = 80

-- Removes the title bar, leaving only the tab bar. Keeps
-- the ability to resize by dragging the window's edges.
-- On macOS, 'RESIZE|INTEGRATED_BUTTONS' also looks nice if
-- you want to keep the window controls visible and integrate
-- them into the tab bar.
config.window_decorations = 'RESIZE'


--------------------------------------------------------------------------------
-- Powerline / Starship -like right side header
--------------------------------------------------------------------------------
local function segments_for_right_status(window)
  return {
    window:active_workspace(),
    wezterm.strftime('%a %b %-d %H:%M'),
    wezterm.hostname(),
  }
end

wezterm.on('update-right-status', function(window, _)
  local SOLID_LEFT_ARROW = utf8.char(0xe0b2)
  local segments = segments_for_right_status(window)
  local color_scheme = window:effective_config().resolved_palette

  -- Note the use of wezterm.color.parse here, this returns
  -- a Color object, which comes with functionality for lightening
  -- or darkening the colour (amongst other things).
  if window:leader_is_active() then
    bg = wezterm.color.parse(color_scheme.foreground)
    fg = color_scheme.background
  else
    bg = wezterm.color.parse(color_scheme.background)
    fg = color_scheme.foreground
  end

  -- Each powerline segment is going to be coloured progressively
  -- darker/lighter depending on whether we're on a dark/light colour
  -- scheme. Let's establish the "from" and "to" bounds of our gradient.
  local gradient_to, gradient_from = bg
  gradient_from = gradient_to:lighten(0.3)

  -- Yes, WezTerm supports creating gradients, because why not?! Although
  -- they'd usually be used for setting high fidelity gradients on your terminal's
  -- background, we'll use them here to give us a sample of the powerline segment
  -- colours we need.
  local gradient = wezterm.color.gradient(
    {
      orientation = 'Horizontal',
      colors = { gradient_from, gradient_to },
    },
    #segments -- only gives us as many colours as we have segments.
  )

  -- We'll build up the elements to send to wezterm.format in this table.
  local elements = {}
  for i, seg in ipairs(segments) do
    local is_first = i == 1
    if is_first then
      table.insert(elements, { Background = { Color = 'none' } })
    end
    table.insert(elements, { Foreground = { Color = gradient[i] } })
    table.insert(elements, { Text = SOLID_LEFT_ARROW })
    table.insert(elements, { Foreground = { Color = fg } })
    table.insert(elements, { Background = { Color = gradient[i] } })
    table.insert(elements, { Text = ' ' .. seg .. ' ' })
  end
  window:set_right_status(wezterm.format(elements))
end)


--------------------------------------------------------------------------------
-- Keybindings
--------------------------------------------------------------------------------
config.leader = { key = 'a', mods = 'ALT', timeout_milliseconds = 2000 }

local function move_pane(key, direction)
  return {
    key = key,
    mods = 'LEADER',
    action = wezterm.action.ActivatePaneDirection(direction),
  }
end

local function resize_pane(key, direction)
  return {
    key = key,
    action = wezterm.action.AdjustPaneSize { direction, 3 }
  }
end

config.keys = {
  -- Left word jump - sends ESC + b
  {
    key = 'LeftArrow',
    mods = 'OPT',
    action = wezterm.action.SendString '\x1bb',
  },
  -- Right word jump - sends ESC + f
  {
    key = 'RightArrow',
    mods = 'OPT',
    action = wezterm.action.SendString '\x1bf',
  },
  -- Open preferences (this file) in VSCode
  {
    key = ',',
    mods = 'CMD',
    action = wezterm.action.SpawnCommandInNewTab {
      cwd = wezterm.home_dir,
      args = { '/opt/homebrew/bin/code', wezterm.config_file },
    },
  },
  -- Clear scrollback and send CTRL + l to redraw the prompt
  {
    key = 'k',
    mods = 'CMD',
    action = wezterm.action.Multiple {
      wezterm.action.ClearScrollback 'ScrollbackAndViewport',
      wezterm.action.SendKey { key = 'l', mods = 'CTRL' },
    },
  },
  -- Launch project picker
  {
    key = 'p',
    mods = 'LEADER',
    action = projects.choose_project(),
  },
  -- Launch workspace picker
  {
    key = 'f',
    mods = 'LEADER',
    action = wezterm.action.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' },
  },
  -- Split panes horizontally
  {
    key = '"',
    mods = 'LEADER',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  -- Split panes vertically
  {
    key = '%',
    mods = 'LEADER',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  -- Move between panes - LEADER + ...
  move_pane('j', 'Down'),
  move_pane('k', 'Up'),
  move_pane('h', 'Left'),
  move_pane('l', 'Right'),
  move_pane('DownArrow', 'Down'),
  move_pane('UpArrow', 'Up'),
  move_pane('LeftArrow', 'Left'),
  move_pane('RightArrow', 'Right'),
  -- Change tab title
  {
    key = 'T',
    mods = 'CMD|SHIFT',
    action = wezterm.action.PromptInputLine {
      description = 'Enter new name for tab',
      action = wezterm.action_callback(
        function(window, pane, line)
          if line then
            window:active_tab():set_title(line)
          end
        end
      ),
    },
  },
  -- Change workspace title
  {
    key = 'W',
    mods = 'CMD|SHIFT',
    action = wezterm.action.PromptInputLine {
      description = 'Enter new name for workspace',
      action = wezterm.action_callback(
        function(window, pane, line)
          if line then
            wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
          end
        end
      ),
    },
  },
  -- Keybinding layer to resize panes
  {
    key = 'r',
    mods = 'LEADER',
    -- Activate the `resize_panes` keytable
    action = wezterm.action.ActivateKeyTable {
      name = 'resize_panes',
      -- Ensures the keytable stays active after it handles its
      -- first keypress.
      one_shot = false,
      -- Deactivate the keytable after a timeout.
      timeout_milliseconds = 1000,
    }
  },
}

config.key_tables = {
  -- Keytable for resizing panes - LEADER + R + ...
  resize_panes = {
    resize_pane('j', 'Down'),
    resize_pane('k', 'Up'),
    resize_pane('h', 'Left'),
    resize_pane('l', 'Right'),
    resize_pane('DownArrow', 'Down'),
    resize_pane('UpArrow', 'Up'),
    resize_pane('LeftArrow', 'Left'),
    resize_pane('RightArrow', 'Right'),
  },
}

-- Returns our config to be evaluated. We must always do this at the bottom of this file
return config
