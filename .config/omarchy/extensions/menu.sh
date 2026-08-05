# Omarchy menu overrides. Sourced by omarchy-menu at
# ~/.config/omarchy/extensions/menu.sh - the sanctioned extension point, so nothing in
# Omarchy's read-only tree is touched.
#
# WARNING, from Omarchy's own template: an overridden function does NOT receive upstream
# updates. show_toggle_menu below is a verbatim copy of Omarchy's with two edits, so if
# Omarchy adds or renames a Toggle Menu entry, this copy will silently lack it. Re-copy
# from $OMARCHY_PATH/bin/omarchy-menu after an update that changes that menu.
#
# WHY IT IS OVERRIDDEN
#
# The "1-Window Ratio" entry dispatched to
# omarchy-hyprland-window-single-square-aspect-toggle, which hardcodes a 1:1 ratio. This
# rice runs 6:5 (ADR-0026), so the menu entry applied the wrong value. Omarchy's script
# cannot be shadowed on PATH - ~/.local/share/omarchy/bin precedes ~/.local/bin - so the
# menu itself is the place to fix it.
#
# Generated from Omarchy's source rather than retyped, so the Nerd Font glyphs in the
# option labels are preserved exactly. THE ONLY EDITS ARE:
#   label     "1-Window Ratio"  ->  "1-Window Zen Ratio"
#   dispatch  omarchy-hyprland-window-single-square-aspect-toggle  ->  ratio-toggle

show_toggle_menu() {
  local options="󱄄  Screensaver\n󰔎  Nightlight\n󱫖  Idle Lock\n󰂛  Notifications\n󰍜  Top Bar\n󱂬  Workspace Layout\n  Window Gaps\n  1-Window Zen Ratio\n󰍹  Monitor Scaling\n  Direct Boot\n󰟵  Passwordless Sudo"

  case $(menu "Toggle" "$options") in
  *Screensaver*) omarchy-toggle-screensaver ;;
  *Nightlight*) omarchy-toggle-nightlight ;;
  *Idle*) omarchy-toggle-idle ;;
  *Notifications*) omarchy-toggle-notification-silencing ;;
  *Bar*) omarchy-toggle-waybar ;;
  *Layout*) omarchy-hyprland-workspace-layout-toggle ;;
  *Ratio*) ratio-toggle ;;
  *Gaps*) omarchy-hyprland-window-gaps-toggle ;;
  *Scaling*) omarchy-hyprland-monitor-scaling-cycle ;;
  *"Direct Boot"*) present_terminal omarchy-config-direct-boot ;;
  *"Passwordless Sudo"*) present_terminal omarchy-sudo-passwordless ;;
  *) back_to show_trigger_menu ;;
  esac
}
