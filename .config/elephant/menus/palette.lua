--
-- System palette for Walker: Omarchy's Toggle Menu plus this rice's own commands,
-- merged into the SAME list as the application launcher. See ADR-0027.
--
-- GENERATED - do not hand-edit the glyphs. Every label carries a Nerd Font glyph, and
-- pasting those through an editor is lossy: a dropped glyph leaves an entry that renders
-- as nothing, with no error anywhere.
--
-- TWO NON-OBVIOUS MECHANISMS
--
-- 1. THE LEADING SPACE IN EVERY `Text` IS LOAD-BEARING. With an empty query Walker merges
--    every provider into one list sorted by text, so without it these entries would be
--    scattered alphabetically among the applications - "Theme" would sit between "Steam"
--    and "Typora". A leading space sorts below nothing else, so the palette clusters above
--    "Aether" and the apps follow in their own alphabetical run.
--    Measured: with the space, position 0; without it, position 49 of 65.
--
-- 2. `FixedOrder = true` SURVIVES THAT MERGE. Without it these entries would be sorted
--    alphabetically among themselves, losing Omarchy's Toggle Menu order. Verified by
--    feeding in Zebra/Apple/Mango and getting them back in that order at the top.
--
-- Neither is documented; both were established by querying elephant directly.
--
-- ORDER AND NAMING: Omarchy's Toggle Menu entries come first, in Omarchy's order and under
-- Omarchy's names, because those are canonical. This rice's own commands follow. Where
-- both had an entry, Omarchy's name wins - hence "Start Screensaver" for the one that
-- launches it, since Omarchy's "Screensaver" is the on/off toggle.
--
Name = "palette"
NamePretty = "System"
-- No Icon: the label already carries a Nerd Font glyph, and setting a provider icon makes
-- every entry render an application-style image beside it, which reads as a broken app
-- entry rather than a command. Omarchy's own menus set no icon for the same reason.
HideFromProviderlist = true
FixedOrder = true
Description = "System commands and toggles"
-- Rank a match on the label above a match on the keywords, and both above the subtext.
-- Without this, a query like "the" matches "End the session" / "Skip the boot menu" and
-- buries the applications under commands that merely contain a common word.
-- PRIORITY-REMOVED-FOR-TEST

local function cmd_ok(c)
  local ok = os.execute(c .. " >/dev/null 2>&1")
  return ok == true or ok == 0
end

local function toggle_enabled(name)
  local f = io.open(os.getenv("HOME") .. "/.local/state/omarchy/toggles/" .. name, "r")
  if f then f:close() return true end
  return false
end

local function file_exists(path)
  local f = io.open(path, "r")
  if f then f:close() return true end
  return false
end

function GetEntries()
  local entries = {}
  local function add(e) table.insert(entries, e) end

  -- Omarchy Toggle Menu, in Omarchy's order and under Omarchy's names.
  add({
    Text = " 󱄄  Screensaver",
    Keywords = {"screensaver", "idle"},
    Actions = { activate = "omarchy-toggle-screensaver" },
  })
  add({
    Text = " 󰔎  Nightlight",
    Keywords = {"night", "blue light", "warm"},
    Actions = { activate = "omarchy-toggle-nightlight" },
  })
  add({
    Text = " 󱫖  Idle Lock",
    Keywords = {"idle", "lock", "sleep"},
    Actions = { activate = "omarchy-toggle-idle" },
  })
  add({
    Text = " 󰂛  Notifications",
    Keywords = {"dnd", "do not disturb", "silence"},
    Actions = { activate = "omarchy-toggle-notification-silencing" },
  })
  add({
    Text = " 󰍜  Top Bar",
    Keywords = {"waybar", "bar", "panel"},
    Actions = { activate = "omarchy-toggle-waybar" },
  })
  add({
    Text = " 󱂬  Workspace Layout",
    Keywords = {"tiling", "dwindle", "master"},
    Actions = { activate = "omarchy-hyprland-workspace-layout-toggle" },
  })
  add({
    Text = "   Window Gaps",
    Keywords = {"gaps", "spacing"},
    Actions = { activate = "omarchy-hyprland-window-gaps-toggle" },
  })
  add({
    Text = "   1-Window Zen Ratio",
    Keywords = {"zen", "aspect", "ratio", "single window"},
    Actions = { activate = "ratio-toggle" },
  })
  add({
    Text = " 󰍹  Monitor Scaling",
    Keywords = {"scale", "hidpi", "resolution"},
    Actions = { activate = "omarchy-hyprland-monitor-scaling-cycle" },
  })
  add({
    Text = "   Direct Boot",
    Keywords = {"boot", "grub"},
    Actions = { activate = "omarchy-launch-floating-terminal-with-presentation omarchy-config-direct-boot" },
  })
  add({
    Text = " 󰟵  Passwordless Sudo",
    Keywords = {"sudo", "password"},
    Actions = { activate = "omarchy-launch-floating-terminal-with-presentation omarchy-sudo-passwordless" },
  })

  -- Appearance is dynamic: label it with where it will take you, not where you are.
  if file_exists(os.getenv("HOME") .. "/.config/omarchy/current/theme/light.mode") then
    add({
      Text = " 󰖔  Switch to Dark",
      Keywords = {"dark", "appearance", "mode"},
      Actions = { activate = "toggle-appearance" },
    })
  else
    add({
      Text = " 󰖨  Switch to Light",
      Keywords = {"light", "appearance", "mode"},
      Actions = { activate = "toggle-appearance" },
    })
  end

  add({
    Text = " 󰇲  Emoji & Symbols",
    Keywords = {"emoji", "symbol", "unicode"},
    Actions = { activate = "omarchy-launch-walker -m symbols" },
  })
  add({
    Text = " 󰅍  Clipboard History",
    Keywords = {"clipboard", "paste", "history"},
    Actions = { activate = "omarchy-launch-walker -m clipboard" },
  })
  add({
    Text = " 󰸉  Wallpaper",
    Keywords = {"background", "wallpaper"},
    Actions = { activate = "omarchy-menu background" },
  })
  add({
    Text = " 󰏘  Theme",
    Keywords = {"theme", "colours", "appearance"},
    Actions = { activate = "omarchy-menu theme" },
  })
  add({
    Text = " 󱄄  Start Screensaver",
    Keywords = {"screensaver", "blank"},
    Actions = { activate = "omarchy-launch-screensaver force" },
  })
  add({
    Text = " 󰌾  Lock",
    Keywords = {"lock", "secure"},
    Actions = { activate = "omarchy-system-lock" },
  })
  if not toggle_enabled("suspend-off") then
    add({
      Text = " 󰒲  Sleep",
      Keywords = {"suspend", "sleep"},
      Actions = { activate = "systemctl suspend" },
    })
  end
  if cmd_ok("omarchy-hibernation-available") then
    add({
      Text = " 󰤁  Hibernate",
      Keywords = {"hibernate"},
      Actions = { activate = "systemctl hibernate" },
    })
  end
  add({
    Text = " 󰍃  Log Out",
    Keywords = {"logout", "sign out"},
    Actions = { activate = "omarchy-system-logout" },
  })
  add({
    Text = " 󰜉  Restart",
    Keywords = {"reboot", "restart"},
    Actions = { activate = "omarchy-system-reboot" },
  })
  add({
    Text = " 󰐥  Shut Down",
    Keywords = {"shutdown", "power off", "poweroff"},
    Actions = { activate = "omarchy-system-shutdown" },
  })

  return entries
end
