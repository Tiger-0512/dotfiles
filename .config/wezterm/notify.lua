local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

local MAX_NOTIFICATIONS = 50
local notifications = {}
local notified_tabs = {}
local notified_panes = {}
local active_tab_timer = {}

local HOME = os.getenv("HOME")
local NOTIF_FILE = HOME .. "/.local/share/wezterm-notify/notifications.json"

-- JSON文字列エスケープ
local function esc(s)
	return (s or "")
		:gsub('\\', '\\\\')
		:gsub('"', '\\"')
		:gsub('\n', '\\n')
		:gsub('\r', '')
		:gsub('\t', '  ')
		:gsub('[%c]', '')
end

-- JSONファイルに保存
local function save()
	os.execute("mkdir -p '" .. HOME .. "/.local/share/wezterm-notify'")
	local f = io.open(NOTIF_FILE, "w")
	if not f then
		return
	end
	f:write("[\n")
	for i, n in ipairs(notifications) do
		if i > 1 then
			f:write(",\n")
		end
		f:write(string.format(
			'{"tab_id":%d,"pane_id":%d,"title":"%s","body":"%s","time":%d,"pane_text":"%s"}',
			n.tab_id, n.pane_id, esc(n.title), esc(n.body), n.time, esc(n.pane_text)
		))
	end
	f:write("\n]")
	f:close()
end

-- 起動時にJSONから復元
local function load()
	local f = io.open(NOTIF_FILE, "r")
	if not f then
		return
	end
	local content = f:read("*a")
	f:close()
	local ok, data = pcall(wezterm.json_parse, content)
	if ok and type(data) == "table" then
		for _, n in ipairs(data) do
			notifications[#notifications + 1] = n
		end
	end
end

load()

-- ペインの最後の30行を取得
local function get_pane_text(pane)
	local ok, text = pcall(function()
		return pane:get_lines_as_text()
	end)
	return ok and text or ""
end

local function add_notification(tab_id, pane_id, title, body, pane_text)
	table.insert(notifications, 1, {
		tab_id = tab_id,
		pane_id = pane_id,
		title = title,
		body = body,
		time = os.time(),
		pane_text = pane_text or "",
	})
	while #notifications > MAX_NOTIFICATIONS do
		table.remove(notifications)
	end
	notified_panes[tostring(pane_id)] = tab_id
	pcall(save)
end

function M.has_notification(tab_id)
	return notified_tabs[tostring(tab_id)] == true
end

function M.is_timer_active(tab_id)
	return active_tab_timer[tostring(tab_id)] == true
end

function M.clear_tab(tab_id)
	notified_tabs[tostring(tab_id)] = nil
end

-- bell発火時にアクティブだったペインは、一度フォーカスが外れるまでクリアしない
local bell_origin_panes = {}
local has_left_pane = {}

function M.clear_active_tab(window)
	local p = window:active_pane()
	if not p then
		return
	end
	local pk = tostring(p:pane_id())

	-- bell発火ペインにまだいる場合はクリアしない
	if bell_origin_panes[pk] and not has_left_pane[pk] then
		return
	end

	-- 一度離れたペインに戻ってきた場合はクリア
	if bell_origin_panes[pk] and has_left_pane[pk] then
		bell_origin_panes[pk] = nil
		has_left_pane[pk] = nil
	end

	-- 他のペインにフォーカスしたら「離れた」フラグを立てる
	for bpk, _ in pairs(bell_origin_panes) do
		if bpk ~= pk then
			has_left_pane[bpk] = true
		end
	end

	local tid = notified_panes[pk]
	if not tid then
		return
	end
	notified_panes[pk] = nil
	local tk = tostring(tid)
	for _, v in pairs(notified_panes) do
		if tostring(v) == tk then
			return
		end
	end
	notified_tabs[tk] = nil
end

-- 通知ビューアから開かれたタブを記録（bellを無視するため）
local viewer_source_tab_id = nil

function M.show_notifications()
	return wezterm.action_callback(function(window, pane)
		-- 既に通知タブが開いていたら閉じる
		local mux_win = window:mux_window()
		for i, tab in ipairs(mux_win:tabs()) do
			local title = tab:active_pane():get_title()
			if title:find("Notifications") then
				local ap = tab:active_pane()
				window:perform_action(act.ActivateTab(i - 1), ap)
				window:perform_action(act.CloseCurrentTab({ confirm = false }), ap)
				return
			end
		end

		pcall(save)
		local nf = NOTIF_FILE
		local script = 'export PATH="/opt/homebrew/bin:$PATH"\n'
			.. 'NOTIF_FILE="' .. nf .. '"\nexport NOTIF_FILE\n'
			.. [=[
printf "\033]2;Notifications🔔\007"
count=$(jq length < "$NOTIF_FILE" 2>/dev/null)
if [ -z "$count" ] || [ "$count" = "0" ]; then
  echo "通知はありません"
  sleep 1
  exit 0
fi

selected=$(fzf \
  --ansi \
  --layout=reverse \
  --border=rounded \
  --border-label=" 🔔 Notifications " \
  --header="Enter: 遷移 / Ctrl-X: 全クリア / Ctrl-U/D: スクロール / Esc: 閉じる" \
  --preview='idx=$(echo {} | cut -d: -f1); echo "🔔 Notification Detail"; echo "─────────────────────"; jq -r --argjson i "$idx" "\"⏰ \" + (.[\$i].time | strftime(\"%H:%M:%S\")) + \"  \" + .[\$i].title + \" - \" + .[\$i].body + \"\n📑 Tab:#\" + (.[\$i].tab_id|tostring) + \"  🔲 Pane:#\" + (.[\$i].pane_id|tostring)" "$NOTIF_FILE"; echo ""; echo "── Pane Content ──────────"; jq -r --argjson i "$idx" ".[\$i].pane_text" "$NOTIF_FILE"' \
  --preview-window=right:50%:wrap \
  --bind="ctrl-d:preview-half-page-down" \
  --bind="ctrl-u:preview-half-page-up" \
  --bind="ctrl-x:become(echo clear_all)" \
  < <(jq -r 'to_entries[] | "\(.key):\(.value.time | strftime("%H:%M:%S"))  \(.value.title) - \(.value.body)"' "$NOTIF_FILE") \
  || true)

if [ -n "$selected" ]; then
  if [ "$selected" = "clear_all" ]; then
    printf "\033]1337;SetUserVar=%s=%s\007" "WEZTERM_NOTIF_RESULT" "$(echo -n 'clear_all' | base64)"
  else
    key=$(echo "$selected" | cut -d: -f1)
    printf "\033]1337;SetUserVar=%s=%s\007" "WEZTERM_NOTIF_RESULT" "$(echo -n "$key" | base64)"
  fi
  sleep 0.5
fi
]=]
		window:perform_action(
			act.SpawnCommandInNewTab({ args = { "bash", "-c", script } }),
			pane
		)
	end)
end

function M.apply_to_config(config, opts)
	opts = opts or {}
	config.audible_bell = "Disabled"

	wezterm.on("bell", function(window, pane)
		local tab = pane:tab()
		if not tab then
			return
		end
		local tab_id = tab:tab_id()
		local title = pane:get_title()
		-- 通知ビューアタブは無視
		if title:find("Notifications") then
			return
		end
		-- アクティブタブではタブ装飾を付けない
		local mux_win = window:mux_window()
		local active_tab = mux_win:active_tab()
		local is_active = active_tab and active_tab:tab_id() == tab_id

		local pane_text = get_pane_text(pane)
		add_notification(tab_id, pane:pane_id(), title, "completed", pane_text)
		notified_tabs[tostring(tab_id)] = true
		local pk = tostring(pane:pane_id())
		if is_active then
			bell_origin_panes[pk] = true
			has_left_pane[pk] = nil
		end
		window:toast_notification("WezTerm", title .. " - completed")
		-- タブバーの再描画を強制
		window:set_right_status("")
		wezterm.background_child_process({ "osascript", "-e", "beep" })
	end)

	wezterm.on("user-var-changed", function(window, pane, name, value)
		if name == "WEZTERM_NOTIFY" and value ~= "" then
			local tab = pane:tab()
			local tab_id = tab and tab:tab_id() or 0
			local title, body = value:match("^([^:]*):(.*)$")
			if not title then
				title = pane:get_title()
				body = value
			end
			local pane_text = get_pane_text(pane)
			add_notification(tab_id, pane:pane_id(), title, body, pane_text)
			window:toast_notification("WezTerm", title .. " - " .. body)
			wezterm.background_child_process({ "osascript", "-e", "beep" })
		elseif name == "WEZTERM_NOTIF_RESULT" and value ~= "" then
			window:perform_action(act.CloseCurrentTab({ confirm = false }), pane)
			if value == "clear_all" then
				notifications = {}
				notified_tabs = {}
				notified_panes = {}
				pcall(save)
			else
				local idx = tonumber(value)
				if idx then
					local n = notifications[idx + 1]
					if n then
						local mux_win = window:mux_window()
						for i, tab in ipairs(mux_win:tabs()) do
							if tab:tab_id() == n.tab_id then
								local ap = tab:active_pane()
								window:perform_action(act.ActivateTab(i - 1), ap)
								for _, pi in ipairs(tab:panes_with_info()) do
									if pi.pane:pane_id() == n.pane_id then
										pi.pane:activate()
										break
									end
								end
								break
							end
						end
					end
				end
			end
		end
	end)

	if not config.keys then
		config.keys = {}
	end
	config.keys[#config.keys + 1] = {
		key = "phys:n",
		mods = opts.mods or "CTRL|SHIFT",
		action = M.show_notifications(),
	}
end

return M
