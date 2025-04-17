# moxnotify

moxnotify is a notification server for the mox desktop environment. It handles system notifications with customizable appearance, behavior, and sound options.

## Configuration

Moxnotify's configuration is written in Lua and located at:

- `$XDG_CONFIG_HOME/moxnotify/config.lua` or
- `~/.config/moxnotify/config.lua`

## General Configuration

| Option               | Description                                                                                                                                                 | Type                            | Default                                                          |
| -------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------- | ---------------------------------------------------------------- |
| `margin`             | Margin of the daemon surface. Can be a single integer for uniform margin or a map with `top`, `right`, `bottom`, and `left` values.                         | int or map of int's             | `0`                                                              |
| `scroll_sensitivity` | Sensitivity of mouse scroll for notification interaction.                                                                                                   | float                           | `20.0`                                                           |
| `hint_characters`    | Characters used for keyboard button hints.                                                                                                                  | string                          | `sadfjklewcmpgh`                                                 |
| `max_visible`        | Maximum amount of notifications visible on screen at once.                                                                                                  | int                             | `5`                                                              |
| `anchor`             | Position of the notifications on screen.                                                                                                                    | [Anchor](#anchor)               | `top_right`                                                      |
| `layer`              | Layer on which the notifications are rendered.                                                                                                              | [Layer](#layer)                 | `overlay`                                                        |
| `queue`              | Order in which notifications are dismissed.                                                                                                                 | [Queue](#queue)                 | `unordered`                                                      |
| `output`             | Determines on which display output notifications will be rendered. Empty value means all outputs.                                                           | string                          | `""` (empty)                                                     |
| `icon_size`          | Size of the notification icon in pixels.                                                                                                                    | int                             | `64`                                                             |
| `app_icon_size`      | Size of the application icon in pixels.                                                                                                                     | int                             | `24`                                                             |
| `default_sound_file` | Path to default sound played on new notifications that don't provide their own sound. Can be specified per urgency level.                                   | path or map of paths by urgency | `""` (empty)                                                     |
| `ignore_sound_file`  | When set to true, ignore sounds provided by notifications.                                                                                                  | bool                            | `false`                                                          |
| `default_timeout`    | Default timeout in seconds if one isn't requested by notification. Can be specified per urgency level: `urgency_low`, `urgency_normal`, `urgency_critical`. | int or map of ints by urgency   | `{ urgency_low = 5, urgency_normal = 10, urgency_critical = 0 }` |
| `ignore_timeout`     | When set to true, ignore timeout requested by notification.                                                                                                 | bool                            | `false`                                                          |
| `history.size`       | Maximum number of notifications to store in history.                                                                                                        | int                             | `1000`                                                           |
| `history.path`       | Path to the history database file.                                                                                                                          | path                            | `~/.local/share/moxnotify/db.mox`                                |

### Example General Configuration

```lua
general = {
  margin = 0,  -- Alternatively, you can use a table: { top = 0, right = 0, bottom = 0, left = 0 }
  history = {
    size = 1000,
    path = "~/.local/share/moxnotify/db.mox"
  },
  default_sound_file = "/run/current-system/sw/share/sounds/freedesktop/stereo/message.oga",  -- you can also use a table to map urgency levels if needed
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

| Mode | Description                                           |
| ---- | ----------------------------------------------------- |
| n    | Normal mode – general interaction with notifications. |
| h    | Hint mode – for pressing buttons with keypresses.     |

### Keymap Actions

| Action                | Description                                                    |
| --------------------- | -------------------------------------------------------------- |
| dismiss_notification  | Dismisses the current notification.                            |
| next_notification     | Focuses next notification                                      |
| previous_notification | Focuses previous notification                                  |
| first_notification    | Focuses first notification.                                    |
| last_notification     | Focuses last notification.                                     |
| unfocus               | Unfocuses surface                                              |
| noop                  | No operation; placeholder that performs no action.             |
| hint_mode             | Activates hint mode for keyboard-based notification selection. |
| normal_mode           | Activates normal mode                                          |
| mute                  | Mutes all sounds coming from the daemon                        |
| unmute                | Unmutes all sounds coming from the daemon                      |
| toggle_mute           | Toggles mute state of the daemon                               |
| inhibit               | Inhibits notifications                                         |
| uninhibit             | Uninhibits notifications                                       |
| toggle_inhibit        | Toggles inhibit state of notifications                         |
| show_history          | Views history of notifications                                 |
| hide_history          | Hides history of notifications                                 |
| toggle_history        | Toggles history state                                          |

### Example Keymaps Configuration

```lua
keymaps = {
  {
    mode = "n";
    keys = "d";
    action = "dismiss_notification";
  },
  {
    mode = "n";
    keys = "<C-g>";
    action = "last_notification";
  },
  {
    mode = "n";
    keys = "gw";
    action = "hint_mode";
  },
  {
    mode = "n";
    keys = "f";
    action = "noop";
  }
}
```

## Styling System

Each style rule customizes notifications based on a selector (which notifications it applies to) and an optional state (interaction state).

### Style Rule Properties

| Property           | Description                                                                                                              | Type                                             | Default   |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------ | --------- |
| selector           | Target(s) for this style rule. Can be a string (e.g. "notification") or an array of strings (e.g. {"dismiss", "hints"}). | [Selector](#selector) or [Selector](#selector)[] | empty     |
| state              | Interaction state when this rule applies (e.g. "hover", "container_hover").                                              | [State](#state)                                  | "default" |
| style              | The style overrides (fonts, colors, backgrounds, borders, etc.)                                                          | Style                                            | {}        |
| default_timeout    | Override global timeout (in seconds) for matching notifications                                                          | number                                           | nil       |
| ignore_timeout     | Whether to ignore timeouts for matching notifications                                                                    | boolean                                          | nil       |
| default_sound_file | Override default sound file for matching notifications                                                                   | string (SoundFile)                               | nil       |
| ignore_sound_file  | Whether to silence sounds for matching notifications                                                                     | boolean                                          | nil       |

### Style Properties

| Property       | Description                   | Type                         |
| -------------- | ----------------------------- | ---------------------------- |
| background     | Color of background           | hex or map of hex by urgency |
| min_width      | Minimum width of the element  | int or auto                  |
| width          | Width of the element          | int or auto                  |
| max_width      | Maximum width of the element  | int or auto                  |
| min_height     | Minimum height of the element | int or auto                  |
| height         | Height of the element         | int or auto                  |
| max_height     | Maximum width of the element  | int or auto                  |
| font.size      | Size of the font              | int                          |
| font.family    | Family of the font            | string                       |
| font.color     | Color of the font             | string                       |
| border.size    | Size of the border            | int                          |
| border.color   | Color of the border           | hex or map of hex by urgency |
| border.radius  | Radius of the border          | int                          |
| margin.left    | Margin left of the element    | int                          |
| margin.right   | Margin right of the element   | int                          |
| margin.top     | Margin top of the element     | int                          |
| margin.bottom  | Margin bottom of the element  | int                          |
| padding.left   | Padding left of the element   | int                          |
| padding.right  | Padding right of the element  | int                          |
| padding.top    | Padding top of the element    | int                          |
| padding.bottom | Padding bottom of the element | int                          |

### Example Styles Configuration

```lua
styles = {
  {
    selector = "*",
    style = {
      border = {
        color = {
          urgency_critical = "#f38ba8",
          urgency_low = "#a6e3a1",
          urgency_normal = "#cba6f7"
        }
      },
      font = {
        color = "#cdd6f4",
        family = "DejaVu Sans",
        size = 10
      }
    }
  },
  {
    selector = {
      "next_counter",
      "prev_counter",
      "notification",
      "hints"
    },
    style = {
      background = {
        urgency_critical = "#181825FF",
        urgency_low = "#1e1e2eFF",
        urgency_normal = "#181825FF"
      }
    }
  },
  {
    selector = "notification",
    state = "hover",
    style = {
      background = {
        urgency_critical = "#313244FF",
        urgency_low = "#313244FF",
        urgency_normal = "#313244FF"
      }
    }
  },
  {
    selector = "action",
    state = "hover",
    style = {
      background = {
        urgency_critical = "#f38ba8",
        urgency_low = "#f2cdcd",
        urgency_normal = "#f2cdcd"
      }
    }
  },
  {
    selector = "progress",
    style = {
      background = {
        urgency_critical = "#f38ba8",
        urgency_low = "#f2cdcd",
        urgency_normal = "#f2cdcd"
      }
    }
  },
  {
    selector = "dismiss",
    style = {
      font = {
        color = "#00000000"
      }
    }
  },
  {
    selector = "dismiss",
    state = "container_hover",
    style = {
      font = {
        color = "#000000"
      }
    }
  }
}
```

## Special Types

<a id="queue"></a>

### Queue

- `unordered`: Every notification expires independently without order
- `fifo`: Notifications expire one by one in the order they arrived (First In, First Out)

<a id="anchor"></a>

### Anchor

- `top_right`: Notifications appear in the top-right corner
- `top_center`: Notifications appear at the top
- `top_left`: Notifications appear in the top-left corner
- `bottom_left`: Notifications appear in the bottom-left corner
- `bottom_center`: Notifications appear at the bottom
- `bottom_right`: Notifications appear in the bottom-right corner
- `center-right`: Notifications appear at the right of the screen
- `center`: Notifications appear in the center of the screen
- `center-left`: Notifications appear at the left of the screen

<a id="layer"></a>

### Layer

- `background`: Notifications appear behind regular windows
- `bottom`: Notifications appear above background but below regular windows
- `top`: Notifications appear above regular windows
- `overlay`: Notifications appear above all other windows

<a id="selector"></a>

### Selector

- `all`: Every element
- `prev_counter`: The "previous" badge
- `next_counter`: The "next" badge
- `all_notifications`: The whole notification list
- `notification = <string>`: A specific notification instance
- `action_button`: Any action button
- `dismiss_button`: The dismiss ("×") button
- `progress`: Progress bar
- `icon`: The notification's icon
- `hints`: Keyboard hint overlays

<a id="state"></a>

### States

The State enum controls when a style fires:

- `default`: Normal, resting state
- `hover`: When the mouse is over the target
- `container_hover`: When the mouse is anywhere over the notification container
- `container_hover = <string>`: Hover state for a container with a specific name
