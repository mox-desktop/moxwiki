# moxidle

moxidle is an idle management daemon for Mox

# Configuration

Moxidle's configuration is written in Lua and is located at $XDG_CONFIG_HOME/moxidle/config.lua
or ~/.config/moxidle/config.lua. A config file is required; moxidle won’t run without one.

# General

| variable | description | type | default |
|----------|----------|----------|----------|
| lock_cmd | command to run when receiving a dbus lock event (e.g. loginctl lock-session) | string | empty |
| unlock_cmd | command to run when receiving a dbus unlock event (e.g. loginctl unlock-session) | string | empty |
| before_sleep_cmd | command to run when receiving a dbus prepare_sleep event | string | empty |
| after_sleep_cmd | command to run when receiving a dbus post prepare_sleep event | string | empty |
| ignore_dbus_inhibit | whether to ignore dbus-sent idle inhibit events (e.g. from firefox) | bool | false |
| ignore_systemd_inhibit | whether to ignore systemd-inhibit --what=idle inhibitors | bool | false |
| ignore_audio_inhibit | whether to ignore ihbitition when audio is played (e.g. from firefox) | bool | false |

# Conditions

- **`on_battery`**:
   - Triggers when the system is running on battery power (not plugged into AC).

- **`on_ac`**:
   - Triggers when the system is plugged into an AC power source.

- **`battery_below = <int>`**:
   - Triggers when the battery level is below the specified percentage (e.g., `battery_below = 20`).

- **`battery_above = <int>`**:
   - Triggers when the battery level is above the specified percentage (e.g., `battery_above = 80`).

- **`battery_equal = <int>`**:
   - Triggers when the battery level is equal to the specified percentage (e.g., `battery_equal = 50`).

- **`battery_equal = <int>`**:
   - Triggers when the battery level is equal to the specified percentage (e.g., `battery_equal = 50`).

- **`battery_level = <BatteryLevel>`**:
   - Triggers when the battery level is equal to the specified level (e.g., `battery_level = critical`).

- **`battery_state = <BatteryState>`**:
   - Triggers when the battery state is equal to the specified state (e.g., `battery_state = charging`).

#### Valid `BatteryLevel` Values
- `"unkown"` or `0`
- `"none"` or `1`
- `"low"` or `3`
- `"critical"` or `4`
- `"normal"` or `6`
- `"high"` or `7`
- `"full"` or `8`
  
#### Valid `BatteryState` Values
- `"unkown"` or `0`
- `"charging"` or `1`
- `"discharging"` or `2`
- `"empty"` or `3`
- `"fully_charged"` or `4`
- `"pending_charge"` or `5`
- `"pending_discharge"` or `6`

# Timeouts

Moxidle uses timeouts to define actions on idleness.

When conditions are met and the system is idle, the timeout countdown (in seconds) begins.  
After the timeout duration, `on_timeout` is triggered.  
When user activity resumes, `on_resume` is executed.

Example timeout:

```
{
  conditions = { "on_battery" },             -- Conditions that must be fullfilled for timeout to begin
  timeout = 300,                             -- In seconds
  on-timeout = notify-send "You are idle!"   -- Command to run when timeout has passed.
  on_resume = "notify-send 'Welcome back!'", -- Command to run when activity is detected after timeout has fired.
},
```

You can define as many listeners as you want.

Full example with hyprlock

```
return {
  general = {
    lock_cmd = "pidof hyprlock || hyprlock",                 -- If hyprlock isn't running, start it. Prevents multiple instances.
    before_sleep_cmd = "loginctl lock-session",              -- Locks the session before the system sleeps.
  },

  timeouts = {
    {
      conditions = { "on_battery", { battery_below = 20 } }, -- Applies when on battery and battery is below 20%.
      timeout = 300,                                         -- Waits 5 minutes (300 seconds) of inactivity.
      on_timeout = "systemctl suspend",                      -- Suspends the system when timeout hits.
    },

    {
      conditions = { "on_ac" },                              -- Applies when plugged into AC power.
      timeout = 300,                                         -- Waits 5 minutes.
      on_timeout = "pidof hyprlock || hyprlock",             -- Locks the screen if not already locked.
    },
    {
      conditions = { "on_ac" },                              -- Still on AC power.
      timeout = 900,                                         -- Waits 15 minutes.
      on_timeout = "systemctl suspend",                      -- Suspends the system after 15 minutes of inactivity.
    },
  },
}
```
