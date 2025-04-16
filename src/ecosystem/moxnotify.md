# moxnotify

moxnotify is a notification server for the mox desktop environment. It handles system notifications with customizable appearance, behavior, and sound options.

# Configuration

Moxnotify's configuration is written in Lua and is located at:

- `$XDG_CONFIG_HOME/moxnotify/config.lua` or
- `~/.config/moxnotify/config.lua`

## General

| Option               | Description                                                                                                                         | Type                            | Default                                                          |
| -------------------- | ----------------------------------------------------------------------------------------------------------------------------------- | ------------------------------- | ---------------------------------------------------------------- |
| `margin`             | Margin of the daemon surface. Can be a single integer for uniform margin or a map with `top`, `right`, `bottom`, and `left` values. | int or map of int's             | `0`                                                              |
| `scroll_sensitivity` | Sensitivity of mouse scroll for notification interaction.                                                                           | float                           | `20.0`                                                           |
| `hint_characters`    | Characters used for keyboard button hints.                                                                                          | string                          | `sadfjklewcmpgh`                                                 |
| `max_visible`        | Maximum amount of notifications visible on screen at once.                                                                          | int                             | `5`                                                              |
| `anchor`             | Position of the notifications on screen (see Anchor Types below).                                                                   | Anchor                          | `top_right`                                                      |
| `layer`              | Layer on which the notifications are rendered (see Layer Types below).                                                              | Layer                           | `overlay`                                                        |
| `queue`              | Order in which notifications are dismissed (see Queue Types below).                                                                 | Queue                           | `unordered`                                                      |
| `output`             | Determines on which display output notifications will be rendered. Empty value means all outputs.                                   | string                          | `""` (empty)                                                     |
| `icon_size`          | Size of the notification icon in pixels.                                                                                            | int                             | `64`                                                             |
| `app_icon_size`      | Size of the application icon in pixels.                                                                                             | int                             | `24`                                                             |
| `default_sound_file` | Path to default sound played on new notifications that don't provide their own sound. Can be specified per urgency level.           | path or map of paths by urgency | `""` (empty)                                                     |
| `ignore_sound_file`  | When set to true, ignore sounds provided by notifications.                                                                          | bool                            | `false`                                                          |
| `default_timeout`    | Default timeout in seconds if one isn't requested by notification. Can be specified per urgency level.                              | int or map of ints by urgency   | `{ urgency_low = 5, urgency_normal = 10, urgency_critical = 0 }` |
| `ignore_timeout`     | When set to true, ignore timeout requested by notification.                                                                         | bool                            | `false`                                                          |

### History

| Option         | Description                                          | Type | Default                           |
| -------------- | ---------------------------------------------------- | ---- | --------------------------------- |
| `history.size` | Maximum number of notifications to store in history. | int  | `1000`                            |
| `history.path` | Path to the history database file.                   | path | `~/.local/share/moxnotify/db.mox` |

## Special Types

### Queue types

- `unordered`: Every notification expires independently without order
- `fifo`: Notifications expire one by one in the order they arrived (First In, First Out)

### Anchor types

- `top_right`: Notifications appear in the top-right corner
- `top_center`: Notifications appear at the top
- `top_left`: Notifications appear in the top-left corner
- `bottom_left`: Notifications appear in the bottom-left corner
- `bottom_center`: Notifications appear at the bottom
- `bottom_right`: Notifications appear in the bottom-right corner
- `center-right`: Notifications appear at the right of the screen
- `center`: Notifications appear in the center of the screen
- `center-left`: Notifications appear at the left of the screen

### Layer types

- `background`: Notifications appear behind regular windows
- `bottom`: Notifications appear above background but below regular windows
- `top`: Notifications appear above regular windows
- `overlay`: Notifications appear above all other windows

```lua
general = {
  margin = 0,  -- Alternatively, you can use a table: { top = 0, right = 0, bottom = 0, left = 0 }
  history = {
    size = 1000,
    path = "~/.local/share/moxnotify/db.mox"
  },
  default_sound_file = "",  -- Empty by default; you can also use a table to map urgency levels if needed
  ignore_sound_file = false,
  hint_characters = "sadfjklewcmpgh",
  scroll_sensitivity = 20.0,
  max_visible = 5,
  icon_size = 64,
  app_icon_size = 24,
  anchor = "top_right",  -- Default anchor position
  layer = "overlay",     -- Default layer for notifications
  queue = "unordered",   -- Default queue type
  output = nil,          -- nil means notifications will display on output chosen by compositor (Usually the one currently focused)
  default_timeout = {
    urgency_low = 5,
    urgency_normal = 10,
    urgency_critical = 0
  },
  ignore_timeout = false
}
```

## Keymaps

Moxnotify allows you to define custom keymaps for interacting with notifications inspired by vim. Each keymap consists of the following properties:

- **mode**: The mode in which the keymap is active (e.g., `"n"` for normal mode).
- **keys**: The key or combination of keys that trigger the action.
- **action**: The command that is executed when the key(s) are pressed.

### Keymap Modes

Provide a table or list that details each mode, along with a short description.

| **Mode** | **Description**                                       |
| -------- | ----------------------------------------------------- |
| n        | Normal mode – general interaction with notifications. |
| h        | Hint mode – for pressing buttons with keypresses.     |

### Keymap Actions

List each action with a clear explanation of what it does. Use a table or a bullet list for clarity.

| **Action**           | **Description**                                                |
| -------------------- | -------------------------------------------------------------- |
| dismiss_notification | Dismisses the current notification.                            |
| last_notification    | Shows the last (previous) notification.                        |
| hint_mode            | Activates hint mode for keyboard-based notification selection. |
| noop                 | No operation; placeholder that performs no action.             |
| ...                  | Add any extra actions your system supports as needed.          |

### Keymaps Configuration Example

Below is an example of the keymaps configuration in Lua:

```lua
keymaps = {
  {
    mode = "n";
    keys = "d";
    action = "dismiss_notification";
  }
  {
    mode = "n";
    keys = "<C-g>";
    action = "last_notification";
  }
  {
    mode = "n";
    keys = "gw";
    action = "hint_mode";
  }
  {
    mode = "n";
    keys = "f";
    action = "noop";
  }
}
```

## Styles

Each style rule customizes notifications based on a selector (which notifications it applies to) and an optional state (interaction state). Below is the list of fields you can configure for each style entry

| Variable           | Description                                                                                                             | Type                 | Default   |
| ------------------ | ----------------------------------------------------------------------------------------------------------------------- | -------------------- | --------- |
| selector           | Target(s) for this style rule. Can be a string (e.g. "notification") or an array of strings (e.g. {"dismiss", "hints"}) | string or string[]   | empty     |
| state              | Interaction state when this rule applies (e.g. "hover", "container_hover")                                              | string               | "default" |
| style              | The style overrides (fonts, colors, backgrounds, borders, etc.)                                                         | table (PartialStyle) | required  |
| default_timeout    | Override global timeout (in seconds) for matching notifications                                                         | number (Timeout)     | nil       |
| ignore_timeout     | Whether to ignore timeouts for matching notifications                                                                   | boolean              | nil       |
| default_sound_file | Override default sound file for matching notifications                                                                  | string (SoundFile)   | nil       |
| ignore_sound_file  | Whether to silence sounds for matching notifications                                                                    | boolean              | nil       |
