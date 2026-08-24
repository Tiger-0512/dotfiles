#!/bin/sh
# Focus the next agent pane that is waiting for the user.
#
# Bound to ctrl+a from config.toml as a [[keys.command]] of type = "shell",
# which Herdr runs detached through /bin/sh -c.
#
# Herdr has no keybinding action for "focus the agent that needs attention" —
# [keys] only offers previous_agent / next_agent (plain sidebar order) and the
# indexed focus_agent. So resolve the target over the socket API instead.
#
# Queue order is blocked (waiting for input) first, then done (finished).
# Pressing the key repeatedly walks that queue: when the currently focused pane
# is already in it, the next entry is picked.
set -eu

# Herdr's server inherits the env of whatever launched it, so don't rely on the
# login shell's PATH being present.
PATH="$HOME/.nix-profile/bin:/etc/profiles/per-user/${USER:-$(id -un)}/bin:/run/current-system/sw/bin:/usr/local/bin:$PATH"
export PATH

command -v herdr >/dev/null 2>&1 || exit 0
command -v jq >/dev/null 2>&1 || exit 0

target=$(herdr agent list | jq -r '
  ( [ .result.agents[] | select(.agent_status == "blocked") ]
    + [ .result.agents[] | select(.agent_status == "done") ] ) as $queue
  | ( $queue | map(.focused) | index(true) ) as $current
  | if ($queue | length) == 0 then ""
    elif $current == null then $queue[0].pane_id
    else $queue[(($current + 1) % ($queue | length))].pane_id
    end
')

if [ -z "$target" ]; then
  herdr notification show "No agent is waiting" >/dev/null 2>&1 || true
  exit 0
fi

herdr agent focus "$target" >/dev/null 2>&1 || true
