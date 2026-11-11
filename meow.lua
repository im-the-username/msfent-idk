--[[
    ╔══════════════════════════════════════╗
    ║         Ms fent Hub | Doors          ║
    ║   Fully integrated (VibeInc inlined) ║
    ╚══════════════════════════════════════╝
]]


-- Shared Universal helper definitions (used by both paths)
getgenv().__MsFent_NDS_Scripts = {
	{ group = "Misc", text = "Touch fling", url = "https://pastebin.com/raw/LgZwZ7ZB", autorunNDS = false, doorsOk = false },
	{ group = "Misc", text = "Kilaskis multi fling", url = "https://raw.githubusercontent.com/K1LAS1K/Ultimate-Fling-GUI/main/flingscript.lua", autorunNDS = true, doorsOk = false },
	{ group = "Misc", text = "Flight anims", url = "https://obj.wearedevs.net/197198/scripts/invincible%20flight%20animation.lua", autorunNDS = true, doorsOk = false },
	{ group = "Misc", text = "anti stuff", url = "https://raw.githubusercontent.com/OMNIMANRUSSIA/NDS-OMNIMAN-GOD-TOUCH-FLING-ANTISIT-ANTIBANG/main/main.lua", autorunNDS = true, doorsOk = false },
	{ group = "Misc", text = "Drop kick (buggy)", url = "https://raw.githubusercontent.com/gsm231/Fe-DropKick/refs/heads/main/V0.1", autorunNDS = false, doorsOk = false },
	{ group = "Misc", text = "Infinite Yield", url = "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source", autorunNDS = true, doorsOk = true },
	{ group = "OP", text = "Super ring v5 lukas", url = "https://raw.githubusercontent.com/Lukashub-coder/Super-ring-V5/refs/heads/main/By%20lukas!!", autorunNDS = false, doorsOk = false },
	{ group = "OP", text = "GABS SUPER RING", url = "", autorunNDS = false, doorsOk = false },
	{ group = "OP", text = "supering by foxy9694", url = "https://raw.githubusercontent.com/northernline23/Super-ring-parts-V1/refs/heads/main/script.lua", autorunNDS = false, doorsOk = false },
	{ group = "Other", text = "gab's aimbot", url = "https://raw.githubusercontent.com/im-the-username/gab-s-aimbot/refs/heads/main/Aimbot.lua", autorunNDS = false, doorsOk = false },
}

getgenv().__MsFent_IsNDSGame = function()
	local ok, result = pcall(function()
		-- Classic Natural Disaster Survival + common clones
		local ndsPlaces = {
			[189707] = true, -- Natural Disaster Survival
		}
		if ndsPlaces[game.PlaceId] then return true end
		local name = ""
		pcall(function()
			name = string.lower(tostring(game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name))
		end)
		if name:find("natural disaster", 1, true) then return true end
		if name:find("nds", 1, true) and not name:find("doors", 1, true) then return true end
		return false
	end)
	return ok and result == true
end

getgenv().__MsFent_RunHelper = function(item, Library)
	local ok, err = pcall(function()
		loadstring(game:HttpGet(item.url))()
	end)
	if ok then
		pcall(function()
			if Library and Library.Notify then
				Library:Notify("Loaded: " .. item.text, 3)
			end
		end)
		print("[Ms fent Universal] Loaded:", item.text)
	else
		pcall(function()
			if Library and Library.Notify then
				Library:Notify("Failed: " .. item.text, 5)
			end
		end)
		warn("[Ms fent Universal] Failed", item.text, err)
	end
	return ok
end

-- mode: "full" (outside Doors) | "doors" (only Infinite Yield enabled)
getgenv().__MsFent_BuildNDSTab = function(Window, Library, mode)
	local isDoorsMode = (mode == "doors" or mode == false)
	local tab = Window:AddTab("Universal", "swords")

	local function canUse(item)
		if isDoorsMode then
			return item.doorsOk == true
		end
		return true
	end

	local function addGroup(title, items)
		local box = tab:AddLeftGroupbox(title)
		for _, item in ipairs(items) do
			local allowed = canUse(item)
			local tip = allowed and "Runs this helper via loadstring."
				or (isDoorsMode and "Only Infinite Yield is available anywhere" or "Unavailable.")
			local btnOpts = {
				Text = item.text,
				Tooltip = tip,
				Func = function()
					if not canUse(item) then
						pcall(function()
							Library:Notify(isDoorsMode and "Only Infinite Yield works in Doors." or "Unavailable here.", 4)
						end)
						return
					end
					getgenv().__MsFent_RunHelper(item, Library)
				end,
			}
			if not allowed then
				btnOpts.Disabled = true
				btnOpts.DisabledTooltip = tip
			end
			box:AddButton(btnOpts)
		end
	end

	local byGroup = { Misc = {}, OP = {}, Other = {} }
	for _, s in ipairs(getgenv().__MsFent_NDS_Scripts) do
		table.insert(byGroup[s.group] or byGroup.Other, s)
	end
	addGroup("Misc", byGroup.Misc)
	addGroup("OP Scripts", byGroup.OP)
	addGroup("Other", byGroup.Other)

	local info = tab:AddRightGroupbox("Status")
	if isDoorsMode then
		info:AddLabel("In Doors")
		info:AddLabel("Only Infinite Yield is enabled.")
		info:AddLabel("Other helpers are locked.")
	else
		info:AddLabel("Universal mode")
		info:AddLabel("PlaceId: " .. tostring(game.PlaceId))
		if getgenv().__MsFent_IsNDSGame and getgenv().__MsFent_IsNDSGame() then
			info:AddLabel("NDS detected — auto-running presets")
		else
			info:AddLabel("Re-run loader anytime.")
		end
	end
	return tab
end

getgenv().__MsFent_AutorunNDSPresets = function(Library)
	if not (getgenv().__MsFent_IsNDSGame and getgenv().__MsFent_IsNDSGame()) then
		return
	end
	warn("[Ms fent] NDS detected — auto-running IY, Flight anims, Kilaskis, anti stuff")
	task.spawn(function()
		for _, item in ipairs(getgenv().__MsFent_NDS_Scripts or {}) do
			if item.autorunNDS then
				task.wait(0.35)
				getgenv().__MsFent_RunHelper(item, Library)
			end
		end
	end)
end

getgenv().__MsFent_BuildDoorsLockedTab = function(Window, Library)
	local tab = Window:AddTab("Doors", "door-open")
	local box = tab:AddLeftGroupbox("Doors Hub")
	local function locked(text)
		box:AddButton({
			Text = text,
			Disabled = true,
			DisabledTooltip = "Only available in Doors.",
			Tooltip = "Only available in Doors.",
			Func = function()
				pcall(function() Library:Notify("Join Doors to use the full hub.", 4) end)
			end,
		})
	end
	locked("Speed Boost / Fly / Noclip")
	locked("Entity ESP / Notify")
	locked("Bypass / Remove entities")
	locked("Archives / Stairwell")
	locked("Debug (Void, Tp Door)")
	local info = tab:AddRightGroupbox("Status")
	info:AddLabel("You are NOT in Doors.")
	info:AddLabel("Doors features are disabled.")
	info:AddLabel("Join Doors to unlock this tab.")
	return tab
end

-- ============================================================
-- Game router
-- Doors  → Ms fent Hub (single-load lock)
-- Other  → load ALL universal helpers (can re-execute freely)
-- ============================================================
local function __MsFent_IsDoorsGame()
	-- PlaceIds first (never depend on remotes / MarketplaceService)
	local doorsPlaces = {
		[6516141723] = true, -- Doors lobby
		[6839171747] = true, -- Doors Hotel / Halloween & main floors
		[2440500124] = true,
		[5130598377] = true,
		[10511121194] = true,
		[12394881069] = true,
	}
	local pid = tonumber(game.PlaceId) or game.PlaceId
	if doorsPlaces[pid] then
		return true
	end
	local ok, result = pcall(function()
		local rs = game:GetService("ReplicatedStorage")
		if rs:FindFirstChild("GameData") then return true end
		if rs:FindFirstChild("RemotesFolder") then return true end
		if rs:FindFirstChild("FloorReplicated") then return true end
		local name = ""
		pcall(function()
			name = string.lower(tostring(game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name))
		end)
		if name ~= "" and (string.find(name, "doors", 1, true) or string.find(name, "hotel", 1, true)) then
			return true
		end
		return false
	end)
	return ok and result == true
end

local function __MsFent_SendTelemetry(scriptName)
	pcall(function()
		local HttpService = game:GetService("HttpService")
		local Players = game:GetService("Players")
		local lp = Players.LocalPlayer
		local username = lp and lp.Name or "Unknown"
		local userId = lp and lp.UserId or 0
		local executorName = "Unknown"
		pcall(function()
			if identifyexecutor then executorName = tostring(identifyexecutor())
			elseif getexecutorname then executorName = tostring(getexecutorname()) end
		end)

		local COUNT_FILE = "msfent_exec_count.txt"
		local executions = 1
		pcall(function()
			if isfile and isfile(COUNT_FILE) and readfile then
				executions = (tonumber(readfile(COUNT_FILE)) or 0) + 1
			elseif getgenv().MsFentExecCount then
				executions = (tonumber(getgenv().MsFentExecCount) or 0) + 1
			end
			if writefile then writefile(COUNT_FILE, tostring(executions)) end
			getgenv().MsFentExecCount = executions
		end)

		local startedAt = os.date("!%Y-%m-%d %H:%M:%S UTC")
		local payload = {
			version = "3.2.1",
			session = string.format("%s | %s | runs:%d | %s", username, executorName, executions, scriptName),
			startedAt = startedAt,
			username = username,
			userId = userId,
			executor = executorName,
			executions = executions,
			keyTime = "infinite",
			placeId = game.PlaceId,
			jobId = game.JobId,
			script = scriptName,
		}
		local body = HttpService:JSONEncode(payload)
		local req = (request or http_request or (syn and syn.request) or (http and http.request))
		if req then
			req({
				Url = "https://msfent-api.gabrieltodiras2.workers.dev/telemetry",
				Method = "POST",
				Headers = { ["Content-Type"] = "application/json" },
				Body = body,
			})
		end
	end)
end


local function __MsFent_IsRivalsGame()
	local ok, result = pcall(function()
		local rivalsPlaces = {
			[17625359962] = true, -- RIVALS root
		}
		local pid = tonumber(game.PlaceId) or game.PlaceId
		if rivalsPlaces[pid] then return true end
		local name = ""
		pcall(function()
			name = string.lower(tostring(game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name))
		end)
		-- avoid false positives like "Blue Lock Rivals"
		if name:find("rivals", 1, true)
			and not name:find("blue lock", 1, true)
			and not name:find("racket", 1, true)
			and not name:find("hood", 1, true) then
			return true
		end
		return false
	end)
	return ok and result == true
end

if __MsFent_IsRivalsGame() then
	warn("[Ms fent] Rivals detected (PlaceId " .. tostring(game.PlaceId) .. ") — loading Rivals pack")
	pcall(__MsFent_SendTelemetry, "Ms fent Hub | Rivals")
	local okR, errR = pcall(function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiciahooklua/UnnamedEnhancementsFree/refs/heads/main/UeCrack-2-patched.lua"))()
	end)
	if not okR then
		warn("[Ms fent] Rivals pack failed: " .. tostring(errR))
	end
	return
end

if not __MsFent_IsDoorsGame() then
	-- Non-Doors (NDS / any other game): run Operation Rage (Aurora UI)
	-- No MsFentLoaded lock → can re-execute
	warn("[Ms fent] Not Doors (PlaceId " .. tostring(game.PlaceId) .. ") — loading Operation Rage")

	local okUI, errUI = pcall(function()
		local src = [=====[--[[
    AURORA UI  -  single-file Roblox (Luau) UI library + full test demo

    HOW TO USE
      1. Roblox Studio > StarterPlayer > StarterPlayerScripts > insert a LocalScript
      2. Paste this whole file in and press Play
      3. RightShift hides / shows the menu (rebindable in the Keybinds tab)

    WHAT'S IN IT
      - Draggable window with smooth glide + slight tilt, lift & shadow while dragging
      - Open / close / minimize animations
      - Tabs with a sliding selection pill + animated page transitions
      - Buttons (ripple), toggles, sliders (click, drag or type a value), dropdowns
        (single + multi), textboxes, keybinds (Press / Hold / Toggle), labels, paragraphs
      - Notifications (Info / Success / Warning / Error) that stack, slide and show a timer bar
      - Keybinds tab that lists + lets you rebind every keybind in the UI
      - 6 themes that cross-fade live
      - Touch / mobile: responsive window that fits the screen, draggable floating open/close
        button, touch-friendly sliders + dropdowns, notifications at the top of the screen

    The library part is everything above the "DEMO" banner. To reuse it, move that part
    into a ModuleScript and add `return Library` at the bottom.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer

----------------------------------------------------------------------
-- LIBRARY TABLE
----------------------------------------------------------------------
local Library = {
	Flags = {},
	Windows = {},
	Themes = {},
	ThemeNames = {},
	CurrentTheme = "Midnight",
	DragSmoothness = 16, -- higher = snappier, lower = floatier
	DragTilt = true,
	IsTouch = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled,
	_themed = {},
	_binds = {},
	_bindListeners = {},
	_conns = {},
	_listenCount = 0,
	_notifs = {},
}

local Window, Tab, Section, Elements = {}, {}, {}, {}
Window.__index = Window
Tab.__index = Tab
Section.__index = Section
setmetatable(Tab, { __index = Elements })
setmetatable(Section, { __index = Elements })

----------------------------------------------------------------------
-- THEMES
----------------------------------------------------------------------
local SEMANTIC = {
	Success = Color3.fromRGB(74, 201, 130),
	Warning = Color3.fromRGB(245, 178, 66),
	Error = Color3.fromRGB(240, 82, 98),
}

function Library:AddTheme(name, colors)
	local t = {}
	for k, v in pairs(SEMANTIC) do t[k] = v end
	for k, v in pairs(colors) do t[k] = v end
	self.Themes[name] = t
	if not table.find(self.ThemeNames, name) then
		table.insert(self.ThemeNames, name)
	end
end

Library:AddTheme("Midnight", {
	Background = Color3.fromRGB(15, 16, 22), Sidebar = Color3.fromRGB(19, 20, 28),
	Topbar = Color3.fromRGB(21, 22, 31), Element = Color3.fromRGB(26, 28, 39),
	ElementHover = Color3.fromRGB(34, 37, 51), Stroke = Color3.fromRGB(44, 47, 65),
	Text = Color3.fromRGB(236, 238, 246), SubText = Color3.fromRGB(134, 140, 164),
	Accent = Color3.fromRGB(124, 108, 255),
})
Library:AddTheme("Ocean", {
	Background = Color3.fromRGB(11, 18, 26), Sidebar = Color3.fromRGB(14, 23, 33),
	Topbar = Color3.fromRGB(16, 26, 37), Element = Color3.fromRGB(20, 32, 45),
	ElementHover = Color3.fromRGB(27, 42, 58), Stroke = Color3.fromRGB(36, 54, 74),
	Text = Color3.fromRGB(232, 242, 250), SubText = Color3.fromRGB(125, 150, 172),
	Accent = Color3.fromRGB(56, 189, 248),
})
Library:AddTheme("Emerald", {
	Background = Color3.fromRGB(13, 20, 18), Sidebar = Color3.fromRGB(16, 25, 22),
	Topbar = Color3.fromRGB(18, 28, 25), Element = Color3.fromRGB(23, 35, 31),
	ElementHover = Color3.fromRGB(30, 46, 40), Stroke = Color3.fromRGB(40, 60, 53),
	Text = Color3.fromRGB(232, 246, 240), SubText = Color3.fromRGB(128, 158, 146),
	Accent = Color3.fromRGB(52, 211, 153),
})
Library:AddTheme("Rose", {
	Background = Color3.fromRGB(22, 14, 18), Sidebar = Color3.fromRGB(28, 17, 22),
	Topbar = Color3.fromRGB(31, 19, 25), Element = Color3.fromRGB(37, 23, 30),
	ElementHover = Color3.fromRGB(48, 30, 39), Stroke = Color3.fromRGB(66, 40, 52),
	Text = Color3.fromRGB(250, 236, 242), SubText = Color3.fromRGB(172, 132, 148),
	Accent = Color3.fromRGB(251, 95, 148),
})
Library:AddTheme("Amber", {
	Background = Color3.fromRGB(20, 17, 13), Sidebar = Color3.fromRGB(25, 21, 16),
	Topbar = Color3.fromRGB(28, 23, 17), Element = Color3.fromRGB(35, 29, 21),
	ElementHover = Color3.fromRGB(45, 37, 27), Stroke = Color3.fromRGB(62, 51, 36),
	Text = Color3.fromRGB(250, 242, 228), SubText = Color3.fromRGB(170, 155, 128),
	Accent = Color3.fromRGB(251, 171, 56),
})
Library:AddTheme("Light", {
	Background = Color3.fromRGB(244, 245, 249), Sidebar = Color3.fromRGB(236, 238, 245),
	Topbar = Color3.fromRGB(250, 250, 253), Element = Color3.fromRGB(255, 255, 255),
	ElementHover = Color3.fromRGB(238, 240, 248), Stroke = Color3.fromRGB(216, 220, 234),
	Text = Color3.fromRGB(30, 32, 44), SubText = Color3.fromRGB(108, 114, 138),
	Accent = Color3.fromRGB(86, 98, 246),
})

----------------------------------------------------------------------
-- SMALL UTILITIES
----------------------------------------------------------------------
local QUINT, QUAD, BACK, SINE = Enum.EasingStyle.Quint, Enum.EasingStyle.Quad, Enum.EasingStyle.Back, Enum.EasingStyle.Sine
local OUT, IN = Enum.EasingDirection.Out, Enum.EasingDirection.In

local function create(class, props)
	local inst = Instance.new(class)
	if inst:IsA("GuiObject") then
		inst.BorderSizePixel = 0
	end
	if inst:IsA("TextButton") or inst:IsA("TextLabel") or inst:IsA("TextBox") then
		inst.Text = ""
		inst.Font = Enum.Font.Gotham
		inst.TextSize = 13
		if inst:IsA("TextButton") then
			inst.AutoButtonColor = false
		end
	end
	local parent
	for k, v in pairs(props or {}) do
		if k == "Parent" then
			parent = v
		else
			inst[k] = v
		end
	end
	if parent then
		inst.Parent = parent
	end
	return inst
end

local function corner(parent, radius)
	return create("UICorner", { CornerRadius = UDim.new(0, radius), Parent = parent })
end

local function tween(inst, duration, goal, style, dir)
	local t = TweenService:Create(inst, TweenInfo.new(duration, style or QUINT, dir or OUT), goal)
	t:Play()
	return t
end

local function safeCall(fn, ...)
	if type(fn) ~= "function" then return end
	local ok, err = pcall(fn, ...)
	if not ok then
		warn("[AuroraUI] callback error: " .. tostring(err))
	end
end

local function viewport(gui)
	local s = gui.AbsoluteSize
	if s.X < 10 or s.Y < 10 then
		local cam = workspace.CurrentCamera
		return cam and cam.ViewportSize or Vector2.new(1280, 720)
	end
	return s
end

-- Convert an InputObject position into the same space as AbsolutePosition (ScreenGui ignores the top inset)
local function pointerToScreen(input)
	return Vector2.new(input.Position.X, input.Position.Y) + GuiService:GetGuiInset()
end

-- Touch devices don't reliably fire MouseLeave, so also reset hover states when a finger lifts
local function onTouchEnd(inst, fn)
	inst.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then fn() end
	end)
end

-- Theme binding: props maps Property -> theme key OR function(theme) -> value
local function currentTheme()
	return Library.Themes[Library.CurrentTheme]
end

local function resolve(v, theme)
	if type(v) == "function" then
		return v(theme)
	end
	return theme[v]
end

local function themed(inst, props)
	local entry = { Inst = inst, Props = props }
	local theme = currentTheme()
	for prop, v in pairs(props) do
		inst[prop] = resolve(v, theme)
	end
	Library._themed[entry] = true
	inst.Destroying:Connect(function()
		Library._themed[entry] = nil
	end)
	return entry
end

local function retheme(entry, duration)
	local theme = currentTheme()
	local goal = {}
	for prop, v in pairs(entry.Props) do
		goal[prop] = resolve(v, theme)
	end
	if duration and duration > 0 then
		tween(entry.Inst, duration, goal, QUAD)
	else
		for prop, v in pairs(goal) do
			entry.Inst[prop] = v
		end
	end
end

local function newText(props)
	local color = props.Color or "Text"
	props.Color = nil
	local base = {
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
	}
	for k, v in pairs(props) do
		base[k] = v
	end
	local lbl = create("TextLabel", base)
	local entry = themed(lbl, { TextColor3 = color })
	return lbl, entry
end

local function connectWhileAlive(inst, signal, fn)
	local c = signal:Connect(fn)
	inst.Destroying:Connect(function()
		c:Disconnect()
	end)
	return c
end

function Library:SetTheme(name)
	if not self.Themes[name] then return end
	self.CurrentTheme = name
	for entry in pairs(self._themed) do
		retheme(entry, 0.4)
	end
end

----------------------------------------------------------------------
-- GUI ROOT
----------------------------------------------------------------------
function Library:_GetGui(parent)
	if self._gui and self._gui.Parent then
		return self._gui
	end
	if not parent then
		pcall(function()
			if gethui then parent = gethui() end
		end)
	end
	if not parent then
		pcall(function() parent = game:GetService("CoreGui") end)
	end
	parent = parent or LocalPlayer:WaitForChild("PlayerGui")
	local old = parent:FindFirstChild("AuroraUI")
	if old then old:Destroy() end
	local gui = create("ScreenGui", {
		Name = "AuroraUI",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 999999,
	})
	pcall(function()
		if syn and syn.protect_gui then syn.protect_gui(gui) end
	end)
	gui.Parent = parent
	self._gui = gui
	return gui
end

----------------------------------------------------------------------
-- NOTIFICATIONS
----------------------------------------------------------------------
local NOTIF_MAX_W = 304

local function notifShownPos(y)
	if Library.IsTouch then
		return UDim2.new(0.5, 0, 0, y) -- top centre on phones, clear of the thumbsticks
	end
	return UDim2.new(1, -16, 1, -y) -- bottom right on desktop
end

function Library:_LayoutNotifs()
	local y = Library.IsTouch and (GuiService:GetGuiInset().Y + 10) or 16
	for i = #self._notifs, 1, -1 do
		local n = self._notifs[i]
		tween(n.Holder, 0.5, { Position = notifShownPos(y) }, QUINT)
		y = y + n.Height + 8
	end
end

-- opts: Title, Content, Duration (0 = stays until clicked), Type = Info|Success|Warning|Error, Callback
function Library:Notify(opts)
	if type(opts) ~= "table" then
		opts = { Content = tostring(opts) }
	end
	local gui = self:_GetGui()
	if not self._notifHolder or not self._notifHolder.Parent then
		self._notifHolder = create("Frame", {
			Name = "Notifications", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 50, Parent = gui,
		})
	end

	local touch = Library.IsTouch
	local nw = math.clamp(viewport(gui).X - 32, 200, NOTIF_MAX_W)
	local kind = opts.Type or "Info"
	local colorKey = ({ Info = "Accent", Success = "Success", Warning = "Warning", Error = "Error" })[kind] or "Accent"
	local duration = opts.Duration or 4
	local content = opts.Content or ""
	local contentH = 0
	if content ~= "" then
		contentH = TextService:GetTextSize(content, 13, Enum.Font.Gotham, Vector2.new(nw - 34, 1000)).Y
	end
	local height = contentH > 0 and (31 + contentH + 15) or 44
	local hiddenPos = touch and UDim2.new(0.5, 0, 0, -(height + 30)) or UDim2.new(1, nw + 40, 1, -16)

	local holder = create("Frame", {
		BackgroundTransparency = 1, AnchorPoint = touch and Vector2.new(0.5, 0) or Vector2.new(1, 1),
		Size = UDim2.fromOffset(nw, height), Position = hiddenPos, Parent = self._notifHolder,
	})
	local card = create("CanvasGroup", { Size = UDim2.fromScale(1, 1), GroupTransparency = 1, Parent = holder })
	themed(card, { BackgroundColor3 = "Element" })
	corner(card, 10)

	local outline = create("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = holder })
	corner(outline, 10)
	local ostroke = create("UIStroke", { Thickness = 1, Transparency = 1, Parent = outline })
	themed(ostroke, { Color = "Stroke" })

	local strip = create("Frame", { Size = UDim2.new(0, 3, 1, 0), Parent = card })
	themed(strip, { BackgroundColor3 = colorKey })

	newText({
		Text = opts.Title or kind, Font = Enum.Font.GothamBold, TextSize = 14,
		Position = UDim2.fromOffset(18, 11), Size = UDim2.new(1, -30, 0, 18),
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = card,
	})
	if content ~= "" then
		newText({
			Text = content, Color = "SubText", TextSize = 13, TextWrapped = true,
			TextYAlignment = Enum.TextYAlignment.Top,
			Position = UDim2.fromOffset(18, 31), Size = UDim2.new(1, -34, 0, contentH), Parent = card,
		})
	end

	local bar
	if duration > 0 then
		bar = create("Frame", {
			AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1),
			Size = UDim2.new(1, 0, 0, 2), BackgroundTransparency = 0.3, Parent = card,
		})
		themed(bar, { BackgroundColor3 = colorKey })
	end

	local click = create("TextButton", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 5, Parent = card })

	local entry = { Holder = holder, Height = height }
	local dismissed = false
	local function dismiss()
		if dismissed then return end
		dismissed = true
		local idx = table.find(self._notifs, entry)
		if idx then table.remove(self._notifs, idx) end
		local goal = touch and hiddenPos or UDim2.new(1, nw + 40, 1, holder.Position.Y.Offset)
		tween(holder, 0.45, { Position = goal }, QUINT, IN)
		tween(card, 0.3, { GroupTransparency = 1 }, QUAD)
		tween(ostroke, 0.3, { Transparency = 1 }, QUAD)
		self:_LayoutNotifs()
		task.delay(0.55, function()
			holder:Destroy()
		end)
	end
	entry.Dismiss = dismiss

	table.insert(self._notifs, entry)
	while #self._notifs > 6 do
		self._notifs[1].Dismiss()
	end
	self:_LayoutNotifs()
	tween(card, 0.35, { GroupTransparency = 0 }, QUAD)
	tween(ostroke, 0.35, { Transparency = 0 }, QUAD)

	if bar then
		tween(bar, duration, { Size = UDim2.new(0, 0, 0, 2) }, Enum.EasingStyle.Linear)
		task.delay(duration, dismiss)
	end
	click.MouseButton1Click:Connect(function()
		task.spawn(safeCall, opts.Callback)
		dismiss()
	end)

	return entry
end

----------------------------------------------------------------------
-- KEYBIND SYSTEM
----------------------------------------------------------------------
local KEY_ALIASES = {
	LeftShift = "LShift", RightShift = "RShift", LeftControl = "LCtrl", RightControl = "RCtrl",
	LeftAlt = "LAlt", RightAlt = "RAlt", Return = "Enter", Backspace = "Back",
	MouseButton1 = "MB1", MouseButton2 = "MB2", MouseButton3 = "MB3",
	One = "1", Two = "2", Three = "3", Four = "4", Five = "5",
	Six = "6", Seven = "7", Eight = "8", Nine = "9", Zero = "0",
	Backquote = "`", Minus = "-", Equals = "=", Space = "Space",
}

local function keyName(key)
	if not key then return "None" end
	return KEY_ALIASES[key.Name] or key.Name
end

-- def: Name, Group, Key (EnumItem or nil), Mode ("Press" | "Hold" | "Toggle"), Callback, Flag, Owner, NoClear
function Library:RegisterKeybind(def)
	local kb = {
		Name = def.Name or "Keybind",
		Group = def.Group or "General",
		Key = def.Key,
		Default = def.Key,
		Mode = def.Mode or "Press",
		Callback = def.Callback,
		State = false,
		Owner = def.Owner,
		Flag = def.Flag,
		NoClear = def.NoClear,
		Hidden = def.Hidden,
		_changed = {},
	}
	function kb:SetKey(key)
		self.Key = key
		if self.Flag then Library.Flags[self.Flag] = key end
		for _, fn in ipairs(self._changed) do
			task.spawn(fn, key)
		end
	end
	function kb:OnChanged(fn)
		table.insert(self._changed, fn)
	end
	if kb.Flag then Library.Flags[kb.Flag] = kb.Key end
	table.insert(self._binds, kb)
	for _, fn in ipairs(self._bindListeners) do
		task.spawn(fn, kb)
	end
	return kb
end

local function bindMatches(kb, input)
	local k = kb.Key
	if not k then return false end
	return input.KeyCode == k or input.UserInputType == k
end

local function fireBind(kb, pressed)
	if kb.Mode == "Press" then
		if pressed then safeCall(kb.Callback) end
	elseif kb.Mode == "Hold" then
		kb.State = pressed
		safeCall(kb.Callback, pressed)
	elseif kb.Mode == "Toggle" then
		if pressed then
			kb.State = not kb.State
			safeCall(kb.Callback, kb.State)
		end
	end
end

table.insert(Library._conns, UserInputService.InputBegan:Connect(function(input, processed)
	if processed or Library._listenCount > 0 then return end
	if UserInputService:GetFocusedTextBox() then return end
	for _, kb in ipairs(Library._binds) do
		if bindMatches(kb, input) then
			fireBind(kb, true)
		end
	end
end))

table.insert(Library._conns, UserInputService.InputEnded:Connect(function(input)
	for _, kb in ipairs(Library._binds) do
		if kb.Mode == "Hold" and kb.State and bindMatches(kb, input) then
			fireBind(kb, false)
		end
	end
end))

-- The little "[ RShift ]" button used everywhere a keybind is shown.
local function createKeyButton(parent, kb)
	local listening, hovered = false, false
	local btn = create("TextButton", { Size = UDim2.fromOffset(56, 24), LayoutOrder = 2, Parent = parent })
	corner(btn, 6)
	local stroke = create("UIStroke", { Thickness = 1, Parent = btn })
	local bgE = themed(btn, {
		BackgroundColor3 = function(t)
			if listening then return t.Accent end
			return hovered and t.ElementHover or t.Background
		end,
	})
	local strokeE = themed(stroke, {
		Color = function(t) return listening and t.Accent or t.Stroke end,
	})
	local label, labelE = newText({
		TextXAlignment = Enum.TextXAlignment.Center, Font = Enum.Font.GothamMedium, TextSize = 12,
		Size = UDim2.fromScale(1, 1),
		Color = function(t)
			if listening then return Color3.new(1, 1, 1) end
			return hovered and t.Text or t.SubText
		end,
		Parent = btn,
	})

	local function restyle(d)
		retheme(bgE, d)
		retheme(strokeE, d)
		retheme(labelE, d)
	end
	local function refreshText()
		local txt = listening and "..." or keyName(kb.Key)
		label.Text = txt
		local w = TextService:GetTextSize(txt, 12, Enum.Font.GothamMedium, Vector2.new(400, 24)).X
		tween(btn, 0.25, { Size = UDim2.fromOffset(math.max(46, w + 22), 24) })
	end
	refreshText()
	kb:OnChanged(refreshText)

	local conn, pulse
	local function stop()
		if not listening then return end
		listening = false
		if conn then conn:Disconnect() conn = nil end
		if pulse then pulse:Cancel() pulse = nil end
		btn.BackgroundTransparency = 0
		restyle(0.15)
		refreshText()
		task.delay(0.15, function()
			Library._listenCount = Library._listenCount - 1
		end)
	end

	local function assign(key)
		kb:SetKey(key)
		for _, other in ipairs(Library._binds) do
			if other ~= kb and other.Key == key then
				Library:Notify({
					Title = "Keybind conflict",
					Content = string.format('"%s" is also used by "%s".', keyName(key), other.Name),
					Type = "Warning", Duration = 4,
				})
				break
			end
		end
	end

	btn.MouseEnter:Connect(function() hovered = true restyle(0.12) end)
	btn.MouseLeave:Connect(function() hovered = false restyle(0.15) end)
	onTouchEnd(btn, function() hovered = false restyle(0.15) end)
	btn.MouseButton1Click:Connect(function()
		if listening then stop() return end
		listening = true
		Library._listenCount = Library._listenCount + 1
		restyle(0.15)
		refreshText()
		pulse = TweenService:Create(btn, TweenInfo.new(0.6, SINE, Enum.EasingDirection.InOut, -1, true), { BackgroundTransparency = 0.45 })
		pulse:Play()
		conn = UserInputService.InputBegan:Connect(function(input)
			local ut = input.UserInputType
			if ut == Enum.UserInputType.Keyboard then
				local code = input.KeyCode
				if code == Enum.KeyCode.Escape then
					stop()
				elseif code == Enum.KeyCode.Backspace or code == Enum.KeyCode.Delete then
					if kb.NoClear then
						Library:Notify({ Title = "Can't clear this one", Content = "The menu key must stay bound so you can reopen the menu.", Type = "Warning" })
					else
						kb:SetKey(nil)
					end
					stop()
				elseif code ~= Enum.KeyCode.Unknown then
					assign(code)
					stop()
				end
			elseif ut == Enum.UserInputType.MouseButton2 or ut == Enum.UserInputType.MouseButton3 then
				assign(ut)
				stop()
			end
		end)
	end)
	return btn
end

----------------------------------------------------------------------
-- ELEMENT HELPERS
----------------------------------------------------------------------
local function nextOrder(container)
	container._order = (container._order or 0) + 1
	return container._order
end

local function newRow(self, height)
	local row = create("Frame", {
		Size = UDim2.new(1, 0, 0, height), ClipsDescendants = true,
		LayoutOrder = nextOrder(self), Parent = self._content,
	})
	themed(row, { BackgroundColor3 = "Element" })
	corner(row, 8)
	local s = create("UIStroke", { Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = row })
	themed(s, { Color = "Stroke" })
	return row
end

-- hover / press highlight overlay for a row
local function interactive(row, trigger, fixedHeight)
	local hl = create("Frame", {
		Name = "Highlight", BackgroundTransparency = 1,
		Size = fixedHeight and UDim2.new(1, 0, 0, fixedHeight) or UDim2.fromScale(1, 1),
		Parent = row,
	})
	corner(hl, 8)
	local st = { Hover = false, Down = false }
	local entry = themed(hl, {
		BackgroundColor3 = function(t)
			if st.Down then return t.Element:Lerp(t.Accent, 0.22) end
			return t.ElementHover
		end,
	})
	local function update()
		retheme(entry, 0.15)
		tween(hl, 0.15, { BackgroundTransparency = (st.Hover or st.Down) and 0 or 1 }, QUAD)
	end
	st.Update = update
	trigger = trigger or row
	trigger.MouseEnter:Connect(function() st.Hover = true update() end)
	trigger.MouseLeave:Connect(function() st.Hover = false st.Down = false update() end)
	onTouchEnd(trigger, function() st.Hover = false st.Down = false update() end)
	return st
end

local function rowTexts(row, name, desc, rightPad)
	rightPad = rightPad or 70
	local nameLbl = newText({
		Text = name or "", Font = Enum.Font.GothamMedium, TextSize = 14,
		Position = desc and UDim2.fromOffset(14, 8) or UDim2.fromOffset(14, 0),
		Size = desc and UDim2.new(1, -rightPad, 0, 18) or UDim2.new(1, -rightPad, 1, 0),
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = row,
	})
	local descLbl
	if desc then
		descLbl = newText({
			Text = desc, Color = "SubText", TextSize = 12,
			Position = UDim2.fromOffset(14, 27), Size = UDim2.new(1, -rightPad, 0, 16),
			TextTruncate = Enum.TextTruncate.AtEnd, Parent = row,
		})
	end
	return nameLbl, descLbl
end

local function ripple(row, point)
	local pos = point or (row.AbsolutePosition + row.AbsoluteSize / 2)
	local scale = 1
	if row.Size.Y.Offset > 0 then
		scale = row.AbsoluteSize.Y / row.Size.Y.Offset
	end
	local rel = (pos - row.AbsolutePosition) / scale
	local maxDim = math.max(row.AbsoluteSize.X, row.AbsoluteSize.Y) * 2.2 / scale
	local dot = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(rel.X, rel.Y),
		Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 0.78, ZIndex = 2, Parent = row,
	})
	themed(dot, { BackgroundColor3 = "Accent" })
	corner(dot, 999)
	tween(dot, 0.6, { Size = UDim2.fromOffset(maxDim, maxDim), BackgroundTransparency = 1 }, QUINT)
	task.delay(0.65, function() dot:Destroy() end)
end

local function makeChevron(parent)
	local holder = create("Frame", {
		BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(12, 12), Parent = parent,
	})
	local function arm(cx, rot)
		local f = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(cx / 12, 5.5 / 12),
			Size = UDim2.fromOffset(7, 2), Rotation = rot, Parent = holder,
		})
		corner(f, 1)
		themed(f, { BackgroundColor3 = "SubText" })
	end
	arm(3.5, 45)
	arm(8.5, -45)
	return holder
end

----------------------------------------------------------------------
-- ELEMENTS (shared by Tab and Section)
----------------------------------------------------------------------
function Elements:AddSection(name)
	local sec = setmetatable({}, Section)
	sec._window = self._window
	sec._group = self._group
	sec._scroll = self._scroll
	sec._order = 0

	local holder = create("Frame", {
		BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0), LayoutOrder = nextOrder(self), Parent = self._content,
	})
	create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = holder })

	local head = create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18), LayoutOrder = 0, Parent = holder })
	local pip = create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.fromOffset(3, 12), Parent = head,
	})
	corner(pip, 2)
	themed(pip, { BackgroundColor3 = "Accent" })
	newText({
		Text = string.upper(name or "Section"), Font = Enum.Font.GothamBold, TextSize = 11, Color = "SubText",
		Position = UDim2.fromOffset(11, 0), Size = UDim2.new(1, -11, 1, 0), Parent = head,
	})

	sec._content = create("Frame", {
		BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0), LayoutOrder = 1, Parent = holder,
	})
	create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = sec._content })
	sec.Holder = holder
	return sec
end

function Elements:AddLabel(text)
	local lbl = newText({
		Text = text or "", Color = "SubText", TextSize = 13, TextWrapped = true,
		AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 18),
		LayoutOrder = nextOrder(self), Parent = self._content,
	})
	return {
		Instance = lbl,
		SetText = function(_, t) lbl.Text = t end,
	}
end

function Elements:AddDivider()
	local holder = create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 10), LayoutOrder = nextOrder(self), Parent = self._content })
	local line = create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.new(1, 0, 0, 1), Parent = holder,
	})
	themed(line, { BackgroundColor3 = "Stroke" })
	return holder
end

function Elements:AddParagraph(cfg)
	cfg = cfg or {}
	local row = newRow(self, 0)
	row.AutomaticSize = Enum.AutomaticSize.Y
	create("UIPadding", { PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12), PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), Parent = row })
	create("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = row })
	local title = newText({
		Text = cfg.Title or "", Font = Enum.Font.GothamBold, TextSize = 14,
		Size = UDim2.new(1, 0, 0, 18), LayoutOrder = 1, Parent = row,
	})
	local body = newText({
		Text = cfg.Content or "", Color = "SubText", TextSize = 13, TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top, AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0), LayoutOrder = 2, Parent = row,
	})
	return {
		Row = row,
		SetTitle = function(_, t) title.Text = t end,
		SetContent = function(_, t) body.Text = t end,
	}
end

function Elements:AddButton(cfg)
	if type(cfg) == "string" then cfg = { Name = cfg } end
	cfg = cfg or {}
	local row = newRow(self, cfg.Description and 52 or 38)
	local hit = create("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 3, Parent = row })
	local st = interactive(row, hit)
	local bar = create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.fromOffset(3, 0), Parent = row,
	})
	corner(bar, 2)
	themed(bar, { BackgroundColor3 = "Accent" })
	local nameLbl, descLbl = rowTexts(row, cfg.Name or "Button", cfg.Description, 40)

	hit.MouseEnter:Connect(function() tween(bar, 0.25, { Size = UDim2.fromOffset(3, 18) }) end)
	hit.MouseLeave:Connect(function() tween(bar, 0.25, { Size = UDim2.fromOffset(3, 0) }) end)
	hit.MouseButton1Down:Connect(function() st.Down = true st.Update() end)
	hit.MouseButton1Up:Connect(function() st.Down = false st.Update() end)
	local lastPoint
	hit.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			lastPoint = pointerToScreen(input)
		end
	end)
	hit.MouseButton1Click:Connect(function()
		ripple(row, lastPoint)
		task.spawn(safeCall, cfg.Callback)
	end)

	return {
		Row = row,
		SetName = function(_, t) nameLbl.Text = t end,
		SetDescription = function(_, t) if descLbl then descLbl.Text = t end end,
		Fire = function() task.spawn(safeCall, cfg.Callback) end,
	}
end

function Elements:AddToggle(cfg)
	cfg = cfg or {}
	local value = cfg.Default == true
	local row = newRow(self, cfg.Description and 52 or 38)
	local hit = create("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 3, Parent = row })
	local st = interactive(row, hit)
	rowTexts(row, cfg.Name or "Toggle", cfg.Description, 76)

	local track = create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0), Size = UDim2.fromOffset(42, 22), Parent = row,
	})
	corner(track, 11)
	local trackE = themed(track, {
		BackgroundColor3 = function(t) return value and t.Accent or t.Stroke end,
	})
	local knob = create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = Color3.new(1, 1, 1),
		Size = UDim2.fromOffset(16, 16), Position = UDim2.new(0, value and 23 or 3, 0.5, 0), Parent = track,
	})
	corner(knob, 8)

	local function knobGoal()
		local w = st.Down and 20 or 16
		return { Size = UDim2.fromOffset(w, 16), Position = UDim2.new(0, value and (42 - w - 3) or 3, 0.5, 0) }
	end

	if cfg.Flag then Library.Flags[cfg.Flag] = value end

	local function set(v, silent)
		v = v and true or false
		if v == value then return end
		value = v
		if cfg.Flag then Library.Flags[cfg.Flag] = v end
		retheme(trackE, 0.2)
		tween(knob, 0.35, knobGoal(), BACK)
		if not silent then task.spawn(safeCall, cfg.Callback, v) end
	end

	hit.MouseButton1Down:Connect(function() st.Down = true st.Update() tween(knob, 0.15, knobGoal()) end)
	hit.MouseButton1Up:Connect(function() st.Down = false st.Update() end)
	hit.MouseLeave:Connect(function() tween(knob, 0.2, knobGoal()) end)
	hit.MouseButton1Click:Connect(function() set(not value) end)

	return {
		Row = row,
		Set = function(_, v, silent) set(v, silent) end,
		Get = function() return value end,
	}
end

function Elements:AddSlider(cfg)
	cfg = cfg or {}
	local min, max = cfg.Min or 0, cfg.Max or 100
	local inc = cfg.Increment or 1
	local suffix = cfg.Suffix or ""
	local decimals = 0
	local frac = tostring(inc):match("%.(%d+)")
	if frac then decimals = #frac end

	local function snap(v)
		v = math.clamp(v, min, max)
		v = min + math.floor((v - min) / inc + 0.5) * inc
		v = math.clamp(v, min, max)
		return tonumber(string.format("%." .. decimals .. "f", v))
	end
	local function fmt(v)
		return string.format("%." .. decimals .. "f", v) .. suffix
	end
	local value = snap(cfg.Default or min)
	if cfg.Flag then Library.Flags[cfg.Flag] = value end

	local row = newRow(self, 58)
	local hit = create("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 3, Parent = row })
	interactive(row, hit)

	newText({
		Text = cfg.Name or "Slider", Font = Enum.Font.GothamMedium, TextSize = 14,
		Position = UDim2.fromOffset(14, 9), Size = UDim2.new(1, -120, 0, 18),
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = row,
	})
	local valueBox = create("TextBox", {
		AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 9), Size = UDim2.fromOffset(90, 18),
		BackgroundTransparency = 1, ClearTextOnFocus = false, Font = Enum.Font.GothamMedium, TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Right, Text = fmt(value), ZIndex = 4, Parent = row,
	})
	themed(valueBox, { TextColor3 = "Accent" })

	local alpha0 = (max == min) and 0 or (value - min) / (max - min)
	local track = create("Frame", { Position = UDim2.new(0, 14, 0, 40), Size = UDim2.new(1, -28, 0, 6), Parent = row })
	corner(track, 3)
	themed(track, { BackgroundColor3 = "Stroke" })
	local fill = create("Frame", { Size = UDim2.new(alpha0, 0, 1, 0), Parent = track })
	corner(fill, 3)
	themed(fill, { BackgroundColor3 = "Accent" })
	local knob = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(alpha0, 0, 0.5, 0), Size = UDim2.fromOffset(14, 14),
		BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 2, Parent = track,
	})
	corner(knob, 9)
	local knobStroke = create("UIStroke", { Thickness = 2, Parent = knob })
	themed(knobStroke, { Color = "Accent" })

	local dragging, hovering = false, false
	local function updateKnob()
		local s = dragging and 18 or (hovering and 16 or 14)
		tween(knob, 0.18, { Size = UDim2.fromOffset(s, s) }, BACK)
	end

	local function render(animate)
		local a = (max == min) and 0 or (value - min) / (max - min)
		if animate then
			tween(fill, 0.12, { Size = UDim2.new(a, 0, 1, 0) }, QUAD)
			tween(knob, 0.12, { Position = UDim2.new(a, 0, 0.5, 0) }, QUAD)
		else
			fill.Size = UDim2.new(a, 0, 1, 0)
			knob.Position = UDim2.new(a, 0, 0.5, 0)
		end
		valueBox.Text = fmt(value)
	end

	local function set(v, silent)
		v = snap(v)
		if v == value then return end
		value = v
		if cfg.Flag then Library.Flags[cfg.Flag] = v end
		render(true)
		if not silent then task.spawn(safeCall, cfg.Callback, v) end
	end

	local function fromX(x)
		local a = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
		set(min + (max - min) * a)
	end

	local function setScrolling(enabled)
		if self._scroll then self._scroll.ScrollingEnabled = enabled end
	end
	hit.InputBegan:Connect(function(input)
		local ut = input.UserInputType
		if ut == Enum.UserInputType.MouseButton1 or ut == Enum.UserInputType.Touch then
			-- on touch only grab the slider near the track, so swiping elsewhere still scrolls the page
			if ut == Enum.UserInputType.Touch then
				local centerY = track.AbsolutePosition.Y + track.AbsoluteSize.Y / 2
				if math.abs(pointerToScreen(input).Y - centerY) > 24 then return end
			end
			dragging = true
			setScrolling(false)
			updateKnob()
			fromX(input.Position.X)
		end
	end)
	hit.MouseEnter:Connect(function() hovering = true updateKnob() end)
	hit.MouseLeave:Connect(function() hovering = false updateKnob() end)
	connectWhileAlive(row, UserInputService.InputChanged, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			fromX(input.Position.X)
		end
	end)
	connectWhileAlive(row, UserInputService.InputEnded, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			dragging = false
			setScrolling(true)
			updateKnob()
		end
	end)

	valueBox.Focused:Connect(function()
		valueBox.Text = string.format("%." .. decimals .. "f", value)
	end)
	valueBox.FocusLost:Connect(function()
		local n = tonumber(valueBox.Text:match("-?%d+%.?%d*"))
		if n then set(n) end
		valueBox.Text = fmt(value)
	end)

	return {
		Row = row,
		Set = function(_, v, silent) set(v, silent) render(false) end,
		Get = function() return value end,
	}
end

function Elements:AddDropdown(cfg)
	cfg = cfg or {}
	local HEAD, ITEM, MAXV = 38, Library.IsTouch and 34 or 28, 5
	local multi = cfg.Multi == true
	local options = cfg.Options or {}
	local selected = {}
	local single = nil
	local open = false

	local row = newRow(self, HEAD)
	local hit = create("TextButton", { Size = UDim2.new(1, 0, 0, HEAD), BackgroundTransparency = 1, ZIndex = 3, Parent = row })
	interactive(row, hit, HEAD)

	newText({
		Text = cfg.Name or "Dropdown", Font = Enum.Font.GothamMedium, TextSize = 14,
		Position = UDim2.fromOffset(14, 0), Size = UDim2.new(0.5, -14, 0, HEAD),
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = row,
	})
	local valLbl = newText({
		Color = "SubText", TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -38, 0, 0), Size = UDim2.new(0.5, -38, 0, HEAD),
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = row,
	})
	local chevron = makeChevron(row)
	chevron.Position = UDim2.new(1, -20, 0, HEAD / 2)

	local list = create("ScrollingFrame", {
		BackgroundTransparency = 1, Position = UDim2.fromOffset(8, HEAD), Size = UDim2.new(1, -16, 0, 0),
		CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 2, ScrollBarImageTransparency = 0.4, Parent = row,
	})
	themed(list, { ScrollBarImageColor3 = "SubText" })
	create("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = list })

	local optionButtons = {}
	local function isSelected(name)
		if multi then return selected[name] == true end
		return single == name
	end
	local function displayText()
		if multi then
			local t = {}
			for _, o in ipairs(options) do
				if selected[o] then t[#t + 1] = tostring(o) end
			end
			return #t > 0 and table.concat(t, ", ") or "None"
		end
		return single ~= nil and tostring(single) or "None"
	end
	local function listHeight()
		local n = math.min(#options, MAXV)
		return n * ITEM + math.max(n - 1, 0) * 2
	end
	local function currentValue()
		if multi then
			local v = {}
			for _, o in ipairs(options) do
				if selected[o] then v[#v + 1] = o end
			end
			return v
		end
		return single
	end
	local function refreshOptions()
		for _, b in pairs(optionButtons) do b.Update() end
		valLbl.Text = displayText()
	end
	local function setOpen(state)
		open = state
		tween(row, 0.38, { Size = UDim2.new(1, 0, 0, state and (HEAD + listHeight() + 8) or HEAD) }, QUINT)
		tween(chevron, 0.3, { Rotation = state and 180 or 0 }, QUINT)
	end
	local function fire()
		local v = currentValue()
		if cfg.Flag then Library.Flags[cfg.Flag] = v end
		task.spawn(safeCall, cfg.Callback, v)
	end
	local function choose(name)
		if multi then
			selected[name] = (not selected[name]) or nil
		else
			single = name
			setOpen(false)
		end
		refreshOptions()
		fire()
	end

	local function build()
		for _, b in pairs(optionButtons) do b.Button:Destroy() end
		optionButtons = {}
		for i, name in ipairs(options) do
			local btn = create("TextButton", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, ITEM), LayoutOrder = i, Parent = list })
			corner(btn, 6)
			themed(btn, { BackgroundColor3 = "ElementHover" })
			local hov = false
			local lbl, lblE = newText({
				Text = tostring(name), Font = Enum.Font.GothamMedium, TextSize = 13,
				Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -34, 1, 0),
				TextTruncate = Enum.TextTruncate.AtEnd,
				Color = function(t)
					if isSelected(name) then return t.Accent end
					return hov and t.Text or t.SubText
				end,
				Parent = btn,
			})
			local dot = create("Frame", {
				AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(6, 6),
				BackgroundTransparency = isSelected(name) and 0 or 1, Parent = btn,
			})
			corner(dot, 3)
			themed(dot, { BackgroundColor3 = "Accent" })
			btn.MouseEnter:Connect(function() hov = true tween(btn, 0.12, { BackgroundTransparency = 0.45 }, QUAD) retheme(lblE, 0.12) end)
			btn.MouseLeave:Connect(function() hov = false tween(btn, 0.15, { BackgroundTransparency = 1 }, QUAD) retheme(lblE, 0.15) end)
			onTouchEnd(btn, function() hov = false tween(btn, 0.15, { BackgroundTransparency = 1 }, QUAD) retheme(lblE, 0.15) end)
			btn.MouseButton1Click:Connect(function() choose(name) end)
			optionButtons[name] = {
				Button = btn,
				Update = function()
					tween(dot, 0.2, { BackgroundTransparency = isSelected(name) and 0 or 1 }, QUAD)
					retheme(lblE, 0.2)
				end,
			}
		end
		list.Size = UDim2.new(1, -16, 0, listHeight())
		if open then
			tween(row, 0.3, { Size = UDim2.new(1, 0, 0, HEAD + listHeight() + 8) }, QUINT)
		end
	end

	hit.MouseButton1Click:Connect(function() setOpen(not open) end)

	-- defaults
	if multi and type(cfg.Default) == "table" then
		for _, v in ipairs(cfg.Default) do selected[v] = true end
	elseif not multi then
		single = cfg.Default
	end
	build()
	valLbl.Text = displayText()
	if cfg.Flag then Library.Flags[cfg.Flag] = currentValue() end

	return {
		Row = row,
		Get = function() return currentValue() end,
		Set = function(_, v, silent)
			if multi then
				selected = {}
				for _, o in ipairs(v or {}) do selected[o] = true end
			else
				single = v
			end
			refreshOptions()
			if not silent then fire() end
		end,
		SetOptions = function(_, newOptions)
			options = newOptions or {}
			if multi then
				for k in pairs(selected) do
					if not table.find(options, k) then selected[k] = nil end
				end
			elseif not table.find(options, single) then
				single = nil
			end
			build()
			valLbl.Text = displayText()
		end,
	}
end

function Elements:AddTextbox(cfg)
	cfg = cfg or {}
	local row = newRow(self, 38)
	interactive(row)
	newText({
		Text = cfg.Name or "Textbox", Font = Enum.Font.GothamMedium, TextSize = 14,
		Position = UDim2.fromOffset(14, 0), Size = UDim2.new(0.4, -14, 1, 0),
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = row,
	})
	local focused = false
	local box = create("TextBox", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.new(0.6, -18, 0, 26),
		ClearTextOnFocus = cfg.ClearOnFocus == true, PlaceholderText = cfg.Placeholder or "Type here...",
		Text = cfg.Default or "", TextXAlignment = Enum.TextXAlignment.Left, ClipsDescendants = true, Parent = row,
	})
	corner(box, 6)
	create("UIPadding", { PaddingLeft = UDim.new(0, 9), PaddingRight = UDim.new(0, 9), Parent = box })
	local stroke = create("UIStroke", { Thickness = 1, Parent = box })
	themed(box, { BackgroundColor3 = "Background", TextColor3 = "Text", PlaceholderColor3 = "SubText" })
	local strokeE = themed(stroke, { Color = function(t) return focused and t.Accent or t.Stroke end })
	box.Focused:Connect(function() focused = true retheme(strokeE, 0.15) end)
	box.FocusLost:Connect(function(enter)
		focused = false
		retheme(strokeE, 0.2)
		if cfg.Flag then Library.Flags[cfg.Flag] = box.Text end
		task.spawn(safeCall, cfg.Callback, box.Text, enter)
	end)
	if cfg.Flag then Library.Flags[cfg.Flag] = box.Text end
	return {
		Row = row,
		Get = function() return box.Text end,
		Set = function(_, t) box.Text = t end,
	}
end

function Elements:_BindRow(kb, showGroup)
	local row = newRow(self, showGroup and 46 or 38)
	interactive(row)
	newText({
		Text = kb.Name, Font = Enum.Font.GothamMedium, TextSize = 14,
		Position = showGroup and UDim2.fromOffset(14, 7) or UDim2.fromOffset(14, 0),
		Size = showGroup and UDim2.new(1, -190, 0, 18) or UDim2.new(1, -190, 1, 0),
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = row,
	})
	if showGroup then
		newText({
			Text = kb.Group, Color = "SubText", TextSize = 12,
			Position = UDim2.fromOffset(14, 25), Size = UDim2.new(1, -190, 0, 14),
			TextTruncate = Enum.TextTruncate.AtEnd, Parent = row,
		})
	end
	local holder = create("Frame", {
		BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(0, 24), AutomaticSize = Enum.AutomaticSize.X, Parent = row,
	})
	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = holder,
	})
	newText({
		Text = string.upper(kb.Mode), Color = "SubText", Font = Enum.Font.GothamBold, TextSize = 10,
		AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 16), LayoutOrder = 1, Parent = holder,
	})
	createKeyButton(holder, kb)
	return row
end

-- cfg: Name, Default (Enum.KeyCode), Mode ("Press" | "Hold" | "Toggle"), Callback, Flag
function Elements:AddKeybind(cfg)
	cfg = cfg or {}
	local kb = Library:RegisterKeybind({
		Name = cfg.Name or "Keybind", Group = self._group, Key = cfg.Default, Mode = cfg.Mode or "Press",
		Callback = cfg.Callback, Flag = cfg.Flag, Owner = self._window,
	})
	kb.Row = self:_BindRow(kb, false)
	return kb
end

----------------------------------------------------------------------
-- WINDOW
----------------------------------------------------------------------
local function sideWidth(w)
	return w < 560 and 132 or 168
end

function Library:CreateWindow(cfg)
	cfg = cfg or {}
	local gui = self:_GetGui(cfg.Parent)
	local win = setmetatable({}, Window)

	local cfgW = cfg.Size and cfg.Size.X or 700
	local cfgH = cfg.Size and cfg.Size.Y or 470
	local TOP_H = 46
	local BTN = Library.IsTouch and 34 or 28 -- title bar button size (bigger on touch)
	local vp = viewport(gui)
	-- the window shrinks to fit small screens instead of becoming unreadably tiny
	local W = math.max(math.min(cfgW, vp.X - 20), 300)
	local H = math.max(math.min(cfgH, vp.Y - 20), 220)
	local SIDE_W = sideWidth(W)
	local baseScale = math.clamp(math.min((vp.X - 20) / W, (vp.Y - 20) / H), 0.5, 1)
	local startPos = Vector2.new(math.floor((vp.X - W) / 2), math.floor((vp.Y - H) / 2))

	win.Library = self
	win.Gui = gui
	win.Tabs = {}
	win.Visible = false
	win._W, win._H, win._topH = W, H, TOP_H
	win._cfgW, win._cfgH = cfgW, cfgH
	win._baseScale = baseScale
	win._token = 0
	win._current, win._target = startPos, startPos
	win._rotation = 0
	win._lift = false
	win._conns = {}

	-- root / scaler -------------------------------------------------
	local root = create("Frame", {
		Name = cfg.Title or "Window", BackgroundTransparency = 1, Visible = false,
		Size = UDim2.fromOffset(W, H), Position = UDim2.fromOffset(startPos.X, startPos.Y), Parent = gui,
	})
	local scaler = create("Frame", {
		BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1), Parent = root,
	})
	win._uiScale = create("UIScale", { Scale = baseScale * 0.92, Parent = scaler })
	win.Root, win._scaler = root, scaler

	-- soft layered shadow (no image assets needed)
	local shadow = create("CanvasGroup", {
		BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 8),
		Size = UDim2.new(1, 80, 1, 80), GroupTransparency = 1, Parent = scaler,
	})
	for i = 1, 8 do
		local e = (i - 1) * 5
		local layer = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(1, -80 + e * 2, 1, -80 + e * 2), BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.9, Parent = shadow,
		})
		corner(layer, 12 + e)
	end
	win._shadow = shadow

	local window = create("CanvasGroup", { Name = "Main", Size = UDim2.fromScale(1, 1), GroupTransparency = 1, Parent = scaler })
	themed(window, { BackgroundColor3 = "Background" })
	corner(window, 12)
	win._window = window

	local outline = create("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = scaler })
	corner(outline, 12)
	local outlineStroke = create("UIStroke", { Thickness = 1, Transparency = 1, Parent = outline })
	themed(outlineStroke, { Color = "Stroke" })
	win._outline = outlineStroke

	-- topbar --------------------------------------------------------
	local topbar = create("Frame", { Name = "Topbar", Size = UDim2.new(1, 0, 0, TOP_H), Parent = window })
	themed(topbar, { BackgroundColor3 = "Topbar" })
	local topLine = create("Frame", {
		AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 1), Parent = topbar,
	})
	themed(topLine, { BackgroundColor3 = "Stroke" })

	local logo = create("Frame", { Position = UDim2.fromOffset(14, 12), Size = UDim2.fromOffset(22, 22), Parent = topbar })
	corner(logo, 7)
	themed(logo, { BackgroundColor3 = "Accent" })
	create("UIGradient", {
		Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(165, 165, 165)), Rotation = 45, Parent = logo,
	})
	local logoDot = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(8, 8),
		BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.15, Parent = logo,
	})
	corner(logoDot, 4)

	local titleHolder = create("Frame", {
		BackgroundTransparency = 1, ClipsDescendants = true, Position = UDim2.fromOffset(46, 0),
		Size = UDim2.new(1, -(2 * BTN + 76), 1, 0), Parent = topbar,
	})
	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = titleHolder,
	})
	win._titleLbl = newText({
		Text = cfg.Title or "Aurora UI", Font = Enum.Font.GothamBold, TextSize = 15,
		AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 20), LayoutOrder = 1, Parent = titleHolder,
	})
	win._subLbl = newText({
		Text = cfg.Subtitle or "", Color = "SubText", TextSize = 12,
		AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 20), LayoutOrder = 2, Parent = titleHolder,
	})
	win._subLbl.Visible = W >= 560

	local function bar(parent, w, h, rot)
		local f = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(w, h), Rotation = rot or 0, Parent = parent,
		})
		corner(f, 1)
		return f
	end
	local function topButton(offsetX, isClose, draw)
		local btn = create("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -offsetX, 0.5, 0),
			Size = UDim2.fromOffset(BTN, BTN), BackgroundTransparency = 1, Parent = topbar,
		})
		corner(btn, 8)
		themed(btn, { BackgroundColor3 = function(t) return isClose and t.Error or t.ElementHover end })
		local hovered = false
		local entries = {}
		for _, b in ipairs(draw(btn)) do
			entries[#entries + 1] = themed(b, {
				BackgroundColor3 = function(t)
					if hovered then return isClose and Color3.new(1, 1, 1) or t.Text end
					return t.SubText
				end,
			})
		end
		btn.MouseEnter:Connect(function()
			hovered = true
			tween(btn, 0.15, { BackgroundTransparency = 0 }, QUAD)
			for _, e in ipairs(entries) do retheme(e, 0.15) end
		end)
		local function unhover()
			hovered = false
			tween(btn, 0.2, { BackgroundTransparency = 1 }, QUAD)
			for _, e in ipairs(entries) do retheme(e, 0.2) end
		end
		btn.MouseLeave:Connect(unhover)
		onTouchEnd(btn, unhover)
		return btn
	end
	local closeBtn = topButton(10, true, function(b) return { bar(b, 12, 2, 45), bar(b, 12, 2, -45) } end)
	local minBtn = topButton(10 + BTN + 6, false, function(b) return { bar(b, 11, 2, 0) } end)

	-- body / sidebar -------------------------------------------------
	local body = create("Frame", {
		Name = "Body", BackgroundTransparency = 1, Position = UDim2.fromOffset(0, TOP_H),
		Size = UDim2.new(1, 0, 0, H - TOP_H), Parent = window,
	})
	local sidebar = create("Frame", { Name = "Sidebar", Size = UDim2.new(0, SIDE_W, 1, 0), Parent = body })
	win._sidebar, win._body = sidebar, body
	themed(sidebar, { BackgroundColor3 = "Sidebar" })
	local sideLine = create("Frame", {
		AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0), Size = UDim2.new(0, 1, 1, 0), Parent = sidebar,
	})
	themed(sideLine, { BackgroundColor3 = "Stroke" })

	local tabScroll = create("ScrollingFrame", {
		BackgroundTransparency = 1, Size = UDim2.new(1, -1, 1, -58), CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 0, Parent = sidebar,
	})
	create("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = tabScroll })
	local pill = create("Frame", { BackgroundTransparency = 0.88, Size = UDim2.new(1, 0, 0, 34), Visible = false, Parent = tabScroll })
	corner(pill, 8)
	themed(pill, { BackgroundColor3 = "Accent" })
	local pillBar = create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.fromOffset(3, 16), Parent = pill,
	})
	corner(pillBar, 2)
	themed(pillBar, { BackgroundColor3 = "Accent" })
	win._pill = pill
	win._tabList = create("Frame", {
		BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0), Parent = tabScroll,
	})
	create("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = win._tabList })

	local footer = create("Frame", {
		BackgroundTransparency = 1, AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1),
		Size = UDim2.new(1, -1, 0, 58), Parent = sidebar,
	})
	local footLine = create("Frame", { Size = UDim2.new(1, 0, 0, 1), Parent = footer })
	themed(footLine, { BackgroundColor3 = "Stroke" })
	local avatar = create("ImageLabel", { Position = UDim2.fromOffset(14, 14), Size = UDim2.fromOffset(32, 32), Parent = footer })
	themed(avatar, { BackgroundColor3 = "Element" })
	corner(avatar, 16)
	newText({
		Text = LocalPlayer.DisplayName, Font = Enum.Font.GothamMedium, TextSize = 13,
		Position = UDim2.fromOffset(54, 14), Size = UDim2.new(1, -62, 0, 16), TextTruncate = Enum.TextTruncate.AtEnd, Parent = footer,
	})
	newText({
		Text = "@" .. LocalPlayer.Name, Color = "SubText", TextSize = 11,
		Position = UDim2.fromOffset(54, 30), Size = UDim2.new(1, -62, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd, Parent = footer,
	})
	task.spawn(function()
		local ok, img = pcall(function()
			return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
		end)
		if ok and img and avatar.Parent then avatar.Image = img end
	end)

	win._pages = create("Frame", {
		Name = "Content", BackgroundTransparency = 1, ClipsDescendants = true,
		Position = UDim2.fromOffset(SIDE_W, 0), Size = UDim2.new(1, -SIDE_W, 1, 0), Parent = body,
	})

	-- dragging (smooth follow + tilt) ----------------------------------
	local function clampPos(v)
		return win:_Clamp(v)
	end

	local dragging, dragStart, startTarget, dragInput = false, nil, nil, nil
	topbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragInput = input
			dragStart = input.Position
			startTarget = win._target
			win:_SetLift(true)
			local c
			c = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					win:_SetLift(false)
					c:Disconnect()
				end
			end)
		end
	end)
	table.insert(win._conns, UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input == dragInput then
			local d = input.Position - dragStart
			win._target = clampPos(Vector2.new(startTarget.X + d.X, startTarget.Y + d.Y))
		end
	end))

	table.insert(win._conns, RunService.RenderStepped:Connect(function(dt)
		if not root.Visible then return end
		local cur, tgt = win._current, win._target
		local a = 1 - math.exp(-dt * Library.DragSmoothness)
		local nxt = cur + (tgt - cur) * a
		if (tgt - nxt).Magnitude < 0.4 then nxt = tgt end

		local vx = dt > 0 and (nxt.X - cur.X) / dt or 0
		local wantRot = Library.DragTilt and math.clamp(vx * 0.0012, -2.5, 2.5) or 0
		local rot = win._rotation
		local nrot = rot + (wantRot - rot) * (1 - math.exp(-dt * 10))
		if math.abs(nrot) < 0.02 then nrot = 0 end

		if nxt ~= cur then
			win._current = nxt
			root.Position = UDim2.fromOffset(math.floor(nxt.X + 0.5), math.floor(nxt.Y + 0.5))
		end
		if nrot ~= rot then
			win._rotation = nrot
			scaler.Rotation = nrot
		end
	end))

	-- window buttons ---------------------------------------------------
	closeBtn.MouseButton1Click:Connect(function()
		win:SetVisible(false)
		Library:Notify({
			Title = "Menu hidden",
			Content = win:_ToggleHint() .. " to show it again.",
			Type = "Info", Duration = 3,
		})
	end)
	minBtn.MouseButton1Click:Connect(function()
		win:SetMinimized(not win._minimized)
	end)

	table.insert(self.Windows, win)
	win.ToggleBind = self:RegisterKeybind({
		Name = "Toggle Menu", Group = "Interface", Key = cfg.ToggleKey or Enum.KeyCode.RightShift,
		Mode = "Press", Callback = function() win:Toggle() end, Owner = win, NoClear = true,
	})

	table.insert(win._conns, gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		win:_Refit()
	end))

	local useFab = cfg.FloatingButton
	if useFab == nil then useFab = self.IsTouch end
	if useFab then win:SetFloatingButton(true) end

	win:SetVisible(true)
	return win
end

-- visibility / scale / minimize ----------------------------------------
function Window:_ApplyScale(duration, style, dir)
	local mult = self.Visible and 1 or 0.92
	if self._lift and self.Visible then mult = 1.012 end
	tween(self._uiScale, duration, { Scale = self._baseScale * mult }, style or QUINT, dir or OUT)
end

function Window:_SetLift(on)
	self._lift = on
	if not self.Visible then return end
	self:_ApplyScale(0.35, QUINT, OUT)
	tween(self._shadow, 0.3, { GroupTransparency = on and 0.1 or 0.35 }, QUAD)
end

function Window:SetVisible(state)
	state = state and true or false
	if self.Visible == state then return end
	self.Visible = state
	self._token = self._token + 1
	local token = self._token
	self:_UpdateFab()
	if state then
		self.Root.Visible = true
		self:_ApplyScale(0.6, BACK, OUT)
		tween(self._window, 0.3, { GroupTransparency = 0 }, QUAD)
		tween(self._outline, 0.3, { Transparency = 0 }, QUAD)
		tween(self._shadow, 0.45, { GroupTransparency = 0.35 }, QUAD)
	else
		self:_ApplyScale(0.3, QUINT, IN)
		tween(self._window, 0.25, { GroupTransparency = 1 }, QUAD)
		tween(self._outline, 0.25, { Transparency = 1 }, QUAD)
		tween(self._shadow, 0.25, { GroupTransparency = 1 }, QUAD)
		task.delay(0.35, function()
			if token == self._token and not self.Visible then
				self.Root.Visible = false
			end
		end)
	end
end

function Window:Toggle()
	self:SetVisible(not self.Visible)
end

function Window:SetMinimized(state)
	self._minimized = state and true or false
	tween(self.Root, 0.5, { Size = UDim2.fromOffset(self._W, self._minimized and self._topH or self._H) }, QUINT)
end

function Window:SetTitle(text)
	self._titleLbl.Text = text
end

function Window:_Clamp(v)
	local size = viewport(self.Gui)
	return Vector2.new(math.clamp(v.X, 90 - self._W, size.X - 90), math.clamp(v.Y, 0, size.Y - 46))
end

-- Re-fit to the screen when it changes size (phone rotation, resizing the Studio viewport, ...)
function Window:_Refit()
	local vp = viewport(self.Gui)
	local W = math.max(math.min(self._cfgW, vp.X - 20), 300)
	local H = math.max(math.min(self._cfgH, vp.Y - 20), 220)
	self._W, self._H = W, H
	self._baseScale = math.clamp(math.min((vp.X - 20) / W, (vp.Y - 20) / H), 0.5, 1)
	local side = sideWidth(W)
	self.Root.Size = UDim2.fromOffset(W, self._minimized and self._topH or H)
	self._body.Size = UDim2.new(1, 0, 0, H - self._topH)
	self._sidebar.Size = UDim2.new(0, side, 1, 0)
	self._pages.Position = UDim2.fromOffset(side, 0)
	self._pages.Size = UDim2.new(1, -side, 1, 0)
	self._subLbl.Visible = W >= 560
	self._target = self:_Clamp(self._target)
	self._current = self:_Clamp(self._current)
	self.Root.Position = UDim2.fromOffset(math.floor(self._current.X + 0.5), math.floor(self._current.Y + 0.5))
	self:_ApplyScale(0.25)
end

function Window:_ToggleHint()
	if self._fab then return "Tap the floating button" end
	return "Press " .. keyName(self.ToggleBind.Key)
end

function Window:_UpdateFab()
	if self._fab then
		tween(self._fab, 0.3, { BackgroundTransparency = self.Visible and 0.4 or 0 }, QUAD)
	end
end

-- A draggable round button that opens / closes the menu. On by default for touch devices.
-- Tap = toggle, drag = move it (it snaps to the nearest screen edge when released).
function Window:SetFloatingButton(state)
	if not state then
		local old = self._fab
		if old then
			self._fab = nil
			tween(old, 0.25, { Size = UDim2.fromOffset(0, 0) }, QUINT, IN)
			task.delay(0.3, function() old:Destroy() end)
		end
		return
	end
	if self._fab then return end

	local gui = self.Gui
	local SIZE = 52
	local vp = viewport(gui)
	local center = Vector2.new(vp.X - SIZE / 2 - 12, math.floor(vp.Y * 0.4))
	local fab = create("TextButton", {
		Name = "AuroraButton", AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 40,
		Size = UDim2.fromOffset(0, 0), Position = UDim2.fromOffset(center.X, center.Y), Parent = gui,
	})
	corner(fab, SIZE / 2)
	themed(fab, { BackgroundColor3 = "Accent" })
	create("UIGradient", { Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(165, 165, 165)), Rotation = 45, Parent = fab })
	create("UIStroke", { Thickness = 2, Color = Color3.new(1, 1, 1), Transparency = 0.7, Parent = fab })
	local dot = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(18, 18),
		BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.1, Parent = fab,
	})
	corner(dot, 9)
	self._fab = fab
	tween(fab, 0.5, { Size = UDim2.fromOffset(SIZE, SIZE) }, BACK)
	self:_UpdateFab()

	local pressing, moved, startPoint, startCenter, trackInput = false, false, nil, nil, nil
	fab.InputBegan:Connect(function(input)
		local ut = input.UserInputType
		if ut ~= Enum.UserInputType.MouseButton1 and ut ~= Enum.UserInputType.Touch then return end
		pressing, moved = true, false
		startPoint, startCenter, trackInput = input.Position, center, input
		tween(fab, 0.12, { Size = UDim2.fromOffset(SIZE - 8, SIZE - 8) }, QUAD)
		local c
		c = input.Changed:Connect(function()
			if input.UserInputState ~= Enum.UserInputState.End then return end
			c:Disconnect()
			if not pressing then return end
			pressing = false
			tween(fab, 0.35, { Size = UDim2.fromOffset(SIZE, SIZE) }, BACK)
			if moved then
				local size = viewport(gui)
				local x = center.X < size.X / 2 and (SIZE / 2 + 12) or (size.X - SIZE / 2 - 12)
				center = Vector2.new(x, center.Y)
				tween(fab, 0.4, { Position = UDim2.fromOffset(center.X, center.Y) }, QUINT)
			else
				self:Toggle()
			end
		end)
	end)
	connectWhileAlive(fab, UserInputService.InputChanged, function(input)
		if not pressing then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input == trackInput then
			local d = input.Position - startPoint
			if d.Magnitude > 8 then moved = true end
			if moved then
				local size = viewport(gui)
				center = Vector2.new(
					math.clamp(startCenter.X + d.X, SIZE / 2 + 4, size.X - SIZE / 2 - 4),
					math.clamp(startCenter.Y + d.Y, SIZE / 2 + 4, size.Y - SIZE / 2 - 4)
				)
				fab.Position = UDim2.fromOffset(center.X, center.Y)
			end
		end
	end)
end

function Window:Notify(opts)
	return Library:Notify(opts)
end

function Window:Destroy()
	for _, c in ipairs(self._conns) do c:Disconnect() end
	for i = #Library._binds, 1, -1 do
		if Library._binds[i].Owner == self then table.remove(Library._binds, i) end
	end
	local idx = table.find(Library.Windows, self)
	if idx then table.remove(Library.Windows, idx) end
	self:SetFloatingButton(false)
	self:SetVisible(false)
	task.delay(0.5, function()
		self.Root:Destroy()
	end)
end

function Library:Unload()
	for _, w in ipairs({ table.unpack(self.Windows) }) do
		w:Destroy()
	end
	for _, c in ipairs(self._conns) do c:Disconnect() end
	table.clear(self._binds)
	for _, n in ipairs({ table.unpack(self._notifs) }) do n.Dismiss() end
	task.delay(0.9, function()
		if self._gui then self._gui:Destroy() end
	end)
end

-- tabs --------------------------------------------------------------------
-- cfg: Name, Description, Icon (optional "rbxassetid://...")
function Window:AddTab(cfg)
	if type(cfg) == "string" then cfg = { Name = cfg } end
	cfg = cfg or {}
	local tab = setmetatable({}, Tab)
	local index = #self.Tabs + 1
	tab.Window, tab._window = self, self
	tab.Name = cfg.Name or ("Tab " .. index)
	tab.Index = index
	tab._group = tab.Name
	tab._order = 0

	-- sidebar button
	local btn = create("TextButton", { Name = tab.Name, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 34), LayoutOrder = index, Parent = self._tabList })
	corner(btn, 8)
	themed(btn, { BackgroundColor3 = "ElementHover" })
	local hovered = false
	local xOff = 14
	local iconE
	if cfg.Icon then
		local icon = create("ImageLabel", {
			BackgroundTransparency = 1, Image = cfg.Icon, AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 12, 0.5, 0), Size = UDim2.fromOffset(18, 18), Parent = btn,
		})
		iconE = themed(icon, {
			ImageColor3 = function(t)
				if self._active == tab then return t.Accent end
				return hovered and t.Text or t.SubText
			end,
		})
		xOff = 38
	end
	local lbl, lblE = newText({
		Text = tab.Name, Font = Enum.Font.GothamMedium, TextSize = 13,
		Position = UDim2.fromOffset(xOff, 0), Size = UDim2.new(1, -xOff - 8, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd,
		Color = function(t)
			if self._active == tab then return t.Text end
			return hovered and t.Text or t.SubText
		end,
		Parent = btn,
	})
	tab.RefreshButton = function()
		retheme(lblE, 0.25)
		if iconE then retheme(iconE, 0.25) end
		tween(btn, 0.2, { BackgroundTransparency = 1 }, QUAD)
	end
	btn.MouseEnter:Connect(function()
		hovered = true
		retheme(lblE, 0.15)
		if iconE then retheme(iconE, 0.15) end
		if self._active ~= tab then tween(btn, 0.15, { BackgroundTransparency = 0.6 }, QUAD) end
	end)
	btn.MouseLeave:Connect(function()
		hovered = false
		retheme(lblE, 0.2)
		if iconE then retheme(iconE, 0.2) end
		tween(btn, 0.2, { BackgroundTransparency = 1 }, QUAD)
	end)
	btn.MouseButton1Click:Connect(function() self:SelectTab(tab) end)
	tab.Button = btn

	-- page
	local page = create("CanvasGroup", {
		Name = tab.Name, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
		GroupTransparency = 1, Visible = false, Parent = self._pages,
	})
	local scroll = create("ScrollingFrame", {
		BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 3, ScrollBarImageTransparency = 0.5,
		ScrollingDirection = Enum.ScrollingDirection.Y, Parent = page,
	})
	themed(scroll, { ScrollBarImageColor3 = "SubText" })
	create("UIListLayout", { Padding = UDim.new(0, 14), SortOrder = Enum.SortOrder.LayoutOrder, Parent = scroll })
	create("UIPadding", {
		PaddingTop = UDim.new(0, 14), PaddingBottom = UDim.new(0, 16),
		PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 18), Parent = scroll,
	})

	local header = create("Frame", {
		Name = "Header", BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0), LayoutOrder = 0, Parent = scroll,
	})
	create("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = header })
	newText({
		Text = tab.Name, Font = Enum.Font.GothamBold, TextSize = 22, Size = UDim2.new(1, 0, 0, 28), LayoutOrder = 1, Parent = header,
	})
	if cfg.Description then
		newText({
			Text = cfg.Description, Color = "SubText", TextSize = 13, TextWrapped = true,
			TextYAlignment = Enum.TextYAlignment.Top, AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, 0, 0, 0), LayoutOrder = 2, Parent = header,
		})
	end

	tab._content = create("Frame", {
		Name = "Elements", BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0), LayoutOrder = 1, Parent = scroll,
	})
	create("UIListLayout", { Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder, Parent = tab._content })
	tab.Page, tab.Scroll = page, scroll
	tab._scroll = scroll

	table.insert(self.Tabs, tab)
	if not self._active then
		self:SelectTab(tab)
	end
	return tab
end

function Window:SelectTab(tab)
	if type(tab) == "string" then
		for _, t in ipairs(self.Tabs) do
			if t.Name == tab then tab = t break end
		end
	end
	if type(tab) ~= "table" or self._active == tab then return end
	local prev = self._active
	self._active = tab
	if prev then
		prev.Page.Visible = false
		prev.Page.GroupTransparency = 1
		prev.RefreshButton()
	end
	tab.RefreshButton()

	local page = tab.Page
	page.Position = UDim2.fromOffset(0, 18)
	page.GroupTransparency = 1
	page.Visible = true
	tween(page, 0.5, { Position = UDim2.fromOffset(0, 0), GroupTransparency = 0 }, QUINT)

	local y = (tab.Index - 1) * 38
	if not self._pill.Visible then
		self._pill.Position = UDim2.fromOffset(0, y)
		self._pill.Visible = true
	else
		tween(self._pill, 0.5, { Position = UDim2.fromOffset(0, y) }, QUINT)
	end
end

-- Built-in tab that lists every keybind and lets the user rebind / reset them.
function Window:AddKeybindsTab(cfg)
	cfg = cfg or {}
	local tab = self:AddTab({
		Name = cfg.Name or "Keybinds",
		Description = "Click a key to rebind it, then press the new key. Backspace clears, Esc cancels. Right/middle mouse work too.",
	})
	local iface = tab:AddSection("Interface")
	local registered = tab:AddSection("Registered Keybinds")
	local manage = tab:AddSection("Manage")

	local shown = {}
	local function consider(kb)
		if shown[kb] or kb.Hidden or (kb.Owner and kb.Owner ~= self) then return end
		shown[kb] = true
		local isMenu = kb == self.ToggleBind
		local target = isMenu and iface or registered
		target:_BindRow(kb, not isMenu)
	end
	for _, kb in ipairs(Library._binds) do consider(kb) end
	table.insert(Library._bindListeners, function(kb)
		if tab.Page.Parent then consider(kb) end
	end)

	manage:AddButton({
		Name = "Reset all keybinds", Description = "Restore every keybind to its default key",
		Callback = function()
			for _, kb in ipairs(Library._binds) do
				if shown[kb] then kb:SetKey(kb.Default) end
			end
			Library:Notify({ Title = "Keybinds reset", Content = "All keybinds are back to their defaults.", Type = "Success" })
		end,
	})
	manage:AddButton({
		Name = "Clear all keybinds", Description = "Unbind everything except the menu key",
		Callback = function()
			for _, kb in ipairs(Library._binds) do
				if shown[kb] and not kb.NoClear then kb:SetKey(nil) end
			end
			Library:Notify({ Title = "Keybinds cleared", Content = "All keybinds (except the menu key) are unbound.", Type = "Warning" })
		end,
	})
	return tab
end

local Stats = game:GetService("Stats")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")

-- Owner notification
do
	local ok, thumb = pcall(function()
		return Players:GetUserThumbnailAsync(2320681142, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
	end)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = "Owner",
			Text = "Gabrieltod112",
			Icon = ok and thumb or "",
			Duration = 6,
		})
	end)
end

----------------------------------------------------------------------
-- OWNER / MARKER
----------------------------------------------------------------------
local OWNER_USER_ID = 2320681142
local isOwner = LocalPlayer.UserId == OWNER_USER_ID
local MARKER_NAME = "OperationRage_Client_Marker"

local function plantMarker()
	local pg = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui")
	if not pg:FindFirstChild(MARKER_NAME) then
		local marker = Instance.new("Folder")
		marker.Name = MARKER_NAME
		marker.Parent = pg
	end
end
plantMarker()

local function isUsingScript(player)
	if not player then return false end
	local pg = player:FindFirstChild("PlayerGui")
	return pg and pg:FindFirstChild(MARKER_NAME) ~= nil
end

----------------------------------------------------------------------
-- NDS
----------------------------------------------------------------------
local NDS_PLACE_IDS = { [189707] = true }
local function isNDS()
	return NDS_PLACE_IDS[game.PlaceId] == true
end

----------------------------------------------------------------------
-- SETTINGS
----------------------------------------------------------------------
local ConfigFolder = "OperationRage"
local ConfigFile = ConfigFolder .. "/settings.json"
local DefaultSettings = {
	ToggleKey = "RightControl",
	NDS_DontPrompt = false,
	NDS_AutoLoad = false,
}
local Settings = table.clone(DefaultSettings)

local function saveSettings()
	pcall(function()
		if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
		writefile(ConfigFile, HttpService:JSONEncode(Settings))
	end)
end

local function loadSettings()
	pcall(function()
		if isfile(ConfigFile) then
			local data = HttpService:JSONDecode(readfile(ConfigFile))
			for k, v in pairs(data) do Settings[k] = v end
		end
	end)
end
loadSettings()

----------------------------------------------------------------------
-- MUSIC
----------------------------------------------------------------------
local MusicLibrary = {
	{Name = "Raining Tacos", ID = 142376088},
	{Name = "Crab Rave", ID = 5410086218},
	{Name = "Whatcha Say", ID = 168208965},
	{Name = "God's Plan - Drake", ID = 1665926924},
	{Name = "Stronger - Kanye", ID = 136209425},
	{Name = "Tokyo Drift", ID = 1837015626},
	{Name = "Stadium Rave (SpongeBob)", ID = 1846368080},
	{Name = "Spooky Scary Skeletons", ID = 138081566},
	{Name = "Gangsta's Paradise", ID = 6070263388},
	{Name = "Smooth Criminal", ID = 4883181281},
	{Name = "Without Me - Eminem", ID = 6689996382},
	{Name = "Intergalactic", ID = 131603357},
	{Name = "Black and Yellow", ID = 139235100},
	{Name = "Moves Like Jagger", ID = 291895335},
	{Name = "Jenny", ID = 170103636},
	{Name = "Let's Get It Started", ID = 138134680},
	{Name = "Claire De Lune", ID = 1838457617},
	{Name = "Happy Song", ID = 1843404009},
	{Name = "Squid Game Theme", ID = 7535587224},
	{Name = "Sandstorm", ID = 166562385},
	{Name = "Never Gonna Give You Up", ID = 507443984},
	{Name = "Thunderstruck", ID = 146961487},
	{Name = "Baby Shark", ID = 614018503},
	{Name = "Gangnam Style", ID = 1293544985},
	{Name = "Bohemian Rhapsody", ID = 4587240503},
	{Name = "Rasputin", ID = 5512350519},
	{Name = "Take On Me", ID = 4606705490},
	{Name = "Believer", ID = 2389193148},
	{Name = "Levitating", ID = 6606223785},
	{Name = "Bad Habits", ID = 7202579511},
	{Name = "In The End", ID = 3018974408},
	{Name = "Smells Like Teen Spirit", ID = 3495593580},
	{Name = "Pokerap", ID = 152381839},
	{Name = "Team Fortress 2", ID = 166378555},
	{Name = "Mii Channel", ID = 143666548},
	{Name = "GTA San Andreas", ID = 4571975095},
	{Name = "Moonlight Sonata", ID = 445023353},
	{Name = "Fur Elise", ID = 450051032},
	{Name = "Chill Jazz", ID = 1845341094},
	{Name = "Lo-Fi Chill", ID = 9043887091},
	{Name = "Running", ID = 1843436418},
	{Name = "Get Hyper", ID = 138855854},
	{Name = "Trumpets", ID = 146237847},
	{Name = "Wooden Bear", ID = 1844397736},
	{Name = "Ooh Kill Em", ID = 139222895},
	{Name = "Domo23", ID = 8757702532},
	{Name = "Shiawase", ID = 5409360995},
	{Name = "Poolside", ID = 9046863253},
	{Name = "Horror", ID = 9039981149},
	{Name = "All Star", ID = 166560754},
	{Name = "Nyan Cat", ID = 142292308},
	{Name = "Numb - Linkin Park", ID = 368199310},
	{Name = "Bring Me To Life", ID = 547303549},
	{Name = "We Will Rock You", ID = 333449748},
	{Name = "Enter Sandman", ID = 2565757094},
	{Name = "Paint It Black", ID = 6828176320},
	{Name = "Highway to Hell", ID = 4728058875},
	{Name = "Dynamite - BTS", ID = 6257627378},
	{Name = "Butter - BTS", ID = 6844912719},
	{Name = "Money - LISA", ID = 7551431783},
	{Name = "God Is A Woman", ID = 2071829884},
	{Name = "Say So", ID = 521116871},
	{Name = "Industry Baby", ID = 7253841629},
	{Name = "Sunflower", ID = 2698664996},
	{Name = "Viva La Vida", ID = 170173180},
	{Name = "Chop Suey", ID = 4556134799},
	{Name = "This Is America", ID = 2062482384},
	{Name = "Lean On", ID = 606299326},
	{Name = "Royals", ID = 412314152},
	{Name = "Natural - Imagine Dragons", ID = 2173344520},
	{Name = "What's Up Danger", ID = 3106151105},
	{Name = "Hallelujah", ID = 241864564},
	{Name = "Let It Go", ID = 189105508},
	{Name = "Applause", ID = 130964099},
	{Name = "Milkshake", ID = 321199908},
	{Name = "Soft Jazz", ID = 926493242},
	{Name = "Toccata & Fugue", ID = 564238335},
}

local songNames = {}
local songByName = {}
for _, s in ipairs(MusicLibrary) do
	table.insert(songNames, s.Name)
	songByName[s.Name] = s.ID
end

local currentSound = nil
local isPlaying = false
local currentVol = 0.5
local currentSpeed = 1

local function playSong(id)
	if currentSound then
		currentSound:Stop()
		currentSound:Destroy()
	end
	currentSound = Instance.new("Sound")
	currentSound.SoundId = "rbxassetid://" .. tostring(id)
	currentSound.Volume = currentVol
	currentSound.PlaybackSpeed = currentSpeed
	currentSound.Looped = true
	currentSound.Parent = SoundService
	currentSound:Play()
	isPlaying = true
end

local function stopSong()
	if currentSound then
		currentSound:Stop()
		currentSound:Destroy()
		currentSound = nil
	end
	isPlaying = false
end

----------------------------------------------------------------------
-- PRESETS / KILL
----------------------------------------------------------------------
local function runNDSPreset()
	local scripts = {
		{name = "Touch fling", url = "https://pastebin.com/raw/LgZwZ7ZB"},
		{name = "Kilaskis multi fling", url = "https://raw.githubusercontent.com/K1LAS1K/Ultimate-Fling-GUI/main/flingscript.lua"},
		{name = "anti stuff", url = "https://raw.githubusercontent.com/OMNIMANRUSSIA/NDS-OMNIMAN-GOD-TOUCH-FLING-ANTISIT-ANTIBANG/main/main.lua"},
		{name = "Flight anims", url = "https://obj.wearedevs.net/197198/scripts/invincible%20flight%20animation.lua"},
		{name = "Infinite Yield", url = "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"},
	}
	for _, s in ipairs(scripts) do
		task.spawn(function()
			local ok, err = pcall(function()
				loadstring(game:HttpGet(s.url, true))()
			end)
			if not ok then
				warn("[NDS Preset] " .. s.name .. " failed: " .. tostring(err))
			end
		end)
		task.wait(0.4)
	end
	Library:Notify({ Title = "NDS Preset", Content = "Loading recommended scripts…", Type = "Success", Duration = 3 })
end

local function attemptKill(targetPlayer)
	if not targetPlayer or not targetPlayer.Character then return end
	local char = targetPlayer.Character
	local hum = char:FindFirstChildOfClass("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if hum then pcall(function() hum.Health = 0 end) end
	if hrp then
		pcall(function()
			hrp.Velocity = Vector3.new(0, 9999, 0)
			hrp.RotVelocity = Vector3.new(9999, 9999, 9999)
		end)
	end
end

local function safeLoad(name, url)
	return function()
		local ok, err = pcall(function()
			loadstring(game:HttpGet(url, true))()
		end)
		if ok then
			Library:Notify({ Title = name, Content = "Loaded successfully.", Type = "Success", Duration = 2 })
		else
			Library:Notify({ Title = name, Content = "Failed: " .. tostring(err), Type = "Error", Duration = 4 })
			warn(name .. ": " .. tostring(err))
		end
	end
end

----------------------------------------------------------------------
-- WINDOW
----------------------------------------------------------------------
Library:SetTheme("Rose")

local toggleKey = Enum.KeyCode[Settings.ToggleKey] or Enum.KeyCode.RightControl

local Window = Library:CreateWindow({
	Title = "Operation Rage",
	Subtitle = "made by gabrieltod112",
	Size = Vector2.new(620, 460),
	ToggleKey = toggleKey,
})

----------------------------------------------------------------------
-- HOME
----------------------------------------------------------------------
local Home = Window:AddTab({
	Name = "Home",
	Description = "Welcome to Operation Rage. Use the tabs to load scripts, music, and settings.",
})
Home:AddParagraph({
	Title = "Player",
	Content = string.format("%s  (@%s)\nUserId: %s%s",
		LocalPlayer.DisplayName, LocalPlayer.Name, tostring(LocalPlayer.UserId),
		isOwner and "\n★ Owner access enabled" or ""),
})
Home:AddParagraph({
	Title = "Quick tips",
	Content = "• RightControl (or your set key) toggles this menu\n• Misc / OP / Other Games load external scripts\n• Music is client-sided only\n• NDS auto-detects Natural Disaster Survival",
})
local homeStats = Home:AddLabel("FPS: --  |  Ping: -- ms")
task.spawn(function()
	while task.wait(0.5) do
		local fps = math.floor(1 / RunService.RenderStepped:Wait())
		local ping = 0
		pcall(function()
			ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
		end)
		homeStats:SetText("FPS: " .. fps .. "  |  Ping: " .. ping .. " ms")
	end
end)

----------------------------------------------------------------------
-- NDS protection (Home)
----------------------------------------------------------------------
local ndsSec = Home:AddSection("NDS Protection")
ndsSec:AddParagraph({
	Title = "Visual / Audio",
	Content = "Destroy Disaster Sound mutes/removes disaster audio. No Fog + No Disaster GUI cleans lighting and UI overlays.",
})

local destroyDisasterSound = false
local noFogNoGui = false
local soundConn, fogGuiConn
local mutedSounds = {} -- [Sound] = original Volume

local function isDisasterRelated(obj)
	local n = string.lower(obj.Name or "")
	-- common NDS / generic disaster naming
	local keys = {
		"disaster", "earthquake", "quake", "tornado", "tsunami", "flood",
		"blizzard", "sandstorm", "volcano", "meteor", "thunder", "lightning",
		"avalanche", "acid", "rain", "storm", "wind", "shake", "collapse",
		"fire", "lava", "siren", "alarm", "warning", "ambient", "disastermusic",
		"disastersound", "quake_sound", "disaster_sound",
	}
	for _, k in ipairs(keys) do
		if string.find(n, k, 1, true) then return true end
	end
	return false
end

local function silenceSound(s)
	if not s or not s:IsA("Sound") then return end
	if mutedSounds[s] == nil then
		mutedSounds[s] = s.Volume
	end
	pcall(function()
		s.Volume = 0
		s:Stop()
	end)
end

local function restoreSound(s)
	if not s or not s.Parent then
		mutedSounds[s] = nil
		return
	end
	local vol = mutedSounds[s]
	if vol ~= nil then
		pcall(function() s.Volume = vol end)
		mutedSounds[s] = nil
	end
end

local function wipeDisasterSounds()
	-- Content / Module under Workspace (NDS map content)
	local roots = {
		workspace:FindFirstChild("Content"),
		workspace:FindFirstChild("content"),
		workspace:FindFirstChild("Module"),
		workspace:FindFirstChild("Modules"),
		workspace:FindFirstChild("Game"),
		workspace:FindFirstChild("Map"),
		workspace:FindFirstChild("Island"),
		workspace,
		game:GetService("SoundService"),
		game:GetService("ReplicatedStorage"),
	}
	for _, root in ipairs(roots) do
		if not root then continue end
		for _, d in ipairs(root:GetDescendants()) do
			if d:IsA("Sound") then
				-- Always silence anything under Content/Module; elsewhere only name-matched
				local underContent = false
				local p = d.Parent
				while p and p ~= workspace and p ~= game do
					local pn = string.lower(p.Name or "")
					if pn == "content" or pn == "module" or pn == "modules" or pn == "sounds" or pn == "disaster" then
						underContent = true
						break
					end
					p = p.Parent
				end
				if underContent or isDisasterRelated(d) or isDisasterRelated(d.Parent or d) then
					silenceSound(d)
				end
			end
		end
	end
end

local function stopSoundLoop()
	if soundConn then
		pcall(function() soundConn:Disconnect() end)
		soundConn = nil
	end
	-- restore volumes
	for s, _ in pairs(mutedSounds) do
		restoreSound(s)
	end
	mutedSounds = {}
end

local function startSoundLoop()
	stopSoundLoop()
	wipeDisasterSounds()
	soundConn = RunService.Heartbeat:Connect(function()
		if not destroyDisasterSound then return end
		-- continuous: new sounds can spawn mid-disaster
		wipeDisasterSounds()
	end)
	-- also catch newly added sounds
	local function hook(root)
		if not root then return end
		root.DescendantAdded:Connect(function(d)
			if not destroyDisasterSound then return end
			if d:IsA("Sound") then
				task.defer(function()
					if destroyDisasterSound and d.Parent then
						local underContent = false
						local p = d.Parent
						while p and p ~= workspace and p ~= game do
							local pn = string.lower(p.Name or "")
							if pn == "content" or pn == "module" or pn == "modules" or pn == "sounds" or pn == "disaster" then
								underContent = true
								break
							end
							p = p.Parent
						end
						if underContent or isDisasterRelated(d) then
							silenceSound(d)
						end
					end
				end)
			end
		end)
	end
	hook(workspace)
	hook(game:GetService("SoundService"))
end

-- Fog + Disaster GUI
local savedFog = nil
local hiddenGuis = {} -- [gui] = true

local function clearFog()
	local Lighting = game:GetService("Lighting")
	if not savedFog then
		savedFog = {
			FogEnd = Lighting.FogEnd,
			FogStart = Lighting.FogStart,
			FogColor = Lighting.FogColor,
		}
	end
	pcall(function()
		Lighting.FogEnd = 100000
		Lighting.FogStart = 0
	end)
	-- Atmosphere / Bloom sometimes used for blizzard/sandstorm
	for _, c in ipairs(Lighting:GetChildren()) do
		if c:IsA("Atmosphere") then
			pcall(function()
				c.Density = 0
				c.Haze = 0
			end)
		elseif c:IsA("BloomEffect") or c:IsA("BlurEffect") or c:IsA("ColorCorrectionEffect") then
			-- leave mild effects; only zero extreme disaster ones by name
			if isDisasterRelated(c) then
				pcall(function() c.Enabled = false end)
			end
		end
	end
end

local function restoreFog()
	if not savedFog then return end
	local Lighting = game:GetService("Lighting")
	pcall(function()
		Lighting.FogEnd = savedFog.FogEnd
		Lighting.FogStart = savedFog.FogStart
		Lighting.FogColor = savedFog.FogColor
	end)
	savedFog = nil
end

local DISASTER_GUI_NAMES = {
	"disaster", "blizzard", "sandstorm", "storm", "warning", "alert",
	"message", "hint", "disastergui", "disaster_gui", "weather",
	"effects", "overlay", "screen", "notification", "disasterlabel",
}

local function isDisasterGui(obj)
	local n = string.lower(obj.Name or "")
	for _, k in ipairs(DISASTER_GUI_NAMES) do
		if string.find(n, k, 1, true) then return true end
	end
	return false
end

local function hideDisasterGuis()
	local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:FindFirstChild("PlayerGui")
	if not pg then return end
	for _, g in ipairs(pg:GetDescendants()) do
		if (g:IsA("ScreenGui") or g:IsA("Frame") or g:IsA("TextLabel") or g:IsA("ImageLabel") or g:IsA("BillboardGui")) and isDisasterGui(g) then
			if g.Visible ~= false then
				hiddenGuis[g] = true
				pcall(function() g.Visible = false end)
			end
		end
	end
	-- also CoreGui messages sometimes
	pcall(function()
		local StarterGui = game:GetService("StarterGui")
		-- no reliable API to clear all; visibility is enough
	end)
end

local function restoreDisasterGuis()
	for g, _ in pairs(hiddenGuis) do
		if g and g.Parent then
			pcall(function() g.Visible = true end)
		end
	end
	hiddenGuis = {}
end

local function stopFogGui()
	if fogGuiConn then
		pcall(function() fogGuiConn:Disconnect() end)
		fogGuiConn = nil
	end
	restoreFog()
	restoreDisasterGuis()
end

local function startFogGui()
	stopFogGui()
	clearFog()
	hideDisasterGuis()
	fogGuiConn = RunService.Heartbeat:Connect(function()
		if not noFogNoGui then return end
		clearFog()
		hideDisasterGuis()
	end)
	local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
	if pg then
		pg.DescendantAdded:Connect(function(d)
			if not noFogNoGui then return end
			if isDisasterGui(d) and (d:IsA("ScreenGui") or d:IsA("Frame") or d:IsA("TextLabel") or d:IsA("ImageLabel")) then
				task.defer(function()
					if noFogNoGui and d.Parent then
						hiddenGuis[d] = true
						pcall(function() d.Visible = false end)
					end
				end)
			end
		end)
	end
end

ndsSec:AddToggle({
	Name = "Destroy Disaster Sound",
	Description = "Deletes / mutes disaster sounds under Content / Module (and name-matched sounds).",
	Default = false,
	Callback = function(v)
		destroyDisasterSound = v and true or false
		if destroyDisasterSound then
			startSoundLoop()
			Library:Notify({ Title = "Disaster Sound", Content = "Enabled — disaster audio silenced.", Type = "Success", Duration = 3 })
		else
			stopSoundLoop()
			Library:Notify({ Title = "Disaster Sound", Content = "Disabled — sounds restored where possible.", Type = "Info", Duration = 2 })
		end
	end,
})

ndsSec:AddToggle({
	Name = "No Fog + No Disaster GUI",
	Description = "Removes fog / atmosphere haze and hides disaster overlay GUIs.",
	Default = false,
	Callback = function(v)
		noFogNoGui = v and true or false
		if noFogNoGui then
			startFogGui()
			Library:Notify({ Title = "No Fog / GUI", Content = "Enabled — fog cleared, disaster UI hidden.", Type = "Success", Duration = 3 })
		else
			stopFogGui()
			Library:Notify({ Title = "No Fog / GUI", Content = "Disabled.", Type = "Info", Duration = 2 })
		end
	end,
})

----------------------------------------------------------------------
-- MISC
----------------------------------------------------------------------
local Misc = Window:AddTab({ Name = "Misc", Description = "Utility scripts — fling, flight, anti, admin." })
local miscSec = Misc:AddSection("Scripts")
miscSec:AddButton({ Name = "Touch fling", Callback = safeLoad("Touch fling", "https://pastebin.com/raw/LgZwZ7ZB") })
miscSec:AddButton({ Name = "Kilaskis multi fling", Callback = safeLoad("Kilaskis multi fling", "https://raw.githubusercontent.com/K1LAS1K/Ultimate-Fling-GUI/main/flingscript.lua") })
miscSec:AddButton({ Name = "Flight anims", Callback = safeLoad("Flight anims", "https://obj.wearedevs.net/197198/scripts/invincible%20flight%20animation.lua") })
miscSec:AddButton({ Name = "anti stuff", Callback = safeLoad("anti stuff", "https://raw.githubusercontent.com/OMNIMANRUSSIA/NDS-OMNIMAN-GOD-TOUCH-FLING-ANTISIT-ANTIBANG/main/main.lua") })
miscSec:AddButton({ Name = "Drop kick (buggy)", Callback = safeLoad("Drop kick", "https://raw.githubusercontent.com/gsm231/Fe-DropKick/refs/heads/main/V0.1") })
miscSec:AddButton({ Name = "Infinite Yield", Callback = safeLoad("Infinite Yield", "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source") })

local ndsSec = Misc:AddSection("Natural Disaster Survival")
ndsSec:AddButton({
	Name = "Load NDS preset now",
	Description = "Touch fling + multi fling + anti + flight + Infinite Yield",
	Callback = runNDSPreset,
})

----------------------------------------------------------------------
-- OP
----------------------------------------------------------------------
local OP = Window:AddTab({ Name = "OP", Description = "Heavy part / ring scripts." })
local opSec = OP:AddSection("Ring scripts")
opSec:AddButton({ Name = "Super ring v5 lukas", Callback = safeLoad("Super ring v5 lukas", "https://raw.githubusercontent.com/Lukashub-coder/Super-ring-V5/refs/heads/main/By%20lukas!!") })
opSec:AddButton({
	Name = "GABS SUPER RING",
	Description = "Embedded local copy (no remote load).",
	Callback = function()
		local fn, err = loadstring([===[
-- made by gabrieltod112
-- Owner UserId: 2320681142

print([[
@@@@@@@@@@%%%*%@@@@@@@@@@@@@@@@@@@@@@@%#:*@%@@@@@@@@@@@@@@@@@@@@@@@@%%%%@@@@@@@@
@@@@@@@@%%%%@@@@@@%@@@@@@@@@@@@@@@@@@@*. .@@@@@@@@@@#@@@@@@@@@@@@@@@@@%%*=:+@@@@
@@@@@@@%%%*@%@@@@@@@@@@@@@@@@@@@@@@%%=    +@@@#@@@@@@@@@@@@@@@@@@@@@#=.    +@@@@
@@@@@%%%*%@@@@@@@@@@@= +@@@@@@@@@@@%=      #@@@@@@@@@@@@@@@@@@@@%+:        +%@@@
@@@@%%%%@@@@@@%#@@%-:+=.@@@@@@@@@@%-       .%@@@@@@@@@@@@@@@@%=.           -%%@@
@@%%%%-..*@@@@@@#.:#@@# @@@@@@@@@@-         -@@@@@@@@@@@@@%+:          --  .*%%%
@%%%#=.%%::*@@@@@-.%@@@ *@@@@@@@@=           =@@@@@@@@@%+:          .:=:-   :%%%
%%%%% #@%@# -%#@@@# =@@-:@@@@@@@=             -%@@@@@*:            :=:::-    *@%
@@@@-:@@@@%@* :@@@@@-.%# %@@@@@+          .... .*@@#:            .=-::::=    -@@
@@@@ #@@@@@@@@*::%%@@* + *@@*@*.   :-:.          .+:            --::::::=.   :@@
@@@% @@@@@@@@@@@*::#%%*. :@@@#..--:.                          .=-:::::::=.   :%@
@@@# @@@@@@@@@@@@%*.-%@@- %@%: ...::                         .-:::::::::-:   :%@
@@@% **#####**%%%%%%* =@@ #@-   .-                           :-:::::::::-:   :@@
@@@@%#%@%%%%#*=-:.   .. *@@+   =.                               -=--::::-.   -@@
@@@@@@@@@@@@@@@@@@@@@@%*@@%: .===.                                 =::::=.   =@@
@@@@@@@@@@@@@@@@@@@@@@@@@@#  -.-.                                 -:::::=.  .#@@
@@@@@@@%##@@@@@@@@@@@@@@@@+    -                                   ::-:--   -@@@
@@@@@@@@@%=.:+#@@@@@@@@@@@-   :.                                     -:-   .#@@@
@@@@%@@@@@@+   .+@@@@%@@=*=   =    .               :-=+=.            -=   .*@@@@
@@@@@@@@@@@%:     +@@%:+*.    = -. +++=          -  :+++++               :#@@@@@
@@@@@@@@@@@@-      .*@=.:=:   =   .++++             -+++++.             ----+#@@
@@@@@@@@@@@%:        == ..-:=::.  :++++.            -+++++.            .:= =@@@@
@@@@@@@@@@@*          .   .:=.--  :++++.            -+++++.        ...::.=+@@@@@
@@@@@@@@@@%-                :: =  .+++=             :++++=              -#@@@@@@
@@@@@@@@@@=             :===:. -     .                                 =@@@@@@@@
@@@@@@@@@*. ....:      ..-:    :.                                    :+%%%%@@@@@
@@@@@@@@%::. ::..-- ::----:-   -    .--.                                .-@@@@@@
@@@@@@@@-.: =.    -+:-.   ::=-:-                                       :*@@@@@@@
@@@@@@@=..- =  ...:+=:..   ==*-:-.                                   :+#@@@@@@@@
@@@@@@*.::=.=-::::.==::::::-*%%%%#+:          .                   .:+#%##%%@@@@@
@@@@@#- -..=.=....-=-....:==**#%%%%%#+-.    ..                 .-+#%%%%%%%%@@@@@
@@@@@- ::   -:.::.   .--:.-=. :+#%%%%%%%#*++=====++++*+-.  -+##%%%%%%%%%%%%@@@@@
@@@@+  --:..:+           :=.   -+%%%%%%%%%%%@@@@%%%%%%%%%#####%%%%%@@@%%%%%@@@@@
@@@*=. .=...:-  .::....:..-::::==##%%%%##%@@%%%#####%%%%%@@@%%%%@@@%+%%%%%%%#@@@
@@%:.-  :-:-:  -:       ::-:.:-:*@%####%%%#########%%%%@@%%%%%@@%%%*:=%%@@@*-=@@
@@=.  =       =.  ..... .:-    +%@%%###%%%%%%####%%%%%%%%%%@@%%####++-=+*#+=#-#@
%*.    .:    :-:::::::::::-. .*%%%@@%#####%%%%%%%%%%%%%%@@%%%####++=+*#####%#%@@
%-.      :   --::::::......::#%%%#%@@%%#####%%%%%%%%%@@%%%%%%####*+=+**#++#*%@@@
#:.      .:  :-.....::-:.:-=%@%%####%%@@@%%%%%@@@@@%%%%%%%@@@%###+++=++++++#%@@@
#:.       .:  ::::::.:--. -#@@%%%######%%%@@@@%%%%%####%%%%@#==+###*=#####%%%@@@
%:..        :         =:  +%@@%%%%%%#####***+++++=+**###%%@@=*%+=##++######%@@@@
@+..        :         -.  :*@@%%%%%%#*+:  :---:         .-+##+**-*#=*#%%%%%%@@@@
@@+....     =               :*#%%#%*:--  =.   -:.             :+#-#-%%%%%%%@@@@@
@@@*:......:-               :#%%%%%*.:: ::   =.                -*#*%%%%%%%@@@@@@
thanks for using my script -gab :3
]])

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local Folder = Instance.new("Folder", Workspace)
local Part = Instance.new("Part", Folder)
Part.Anchored = true
Part.CanCollide = false
Part.Transparency = 1

if not getgenv().Network then
	getgenv().Network = {
		BaseParts = {},
		Velocity = Vector3.new(14.46262424, 14.46262424, 14.46262424),
		Active = true,
	}
	local Network = getgenv().Network
	Network.RetainPart = function(p)
		if typeof(p) == "Instance" and p:IsA("BasePart") and p:IsDescendantOf(Workspace) then
			if not table.find(Network.BaseParts, p) then
				table.insert(Network.BaseParts, p)
				p.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
				p.CanCollide = false
			end
		end
	end
	RunService.Heartbeat:Connect(function()
		pcall(function()
			sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
		end)
		LocalPlayer.ReplicationFocus = Workspace
		-- Always pulse retained parts slightly harder when network active
		if not Network.Active then return end
		for _, p in pairs(Network.BaseParts) do
			if p and p.Parent and p:IsDescendantOf(Workspace) then
				p.Velocity = Network.Velocity
				pcall(function() p.AssemblyLinearVelocity = Network.Velocity end)
			end
		end
	end)
end

local function playSound(id)
	local s = Instance.new("Sound")
	s.SoundId = "rbxassetid://" .. id
	s.Parent = SoundService
	s:Play()
	s.Ended:Connect(function() s:Destroy() end)
end
playSound("2865227271")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GabsRingUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 540, 0, 420)
Main.Position = UDim2.new(0.5, -270, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)

local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(70, 45, 95)
Stroke.Thickness = 1.4
Stroke.Transparency = 0.15

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 38)
TitleBar.BackgroundColor3 = Color3.fromRGB(18, 16, 24)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 14)

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 12)
TitleFix.Position = UDim2.new(0, 0, 1, -12)
TitleFix.BackgroundColor3 = Color3.fromRGB(18, 16, 24)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

-- Accent strip under title
local TitleAccent = Instance.new("Frame")
TitleAccent.Size = UDim2.new(1, 0, 0, 2)
TitleAccent.Position = UDim2.new(0, 0, 1, -2)
TitleAccent.BackgroundColor3 = Color3.fromRGB(140, 70, 200)
TitleAccent.BorderSizePixel = 0
TitleAccent.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 14, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "gab's Rings  •  v2.9"
Title.TextColor3 = Color3.fromRGB(245, 240, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 28, 0, 26)
MinimizeBtn.Position = UDim2.new(1, -70, 0, 6)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(38, 34, 48)
MinimizeBtn.Text = "−"
MinimizeBtn.TextColor3 = Color3.fromRGB(230, 225, 245)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 18
MinimizeBtn.Parent = TitleBar
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 26)
CloseBtn.Position = UDim2.new(1, -36, 0, 6)
CloseBtn.BackgroundColor3 = Color3.fromRGB(170, 50, 70)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

CloseBtn.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)

-- Minimize wired after full UI is built (see setMinimized below)
TitleBar.ZIndex = 20
MinimizeBtn.ZIndex = 21
CloseBtn.ZIndex = 21
Title.ZIndex = 21

local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(0, 110, 1, -90)
TabFrame.Position = UDim2.new(0, 0, 0, 38)
TabFrame.BackgroundColor3 = Color3.fromRGB(14, 13, 18)
TabFrame.BorderSizePixel = 0
TabFrame.Parent = Main

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -120, 1, -100)
Content.Position = UDim2.new(0, 115, 0, 45)
Content.BackgroundTransparency = 1
Content.Parent = Main

local function createTabButton(name, order)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 34)
	btn.Position = UDim2.new(0, 5, 0, 10 + (order - 1) * 42)
	btn.BackgroundColor3 = Color3.fromRGB(28, 26, 36)
	btn.Text = name
	btn.TextColor3 = Color3.fromRGB(180, 175, 195)
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = 13
	btn.Parent = TabFrame
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	local ts = Instance.new("UIStroke", btn)
	ts.Color = Color3.fromRGB(50, 45, 65)
	ts.Thickness = 1
	ts.Transparency = 0.4
	return btn
end

local LocalTabBtn = createTabButton("Local", 1)
local TargetTabBtn = createTabButton("Target", 2)
local TextTabBtn = createTabButton("Text", 3)
ThreeDPlusTabBtn = createTabButton("3D+", 4)

local function createPage()
	local page = Instance.new("ScrollingFrame")
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 3
	page.ScrollBarImageColor3 = Color3.fromRGB(110, 80, 150)
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.Visible = false
	page.Parent = Content
	return page
end

local LocalPage = createPage()
local TargetPage = createPage()
local TextPage = createPage()
ThreeDPlusPage = createPage()

local function showPage(page, activeBtn)
	LocalPage.Visible = false
	TargetPage.Visible = false
	TextPage.Visible = false
	ThreeDPlusPage.Visible = false
	page.Visible = true
	for _, btn in pairs({LocalTabBtn, TargetTabBtn, TextTabBtn, ThreeDPlusTabBtn}) do
		btn.BackgroundColor3 = Color3.fromRGB(28, 26, 36)
		btn.TextColor3 = Color3.fromRGB(180, 175, 195)
	end
	activeBtn.BackgroundColor3 = Color3.fromRGB(95, 55, 160)
	activeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
end

LocalTabBtn.MouseButton1Click:Connect(function() showPage(LocalPage, LocalTabBtn) end)
TargetTabBtn.MouseButton1Click:Connect(function() showPage(TargetPage, TargetTabBtn) end)
TextTabBtn.MouseButton1Click:Connect(function() showPage(TextPage, TextTabBtn) end)
ThreeDPlusTabBtn.MouseButton1Click:Connect(function() showPage(ThreeDPlusPage, ThreeDPlusTabBtn) end)
showPage(LocalPage, LocalTabBtn)

-- Bottom bar
local BottomBar = Instance.new("Frame")
BottomBar.Size = UDim2.new(1, 0, 0, 52)
BottomBar.Position = UDim2.new(0, 0, 1, -52)
BottomBar.BackgroundColor3 = Color3.fromRGB(14, 13, 18)
BottomBar.BorderSizePixel = 0
BottomBar.Parent = Main

local BottomStroke = Instance.new("Frame")
BottomStroke.Size = UDim2.new(1, 0, 0, 1)
BottomStroke.BackgroundColor3 = Color3.fromRGB(70, 45, 95)
BottomStroke.BackgroundTransparency = 0.35
BottomStroke.BorderSizePixel = 0
BottomStroke.Parent = BottomBar

local FreezeButton = Instance.new("TextButton")
FreezeButton.Size = UDim2.new(0, 100, 0, 32)
FreezeButton.Position = UDim2.new(0, 8, 0.5, -16)
FreezeButton.BackgroundColor3 = Color3.fromRGB(40, 38, 50)
FreezeButton.Text = "Freeze  •  Off"
FreezeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FreezeButton.Font = Enum.Font.GothamMedium
FreezeButton.TextSize = 11
FreezeButton.Parent = BottomBar
Instance.new("UICorner", FreezeButton).CornerRadius = UDim.new(0, 8)

local SafetyShieldButton = Instance.new("TextButton")
SafetyShieldButton.Size = UDim2.new(0, 110, 0, 32)
SafetyShieldButton.Position = UDim2.new(0, 114, 0.5, -16)
SafetyShieldButton.BackgroundColor3 = Color3.fromRGB(30, 70, 110)
SafetyShieldButton.Text = "Shield  •  Off"
SafetyShieldButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SafetyShieldButton.Font = Enum.Font.GothamMedium
SafetyShieldButton.TextSize = 11
SafetyShieldButton.Parent = BottomBar
Instance.new("UICorner", SafetyShieldButton).CornerRadius = UDim.new(0, 8)

local SpeedModeButton = Instance.new("TextButton")
SpeedModeButton.Size = UDim2.new(0, 130, 0, 32)
SpeedModeButton.Position = UDim2.new(0, 230, 0.5, -16)
SpeedModeButton.BackgroundColor3 = Color3.fromRGB(45, 90, 140)
SpeedModeButton.Text = "Mode: Smooth"
SpeedModeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedModeButton.Font = Enum.Font.GothamMedium
SpeedModeButton.TextSize = 11
SpeedModeButton.Parent = BottomBar
Instance.new("UICorner", SpeedModeButton).CornerRadius = UDim.new(0, 8)

local FixedPosButton = Instance.new("TextButton")
FixedPosButton.Size = UDim2.new(0, 120, 0, 32)
FixedPosButton.Position = UDim2.new(0, 366, 0.5, -16)
FixedPosButton.BackgroundColor3 = Color3.fromRGB(40, 70, 110)
FixedPosButton.Text = "Fixed Pos  •  Off"
FixedPosButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FixedPosButton.Font = Enum.Font.GothamMedium
FixedPosButton.TextSize = 11
FixedPosButton.Parent = BottomBar
Instance.new("UICorner", FixedPosButton).CornerRadius = UDim.new(0, 8)

-- Credits button (left of Main)
local CreditsButton = Instance.new("TextButton")
CreditsButton.Name = "CreditsButton"
CreditsButton.Size = UDim2.new(0, 72, 0, 32)
CreditsButton.Position = UDim2.new(0, -80, 1, -52)
CreditsButton.BackgroundColor3 = Color3.fromRGB(35, 32, 48)
CreditsButton.Text = "Credits"
CreditsButton.TextColor3 = Color3.fromRGB(200, 185, 230)
CreditsButton.Font = Enum.Font.GothamMedium
CreditsButton.TextSize = 12
CreditsButton.Parent = Main
Instance.new("UICorner", CreditsButton).CornerRadius = UDim.new(0, 8)
local CreditsStroke = Instance.new("UIStroke", CreditsButton)
CreditsStroke.Color = Color3.fromRGB(70, 45, 95)
CreditsStroke.Thickness = 1.2
CreditsStroke.Transparency = 0.25

-- ==================== OFFSET PANEL (attached to the right of Main) ====================
Main.ClipsDescendants = false   -- important so the panel can stick out

local OffsetPanel = Instance.new("Frame")
OffsetPanel.Name = "OffsetPanel"
OffsetPanel.Size = UDim2.new(0, 78, 0, 310)
OffsetPanel.Position = UDim2.new(1, 8, 0, 45)   -- 8 pixels to the right of Main
OffsetPanel.BackgroundColor3 = Color3.fromRGB(14, 13, 18)
OffsetPanel.BorderSizePixel = 0
OffsetPanel.Visible = true
OffsetPanel.ZIndex = 50
OffsetPanel.Parent = Main
Instance.new("UICorner", OffsetPanel).CornerRadius = UDim.new(0, 10)

local OffsetStroke = Instance.new("UIStroke", OffsetPanel)
OffsetStroke.Color = Color3.fromRGB(70, 45, 95)
OffsetStroke.Thickness = 1.3
OffsetStroke.Transparency = 0.2

local OffsetTitle = Instance.new("TextLabel")
OffsetTitle.Size = UDim2.new(1, 0, 0, 22)
OffsetTitle.Position = UDim2.new(0, 0, 0, 4)
OffsetTitle.BackgroundTransparency = 1
OffsetTitle.Text = "OFFSET"
OffsetTitle.TextColor3 = Color3.fromRGB(180, 150, 220)
OffsetTitle.Font = Enum.Font.GothamBold
OffsetTitle.TextSize = 11
OffsetTitle.Parent = OffsetPanel

-- X Slider
local XLabel = Instance.new("TextLabel")
XLabel.Size = UDim2.new(1, 0, 0, 16)
XLabel.Position = UDim2.new(0, 0, 0, 28)
XLabel.BackgroundTransparency = 1
XLabel.Text = "X: 0"
XLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
XLabel.Font = Enum.Font.GothamMedium
XLabel.TextSize = 11
XLabel.Parent = OffsetPanel

local XSliderBg = Instance.new("Frame")
XSliderBg.Size = UDim2.new(0, 18, 0, 70)
XSliderBg.Position = UDim2.new(0.5, -9, 0, 48)
XSliderBg.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
XSliderBg.BorderSizePixel = 0
XSliderBg.Active = true
XSliderBg.Parent = OffsetPanel
Instance.new("UICorner", XSliderBg).CornerRadius = UDim.new(0, 6)

local XSliderFill = Instance.new("Frame")
XSliderFill.Size = UDim2.new(1, 0, 0.5, 0)
XSliderFill.Position = UDim2.new(0, 0, 0.5, 0)
XSliderFill.BackgroundColor3 = Color3.fromRGB(50, 120, 200)
XSliderFill.BorderSizePixel = 0
XSliderFill.Parent = XSliderBg
Instance.new("UICorner", XSliderFill).CornerRadius = UDim.new(0, 6)

local XKnob = Instance.new("TextButton")
XKnob.Size = UDim2.new(0, 22, 0, 14)
XKnob.Position = UDim2.new(0.5, -11, 0.5, -7)
XKnob.BackgroundColor3 = Color3.fromRGB(220, 220, 230)
XKnob.Text = ""
XKnob.Active = true
XKnob.Parent = XSliderBg
Instance.new("UICorner", XKnob).CornerRadius = UDim.new(0, 4)

-- Y Slider
local YLabel = Instance.new("TextLabel")
YLabel.Size = UDim2.new(1, 0, 0, 16)
YLabel.Position = UDim2.new(0, 0, 0, 128)
YLabel.BackgroundTransparency = 1
YLabel.Text = "Y: 0"
YLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
YLabel.Font = Enum.Font.GothamMedium
YLabel.TextSize = 11
YLabel.Parent = OffsetPanel

local YSliderBg = Instance.new("Frame")
YSliderBg.Size = UDim2.new(0, 18, 0, 70)
YSliderBg.Position = UDim2.new(0.5, -9, 0, 148)
YSliderBg.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
YSliderBg.BorderSizePixel = 0
YSliderBg.Active = true
YSliderBg.Parent = OffsetPanel
Instance.new("UICorner", YSliderBg).CornerRadius = UDim.new(0, 6)

local YSliderFill = Instance.new("Frame")
YSliderFill.Size = UDim2.new(1, 0, 0.5, 0)
YSliderFill.Position = UDim2.new(0, 0, 0.5, 0)
YSliderFill.BackgroundColor3 = Color3.fromRGB(50, 160, 100)
YSliderFill.BorderSizePixel = 0
YSliderFill.Parent = YSliderBg
Instance.new("UICorner", YSliderFill).CornerRadius = UDim.new(0, 6)

local YKnob = Instance.new("TextButton")
YKnob.Size = UDim2.new(0, 22, 0, 14)
YKnob.Position = UDim2.new(0.5, -11, 0.5, -7)
YKnob.BackgroundColor3 = Color3.fromRGB(220, 220, 230)
YKnob.Text = ""
YKnob.Active = true
YKnob.Parent = YSliderBg
Instance.new("UICorner", YKnob).CornerRadius = UDim.new(0, 4)

-- Z Slider
local ZLabel = Instance.new("TextLabel")
ZLabel.Size = UDim2.new(1, 0, 0, 16)
ZLabel.Position = UDim2.new(0, 0, 0, 228)
ZLabel.BackgroundTransparency = 1
ZLabel.Text = "Z: 0"
ZLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
ZLabel.Font = Enum.Font.GothamMedium
ZLabel.TextSize = 11
ZLabel.Parent = OffsetPanel

local ZSliderBg = Instance.new("Frame")
ZSliderBg.Size = UDim2.new(0, 18, 0, 70)
ZSliderBg.Position = UDim2.new(0.5, -9, 0, 248)
ZSliderBg.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
ZSliderBg.BorderSizePixel = 0
ZSliderBg.Active = true
ZSliderBg.Parent = OffsetPanel
Instance.new("UICorner", ZSliderBg).CornerRadius = UDim.new(0, 6)

local ZSliderFill = Instance.new("Frame")
ZSliderFill.Size = UDim2.new(1, 0, 0.5, 0)
ZSliderFill.Position = UDim2.new(0, 0, 0.5, 0)
ZSliderFill.BackgroundColor3 = Color3.fromRGB(180, 90, 50)
ZSliderFill.BorderSizePixel = 0
ZSliderFill.Parent = ZSliderBg
Instance.new("UICorner", ZSliderFill).CornerRadius = UDim.new(0, 6)

local ZKnob = Instance.new("TextButton")
ZKnob.Size = UDim2.new(0, 22, 0, 14)
ZKnob.Position = UDim2.new(0.5, -11, 0.5, -7)
ZKnob.BackgroundColor3 = Color3.fromRGB(220, 220, 230)
ZKnob.Text = ""
ZKnob.Active = true
ZKnob.Parent = ZSliderBg
Instance.new("UICorner", ZKnob).CornerRadius = UDim.new(0, 4)

-- Keep it stuck to the right side
local minimized = false
local originalSize = UDim2.new(0, 540, 0, 420)

local function updateOffsetPanelPos()
	OffsetPanel.Position = UDim2.new(1, 8, 0, 45)
	if not minimized then
		OffsetPanel.Visible = true
	end
end
updateOffsetPanelPos()

function setMinimized(state)
	minimized = state and true or false
	if minimized then
		TabFrame.Visible = false
		Content.Visible = false
		BottomBar.Visible = false
		OffsetPanel.Visible = false
		if RotPanel then RotPanel.Visible = false end
		if CreditsButton then CreditsButton.Visible = false end
		Main.ClipsDescendants = true
		Main.Size = UDim2.new(0, 540, 0, 38)
		MinimizeBtn.Text = "+"
	else
		Main.Size = originalSize
		Main.ClipsDescendants = false
		TabFrame.Visible = true
		Content.Visible = true
		BottomBar.Visible = true
		OffsetPanel.Visible = true
		OffsetPanel.Position = UDim2.new(1, 8, 0, 45)
		if RotPanel then
			RotPanel.Visible = true
			RotPanel.Position = UDim2.new(0, -86, 0, 45)
		end
		if CreditsButton then CreditsButton.Visible = true end
		MinimizeBtn.Text = "−"
	end
end

MinimizeBtn.MouseButton1Click:Connect(function()
	setMinimized(not minimized)
	playSound("12221967")
end)

-- ==================== ROTATION PANEL (left of Main) ====================
-- Global orient state (must exist BEFORE local ST is created so sliders work)
ORIENT = ORIENT or { pitch = 0, yaw = 0, roll = 0 }
ORIENT_SMOOTH = ORIENT_SMOOTH or { pitch = 0, yaw = 0, roll = 0 }
ORIENT_SMOOTH_SPEED = 10 -- higher = snappier, lower = silkier

RotPanel = Instance.new("Frame")
RotPanel.Name = "RotPanel"
RotPanel.Size = UDim2.new(0, 78, 0, 340)
RotPanel.Position = UDim2.new(0, -86, 0, 45)
RotPanel.BackgroundColor3 = Color3.fromRGB(14, 13, 18)
RotPanel.BorderSizePixel = 0
RotPanel.Visible = true
RotPanel.ZIndex = 50
RotPanel.Parent = Main
Instance.new("UICorner", RotPanel).CornerRadius = UDim.new(0, 10)
do
	local s = Instance.new("UIStroke", RotPanel)
	s.Color = Color3.fromRGB(70, 45, 95)
	s.Thickness = 1.3
	s.Transparency = 0.2
end
do
	local t = Instance.new("TextLabel")
	t.Size = UDim2.new(1, 0, 0, 22)
	t.Position = UDim2.new(0, 0, 0, 4)
	t.BackgroundTransparency = 1
	t.Text = "ROTATE"
	t.TextColor3 = Color3.fromRGB(180, 150, 220)
	t.Font = Enum.Font.GothamBold
	t.TextSize = 11
	t.Parent = RotPanel
end

local function makeOrientSlider(title, color, y0, getVal, setVal)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 16)
	label.Position = UDim2.new(0, 0, 0, y0)
	label.BackgroundTransparency = 1
	label.Text = title .. ": 0°"
	label.TextColor3 = Color3.fromRGB(200, 200, 210)
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 10
	label.Parent = RotPanel

	local bg = Instance.new("TextButton")
	bg.Size = UDim2.new(0, 18, 0, 70)
	bg.Position = UDim2.new(0.5, -9, 0, y0 + 18)
	bg.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
	bg.BorderSizePixel = 0
	bg.Text = ""
	bg.AutoButtonColor = false
	bg.Parent = RotPanel
	Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 6)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(1, 0, 0.5, 0)
	fill.Position = UDim2.new(0, 0, 0.5, 0)
	fill.BackgroundColor3 = color
	fill.BorderSizePixel = 0
	fill.Parent = bg
	Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 6)

	local knob = Instance.new("TextButton")
	knob.Size = UDim2.new(0, 22, 0, 14)
	knob.Position = UDim2.new(0.5, -11, 0.5, -7)
	knob.BackgroundColor3 = Color3.fromRGB(220, 220, 230)
	knob.Text = ""
	knob.AutoButtonColor = false
	knob.Parent = bg
	Instance.new("UICorner", knob).CornerRadius = UDim.new(0, 4)

	local dragging = false
	local function applyFromY(screenY)
		local relY = (screenY - bg.AbsolutePosition.Y) / math.max(1, bg.AbsoluteSize.Y)
		relY = math.clamp(relY, 0, 1)
		local deg = math.floor((0.5 - relY) * 180) -- +90 top, 0 mid, -90 bottom
		setVal(deg)
		label.Text = title .. ": " .. deg .. "°"
		knob.Position = UDim2.new(0.5, -11, relY, -7)
		fill.Size = UDim2.new(1, 0, 1 - relY, 0)
		fill.Position = UDim2.new(0, 0, relY, 0)
	end

	local function startDrag(input)
		dragging = true
		applyFromY(input.Position.Y)
	end

	bg.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			startDrag(input)
		end
	end)
	knob.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			startDrag(input)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			applyFromY(input.Position.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

makeOrientSlider("Pitch", Color3.fromRGB(200, 90, 90), 28,
	function() return ORIENT.pitch end,
	function(v)
		ORIENT.pitch = v
		if ST then ST.orientPitch = v end
	end)
makeOrientSlider("Yaw", Color3.fromRGB(90, 160, 200), 128,
	function() return ORIENT.yaw end,
	function(v)
		ORIENT.yaw = v
		if ST then ST.orientYaw = v end
	end)
makeOrientSlider("Roll", Color3.fromRGB(160, 120, 60), 228,
	function() return ORIENT.roll end,
	function(v)
		ORIENT.roll = v
		if ST then ST.orientRoll = v end
	end)

-- Reset rotations button
local ResetRotBtn = Instance.new("TextButton")
ResetRotBtn.Size = UDim2.new(1, -10, 0, 22)
ResetRotBtn.Position = UDim2.new(0, 5, 1, -28)
ResetRotBtn.BackgroundColor3 = Color3.fromRGB(140, 55, 70)
ResetRotBtn.Text = "Reset"
ResetRotBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ResetRotBtn.Font = Enum.Font.GothamBold
ResetRotBtn.TextSize = 11
ResetRotBtn.Parent = RotPanel
Instance.new("UICorner", ResetRotBtn).CornerRadius = UDim.new(0, 5)

-- Store knob/label refs for visual reset — re-apply mid position via shared helpers
local function resetOrientSlidersVisual()
	-- Fire apply at center (0°) for each by simulating mid; labels updated in set
	for _, child in ipairs(RotPanel:GetChildren()) do
		if child:IsA("TextLabel") and child.Text:find(":") then
			local name = child.Text:match("^(%w+):")
			if name == "Pitch" or name == "Yaw" or name == "Roll" then
				child.Text = name .. ": 0°"
			end
		end
	end
	-- Reset knob/fill positions on each slider track
	for _, child in ipairs(RotPanel:GetChildren()) do
		if child:IsA("TextButton") and child.Size.Y.Offset == 70 then
			local fill = child:FindFirstChildOfClass("Frame")
			local knob = nil
			for _, k in ipairs(child:GetChildren()) do
				if k:IsA("TextButton") then knob = k break end
			end
			if fill then
				fill.Size = UDim2.new(1, 0, 0.5, 0)
				fill.Position = UDim2.new(0, 0, 0.5, 0)
			end
			if knob then
				knob.Position = UDim2.new(0.5, -11, 0.5, -7)
			end
		end
	end
end

ResetRotBtn.MouseButton1Click:Connect(function()
	ORIENT.pitch = 0
	ORIENT.yaw = 0
	ORIENT.roll = 0
	if ORIENT_SMOOTH then
		ORIENT_SMOOTH.pitch = 0
		ORIENT_SMOOTH.yaw = 0
		ORIENT_SMOOTH.roll = 0
	end
	if ST then
		ST.orientPitch = 0
		ST.orientYaw = 0
		ST.orientRoll = 0
	end
	resetOrientSlidersVisual()
	playSound("12221967")
end)

-- ==================== PAGE BUTTONS ====================
local function makeBtn(parent, text, y, color)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -12, 0, 30)
	b.Position = UDim2.new(0, 6, 0, y)
	b.BackgroundColor3 = color
	b.Text = text
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.Font = Enum.Font.GothamMedium
	b.TextSize = 12
	b.AutoButtonColor = true
	b.Parent = parent
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
	local st = Instance.new("UIStroke", b)
	st.Color = Color3.fromRGB(255, 255, 255)
	st.Thickness = 1
	st.Transparency = 0.88
	return b
end

local function makeHalfBtn(parent, text, x, y, color)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 185, 0, 28)
	b.Position = UDim2.new(0, x, 0, y)
	b.BackgroundColor3 = color
	b.Text = text
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.Font = Enum.Font.GothamMedium
	b.TextSize = 12
	b.AutoButtonColor = true
	b.Parent = parent
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
	local st = Instance.new("UIStroke", b)
	st.Color = Color3.fromRGB(255, 255, 255)
	st.Thickness = 1
	st.Transparency = 0.88
	return b
end

local function makeLabel(parent, text, y)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, -12, 0, 18)
	l.Position = UDim2.new(0, 8, 0, y)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = Color3.fromRGB(170, 140, 210)
	l.Font = Enum.Font.GothamBold
	l.TextSize = 11
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = parent
	return l
end

-- LOCAL PAGE
makeLabel(LocalPage, "YOUR RING", 6)
local ToggleButton = makeBtn(LocalPage, "Your Ring  •  Off", 26, Color3.fromRGB(160, 40, 40))

makeLabel(LocalPage, "SHAPES", 66)
local LocalSphereButton = makeHalfBtn(LocalPage, "Triangle  •  Off", 8, 88, Color3.fromRGB(50, 50, 90))
local LocalSquareButton = makeHalfBtn(LocalPage, "Square  •  Off", 200, 88, Color3.fromRGB(65, 45, 100))
local LocalCubeButton = makeHalfBtn(LocalPage, "Cube  •  Off", 8, 122, Color3.fromRGB(40, 70, 100))
local LocalDownConeButton = makeHalfBtn(LocalPage, "Down Cone  •  Off", 200, 122, Color3.fromRGB(90, 45, 45))
local LocalBallButton = makeHalfBtn(LocalPage, "Sphere  •  Off", 8, 156, Color3.fromRGB(30, 90, 110))
local LocalHexButton = makeHalfBtn(LocalPage, "Hexagon  •  Off", 200, 156, Color3.fromRGB(80, 50, 120))
local LocalRectButton = makeHalfBtn(LocalPage, "Rectangle  •  Off", 8, 190, Color3.fromRGB(60, 80, 50))
local LocalBoxButton = makeHalfBtn(LocalPage, "Box  •  Off", 200, 190, Color3.fromRGB(90, 60, 40))
local LocalPyramidButton = makeHalfBtn(LocalPage, "Pyramid  •  Off", 8, 224, Color3.fromRGB(100, 70, 40))
local LocalConeButton = makeHalfBtn(LocalPage, "Cone  •  Off", 200, 224, Color3.fromRGB(70, 90, 50))
local LocalOctaButton = makeHalfBtn(LocalPage, "Octahedron  •  Off", 8, 258, Color3.fromRGB(50, 80, 100))
local LocalStarButton = makeHalfBtn(LocalPage, "Star  •  Off", 200, 258, Color3.fromRGB(140, 100, 30))
local LocalPentagonButton = makeHalfBtn(LocalPage, "Pentagon  •  Off", 8, 292, Color3.fromRGB(90, 60, 110))
local LocalOctagonButton = makeHalfBtn(LocalPage, "Octagon  •  Off", 200, 292, Color3.fromRGB(60, 90, 80))
local LocalDiamondButton = makeHalfBtn(LocalPage, "Diamond  •  Off", 8, 326, Color3.fromRGB(100, 50, 80))
local LocalCrossButton = makeHalfBtn(LocalPage, "Cross  •  Off", 200, 326, Color3.fromRGB(80, 80, 50))
local LocalHeartButton = makeHalfBtn(LocalPage, "Heart  •  Off", 8, 360, Color3.fromRGB(160, 40, 80))
local LocalDNAButton = makeHalfBtn(LocalPage, "DNA  •  Off", 200, 360, Color3.fromRGB(40, 120, 160))

local CursorButton = makeBtn(LocalPage, "Cursor Follow  •  Off", 400, Color3.fromRGB(160, 40, 40))

local RadiusFrame = Instance.new("Frame")
RadiusFrame.Size = UDim2.new(1, -12, 0, 42)
RadiusFrame.Position = UDim2.new(0, 6, 0, 440)
RadiusFrame.BackgroundColor3 = Color3.fromRGB(22, 20, 30)
RadiusFrame.BorderSizePixel = 0
RadiusFrame.Parent = LocalPage
Instance.new("UICorner", RadiusFrame).CornerRadius = UDim.new(0, 7)

local DecreaseRadius = Instance.new("TextButton")
DecreaseRadius.Size = UDim2.new(0, 34, 0, 24)
DecreaseRadius.Position = UDim2.new(0, 8, 0, 9)
DecreaseRadius.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
DecreaseRadius.Text = "−"
DecreaseRadius.TextColor3 = Color3.fromRGB(220, 220, 220)
DecreaseRadius.Font = Enum.Font.GothamBold
DecreaseRadius.TextSize = 16
DecreaseRadius.Parent = RadiusFrame
Instance.new("UICorner", DecreaseRadius).CornerRadius = UDim.new(0, 5)

local IncreaseRadius = Instance.new("TextButton")
IncreaseRadius.Size = UDim2.new(0, 34, 0, 24)
IncreaseRadius.Position = UDim2.new(1, -42, 0, 9)
IncreaseRadius.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
IncreaseRadius.Text = "+"
IncreaseRadius.TextColor3 = Color3.fromRGB(220, 220, 220)
IncreaseRadius.Font = Enum.Font.GothamBold
IncreaseRadius.TextSize = 16
IncreaseRadius.Parent = RadiusFrame
Instance.new("UICorner", IncreaseRadius).CornerRadius = UDim.new(0, 5)

local RadiusDisplay = Instance.new("TextLabel")
RadiusDisplay.Size = UDim2.new(0, 140, 0, 24)
RadiusDisplay.Position = UDim2.new(0.5, -70, 0, 9)
RadiusDisplay.BackgroundTransparency = 1
RadiusDisplay.Text = "Radius: 50"
RadiusDisplay.TextColor3 = Color3.fromRGB(230, 230, 230)
RadiusDisplay.Font = Enum.Font.GothamMedium
RadiusDisplay.TextSize = 13
RadiusDisplay.Parent = RadiusFrame

local LocalPartsLabel = Instance.new("TextLabel")
LocalPartsLabel.Size = UDim2.new(1, 0, 0, 14)
LocalPartsLabel.Position = UDim2.new(0, 0, 0, 490)
LocalPartsLabel.BackgroundTransparency = 1
LocalPartsLabel.Text = "Parts: 0"
LocalPartsLabel.TextColor3 = Color3.fromRGB(110, 190, 130)
LocalPartsLabel.Font = Enum.Font.Gotham
LocalPartsLabel.TextSize = 11
LocalPartsLabel.Parent = LocalPage
LocalPage.CanvasSize = UDim2.new(0, 0, 0, 540)

-- TARGET PAGE
makeLabel(TargetPage, "TARGET PLAYER", 6)
local NameBox = Instance.new("TextBox")
NameBox.Size = UDim2.new(1, -12, 0, 28)
NameBox.Position = UDim2.new(0, 6, 0, 26)
NameBox.BackgroundColor3 = Color3.fromRGB(22, 20, 30)
NameBox.Text = ""
NameBox.PlaceholderText = "Player name..."
NameBox.PlaceholderColor3 = Color3.fromRGB(90, 90, 100)
NameBox.TextColor3 = Color3.fromRGB(235, 235, 235)
NameBox.Font = Enum.Font.Gotham
NameBox.TextSize = 13
NameBox.ClearTextOnFocus = false
NameBox.Parent = TargetPage
Instance.new("UICorner", NameBox).CornerRadius = UDim.new(0, 6)

local PlayersListBtn = makeHalfBtn(TargetPage, "Players list  ▼", 8, 58, Color3.fromRGB(45, 70, 120))
local RefreshPlayersBtn = makeHalfBtn(TargetPage, "Refresh", 200, 58, Color3.fromRGB(50, 50, 60))

local PlayerListFrame = Instance.new("ScrollingFrame")
PlayerListFrame.Name = "PlayerList"
PlayerListFrame.Size = UDim2.new(1, -12, 0, 110)
PlayerListFrame.Position = UDim2.new(0, 6, 0, 90)
PlayerListFrame.BackgroundColor3 = Color3.fromRGB(18, 16, 24)
PlayerListFrame.BorderSizePixel = 0
PlayerListFrame.ScrollBarThickness = 4
PlayerListFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100)
PlayerListFrame.Visible = false
PlayerListFrame.ZIndex = 20
PlayerListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerListFrame.Parent = TargetPage
Instance.new("UICorner", PlayerListFrame).CornerRadius = UDim.new(0, 6)
local PlayerListLayout = Instance.new("UIListLayout")
PlayerListLayout.Padding = UDim.new(0, 4)
PlayerListLayout.SortOrder = Enum.SortOrder.LayoutOrder
PlayerListLayout.Parent = PlayerListFrame
local PlayerListPad = Instance.new("UIPadding")
PlayerListPad.PaddingTop = UDim.new(0, 4)
PlayerListPad.PaddingLeft = UDim.new(0, 4)
PlayerListPad.PaddingRight = UDim.new(0, 4)
PlayerListPad.Parent = PlayerListFrame

local TargetToggle = makeBtn(TargetPage, "Target Ring  •  Off", 90, Color3.fromRGB(160, 40, 40))
local AutoTargetBtn = makeBtn(TargetPage, "Auto nearest  •  Off", 124, Color3.fromRGB(50, 50, 60))
local MultiTargetBtn = makeHalfBtn(TargetPage, "Multi (0/3)  •  Off", 8, 158, Color3.fromRGB(50, 50, 60))
local SpectateBtn = makeHalfBtn(TargetPage, "Spectate  •  Off", 200, 158, Color3.fromRGB(50, 50, 60))

makeLabel(TargetPage, "TARGET SHAPES", 196)
local TargetSphereButton = makeHalfBtn(TargetPage, "Triangle  •  Off", 8, 218, Color3.fromRGB(50, 50, 90))
local TargetSquareButton = makeHalfBtn(TargetPage, "Square  •  Off", 200, 218, Color3.fromRGB(65, 45, 100))
local TargetCubeButton = makeHalfBtn(TargetPage, "Cube  •  Off", 8, 252, Color3.fromRGB(40, 70, 100))
local TargetDownConeButton = makeHalfBtn(TargetPage, "Down Cone  •  Off", 200, 252, Color3.fromRGB(90, 45, 45))
local TargetBallButton = makeHalfBtn(TargetPage, "Sphere  •  Off", 8, 286, Color3.fromRGB(30, 90, 110))
local TargetHexButton = makeHalfBtn(TargetPage, "Hexagon  •  Off", 200, 286, Color3.fromRGB(80, 50, 120))
local TargetRectButton = makeHalfBtn(TargetPage, "Rectangle  •  Off", 8, 320, Color3.fromRGB(60, 80, 50))
local TargetBoxButton = makeHalfBtn(TargetPage, "Box  •  Off", 200, 320, Color3.fromRGB(90, 60, 40))
local TargetPyramidButton = makeHalfBtn(TargetPage, "Pyramid  •  Off", 8, 354, Color3.fromRGB(100, 70, 40))
local TargetConeButton = makeHalfBtn(TargetPage, "Cone  •  Off", 200, 354, Color3.fromRGB(70, 90, 50))
local TargetOctaButton = makeHalfBtn(TargetPage, "Octahedron  •  Off", 8, 388, Color3.fromRGB(50, 80, 100))
local TargetStarButton = makeHalfBtn(TargetPage, "Star  •  Off", 200, 388, Color3.fromRGB(140, 100, 30))
local TargetPentagonButton = makeHalfBtn(TargetPage, "Pentagon  •  Off", 8, 422, Color3.fromRGB(90, 60, 110))
local TargetOctagonButton = makeHalfBtn(TargetPage, "Octagon  •  Off", 200, 422, Color3.fromRGB(60, 90, 80))
local TargetDiamondButton = makeHalfBtn(TargetPage, "Diamond  •  Off", 8, 456, Color3.fromRGB(100, 50, 80))
local TargetCrossButton = makeHalfBtn(TargetPage, "Cross  •  Off", 200, 456, Color3.fromRGB(80, 80, 50))

local TargetRadiusFrame = Instance.new("Frame")
TargetRadiusFrame.Size = UDim2.new(1, -12, 0, 42)
TargetRadiusFrame.Position = UDim2.new(0, 6, 0, 494)
TargetRadiusFrame.BackgroundColor3 = Color3.fromRGB(22, 20, 30)
TargetRadiusFrame.BorderSizePixel = 0
TargetRadiusFrame.Parent = TargetPage
Instance.new("UICorner", TargetRadiusFrame).CornerRadius = UDim.new(0, 7)

local TargetDecrease = Instance.new("TextButton")
TargetDecrease.Size = UDim2.new(0, 34, 0, 24)
TargetDecrease.Position = UDim2.new(0, 8, 0, 9)
TargetDecrease.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
TargetDecrease.Text = "−"
TargetDecrease.TextColor3 = Color3.fromRGB(220, 220, 220)
TargetDecrease.Font = Enum.Font.GothamBold
TargetDecrease.TextSize = 16
TargetDecrease.Parent = TargetRadiusFrame
Instance.new("UICorner", TargetDecrease).CornerRadius = UDim.new(0, 5)

local TargetIncrease = Instance.new("TextButton")
TargetIncrease.Size = UDim2.new(0, 34, 0, 24)
TargetIncrease.Position = UDim2.new(1, -42, 0, 9)
TargetIncrease.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
TargetIncrease.Text = "+"
TargetIncrease.TextColor3 = Color3.fromRGB(220, 220, 220)
TargetIncrease.Font = Enum.Font.GothamBold
TargetIncrease.TextSize = 16
TargetIncrease.Parent = TargetRadiusFrame
Instance.new("UICorner", TargetIncrease).CornerRadius = UDim.new(0, 5)

local TargetRadiusDisplay = Instance.new("TextLabel")
TargetRadiusDisplay.Size = UDim2.new(0, 140, 0, 24)
TargetRadiusDisplay.Position = UDim2.new(0.5, -70, 0, 9)
TargetRadiusDisplay.BackgroundTransparency = 1
TargetRadiusDisplay.Text = "Radius: 50"
TargetRadiusDisplay.TextColor3 = Color3.fromRGB(230, 230, 230)
TargetRadiusDisplay.Font = Enum.Font.GothamMedium
TargetRadiusDisplay.TextSize = 13
TargetRadiusDisplay.Parent = TargetRadiusFrame

local TargetPartsLabel = Instance.new("TextLabel")
TargetPartsLabel.Size = UDim2.new(1, 0, 0, 14)
TargetPartsLabel.Position = UDim2.new(0, 0, 0, 544)
TargetPartsLabel.BackgroundTransparency = 1
TargetPartsLabel.Text = "Parts: 0"
TargetPartsLabel.TextColor3 = Color3.fromRGB(200, 150, 90)
TargetPartsLabel.Font = Enum.Font.Gotham
TargetPartsLabel.TextSize = 11
TargetPartsLabel.Parent = TargetPage
TargetPage.CanvasSize = UDim2.new(0, 0, 0, 580)

-- TEXT PAGE
makeLabel(TextPage, "SUPER TEXT", 6)
local TextBox = Instance.new("TextBox")
TextBox.Size = UDim2.new(1, -12, 0, 28)
TextBox.Position = UDim2.new(0, 6, 0, 26)
TextBox.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
TextBox.Text = "GABS"
TextBox.PlaceholderText = "Type text..."
TextBox.PlaceholderColor3 = Color3.fromRGB(90, 90, 100)
TextBox.TextColor3 = Color3.fromRGB(235, 235, 235)
TextBox.Font = Enum.Font.Gotham
TextBox.TextSize = 13
TextBox.ClearTextOnFocus = false
TextBox.Parent = TextPage
Instance.new("UICorner", TextBox).CornerRadius = UDim.new(0, 6)

local TextToggle = makeBtn(TextPage, "Super Text  •  Off", 62, Color3.fromRGB(160, 40, 40))

local PixelFrame = Instance.new("Frame")
PixelFrame.Size = UDim2.new(1, -12, 0, 42)
PixelFrame.Position = UDim2.new(0, 6, 0, 100)
PixelFrame.BackgroundColor3 = Color3.fromRGB(22, 20, 30)
PixelFrame.BorderSizePixel = 0
PixelFrame.Parent = TextPage
Instance.new("UICorner", PixelFrame).CornerRadius = UDim.new(0, 7)

local DecreasePixel = Instance.new("TextButton")
DecreasePixel.Size = UDim2.new(0, 34, 0, 24)
DecreasePixel.Position = UDim2.new(0, 8, 0, 9)
DecreasePixel.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
DecreasePixel.Text = "−"
DecreasePixel.TextColor3 = Color3.fromRGB(220, 220, 220)
DecreasePixel.Font = Enum.Font.GothamBold
DecreasePixel.TextSize = 16
DecreasePixel.Parent = PixelFrame
Instance.new("UICorner", DecreasePixel).CornerRadius = UDim.new(0, 5)

local IncreasePixel = Instance.new("TextButton")
IncreasePixel.Size = UDim2.new(0, 34, 0, 24)
IncreasePixel.Position = UDim2.new(1, -42, 0, 9)
IncreasePixel.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
IncreasePixel.Text = "+"
IncreasePixel.TextColor3 = Color3.fromRGB(220, 220, 220)
IncreasePixel.Font = Enum.Font.GothamBold
IncreasePixel.TextSize = 16
IncreasePixel.Parent = PixelFrame
Instance.new("UICorner", IncreasePixel).CornerRadius = UDim.new(0, 5)

local PixelDisplay = Instance.new("TextLabel")
PixelDisplay.Size = UDim2.new(0, 140, 0, 24)
PixelDisplay.Position = UDim2.new(0.5, -70, 0, 9)
PixelDisplay.BackgroundTransparency = 1
PixelDisplay.Text = "Pixel Size: 4.5"
PixelDisplay.TextColor3 = Color3.fromRGB(230, 230, 230)
PixelDisplay.Font = Enum.Font.GothamMedium
PixelDisplay.TextSize = 13
PixelDisplay.Parent = PixelFrame
TextPage.CanvasSize = UDim2.new(0, 0, 0, 160)

-- ==================== 3D+ PAGE ====================
-- One compact, scrollable page keeps the extra UI well below the usual 200-instance
-- problem while still giving the 3D+ tab a large shape library.
makeLabel(ThreeDPlusPage, "3D+ SHAPE LIBRARY", 6)
ThreeDPlusInfo = Instance.new("TextLabel")
ThreeDPlusInfo.Size = UDim2.new(1, -12, 0, 30)
ThreeDPlusInfo.Position = UDim2.new(0, 6, 0, 24)
ThreeDPlusInfo.BackgroundTransparency = 1
ThreeDPlusInfo.Text = "Select one • 3D+ uses your Local ring parts"
ThreeDPlusInfo.TextColor3 = Color3.fromRGB(120, 160, 210)
ThreeDPlusInfo.Font = Enum.Font.Gotham
ThreeDPlusInfo.TextSize = 11
ThreeDPlusInfo.TextXAlignment = Enum.TextXAlignment.Left
ThreeDPlusInfo.Parent = ThreeDPlusPage

ThreeDPlusButtons = {}
ThreeDPlusShapeNames = {
	"Broken button(dont touch)", "Triangular Prism", "Pentagonal Prism", "Hexagonal Prism",
	"Octagonal Prism", "Decagonal Prism", "Dodecagonal Prism", "Cylinder",
	"Triangular Bipyramid", "Pentagonal Bipyramid", "Hexagonal Bipyramid", "Pentagonal Pyramid",
	"Hexagonal Pyramid", "Heptagonal Pyramid", "Octagonal Pyramid", "Icosahedron",
	"Dodecahedron", "Torus", "Helix", "Double Helix",
	"Spring", "Heart Prism", "Star Prism", "Hexagram Prism",
	"Arrow Prism", "Cross Prism 3D", "Capsule", "Hourglass",
	"Spherical Cage", "Geodesic Sphere"
}

for i, shapeName in ipairs(ThreeDPlusShapeNames) do
	local col = (i - 1) % 2
	local row = math.floor((i - 1) / 2)
	local b = makeHalfBtn(
		ThreeDPlusPage,
		shapeName .. "  •  Off",
		8 + col * 192,
		58 + row * 34,
		Color3.fromRGB(45 + ((i * 17) % 45), 55 + ((i * 11) % 45), 85 + ((i * 19) % 55))
	)
	ThreeDPlusButtons[shapeName] = b
end

ThreeDPlusStatus = Instance.new("TextLabel")
ThreeDPlusStatus.Size = UDim2.new(1, -12, 0, 18)
ThreeDPlusStatus.Position = UDim2.new(0, 8, 0, 58 + math.ceil(#ThreeDPlusShapeNames / 2) * 34 + 4)
ThreeDPlusStatus.BackgroundTransparency = 1
ThreeDPlusStatus.Text = "Selected: None"
ThreeDPlusStatus.TextColor3 = Color3.fromRGB(110, 190, 130)
ThreeDPlusStatus.Font = Enum.Font.Gotham
ThreeDPlusStatus.TextSize = 11
ThreeDPlusStatus.TextXAlignment = Enum.TextXAlignment.Left
ThreeDPlusStatus.Parent = ThreeDPlusPage
ThreeDPlusPage.CanvasSize = UDim2.new(0, 0, 0, 58 + math.ceil(#ThreeDPlusShapeNames / 2) * 34 + 35)

-- Dragging (also moves OffsetPanel)
local dragging, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = Main.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		updateOffsetPanelPos()
		if RotPanel then RotPanel.Position = UDim2.new(0, -86, 0, 45) end
	end
end)

-- ==================== LOGIC ====================
-- State packed into tables to stay under Luau's 200 local-register limit
local ST = {
	radius = 50,
	height = 100,
	rotationSpeed = 0.65,
	attractionStrength = 1100,
	ringPartsEnabled = false,
	freezeEnabled = false,
	smoothMode = true,
	shapeSpinSpeed = 0.20,
	fixedPosEnabled = false,
	fixedBasePosition = nil,
	fixedOffsetX = 0,
	fixedOffsetY = 0,
	fixedOffsetZ = 0,
	fixedMarker = nil,
	targetRadius = 50,
	targetRingEnabled = false,
	targetPlayer = nil,
	targetPlayers = {},
	autoTargetNearest = false,
	multiTargetEnabled = false,
	spectateEnabled = false,
	maxMultiTargets = 3,
	uiVisible = true,
	targetHeight = 100,
	targetRotationSpeed = 0.65,
	targetAttractionStrength = 1100,
	cursorRingEnabled = false,
	cursorOrbitRadius = 5.2,
	cursorRotationSpeed = 1.6,
	cursorAttraction = 420,
	maxCursorDistance = 200,
	minDistanceFromSelf = 10,
	textEnabled = false,
	textString = "GABS",
	textPixelSize = 4.5,
	textHeightOffset = 11,
	textFrontOffset = -17,
	textAttraction = 1300,
	localPartsCount = 0,
	targetPartsCount = 0,
	lastLocalTriCount = 30,
	lastTargetTriCount = 30,
	frozenAngle = 0,
	orientPitch = (ORIENT and ORIENT.pitch) or 0,
	orientYaw = (ORIENT and ORIENT.yaw) or 0,
	orientRoll = (ORIENT and ORIENT.roll) or 0,
}
threeDPlusShape = nil
local parts = {}
local mouse = LocalPlayer:GetMouse()

-- Local / target shape flags (table fields, not locals)
local LS = {
	sphere = false, square = false, cube = false, downcone = false, ball = false,
	hex = false, rect = false, box = false, pyramid = false, cone = false,
	octa = false, star = false, pentagon = false, octagon = false, diamond = false, cross = false,
	heart = false, dna = false,
}
local TS = {
	sphere = false, square = false, cube = false, downcone = false, ball = false,
	hex = false, rect = false, box = false, pyramid = false, cone = false,
	octa = false, star = false, pentagon = false, octagon = false, diamond = false, cross = false,
}

-- Compatibility aliases via metatable proxies would be slow; use explicit redirects below as locals that point into tables is NOT possible for booleans.
-- Instead we rewrite references. For minimal churn, bind short upvalues only where needed inside functions.


local Font = {
	[" "] = {"00000","00000","00000","00000","00000","00000","00000"},
	["A"] = {"01110","10001","10001","11111","10001","10001","10001"},
	["B"] = {"11110","10001","10001","11110","10001","10001","11110"},
	["C"] = {"01110","10001","10000","10000","10000","10001","01110"},
	["D"] = {"11110","10001","10001","10001","10001","10001","11110"},
	["E"] = {"11111","10000","10000","11110","10000","10000","11111"},
	["F"] = {"11111","10000","10000","11110","10000","10000","10000"},
	["G"] = {"01110","10001","10000","10111","10001","10001","01110"},
	["H"] = {"10001","10001","10001","11111","10001","10001","10001"},
	["I"] = {"01110","00100","00100","00100","00100","00100","01110"},
	["J"] = {"00111","00010","00010","00010","00010","10010","01100"},
	["K"] = {"10001","10010","10100","11000","10100","10010","10001"},
	["L"] = {"10000","10000","10000","10000","10000","10000","11111"},
	["M"] = {"10001","11011","10101","10001","10001","10001","10001"},
	["N"] = {"10001","11001","10101","10011","10001","10001","10001"},
	["O"] = {"01110","10001","10001","10001","10001","10001","01110"},
	["P"] = {"11110","10001","10001","11110","10000","10000","10000"},
	["Q"] = {"01110","10001","10001","10001","10101","10010","01101"},
	["R"] = {"11110","10001","10001","11110","10100","10010","10001"},
	["S"] = {"01111","10000","10000","01110","00001","00001","11110"},
	["T"] = {"11111","00100","00100","00100","00100","00100","00100"},
	["U"] = {"10001","10001","10001","10001","10001","10001","01110"},
	["V"] = {"10001","10001","10001","10001","10001","01010","00100"},
	["W"] = {"10001","10001","10001","10001","10101","11011","10001"},
	["X"] = {"10001","10001","01010","00100","01010","10001","10001"},
	["Y"] = {"10001","10001","01010","00100","00100","00100","00100"},
	["Z"] = {"11111","00001","00010","00100","01000","10000","11111"},
	["0"] = {"01110","10001","10011","10101","11001","10001","01110"},
	["1"] = {"00100","01100","00100","00100","00100","00100","01110"},
	["2"] = {"01110","10001","00001","00010","00100","01000","11111"},
	["3"] = {"01110","10001","00001","00110","00001","10001","01110"},
	["4"] = {"00010","00110","01010","10010","11111","00010","00010"},
	["5"] = {"11111","10000","11110","00001","00001","10001","01110"},
	["6"] = {"01110","10000","10000","11110","10001","10001","01110"},
	["7"] = {"11111","00001","00010","00100","01000","01000","01000"},
	["8"] = {"01110","10001","10001","01110","10001","10001","01110"},
	["9"] = {"01110","10001","10001","01111","00001","00001","01110"},
	["?"] = {"01110","10001","00001","00010","00100","00000","00100"},
	[","] = {"00000","00000","00000","00000","00100","00100","01000"},
	["."] = {"00000","00000","00000","00000","00000","01100","01100"},
	[":"] = {"00000","01100","01100","00000","01100","01100","00000"},
	[";"] = {"00000","01100","01100","00000","00100","00100","01000"},
	["+"] = {"00000","00100","00100","11111","00100","00100","00000"},
	["!"] = {"00100","00100","00100","00100","00100","00000","00100"},
	["-"] = {"00000","00000","00000","11111","00000","00000","00000"},
	["'"] = {"00100","00100","01000","00000","00000","00000","00000"},
	["\""] = {"01010","01010","10100","00000","00000","00000","00000"},
	["("] = {"00010","00100","01000","01000","01000","00100","00010"},
	[")"] = {"01000","00100","00010","00010","00010","00100","01000"},
	["/"] = {"00001","00010","00100","01000","10000","00000","00000"},
	["\\"] = {"10000","01000","00100","00010","00001","00000","00000"},
	["="] = {"00000","00000","11111","00000","11111","00000","00000"},
	["*"] = {"00000","00100","10101","01110","10101","00100","00000"},
	["🥖"] = {"0011111100","0111111110","1111111111","0111111110","0011111100"},
	["@"] = {"0011111100","0111111110","1111111111","0111111110","0011111100"},
	["❤️"] = {"01100110","11111111","11111111","01111110","00111100","00011000","00000000"},
	["❤"] = {"01100110","11111111","11111111","01111110","00111100","00011000","00000000"},
	["🔥"] = {"00010000","00111000","01111100","01111110","11111111","01111110","00111000"},
	["💀"] = {"01111110","11111111","11011011","11111111","01111110","00100100","00111100"},
	["😂"] = {"01111110","10000001","10100101","10000001","10111101","10000001","01111110"},
	["🍕"] = {"00010000","00111000","01111100","11111110","11111111","01111110","00111000"},
	["⭐"] = {"00010000","00111000","11111111","01111110","00111000","01010100","10000010"},
	["★"] = {"00010000","00111000","11111111","01111110","00111000","01010100","10000010"},
	["😎"] = {"01111110","10000001","11100111","10000001","10111101","10000001","01111110"},
	["👍"] = {"00110000","00110000","00111110","11111111","11111111","01111110","00111100"},
	["💯"] = {"10001001","10001001","10001001","11111001","10001001","10001001","10001111"},
	["✨"] = {"00010000","01010100","00111000","11111111","00111000","01010100","00010000"},
}

local function getTextPoints(str)
	str = tostring(str or "")
	local points = {}
	local cursorX = 0
	local gap = 1.5
	for _, code in utf8.codes(str) do
		local char = utf8.char(code)
		local rows = Font[char] or Font[string.upper(char)] or Font[" "]
		local h = #rows
		local w = #rows[1]
		for row = 1, h do
			local line = rows[row]
			for col = 1, #line do
				if string.sub(line, col, col) == "1" then
					table.insert(points, Vector3.new((cursorX + (col - 1)) * ST.textPixelSize, (h - row) * ST.textPixelSize, 0))
				end
			end
		end
		cursorX = cursorX + w + gap
	end
	if #points > 0 then
		local minX, maxX = math.huge, -math.huge
		for _, p in ipairs(points) do
			minX = math.min(minX, p.X)
			maxX = math.max(maxX, p.X)
		end
		local mid = (minX + maxX) / 2
		for i, p in ipairs(points) do
			points[i] = Vector3.new(p.X - mid, p.Y, 0)
		end
	end
	return points
end

local currentTextPoints = getTextPoints(ST.textString)
TextBox:GetPropertyChangedSignal("Text"):Connect(function()
	ST.textString = TextBox.Text
	currentTextPoints = getTextPoints(ST.textString)
end)

local function RetainPart(part)
	if part:IsA("BasePart") and not part.Anchored and part:IsDescendantOf(Workspace) then
		if part:IsDescendantOf(LocalPlayer.Character) then return false end
		part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
		part.CanCollide = false
		return true
	end
	return false
end

local function addPart(part)
	if RetainPart(part) and not table.find(parts, part) then
		table.insert(parts, part)
	end
end

local function removePart(part)
	local idx = table.find(parts, part)
	if idx then table.remove(parts, idx) end
end

for _, p in pairs(Workspace:GetDescendants()) do addPart(p) end
Workspace.DescendantAdded:Connect(addPart)
Workspace.DescendantRemoving:Connect(removePart)

local function anyShapeActive()
	return ST.textEnabled or ST.ringPartsEnabled or LS.sphere or LS.square or LS.cube or LS.downcone or LS.ball
		or LS.hex or LS.rect or LS.box or LS.pyramid or LS.cone or LS.octa or LS.star
		or LS.pentagon or LS.octagon or LS.diamond or LS.cross or LS.heart or LS.dna or threeDPlusShape ~= nil
		or ST.cursorRingEnabled or ST.targetRingEnabled or TS.sphere or TS.square or TS.cube or TS.downcone or TS.ball
		or TS.hex or TS.rect or TS.box or TS.pyramid or TS.cone or TS.octa or TS.star
		or TS.pentagon or TS.octagon or TS.diamond or TS.cross
end

RunService.Heartbeat:Connect(function()
	getgenv().Network.Active = not anyShapeActive()
end)

local function isLocalPart(index, total)
	if ST.cursorRingEnabled or ST.textEnabled then return true end
	if not ST.targetRingEnabled and not TS.sphere and not TS.square and not TS.cube and not TS.downcone and not TS.ball
		and not TS.hex and not TS.rect and not TS.box and not TS.pyramid and not TS.cone and not TS.octa and not TS.star
		and not TS.pentagon and not TS.octagon and not TS.diamond and not TS.cross then return true end
	if not ST.ringPartsEnabled and not LS.sphere and not LS.square and not LS.cube and not LS.downcone and not LS.ball
		and not LS.hex and not LS.rect and not LS.box and not LS.pyramid and not LS.cone and not LS.octa and not LS.star
		and not LS.pentagon and not LS.octagon and not LS.diamond and not LS.cross and not LS.heart and not LS.dna and threeDPlusShape == nil then return false end
	return index <= math.floor(total * 0.7)
end

local function applyVelocity(part, targetPos, strength)
	-- Aggressive retention: keep network ownership hints + stronger pull for shapes
	pcall(function()
		part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
		part.CanCollide = false
		part.Massless = true
	end)
	local dir = targetPos - part.Position
	local mag = dir.Magnitude
	if mag < 0.02 then
		part.Velocity = Vector3.zero
		pcall(function() part.AssemblyLinearVelocity = Vector3.zero end)
		return
	end
	local unit = dir.Unit
	if ST.smoothMode then
		-- stronger smooth pull so shapes hold better
		local speed = math.min(strength * 1.35, mag * 28)
		if mag > 0.15 then
			part.Velocity = unit * speed
			pcall(function() part.AssemblyLinearVelocity = unit * speed end)
		elseif mag > 0.04 then
			local s = mag * 16
			part.Velocity = unit * s
			pcall(function() part.AssemblyLinearVelocity = unit * s end)
		else
			part.Velocity = unit * (mag * 8)
		end
	else
		-- aggressive mode
		local speed = math.min(strength * 2.4, mag * 55)
		if mag > 0.08 then
			part.Velocity = unit * speed
			pcall(function() part.AssemblyLinearVelocity = unit * speed end)
		elseif mag > 0.03 then
			local s = mag * 30
			part.Velocity = unit * s
			pcall(function() part.AssemblyLinearVelocity = unit * s end)
		else
			part.Velocity = unit * (mag * 14)
		end
	end
end

function getCubeEdges(center, size, angle)
	local s = size / 2
	local cosA = math.cos(angle)
	local sinA = math.sin(angle)
	local function rotate(x, z) return x * cosA - z * sinA, x * sinA + z * cosA end
	local function makeVert(ox, oy, oz)
		local rx, rz = rotate(ox, oz)
		return Vector3.new(center.X + rx, center.Y + oy, center.Z + rz)
	end
	local v = {
		makeVert(-s,-s,-s), makeVert(s,-s,-s), makeVert(s,-s,s), makeVert(-s,-s,s),
		makeVert(-s,s,-s), makeVert(s,s,-s), makeVert(s,s,s), makeVert(-s,s,s)
	}
	return {
		{v[1],v[2]},{v[2],v[3]},{v[3],v[4]},{v[4],v[1]},
		{v[5],v[6]},{v[6],v[7]},{v[7],v[8]},{v[8],v[5]},
		{v[1],v[5]},{v[2],v[6]},{v[3],v[7]},{v[4],v[8]}
	}
end

function getHexEdges(center, radius, angle)
	local edges = {}
	for i = 0, 5 do
		local a1 = angle + (i / 6) * math.pi * 2
		local a2 = angle + ((i + 1) / 6) * math.pi * 2
		local p1 = Vector3.new(center.X + math.cos(a1) * radius, center.Y, center.Z + math.sin(a1) * radius)
		local p2 = Vector3.new(center.X + math.cos(a2) * radius, center.Y, center.Z + math.sin(a2) * radius)
		table.insert(edges, {p1, p2})
	end
	return edges
end

function getRectEdges(center, width, depth, angle)
	local hw, hd = width / 2, depth / 2
	local cosA = math.cos(angle)
	local sinA = math.sin(angle)
	local function rotate(x, z) return x * cosA - z * sinA, x * sinA + z * cosA end
	local function make(ox, oz)
		local rx, rz = rotate(ox, oz)
		return Vector3.new(center.X + rx, center.Y, center.Z + rz)
	end
	local v1 = make(-hw, -hd)
	local v2 = make( hw, -hd)
	local v3 = make( hw,  hd)
	local v4 = make(-hw,  hd)
	return {{v1,v2},{v2,v3},{v3,v4},{v4,v1}}
end

function getBoxEdges(center, sx, sy, sz, angle)
	local hx, hy, hz = sx / 2, sy / 2, sz / 2
	local cosA = math.cos(angle)
	local sinA = math.sin(angle)
	local function rotate(x, z) return x * cosA - z * sinA, x * sinA + z * cosA end
	local function make(ox, oy, oz)
		local rx, rz = rotate(ox, oz)
		return Vector3.new(center.X + rx, center.Y + oy, center.Z + rz)
	end
	local v = {
		make(-hx,-hy,-hz), make(hx,-hy,-hz), make(hx,-hy,hz), make(-hx,-hy,hz),
		make(-hx, hy,-hz), make(hx, hy,-hz), make(hx, hy,hz), make(-hx, hy,hz)
	}
	return {
		{v[1],v[2]},{v[2],v[3]},{v[3],v[4]},{v[4],v[1]},
		{v[5],v[6]},{v[6],v[7]},{v[7],v[8]},{v[8],v[5]},
		{v[1],v[5]},{v[2],v[6]},{v[3],v[7]},{v[4],v[8]}
	}
end

function getPyramidEdges(center, size, angle)
	local s = size / 2
	local h = size * 0.9
	local cosA = math.cos(angle)
	local sinA = math.sin(angle)
	local function rotate(x, z) return x * cosA - z * sinA, x * sinA + z * cosA end
	local function make(ox, oy, oz)
		local rx, rz = rotate(ox, oz)
		return Vector3.new(center.X + rx, center.Y + oy, center.Z + rz)
	end
	local base = {
		make(-s, -h*0.3, -s), make(s, -h*0.3, -s),
		make(s, -h*0.3, s), make(-s, -h*0.3, s)
	}
	local apex = make(0, h*0.7, 0)
	return {
		{base[1], base[2]}, {base[2], base[3]}, {base[3], base[4]}, {base[4], base[1]},
		{base[1], apex}, {base[2], apex}, {base[3], apex}, {base[4], apex}
	}
end

function getOctaEdges(center, size, angle)
	local s = size * 0.75
	local cosA = math.cos(angle)
	local sinA = math.sin(angle)
	local function rotate(x, z) return x * cosA - z * sinA, x * sinA + z * cosA end
	local function make(ox, oy, oz)
		local rx, rz = rotate(ox, oz)
		return Vector3.new(center.X + rx, center.Y + oy, center.Z + rz)
	end
	local top = make(0, s, 0)
	local bot = make(0, -s, 0)
	local eq = {
		make(s, 0, 0), make(0, 0, s),
		make(-s, 0, 0), make(0, 0, -s)
	}
	return {
		{top, eq[1]}, {top, eq[2]}, {top, eq[3]}, {top, eq[4]},
		{bot, eq[1]}, {bot, eq[2]}, {bot, eq[3]}, {bot, eq[4]},
		{eq[1], eq[2]}, {eq[2], eq[3]}, {eq[3], eq[4]}, {eq[4], eq[1]}
	}
end

function getStarEdges(center, radius, angle)
	local edges = {}
	local outer = radius
	local inner = radius * 0.4
	local points = {}
	for i = 0, 9 do
		local a = angle + (i / 10) * math.pi * 2 - math.pi / 2
		local r = (i % 2 == 0) and outer or inner
		table.insert(points, Vector3.new(center.X + math.cos(a) * r, center.Y, center.Z + math.sin(a) * r))
	end
	for i = 1, 10 do
		local next = (i % 10) + 1
		table.insert(edges, {points[i], points[next]})
	end
	return edges
end

function getConeEdges(center, radius, height, angle, upsideDown)
	local edges = {}
	local segments = 12
	local baseY = upsideDown and (center.Y + height * 0.4) or (center.Y - height * 0.4)
	local apexY = upsideDown and (center.Y - height * 0.5) or (center.Y + height * 0.5)
	local apex = Vector3.new(center.X, apexY, center.Z)
	local basePoints = {}
	for i = 0, segments - 1 do
		local a = angle + (i / segments) * math.pi * 2
		local p = Vector3.new(center.X + math.cos(a) * radius, baseY, center.Z + math.sin(a) * radius)
		table.insert(basePoints, p)
	end
	for i = 1, segments do
		local next = (i % segments) + 1
		table.insert(edges, {basePoints[i], basePoints[next]})
	end
	for i = 1, segments do
		table.insert(edges, {basePoints[i], apex})
	end
	return edges
end

function getPentagonEdges(center, radius, angle)
	local edges = {}
	for i = 0, 4 do
		local a1 = angle + (i / 5) * math.pi * 2 - math.pi / 2
		local a2 = angle + ((i + 1) / 5) * math.pi * 2 - math.pi / 2
		local p1 = Vector3.new(center.X + math.cos(a1) * radius, center.Y, center.Z + math.sin(a1) * radius)
		local p2 = Vector3.new(center.X + math.cos(a2) * radius, center.Y, center.Z + math.sin(a2) * radius)
		table.insert(edges, {p1, p2})
	end
	return edges
end

function getOctagonEdges(center, radius, angle)
	local edges = {}
	for i = 0, 7 do
		local a1 = angle + (i / 8) * math.pi * 2
		local a2 = angle + ((i + 1) / 8) * math.pi * 2
		local p1 = Vector3.new(center.X + math.cos(a1) * radius, center.Y, center.Z + math.sin(a1) * radius)
		local p2 = Vector3.new(center.X + math.cos(a2) * radius, center.Y, center.Z + math.sin(a2) * radius)
		table.insert(edges, {p1, p2})
	end
	return edges
end

function getDiamondEdges(center, radius, angle)
	local cosA = math.cos(angle)
	local sinA = math.sin(angle)
	local function rotate(x, z) return x * cosA - z * sinA, x * sinA + z * cosA end
	local function make(ox, oz)
		local rx, rz = rotate(ox, oz)
		return Vector3.new(center.X + rx, center.Y, center.Z + rz)
	end
	local v1 = make(0, -radius)
	local v2 = make(radius * 0.7, 0)
	local v3 = make(0, radius)
	local v4 = make(-radius * 0.7, 0)
	return {{v1,v2},{v2,v3},{v3,v4},{v4,v1}}
end

function getCrossEdges(center, radius, angle)
	local cosA = math.cos(angle)
	local sinA = math.sin(angle)
	local function rotate(x, z) return x * cosA - z * sinA, x * sinA + z * cosA end
	local function make(ox, oz)
		local rx, rz = rotate(ox, oz)
		return Vector3.new(center.X + rx, center.Y, center.Z + rz)
	end
	local t = radius * 0.25
	local s = radius
	return {
		{make(-t, -s), make(t, -s)}, {make(t, -s), make(t, -t)},
		{make(t, -t), make(s, -t)}, {make(s, -t), make(s, t)},
		{make(s, t), make(t, t)}, {make(t, t), make(t, s)},
		{make(t, s), make(-t, s)}, {make(-t, s), make(-t, t)},
		{make(-t, t), make(-s, t)}, {make(-s, t), make(-s, -t)},
		{make(-s, -t), make(-t, -t)}, {make(-t, -t), make(-t, -s)}
	}
end


-- Smooth orient toward slider targets every frame (kills rotation jitter)
RunService.Heartbeat:Connect(function(dt)
	if not ORIENT or not ORIENT_SMOOTH then return end
	local a = math.clamp((ORIENT_SMOOTH_SPEED or 10) * (dt or 0.016), 0, 1)
	ORIENT_SMOOTH.pitch = ORIENT_SMOOTH.pitch + (ORIENT.pitch - ORIENT_SMOOTH.pitch) * a
	ORIENT_SMOOTH.yaw   = ORIENT_SMOOTH.yaw   + (ORIENT.yaw   - ORIENT_SMOOTH.yaw)   * a
	ORIENT_SMOOTH.roll  = ORIENT_SMOOTH.roll  + (ORIENT.roll  - ORIENT_SMOOTH.roll)  * a
end)

-- Orient a point relative to center using SMOOTHED Pitch / Yaw / Roll
function orientPoint(center, worldPos)
	local rel = worldPos - center
	local op = (ORIENT_SMOOTH and ORIENT_SMOOTH.pitch) or (ORIENT and ORIENT.pitch) or 0
	local oy = (ORIENT_SMOOTH and ORIENT_SMOOTH.yaw) or (ORIENT and ORIENT.yaw) or 0
	local orr = (ORIENT_SMOOTH and ORIENT_SMOOTH.roll) or (ORIENT and ORIENT.roll) or 0
	local p = math.rad(op)
	local y = math.rad(oy)
	local r = math.rad(orr)
	-- Yaw (Y)
	local cosY, sinY = math.cos(y), math.sin(y)
	local x1 = rel.X * cosY + rel.Z * sinY
	local y1 = rel.Y
	local z1 = -rel.X * sinY + rel.Z * cosY
	-- Pitch (X)
	local cosP, sinP = math.cos(p), math.sin(p)
	local x2 = x1
	local y2 = y1 * cosP - z1 * sinP
	local z2 = y1 * sinP + z1 * cosP
	-- Roll (Z)
	local cosR, sinR = math.cos(r), math.sin(r)
	local x3 = x2 * cosR - y2 * sinR
	local y3 = x2 * sinR + y2 * cosR
	local z3 = z2
	return Vector3.new(center.X + x3, center.Y + y3, center.Z + z3)
end

function orientEdges(center, edges)
	if not edges or #edges == 0 then return edges end
	local op = (ORIENT_SMOOTH and ORIENT_SMOOTH.pitch) or (ORIENT and ORIENT.pitch) or 0
	local oy = (ORIENT_SMOOTH and ORIENT_SMOOTH.yaw) or (ORIENT and ORIENT.yaw) or 0
	local orr = (ORIENT_SMOOTH and ORIENT_SMOOTH.roll) or (ORIENT and ORIENT.roll) or 0
	-- still run while smoothing toward zero/nonzero so it eases
	if math.abs(op) < 0.05 and math.abs(oy) < 0.05 and math.abs(orr) < 0.05
		and (not ORIENT or (ORIENT.pitch == 0 and ORIENT.yaw == 0 and ORIENT.roll == 0)) then
		return edges
	end
	local out = table.create(#edges)
	for i, e in ipairs(edges) do
		out[i] = { orientPoint(center, e[1]), orientPoint(center, e[2]) }
	end
	return out
end

function orientPoints(center, points)
	if not points or #points == 0 then return points end
	local op = (ORIENT_SMOOTH and ORIENT_SMOOTH.pitch) or (ORIENT and ORIENT.pitch) or 0
	local oy = (ORIENT_SMOOTH and ORIENT_SMOOTH.yaw) or (ORIENT and ORIENT.yaw) or 0
	local orr = (ORIENT_SMOOTH and ORIENT_SMOOTH.roll) or (ORIENT and ORIENT.roll) or 0
	if math.abs(op) < 0.05 and math.abs(oy) < 0.05 and math.abs(orr) < 0.05
		and (not ORIENT or (ORIENT.pitch == 0 and ORIENT.yaw == 0 and ORIENT.roll == 0)) then
		return points
	end
	local out = table.create(#points)
	for i, p in ipairs(points) do
		out[i] = orientPoint(center, p)
	end
	return out
end

function getHeartEdges(center, radius, angle)
	local edges = {}
	local pts = {}
	local steps = 28
	local scale = radius / 16
	local cosA, sinA = math.cos(angle), math.sin(angle)
	for i = 0, steps do
		local t = (i / steps) * math.pi * 2
		local hx = 16 * (math.sin(t) ^ 3)
		local hy = 13 * math.cos(t) - 5 * math.cos(2 * t) - 2 * math.cos(3 * t) - math.cos(4 * t)
		local x, z = hx * scale, hy * scale
		local rx = x * cosA - z * sinA
		local rz = x * sinA + z * cosA
		table.insert(pts, Vector3.new(center.X + rx, center.Y, center.Z + rz))
	end
	for i = 1, #pts - 1 do
		table.insert(edges, {pts[i], pts[i + 1]})
	end
	if #pts > 1 then
		table.insert(edges, {pts[#pts], pts[1]})
	end
	return edges
end

function getDNAEdges(center, radius, angle)
	-- True-looking DNA: 2 backbone strands + base-pair rungs (not a single spring)
	local edges = {}
	local turns = 2.0          -- fewer turns = less "springy"
	local segments = 36
	local height = radius * 2.8
	local rad = radius * 0.72  -- wider helix so strands are distinct
	local rungEvery = 2        -- base pair every N segments

	local strandA = {}
	local strandB = {}
	for i = 0, segments do
		local t = i / segments
		local a = t * turns * math.pi * 2 + angle
		local yy = (t - 0.5) * height
		-- slight oval so strands read as ribbons
		local cx = math.cos(a) * rad
		local cz = math.sin(a) * rad
		table.insert(strandA, Vector3.new(center.X + cx, center.Y + yy, center.Z + cz))
		table.insert(strandB, Vector3.new(center.X - cx, center.Y + yy, center.Z - cz))
	end

	-- backbone A
	for i = 1, #strandA - 1 do
		table.insert(edges, {strandA[i], strandA[i + 1]})
	end
	-- backbone B
	for i = 1, #strandB - 1 do
		table.insert(edges, {strandB[i], strandB[i + 1]})
	end
	-- base-pair rungs (straight bars between strands)
	for i = 1, #strandA, rungEvery do
		table.insert(edges, {strandA[i], strandB[i]})
	end
	return edges
end

local function getSpherePoints(center, radius, angleOffset)
	local points = {}
	local numPoints = 72
	local goldenAngle = math.pi * (3 - math.sqrt(5))
	for i = 0, numPoints - 1 do
		local y = 1 - (i / (numPoints - 1)) * 2
		local radiusAtY = math.sqrt(1 - y * y)
		local theta = goldenAngle * i + angleOffset
		local x = math.cos(theta) * radiusAtY
		local z = math.sin(theta) * radiusAtY
		table.insert(points, center + Vector3.new(x, y, z) * radius)
	end
	return points
end

-- ==================== 3D+ GEOMETRY ====================
local Shape3D = {}
function Shape3D.rotate3DPoint(center, x, y, z, angle)
	local c = math.cos(angle)
	local s = math.sin(angle)
	return Vector3.new(center.X + x * c - z * s, center.Y + y, center.Z + x * s + z * c)
end

function Shape3D.addEdge(edges, a, b)
	if (a - b).Magnitude > 0.001 then
		table.insert(edges, {a, b})
	end
end

function Shape3D.getRegularPolygonPoints(center, radius, y, sides, angle)
	local pts = {}
	for i = 0, sides - 1 do
		local a = angle + (i / sides) * math.pi * 2 - math.pi / 2
		table.insert(pts, Vector3.new(center.X + math.cos(a) * radius, center.Y + y, center.Z + math.sin(a) * radius))
	end
	return pts
end

function Shape3D.getPrismEdges3D(center, radius, height, sides, angle)
	local edges = {}
	local top = Shape3D.getRegularPolygonPoints(center, radius, height * 0.5, sides, angle)
	local bottom = Shape3D.getRegularPolygonPoints(center, radius, -height * 0.5, sides, angle)
	for i = 1, sides do
		local n = (i % sides) + 1
		Shape3D.addEdge(edges, top[i], top[n])
		Shape3D.addEdge(edges, bottom[i], bottom[n])
		Shape3D.addEdge(edges, top[i], bottom[i])
	end
	return edges
end

function Shape3D.getPyramidEdges3D(center, radius, height, sides, angle)
	local edges = {}
	local base = Shape3D.getRegularPolygonPoints(center, radius, -height * 0.5, sides, angle)
	local apex = Vector3.new(center.X, center.Y + height * 0.5, center.Z)
	for i = 1, sides do
		local n = (i % sides) + 1
		Shape3D.addEdge(edges, base[i], base[n])
		Shape3D.addEdge(edges, base[i], apex)
	end
	return edges
end

function Shape3D.getBipyramidEdges3D(center, radius, height, sides, angle)
	local edges = {}
	local ring = Shape3D.getRegularPolygonPoints(center, radius, 0, sides, angle)
	local top = Vector3.new(center.X, center.Y + height * 0.5, center.Z)
	local bottom = Vector3.new(center.X, center.Y - height * 0.5, center.Z)
	for i = 1, sides do
		local n = (i % sides) + 1
		Shape3D.addEdge(edges, ring[i], ring[n])
		Shape3D.addEdge(edges, ring[i], top)
		Shape3D.addEdge(edges, ring[i], bottom)
	end
	return edges
end

function Shape3D.getTorusEdges3D(center, majorRadius, minorRadius, majorSegments, minorSegments, angle)
	local edges = {}
	local rings = {}
	for i = 0, majorSegments - 1 do
		local u = angle + (i / majorSegments) * math.pi * 2
		local ring = {}
		for j = 0, minorSegments - 1 do
			local v = (j / minorSegments) * math.pi * 2
			local radial = majorRadius + minorRadius * math.cos(v)
			local x = math.cos(u) * radial
			local y = math.sin(v) * minorRadius
			local z = math.sin(u) * radial
			table.insert(ring, center + Vector3.new(x, y, z))
		end
		table.insert(rings, ring)
	end
	for i = 1, majorSegments do
		local ni = (i % majorSegments) + 1
		for j = 1, minorSegments do
			local nj = (j % minorSegments) + 1
			Shape3D.addEdge(edges, rings[i][j], rings[ni][j])
			Shape3D.addEdge(edges, rings[i][j], rings[i][nj])
		end
	end
	return edges
end

function Shape3D.getHelixEdges3D(center, radius, height, turns, segments, angle, doubleHelix)
	local edges = {}
	local paths = doubleHelix and 2 or 1
	for strand = 0, paths - 1 do
		local previous = nil
		for i = 0, segments do
			local t = i / segments
			local a = angle + t * turns * math.pi * 2 + strand * math.pi
			local p = center + Vector3.new(math.cos(a) * radius, (t - 0.5) * height, math.sin(a) * radius)
			if previous then Shape3D.addEdge(edges, previous, p) end
			previous = p
		end
	end
	if doubleHelix then
		for i = 0, segments, 4 do
			local t = i / segments
			local a = angle + t * turns * math.pi * 2
			local p1 = center + Vector3.new(math.cos(a) * radius, (t - 0.5) * height, math.sin(a) * radius)
			local p2 = center + Vector3.new(math.cos(a + math.pi) * radius, (t - 0.5) * height, math.sin(a + math.pi) * radius)
			Shape3D.addEdge(edges, p1, p2)
		end
	end
	return edges
end

function Shape3D.getSpringEdges3D(center, radius, height, turns, segments, angle)
	local edges = {}
	local previous = nil
	for i = 0, segments do
		local t = i / segments
		local a = angle + t * turns * math.pi * 2
		local p = center + Vector3.new(math.cos(a) * radius, (t - 0.5) * height, math.sin(a) * radius)
		if previous then Shape3D.addEdge(edges, previous, p) end
		previous = p
	end
	local top = Shape3D.getRegularPolygonPoints(center, radius * 0.45, height * 0.5, 8, angle)
	local bottom = Shape3D.getRegularPolygonPoints(center, radius * 0.45, -height * 0.5, 8, angle)
	for i = 1, 8 do
		local n = (i % 8) + 1
		Shape3D.addEdge(edges, top[i], top[n])
		Shape3D.addEdge(edges, bottom[i], bottom[n])
	end
	return edges
end

function Shape3D.getHeartPrismEdges3D(center, scale, depth, angle)
	local edges = {}
	local front, back = {}, {}
	local points = 24
	for i = 0, points - 1 do
		local t = (i / points) * math.pi * 2
		local x = 16 * math.sin(t)^3
		local y = 13 * math.cos(t) - 5 * math.cos(2*t) - 2 * math.cos(3*t) - math.cos(4*t)
		local z = depth * 0.5
		front[i + 1] = Shape3D.rotate3DPoint(center, x * scale / 16, y * scale / 16, z, angle)
		back[i + 1] = Shape3D.rotate3DPoint(center, x * scale / 16, y * scale / 16, -z, angle)
	end
	for i = 1, points do
		local n = (i % points) + 1
		Shape3D.addEdge(edges, front[i], front[n])
		Shape3D.addEdge(edges, back[i], back[n])
		Shape3D.addEdge(edges, front[i], back[i])
	end
	return edges
end

function Shape3D.getStarPrismEdges3D(center, outerRadius, innerRadius, depth, points, angle)
	local edges = {}
	local count = points * 2
	local front, back = {}, {}
	for i = 0, count - 1 do
		local a = angle + (i / count) * math.pi * 2 - math.pi / 2
		local r = (i % 2 == 0) and outerRadius or innerRadius
		front[i + 1] = Vector3.new(center.X + math.cos(a) * r, center.Y + depth * 0.5, center.Z + math.sin(a) * r)
		back[i + 1] = Vector3.new(center.X + math.cos(a) * r, center.Y - depth * 0.5, center.Z + math.sin(a) * r)
	end
	for i = 1, count do
		local n = (i % count) + 1
		Shape3D.addEdge(edges, front[i], front[n])
		Shape3D.addEdge(edges, back[i], back[n])
		Shape3D.addEdge(edges, front[i], back[i])
	end
	return edges
end

function Shape3D.getArrowPrismEdges3D(center, size, depth, angle)
	local pts = {
		{-1.0, -0.35}, {0.0, -0.35}, {0.0, -0.75}, {1.25, 0.0},
		{0.0, 0.75}, {0.0, 0.35}, {-1.0, 0.35}
	}
	local edges = {}
	local front, back = {}, {}
	for i, p in ipairs(pts) do
		front[i] = Shape3D.rotate3DPoint(center, p[1] * size, p[2] * size, depth * 0.5, angle)
		back[i] = Shape3D.rotate3DPoint(center, p[1] * size, p[2] * size, -depth * 0.5, angle)
	end
	for i = 1, #pts do
		local n = (i % #pts) + 1
		Shape3D.addEdge(edges, front[i], front[n])
		Shape3D.addEdge(edges, back[i], back[n])
		Shape3D.addEdge(edges, front[i], back[i])
	end
	return edges
end

function Shape3D.getCrossPrismEdges3D(center, radius, depth, angle)
	local t = radius * 0.28
	local s = radius
	local pts = {
		{-t,-s},{t,-s},{t,-t},{s,-t},{s,t},{t,t},{t,s},{-t,s},
		{-t,t},{-s,t},{-s,-t},{-t,-t}
	}
	local edges = {}
	local front, back = {}, {}
	for i, p in ipairs(pts) do
		front[i] = Shape3D.rotate3DPoint(center, p[1], p[2], depth * 0.5, angle)
		back[i] = Shape3D.rotate3DPoint(center, p[1], p[2], -depth * 0.5, angle)
	end
	for i = 1, #pts do
		local n = (i % #pts) + 1
		Shape3D.addEdge(edges, front[i], front[n])
		Shape3D.addEdge(edges, back[i], back[n])
		Shape3D.addEdge(edges, front[i], back[i])
	end
	return edges
end

function Shape3D.getCapsuleEdges3D(center, radius, height, segments, angle)
	local edges = {}
	local rings = {}
	local ringCount = 7
	for k = 0, ringCount - 1 do
		local t = k / (ringCount - 1)
		local y = (t - 0.5) * height
		local rr = radius
		if t < 0.22 then
			local q = (t / 0.22) * math.pi * 0.5
			y = -height * 0.5 + math.sin(q) * radius
			rr = math.cos(q) * radius
		elseif t > 0.78 then
			local q = ((1 - t) / 0.22) * math.pi * 0.5
			y = height * 0.5 - math.sin(q) * radius
			rr = math.cos(q) * radius
		else
			y = -height * 0.5 + radius + (t - 0.22) / 0.56 * (height - 2 * radius)
		end
		local ring = Shape3D.getRegularPolygonPoints(center, math.max(rr, 0.08), y, segments, angle)
		table.insert(rings, ring)
	end
	for k = 1, #rings do
		local ring = rings[k]
		for j = 1, #ring do
			local n = (j % #ring) + 1
			Shape3D.addEdge(edges, ring[j], ring[n])
			if k < #rings then Shape3D.addEdge(edges, ring[j], rings[k + 1][j]) end
		end
	end
	return edges
end

function Shape3D.getHourglassEdges3D(center, radius, height, segments, angle)
	local edges = {}
	local rings = {}
	for k = 0, 6 do
		local t = k / 6
		local y = (t - 0.5) * height
		local rr = radius * (0.28 + 0.72 * math.abs(2 * t - 1)^0.65)
		table.insert(rings, Shape3D.getRegularPolygonPoints(center, rr, y, segments, angle))
	end
	for k = 1, #rings do
		for j = 1, segments do
			local n = (j % segments) + 1
			Shape3D.addEdge(edges, rings[k][j], rings[k][n])
			if k < #rings then Shape3D.addEdge(edges, rings[k][j], rings[k + 1][j]) end
		end
	end
	return edges
end

function Shape3D.getSphericalCageEdges3D(center, radius, angle)
	local edges = {}
	local rings = {5, 7, 9, 11}
	local ringPoints = {}
	for k, sides in ipairs(rings) do
		local t = k / (#rings + 1)
		local y = (0.5 - t) * radius * 1.7
		local rr = math.sqrt(math.max(0, radius * radius - y * y))
		ringPoints[k] = Shape3D.getRegularPolygonPoints(center, rr, y, sides, angle + k * 0.31)
	end
	for k = 1, #ringPoints do
		for j = 1, #ringPoints[k] do
			local n = (j % #ringPoints[k]) + 1
			Shape3D.addEdge(edges, ringPoints[k][j], ringPoints[k][n])
		end
		if k < #ringPoints then
			for j = 1, #ringPoints[k] do
				local a = ringPoints[k][j]
				local best, bestD = nil, math.huge
				for q = 1, #ringPoints[k + 1] do
					local d = (a - ringPoints[k + 1][q]).Magnitude
					if d < bestD then bestD, best = d, ringPoints[k + 1][q] end
				end
				if best then Shape3D.addEdge(edges, a, best) end
			end
		end
	end
	local top = Vector3.new(center.X, center.Y + radius, center.Z)
	local bottom = Vector3.new(center.X, center.Y - radius, center.Z)
	for _, p in ipairs(ringPoints[1]) do Shape3D.addEdge(edges, p, top) end
	for _, p in ipairs(ringPoints[#ringPoints]) do Shape3D.addEdge(edges, p, bottom) end
	return edges
end

function Shape3D.getPolyhedronEdgesFromVertices(center, vertices, angle)
	local pts = {}
	for _, v in ipairs(vertices) do
		table.insert(pts, Shape3D.rotate3DPoint(center, v[1], v[2], v[3], angle))
	end
	local distances = {}
	for i = 1, #pts do
		for j = i + 1, #pts do
			local d = (pts[i] - pts[j]).Magnitude
			if d > 0.001 then table.insert(distances, d) end
		end
	end
	table.sort(distances)
	local edgeLength = distances[1]
	-- Find a stable minimum non-zero length, then allow a tiny tolerance for float math.
	local tol = math.max(0.01, edgeLength * 0.08)
	local edges = {}
	for i = 1, #pts do
		for j = i + 1, #pts do
			local d = (pts[i] - pts[j]).Magnitude
			if math.abs(d - edgeLength) <= tol then Shape3D.addEdge(edges, pts[i], pts[j]) end
		end
	end
	return edges
end

function Shape3D.getIcosahedronEdges3D(center, size, angle)
	local phi = (1 + math.sqrt(5)) / 2
	local a = size * 0.55
	local b = a * phi
	local v = {}
	for _, x in ipairs({-a, a}) do for _, y in ipairs({-b, b}) do table.insert(v, {0, x, y}) end end
	for _, x in ipairs({-a, a}) do for _, y in ipairs({-b, b}) do table.insert(v, {x, y, 0}) end end
	for _, x in ipairs({-b, b}) do for _, y in ipairs({-a, a}) do table.insert(v, {x, 0, y}) end end
	return Shape3D.getPolyhedronEdgesFromVertices(center, v, angle)
end

function Shape3D.getDodecahedronEdges3D(center, size, angle)
	local phi = (1 + math.sqrt(5)) / 2
	local inv = 1 / phi
	local v = {}
	for _, x in ipairs({-1, 1}) do for _, y in ipairs({-1, 1}) do for _, z in ipairs({-1, 1}) do table.insert(v, {x * size * 0.42, y * size * 0.42, z * size * 0.42}) end end end
	for _, y in ipairs({-inv, inv}) do for _, z in ipairs({-phi, phi}) do table.insert(v, {0, y * size * 0.42, z * size * 0.42}) end end
	for _, x in ipairs({-inv, inv}) do for _, y in ipairs({-phi, phi}) do table.insert(v, {x * size * 0.42, y * size * 0.42, 0}) end end
	for _, x in ipairs({-phi, phi}) do for _, z in ipairs({-inv, inv}) do table.insert(v, {x * size * 0.42, 0, z * size * 0.42}) end end
	return Shape3D.getPolyhedronEdgesFromVertices(center, v, angle)
end

function Shape3D.getGeodesicSphereEdges3D(center, radius, angle)
	-- A lightweight geodesic-like cage built from several staggered latitude rings.
	local edges = {}
	local rings = 8
	local sides = 12
	local ringPts = {}
	for k = 1, rings do
		local t = (k - 1) / (rings - 1)
		local y = (1 - 2 * t) * radius
		local rr = math.sqrt(math.max(0, radius * radius - y * y))
		local count = (k == 1 or k == rings) and 1 or sides
		if count == 1 then
			ringPts[k] = {Vector3.new(center.X, center.Y + y, center.Z)}
		else
			ringPts[k] = Shape3D.getRegularPolygonPoints(center, rr, y, count, angle + k * 0.17)
		end
	end
	for k = 1, rings do
		local ring = ringPts[k]
		if #ring > 1 then
			for j = 1, #ring do Shape3D.addEdge(edges, ring[j], ring[(j % #ring) + 1]) end
		end
		if k < rings then
			local nextRing = ringPts[k + 1]
			for _, a in ipairs(ring) do
				local used = {}
				local nearest = {}
				for q = 1, #nextRing do table.insert(nearest, {q, (a - nextRing[q]).Magnitude}) end
				table.sort(nearest, function(p, q) return p[2] < q[2] end)
				for q = 1, math.min(2, #nearest) do
					local idx = nearest[q][1]
					if not used[idx] then used[idx] = true; Shape3D.addEdge(edges, a, nextRing[idx]) end
				end
			end
		end
	end
	return edges
end

function get3DPlusEdges(center, radiusValue, angle, shape)
	local r = radiusValue
	if shape == "Tetrahedron" then
		local s = r * 0.95
		local h = s * 0.82
		local v = {
			{-s, -h * 0.5, -s * 0.55}, {s, -h * 0.5, -s * 0.55},
			{0, -h * 0.5, s * 1.1}, {0, h * 0.75, 0}
		}
		return {{Shape3D.rotate3DPoint(center, table.unpack(v[1])), Shape3D.rotate3DPoint(center, table.unpack(v[2]))},
			{Shape3D.rotate3DPoint(center, table.unpack(v[2])), Shape3D.rotate3DPoint(center, table.unpack(v[3]))},
			{Shape3D.rotate3DPoint(center, table.unpack(v[3])), Shape3D.rotate3DPoint(center, table.unpack(v[1]))},
			{Shape3D.rotate3DPoint(center, table.unpack(v[1])), Shape3D.rotate3DPoint(center, table.unpack(v[4]))},
			{Shape3D.rotate3DPoint(center, table.unpack(v[2])), Shape3D.rotate3DPoint(center, table.unpack(v[4]))},
			{Shape3D.rotate3DPoint(center, table.unpack(v[3])), Shape3D.rotate3DPoint(center, table.unpack(v[4]))}}
	elseif shape == "Triangular Prism" then return Shape3D.getPrismEdges3D(center, r, r * 1.35, 3, angle)
	elseif shape == "Pentagonal Prism" then return Shape3D.getPrismEdges3D(center, r, r * 1.2, 5, angle)
	elseif shape == "Hexagonal Prism" then return Shape3D.getPrismEdges3D(center, r, r * 1.25, 6, angle)
	elseif shape == "Octagonal Prism" then return Shape3D.getPrismEdges3D(center, r, r * 1.2, 8, angle)
	elseif shape == "Decagonal Prism" then return Shape3D.getPrismEdges3D(center, r, r * 1.15, 10, angle)
	elseif shape == "Dodecagonal Prism" then return Shape3D.getPrismEdges3D(center, r, r * 1.1, 12, angle)
	elseif shape == "Cylinder" then return Shape3D.getPrismEdges3D(center, r, r * 1.6, 16, angle)
	elseif shape == "Triangular Bipyramid" then return Shape3D.getBipyramidEdges3D(center, r, r * 1.8, 3, angle)
	elseif shape == "Pentagonal Bipyramid" then return Shape3D.getBipyramidEdges3D(center, r, r * 1.8, 5, angle)
	elseif shape == "Hexagonal Bipyramid" then return Shape3D.getBipyramidEdges3D(center, r, r * 1.8, 6, angle)
	elseif shape == "Pentagonal Pyramid" then return Shape3D.getPyramidEdges3D(center, r, r * 1.7, 5, angle)
	elseif shape == "Hexagonal Pyramid" then return Shape3D.getPyramidEdges3D(center, r, r * 1.75, 6, angle)
	elseif shape == "Heptagonal Pyramid" then return Shape3D.getPyramidEdges3D(center, r, r * 1.8, 7, angle)
	elseif shape == "Octagonal Pyramid" then return Shape3D.getPyramidEdges3D(center, r, r * 1.85, 8, angle)
	elseif shape == "Icosahedron" then return Shape3D.getIcosahedronEdges3D(center, r * 1.15, angle)
	elseif shape == "Dodecahedron" then return Shape3D.getDodecahedronEdges3D(center, r * 1.35, angle)
	elseif shape == "Torus" then return Shape3D.getTorusEdges3D(center, r * 0.62, r * 0.24, 14, 7, angle)
	elseif shape == "Helix" then return Shape3D.getHelixEdges3D(center, r * 0.62, r * 2.2, 2.5, 72, angle, false)
	elseif shape == "Double Helix" then return Shape3D.getHelixEdges3D(center, r * 0.62, r * 2.2, 2.5, 72, angle, true)
	elseif shape == "Spring" then return Shape3D.getSpringEdges3D(center, r * 0.62, r * 2.2, 4.0, 96, angle)
	elseif shape == "Heart Prism" then return Shape3D.getHeartPrismEdges3D(center, r * 0.085, r * 0.72, angle)
	elseif shape == "Star Prism" then return Shape3D.getStarPrismEdges3D(center, r, r * 0.42, r * 0.75, 5, angle)
	elseif shape == "Hexagram Prism" then return Shape3D.getStarPrismEdges3D(center, r, r * 0.44, r * 0.75, 6, angle)
	elseif shape == "Arrow Prism" then return Shape3D.getArrowPrismEdges3D(center, r * 0.72, r * 0.8, angle)
	elseif shape == "Cross Prism 3D" then return Shape3D.getCrossPrismEdges3D(center, r, r * 0.7, angle)
	elseif shape == "Capsule" then return Shape3D.getCapsuleEdges3D(center, r * 0.55, r * 1.7, 12, angle)
	elseif shape == "Hourglass" then return Shape3D.getHourglassEdges3D(center, r, r * 1.9, 12, angle)
	elseif shape == "Spherical Cage" then return Shape3D.getSphericalCageEdges3D(center, r, angle)
	elseif shape == "Geodesic Sphere" then return Shape3D.getGeodesicSphereEdges3D(center, r, angle)
	end
	return {}
end

local function getOrbitCenter()
	if ST.fixedPosEnabled and ST.fixedBasePosition then
		return ST.fixedBasePosition + Vector3.new(ST.fixedOffsetX, ST.fixedOffsetY, ST.fixedOffsetZ)
	end
	local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	return hrp and hrp.Position or Vector3.zero
end

local function updateMarker()
	if ST.fixedMarker and ST.fixedMarker.Parent and ST.fixedBasePosition then
		ST.fixedMarker.Position = ST.fixedBasePosition + Vector3.new(ST.fixedOffsetX, ST.fixedOffsetY, ST.fixedOffsetZ)
	end
end

-- Slider logic (X / Y / Z)
local function setupVerticalSlider(knob, fill, bg, axis)
	local draggingSlider = false

	local function updateFromY(relY)
		relY = math.clamp(relY, 0, 1)
		local value = math.floor((0.5 - relY) * 200)
		if axis == "X" then
			ST.fixedOffsetX = value
			XLabel.Text = "X: " .. value
		elseif axis == "Y" then
			ST.fixedOffsetY = value
			YLabel.Text = "Y: " .. value
		else
			ST.fixedOffsetZ = value
			ZLabel.Text = "Z: " .. value
		end
		knob.Position = UDim2.new(0.5, -11, relY, -7)
		fill.Size = UDim2.new(1, 0, 1 - relY, 0)
		fill.Position = UDim2.new(0, 0, relY, 0)
		updateMarker()
	end

	local function updateFromInput(input)
		local absY = input.Position.Y
		local bgAbs = bg.AbsolutePosition.Y
		local bgH = bg.AbsoluteSize.Y
		if bgH <= 0 then return end
		updateFromY((absY - bgAbs) / bgH)
	end

	-- Clicking anywhere on the track immediately moves the slider.
	bg.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingSlider = true
			updateFromInput(input)
		end
	end)

	knob.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingSlider = true
			updateFromInput(input)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingSlider = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			updateFromInput(input)
		end
	end)

	-- Start exactly at zero.
	updateFromY(0.5)
end

setupVerticalSlider(XKnob, XSliderFill, XSliderBg, "X")
setupVerticalSlider(YKnob, YSliderFill, YSliderBg, "Y")
setupVerticalSlider(ZKnob, ZSliderFill, ZSliderBg, "Z")

-- LOCAL HEARTBEAT
RunService.Heartbeat:Connect(function()
	ST.localPartsCount = 0

	if ST.textEnabled then
		local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		local pts = currentTextPoints
		local count = #pts
		if count == 0 then LocalPartsLabel.Text = "Parts: 0" return end
		local baseCF = hrp.CFrame * CFrame.new(0, ST.textHeightOffset, ST.textFrontOffset)
		for i, part in ipairs(parts) do
			if part.Parent and not part.Anchored then
				local idx = ((i - 1) % count) + 1
				local localPos = pts[idx]
				local spread = 0.3
				local ox = ((i * 17) % 100) / 100 * spread - spread/2
				local oy = ((i * 31) % 100) / 100 * spread - spread/2
				local oz = ((i * 47) % 100) / 100 * spread - spread/2
				local targetPos = (baseCF * CFrame.new(localPos + Vector3.new(ox, oy, oz))).Position
				applyVelocity(part, targetPos, ST.textAttraction)
				ST.localPartsCount += 1
			end
		end
		LocalPartsLabel.Text = "Parts: " .. ST.localPartsCount
		return
	end

	if ST.cursorRingEnabled then
		local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		local mousePos = mouse.Hit.Position
		local center = mousePos
		local offset = center - hrp.Position
		if offset.Magnitude > ST.maxCursorDistance then
			center = hrp.Position + offset.Unit * ST.maxCursorDistance
		end
		local selfOffset = center - hrp.Position
		if selfOffset.Magnitude < ST.minDistanceFromSelf then
			center = hrp.Position + (selfOffset.Magnitude > 0.1 and selfOffset.Unit or Vector3.new(1,0,0)) * ST.minDistanceFromSelf
		end
		local baseAngle = tick() * ST.cursorRotationSpeed
		for i, part in ipairs(parts) do
			if part.Parent and not part.Anchored then
				local angle = baseAngle + i * 0.37
				local targetPos = Vector3.new(center.X + math.cos(angle) * ST.cursorOrbitRadius, center.Y + 1.2, center.Z + math.sin(angle) * ST.cursorOrbitRadius)
				applyVelocity(part, targetPos, ST.cursorAttraction)
				ST.localPartsCount += 1
			end
		end
		LocalPartsLabel.Text = "Parts: " .. ST.localPartsCount
		return
	end

	if not ST.ringPartsEnabled and not LS.sphere and not LS.square and not LS.cube and not LS.downcone and not LS.ball
		and not LS.hex and not LS.rect and not LS.box and not LS.pyramid and not LS.cone and not LS.octa and not LS.star
		and not LS.pentagon and not LS.octagon and not LS.diamond and not LS.cross and not LS.heart and not LS.dna and threeDPlusShape == nil then
		LocalPartsLabel.Text = "Parts: 0"
		return
	end

	local center = getOrbitCenter()
	local total = #parts
	local r = ST.radius
	local triCounter = 0

	local baseAngle = ST.freezeEnabled and ST.frozenAngle or (tick() * ST.rotationSpeed * 2)
	if not ST.freezeEnabled then ST.frozenAngle = baseAngle end
	local spinAngle = ST.freezeEnabled and ST.frozenAngle or (tick() * ST.shapeSpinSpeed)

	local a1, a2, a3 = baseAngle, baseAngle + 2.0944, baseAngle + 4.1888
	local p1 = Vector3.new(center.X + math.cos(a1)*r, center.Y, center.Z + math.sin(a1)*r)
	local p2 = Vector3.new(center.X + math.cos(a2)*r, center.Y, center.Z + math.sin(a2)*r)
	local p3 = Vector3.new(center.X + math.cos(a3)*r, center.Y, center.Z + math.sin(a3)*r)
	local triEdges = orientEdges(center, {{p1,p2},{p2,p3},{p3,p1}})

	local s1,s2,s3,s4 = baseAngle, baseAngle+1.5708, baseAngle+3.1416, baseAngle+4.7124
	local sp1 = Vector3.new(center.X + math.cos(s1)*r, center.Y, center.Z + math.sin(s1)*r)
	local sp2 = Vector3.new(center.X + math.cos(s2)*r, center.Y, center.Z + math.sin(s2)*r)
	local sp3 = Vector3.new(center.X + math.cos(s3)*r, center.Y, center.Z + math.sin(s3)*r)
	local sp4 = Vector3.new(center.X + math.cos(s4)*r, center.Y, center.Z + math.sin(s4)*r)
	local squareEdges = orientEdges(center, {{sp1,sp2},{sp2,sp3},{sp3,sp4},{sp4,sp1}})

	local cubeEdges = orientEdges(center, getCubeEdges(center, r * 1.8, spinAngle))
	local hexEdges = orientEdges(center, getHexEdges(center, r, spinAngle))
	local rectEdges = orientEdges(center, getRectEdges(center, r * 2.2, r * 1.1, spinAngle))
	local boxEdges = orientEdges(center, getBoxEdges(center, r * 2.4, r * 1.2, r * 1.4, spinAngle))
	local pyramidEdges = orientEdges(center, getPyramidEdges(center, r * 1.9, spinAngle))
	local coneEdges = orientEdges(center, getConeEdges(center, r * 0.95, r * 1.6, spinAngle, false))
	local downConeEdges = orientEdges(center, getConeEdges(center, r * 0.95, r * 1.6, spinAngle, true))
	local octaEdges = orientEdges(center, getOctaEdges(center, r * 1.5, spinAngle))
	local starEdges = orientEdges(center, getStarEdges(center, r, spinAngle))
	local pentagonEdges = orientEdges(center, getPentagonEdges(center, r, spinAngle))
	local octagonEdges = orientEdges(center, getOctagonEdges(center, r, spinAngle))
	local diamondEdges = orientEdges(center, getDiamondEdges(center, r, spinAngle))
	local crossEdges = orientEdges(center, getCrossEdges(center, r, spinAngle))
	local heartEdges = LS.heart and orientEdges(center, getHeartEdges(center, r, spinAngle)) or {}
	local dnaEdges = LS.dna and orientEdges(center, getDNAEdges(center, r, spinAngle)) or {}
	local threeDPlusEdges = threeDPlusShape and orientEdges(center, get3DPlusEdges(center, r, spinAngle, threeDPlusShape)) or {}
	local spherePoints = LS.ball and orientPoints(center, getSpherePoints(center, r * 0.95, spinAngle)) or {}

	for i, part in ipairs(parts) do
		if part.Parent and not part.Anchored and isLocalPart(i, total) then
			triCounter += 1
			local targetPos

			if threeDPlusShape and #threeDPlusEdges > 0 then
				local edgeIndex = ((triCounter - 1) % #threeDPlusEdges) + 1
				local partsPerEdge = math.max(1, math.floor(ST.lastLocalTriCount / #threeDPlusEdges))
				local idxOnEdge = math.floor((triCounter - 1) / #threeDPlusEdges)
				local t = (idxOnEdge % partsPerEdge) / partsPerEdge
				targetPos = threeDPlusEdges[edgeIndex][1]:Lerp(threeDPlusEdges[edgeIndex][2], t)
			elseif LS.ball then
				local idx = ((triCounter - 1) % #spherePoints) + 1
				targetPos = spherePoints[idx]
			elseif LS.downcone then
				local edgeIndex = ((triCounter - 1) % #downConeEdges) + 1
				local partsPerEdge = math.max(1, math.floor(ST.lastLocalTriCount / #downConeEdges))
				local idxOnEdge = math.floor((triCounter - 1) / #downConeEdges)
				local t = (idxOnEdge % partsPerEdge) / partsPerEdge
				targetPos = downConeEdges[edgeIndex][1]:Lerp(downConeEdges[edgeIndex][2], t)
			elseif LS.cone then
				local edgeIndex = ((triCounter - 1) % #coneEdges) + 1
				local partsPerEdge = math.max(1, math.floor(ST.lastLocalTriCount / #coneEdges))
				local idxOnEdge = math.floor((triCounter - 1) / #coneEdges)
				local t = (idxOnEdge % partsPerEdge) / partsPerEdge
				targetPos = coneEdges[edgeIndex][1]:Lerp(coneEdges[edgeIndex][2], t)
			elseif LS.cross then
				local edgeIndex = ((triCounter - 1) % #crossEdges) + 1
				local partsPerEdge = math.max(1, math.floor(ST.lastLocalTriCount / #crossEdges))
				local idxOnEdge = math.floor((triCounter - 1) / #crossEdges)
				local t = (idxOnEdge % partsPerEdge) / partsPerEdge
				targetPos = crossEdges[edgeIndex][1]:Lerp(crossEdges[edgeIndex][2], t)
			elseif LS.heart then
				if #heartEdges > 0 then
					local edgeIndex = ((triCounter - 1) % #heartEdges) + 1
					local partsPerEdge = math.max(1, math.floor(ST.lastLocalTriCount / #heartEdges))
					local idxOnEdge = math.floor((triCounter - 1) / #heartEdges)
					local t = (idxOnEdge % partsPerEdge) / partsPerEdge
					targetPos = heartEdges[edgeIndex][1]:Lerp(heartEdges[edgeIndex][2], t)
				else
					targetPos = center
				end
			elseif LS.dna then
				if #dnaEdges > 0 then
					local edgeIndex = ((triCounter - 1) % #dnaEdges) + 1
					local partsPerEdge = math.max(1, math.floor(ST.lastLocalTriCount / #dnaEdges))
					local idxOnEdge = math.floor((triCounter - 1) / #dnaEdges)
					local t = (idxOnEdge % partsPerEdge) / partsPerEdge
					targetPos = dnaEdges[edgeIndex][1]:Lerp(dnaEdges[edgeIndex][2], t)
				else
					targetPos = center
				end
			elseif LS.diamond then
				local edgeIndex = ((triCounter - 1) % 4) + 1
				local partsPerEdge = math.max(1, math.floor(ST.lastLocalTriCount / 4))
				local idxOnEdge = math.floor((triCounter - 1) / 4)
				local t = (idxOnEdge % partsPerEdge) / partsPerEdge
				targetPos = diamondEdges[edgeIndex][1]:Lerp(diamondEdges[edgeIndex][2], t)
			elseif LS.octagon then
				local edgeIndex = ((triCounter - 1) % 8) + 1
				local partsPerEdge = math.max(1, math.floor(ST.lastLocalTriCount / 8))
				local idxOnEdge = math.floor((triCounter - 1) / 8)
				local t = (idxOnEdge % partsPerEdge) / partsPerEdge
				targetPos = octagonEdges[edgeIndex][1]:Lerp(octagonEdges[edgeIndex][2], t)
			elseif LS.pentagon then
				local edgeIndex = ((triCounter - 1) % 5) + 1
				local partsPerEdge = math.max(1, math.floor(ST.lastLocalTriCount / 5))
				local idxOnEdge = math.floor((triCounter - 1) / 5)
				local t = (idxOnEdge % partsPerEdge) / partsPerEdge
				targetPos = pentagonEdges[edgeIndex][1]:Lerp(pentagonEdges[edgeIndex][2], t)
			elseif LS.star then
				local edgeIndex = ((triCounter - 1) % 10) + 1
				local partsPerEdge = math.max(1, math.floor(ST.lastLocalTriCount / 10))
				local idxOnEdge = math.floor((triCounter - 1) / 10)
				local t = (idxOnEdge % partsPerEdge) / partsPerEdge
				targetPos = starEdges[edgeIndex][1]:Lerp(starEdges[edgeIndex][2], t)
			elseif LS.octa then
				local edgeIndex = ((triCounter - 1) % 12) + 1
				local partsPerEdge = math.max(1, math.floor(ST.lastLocalTriCount / 12))
				local idxOnEdge = math.floor((triCounter - 1) / 12)
				local t = (idxOnEdge % partsPerEdge) / partsPerEdge
				targetPos = octaEdges[edgeIndex][1]:Lerp(octaEdges[edgeIndex][2], t)
			elseif LS.pyramid then
				local edgeIndex = ((triCounter - 1) % 8) + 1
				local partsPerEdge = math.max(1, math.floor(ST.lastLocalTriCount / 8))
				local idxOnEdge = math.floor((triCounter - 1) / 8)
				local t = (idxOnEdge % partsPerEdge) / partsPerEdge
				targetPos = pyramidEdges[edgeIndex][1]:Lerp(pyramidEdges[edgeIndex][2], t)
			elseif LS.box then
				local edgeIndex = ((triCounter - 1) % 12) + 1
				local partsPerEdge = math.max(1, math.floor(ST.lastLocalTriCount / 12))
				local idxOnEdge = math.floor((triCounter - 1) / 12)
				local t = (idxOnEdge % partsPerEdge) / partsPerEdge
				targetPos = boxEdges[edgeIndex][1]:Lerp(boxEdges[edgeIndex][2], t)
			elseif LS.hex then
				local edgeIndex = ((triCounter - 1) % 6) + 1
				local partsPerEdge = math.max(1, math.floor(ST.lastLocalTriCount / 6))
				local idxOnEdge = math.floor((triCounter - 1) / 6)
				local t = (idxOnEdge % partsPerEdge) / partsPerEdge
				targetPos = hexEdges[edgeIndex][1]:Lerp(hexEdges[edgeIndex][2], t)
			elseif LS.rect then
				local edgeIndex = ((triCounter - 1) % 4) + 1
				local partsPerEdge = math.max(1, math.floor(ST.lastLocalTriCount / 4))
				local idxOnEdge = math.floor((triCounter - 1) / 4)
				local t = (idxOnEdge % partsPerEdge) / partsPerEdge
				targetPos = rectEdges[edgeIndex][1]:Lerp(rectEdges[edgeIndex][2], t)
			elseif LS.cube then
				local edgeIndex = ((triCounter - 1) % 12) + 1
				local partsPerEdge = math.max(1, math.floor(ST.lastLocalTriCount / 12))
				local idxOnEdge = math.floor((triCounter - 1) / 12)
				local t = (idxOnEdge % partsPerEdge) / partsPerEdge
				targetPos = cubeEdges[edgeIndex][1]:Lerp(cubeEdges[edgeIndex][2], t)
			elseif LS.sphere then
				local edgeIndex = ((triCounter-1) % 3) + 1
				local partsPerEdge = math.max(1, math.floor(ST.lastLocalTriCount / 3))
				local idxOnEdge = math.floor((triCounter-1) / 3)
				local t = (idxOnEdge % partsPerEdge) / partsPerEdge
				targetPos = triEdges[edgeIndex][1]:Lerp(triEdges[edgeIndex][2], t)
			elseif LS.square then
				local edgeIndex = ((triCounter-1) % 4) + 1
				local partsPerEdge = math.max(1, math.floor(ST.lastLocalTriCount / 4))
				local idxOnEdge = math.floor((triCounter-1) / 4)
				local t = (idxOnEdge % partsPerEdge) / partsPerEdge
				targetPos = squareEdges[edgeIndex][1]:Lerp(squareEdges[edgeIndex][2], t)
			else
				-- YOUR RING (original): no rotation-panel orient — shapes only
				local pos = part.Position
				local angle = math.atan2(pos.Z - center.Z, pos.X - center.X)
				local newAngle = ST.freezeEnabled and angle or (angle + math.rad(ST.rotationSpeed))
				local dist = (Vector3.new(pos.X, center.Y, pos.Z) - center).Magnitude
				targetPos = Vector3.new(
					center.X + math.cos(newAngle) * math.min(r, dist),
					center.Y + (ST.height * math.abs(math.sin((pos.Y - center.Y)/ST.height))),
					center.Z + math.sin(newAngle) * math.min(r, dist)
				)
			end

			if not LS.sphere and not LS.square and not LS.cube and not LS.downcone and not LS.ball
				and not LS.hex and not LS.rect and not LS.box and not LS.pyramid and not LS.cone and not LS.octa and not LS.star
				and not LS.pentagon and not LS.octagon and not LS.diamond and not LS.cross and not LS.heart and not LS.dna and threeDPlusShape == nil then
				local dir = targetPos - part.Position
				if dir.Magnitude > 0.01 then
					part.Velocity = dir.Unit * ST.attractionStrength
				end
			else
				applyVelocity(part, targetPos, ST.attractionStrength)
			end

			ST.localPartsCount += 1
		end
	end
	ST.lastLocalTriCount = math.max(3, ST.localPartsCount)
	LocalPartsLabel.Text = "Parts: " .. ST.localPartsCount
end)

-- TARGET HEARTBEAT
RunService.Heartbeat:Connect(function()
	ST.targetPartsCount = 0
	if ST.cursorRingEnabled or ST.textEnabled then return end
	if not isTargetModeOn() then
		TargetPartsLabel.Text = "Parts: 0"
		return
	end

	-- Auto-target nearest
	if ST.autoTargetNearest then
		local nearest = findNearestPlayer()
		if nearest then
			if ST.multiTargetEnabled then
				if #ST.targetPlayers == 0 then addToMultiTarget(nearest) end
				-- keep nearest as primary
				if ST.targetPlayers[1] ~= nearest then
					for i, p in ipairs(ST.targetPlayers) do
						if p == nearest then table.remove(ST.targetPlayers, i) break end
					end
					table.insert(ST.targetPlayers, 1, nearest)
					syncPrimaryTarget()
				end
			else
				setSingleTarget(nearest)
			end
			updateMultiBtn()
		end
	end

	local activeRoots = getActiveTargetRoots()
	if #activeRoots == 0 then
		TargetPartsLabel.Text = "Parts: 0 (no target / respawning)"
		return
	end

	local total = #parts
	local r = ST.targetRadius
	local triCounter = 0
	-- Primary center for shape edge generation (first target)
	local char = activeRoots[1].char
	local hrp = activeRoots[1].root
	local center = activeRoots[1].center

	local baseAngle = ST.freezeEnabled and ST.frozenAngle or (tick() * ST.targetRotationSpeed * 2)
	if not ST.freezeEnabled then ST.frozenAngle = baseAngle end
	local spinAngle = ST.freezeEnabled and ST.frozenAngle or (tick() * ST.shapeSpinSpeed)

	local a1,a2,a3 = baseAngle, baseAngle+2.0944, baseAngle+4.1888
	local p1 = Vector3.new(center.X+math.cos(a1)*r, center.Y, center.Z+math.sin(a1)*r)
	local p2 = Vector3.new(center.X+math.cos(a2)*r, center.Y, center.Z+math.sin(a2)*r)
	local p3 = Vector3.new(center.X+math.cos(a3)*r, center.Y, center.Z+math.sin(a3)*r)
	local triEdges = orientEdges(center, {{p1,p2},{p2,p3},{p3,p1}})

	local s1,s2,s3,s4 = baseAngle, baseAngle+1.5708, baseAngle+3.1416, baseAngle+4.7124
	local sp1 = Vector3.new(center.X+math.cos(s1)*r, center.Y, center.Z+math.sin(s1)*r)
	local sp2 = Vector3.new(center.X+math.cos(s2)*r, center.Y, center.Z+math.sin(s2)*r)
	local sp3 = Vector3.new(center.X+math.cos(s3)*r, center.Y, center.Z+math.sin(s3)*r)
	local sp4 = Vector3.new(center.X+math.cos(s4)*r, center.Y, center.Z+math.sin(s4)*r)
	local squareEdges = orientEdges(center, {{sp1,sp2},{sp2,sp3},{sp3,sp4},{sp4,sp1}})

	local cubeEdges = orientEdges(center, getCubeEdges(center, r * 1.8, spinAngle))
	local hexEdges = orientEdges(center, getHexEdges(center, r, spinAngle))
	local rectEdges = orientEdges(center, getRectEdges(center, r * 2.2, r * 1.1, spinAngle))
	local boxEdges = orientEdges(center, getBoxEdges(center, r * 2.4, r * 1.2, r * 1.4, spinAngle))
	local pyramidEdges = orientEdges(center, getPyramidEdges(center, r * 1.9, spinAngle))
	local coneEdges = orientEdges(center, getConeEdges(center, r * 0.95, r * 1.6, spinAngle, false))
	local downConeEdges = orientEdges(center, getConeEdges(center, r * 0.95, r * 1.6, spinAngle, true))
	local octaEdges = orientEdges(center, getOctaEdges(center, r * 1.5, spinAngle))
	local starEdges = orientEdges(center, getStarEdges(center, r, spinAngle))
	local pentagonEdges = orientEdges(center, getPentagonEdges(center, r, spinAngle))
	local octagonEdges = orientEdges(center, getOctagonEdges(center, r, spinAngle))
	local diamondEdges = orientEdges(center, getDiamondEdges(center, r, spinAngle))
	local crossEdges = orientEdges(center, getCrossEdges(center, r, spinAngle))
	local spherePoints = TS.ball and orientPoints(center, getSpherePoints(center, r * 0.95, spinAngle)) or {}

	for i, part in ipairs(parts) do
		if part.Parent and not part.Anchored and not isLocalPart(i, total) then
			-- Multi-target: assign part to a target by index
			local assigned = activeRoots[((i - 1) % #activeRoots) + 1]
			local center = assigned.center
			local char = assigned.char
			if part:IsDescendantOf(char) then continue end
			-- Skip all active target characters
			local skipPart = false
			for _, ar in ipairs(activeRoots) do
				if part:IsDescendantOf(ar.char) then skipPart = true break end
			end
			if skipPart then continue end

			triCounter += 1
			local targetPos

			-- Multi-target uses stable rings around each player (shapes use primary geometry offset)
			if #activeRoots > 1 and not (TS.ball or TS.sphere or TS.square or TS.cube
				or TS.downcone or TS.hex or TS.rect or TS.box
				or TS.pyramid or TS.cone or TS.octa or TS.star
				or TS.pentagon or TS.octagon or TS.diamond or TS.cross) then
				local angle = (tick() * ST.targetRotationSpeed * 2) + (triCounter * 0.37)
				if ST.freezeEnabled then angle = ST.frozenAngle + triCounter * 0.37 end
				targetPos = Vector3.new(
					center.X + math.cos(angle) * r,
					center.Y + math.sin(angle * 2) * 2,
					center.Z + math.sin(angle) * r
				)
				applyVelocity(part, targetPos, ST.targetAttractionStrength)
				ST.targetPartsCount += 1
				continue
			elseif #activeRoots > 1 then
				-- shapes + multi: take primary-relative target then shift to assigned center
				-- fall through using local center for orbit math below by recomputing simple ring
				local angle = (tick() * ST.targetRotationSpeed * 2) + (triCounter * 0.37)
				if ST.freezeEnabled then angle = ST.frozenAngle + triCounter * 0.37 end
				targetPos = Vector3.new(
					center.X + math.cos(angle) * r,
					center.Y,
					center.Z + math.sin(angle) * r
				)
				applyVelocity(part, targetPos, ST.targetAttractionStrength)
				ST.targetPartsCount += 1
				continue
			end

			if TS.ball then
				local idx = ((triCounter - 1) % #spherePoints) + 1
				targetPos = spherePoints[idx]
			elseif TS.downcone then
				local edgeIndex = ((triCounter - 1) % #downConeEdges) + 1
				local partsPerEdge = math.max(1, math.floor(ST.lastTargetTriCount / #downConeEdges))
				local idxOnEdge = math.floor((triCounter - 1) / #downConeEdges)
				local t = (idxOnEdge % partsPerEdge) / partsPerEdge
				targetPos = downConeEdges[edgeIndex][1]:Lerp(downConeEdges[edgeIndex][2], t)
			elseif TS.cone then
				local edgeIndex = ((triCounter - 1) % #coneEdges) + 1
				local partsPerEdge = math.max(1, math.floor(ST.lastTargetTriCount / #coneEdges))
				local idxOnEdge = math.floor((triCounter - 1) / #coneEdges)
				local t = (idxOnEdge % partsPerEdge) / partsPerEdge
				targetPos = coneEdges[edgeIndex][1]:Lerp(coneEdges[edgeIndex][2], t)
			elseif TS.cross then
				local edgeIndex = ((triCounter - 1) % #crossEdges) + 1
				local partsPerEdge = math.max(1, math.floor(ST.lastTargetTriCount / #crossEdges))
				local idxOnEdge = math.floor((triCounter - 1) / #crossEdges)
				local t = (idxOnEdge % partsPerEdge) / partsPerEdge
				targetPos = crossEdges[edgeIndex][1]:Lerp(crossEdges[edgeIndex][2], t)
			elseif TS.diamond then
				local edgeIndex = ((triCounter - 1) % 4) + 1
				local partsPerEdge = math.max(1, math.floor(ST.lastTargetTriCount / 4))
				local idxOnEdge = math.floor((triCounter - 1) / 4)
				local t = (idxOnEdge % partsPerEdge) / partsPerEdge
				targetPos = diamondEdges[edgeIndex][1]:Lerp(diamondEdges[edgeIndex][2], t)
			elseif TS.octagon then
				local edgeIndex = ((triCounter - 1) % 8) + 1
				local partsPerEdge = math.max(1, math.floor(ST.lastTargetTriCount / 8))
				local idxOnEdge = math.floor((triCounter - 1) / 8)
				local t = (idxOnEdge % partsPerEdge) / partsPerEdge
				targetPos = octagonEdges[edgeIndex][1]:Lerp(octagonEdges[edgeIndex][2], t)
			elseif TS.pentagon then
				local edgeIndex = ((triCounter - 1) % 5) + 1
				local partsPerEdge = math.max(1, math.floor(ST.lastTargetTriCount / 5))
				local idxOnEdge = math.floor((triCounter - 1) / 5)
				local t = (idxOnEdge % partsPerEdge) / partsPerEdge
				targetPos = pentagonEdges[edgeIndex][1]:Lerp(pentagonEdges[edgeIndex][2], t)
			elseif TS.star then
				local edgeIndex = ((triCounter - 1) % 10) + 1
				local partsPerEdge = math.max(1, math.floor(ST.lastTargetTriCount / 10))
				local idxOnEdge = math.floor((triCounter - 1) / 10)
				local t = (idxOnEdge % partsPerEdge) / partsPerEdge
				targetPos = starEdges[edgeIndex][1]:Lerp(starEdges[edgeIndex][2], t)
			elseif TS.octa then
				local edgeIndex = ((triCounter - 1) % 12) + 1
				local partsPerEdge = math.max(1, math.floor(ST.lastTargetTriCount / 12))
				local idxOnEdge = math.floor((triCounter - 1) / 12)
				local t = (idxOnEdge % partsPerEdge) / partsPerEdge
				targetPos = octaEdges[edgeIndex][1]:Lerp(octaEdges[edgeIndex][2], t)
			elseif TS.pyramid then
				local edgeIndex = ((triCounter - 1) % 8) + 1
				local partsPerEdge = math.max(1, math.floor(ST.lastTargetTriCount / 8))
				local idxOnEdge = math.floor((triCounter - 1) / 8)
				local t = (idxOnEdge % partsPerEdge) / partsPerEdge
				targetPos = pyramidEdges[edgeIndex][1]:Lerp(pyramidEdges[edgeIndex][2], t)
			elseif TS.box then
				local edgeIndex = ((triCounter - 1) % 12) + 1
				local partsPerEdge = math.max(1, math.floor(ST.lastTargetTriCount / 12))
				local idxOnEdge = math.floor((triCounter - 1) / 12)
				local t = (idxOnEdge % partsPerEdge) / partsPerEdge
				targetPos = boxEdges[edgeIndex][1]:Lerp(boxEdges[edgeIndex][2], t)
			elseif TS.hex then
				local edgeIndex = ((triCounter - 1) % 6) + 1
				local partsPerEdge = math.max(1, math.floor(ST.lastTargetTriCount / 6))
				local idxOnEdge = math.floor((triCounter - 1) / 6)
				local t = (idxOnEdge % partsPerEdge) / partsPerEdge
				targetPos = hexEdges[edgeIndex][1]:Lerp(hexEdges[edgeIndex][2], t)
			elseif TS.rect then
				local edgeIndex = ((triCounter - 1) % 4) + 1
				local partsPerEdge = math.max(1, math.floor(ST.lastTargetTriCount / 4))
				local idxOnEdge = math.floor((triCounter - 1) / 4)
				local t = (idxOnEdge % partsPerEdge) / partsPerEdge
				targetPos = rectEdges[edgeIndex][1]:Lerp(rectEdges[edgeIndex][2], t)
			elseif TS.cube then
				local edgeIndex = ((triCounter - 1) % 12) + 1
				local partsPerEdge = math.max(1, math.floor(ST.lastTargetTriCount / 12))
				local idxOnEdge = math.floor((triCounter - 1) / 12)
				local t = (idxOnEdge % partsPerEdge) / partsPerEdge
				targetPos = cubeEdges[edgeIndex][1]:Lerp(cubeEdges[edgeIndex][2], t)
			elseif TS.sphere then
				local edgeIndex = ((triCounter-1)%3)+1
				local partsPerEdge = math.max(1, math.floor(ST.lastTargetTriCount/3))
				local idxOnEdge = math.floor((triCounter-1)/3)
				local t = (idxOnEdge % partsPerEdge) / partsPerEdge
				targetPos = triEdges[edgeIndex][1]:Lerp(triEdges[edgeIndex][2], t)
			elseif TS.square then
				local edgeIndex = ((triCounter-1)%4)+1
				local partsPerEdge = math.max(1, math.floor(ST.lastTargetTriCount/4))
				local idxOnEdge = math.floor((triCounter-1)/4)
				local t = (idxOnEdge % partsPerEdge) / partsPerEdge
				targetPos = squareEdges[edgeIndex][1]:Lerp(squareEdges[edgeIndex][2], t)
			else
				-- Default target ring: stable orbit, respects ROTATE panel
				local angle = math.atan2(part.Position.Z - center.Z, part.Position.X - center.X)
				if angle ~= angle then angle = (triCounter * 0.37) end
				local newAngle = ST.freezeEnabled and angle or (angle + math.rad(ST.targetRotationSpeed))
				local useR = r
				local flat = Vector3.new(
					center.X + math.cos(newAngle) * useR,
					center.Y,
					center.Z + math.sin(newAngle) * useR
				)
				targetPos = orientPoint(center, flat)
			end

			if not TS.sphere and not TS.square and not TS.cube and not TS.downcone and not TS.ball
				and not TS.hex and not TS.rect and not TS.box and not TS.pyramid and not TS.cone and not TS.octa and not TS.star
				and not TS.pentagon and not TS.octagon and not TS.diamond and not TS.cross then
				local dir = targetPos - part.Position
				if dir.Magnitude > 0.01 then
					part.Velocity = dir.Unit * ST.targetAttractionStrength
				end
			else
				applyVelocity(part, targetPos, ST.targetAttractionStrength)
			end

			ST.targetPartsCount += 1
		end
	end
	ST.lastTargetTriCount = math.max(3, ST.targetPartsCount)
	TargetPartsLabel.Text = "Parts: " .. ST.targetPartsCount
end)

-- ==================== BUTTONS ====================
local function turnOffLocalShapes()
	ST.ringPartsEnabled = false
	LS.sphere = false
	LS.square = false
	LS.cube = false
	LS.downcone = false
	LS.ball = false
	LS.hex = false
	LS.rect = false
	LS.box = false
	LS.pyramid = false
	LS.cone = false
	LS.octa = false
	LS.star = false
	LS.pentagon = false
	LS.octagon = false
	LS.diamond = false
	LS.cross = false
	LS.heart = false
	LS.dna = false
	threeDPlusShape = nil
	ST.cursorRingEnabled = false

	ToggleButton.Text = "Your Ring  •  Off"
	ToggleButton.BackgroundColor3 = Color3.fromRGB(160, 40, 40)
	LocalSphereButton.Text = "Triangle  •  Off"
	LocalSphereButton.BackgroundColor3 = Color3.fromRGB(50, 50, 90)
	LocalSquareButton.Text = "Square  •  Off"
	LocalSquareButton.BackgroundColor3 = Color3.fromRGB(65, 45, 100)
	LocalCubeButton.Text = "Cube  •  Off"
	LocalCubeButton.BackgroundColor3 = Color3.fromRGB(40, 70, 100)
	LocalDownConeButton.Text = "Down Cone  •  Off"
	LocalDownConeButton.BackgroundColor3 = Color3.fromRGB(90, 45, 45)
	LocalBallButton.Text = "Sphere  •  Off"
	LocalBallButton.BackgroundColor3 = Color3.fromRGB(30, 90, 110)
	LocalHexButton.Text = "Hexagon  •  Off"
	LocalHexButton.BackgroundColor3 = Color3.fromRGB(80, 50, 120)
	LocalRectButton.Text = "Rectangle  •  Off"
	LocalRectButton.BackgroundColor3 = Color3.fromRGB(60, 80, 50)
	LocalBoxButton.Text = "Box  •  Off"
	LocalBoxButton.BackgroundColor3 = Color3.fromRGB(90, 60, 40)
	LocalPyramidButton.Text = "Pyramid  •  Off"
	LocalPyramidButton.BackgroundColor3 = Color3.fromRGB(100, 70, 40)
	LocalConeButton.Text = "Cone  •  Off"
	LocalConeButton.BackgroundColor3 = Color3.fromRGB(70, 90, 50)
	LocalOctaButton.Text = "Octahedron  •  Off"
	LocalOctaButton.BackgroundColor3 = Color3.fromRGB(50, 80, 100)
	LocalStarButton.Text = "Star  •  Off"
	LocalStarButton.BackgroundColor3 = Color3.fromRGB(140, 100, 30)
	LocalPentagonButton.Text = "Pentagon  •  Off"
	LocalPentagonButton.BackgroundColor3 = Color3.fromRGB(90, 60, 110)
	LocalOctagonButton.Text = "Octagon  •  Off"
	LocalOctagonButton.BackgroundColor3 = Color3.fromRGB(60, 90, 80)
	LocalDiamondButton.Text = "Diamond  •  Off"
	LocalDiamondButton.BackgroundColor3 = Color3.fromRGB(100, 50, 80)
	LocalCrossButton.Text = "Cross  •  Off"
	LocalCrossButton.BackgroundColor3 = Color3.fromRGB(80, 80, 50)
	LocalHeartButton.Text = "Heart  •  Off"
	LocalHeartButton.BackgroundColor3 = Color3.fromRGB(160, 40, 80)
	LocalDNAButton.Text = "DNA  •  Off"
	LocalDNAButton.BackgroundColor3 = Color3.fromRGB(40, 120, 160)
	CursorButton.Text = "Cursor Follow  •  Off"
	CursorButton.BackgroundColor3 = Color3.fromRGB(160, 40, 40)
	for i, shapeName in ipairs(ThreeDPlusShapeNames) do
		local btn = ThreeDPlusButtons[shapeName]
		if btn then
			btn.Text = shapeName .. "  •  Off"
			btn.BackgroundColor3 = Color3.fromRGB(45 + ((i * 17) % 45), 55 + ((i * 11) % 45), 85 + ((i * 19) % 55))
		end
	end
	ThreeDPlusStatus.Text = "Selected: None"
end

function setThreeDPlusShape(shapeName)
	turnOffLocalShapes()
	threeDPlusShape = shapeName
	local btn = ThreeDPlusButtons[shapeName]
	if btn then
		btn.Text = shapeName .. "  •  On"
		btn.BackgroundColor3 = Color3.fromRGB(55, 120, 190)
	end
	ToggleButton.Text = "Your Ring  •  On"
	ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 140, 70)
	ThreeDPlusStatus.Text = "Selected: " .. shapeName
	playSound("12221967")
end

do
	local function bindThreeDPlusButtons()
		for shapeName, btn in pairs(ThreeDPlusButtons) do
			btn.MouseButton1Click:Connect(function()
				if threeDPlusShape == shapeName then
					turnOffLocalShapes()
					ThreeDPlusStatus.Text = "Selected: None"
				else
					setThreeDPlusShape(shapeName)
				end
			end)
		end
	end
	bindThreeDPlusButtons()
end

local function turnOffTargetShapes()
	ST.targetRingEnabled = false
	TS.sphere = false
	TS.square = false
	TS.cube = false
	TS.downcone = false
	TS.ball = false
	TS.hex = false
	TS.rect = false
	TS.box = false
	TS.pyramid = false
	TS.cone = false
	TS.octa = false
	TS.star = false
	TS.pentagon = false
	TS.octagon = false
	TS.diamond = false
	TS.cross = false

	TargetToggle.Text = "Target Ring  •  Off"
	TargetToggle.BackgroundColor3 = Color3.fromRGB(160, 40, 40)
	TargetSphereButton.Text = "Triangle  •  Off"
	TargetSphereButton.BackgroundColor3 = Color3.fromRGB(50, 50, 90)
	TargetSquareButton.Text = "Square  •  Off"
	TargetSquareButton.BackgroundColor3 = Color3.fromRGB(65, 45, 100)
	TargetCubeButton.Text = "Cube  •  Off"
	TargetCubeButton.BackgroundColor3 = Color3.fromRGB(40, 70, 100)
	TargetDownConeButton.Text = "Down Cone  •  Off"
	TargetDownConeButton.BackgroundColor3 = Color3.fromRGB(90, 45, 45)
	TargetBallButton.Text = "Sphere  •  Off"
	TargetBallButton.BackgroundColor3 = Color3.fromRGB(30, 90, 110)
	TargetHexButton.Text = "Hexagon  •  Off"
	TargetHexButton.BackgroundColor3 = Color3.fromRGB(80, 50, 120)
	TargetRectButton.Text = "Rectangle  •  Off"
	TargetRectButton.BackgroundColor3 = Color3.fromRGB(60, 80, 50)
	TargetBoxButton.Text = "Box  •  Off"
	TargetBoxButton.BackgroundColor3 = Color3.fromRGB(90, 60, 40)
	TargetPyramidButton.Text = "Pyramid  •  Off"
	TargetPyramidButton.BackgroundColor3 = Color3.fromRGB(100, 70, 40)
	TargetConeButton.Text = "Cone  •  Off"
	TargetConeButton.BackgroundColor3 = Color3.fromRGB(70, 90, 50)
	TargetOctaButton.Text = "Octahedron  •  Off"
	TargetOctaButton.BackgroundColor3 = Color3.fromRGB(50, 80, 100)
	TargetStarButton.Text = "Star  •  Off"
	TargetStarButton.BackgroundColor3 = Color3.fromRGB(140, 100, 30)
	TargetPentagonButton.Text = "Pentagon  •  Off"
	TargetPentagonButton.BackgroundColor3 = Color3.fromRGB(90, 60, 110)
	TargetOctagonButton.Text = "Octagon  •  Off"
	TargetOctagonButton.BackgroundColor3 = Color3.fromRGB(60, 90, 80)
	TargetDiamondButton.Text = "Diamond  •  Off"
	TargetDiamondButton.BackgroundColor3 = Color3.fromRGB(100, 50, 80)
	TargetCrossButton.Text = "Cross  •  Off"
	TargetCrossButton.BackgroundColor3 = Color3.fromRGB(80, 80, 50)
end

SpeedModeButton.MouseButton1Click:Connect(function()
	ST.smoothMode = not ST.smoothMode
	if ST.smoothMode then
		SpeedModeButton.Text = "Mode: Smooth"
		SpeedModeButton.BackgroundColor3 = Color3.fromRGB(45, 90, 140)
		ST.attractionStrength = 1100
		ST.targetAttractionStrength = 1100
		ST.rotationSpeed = 0.65
		ST.targetRotationSpeed = 0.65
	else
		SpeedModeButton.Text = "Mode: Aggressive"
		SpeedModeButton.BackgroundColor3 = Color3.fromRGB(160, 50, 40)
		ST.attractionStrength = 2200
		ST.targetAttractionStrength = 2200
		ST.rotationSpeed = 1.1
		ST.targetRotationSpeed = 1.1
	end
	playSound("12221967")
end)

FreezeButton.MouseButton1Click:Connect(function()
	ST.freezeEnabled = not ST.freezeEnabled
	if ST.freezeEnabled then
		FreezeButton.Text = "Freeze  •  On"
		FreezeButton.BackgroundColor3 = Color3.fromRGB(40, 140, 70)
	else
		FreezeButton.Text = "Freeze  •  Off"
		FreezeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
	end
	playSound("12221967")
end)

-- Safety Shield (invisible island floor disc — reduces ring floor fling)
do
	local shieldOn = false
	local shieldPart = nil
	local shieldConn = nil
	local lp = LocalPlayer

	local function destroyShield()
		if shieldConn then
			pcall(function() shieldConn:Disconnect() end)
			shieldConn = nil
		end
		if shieldPart then
			pcall(function() shieldPart:Destroy() end)
			shieldPart = nil
		end
		local existing = Workspace:FindFirstChild("XenoFixedSafetyShield")
		if existing then pcall(function() existing:Destroy() end) end
	end

	local function createShield()
		destroyShield()
		local islandX, islandY, islandZ = 0, 45.0, 0
		local islandRadius = 145
		local islandMesh = Workspace:FindFirstChild("Island") or Workspace:FindFirstChild("Map")
		if islandMesh and islandMesh:IsA("BasePart") then
			islandX = islandMesh.Position.X
			islandY = islandMesh.Position.Y + 2.3
			islandZ = islandMesh.Position.Z
			islandRadius = math.max(islandMesh.Size.X, islandMesh.Size.Z) / 2
		end
		local TargetPart = Instance.new("Part")
		TargetPart.Name = "XenoFixedSafetyShield"
		TargetPart.Shape = Enum.PartType.Cylinder
		TargetPart.Size = Vector3.new(0.4, islandRadius * 2, islandRadius * 2)
		TargetPart.CFrame = CFrame.new(islandX, islandY, islandZ) * CFrame.Angles(0, 0, math.rad(90))
		TargetPart.Material = Enum.Material.SmoothPlastic
		TargetPart.Color = Color3.fromRGB(0, 120, 255)
		TargetPart.Transparency = 1
		TargetPart.Anchored = true
		TargetPart.CanCollide = true
		TargetPart.Parent = Workspace
		shieldPart = TargetPart

		shieldConn = RunService.PreSimulation:Connect(function()
			if not shieldPart or not shieldPart.Parent or not lp.Character then return end
			local rootPart = lp.Character:FindFirstChild("HumanoidRootPart")
			if not rootPart then return end
			local dist = (Vector3.new(rootPart.Position.X, islandY, rootPart.Position.Z) - TargetPart.Position).Magnitude
			if dist <= islandRadius + 15 then
				for _, limb in ipairs(lp.Character:GetDescendants()) do
					if limb:IsA("BasePart") then
						limb.CanCollide = false
					end
				end
			end
		end)
	end

	SafetyShieldButton.MouseButton1Click:Connect(function()
		shieldOn = not shieldOn
		if shieldOn then
			createShield()
			SafetyShieldButton.Text = "Shield  •  On"
			SafetyShieldButton.BackgroundColor3 = Color3.fromRGB(40, 140, 70)
			pcall(function()
				StarterGui:SetCore("SendNotification", {
					Title = "Safety Shield",
					Text = "ON — invisible island floor active",
					Duration = 3,
				})
			end)
		else
			destroyShield()
			SafetyShieldButton.Text = "Shield  •  Off"
			SafetyShieldButton.BackgroundColor3 = Color3.fromRGB(30, 70, 110)
			pcall(function()
				StarterGui:SetCore("SendNotification", {
					Title = "Safety Shield",
					Text = "OFF",
					Duration = 2,
				})
			end)
		end
		playSound("12221967")
	end)
end

-- Credits
CreditsButton.MouseButton1Click:Connect(function()
	playSound("12221967")
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = "Credits",
			Text = "Orbits: gabrieltod112  |  Fling fix: Novakitsuney / foxy9694",
			Duration = 6,
		})
	end)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = "gabrieltod112",
			Text = "Orbit systems & super ring",
			Duration = 5,
		})
	end)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = "Novakitsuney / foxy9694",
			Text = "Bugfix — fling issue when running the script",
			Duration = 5,
		})
	end)
end)

-- Fixed Pos toggle
FixedPosButton.MouseButton1Click:Connect(function()
	local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	if ST.fixedPosEnabled then
		ST.fixedPosEnabled = false
		ST.fixedBasePosition = nil
		FixedPosButton.Text = "Fixed Pos  •  Off"
		FixedPosButton.BackgroundColor3 = Color3.fromRGB(40, 70, 110)
		if ST.fixedMarker then
			ST.fixedMarker:Destroy()
			ST.fixedMarker = nil
		end
	else
		ST.fixedPosEnabled = true
		ST.fixedBasePosition = hrp.Position
		FixedPosButton.Text = "Fixed Pos  •  On"
		FixedPosButton.BackgroundColor3 = Color3.fromRGB(40, 120, 180)

		if ST.fixedMarker then ST.fixedMarker:Destroy() end
		ST.fixedMarker = Instance.new("Part")
		ST.fixedMarker.Name = "FixedPosMarker"
		ST.fixedMarker.Size = Vector3.new(1.4, 1.4, 1.4)
		ST.fixedMarker.Shape = Enum.PartType.Ball
		ST.fixedMarker.Material = Enum.Material.Neon
		ST.fixedMarker.Color = Color3.fromRGB(0, 170, 255)
		ST.fixedMarker.Transparency = 0.55
		ST.fixedMarker.Anchored = true
		ST.fixedMarker.CanCollide = false
		ST.fixedMarker.CanQuery = false
		ST.fixedMarker.CanTouch = false
		ST.fixedMarker.CastShadow = false
		ST.fixedMarker.Position = ST.fixedBasePosition + Vector3.new(ST.fixedOffsetX, ST.fixedOffsetY, ST.fixedOffsetZ)
		ST.fixedMarker.Parent = Workspace
	end
	playSound("12221967")
end)

TextToggle.MouseButton1Click:Connect(function()
	ST.textEnabled = not ST.textEnabled
	if ST.textEnabled then
		turnOffLocalShapes()
		TextToggle.Text = "Super Text  •  On"
		TextToggle.BackgroundColor3 = Color3.fromRGB(40, 140, 70)
	else
		TextToggle.Text = "Super Text  •  Off"
		TextToggle.BackgroundColor3 = Color3.fromRGB(160, 40, 40)
	end
	playSound("12221967")
end)

ToggleButton.MouseButton1Click:Connect(function()
	if ST.cursorRingEnabled or ST.textEnabled then return end
	if ST.ringPartsEnabled then
		turnOffLocalShapes()
	else
		turnOffLocalShapes()
		ST.ringPartsEnabled = true
		ToggleButton.Text = "Your Ring  •  On"
		ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 140, 70)
	end
	playSound("12221967")
end)

local function setLocalShape(shape)
	turnOffLocalShapes()
	ST.ringPartsEnabled = true
	ToggleButton.Text = "Your Ring  •  On"
	ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 140, 70)

	if shape == "triangle" then
		LS.sphere = true
		LocalSphereButton.Text = "Triangle  •  On"
		LocalSphereButton.BackgroundColor3 = Color3.fromRGB(70, 70, 160)
	elseif shape == "square" then
		LS.square = true
		LocalSquareButton.Text = "Square  •  On"
		LocalSquareButton.BackgroundColor3 = Color3.fromRGB(100, 60, 170)
	elseif shape == "cube" then
		LS.cube = true
		LocalCubeButton.Text = "Cube  •  On"
		LocalCubeButton.BackgroundColor3 = Color3.fromRGB(50, 110, 160)
	elseif shape == "downcone" then
		LS.downcone = true
		LocalDownConeButton.Text = "Down Cone  •  On"
		LocalDownConeButton.BackgroundColor3 = Color3.fromRGB(160, 60, 50)
	elseif shape == "sphere" then
		LS.ball = true
		LocalBallButton.Text = "Sphere  •  On"
		LocalBallButton.BackgroundColor3 = Color3.fromRGB(40, 140, 160)
	elseif shape == "hex" then
		LS.hex = true
		LocalHexButton.Text = "Hexagon  •  On"
		LocalHexButton.BackgroundColor3 = Color3.fromRGB(130, 70, 180)
	elseif shape == "rect" then
		LS.rect = true
		LocalRectButton.Text = "Rectangle  •  On"
		LocalRectButton.BackgroundColor3 = Color3.fromRGB(80, 130, 70)
	elseif shape == "box" then
		LS.box = true
		LocalBoxButton.Text = "Box  •  On"
		LocalBoxButton.BackgroundColor3 = Color3.fromRGB(150, 90, 50)
	elseif shape == "pyramid" then
		LS.pyramid = true
		LocalPyramidButton.Text = "Pyramid  •  On"
		LocalPyramidButton.BackgroundColor3 = Color3.fromRGB(160, 110, 50)
	elseif shape == "cone" then
		LS.cone = true
		LocalConeButton.Text = "Cone  •  On"
		LocalConeButton.BackgroundColor3 = Color3.fromRGB(100, 140, 70)
	elseif shape == "octa" then
		LS.octa = true
		LocalOctaButton.Text = "Octahedron  •  On"
		LocalOctaButton.BackgroundColor3 = Color3.fromRGB(70, 120, 150)
	elseif shape == "star" then
		LS.star = true
		LocalStarButton.Text = "Star  •  On"
		LocalStarButton.BackgroundColor3 = Color3.fromRGB(200, 150, 40)
	elseif shape == "pentagon" then
		LS.pentagon = true
		LocalPentagonButton.Text = "Pentagon  •  On"
		LocalPentagonButton.BackgroundColor3 = Color3.fromRGB(140, 90, 160)
	elseif shape == "octagon" then
		LS.octagon = true
		LocalOctagonButton.Text = "Octagon  •  On"
		LocalOctagonButton.BackgroundColor3 = Color3.fromRGB(90, 140, 110)
	elseif shape == "diamond" then
		LS.diamond = true
		LocalDiamondButton.Text = "Diamond  •  On"
		LocalDiamondButton.BackgroundColor3 = Color3.fromRGB(160, 80, 120)
	elseif shape == "cross" then
		LS.cross = true
		LocalCrossButton.Text = "Cross  •  On"
		LocalCrossButton.BackgroundColor3 = Color3.fromRGB(130, 130, 70)
	elseif shape == "heart" then
		LS.heart = true
		LocalHeartButton.Text = "Heart  •  On"
		LocalHeartButton.BackgroundColor3 = Color3.fromRGB(200, 50, 100)
	elseif shape == "dna" then
		LS.dna = true
		LocalDNAButton.Text = "DNA  •  On"
		LocalDNAButton.BackgroundColor3 = Color3.fromRGB(50, 160, 200)
	end
end

LocalSphereButton.MouseButton1Click:Connect(function()
	if ST.cursorRingEnabled or ST.textEnabled then return end
	if LS.sphere then turnOffLocalShapes() else setLocalShape("triangle") end
	playSound("12221967")
end)
LocalSquareButton.MouseButton1Click:Connect(function()
	if ST.cursorRingEnabled or ST.textEnabled then return end
	if LS.square then turnOffLocalShapes() else setLocalShape("square") end
	playSound("12221967")
end)
LocalCubeButton.MouseButton1Click:Connect(function()
	if ST.cursorRingEnabled or ST.textEnabled then return end
	if LS.cube then turnOffLocalShapes() else setLocalShape("cube") end
	playSound("12221967")
end)
LocalDownConeButton.MouseButton1Click:Connect(function()
	if ST.cursorRingEnabled or ST.textEnabled then return end
	if LS.downcone then turnOffLocalShapes() else setLocalShape("downcone") end
	playSound("12221967")
end)
LocalBallButton.MouseButton1Click:Connect(function()
	if ST.cursorRingEnabled or ST.textEnabled then return end
	if LS.ball then turnOffLocalShapes() else setLocalShape("sphere") end
	playSound("12221967")
end)
LocalHexButton.MouseButton1Click:Connect(function()
	if ST.cursorRingEnabled or ST.textEnabled then return end
	if LS.hex then turnOffLocalShapes() else setLocalShape("hex") end
	playSound("12221967")
end)
LocalRectButton.MouseButton1Click:Connect(function()
	if ST.cursorRingEnabled or ST.textEnabled then return end
	if LS.rect then turnOffLocalShapes() else setLocalShape("rect") end
	playSound("12221967")
end)
LocalBoxButton.MouseButton1Click:Connect(function()
	if ST.cursorRingEnabled or ST.textEnabled then return end
	if LS.box then turnOffLocalShapes() else setLocalShape("box") end
	playSound("12221967")
end)
LocalPyramidButton.MouseButton1Click:Connect(function()
	if ST.cursorRingEnabled or ST.textEnabled then return end
	if LS.pyramid then turnOffLocalShapes() else setLocalShape("pyramid") end
	playSound("12221967")
end)
LocalConeButton.MouseButton1Click:Connect(function()
	if ST.cursorRingEnabled or ST.textEnabled then return end
	if LS.cone then turnOffLocalShapes() else setLocalShape("cone") end
	playSound("12221967")
end)
LocalOctaButton.MouseButton1Click:Connect(function()
	if ST.cursorRingEnabled or ST.textEnabled then return end
	if LS.octa then turnOffLocalShapes() else setLocalShape("octa") end
	playSound("12221967")
end)
LocalStarButton.MouseButton1Click:Connect(function()
	if ST.cursorRingEnabled or ST.textEnabled then return end
	if LS.star then turnOffLocalShapes() else setLocalShape("star") end
	playSound("12221967")
end)
LocalPentagonButton.MouseButton1Click:Connect(function()
	if ST.cursorRingEnabled or ST.textEnabled then return end
	if LS.pentagon then turnOffLocalShapes() else setLocalShape("pentagon") end
	playSound("12221967")
end)
LocalOctagonButton.MouseButton1Click:Connect(function()
	if ST.cursorRingEnabled or ST.textEnabled then return end
	if LS.octagon then turnOffLocalShapes() else setLocalShape("octagon") end
	playSound("12221967")
end)
LocalDiamondButton.MouseButton1Click:Connect(function()
	if ST.cursorRingEnabled or ST.textEnabled then return end
	if LS.diamond then turnOffLocalShapes() else setLocalShape("diamond") end
	playSound("12221967")
end)
LocalCrossButton.MouseButton1Click:Connect(function()
	if ST.cursorRingEnabled or ST.textEnabled then return end
	if LS.cross then turnOffLocalShapes() else setLocalShape("cross") end
	playSound("12221967")
end)
LocalHeartButton.MouseButton1Click:Connect(function()
	if ST.cursorRingEnabled or ST.textEnabled then return end
	if LS.heart then turnOffLocalShapes() else setLocalShape("heart") end
	playSound("12221967")
end)
LocalDNAButton.MouseButton1Click:Connect(function()
	if ST.cursorRingEnabled or ST.textEnabled then return end
	if LS.dna then turnOffLocalShapes() else setLocalShape("dna") end
	playSound("12221967")
end)

CursorButton.MouseButton1Click:Connect(function()
	if ST.textEnabled then return end
	ST.cursorRingEnabled = not ST.cursorRingEnabled
	if ST.cursorRingEnabled then
		turnOffLocalShapes()
		ST.cursorRingEnabled = true
		ST.radius = 200
		RadiusDisplay.Text = "Radius: 200"
		CursorButton.Text = "Cursor Follow  •  On"
		CursorButton.BackgroundColor3 = Color3.fromRGB(40, 140, 70)
	else
		CursorButton.Text = "Cursor Follow  •  Off"
		CursorButton.BackgroundColor3 = Color3.fromRGB(160, 40, 40)
	end
	playSound("12221967")
end)

DecreaseRadius.MouseButton1Click:Connect(function()
	ST.radius = math.max(0, ST.radius - 5)
	RadiusDisplay.Text = "Radius: " .. ST.radius
	playSound("12221967")
end)
IncreaseRadius.MouseButton1Click:Connect(function()
	ST.radius = math.min(10000, ST.radius + 5)
	RadiusDisplay.Text = "Radius: " .. ST.radius
	playSound("12221967")
end)

DecreasePixel.MouseButton1Click:Connect(function()
	ST.textPixelSize = math.max(1.5, ST.textPixelSize - 0.5)
	PixelDisplay.Text = "Pixel Size: " .. string.format("%.1f", ST.textPixelSize)
	currentTextPoints = getTextPoints(ST.textString)
	playSound("12221967")
end)
IncreasePixel.MouseButton1Click:Connect(function()
	ST.textPixelSize = math.min(12, ST.textPixelSize + 0.5)
	PixelDisplay.Text = "Pixel Size: " .. string.format("%.1f", ST.textPixelSize)
	currentTextPoints = getTextPoints(ST.textString)
	playSound("12221967")
end)

function findPlayer(name)
	if not name then return nil end
	name = tostring(name):gsub("^%s+", ""):gsub("%s+$", "")
	if name == "" then return nil end
	local lower = string.lower(name)

	-- 1) Exact Username match
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and string.lower(plr.Name) == lower then
			return plr
		end
	end
	-- 2) Exact DisplayName match
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and string.lower(plr.DisplayName) == lower then
			return plr
		end
	end
	-- 3) Partial Username (starts with)
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and string.sub(string.lower(plr.Name), 1, #lower) == lower then
			return plr
		end
	end
	-- 4) Partial DisplayName (starts with)
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and string.sub(string.lower(plr.DisplayName), 1, #lower) == lower then
			return plr
		end
	end
	-- 5) Contains in Username or DisplayName
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			if string.find(string.lower(plr.Name), lower, 1, true)
				or string.find(string.lower(plr.DisplayName), lower, 1, true) then
				return plr
			end
		end
	end
	return nil
end

function resolveTargetPlayer(preferBox)
	-- Prefer NameBox text when the user typed something
	local boxText = NameBox and NameBox.Text or ""
	boxText = tostring(boxText):gsub("^%s+", ""):gsub("%s+$", "")
	if preferBox and boxText ~= "" then
		local found = findPlayer(boxText)
		if found then return found end
	end
	-- Fall back to current target if still in the server
	if ST.targetPlayer and ST.targetPlayer.Parent == Players then
		return ST.targetPlayer
	end
	-- Last resort: try box again
	if boxText ~= "" then
		return findPlayer(boxText)
	end
	return nil
end

function getTargetRoot(plr)
	if not plr then return nil, nil end
	local char = plr.Character
	if not char then return nil, nil end
	local root = char:FindFirstChild("HumanoidRootPart")
		or char:FindFirstChild("UpperTorso")
		or char:FindFirstChild("Torso")
		or char.PrimaryPart
	if not root then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum and hum.RootPart then
			root = hum.RootPart
		end
	end
	return char, root
end

function isTargetModeOn()
	return ST.targetRingEnabled or TS.sphere or TS.square or TS.cube
		or TS.downcone or TS.ball or TS.hex or TS.rect
		or TS.box or TS.pyramid or TS.cone or TS.octa
		or TS.star or TS.pentagon or TS.octagon or TS.diamond
		or TS.cross
end

function syncPrimaryTarget()
	-- Keep ST.targetPlayer as the first valid entry for UI / spectate
	if #ST.targetPlayers > 0 then
		ST.targetPlayer = ST.targetPlayers[1]
	end
end

function addToMultiTarget(plr)
	if not plr or plr == LocalPlayer then return false end
	for _, p in ipairs(ST.targetPlayers) do
		if p == plr then return false end
	end
	if #ST.targetPlayers >= ST.maxMultiTargets then
		table.remove(ST.targetPlayers, 1)
	end
	table.insert(ST.targetPlayers, plr)
	syncPrimaryTarget()
	return true
end

function setSingleTarget(plr)
	ST.targetPlayers = {}
	if plr then
		table.insert(ST.targetPlayers, plr)
	end
	ST.targetPlayer = plr
end

function getActiveTargetRoots()
	local roots = {}
	-- prune dead
	local alive = {}
	for _, plr in ipairs(ST.targetPlayers) do
		if plr and plr.Parent == Players then
			table.insert(alive, plr)
		end
	end
	ST.targetPlayers = alive
	syncPrimaryTarget()

	local list = ST.targetPlayers
	if #list == 0 and ST.targetPlayer and ST.targetPlayer.Parent == Players then
		list = { ST.targetPlayer }
	end
	for _, plr in ipairs(list) do
		local char, root = getTargetRoot(plr)
		if char and root then
			table.insert(roots, { plr = plr, char = char, root = root, center = root.Position })
		end
	end
	return roots
end

function findNearestPlayer()
	local myChar = LocalPlayer.Character
	local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Head"))
	if not myRoot then return nil end
	local best, bestD = nil, math.huge
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			local _, root = getTargetRoot(plr)
			if root then
				local d = (root.Position - myRoot.Position).Magnitude
				if d < bestD then
					bestD = d
					best = plr
				end
			end
		end
	end
	return best
end

function updateMultiBtn()
	if ST.multiTargetEnabled then
		MultiTargetBtn.Text = string.format("Multi (%d/%d)  •  On", #ST.targetPlayers, ST.maxMultiTargets)
		MultiTargetBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 70)
	else
		MultiTargetBtn.Text = string.format("Multi (%d/%d)  •  Off", #ST.targetPlayers, ST.maxMultiTargets)
		MultiTargetBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	end
end

function refreshPlayerList()
	for _, child in ipairs(PlayerListFrame:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end
	local order = 0
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			order += 1
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, -8, 0, 26)
			btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
			btn.Text = (plr.DisplayName or plr.Name) .. "  (@" .. plr.Name .. ")"
			btn.TextColor3 = Color3.fromRGB(230, 230, 240)
			btn.Font = Enum.Font.Gotham
			btn.TextSize = 12
			btn.TextXAlignment = Enum.TextXAlignment.Left
			btn.LayoutOrder = order
			btn.Parent = PlayerListFrame
			Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
			local pad = Instance.new("UIPadding")
			pad.PaddingLeft = UDim.new(0, 8)
			pad.Parent = btn
			btn.MouseButton1Click:Connect(function()
				NameBox.Text = plr.Name
				if ST.multiTargetEnabled then
					addToMultiTarget(plr)
					updateMultiBtn()
				else
					setSingleTarget(plr)
				end
				if not isTargetModeOn() then
					turnOffTargetShapes()
					ST.targetRingEnabled = true
				end
				TargetToggle.Text = "Target Ring  •  On (" .. (plr.DisplayName or plr.Name) .. ")"
				TargetToggle.BackgroundColor3 = Color3.fromRGB(40, 140, 70)
				PlayerListFrame.Visible = false
				PlayersListBtn.Text = "Players list  ▼"
				playSound("12221967")
				pcall(function()
					StarterGui:SetCore("SendNotification", {
						Title = "Target",
						Text = (ST.multiTargetEnabled and "Added " or "Targeting ") .. (plr.DisplayName or plr.Name),
						Duration = 2,
					})
				end)
			end)
		end
	end
	PlayerListFrame.CanvasSize = UDim2.new(0, 0, 0, math.max(110, order * 30 + 8))
end

TargetToggle.MouseButton1Click:Connect(function()
	if isTargetModeOn() then
		turnOffTargetShapes()
		playSound("12221967")
		return
	end
	local found = resolveTargetPlayer(true) or findNearestPlayer()
	if not found then
		pcall(function()
			StarterGui:SetCore("SendNotification", {Title="Target", Text="Player not found! Pick from list or type a name.", Duration=3})
		end)
		return
	end
	if ST.multiTargetEnabled then
		addToMultiTarget(found)
		updateMultiBtn()
	else
		setSingleTarget(found)
	end
	turnOffTargetShapes()
	ST.targetRingEnabled = true
	TargetToggle.Text = "Target Ring  •  On (" .. (found.DisplayName or found.Name) .. ")"
	TargetToggle.BackgroundColor3 = Color3.fromRGB(40, 140, 70)
	playSound("12221967")
end)

local function setTargetShape(shape)
	local found = resolveTargetPlayer(true) or ST.targetPlayer or findNearestPlayer()
	if not found then
		pcall(function()
			StarterGui:SetCore("SendNotification", {Title="Target", Text="Player not found! Pick from list or type a name.", Duration=3})
		end)
		return
	end
	if ST.multiTargetEnabled then
		addToMultiTarget(found)
		updateMultiBtn()
	else
		setSingleTarget(found)
	end
	turnOffTargetShapes()
	ST.targetRingEnabled = true
	TargetToggle.Text = "Target Ring  •  On (" .. (found.DisplayName or found.Name) .. ")"
	TargetToggle.BackgroundColor3 = Color3.fromRGB(40, 140, 70)

	if shape == "triangle" then
		TS.sphere = true
		TargetSphereButton.Text = "Triangle  •  On"
		TargetSphereButton.BackgroundColor3 = Color3.fromRGB(70, 70, 160)
	elseif shape == "square" then
		TS.square = true
		TargetSquareButton.Text = "Square  •  On"
		TargetSquareButton.BackgroundColor3 = Color3.fromRGB(100, 60, 170)
	elseif shape == "cube" then
		TS.cube = true
		TargetCubeButton.Text = "Cube  •  On"
		TargetCubeButton.BackgroundColor3 = Color3.fromRGB(50, 110, 160)
	elseif shape == "downcone" then
		TS.downcone = true
		TargetDownConeButton.Text = "Down Cone  •  On"
		TargetDownConeButton.BackgroundColor3 = Color3.fromRGB(160, 60, 50)
	elseif shape == "sphere" then
		TS.ball = true
		TargetBallButton.Text = "Sphere  •  On"
		TargetBallButton.BackgroundColor3 = Color3.fromRGB(40, 140, 160)
	elseif shape == "hex" then
		TS.hex = true
		TargetHexButton.Text = "Hexagon  •  On"
		TargetHexButton.BackgroundColor3 = Color3.fromRGB(130, 70, 180)
	elseif shape == "rect" then
		TS.rect = true
		TargetRectButton.Text = "Rectangle  •  On"
		TargetRectButton.BackgroundColor3 = Color3.fromRGB(80, 130, 70)
	elseif shape == "box" then
		TS.box = true
		TargetBoxButton.Text = "Box  •  On"
		TargetBoxButton.BackgroundColor3 = Color3.fromRGB(150, 90, 50)
	elseif shape == "pyramid" then
		TS.pyramid = true
		TargetPyramidButton.Text = "Pyramid  •  On"
		TargetPyramidButton.BackgroundColor3 = Color3.fromRGB(160, 110, 50)
	elseif shape == "cone" then
		TS.cone = true
		TargetConeButton.Text = "Cone  •  On"
		TargetConeButton.BackgroundColor3 = Color3.fromRGB(100, 140, 70)
	elseif shape == "octa" then
		TS.octa = true
		TargetOctaButton.Text = "Octahedron  •  On"
		TargetOctaButton.BackgroundColor3 = Color3.fromRGB(70, 120, 150)
	elseif shape == "star" then
		TS.star = true
		TargetStarButton.Text = "Star  •  On"
		TargetStarButton.BackgroundColor3 = Color3.fromRGB(200, 150, 40)
	elseif shape == "pentagon" then
		TS.pentagon = true
		TargetPentagonButton.Text = "Pentagon  •  On"
		TargetPentagonButton.BackgroundColor3 = Color3.fromRGB(140, 90, 160)
	elseif shape == "octagon" then
		TS.octagon = true
		TargetOctagonButton.Text = "Octagon  •  On"
		TargetOctagonButton.BackgroundColor3 = Color3.fromRGB(90, 140, 110)
	elseif shape == "diamond" then
		TS.diamond = true
		TargetDiamondButton.Text = "Diamond  •  On"
		TargetDiamondButton.BackgroundColor3 = Color3.fromRGB(160, 80, 120)
	elseif shape == "cross" then
		TS.cross = true
		TargetCrossButton.Text = "Cross  •  On"
		TargetCrossButton.BackgroundColor3 = Color3.fromRGB(130, 130, 70)
	end
end

TargetSphereButton.MouseButton1Click:Connect(function()
	if TS.sphere then turnOffTargetShapes() else setTargetShape("triangle") end
	playSound("12221967")
end)
TargetSquareButton.MouseButton1Click:Connect(function()
	if TS.square then turnOffTargetShapes() else setTargetShape("square") end
	playSound("12221967")
end)
TargetCubeButton.MouseButton1Click:Connect(function()
	if TS.cube then turnOffTargetShapes() else setTargetShape("cube") end
	playSound("12221967")
end)
TargetDownConeButton.MouseButton1Click:Connect(function()
	if TS.downcone then turnOffTargetShapes() else setTargetShape("downcone") end
	playSound("12221967")
end)
TargetBallButton.MouseButton1Click:Connect(function()
	if TS.ball then turnOffTargetShapes() else setTargetShape("sphere") end
	playSound("12221967")
end)
TargetHexButton.MouseButton1Click:Connect(function()
	if TS.hex then turnOffTargetShapes() else setTargetShape("hex") end
	playSound("12221967")
end)
TargetRectButton.MouseButton1Click:Connect(function()
	if TS.rect then turnOffTargetShapes() else setTargetShape("rect") end
	playSound("12221967")
end)
TargetBoxButton.MouseButton1Click:Connect(function()
	if TS.box then turnOffTargetShapes() else setTargetShape("box") end
	playSound("12221967")
end)
TargetPyramidButton.MouseButton1Click:Connect(function()
	if TS.pyramid then turnOffTargetShapes() else setTargetShape("pyramid") end
	playSound("12221967")
end)
TargetConeButton.MouseButton1Click:Connect(function()
	if TS.cone then turnOffTargetShapes() else setTargetShape("cone") end
	playSound("12221967")
end)
TargetOctaButton.MouseButton1Click:Connect(function()
	if TS.octa then turnOffTargetShapes() else setTargetShape("octa") end
	playSound("12221967")
end)
TargetStarButton.MouseButton1Click:Connect(function()
	if TS.star then turnOffTargetShapes() else setTargetShape("star") end
	playSound("12221967")
end)
TargetPentagonButton.MouseButton1Click:Connect(function()
	if TS.pentagon then turnOffTargetShapes() else setTargetShape("pentagon") end
	playSound("12221967")
end)
TargetOctagonButton.MouseButton1Click:Connect(function()
	if TS.octagon then turnOffTargetShapes() else setTargetShape("octagon") end
	playSound("12221967")
end)
TargetDiamondButton.MouseButton1Click:Connect(function()
	if TS.diamond then turnOffTargetShapes() else setTargetShape("diamond") end
	playSound("12221967")
end)
TargetCrossButton.MouseButton1Click:Connect(function()
	if TS.cross then turnOffTargetShapes() else setTargetShape("cross") end
	playSound("12221967")
end)

TargetDecrease.MouseButton1Click:Connect(function()
	ST.targetRadius = math.max(0, ST.targetRadius - 5)
	TargetRadiusDisplay.Text = "Radius: " .. ST.targetRadius
	playSound("12221967")
end)
TargetIncrease.MouseButton1Click:Connect(function()
	ST.targetRadius = math.min(10000, ST.targetRadius + 5)
	TargetRadiusDisplay.Text = "Radius: " .. ST.targetRadius
	playSound("12221967")
end)


-- Keep targeting reliable across leaves / respawns
Players.PlayerRemoving:Connect(function(plr)
	local removed = false
	for i = #ST.targetPlayers, 1, -1 do
		if ST.targetPlayers[i] == plr then
			table.remove(ST.targetPlayers, i)
			removed = true
		end
	end
	if plr == ST.targetPlayer then
		ST.targetPlayer = nil
		removed = true
	end
	if removed then
		syncPrimaryTarget()
		updateMultiBtn()
		if #ST.targetPlayers == 0 then
			turnOffTargetShapes()
		end
		pcall(function()
			StarterGui:SetCore("SendNotification", {Title="Target", Text=(plr.DisplayName or plr.Name) .. " left", Duration=2})
		end)
	end
end)

-- Auto-refresh NameBox suggestions aren't needed; re-resolve if box changes while active
NameBox.FocusLost:Connect(function(enter)
	if not enter then return end
	if not (ST.targetRingEnabled or TS.sphere or TS.square or TS.cube
		or TS.downcone or TS.ball or TS.hex or TS.rect
		or TS.box or TS.pyramid or TS.cone or TS.octa
		or TS.star or TS.pentagon or TS.octagon or TS.diamond
		or TS.cross) then
		return
	end
	local found = resolveTargetPlayer(true)
	if found then
		ST.targetPlayer = found
		TargetToggle.Text = "Target Ring  •  On (" .. (found.DisplayName or found.Name) .. ")"
		pcall(function()
			StarterGui:SetCore("SendNotification", {Title="Target", Text="Now targeting " .. (found.DisplayName or found.Name), Duration=2})
		end)
	end
end)


-- ==================== PLAYERS LIST / AUTO / MULTI / SPECTATE / UI KEY ====================
PlayersListBtn.MouseButton1Click:Connect(function()
	PlayerListFrame.Visible = not PlayerListFrame.Visible
	if PlayerListFrame.Visible then
		PlayersListBtn.Text = "Players list  ▲"
		refreshPlayerList()
	else
		PlayersListBtn.Text = "Players list  ▼"
	end
	playSound("12221967")
end)

RefreshPlayersBtn.MouseButton1Click:Connect(function()
	refreshPlayerList()
	PlayerListFrame.Visible = true
	PlayersListBtn.Text = "Players list  ▲"
	playSound("12221967")
end)

AutoTargetBtn.MouseButton1Click:Connect(function()
	ST.autoTargetNearest = not ST.autoTargetNearest
	if ST.autoTargetNearest then
		AutoTargetBtn.Text = "Auto nearest  •  On"
		AutoTargetBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 70)
		local n = findNearestPlayer()
		if n then
			if ST.multiTargetEnabled then addToMultiTarget(n) else setSingleTarget(n) end
			if not isTargetModeOn() then
				turnOffTargetShapes()
				ST.targetRingEnabled = true
			end
			TargetToggle.Text = "Target Ring  •  On (" .. (n.DisplayName or n.Name) .. ")"
			TargetToggle.BackgroundColor3 = Color3.fromRGB(40, 140, 70)
			updateMultiBtn()
		end
	else
		AutoTargetBtn.Text = "Auto nearest  •  Off"
		AutoTargetBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	end
	playSound("12221967")
end)

MultiTargetBtn.MouseButton1Click:Connect(function()
	ST.multiTargetEnabled = not ST.multiTargetEnabled
	if not ST.multiTargetEnabled then
		-- keep only primary
		if ST.targetPlayer then
			setSingleTarget(ST.targetPlayer)
		else
			ST.targetPlayers = {}
		end
	elseif ST.targetPlayer then
		addToMultiTarget(ST.targetPlayer)
	end
	updateMultiBtn()
	playSound("12221967")
end)

SpectateBtn.MouseButton1Click:Connect(function()
	ST.spectateEnabled = not ST.spectateEnabled
	if ST.spectateEnabled then
		SpectateBtn.Text = "Spectate  •  On"
		SpectateBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 70)
	else
		SpectateBtn.Text = "Spectate  •  Off"
		SpectateBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
		pcall(function()
			local cam = workspace.CurrentCamera
			if cam and LocalPlayer.Character then
				local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				if hum then cam.CameraSubject = hum end
			end
		end)
	end
	playSound("12221967")
end)

-- Spectate camera follow
RunService.RenderStepped:Connect(function()
	if not ST.spectateEnabled then return end
	local plr = ST.targetPlayer
	if ST.multiTargetEnabled and #ST.targetPlayers > 0 then
		plr = ST.targetPlayers[1]
	end
	if not plr then return end
	local _, root = getTargetRoot(plr)
	if not root then return end
	local cam = workspace.CurrentCamera
	if not cam then return end
	cam.CameraType = Enum.CameraType.Custom
	local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		cam.CameraSubject = hum
	else
		cam.CameraSubject = root
	end
end)

-- UI toggle key (RightShift) — show/hide whole menu; if minimized, restore first
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.RightShift then
		if minimized and Main.Visible then
			-- bring full UI back
			setMinimized(false)
			ST.uiVisible = true
		else
			ST.uiVisible = not ST.uiVisible
			Main.Visible = ST.uiVisible
			if ST.uiVisible and minimized then
				setMinimized(false)
			end
		end
		playSound("12221967")
	end
end)

Players.PlayerAdded:Connect(function()
	if PlayerListFrame.Visible then
		task.defer(refreshPlayerList)
	end
end)

-- Title hint
Title.Text = "gab's Rings  •  v2.9  |  RShift = UI"

pcall(function()
	local userId = Players:GetUserIdFromNameAsync("Gabrieltod112")
	local thumb = Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
	StarterGui:SetCore("SendNotification", {
		Title = "gabs super ring v2.9",
		Text = "Player list · Auto · Multi · Spectate · RShift UI",
		Icon = thumb,
		Duration = 5
	})
end)


]===])
		if not fn then
			Library:Notify({ Title = "GABS SUPER RING", Content = "Compile error: " .. tostring(err), Type = "Error", Duration = 5 })
			return
		end
		local ok, e = pcall(fn)
		if not ok then
			Library:Notify({ Title = "GABS SUPER RING", Content = "Runtime: " .. tostring(e), Type = "Error", Duration = 5 })
		else
			Library:Notify({ Title = "GABS SUPER RING", Content = "Loaded (embedded).", Type = "Success", Duration = 3 })
		end
	end,
})
opSec:AddButton({ Name = "supering by foxy9694", Callback = safeLoad("supering by foxy9694", "https://raw.githubusercontent.com/northernline23/Super-ring-parts-V1/refs/heads/main/script.lua") })

----------------------------------------------------------------------
-- OTHER GAMES
----------------------------------------------------------------------
local Other = Window:AddTab({ Name = "Other Games", Description = "Game-specific scripts." })
local otherSec = Other:AddSection("Scripts")
otherSec:AddButton({ Name = "gab's aimbot", Callback = safeLoad("gab's aimbot", "https://raw.githubusercontent.com/im-the-username/gab-s-aimbot/refs/heads/main/Aimbot.lua") })
otherSec:AddButton({
	Name = "Doors Script",
	Description = "Link not configured in source",
	Callback = function()
		Library:Notify({ Title = "Doors Script", Content = "Script link is not set (placeholder in original).", Type = "Warning", Duration = 3 })
	end,
})

----------------------------------------------------------------------
-- OWNER
----------------------------------------------------------------------
if isOwner then
	local OwnerTab = Window:AddTab({ Name = "Owner", Description = "Detect users running Operation Rage and kill them." })
	local ownerSec = OwnerTab:AddSection("Detected users")
	local statusLbl = ownerSec:AddLabel("Scanning…")
	local detected = {}
	local drop = ownerSec:AddDropdown({
		Name = "Select user",
		Options = { "None" },
		Default = "None",
	})

	local function refreshOwnerList()
		detected = {}
		local opts = {}
		for _, plr in pairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer and isUsingScript(plr) then
				table.insert(detected, plr)
				table.insert(opts, plr.DisplayName .. " (@" .. plr.Name .. ")")
			end
		end
		if #opts == 0 then
			opts = { "None" }
			statusLbl:SetText("No other users detected")
		else
			statusLbl:SetText(#opts .. " user(s) running the script")
		end
		drop:SetOptions(opts)
	end

	ownerSec:AddButton({ Name = "Refresh list", Callback = refreshOwnerList })
	ownerSec:AddButton({
		Name = "Kill selected",
		Callback = function()
			local sel = drop:Get()
			if not sel or sel == "None" then
				Library:Notify({ Title = "Owner", Content = "No user selected.", Type = "Warning", Duration = 2 })
				return
			end
			for _, plr in ipairs(detected) do
				local label = plr.DisplayName .. " (@" .. plr.Name .. ")"
				if label == sel then
					attemptKill(plr)
					Library:Notify({ Title = "Owner", Content = "Kill attempted on " .. plr.DisplayName, Type = "Error", Duration = 2 })
					return
				end
			end
		end,
	})
	ownerSec:AddButton({
		Name = "Kill all detected",
		Callback = function()
			refreshOwnerList()
			for _, plr in ipairs(detected) do attemptKill(plr) end
			Library:Notify({ Title = "Owner", Content = "Kill attempted on " .. #detected .. " user(s)", Type = "Error", Duration = 2 })
		end,
	})

	refreshOwnerList()
	task.spawn(function()
		while task.wait(3) do refreshOwnerList() end
	end)
	Players.PlayerAdded:Connect(function() task.wait(1) refreshOwnerList() end)
	Players.PlayerRemoving:Connect(refreshOwnerList)
end

----------------------------------------------------------------------
-- MUSIC
----------------------------------------------------------------------
local Music = Window:AddTab({ Name = "Music", Description = "Client-sided music player only you can hear." })
local musicSec = Music:AddSection("Player")
local songDrop = musicSec:AddDropdown({
	Name = "Song",
	Options = songNames,
	Default = songNames[1],
})
local idBox = musicSec:AddTextbox({ Name = "Or paste Audio ID", Placeholder = "e.g. 142376088", Default = "" })
musicSec:AddButton({
	Name = "Play selected / ID",
	Callback = function()
		local id = tonumber(idBox:Get())
		if not id then
			local name = songDrop:Get()
			id = songByName[name]
		end
		if id then
			playSong(id)
			Library:Notify({ Title = "Music", Content = "Playing " .. tostring(id), Type = "Success", Duration = 2 })
		else
			Library:Notify({ Title = "Music", Content = "Pick a song or enter an ID.", Type = "Warning", Duration = 2 })
		end
	end,
})
musicSec:AddButton({
	Name = "Pause / Resume",
	Callback = function()
		if not currentSound then
			Library:Notify({ Title = "Music", Content = "Nothing is playing.", Type = "Info", Duration = 2 })
			return
		end
		if isPlaying then
			currentSound:Pause()
			isPlaying = false
		else
			currentSound:Resume()
			isPlaying = true
		end
	end,
})
musicSec:AddButton({ Name = "Stop", Callback = stopSong })
musicSec:AddSlider({
	Name = "Volume", Min = 0, Max = 100, Default = 50, Increment = 5, Suffix = "%",
	Callback = function(v)
		currentVol = v / 100
		if currentSound then currentSound.Volume = currentVol end
	end,
})
musicSec:AddSlider({
	Name = "Speed", Min = 50, Max = 200, Default = 100, Increment = 10, Suffix = "%",
	Callback = function(v)
		currentSpeed = v / 100
		if currentSound then currentSound.PlaybackSpeed = currentSpeed end
	end,
})

----------------------------------------------------------------------
-- SETTINGS
----------------------------------------------------------------------
local SettingsTab = Window:AddTab({ Name = "Settings", Description = "Keybind, NDS preferences, appearance." })
local look = SettingsTab:AddSection("Appearance")
look:AddDropdown({
	Name = "Theme",
	Options = Library.ThemeNames,
	Default = "Rose",
	Callback = function(name) if name then Library:SetTheme(name) end end,
})

local keySec = SettingsTab:AddSection("Menu keybind")
keySec:AddLabel("Open the Keybinds tab to change the menu toggle key. Default: " .. (Settings.ToggleKey or "RightControl"))
pcall(function()
	if Window.ToggleBind then
		Window.ToggleBind:OnChanged(function(key)
			if key then
				Settings.ToggleKey = key.Name
				saveSettings()
			end
		end)
	end
end)

local ndsSet = SettingsTab:AddSection("Natural Disaster Survival")
ndsSet:AddToggle({
	Name = "Don't prompt me again",
	Default = Settings.NDS_DontPrompt == true,
	Callback = function(v)
		Settings.NDS_DontPrompt = v
		saveSettings()
	end,
})
ndsSet:AddToggle({
	Name = "Auto-load NDS preset",
	Description = "Only applies when Don't prompt is also on",
	Default = Settings.NDS_AutoLoad == true,
	Callback = function(v)
		Settings.NDS_AutoLoad = v
		saveSettings()
	end,
})
ndsSet:AddButton({ Name = "Reset NDS preferences", Callback = function()
	Settings.NDS_DontPrompt = false
	Settings.NDS_AutoLoad = false
	saveSettings()
	Library:Notify({ Title = "NDS", Content = "Will ask again next time you join NDS.", Type = "Info", Duration = 3 })
end })

local manage = SettingsTab:AddSection("Window")
manage:AddButton({ Name = "Minimize", Callback = function() Window:SetMinimized(true) end })
manage:AddButton({
	Name = "Unload Operation Rage",
	Description = "Closes the UI and stops the script host UI",
	Callback = function()
		stopSong()
		Library:Unload()
	end,
})

Window:AddKeybindsTab()

----------------------------------------------------------------------
-- NDS STARTUP
----------------------------------------------------------------------
task.spawn(function()
	task.wait(1.2)
	if not isNDS() then return end
	if Settings.NDS_DontPrompt then
		if Settings.NDS_AutoLoad then runNDSPreset() end
		return
	end
	Library:Notify({
		Title = "Natural Disaster Survival",
		Content = "Load recommended preset? Open Settings to change auto-load, or press this notification then use Misc → Load NDS preset.",
		Type = "Warning",
		Duration = 0,
		Callback = function()
			runNDSPreset()
		end,
	})
end)

task.delay(0.8, function()
	Library:Notify({
		Title = "Operation Rage",
		Content = "Welcome. Toggle key: " .. (Settings.ToggleKey or "RightControl"),
		Type = "Success",
		Duration = 4,
	})
end)
]=====]
		local fn, loadErr = loadstring(src)
		if not fn then
			error("loadstring failed: " .. tostring(loadErr))
		end
		fn()
	end)

	if not okUI then
		warn("[Ms fent] Operation Rage failed: " .. tostring(errUI))
	end

	local tel = (getgenv().__MsFent_IsNDSGame and getgenv().__MsFent_IsNDSGame()) and "Ms fent Hub | Operation Rage (NDS)" or "Ms fent Hub | Operation Rage"
	pcall(__MsFent_SendTelemetry, tel)
	return
end






-- ============================================================
-- Doors path — ZERO Abysall remote components
-- UI = public Obsidian (deividcomsono)
-- Logic = inlined Abysall Main/Env/ESP/STX (no Analytics/InfoTab)
-- ============================================================
if getgenv().MsFentLoaded then
	warn("[Ms fent Hub] Already loaded (Doors)")
	return
end
getgenv().MsFentLoaded = true
shared.Hastelepasta = true

pcall(function()
	if __MsFent_SendTelemetry then __MsFent_SendTelemetry("Ms fent Hub | Doors") end
end)

getgenv().MsFent = getgenv().MsFent or {}
getgenv().MsFent.LatestChangelog = {
	"unknown date",
	"<font color='rgb(100, 0, 100)'>* Meow OwO </font>",
	"<font color='rgb(100, 0, 100)'>* Love u all cuties :3</font>",
	"<font color='rgb(100, 0, 100)'>* mrow :3</font>",
	"3/11/2026",
	"<font color='rgb(0, 255, 0)'>+ Fixed the speed bypass</font>",
	"<font color='rgb(0, 255, 0)'>+ Halloween update bwah</font>",
	"<font color='rgb(0, 255, 0)'>+ Weaveling + Creak Halloween entity notify/ESP</font>",
	"<font color='rgb(0, 255, 0)'>+ Halloween tab: skip cutscenes, remove fog, candy</font>",
	"<font color='rgb(0, 255, 0)'>+ Glue To Ground restored</font>",
	"<font color='rgb(0, 255, 0)'>+ Chair Anticheat Bypass (Archives)</font>",
	"<font color='rgb(0, 255, 0)'>+ Owner tab (you only)</font>",
	"<font color='rgb(0, 255, 0)'>+ No Abysall remote components</font>",
	"11/10/2026",
	"<font color='rgb(0, 255, 0)'>+ lobby / loading screen</font>",
	"9/10/2026",
	"<font color='rgb(0, 255, 0)'>+ stairwell related fixes</font>",
	"<font color='rgb(0, 255, 0)'>+ auto hotel (a little broken but works)</font>",
	"<font color='rgb(0, 255, 0)'>+ skip seek hotel+mines</font>",
	"<font color='rgb(0, 255, 0)'>+ fixed glue to ground</font>",
	"2/10/2026",
	"<font color='rgb(255, 255, 255)'>* Project msfent is expanding!</font>",
	"<font color='rgb(255, 255, 255)'>* NDS gui integrated — all in one project</font>",
	"30/9/2026",
	"<font color='rgb(0, 255, 0)'>fixed more entity stuff</font>",
	"<font color='rgb(0, 255, 0)'>+ Working anti screech :3</font>",
	"<font color='rgb(0, 255, 0)'>+ debug menu</font>",
	"<font color='rgb(255, 0, 0)'>- non working anti screech</font>",
	"29/9/2026",
	"<font color='rgb(0, 255, 0)'>+ stairwell support :3</font>",
	"<font color='rgb(0, 255, 0)'>+ more archives support :3</font>",
	"<font color='rgb(255, 0, 0)'>- some glitches</font>",
}

local LoadStart = tick()

-- Public Obsidian UI (NOT Abysall)
local OBS = "https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/"
local function __MsFent_Http(url)
	return game:HttpGet(url)
end

local Library, SaveManager, ThemeManager
do
	local ok, err = pcall(function()
		Library = loadstring(__MsFent_Http(OBS .. "Library.lua"))()
		SaveManager = loadstring(__MsFent_Http(OBS .. "addons/SaveManager.lua"))()
		ThemeManager = loadstring(__MsFent_Http(OBS .. "addons/ThemeManager.lua"))()
	end)
	if not ok or not Library then
		getgenv().MsFentLoaded = nil
		shared.Hastelepasta = nil
		error("[Ms fent] Failed to load Obsidian UI: " .. tostring(err))
	end
	ThemeManager:SetLibrary(Library)
	SaveManager:SetLibrary(Library)
	SaveManager:IgnoreThemeSettings()
	SaveManager:SetFolder("MsFent/Doors")
	ThemeManager:SetFolder("MsFent")
end

-- Inlined STX
getgenv().__MsFent_STX = nil
pcall(function()
	getgenv().__MsFent_STX = loadstring([==[-- orignal resource: https://github.com/BocusLuke/UI/blob/main/STX

local GUI = game:GetService("CoreGui"):FindFirstChild("STX_Nofitication")
if not GUI then
    local STX_Nofitication = Instance.new("ScreenGui")
    local STX_NofiticationUIListLayout = Instance.new("UIListLayout")
    STX_Nofitication.Name = "STX_Nofitication"
    STX_Nofitication.Parent = game.CoreGui
    STX_Nofitication.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    STX_Nofitication.ResetOnSpawn = false
    
    STX_NofiticationUIListLayout.Name = "STX_NofiticationUIListLayout"
    STX_NofiticationUIListLayout.Parent = STX_Nofitication
    STX_NofiticationUIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    STX_NofiticationUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    STX_NofiticationUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
else
end

local Nofitication = {}

local GUI = game:GetService("CoreGui"):FindFirstChild("STX_Nofitication")
function Nofitication:Notify(nofdebug, middledebug, all)
    local SelectedType = string.lower(tostring(middledebug.Type))
    local ambientShadow = Instance.new("ImageLabel")
    local Window = Instance.new("Frame")
    local Outline_A = Instance.new("Frame")
    local WindowTitle = Instance.new("TextLabel")
    local WindowDescription = Instance.new("TextLabel")
    
    ambientShadow.Name = "ambientShadow"
    ambientShadow.Parent = GUI
    ambientShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    ambientShadow.BackgroundTransparency = 1.000
    ambientShadow.BorderSizePixel = 0
    ambientShadow.Position = UDim2.new(0.91525954, 0, 0.936809778, 0)
    ambientShadow.Size = UDim2.new(0, 0, 0, 0)
    ambientShadow.Image = "rbxassetid://1316045217"
    ambientShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    ambientShadow.ImageTransparency = 0.400
    ambientShadow.ScaleType = Enum.ScaleType.Slice
    ambientShadow.SliceCenter = Rect.new(10, 10, 118, 118)
    
    Window.Name = "Window"
    Window.Parent = ambientShadow
    Window.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Window.BorderSizePixel = 0
    Window.Position = UDim2.new(0, 5, 0, 5)
    Window.Size = UDim2.new(0, 230, 0, 80)
    Window.ZIndex = 2
    
    Outline_A.Name = "Outline_A"
    Outline_A.Parent = Window
    Outline_A.BackgroundColor3 = middledebug.OutlineColor
    Outline_A.BorderSizePixel = 0
    Outline_A.Position = UDim2.new(0, 0, 0, 25)
    Outline_A.Size = UDim2.new(0, 230, 0, 2)
    Outline_A.ZIndex = 5
    
    WindowTitle.Name = "WindowTitle"
    WindowTitle.Parent = Window
    WindowTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    WindowTitle.BackgroundTransparency = 1.000
    WindowTitle.BorderColor3 = Color3.fromRGB(27, 42, 53)
    WindowTitle.BorderSizePixel = 0
    WindowTitle.Position = UDim2.new(0, 8, 0, 2)
    WindowTitle.Size = UDim2.new(0, 222, 0, 22)
    WindowTitle.ZIndex = 4
    WindowTitle.Font = Enum.Font.GothamSemibold
    WindowTitle.Text = nofdebug.Title
    WindowTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
    WindowTitle.TextSize = 12.000
    WindowTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    WindowDescription.Name = "WindowDescription"
    WindowDescription.Parent = Window
    WindowDescription.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    WindowDescription.BackgroundTransparency = 1.000
    WindowDescription.BorderColor3 = Color3.fromRGB(27, 42, 53)
    WindowDescription.BorderSizePixel = 0
    WindowDescription.Position = UDim2.new(0, 8, 0, 34)
    WindowDescription.Size = UDim2.new(0, 216, 0, 40)
    WindowDescription.ZIndex = 4
    WindowDescription.Font = Enum.Font.GothamSemibold
    WindowDescription.Text = nofdebug.Description
    WindowDescription.TextColor3 = Color3.fromRGB(180, 180, 180)
    WindowDescription.TextSize = 12.000
    WindowDescription.TextWrapped = true
    WindowDescription.TextXAlignment = Enum.TextXAlignment.Left
    WindowDescription.TextYAlignment = Enum.TextYAlignment.Top

    if SelectedType == "default" then
        local function ORBHB_fake_script()
            local script = Instance.new('LocalScript', ambientShadow)
        
            ambientShadow:TweenSize(UDim2.new(0, 240, 0, 90), "Out", "Linear", 0.2)
            Window.Size = UDim2.new(0, 230, 0, 80)
            if typeof(middledebug.Time) == "Instance" then
                middledebug.Time.Destroying:Wait()
            else
                Outline_A:TweenSize(UDim2.new(0, 0, 0, 2), "Out", "Linear", middledebug.Time)
                wait(middledebug.Time)
            end
        
            ambientShadow:TweenSize(UDim2.new(0, 0, 0, 0), "Out", "Linear", 0.2)
            
            wait(0.2)
            ambientShadow:Destroy()
        end
        coroutine.wrap(ORBHB_fake_script)()
    elseif SelectedType == "image" then
        ambientShadow:TweenSize(UDim2.new(0, 240, 0, 90), "Out", "Linear", 0.2)
        Window.Size = UDim2.new(0, 230, 0, 80)
        WindowTitle.Position = UDim2.new(0, 24, 0, 2)
        local ImageButton = Instance.new("ImageButton")
        ImageButton.Parent = Window
        ImageButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ImageButton.BackgroundTransparency = 1.000
        ImageButton.BorderSizePixel = 0
        ImageButton.Position = UDim2.new(0, 4, 0, 4)
        ImageButton.Size = UDim2.new(0, 18, 0, 18)
        ImageButton.ZIndex = 5
        ImageButton.AutoButtonColor = false
        ImageButton.Image = all.Image
        ImageButton.ImageColor3 = all.ImageColor

        local function ORBHB_fake_script()
            local script = Instance.new('LocalScript', ambientShadow)

            if typeof(middledebug.Time) == "Instance" then
                middledebug.Time.Destroying:Wait()
            else
                Outline_A:TweenSize(UDim2.new(0, 0, 0, 2), "Out", "Linear", middledebug.Time)
                wait(middledebug.Time)
            end
        
            ambientShadow:TweenSize(UDim2.new(0, 0, 0, 0), "Out", "Linear", 0.2)
            
            wait(0.2)
            ambientShadow:Destroy()
        end
        coroutine.wrap(ORBHB_fake_script)()
    elseif SelectedType == "option" then
        ambientShadow:TweenSize(UDim2.new(0, 240, 0, 110), "Out", "Linear", 0.2)
        Window.Size = UDim2.new(0, 230, 0, 100)
        local Uncheck = Instance.new("ImageButton")
        local Check = Instance.new("ImageButton")
        
        Uncheck.Name = "Uncheck"
        Uncheck.Parent = Window
        Uncheck.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Uncheck.BackgroundTransparency = 1.000
        Uncheck.BorderSizePixel = 0
        Uncheck.Position = UDim2.new(0, 7, 0, 76)
        Uncheck.Size = UDim2.new(0, 18, 0, 18)
        Uncheck.ZIndex = 5
        Uncheck.AutoButtonColor = false
        Uncheck.Image = "http://www.roblox.com/asset/?id=6031094678"
        Uncheck.ImageColor3 = Color3.fromRGB(255, 84, 84)
        
        Check.Name = "Check"
        Check.Parent = Window
        Check.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Check.BackgroundTransparency = 1.000
        Check.BorderSizePixel = 0
        Check.Position = UDim2.new(0, 28, 0, 76)
        Check.Size = UDim2.new(0, 18, 0, 18)
        Check.ZIndex = 5
        Check.AutoButtonColor = false
        Check.Image = "http://www.roblox.com/asset/?id=6031094667"
        Check.ImageColor3 = Color3.fromRGB(83, 230, 50)

        local function ORBHB_fake_script()
            local script = Instance.new('LocalScript', ambientShadow)
        
            local Stilthere = true
            local function Unchecked()
                pcall(function()
                    all.Callback(false)
                end)
                ambientShadow:TweenSize(UDim2.new(0, 0, 0, 0), "Out", "Linear", 0.2)
                
                wait(0.2)
                ambientShadow:Destroy()
                Stilthere = false
            end
            local function Checked()
                pcall(function()
                    all.Callback(true)
                end)
                ambientShadow:TweenSize(UDim2.new(0, 0, 0, 0), "Out", "Linear", 0.2)
                
                wait(0.2)
                ambientShadow:Destroy()
                Stilthere = false
            end
            Uncheck.MouseButton1Click:Connect(Unchecked)
            Check.MouseButton1Click:Connect(Checked)
            
            Outline_A:TweenSize(UDim2.new(0, 0, 0, 2), "Out", "Linear", middledebug.Time)
    
            wait(middledebug.Time)

            if Stilthere == true then
        
                ambientShadow:TweenSize(UDim2.new(0, 0, 0, 0), "Out", "Linear", 0.2)
                
                wait(0.2)
                ambientShadow:Destroy()
            end
        end
        coroutine.wrap(ORBHB_fake_script)()
    end
end

return Nofitication
]==])()
end)

-- Inlined Environment
local function __MsFent_LoadEnvironment()
local Environment = {}
local Log = {}
local Tested = 0
local Failed = 0
local Passed = 0

local BrokenFeatures = {
	["Volcano"] = {"run_on_actor", "oth"},
	["Opiumware"] = {"gethiddenproperty"},
	["Solara"] = {"require"},
	["Xeno"] = {"require"},
}

local RootEnv = getfenv(0)

local function GetGlobal(Path)
	local Value = RootEnv
	while Value ~= nil and Path ~= "" do
		local Name, NextPath = string.match(Path, "^([^.]+)%.?(.*)$")
		Value = Value[Name]
		Path = NextPath
	end
	return Value
end

local Global = setmetatable({}, {
	__index = function(Self, Name)
		return GetGlobal(Name)
	end,
})

local Services = setmetatable({}, {
	__index = function(Self, Name)
		return game:GetService(Name)
	end,
})

local Results = {}

local function AddResult(Name, Text, DidPass)
	table.insert(Results, Text)
	Log[Name] = {
		Passed = DidPass,
		Reason = Text,
	}
end

Environment.Results = Results
Environment.PrintResults = function()
	local Executor = Environment.identifyexecutor and Environment.identifyexecutor() or "Unknown"
	print("Test Result")
	for _, Result in ipairs(Results) do
		print(Result)
		task.wait()
	end
	print("Executor - " .. Executor)
	print("Tests Passed: " .. Passed .. "/" .. Tested)
	print("Test Score: " .. math.floor((Passed / Tested) * 100 + 0.5) .. "%")
end

local function RunTest(Name, Test, InternalName)
	local TimedOut = false
	Tested = Tested + 1

	local ExecutorName = Global.identifyexecutor and Global.identifyexecutor() or "Unknown"
	local BrokenList = BrokenFeatures[ExecutorName]
	if BrokenList and table.find(BrokenList, Name) then
		AddResult(Name, "❌ " .. Name .. " failed: test has been skipped", false)
		Failed = Failed + 1
		return
	end

	local TargetGlobal = Global[Name]
	if not TargetGlobal then
		AddResult(Name, "❌ " .. Name .. " failed: function is nil", false)
		Failed = Failed + 1
		return
	end

	local Time = 0
	local Finished = false

	task.spawn(function()
		local Success, Result = pcall(Test)
		if not TimedOut then
			if Success then
				local Key = InternalName or Name
				Environment[Key] = TargetGlobal
				AddResult(Name, "✅ " .. Name, true)
				Passed = Passed + 1
			else
				AddResult(Name, "❌ " .. Name .. " failed: " .. tostring(Result), false)
				Failed = Failed + 1
			end
		end
		Finished = true
	end)

	while not Finished do
		Time = Time + 1
		if Time > 100 then
			AddResult(Name, "❌ " .. Name .. " failed: test timed out", false)
			Failed = Failed + 1
			TimedOut = true
			break
		end
		task.wait(0.1)
	end
end

RunTest("getgenv", function()
	assert(typeof(Global.getgenv()) == "table", "Did not return a table")
	Global.getgenv().Example = "Test"
	assert(Example == "Test", "Failed to set a global variable")
	Global.getgenv().Example = nil
end)

RunTest("getrenv", function()
	assert(Environment.getgenv, "getgenv is required to test")
	local Env = Global.getrenv()
	assert(typeof(Env) == "table", "Did not return a table")
	assert(typeof(Env.print) == "function", "Did not return an environment table")
	assert(Global.getrenv ~= Global.getgenv, "getrenv is an alias of getgenv")
	assert(Global.getgenv() ~= Global.getrenv(), "Returned executor environment")
	local Success = pcall(function()
		return Env.loadstring([[return 10]])()
	end)
	assert(Success == false, "Should error when calling loadstring from roblox environment")
end)

RunTest("getgc", function()
	local TestFunction = function()
		return 10
	end
	local TestTable = { Value = 10 }
	local YesTables = Global.getgc(true)
	local NoTables = Global.getgc(false)
	assert(table.find(YesTables, TestTable), "Failed to find a table")
	assert(table.find(YesTables, TestFunction), "Failed to find a function")
	assert(not table.find(NoTables, TestTable), "Should not return a table when called with false")
	assert(table.find(NoTables, TestFunction), "Failed to find a function")
end)

RunTest("identifyexecutor", function()
	assert(typeof(Global.identifyexecutor()) == "string", "Did not return a string")
end)

RunTest("request", function()
	local Response = Global.request({
		Url = "https://httpbin.org/status/200",
		Method = "GET",
	})
	assert(Response.StatusCode == 200, "Status code should be 200")
	assert(typeof(Response.Body) == "string", "Body should be a string")
end)

RunTest("cloneref", function()
	local TestPart = Instance.new("Part")
	local Clone = Global.cloneref(TestPart)
	assert(typeof(Clone) == "Instance", "Should return an Instance")
	assert(TestPart ~= Clone, "Clone should not be equal to original")
	TestPart.Name = "Test"
	assert(Clone.Name == "Test", "Changing the original did not change the clone")
	TestPart:Destroy()
end)

RunTest("gethui", function()
	local Hui = Global.gethui()
	assert(typeof(Hui) == "Instance", "Should return an instance")
	local ValidClasses = { "ScreenGui", "Folder", "BasePlayerGui", "CoreGui" }
	if not Hui:IsDescendantOf(Services.CoreGui) and Hui.ClassName ~= "CoreGui" or not table.find(ValidClasses, Hui.ClassName) then
		error("Did not return a valid gui container")
	end
end)

RunTest("getcallbackvalue", function()
	local TestBindable = Instance.new("BindableFunction")
	TestBindable.OnInvoke = function(Value)
		return Value * 10
	end
	local Callback = Global.getcallbackvalue(TestBindable, "OnInvoke")
	local Success, Result = pcall(function()
		assert(typeof(Callback) == "function", "Did not return a function")
		assert(Callback(5) == 50, "Did not return the callback value")
	end)
	TestBindable:Destroy()
	assert(Success, Result)
end)

RunTest("getinstances", function()
	local TestPart1 = Instance.new("Part")
	local TestPart2 = Instance.new("Part", Services.Workspace)
	local InstanceList = Global.getinstances()
	local Found1 = table.find(InstanceList, TestPart1)
	local Found2 = table.find(InstanceList, TestPart2)
	TestPart1:Destroy()
	TestPart2:Destroy()
	assert(Found2, "Did not return an instance")
	assert(Found1, "Did not return an instance parented to nil")
end)

RunTest("getnilinstances", function()
	local TestPart1 = Instance.new("Part")
	local TestPart2 = Instance.new("Part", Services.Workspace)
	local InstanceList = Global.getnilinstances()
	local FoundNil = table.find(InstanceList, TestPart1)
	local FoundParented = table.find(InstanceList, TestPart2)
	TestPart1:Destroy()
	TestPart2:Destroy()
	assert(not FoundParented, "Returned an instance not parented to nil")
	assert(FoundNil, "Did not return an instance parented to nil")
end)

RunTest("fireproximityprompt", function()
	local TestPart = Instance.new("Part", Services.Workspace)
	local TestPrompt = Instance.new("ProximityPrompt", TestPart)
	local Fired = false
	local Connection = TestPrompt.Triggered:Connect(function()
		Fired = true
	end)
	Global.fireproximityprompt(TestPrompt)
	local Tries = 0
	while not Fired and Tries < 10 do
		Tries = Tries + 1
		task.wait(0.1)
	end
	Connection:Disconnect()
	TestPart:Destroy()
	assert(Fired == true, "Failed to fire a proximity prompt")
end)

RunTest("fireclickdetector", function()
	local TestPart = Instance.new("Part", Services.Workspace)
	local TestClick = Instance.new("ClickDetector", TestPart)
	local Fired = false
	local Connection = TestClick.MouseClick:Connect(function()
		Fired = true
	end)
	Global.fireclickdetector(TestClick)
	local Tries = 0
	while not Fired and Tries < 10 do
		Tries = Tries + 1
		task.wait(0.1)
	end
	Connection:Disconnect()
	TestPart:Destroy()
	assert(Fired == true, "Failed to fire a click detector")
end)

RunTest("firetouchinterest", function()
	local TestPart1 = Instance.new("Part", Services.Workspace)
	TestPart1.Position = Vector3.new(0, 1000, 0)
	local TestPart2 = Instance.new("Part", Services.Workspace)
	TestPart2.Position = Vector3.new(0, 1000, 0)
	local Fired = false
	local Connection = TestPart1.Touched:Connect(function(Child)
		if Child == TestPart2 then
			Fired = true
		end
	end)
	Global.firetouchinterest(TestPart1, TestPart2, 0)
	task.wait()
	Global.firetouchinterest(TestPart1, TestPart2, 1)
	local Tries = 0
	while not Fired and Tries < 10 do
		Tries = Tries + 1
		task.wait(0.1)
	end
	Connection:Disconnect()
	TestPart1:Destroy()
	TestPart2:Destroy()
	assert(Fired == true, "Failed to fire a touch interest")
end)

RunTest("clonefunction", function()
	local TestFunction = function()
		return 10
	end
	local TestClone = Global.clonefunction(TestFunction)
	assert(TestFunction ~= TestClone, "Returned the original function")
	assert(TestFunction() == TestClone(), "Clone did not return the same as the original")
end)

RunTest("newcclosure", function()
	local TestFunction = function()
		return 10
	end
	local TestC = Global.newcclosure(TestFunction)
	assert(TestFunction ~= TestC, "Returned the original function")
	assert(TestFunction() == TestC(), "Did not return the same value as the original")
	assert(TestC() == 10, "Did not return the correct value")
	assert(debug.info(TestC, "s") == "[C]", "Did not return a C function")
end)

RunTest("hookfunction", function()
	local TestFunction = function()
		return 10
	end
	local TestC = Global.newcclosure(function()
		return 25
	end)
	local TestHook = function()
		return 100
	end
	local Old = Global.hookfunction(TestFunction, TestHook)
	local OldC = Global.hookfunction(TestC, TestHook)
	assert(TestFunction ~= TestHook, "Original and hook are the same function")
	assert(debug.info(TestC, "s") == "[C]", "Hooked C function is no longer in C")
	assert(TestFunction() == 100, "Did not change the return value")
	assert(Old() == 10, "Did not return the original function")
	assert(OldC() == 25, "Did not return the original C function")
end)

RunTest("restorefunction", function()
	assert(Environment.hookfunction, "hookfunction is required to test")
	local TestFunction = function()
		return 10
	end
	local TestHook = function()
		return 100
	end
	Global.hookfunction(TestFunction, TestHook)
	Global.restorefunction(TestFunction)
	assert(TestFunction() == 10, "Failed to unhook a function")
end)

RunTest("isfunctionhooked", function()
	assert(Environment.hookfunction, "hookfunction is required to test")
	assert(Environment.restorefunction, "restorefunction is required to test")
	local TestFunction = function()
		return 10
	end
	local TestHook = function()
		return 100
	end
	Global.hookfunction(TestFunction, TestHook)
	assert(Global.isfunctionhooked(TestFunction) == true, "Did not return true for a hooked function")
	Global.restorefunction(TestFunction)
	assert(Global.isfunctionhooked(TestFunction) == false, "Did not return false for an unhooked function")
end)

RunTest("isexecutorclosure", function()
	assert(Environment.newcclosure, "newcclosure is required to test")
	local TestFunction = function()
		return 10
	end
	local TestC = Global.newcclosure(TestFunction)
	assert(Global.isexecutorclosure(TestFunction) == true, "Did not return true for an executor function")
	assert(Global.isexecutorclosure(Global.newcclosure) == true, "Did not return true for an executor global")
	assert(Global.isexecutorclosure(warn) == false, "Did not return false for a Roblox global")
	assert(Global.isexecutorclosure(TestC) == true, "Did not return true for an executor C function")
end)

RunTest("getnamecallmethod", function()
	pcall(function()
		game:ExampleNamecall()
	end)
	assert(typeof(Global.getnamecallmethod()) == "string", "Did not return a string")
	assert(Global.getnamecallmethod() == "ExampleNamecall", "Did not return the correct method")
end)

RunTest("hookmetamethod", function()
	assert(Environment.getnamecallmethod, "getnamecallmethod is required to test")
	assert(Environment.newcclosure, "newcclosure is required to test")
	local TestTable = setmetatable({}, {
		__index = Global.newcclosure(function()
			return "normal"
		end),
	})
	Global.hookmetamethod(TestTable, "__index", Global.newcclosure(function()
		return "hooked"
	end))
	assert(TestTable.Example == "hooked", "Failed to hook a metamethod")
end)

RunTest("getrawmetatable", function()
	local TestTable = { __metatable = "Locked!" }
	local TestObject = setmetatable({}, TestTable)
	assert(Global.getrawmetatable(TestObject) == TestTable, "Did not return the metatable")
end)

RunTest("setrawmetatable", function()
	assert(Environment.getrawmetatable, "getrawmetatable is required to test")
	local TestTable = { __metatable = "Locked!" }
	local TestObject = setmetatable({}, TestTable)
	Global.setrawmetatable(TestObject, {
		__index = function()
			return "Edited!"
		end,
	})
	assert(TestObject.Example == "Edited!", "Failed to set the metatable")
end)

RunTest("isreadonly", function()
	local TestTable = {}
	local FrozenTable = table.freeze({})
	assert(Global.isreadonly(TestTable) == false, "Did not return false for a writeable table")
	assert(Global.isreadonly(FrozenTable) == true, "Did not return true for a readonly table")
end)

RunTest("setreadonly", function()
	assert(Environment.isreadonly, "isreadonly is required to test")
	local TestTable = { Value = 10 }
	table.freeze(TestTable)
	Global.setreadonly(TestTable, false)
	TestTable.Value = 100
	assert(Global.isreadonly(TestTable) == false, "Failed to set readonly")
end)

RunTest("Drawing.new", function()
	assert(typeof(Global.Drawing.new) == "function", "Drawing.new is not a function")
	local NewShape = Global.Drawing.new("Circle")
	NewShape.Visible = false
	NewShape.Radius = 10
	NewShape.Thickness = 1
	NewShape.Filled = false
	NewShape.NumSides = 10
	NewShape:Remove()
end, "Drawing_New")

RunTest("Drawing.Fonts", function()
	assert(typeof(Global.Drawing.Fonts) == "table", "Drawing.Fonts is not a table")
end, "Drawing_Fonts")

RunTest("writefile", function()
	Global.writefile("Abysall_Test_File", "example")
	assert(Global.isfile("Abysall_Test_File") == true, "Failed to create a file")
	assert(Global.readfile("Abysall_Test_File") == "example", "File does not contain expected data")
end)

RunTest("isfile", function()
	assert(Global.isfile("Abysall_Test_File") == true, "Did not return true for a valid file")
end)

RunTest("readfile", function()
	assert(Global.readfile("Abysall_Test_File") == "example", "Did not return the expected data")
end)

RunTest("appendfile", function()
	Global.appendfile("Abysall_Test_File", "_appended")
	assert(Global.readfile("Abysall_Test_File") == "example_appended", "Failed to append content to a file")
end)

RunTest("loadfile", function()
	Global.writefile("Abysall_Test_Load", [[return 25]])
	assert(Global.loadfile("Abysall_Test_Load")() == 25, "Failed to load and execute a file")
end)

RunTest("delfile", function()
	Global.delfile("Abysall_Test_File")
	Global.delfile("Abysall_Test_Load")
	assert(Global.isfile("Abysall_Test_File") == false, "Failed to delete a file")
end)

RunTest("makefolder", function()
	Global.makefolder("Abysall_Test_Folder")
	assert(Global.isfolder("Abysall_Test_Folder") == true, "Failed to create a folder")
end)

RunTest("delfolder", function()
	Global.delfolder("Abysall_Test_Folder")
	assert(Global.isfolder("Abysall_Test_Folder") == false, "Failed to delete a folder")
end)

RunTest("listfiles", function()
	Global.makefolder("Abysall_ListFiles_Test")
	Global.writefile("Abysall_ListFiles_Test/Test1", "test 1")
	Global.writefile("Abysall_ListFiles_Test/Test2", "test 2")
	local FilesList = Global.listfiles("Abysall_ListFiles_Test")
	local Found1 = false
	local Found2 = false
	assert(#FilesList == 2, "Did not return the correct number of files")
	for _, File in ipairs(FilesList) do
		local Content = Global.readfile(File)
		if Content == "test 1" then
			Found1 = true
		elseif Content == "test 2" then
			Found2 = true
		end
	end
	Global.delfolder("Abysall_ListFiles_Test")
	assert(Found1 == true, "Did not return the first file")
	assert(Found2 == true, "Did not return the second file")
end)

RunTest("getcustomasset", function()
	assert(Environment.writefile, "writefile is required to test")
	local Content = game:HttpGet("rbxassetid://0")
	Global.writefile("Abysall_Test_Image", Content)
	local Asset = Global.getcustomasset("Abysall_Test_Image")
	local TestImage = Instance.new("ImageLabel", Services.CoreGui.RobloxGui)
	TestImage.Image = Asset
	local Tries = 0
	while not TestImage.IsLoaded and Tries < 10 do
		Tries = Tries + 1
		task.wait(0.1)
	end
	local IsLoaded = TestImage.IsLoaded
	TestImage:Destroy()
	Global.delfile("Abysall_Test_Image")
	assert(string.find(Asset, "rbxasset://"), "Should return an rbxasset id")
	assert(IsLoaded == true, "Failed to load a PNG image")
end)

RunTest("gethiddenproperty", function()
	local TestPart = Instance.new("Part")
	local Value = Global.gethiddenproperty(TestPart, "NetworkIsSleeping")
	TestPart:Destroy()
	assert(Value == false, "Did not return the correct property value")
end)

RunTest("sethiddenproperty", function()
	assert(Environment.gethiddenproperty, "gethiddenproperty is required to test")
	local TestPart = Instance.new("Part")
	Global.sethiddenproperty(TestPart, "NetworkIsSleeping", true)
	local Value = Global.gethiddenproperty(TestPart, "NetworkIsSleeping")
	TestPart:Destroy()
	assert(Value == true, "Failed to set a hidden property")
end)

RunTest("getthreadidentity", function()
	local Identity = Global.getthreadidentity()
	assert(typeof(Identity) == "number", "Did not return a number")
	assert(Identity > 0, "Returned an invalid identity")
	assert(Identity < 9, "Returned an invalid identity")
end)

RunTest("setthreadidentity", function()
	assert(Environment.getthreadidentity, "getthreadidentity is needed to test")
	local Old = Global.getthreadidentity()
	Global.setthreadidentity(2)
	assert(Services.CoreGui == nil, "Capabilities do not match set identity")
	Global.setthreadidentity(Old)
end)

RunTest("isnetworkowner", function()
	local Test = Instance.new("Part", Services.Workspace)
	local RootPart = Services.Players.LocalPlayer.Character.HumanoidRootPart
	local TestPart

	for _, Part in ipairs(Services.Workspace:GetDescendants()) do
		if Part:IsA("BasePart") and Part.Anchored then
			TestPart = Part
			break
		end
	end

	RootPart.Anchored = true
	local IsOwned = Global.isnetworkowner(RootPart)
	RootPart.Anchored = false

	local IsClientOwned = Global.isnetworkowner(Test)
	local IsNotOwned = TestPart and Global.isnetworkowner(TestPart)
	Test:Destroy()

	assert(TestPart ~= nil, "Skipped, no anchored part to test with")
	assert(IsClientOwned == true, "Did not return true for a client owned part")
	assert(IsNotOwned == false, "Did not return false for a non client owned part")
	assert(IsOwned == true, "Did not return true for a client owned anchored part")
end)

RunTest("firesignal", function()
	local TestEvent = Instance.new("RemoteEvent")
	local Fired = false
	local Value1, Value2, Value3
	local Connection = TestEvent.OnClientEvent:Connect(function(Arg1, Arg2, Arg3)
		Fired = true
		Value1 = Arg1
		Value2 = Arg2
		Value3 = Arg3
	end)
	Global.firesignal(TestEvent.OnClientEvent, "Example", 10, true)
	local Tries = 0
	while not Fired and Tries < 10 do
		Tries = Tries + 1
		task.wait(0.1)
	end
	Connection:Disconnect()
	TestEvent:Destroy()
	assert(Fired == true, "Failed to fire a signal")
	assert(Value1 == "Example", "Fired signal with incorrect data")
	assert(Value2 == 10, "Fired signal with incorrect data")
	assert(Value3 == true, "Fired signal with incorrect data")
end)

RunTest("replicatesignal", function()
	local TestButton = Instance.new("Frame")
	Global.replicatesignal(TestButton.MouseWheelForward, 69, 420)
	local Success = pcall(function()
		Global.replicatesignal(TestButton.MouseWheelForward)
		Global.replicatesignal(TestButton.MouseWheelForward, 69)
	end)
	TestButton:Destroy()
	assert(Success == false, "Did not throw an error with invalid arguments")
end)

RunTest("getconnections", function()
	local Fired = false
	local Connection = game.ChildAdded:Connect(function(Child)
		if Child == "Example" then
			Fired = true
		end
	end)
	for _, Conn in ipairs(getconnections(game.ChildAdded)) do
		Conn:Fire("Example")
	end
	local Tries = 0
	while not Fired and Tries < 10 do
		Tries = Tries + 1
		task.wait(0.1)
	end
	Connection:Disconnect()
	assert(Fired == true, "Failed to fire a connection's signals")
end)

RunTest("require", function()
	local TestScript = Global.require(Services.Players.LocalPlayer.PlayerScripts.PlayerModule)
	assert(typeof(TestScript) == "table", "Did not return a table")
	assert(typeof(TestScript.GetControls) == "function", "Did not return the expected data")
	local Original = TestScript.GetControls
	TestScript.GetControls = function()
		return "test"
	end
	assert(TestScript.GetControls() == "test", "Unable to change module values")
	TestScript.GetControls = Original
	TestScript = nil
end)

return Environment

end

-- Inlined ESP
local function __MsFent_LoadESP()
local Library = {
	Font = Enum.Font.RobotoCondensed,
	Rainbow = false,
	Tracers = false,
	Unloaded = false,
	ShowDistance = false,
	MatchColors = true,
	Arrows = false,
	TextTransparency = 0,
	TracerOrigin = "Bottom",
	FillTransparency = 0.75,
	OutlineTransparency = 0,
	TextOutlineTransparency = 0,
	FadeTime = 0,
	RenderLimit = 240,
	TracerSize = 0.5,
	ArrowRadius = 200,
	TextSize = 20,
	DistanceSizeRatio = 1,
	OutlineColor = Color3.fromRGB(255, 255, 255),
	RainbowColor = Color3.fromRGB(255, 255, 255),

	ElementsEnabled = {},
	TransparencyEnabled = {},
	Highlights = {},
	Labels = {},
	Frames = {},
	Lines = {},
	ArrowsTable = {},
	ColorTable = {},
	TextTable = {},
	ConnectionsTable = {},
	Objects = {},
	TotalObjects = {},
}

local RainbowState = {
	HueSetup = 0,
	Hue = 0,
	Step = 0,
	Color = Color3.new(),
}

local CloneReference = cloneref or function(O) return O end
local Players = CloneReference(game:GetService("Players"))
local CoreGui = getgenv and CloneReference(game:GetService("CoreGui")) or Players.LocalPlayer.PlayerGui
local Workspace = CloneReference(workspace)
local RunService = CloneReference(game:GetService("RunService"))
local TweenService = CloneReference(game:GetService("TweenService"))
local UserInputService = CloneReference(game:GetService("UserInputService"))
local Debris = CloneReference(game:GetService("Debris"))
local LocalPlayer = Players.LocalPlayer

local function GetHiddenUI()
	if gethui then return gethui() end
	local Folder = Instance.new("Folder", CoreGui)
	Folder.Name = ("%032x"):format(math.random(0, 2^31))
	return Folder
end

function Library:GenerateRandomString()
	local Chars = {}
	local Pool = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	local PoolLen = #Pool
	for I = 1, 24 do
		local Idx = math.random(1, PoolLen)
		Chars[I] = Pool:sub(Idx, Idx)
	end
	return table.concat(Chars)
end

local HiddenUI = GetHiddenUI()
local Camera = Workspace.CurrentCamera

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Name = Library:GenerateRandomString()
ScreenGui.Parent = HiddenUI

local HighlightsFolder = Instance.new("Folder")
HighlightsFolder.Name = Library:GenerateRandomString()
HighlightsFolder.Parent = ScreenGui

local BillboardsFolder = Instance.new("Folder")
BillboardsFolder.Name = Library:GenerateRandomString()
BillboardsFolder.Parent = ScreenGui

local TracersFrame = Instance.new("Frame")
TracersFrame.Size = UDim2.new(1, 0, 1, 0)
TracersFrame.BackgroundTransparency = 1
TracersFrame.Visible = false
TracersFrame.Name = Library:GenerateRandomString()
TracersFrame.Parent = ScreenGui

local ArrowsFrame = Instance.new("Frame")
ArrowsFrame.Size = UDim2.new(1, 0, 1, 0)
ArrowsFrame.BackgroundTransparency = 1
ArrowsFrame.Visible = false
ArrowsFrame.Name = Library:GenerateRandomString()
ArrowsFrame.Parent = ScreenGui

local ArrowTemplate = Instance.new("ImageLabel")
ArrowTemplate.Image = "rbxassetid://16368985219"
ArrowTemplate.Size = UDim2.new(0, 50, 0, 50)
ArrowTemplate.AnchorPoint = Vector2.new(0.5, 0.5)
ArrowTemplate.BackgroundTransparency = 1
ArrowTemplate.ImageTransparency = 1
local ArrowConstraint = Instance.new("UIAspectRatioConstraint")
ArrowConstraint.AspectRatio = 1
ArrowConstraint.Name = Library:GenerateRandomString()
ArrowConstraint.Parent = ArrowTemplate

local TweenInfoQuad = TweenInfo.new(0, Enum.EasingStyle.Quad)
local function MakeTween(Instance_, Props)
	local Info = TweenInfo.new(Library.FadeTime, Enum.EasingStyle.Quad)
	return TweenService:Create(Instance_, Info, Props)
end

local function PlayTween(Instance_, Props)
	MakeTween(Instance_, Props):Play()
end

local function DestroyObjectData(Object)
	local Highlight = Library.Highlights[Object]
	if Highlight then
		Highlight:Destroy()
		Library.Highlights[Object] = nil
	end

	local Frame = Library.Frames[Object]
	if Frame then
		Frame:Destroy()
		Library.Frames[Object] = nil
	end

	local LineData = Library.Lines[Object]
	if LineData then
		if LineData[1] then LineData[1]:Destroy() end
		Library.Lines[Object] = nil
	end

	local Arrow = Library.ArrowsTable[Object]
	if Arrow then
		Arrow:Destroy()
		Library.ArrowsTable[Object] = nil
	end

	local Conns = Library.ConnectionsTable[Object]
	if Conns then
		for _, Conn in ipairs(Conns) do
			Conn:Disconnect()
		end
		Library.ConnectionsTable[Object] = nil
	end

	Library.Labels[Object] = nil
	Library.ColorTable[Object] = nil
	Library.TextTable[Object] = nil
	Library.ElementsEnabled[Object] = nil
	Library.TransparencyEnabled[Object] = nil
	Library.Objects[Object] = nil

	for Idx = #Library.TotalObjects, 1, -1 do
		if Library.TotalObjects[Idx] == Object then
			table.remove(Library.TotalObjects, Idx)
			break
		end
	end
end

function Library:AddESP(Parameters)
	local Object = Parameters.Object
	if Library.ElementsEnabled[Object] == true or Library.Unloaded == true then return end
	if not Object:IsA("BasePart") and not Object:IsA("Model") then return end

	Library.ElementsEnabled[Object] = true
	Library.TransparencyEnabled[Object] = false
	Library.ConnectionsTable[Object] = Library.ConnectionsTable[Object] or {}

	if Library.Highlights[Object] then
		Library.Highlights[Object]:Destroy()
		Library.Highlights[Object] = nil
	end

	local Highlight = Instance.new("Highlight")
	Highlight.FillTransparency = 1
	Highlight.OutlineTransparency = 1
	Highlight.Name = Library:GenerateRandomString()
	Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	Highlight.Adornee = Object
	Highlight.Parent = HighlightsFolder
	Library.Highlights[Object] = Highlight

	local TextFrame = Instance.new("Frame")
	TextFrame.Visible = false
	TextFrame.Name = Library:GenerateRandomString()
	TextFrame.Size = UDim2.fromScale(1, 1)
	TextFrame.BackgroundTransparency = 1
	TextFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	TextFrame.Parent = BillboardsFolder

	local TextLabel = Instance.new("TextLabel")
	TextLabel.Name = Library:GenerateRandomString()
	TextLabel.BackgroundTransparency = 1
	TextLabel.Text = Parameters.Text
	TextLabel.TextTransparency = 1
	TextLabel.TextStrokeTransparency = Library.TextOutlineTransparency
	TextLabel.Size = UDim2.new(1, 0, 1, 0)
	TextLabel.Font = Library.Font
	TextLabel.TextSize = Library.TextSize
	TextLabel.RichText = true
	TextLabel.TextColor3 = Parameters.Color
	TextLabel.Parent = TextFrame

	Library.Frames[Object] = TextFrame
	Library.Labels[Object] = TextLabel
	Library.ColorTable[Object] = Parameters.Color
	Library.TextTable[Object] = Parameters.Text
	Library.Objects[Object] = Object
	table.insert(Library.TotalObjects, Object)

	PlayTween(Highlight, { FillTransparency = Library.FillTransparency })
	PlayTween(Highlight, { OutlineTransparency = Library.OutlineTransparency })

	local TextFadeIn = MakeTween(TextLabel, { TextTransparency = Library.TextTransparency })
	TextFadeIn.Completed:Once(function()
		Library.TransparencyEnabled[Object] = true
	end)
	TextFadeIn:Play()
	PlayTween(TextLabel, { TextStrokeTransparency = Library.TextOutlineTransparency })

	local LineFrame = Instance.new("Frame")
	LineFrame.Size = UDim2.new(0, 0, 0, 0)
	LineFrame.BackgroundTransparency = 1
	LineFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	LineFrame.Name = Library:GenerateRandomString()
	LineFrame.Parent = TracersFrame

	local Stroke = Instance.new("UIStroke")
	Stroke.Thickness = Library.TracerSize
	Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	Stroke.Transparency = 1
	Stroke.Name = Library:GenerateRandomString()
	Stroke.Parent = LineFrame

	PlayTween(LineFrame, { BackgroundTransparency = 0 })
	PlayTween(Stroke, { Transparency = 0 })
	Library.Lines[Object] = { LineFrame, Stroke }

	task.spawn(function()
		local Last = 0
		local MinInterval = 1 / Library.RenderLimit

		local function Render()
			if not Object or not Object:IsDescendantOf(game) then
				Library:RemoveESP(Object)
				return
			end

			local ObjectPos = Object:GetPivot().Position
			local ScreenPoint, OnScreen = Camera:WorldToViewportPoint(ObjectPos)

			local Frame = Library.Frames[Object]
			local Label = Library.Labels[Object]
			local CachedHighlight = Library.Highlights[Object]
			local LineData = Library.Lines[Object]

			if LineData and LineData[1] then
				LineData[1].Visible = OnScreen
			end

			if Frame then
				Frame.Visible = OnScreen
				if OnScreen then
					Frame.Position = UDim2.new(0, ScreenPoint.X, 0, ScreenPoint.Y)
				end
			end

			if not OnScreen then
				if CachedHighlight then
					CachedHighlight:Destroy()
					Library.Highlights[Object] = nil
					CachedHighlight = nil
				end
			elseif Library.ElementsEnabled[Object] == true and not CachedHighlight then
				CachedHighlight = Instance.new("Highlight")
				CachedHighlight.FillTransparency = 1
				CachedHighlight.OutlineTransparency = 1
				CachedHighlight.Name = Library:GenerateRandomString()
				CachedHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				CachedHighlight.Adornee = Object
				CachedHighlight.Parent = HighlightsFolder
				Library.Highlights[Object] = CachedHighlight
			end

			local ActiveColor = Library.Rainbow and RainbowState.Color or Library.ColorTable[Object] or Color3.fromRGB(255, 255, 255)

			if Label then
				Label.TextColor3 = ActiveColor
			end

			if CachedHighlight then
				local Distance = math.floor((Camera.CFrame.Position - ObjectPos).Magnitude)
				local DistanceText = Library.ShowDistance
					and ("\n" .. '<font size="' .. math.round(Library.TextSize * Library.DistanceSizeRatio) .. '">[' .. Distance .. ']</font>')
					or ""
				if Label then
					Label.Text = Library.TextTable[Object] .. DistanceText
				end

				CachedHighlight.Enabled = true
				CachedHighlight.FillColor = ActiveColor
				CachedHighlight.OutlineColor = Library.MatchColors and ActiveColor or Library.OutlineColor

				if Library.TransparencyEnabled[Object] == true then
					CachedHighlight.FillTransparency = Library.FillTransparency
					CachedHighlight.OutlineTransparency = Library.OutlineTransparency
					if Label then
						Label.TextTransparency = Library.TextTransparency
						Label.TextStrokeTransparency = Library.TextOutlineTransparency
					end
				end
			end

			if LineData and CachedHighlight and Library.Tracers == true and OnScreen then
				local ScreenSize = Camera.ViewportSize
				local Origin

				if Library.TracerOrigin == "Center" then
					Origin = Vector2.new(ScreenSize.X / 2, ScreenSize.Y / 2)
				elseif Library.TracerOrigin == "Top" then
					Origin = Vector2.new(ScreenSize.X / 2, 0)
				elseif Library.TracerOrigin == "Mouse" then
					local MouseLoc = UserInputService:GetMouseLocation()
					Origin = Vector2.new(LocalPlayer:GetMouse().X, MouseLoc.Y)
				else
					Origin = Vector2.new(ScreenSize.X / 2, ScreenSize.Y)
				end

				local Destination = Vector2.new(ScreenPoint.X, ScreenPoint.Y)
				local MidPoint = (Origin + Destination) / 2
				local Rotation = math.deg(math.atan2(Destination.Y - Origin.Y, Destination.X - Origin.X))
				local Length = (Origin - Destination).Magnitude
				local LF = LineData[1]
				local SK = LineData[2]

				LF.Position = UDim2.new(0, MidPoint.X, 0, MidPoint.Y)
				LF.Size = UDim2.new(0, Length, 0, 1)
				LF.Rotation = Rotation
				LF.BackgroundColor3 = ActiveColor
				LF.BorderSizePixel = 0
				LF.Visible = true
				SK.Color = ActiveColor
				SK.Thickness = Library.TracerSize
			end

			if Library.Arrows == true then
				local Arrow = Library.ArrowsTable[Object]
				if Arrow == nil and Library.ElementsEnabled[Object] == true then
					Arrow = ArrowTemplate:Clone()
					Arrow.Name = Library:GenerateRandomString()
					Arrow:WaitForChild(ArrowConstraint.Name, 5)
					Arrow.Parent = ArrowsFrame
					Library.ArrowsTable[Object] = Arrow
					PlayTween(Arrow, { ImageTransparency = 0 })
				elseif Arrow and Library.ElementsEnabled[Object] == true then
					if OnScreen and ScreenPoint.Z > 0 then
						Arrow.Visible = false
					else
						local ScreenSize = Camera.ViewportSize
						local ScreenCenter = Vector2.new(ScreenSize.X / 2, ScreenSize.Y / 2)
						local ToObj = (ObjectPos - Camera.CFrame.Position).Unit
						local Dir = Vector2.new(ScreenPoint.X, ScreenPoint.Y) - ScreenCenter
						if Camera.CFrame.LookVector:Dot(ToObj) < 0 then
							Dir = -Dir
						end
						local Angle = math.atan2(Dir.Y, Dir.X)
						local Radius = math.min(ScreenSize.X, ScreenSize.Y) / 2 - (400 - Library.ArrowRadius)
						local ArrowPos = ScreenCenter + Dir.Unit * Radius

						Arrow.Position = UDim2.new(0, ArrowPos.X, 0, ArrowPos.Y)
						Arrow.Rotation = math.deg(Angle) - 90
						Arrow.Visible = true
						Arrow.ImageColor3 = Library.Rainbow and Library.RainbowColor or Library.ColorTable[Object]
					end
				end
			end
		end

		local Connection
		Connection = RunService.Heartbeat:Connect(function(Delta)
			Last = Last + Delta
			if Last >= 1 / Library.RenderLimit then
				Last = 0
				if Library.ElementsEnabled[Object] ~= true then
					Connection:Disconnect()
					return
				end
				Render()
			end
		end)
		table.insert(Library.ConnectionsTable[Object], Connection)
	end)
end

function Library:RemoveESP(Object)
	if Library.Unloaded == true or Library.ElementsEnabled[Object] ~= true then return end
	Library.ElementsEnabled[Object] = false
	Library.TransparencyEnabled[Object] = false

	local Label = Library.Labels[Object]
	if Label then
		PlayTween(Label, { TextTransparency = 1 })
	end

	local LineData = Library.Lines[Object]
	if LineData then
		if LineData[1] then PlayTween(LineData[1], { BackgroundTransparency = 1 }) end
		if LineData[2] then PlayTween(LineData[2], { Transparency = 1 }) end
	end

	local Highlight = Library.Highlights[Object]
	if Highlight then
		PlayTween(Highlight, { FillTransparency = 1 })
		PlayTween(Highlight, { OutlineTransparency = 1 })
	end

	local Arrow = Library.ArrowsTable[Object]
	if Arrow then
		PlayTween(Arrow, { ImageTransparency = 1 })
	end

	local FadeTime = Library.FadeTime

	if not Object.Parent then
		task.delay(FadeTime + 0.05, function()
			if Library.ElementsEnabled[Object] == false then
				DestroyObjectData(Object)
			end
		end)
	else
		task.delay(FadeTime + 0.05, function()
			if Library.ElementsEnabled[Object] == false then
				DestroyObjectData(Object)
			else
				local ReHighlight = Library.Highlights[Object]
				if ReHighlight then
					PlayTween(ReHighlight, { FillTransparency = Library.FillTransparency })
					PlayTween(ReHighlight, { OutlineTransparency = Library.OutlineTransparency })
				end
			end
		end)
	end
end

function Library:UpdateObjectText(Object, Text)
	if Library.TextTable[Object] ~= nil then
		Library.TextTable[Object] = Text
	end
end

function Library:UpdateObjectColor(Object, Color)
	Library.ColorTable[Object] = Color
	if Library.Labels[Object] and Library.Rainbow ~= true then
		Library.Labels[Object].TextColor3 = Color
	end
end

function Library:SetColorTable(Name, Color)
	Library.ColorTable[Name] = Color
end

function Library:SetFadeTime(Number)
	Library.FadeTime = Number
end

function Library:SetRenderLimit(Number)
	Library.RenderLimit = Number
end

function Library:SetTextTransparency(Number)
	Library.TextTransparency = Number
	for _, Label in pairs(Library.Labels) do
		Label.TextTransparency = Number
	end
end

function Library:SetFillTransparency(Number)
	Library.FillTransparency = Number
	for _, Highlight in pairs(Library.Highlights) do
		if Highlight:IsA("Highlight") then
			Highlight.FillTransparency = Number
		end
	end
end

function Library:SetOutlineTransparency(Number)
	Library.OutlineTransparency = Number
	for _, Highlight in pairs(Library.Highlights) do
		if Highlight:IsA("Highlight") then
			Highlight.OutlineTransparency = Number
		end
	end
end

function Library:SetTextSize(Number)
	Library.TextSize = Number
	for _, Label in pairs(Library.Labels) do
		Label.TextSize = Number
	end
end

function Library:SetTextOutlineTransparency(Number)
	Library.TextOutlineTransparency = Number
	for _, Label in pairs(Library.Labels) do
		Label.TextStrokeTransparency = Number
	end
end

function Library:SetFont(Font)
	Library.Font = Font
	for _, Label in pairs(Library.Labels) do
		Label.Font = Font
	end
end

function Library:SetOutlineColor(Color)
	Library.OutlineColor = Color
end

function Library:SetRainbow(Value)
	Library.Rainbow = Value
end

function Library:SetShowDistance(Value)
	Library.ShowDistance = Value
end

function Library:SetMatchColors(Value)
	Library.MatchColors = Value
end

function Library:SetTracers(Value)
	Library.Tracers = Value
	TracersFrame.Visible = Value
end

function Library:SetArrows(Value)
	Library.Arrows = Value
	ArrowsFrame.Visible = Value
end

function Library:SetArrowRadius(Value)
	Library.ArrowRadius = Value
end

function Library:SetTracerOrigin(Value)
	Library.TracerOrigin = Value
end

function Library:SetDistanceSizeRatio(Value)
	Library.DistanceSizeRatio = Value
end

function Library:SetTracerSize(Value)
	Library.TracerSize = 0.5 * Value
end

function Library:Unload()
	if Library.Unloaded then return end
	Library.Unloaded = true
	for _, Object in pairs(Library.Objects) do
		Library:RemoveESP(Object)
	end
	for _, Conns in pairs(Library.ConnectionsTable) do
		for _, Conn in ipairs(Conns) do
			Conn:Disconnect()
		end
	end
	RainbowConnection:Disconnect()
	CameraConnection:Disconnect()
	ScreenGui.Enabled = false
end

RainbowConnection = RunService.RenderStepped:Connect(function(Delta)
	RainbowState.Step = RainbowState.Step + Delta
	if RainbowState.Step >= (1 / 60) then
		RainbowState.Step = 0
		RainbowState.HueSetup = RainbowState.HueSetup + (1 / 400)
		if RainbowState.HueSetup > 1 then RainbowState.HueSetup = 0 end
		RainbowState.Hue = RainbowState.HueSetup
		RainbowState.Color = Color3.fromHSV(RainbowState.Hue, 0.8, 1)
		Library.RainbowColor = RainbowState.Color
	end
end)

CameraConnection = Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	Camera = Workspace.CurrentCamera
end)

if getgenv then
	getgenv().ESPLibrary = Library
end

return Library

end

-- Fake Abysall table — same shape Main expects, no remote Interface/Analytics
getgenv().Abysall = {
	Environment = __MsFent_LoadEnvironment(),
	ESPLibrary = __MsFent_LoadESP(),
	["16Notice"] = function() end,
	Legit = true,
	UILibrary = "Obsidian",
	TotalExecutions = (getgenv().MsFent and getgenv().MsFent.TotalExecutions) or 1,
	SavePath = "Doors/Game",
	Interface = {
		Library = Library,
		SaveManager = SaveManager,
		ThemeManager = ThemeManager,
		ApplyInfoTab = function() end,
		ApplySettingsTab = function() end,
	},
	Analytics = function() end,
}
getgenv().MsFent = getgenv().Abysall

local Abysall = getgenv().Abysall
local MsFent = Abysall

local Toggles = Library.Toggles
local Options = Library.Options

local function CloneReference(Object)
	if Abysall.Environment and Abysall.Environment.cloneref then
		return Abysall.Environment.cloneref(Object)
	end
	return Object
end

local Services = setmetatable({}, {
	__index = function(_, Name)
		return CloneReference(game:GetService(Name))
	end
})

-- Settings tab builder (replaces Abysall ApplySettingsTab)
function __MsFent_ApplySettings(Window)
	-- Info + Settings tabs are created right after Window/Tabs setup
	if not Window then return end
	if Tabs and Tabs.Settings then return end
	pcall(function()
		local setTab = Window:AddTab("Settings", "settings")
		ThemeManager:ApplyToTab(setTab)
		SaveManager:BuildConfigSection(setTab)
		local info = Window:AddTab("Info", "info")
		local box = info:AddLeftGroupbox("Ms fent")
		box:AddLabel("Ms fent Hub | Doors", true)
		box:AddLabel("made by gabrieltod112", true)
		local cl = info:AddRightGroupbox("Changelog")
		for _, line in ipairs(getgenv().MsFent.LatestChangelog or {}) do
			pcall(function() cl:AddLabel(tostring(line):gsub("<.->", ""), true) end)
		end
	end)
end

local TimeShowerSourceLabel
local TimeShowerToken = 0
local TimeShowerConnection
local BypassDronesStampedeConnection
local HonchoCorrectBoxConnection
local HonchoAutoDepositConnection
local HonchoESPObjects = {}
local HonchoProcessedRooms = {}
local HonchoDepositCache = {}
local AntiClosetTrash_Connection
local AntiRansom_Connection
local ForgetMeNotConnection
local ForgetMeNotRunning = false
local ForgetMeNotProcessing = {}
local ForgetMeNotNotified = {}
local WaterBypassConnection
local WaterParts = {}
local AlmaConnection
local AntiScribbles_Connection
local DroneConnection
local DroneWalkedIntoParents = {}
local OrbitDroppedItemsConnection
local OrbitDroppedItemsAngle = 0
local OrbitDroppedItemsLastTeleport = 0
local OrbitDroppedItemsPauseUntil = 0
local droppedItemsIntervalRunning = false
local Connections = {}



local Globals = {}
local Connections = {}
local ESPConnections = {}
local Groupboxes = {}
local FakePrompts = {}
local Functions = {}
local PartProperties = {}

local Objects = {
	Prompts = {},
	Objectives = {},
	Doors = {},
	HidingSpots = {},
	Entities = {},
	SeekObstructions = {},
	Items = {},
	Chests = {},
	Currency = {},
	Ladders = {},
	Misc = {},
	Obstructions = {},
	EventTriggers = {},
	JumpscareModules = {},
	SeekHighlights = {},
	EyestalkHighlights = {},
	SeekNodes = {},
	SeekDuckBoards = {},
	SeekBridges = {},
	PathLights = {}
}

Globals.IncompatibleMessage = "Your executor doesn't support this feature."

Functions.CheckCompatability = function(Array)
	for _, Name in Array do
		if not Abysall.Environment[Name] then
			return false
		end
	end
	return true
end


-- DontGroup
local LocalPlayer = Services.Players.LocalPlayer



local PortraitName = "MirrorRig_Portrait_" .. LocalPlayer.Name


local Entities = {
	["Weaveling"] = {
		Alias = "Weaveling",
		NotifyMessage = { Title = "Weaveling has spawned", Body = "Try to grab it" }
	},
	["Creak-HALLOWEEN26"] = {
		Alias = "CreakHalloween",
		NotifyMessage = { Title = "Sir Abraham Creakstopher II spawned", Body = "He scary"}
	},
	["TV_Stand"] = {
		Alias = "Noise_TV",
		NotifyMessage = { Title = "Noise tv spawned.", Body = "Dont get near it" }
	},
	[PortraitName] = {
		Alias = "Portrait",
		NotifyMessage = { Title = "Portrait' has spawned.", Body = "Use him to duplicate items." }
	},
	["StemsEntity"] = {
	    Alias = 'Balls',
		NotifyMessage = { Title = "Balls", Body = "Balls."}
	},
	["NoiseModel"] = {
		Alias = 'Noise',
		NotifyMessage = { Title = "Entity 'Noise' has spawned.", Body = "Dont let it touch you." }
	},
	["Creak"] = {
		Alias = "Creak",
		NotifyMessage = { Title = "Entity 'Creak' has spawned.", Body = "Dont touch him." }
	},
	["DronesStampede"] = {
		Alias = "DronesStampede",
		NotifyMessage = { Title = "Entity 'Drones Stampede' has spawned.", Body = "Find a hiding spot." }
	},
	["TellerRig"] = {
		Alias = "Teller",
		NotifyMessage = { Title = "Entity 'Teller' has spawned.", Body = "Dont worry, hes only annoying." }
	},
	["Scribbles"] = {
		Alias = "Scribbles",
		NotifyMessage = { Title = "Entity 'Scribbles' has spawned.", Body = "Find a hiding spot." }
	},
	["BashMoving"] = {
		Alias = "Bash",
		NotifyMessage = { Title = "Entity 'Bash' has spawned.", Body = "Find a hiding spot."}
	},
	["RushMoving"] = {
		Alias = "Rush",
		NotifyMessage = { Title = "Entity 'Rush' has spawned.", Body = "Find a hiding spot." }
	},
	["AmbushMoving"] = {
		Alias = "Ambush",
		NotifyMessage = { Title = "Entity 'Ambush' has spawned.", Body = "Find a hiding spot." }
	},
	["Eyes"] = {
		Alias = "Eyes",
		NotifyMessage = { Title = "Entity 'Eyes' has spawned.", Body = "Avoid looking at it." }
	},
	["Lookman"] = {
		Alias = "Eyes",
		NotifyMessage = { Title = "Entity 'Eyes' has spawned.", Body = "Avoid looking at it." }
	},
	["BackdoorRush"] = {
		Alias = "Blitz",
		NotifyMessage = { Title = "Entity 'Blitz' has spawned.", Body = "Find a hiding spot." }
	},
	["BackdoorLookman"] = {
		Alias = "Lookman",
		NotifyMessage = { Title = "Entity 'Lookman' has spawned.", Body = "Avoid looking at its eyes." }
	},
	["Groundskeeper"] = {
		Alias = "Groundskeeper",
		NotifyMessage = { Title = "Entity 'Groundskeeper' has spawned.", Body = "Avoid stepping on the grass." }
	},
	["A60"] = {
		Alias = "A-60",
		NotifyMessage = { Title = "Entity 'A-60' has spawned.", Body = "Find a hiding spot." }
	},
	["A120"] = {
		Alias = "A-120",
		NotifyMessage = { Title = "Entity 'A-120' has spawned.", Body = "Find a hiding spot." }
	},
	["GloombatSwarm"] = {
		Alias = "Gloombat Swarm",
		NotifyMessage = { Title = "Entity 'Gloombat Swarm' has spawned.", Body = "Keep all light sources turned off." }
	},
	["GlitchRush"] = {
		Alias = "RNIUSHCG==",
		NotifyMessage = { Title = "Entity 'RNIUSHCG==' has spawned.", Body = "Find a hiding spot." }
	},
	["GlitchAmbush"] = {
		Alias = "AR0xMBUSH",
		NotifyMessage = { Title = "Entity 'AR0xMBUSH' has spawned.", Body = "Find a hiding spot." }
	},
	["MonumentEntity"] = {
		Alias = "Monument",
		NotifyMessage = { Title = "Entity 'Monument' has spawned.", Body = "It can't move while you are looking at it." }
	},
	["JeffTheKiller"] = {
		Alias = "Jeff the Killer",
		NotifyMessage = { Title = "Entity 'Jeff the Killer' has spawned.", Body = "Avoid touching him." }
	},
	["CustomEntity"] = {
		Alias = "Custom Entity",
		NotifyMessage = { Title = "Entity 'Custom Entity' has spawned.", Body = "Find a hiding spot." }
	},
	["FrozenAmbush"] = {
		Alias = "Frozen Ambush",
		NotifyMessage = { Title = "Entity 'Frozen Ambush' has spawned.", Body = "Find a hiding spot." }
	},
	["SallyMoving"] = {
		Alias = "Sally",
		NotifyMessage = { Title = "Entity 'Sally' has spawned.", Body = "Find her horse and rop it." }
	}
}

local EntityIcons = {
	["RushMoving"]      = "rbxassetid://10716032262",
	["AmbushMoving"]    = "rbxassetid://10110576663",
	["A60"]             = "rbxassetid://12571092295",
	["A120"]            = "rbxassetid://12711591665",
	["BackdoorRush"]    = "rbxassetid://16602023490",
	["Eyes"]            = "rbxassetid://10183704772",
	["Lookman"]         = "rbxassetid://10183704772",
	["BackdoorLookman"] = "rbxassetid://16764872677",
	["GloombatSwarm"]   = "rbxassetid://79221203116470",
	["Halt"]            = "rbxassetid://11331795398",
	["JeffTheKiller"]   = "rbxassetid://94479432156278",
	["GlitchRush"]      = "rbxassetid://73859273102919",
	["GlitchAmbush"]    = "rbxassetid://88369678433359",
	["SallyMoving"]     = "rbxassetid://10840888070",
	["MonumentEntity"]  = "rbxassetid://88933556873017",
	["Groundskeeper"]   = "rbxassetid://114991380115557"
}

local ItemNames = {
    ["AbrahamHat"]       = "Hat",
    ["LargeScrew"]       = "Screw",
    ["KeyJewelry"]       = "Jewerly Key",
    ["Leftovers"]        = "Lunch Box",
    ["Haybale"]          = "Haybale",
    ["WizardHat"]        = "Wizard Hat",
    ["CandyBasket"]      = "Candy Basket",
    ["BrokenHeadstone"]  = "Broken Headstone",
    ["GiantGummyworm"]   = "Giant Gummyworm",
    ["ChocolateCrate"]   = "Crate of Chocolate",
    ["CandyBucket"]      = "Candy Bucket",
    ["LargeCandyBag"]    = "Large Candy Bag",
    ["SmallCauldron"]    = "Small Cauldron",
    ["ObjectScanner"]    = "Scanner",
    ["Drive"]            = "Drive",
	["DinkyLamp"]         = "Lamp",
	["BottleCrate"]       = "18+ Bottles",
	["GweenSodaPack"]     = "Gween Soda Pack",
	["BrokenMonitor"]     = "Broken Monitor",
	["JerryCan"]          = "Jerry Can",
 	["SallyToyObtain"]    = "Sally Toy",
	["Leftovers"]         = "Lunch Box",
	["HoneyPot"]          = "Honey Pot",
	["FihFlakes"]         = "Fih Food",
	["SecretCD"]          = "CD Disc",
	["Pizza"]             = "Pizza",
	["PaperPlanePickup"]  = "Paper Plane",
	["Lighter"]           = "Lighter",
	["Flashlight"]        = "Flashlight",
	["Lockpick"]          = "Lockpicks",
	["Vitamins"]          = "Vitamins",
	["Bandage"]           = "Bandage",
	["StarVial"]          = "Starlight Vial",
	["StarBottle"]        = "Starlight Bottle",
	["StarJug"]           = "Starlight Barrel",
	["Shakelight"]        = "Gummy Flashlight",
	["Straplight"]        = "Straplight",
	["Bulklight"]         = "Spotlight",
	["Battery"]           = "Battery",
	["Candle"]            = "Candle",
	["Crucifix"]          = "Crucifix",
	["CrucifixWall"]      = "Crucifix",
	["Glowsticks"]        = "Glowstick",
	["SkeletonKey"]       = "Skeleton Key",
	["Candy"]             = "Candy",
	["ShieldMini"]        = "Mini Shield Potion",
	["ShieldBig"]         = "Big Shield Potion",
	["BandagePack"]       = "Bandage Pack",
	["BatteryPack"]       = "Battery Pack",
	["RiftCandle"]        = "Moonlight Candle",
	["LaserPointer"]      = "Laser Pointer",
	["HolyGrenade"]       = "Holy Hand Grenade",
	["Shears"]            = "Shears",
	["Smoothie"]          = "Smoothie",
	["Cheese"]            = "Cheese",
	["Bread"]             = "Bread",
	["AlarmClock"]        = "Alarm Clock",
	["RiftSmoothie"]      = "Moonlight Smoothie",
	["GweenSoda"]         = "Gween Soda",
	["GlitchCube"]        = "Glitch Fragment",
	["Scanner"]           = "Tablet",
	["Bomb"]              = "Bomb",
	["Knockbomb"]         = "Knockbomb",
	["Nanner"]            = "Nanner",
	["BigBomb"]           = "Big Bomb",
	["SnakeBox"]          = "Hiding Box",
	["GoldGun"]           = "Golden Gun",
	["StopSign"]          = "Stop Sign",
	["TipJar"]            = "Tip Jar",
	["Lantern"]           = "Lantern",
	["IronKey"]           = "Iron Key",
	["LotusPetal"]        = "Lotus Petal",
	["Compass"]           = "Compass",
	["LotusPetalPickup"]  = "Lotus Petal",
	["LanternLitItem"]    = "Lantern",
	["KeyIron"]           = "Iron Key",
	["IronKeyForCrypt"]   = "Iron Key",
	["LotusHolder"]       = "Lotus Petal",
	["Multitool"]         = "Multitool",
	["RiftJar"]           = "Rift Jar",
	["AloeVera"]          = "Aloe Vera",
	["Donut"]             = "Donut",
	["Lotus"]             = "Lotus",
	["BoxingGloves"]      = "Boxing Gloves"
}

local CutsceneNames = {
    "Figure",
    "FigureEnd",
    "FigureHotelEnd",
    "FigureHotelFire",
    "SeekIntroFools",
    "SeekIntroHotel",
    "SeekIntroMines",
    "SeekIntroMines2",
    "SerewSeekDrain",
    "SewerSeekLower",
    "GrumbleNestEnd",
    "EyestalkIntro",
}

local Character
local Humanoid
local RootPart

local Collision
local CollisionClone
local CollisionPart
local CollisionPartClone

local Camera = workspace:FindFirstChild("Camera")

local RemotesFolder   = Services.ReplicatedStorage:FindFirstChild("RemotesFolder")
local LiveModifiers   = Services.ReplicatedStorage:FindFirstChild("LiveModifiers")
local FloorReplicated = Services.ReplicatedStorage:FindFirstChild("FloorReplicated")

local CurrentRooms    = Services.Workspace:FindFirstChild("CurrentRooms")

local Drops           = Services.Workspace:FindFirstChild("Drops")
local GameData        = Services.ReplicatedStorage:WaitForChild("GameData")
local Floor           = GameData:WaitForChild("Floor").Value
local LatestRoom      = GameData:WaitForChild("LatestRoom")
local FinishedLoadingRoom = GameData:FindFirstChild("FinishedLoadingRoom")
local RunService = game:GetService("RunService")

if FinishedLoadingRoom then
	FinishedLoadingRoom:Destroy()
end

local function GetHiddenContainer()
	if Functions.CheckCompatability({"gethui"}) then
		return Abysall.Environment.gethui()
	end
	return Services.CoreGui
end

local NotificationLibrary = {
	LiveNotifications = 0,
	Notifications = 1
}

local Container = Instance.new("ScreenGui")
Container.Name = Abysall.ESPLibrary:GenerateRandomString()
Container.Parent = GetHiddenContainer()
Container.DisplayOrder = 32767
Container.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if not Library.Scheme then
	Library.Scheme = setmetatable({}, {
		__index = function(Self, Name)
			return Library[Name]
		end
	})
end

function NotificationLibrary:Notify(TitleText, Desc, Delay)
	task.spawn(function()
		local Notification = Instance.new("Frame")
		local Line = Instance.new("Frame")
		local Warning = Instance.new("ImageLabel")
		local UICorner = Instance.new("UICorner")
		local UICorner2 = Instance.new("UICorner")
		local Title = Instance.new("TextLabel")
		local Description = Instance.new("TextLabel")

		Notification.Name = "Notification"
		Notification.Parent = Container
		Notification.BackgroundColor3 = Library.Scheme.BackgroundColor
		Notification.BackgroundTransparency = 0.4
		Notification.BorderSizePixel = 0
		Notification.Position = UDim2.new(1, 5, 0, 60 + (60 * NotificationLibrary.LiveNotifications))
		Notification.Size = UDim2.new(0, 420, 0, 50)
		Notification:SetAttribute("ID", NotificationLibrary.Notifications)
		Notification:SetAttribute("CurrentPosition", Notification.Position)

		Line.Name = "Line"
		Line.Parent = Notification
		Line.BackgroundColor3 = Library.Scheme.AccentColor
		Line.BorderSizePixel = 0
		Line.Position = UDim2.new(0, 0, 1, -3)
		Line.Size = UDim2.new(0, 0, 0, 3)

		Warning.Name = "Warning"
		Warning.Parent = Notification
		Warning.BackgroundTransparency = 1
		Warning.Position = UDim2.new(0, 10, 0, 5)
		Warning.Size = UDim2.new(0, 40, 0, 40)
		Warning.Image = "rbxassetid://3944668821"
		Warning.ImageColor3 = Library.Scheme.AccentColor
		Warning.ScaleType = Enum.ScaleType.Fit

		UICorner.CornerRadius = UDim.new(0, 20)
		UICorner.Parent = Warning

		UICorner2.CornerRadius = UDim.new(0, 4)
		UICorner2.Parent = Notification

		Title.Name = "Title"
		Title.Parent = Notification
		Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Title.BackgroundTransparency = 1
		Title.Position = UDim2.new(0, 60, 0.155, 0)
		Title.Size = UDim2.new(0, 205, 0, 15)
		Title.Text = TitleText or "..."
		Title.TextColor3 = Library.Scheme.FontColor
		Title.TextSize = 10
		Title.TextStrokeTransparency = 0.75
		Title.TextXAlignment = Enum.TextXAlignment.Left

		Description.Name = "Description"
		Description.Parent = Notification
		Description.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Description.BackgroundTransparency = 1
		Description.Position = UDim2.new(0, 60, 0.483, 0)
		Description.Size = UDim2.new(0, 205, 0, 18)
		Description.Text = Desc or "..."
		Description.TextColor3 = Library.Scheme.FontColor
		Description.TextTransparency = 0.1
		Description.TextSize = 10
		Description.TextStrokeTransparency = 0.75
		Description.TextXAlignment = Enum.TextXAlignment.Left

		NotificationLibrary.LiveNotifications += 1
		NotificationLibrary.Notifications += 1

		Services.TweenService:Create(
			Notification,
			TweenInfo.new(1, Enum.EasingStyle.Exponential),
			{ Position = UDim2.new(1, -370, 0, Notification.Position.Y.Offset) }
		):Play()

		task.wait(0.25)
		if typeof(Delay) == "Instance" then
			Delay.Destroying:Wait()
		else
			Services.TweenService:Create(
				Line,
				TweenInfo.new(Delay - 0.25, Enum.EasingStyle.Linear),
				{ Size = UDim2.new(0, 400, 0, 3) }
			):Play()
			task.wait(Delay - 0.25)
		end

		Notification:SetAttribute("Destroying", true)

		Services.TweenService:Create(
			Notification,
			TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
			{ Position = UDim2.new(1, 5, 0, Notification.Position.Y.Offset) }
		):Play()

		NotificationLibrary.LiveNotifications -= 1

		local NotifId = Notification:GetAttribute("ID")
		local NotifY = Notification:GetAttribute("CurrentPosition").Y.Offset

		for _, Object in Container:GetChildren() do
			if Object.Name == "Notification"
				and Object:GetAttribute("ID")
				and Object:GetAttribute("ID") > NotifId
				and Object:GetAttribute("Destroying") ~= true
				and Object.Position.Y.Offset ~= 60
			then
				local NewY = Object:GetAttribute("CurrentPosition").Y.Offset - 60
				Object:SetAttribute("CurrentPosition", UDim2.new(1, -450, 0, NewY))
				Services.TweenService:Create(
					Object,
					TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut),
					{ Position = UDim2.new(1, -370, 0, NewY) }
				):Play()
			end
		end

		task.wait(0.75)
		Notification:Destroy()
	end)
end

Globals.DoorsNotify = function(NotifyOptions)
	local function PlaySound(Parent, SoundId, Volume)
		local Sound = Instance.new("Sound")
		Sound.SoundId = SoundId
		Sound.Volume = Volume or 1
		Sound.Parent = Parent
		task.spawn(function()
			task.wait(0.1)
			Sound:Play()
			Sound.Ended:Wait()
			Sound:Destroy()
		end)
	end

	local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
	local UIContainer = PlayerGui:FindFirstChild("GlobalUI") or PlayerGui:FindFirstChild("MainUI")
	if not UIContainer then return end

	local AchievementsHolder = UIContainer:FindFirstChild("AchievementsHolder")
	if not AchievementsHolder then return end

	local Achievement = AchievementsHolder.Achievement:Clone()
	Achievement.Size = UDim2.new(0, 0, 0, 0)
	Achievement.Frame.Position = UDim2.new(1.1, 0, 0, 0)
	Achievement.Name = "LiveAchievement"
	Achievement.Visible = true

	Achievement.Frame.TextLabel.Text = NotifyOptions.Style or "NOTIFICATION"
	Achievement.Frame.Details.Title.Text = NotifyOptions.Title or "Sem Título"
	Achievement.Frame.Details.Desc.Text = NotifyOptions.Description or "Sem Descrição"
	Achievement.Frame.Details.Reason.Text = NotifyOptions.Reason or ""
	Achievement.Frame.ImageLabel.Image = (NotifyOptions.Image ~= "" and NotifyOptions.Image) or "rbxassetid://6023426923"

	local Color = NotifyOptions.Color or Color3.new(1, 1, 1)
	Achievement.Frame.TextLabel.TextColor3 = Color
	Achievement.Frame.UIStroke.Color = Color
	Achievement.Frame.Glow.ImageColor3 = Color
	Achievement.Parent = AchievementsHolder

	PlaySound(AchievementsHolder, "rbxassetid://10469938989", 1)

	task.spawn(function()
		Achievement:TweenSize(UDim2.new(1, 0, 0.2, 0), "In", "Quad", 0.8, true)
		task.wait(0.8)
		Achievement.Frame:TweenPosition(UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.5, true)
		Services.TweenService:Create(
			Achievement.Frame.Glow,
			TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{ ImageTransparency = 1 }
		):Play()

		if typeof(NotifyOptions.Time) == "Instance" then
			NotifyOptions.Time.Destroying:Wait()
		else
			task.wait(NotifyOptions.Time or 5)
		end

		Achievement.Frame:TweenPosition(UDim2.new(1.1, 0, 0, 0), "In", "Quad", 0.5, true)
		task.wait(0.5)
		Achievement:TweenSize(UDim2.new(1, 0, -0.1, 0), "InOut", "Quad", 0.5, true)
		task.wait(0.5)
		Achievement:Destroy()
	end)
end

Globals.STX = getgenv().__MsFent_STX
Functions.Notify = function(Settings)
	local HiddenContainer = GetHiddenContainer()

	if not Settings.Body then
		Settings.Body = "..."
	end

	if not Options.NotifyStyle or (Options.NotifyStyle.Value == "Abysall" or Options.NotifyStyle.Value == "MsFent") then
		local Sound = Instance.new("Sound", HiddenContainer)
		Sound.SoundId = "rbxassetid://8784885431"
		Sound.Volume = (Toggles.NotifyPlaySound and Toggles.NotifyPlaySound.Value and Options.NotifySoundVolume.Value) or (Toggles.NotifyPlaySound and 0 or 3)
		Sound.PlayOnRemove = true
		Sound:Destroy()
		NotificationLibrary:Notify(Settings.Title, Settings.Body, Settings.Time or 5)
	elseif Options.NotifyStyle.Value == "Doors" then
		local IsEntity = false
		local EntityName = ""
		for Index, Object in pairs(Entities) do
			if Object.NotifyMessage.Title == Settings.Title or Object.NotifyMessage.Body == Settings.Body then
				IsEntity = true
				EntityName = Index
			end
		end
		Globals.DoorsNotify({
			Title = "Ms fent Hub | Doors",
			Description = Settings.Title,
			Reason = Settings.Body,
			Style = IsEntity and "WARNING" or "NOTIFICATION",
			Color = IsEntity and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 222, 189),
			Image = Settings.Image,
			Time = Settings.Time
		})
getgenv().MsFent = getgenv().MsFent or {}
getgenv().MsFent._Window = Window

	elseif Options.NotifyStyle.Value == "STX" then
		local Sound = Instance.new("Sound", HiddenContainer)
		Sound.SoundId = "rbxassetid://4590657391"
		Sound.Volume = (Toggles.NotifyPlaySound and Toggles.NotifyPlaySound.Value and Options.NotifySoundVolume.Value) or (Toggles.NotifyPlaySound and 0 or 3)
		Sound.PlayOnRemove = true
		Sound:Destroy()

		if Settings.Image then
			Globals.STX:Notify(
				{Title = "Ms fent Hub | Doors", Description = Settings.Title .. "\n" .. Settings.Body},
				{OutlineColor = Library.Scheme.AccentColor,Time = Settings.Time or 5, Type = "image"},
				{Image = Settings.Image, ImageColor = Color3.fromRGB(255, 255, 255)}
			)
		else
			Globals.STX:Notify(
				{Title = "Ms fent Hub | Doors", Description = Settings.Title .. "\n" .. Settings.Body},
				{OutlineColor = Library.Scheme.AccentColor,Time = Settings.Time or 5, Type = "default"}
			)
		end
	else
		local Sound = Instance.new("Sound", HiddenContainer)
		Sound.SoundId = "rbxassetid://4590662766"
		Sound.Volume = (Toggles.NotifyPlaySound and Toggles.NotifyPlaySound.Value and Options.NotifySoundVolume.Value) or (Toggles.NotifyPlaySound and 0 or 3)
		Sound.PlayOnRemove = true
		Sound:Destroy()
		Library:OldNotify({ Title = Settings.Title, Description = Settings.Body, Time = Settings.Time })
	end
end

Functions.Caption = function(Text, PlaySound)
	if typeof(PlaySound) ~= "boolean" then
		PlaySound = true
	end
	local CaptionValue = Instance.new("NumberValue")
	local Caption = Globals.MainUI:WaitForChild("MainFrame"):WaitForChild("Caption"):Clone()
	local CaptionSound = Globals.MainUI:WaitForChild("Initiator"):WaitForChild("Main_Game"):WaitForChild("Reminder"):WaitForChild("Caption")
	local CaptionSoundClone = CaptionSound:Clone()
	CaptionSoundClone.Parent = CaptionSound.Parent
	CaptionSoundClone.Volume = 0.1

	Caption.Destroying:Connect(function()
		CaptionValue:Destroy()
	end)

	for _, Child in Globals.MainUI:GetChildren() do
		if Child.Name == "LiveCaption" then
			Child:Destroy()
		end
	end

	Caption.Parent = Globals.MainUI
	Caption.Visible = true
	Caption.Name = "LiveCaption"
	Caption.Text = Text

	if PlaySound then
		CaptionSoundClone:Play()
	end

	Services.Debris:AddItem(CaptionSoundClone, 5)

	local HolderTween = Services.TweenService:Create(CaptionValue, TweenInfo.new(3), { Value = 100 })
	HolderTween:Play()
	HolderTween.Completed:Connect(function()
		CaptionValue:Destroy()
		Services.TweenService:Create(Caption, TweenInfo.new(4, Enum.EasingStyle.Linear), { TextTransparency = 1 }):Play()
		Services.TweenService:Create(Caption, TweenInfo.new(4, Enum.EasingStyle.Linear), { TextStrokeTransparency = 1 }):Play()
	end)
end

Functions.GetHasteTime = function()
	local TimeRemaining = FloorReplicated.DigitalTimer.Value
	local Minutes = math.floor(TimeRemaining / 60)
	local Seconds = TimeRemaining - (Minutes * 60)
	local MinutesText = Minutes < 10 and ("0" .. tostring(Minutes)) or tostring(Minutes)
	local SecondsText = Seconds < 10 and ("0" .. tostring(Seconds)) or tostring(Seconds)
	return MinutesText .. ":" .. SecondsText
end

Library.OldNotify = Library.Notify
Library.Notify = function(Data, Body, Time)
	Functions.Notify({ Title = Body, Time = Time or 5 })
end

if not LocalPlayer.Character or not CurrentRooms:FindFirstChildOfClass("Model") then
	Functions.Notify({ Title = "Waiting for the game to load..." })
	while not LocalPlayer.Character or not CurrentRooms:FindFirstChildOfClass("Model") do
		task.wait()
	end
	task.wait(4)
end

if not RemotesFolder then
	if Services.ReplicatedStorage:FindFirstChild("EntityInfo") then
		RemotesFolder = Services.ReplicatedStorage:FindFirstChild("EntityInfo")
	elseif Services.ReplicatedStorage:FindFirstChild("Bricks") then
		RemotesFolder = Services.ReplicatedStorage:FindFirstChild("Bricks")
	end
end

if Floor == "Hotel" and RemotesFolder.Name == "Bricks" then
	Floor = "OldHotel"
end

if not LiveModifiers then
	LiveModifiers = Instance.new("Folder")
end

if not FloorReplicated then
	FloorReplicated = Instance.new("Folder")
end

local FakeEvents = {
	Screech = Instance.new("RemoteEvent"),
	Shade   = Instance.new("RemoteEvent"),
	A90     = Instance.new("RemoteEvent"),
	Surge   = Instance.new("RemoteEvent"),
}

FakeEvents.Screech.Name  = "Screech"
FakeEvents.Shade.Name    = "ShadeResult"
FakeEvents.A90.Name      = "A90"
FakeEvents.Surge.Name    = "SurgeRemote"

FakeEvents.Screech_Real = RemotesFolder:WaitForChild("Screech")
FakeEvents.Shade_Real   = RemotesFolder:WaitForChild("ShadeResult")
FakeEvents.A90_Real     = RemotesFolder:FindFirstChild("A90")
FakeEvents.Surge_Real   = RemotesFolder:FindFirstChild("SurgeRemote")

if RemotesFolder:FindFirstChild("FootstepRemoteThatWeNeed") then
    local RealRemote = RemotesFolder:FindFirstChild("FootstepRemoteThatWeNeed")
    RealRemote:Destroy()

    local FakeRemote = Instance.new("RemoteEvent", RemotesFolder)
    FakeRemote.Name = "FootstepRemoteThatWeNeed"
end

Globals.FogInstances = {}
Globals.OldFog = Services.Lighting.FogEnd

for _, Object in Services.Lighting:GetChildren() do
	if Object:IsA("Atmosphere") then
		Object:SetAttribute("Density_Old", Object.Density)

		local AtmoConnection = Object:GetPropertyChangedSignal("Density"):Connect(function()
			if Object.Density ~= 0 then
				Object:SetAttribute("Density_Old", Object.Density)
			end
			if Toggles.RemoveCameraFog.Value then
				Object.Density = 0
			end
		end)

		Object.Destroying:Once(function()
			AtmoConnection:Disconnect()
		end)

		table.insert(Connections, AtmoConnection)
		table.insert(Globals.FogInstances, Object)
	end
end

Globals.SeekNodesFolder = Instance.new("Folder", Services.Workspace)
Globals.SeekNodesFolder.Name = Abysall.ESPLibrary:GenerateRandomString()

Globals.RoomsNodesFolder = Instance.new("Folder", Services.Workspace)
Globals.RoomsNodesFolder.Name = Abysall.ESPLibrary:GenerateRandomString()

Functions.SendChat = function(Message)
	local Folder = Services.ReplicatedStorage:FindFirstChild("DefaultChatSystemEvents") or Instance.new("Folder")
	local Event = Folder:FindFirstChild("SayMessageRequest") or Instance.new("RemoteEvent")
	Event:FireServer(Message, "All")
	local Channel = (Services.TextChatService:FindFirstChild("TextChannels") and Services.TextChatService.TextChannels:FindFirstChild("RBXGeneral")) or Instance.new("TextChannel")
	Channel:SendAsync(Message)
end

Functions.IsCrouching = function()
	if Floor == "Fools" or Floor == "OldHotel" then
		return Character:GetAttribute("Crouching")
	end
	return CollisionPart.CollisionGroup == "PlayerCrouching"
end

Functions.GetInjuriesSpeed = function()
	return 0.075 * (Humanoid.MaxHealth - Humanoid.Health)
end

Functions.GetCurrentSpeed = function()
	local Speed = 15
	Speed += Character:GetAttribute("SpeedBoost") or 0
	Speed += Character:GetAttribute("SpeedBoostBehind") or 0
	Speed += Character:GetAttribute("SpeedBoostExtra") or 0
	Speed += (Floor == "Party" and 10 or 0)
	Speed += (LiveModifiers:FindFirstChild("PlayerFast") and 3 or 0)
	Speed += (LiveModifiers:FindFirstChild("PlayerFaster") and 6 or 0)
	Speed += (LiveModifiers:FindFirstChild("PlayerFastest") and 20 or 0)
	Speed -= (LiveModifiers:FindFirstChild("PlayerSlow") and 3 or 0)
	Speed -= (LiveModifiers:FindFirstChild("PlayerSlowHealth") and Functions.GetInjuriesSpeed() or 0)
	if Functions.IsCrouching() then
		if LiveModifiers:FindFirstChild("PlayerCrouchSlow") then
			Speed -= 8
		elseif LiveModifiers:FindFirstChild("PlayerSlow") then
			Speed -= 8
		else
			Speed -= 5
		end
	end
	return Speed
end

Functions.GetMousePosition = function()
	if Library.IsMobile then
		return Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	end
	local MouseLocation = Services.UserInputService:GetMouseLocation()
	return Vector2.new(MouseLocation.X, MouseLocation.Y)
end

Functions.FormatOxygen = function(Oxygen)
	return "Oxygen: " .. (math.floor(Oxygen * 10) / 10) .. "%"
end

Functions.IsHidePersistent = function()
	return Floor == "Mines"
		or Floor == "Ripple"
		or Floor == "Party"
		or LiveModifiers:FindFirstChild("HideLevel2") ~= nil
end

Functions.GetPlayerFromMouse = function(TargetPart, MaxDistance)
	local Closest
	local ClosestDistance = math.huge

	for _, Player in Services.Players:GetPlayers() do
		local Char = Player.Character
		if Char then
			local Target = Char:FindFirstChild(TargetPart)
			if Target then
				local Result = Camera:WorldToViewportPoint(Target.Position)
				local ScreenPos = Vector2.new(Result.X, Result.Y)
				local Distance = (Functions.GetMousePosition() - ScreenPos).Magnitude
				if Player.Name ~= LocalPlayer.Name and Distance < ClosestDistance and Distance < MaxDistance then
					Closest = Target
					ClosestDistance = Distance
				end
			end
		end
	end
	return Closest
end

local EntityDistances = {
	["RushMoving"]    = 85,
	["Scribbles"]	  = 100,
	["BashMoving"]    = 150,
	["DronesStampede"] = 100,
	["AmbushMoving"]  = 150,
	["A60"]           = 125,
	["A120"]          = 85,
	["GlitchRush"]    = 90,
	["GlitchAmbush"]  = 175,
	["BackdoorRush"]  = 85,
	["CustomEntity"]  = 85,
}

Functions.GetNearestEntity = function(CheckDisabled, List, UseRaycasting)
	local Nearest = { Distance = math.huge, Object = nil }

	for _, Entity in Objects.Entities do
		if not Entity or not Entity:IsA("Model") or not Entity:IsDescendantOf(Services.Workspace) then continue end
		if not EntityDistances[Entity.Name] or not Entity.PrimaryPart then continue end

		local EntityData = Entities[Entity.Name]
		if not EntityData then continue end
		if List and List[EntityData.Alias] then continue end

		local Distance = LocalPlayer:DistanceFromCharacter(Entity.PrimaryPart.Position)
		if Distance < EntityDistances[Entity.Name] and Distance < Nearest.Distance then
			if not CheckDisabled or Entity:GetAttribute("Inactive") ~= true then
				Nearest.Distance = Distance
				Nearest.Object = Entity
			end
		end
	end
	return Nearest.Object
end

Functions.GetNearestFigure = function()
	local Nearest = { Distance = math.huge, Object = nil }
	local FigureNames = { FigureRig = true, FigureRagdoll = true, Figure = true }

	for _, Object in Objects.Entities do
		if Object:IsA("Model") and Object.PrimaryPart and FigureNames[Object.Name] then
			local Distance = LocalPlayer:DistanceFromCharacter(Object.PrimaryPart.Position)
			if Distance < Nearest.Distance and Distance < 25 then
				Nearest.Distance = Distance
				Nearest.Object = Object
			end
		end
	end
	return Nearest.Object
end

Functions.GetNearestHidingSpot = function()
	local Nearest = { Distance = math.huge, Object = nil }
	local LastHideSpot = Character:FindFirstChild("LastHideSpot")

	local function IsHidingSpotName(Name)
		if typeof(Name) ~= "string" then return false end
		return string.find(string.lower(Name), "hidingspot") or string.find(string.lower(Name), "hiding_spot")
	end

	local function GetHidePrompt(Object)
	if not Object then return nil end

	local Prompt = Object:FindFirstChild("HidePrompt") or Object:FindFirstChild("HidingPrompt")
	if Prompt then return Prompt end

	for _, Child in Object:GetDescendants() do
		if (Child:IsA("ProximityPrompt") or Child:IsA("InteractPrompt"))
			and (Child.Name == "HidePrompt" or Child.Name == "HidingPrompt" or IsHidingSpotName(Child.Name))
		then
			return Child
		end
	end

	if IsHidingSpotName(Object.Name) or IsHidingSpotName(Object.Parent and Object.Parent.Name) then
		return Object:FindFirstChild("HidePrompt") or Object:FindFirstChild("HidingPrompt")
	end

	return nil
	end

	local function TryObject(Object)
		if not Object or not Object:IsDescendantOf(Services.Workspace) then return end
		if not Object.PrimaryPart and not Object:FindFirstChildOfClass("BasePart") then return end
		local Prompt = GetHidePrompt(Object)
		if not Prompt then return end
		local PrimaryPart = Object.PrimaryPart or Object:FindFirstChildOfClass("BasePart")
		if not PrimaryPart then return end
		local Distance = LocalPlayer:DistanceFromCharacter(PrimaryPart.Position)
		if Distance < Prompt.MaxActivationDistance and Distance < Nearest.Distance then
			local Persistent = Functions.IsHidePersistent()
			if not Persistent or (LastHideSpot and LastHideSpot.Value ~= Object) or not LastHideSpot then
				Nearest.Distance = Distance
				Nearest.Object = Object
			end
		end
	end

	for _, Object in Objects.HidingSpots do
		TryObject(Object)
	end

	return Nearest.Object
end

Functions.GetNearestTurnNode = function()
	local Nearest = { Distance = math.huge, Object = nil }

	for _, Node in Objects.SeekNodes do
		local Distance = LocalPlayer:DistanceFromCharacter(Node.Position)
		if Distance < Options.AutoSteerMinecartTurnDistance.Value and Distance < Nearest.Distance then
			Nearest.Distance = Distance
			Nearest.Object = Node
		end
	end
	return Nearest.Object
end

Functions.GetNearestDuckBoard = function()
	local Nearest = { Distance = math.huge, Object = nil }

	for _, Board in Objects.SeekDuckBoards do
		if Board.PrimaryPart then
			local Distance = LocalPlayer:DistanceFromCharacter(Board.PrimaryPart.Position)
			if Distance < Options.AutoSteerMinecartDuckDistance.Value and Distance < Nearest.Distance then
				Nearest.Distance = Distance
				Nearest.Object = Board
			end
		end
	end
	return Nearest.Object
end

Functions.GetCurrentAnchor = function()
	local AnchorCode = Globals.MainUI.AnchorHintFrame.AnchorCode.Text
	for _, Anchor in Objects.Objectives do
		if Anchor.Name == "MinesAnchor" and Anchor:FindFirstChild("Sign") then
			if Anchor.Sign.TextLabel.Text == AnchorCode then
				return Anchor
			end
		end
	end
end

Functions.GetMinecart = function()
	return Camera:FindFirstChild("MinecartRig") ~= nil
end

Functions.HasItem = function(Name, OnlyCharacter)
	if not OnlyCharacter and LocalPlayer.Backpack:FindFirstChild(Name) then
		return LocalPlayer.Backpack:FindFirstChild(Name)
	elseif Character:FindFirstChild(Name) then
		return Character:FindFirstChild(Name)
	end
end

Functions.GetFlyVelocity = function()
	if Humanoid.MoveDirection == Vector3.zero then
		return Humanoid.MoveDirection
	end
	local LookFlat = Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z)
	local FlatFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + LookFlat)
	local Velocity = (Camera.CFrame * CFrame.new(FlatFrame:VectorToObjectSpace(Humanoid.MoveDirection))).Position - Camera.CFrame.Position
	if Velocity == Vector3.zero then
		return Velocity
	end
	return Velocity.Unit
end

Globals.PromptContainer = Instance.new("Folder")
Globals.PromptContainer.Name = "PromptContainer"
Globals.PromptContainer.Parent = GetHiddenContainer()

local ESPBlacklist = {}

Functions.AddESP = function(ESPOptions, RoomBased)
	local Object = ESPOptions.Object

	if table.find(ESPBlacklist, Object) then
		return
	end

	if RoomBased then
		local CurrentRoom = tonumber(LocalPlayer:GetAttribute("CurrentRoom"))
		local ObjectRoom = tonumber(Object:GetAttribute("ParentRoom"))

		if ObjectRoom == CurrentRoom or (table.find(Objects.Doors, Object) and ObjectRoom == CurrentRoom + 1) then
			Abysall.ESPLibrary:AddESP(ESPOptions)
		end

		local RoomConnection = LocalPlayer:GetAttributeChangedSignal("CurrentRoom"):Connect(function()
			if Abysall.ESPLibrary.ColorTable[Object] then
				ESPOptions.Color = Abysall.ESPLibrary.ColorTable[Object]
			end

			local NewCurrentRoom = tonumber(LocalPlayer:GetAttribute("CurrentRoom"))
			local ObjRoom = tonumber(Object:GetAttribute("ParentRoom"))

			if ObjRoom == NewCurrentRoom or (table.find(Objects.Doors, Object) and ObjRoom == NewCurrentRoom + 1) then
				Abysall.ESPLibrary:AddESP(ESPOptions)
			else
				Abysall.ESPLibrary:RemoveESP(Object)
			end
		end)

		table.insert(Connections, RoomConnection)
		ESPConnections[Object] = RoomConnection

		Object.Destroying:Once(function()
			RoomConnection:Disconnect()
			if Abysall then
				Abysall.ESPLibrary:RemoveESP(Object)
			end
			local Pos = table.find(Connections, RoomConnection)
			if Pos then table.remove(Connections, Pos) end
		end)
	else
		Abysall.ESPLibrary:AddESP(ESPOptions)
	end
end

Functions.RemoveESP = function(Object)
	local Conn = ESPConnections[Object]
	if Conn then
		Conn:Disconnect()
		ESPConnections[Object] = nil
		local Pos = table.find(Connections, Conn)
		if Pos then table.remove(Connections, Pos) end
	end
	Abysall.ESPLibrary:RemoveESP(Object)
end

Functions.BlacklistESP = function(Object)
	table.insert(ESPBlacklist, Object)
end

Functions.GetDoorNumber = function(Object)
	local DoorNumber = tonumber(Object.Parent.Name) or tonumber(Object.Parent.Parent.Name)
	if DoorNumber then
		DoorNumber = DoorNumber + 1
	end
	if Floor == "Mines" then
		DoorNumber = DoorNumber + 100
	end
	if Floor == "Backdoor" then
		DoorNumber = DoorNumber - 50
	end

	return tostring(DoorNumber)
end

Functions.GetLibraryCode = function()
	local Paper = Character:FindFirstChild("LibraryHintPaper")
		or Character:FindFirstChild("LibraryHintPaperHard")
		or LocalPlayer.Backpack:FindFirstChild("LibraryHintPaper")
		or LocalPlayer.Backpack:FindFirstChild("LibraryHintPaperHard")

	if Paper and Paper:FindFirstChild("UI") then
		local Code = {}
		local CodeLength = Floor == "Fools" and 10 or 5
		for I = 1, CodeLength do Code[I] = "_" end

		local HintChildren = LocalPlayer.PlayerGui.PermUI.Hints:GetChildren()
		local UIChildren = Paper.UI:GetChildren()

		for _, Hint in HintChildren do
			for _, UIChild in UIChildren do
				if Hint:IsA("ImageLabel") and UIChild:IsA("ImageLabel")
					and Hint.ImageRectOffset == UIChild.ImageRectOffset
					and Code[tonumber(UIChild.Name)]
				then
					Code[tonumber(UIChild.Name)] = Hint.TextLabel.Text
				end
			end
		end
		return table.concat(Code)
	end
	return Floor == "Fools" and "__________" or "_____"
end

Globals.UsedRandomCodes = {}
Functions.GetRandomCode = function()
    local CodeTemplate = Functions.GetLibraryCode()
    if not CodeTemplate then
        return nil
    end

    local NewCode
    local Tries = 0
    repeat
        NewCode = CodeTemplate:gsub("_", function()
            return tostring(math.random(0, 9))
        end)
        Tries = Tries + 1
    until not Globals.UsedRandomCodes[NewCode] or Tries >= 10

    Globals.UsedRandomCodes[NewCode] = true
    return NewCode
end

local Window = Library:CreateWindow({
	Title = "Ms fent Hub | Doors",
	Footer = "made by gabrieltod112",
	NotifySide = "Right",
	ShowCustomCursor = false,
	AutoShow = true,
	Center = true,
	TabPadding = 3,
	MenuFadeTime = 0,
	CornerRadius = 6,
})


-- Ms fent: no Abysall InfoTab

local Tabs = {
	General = Window:AddTab("General", "house"),
	Exploits = Window:AddTab("Exploits", "shield"),
	Visuals = Window:AddTab("Visuals", "eye"),
	Floors = Window:AddTab("Floors", "earth"),
	Archives = Window:AddTab("Archives", "rbxassetid://104508835882225"),
	Stairwell = Window:AddTab("Stairwell", "rbxassetid://80017304328364"),
	Halloween = Window:AddTab("New - Halloween", "rbxassetid://101034055693026"),
}

-- INFO / CHANGELOG (Ms fent) — first-class tab so it always shows
do
	local InfoTab = Window:AddTab("Info", "info")
	Tabs.Info = InfoTab
	local left = InfoTab:AddLeftGroupbox("About")
	left:AddLabel("Ms fent Hub | Doors", true)
	left:AddLabel("made by gabrieltod112", true)
	left:AddLabel("UI: Obsidian  |  logic: inlined Abysall", true)
	left:AddLabel("Configs folder: MsFent/Doors", true)
	left:AddLabel("Menu keybind: check Settings tab", true)
	local right = InfoTab:AddRightGroupbox("Changelog")
	local lines = (getgenv().MsFent and getgenv().MsFent.LatestChangelog) or {}
	for _, line in ipairs(lines) do
		-- strip HTML so Obsidian labels always show text
		local plain = tostring(line):gsub("<.->", "")
		pcall(function()
			right:AddLabel(plain, true)
		end)
	end
	-- Settings + config save
	local setTab = Window:AddTab("Settings", "settings")
	Tabs.Settings = setTab
	pcall(function()
		ThemeManager:ApplyToTab(setTab)
		SaveManager:BuildConfigSection(setTab)
	end)
	getgenv().MsFent = getgenv().MsFent or {}
	getgenv().MsFent._Window = Window
end



Groupboxes.General_Character = Tabs.General:AddLeftGroupbox("Character")
Groupboxes.General_Character:AddSlider("SpeedBoostSlider", {
	Text = "Speed Boost", Min = 0, Max = 100, Default = 0, Rounding = 0, Compact = true
})
Groupboxes.General_Character:AddToggle("SpeedBoostToggle", {
	Text = "Enable Speed Boost", Default = false, Tooltip = "Increases your walkspeed by the specified amount."
})
Groupboxes.General_Character:AddToggle("FlyToggle", {
	Text = "Fly", Default = false, Tooltip = "Allows you to freely fly around the map."
})
Toggles.FlyToggle:AddKeyPicker("FlyKeybind", {
	Text = "Fly", Default = "F", Mode = "Toggle", SyncToggleState = true
})
Groupboxes.General_Character:AddSlider("FlySpeed", {
	Text = "Fly Speed", Min = 0, Max = 115, Default = 20, Rounding = 0, Compact = true
})
Groupboxes.General_Character:AddDivider()
Groupboxes.General_Character:AddToggle("NoclipToggle", {
	Text = "Noclip", Default = false, Tooltip = "Allows your character to pass through solid objects."
})
Groupboxes.General_Character:AddToggle("RemoveClosetDelay", {
	Text = "Remove Closet Delay", Default = false,
	Tooltip = "Removes the short window where you can't exit out of a closet after the animation finishes."
})
Groupboxes.General_Character:AddToggle("RemoveAcceleration", {
	Text = "Remove Acceleration", Default = false, Tooltip = "Prevents your character from sliding while moving."
})

local CustomPhysics

Options.SpeedBoostSlider:OnChanged(function(Value)
	if RemotesFolder:FindFirstChild("Crouch") then
		RemotesFolder.Crouch:FireServer(Value and true or Functions.IsCrouching(), true)
	end
end)

Toggles.NoclipToggle:AddKeyPicker("NoclipKeybind", {
	Text = "Noclip", Default = "N", Mode = "Toggle", SyncToggleState = true
})
Toggles.RemoveAcceleration:OnChanged(function(Value)
	for Index, Old in PartProperties do
		Index.CustomPhysicalProperties = Value and CustomPhysics or Old
	end
end)

Groupboxes.General_Character:AddDivider()
Groupboxes.General_Character:AddToggle("EnableCharacterJump", {
	Text = "Enable Jumping", Default = false, Tooltip = "Allows your character to jump."
})
Groupboxes.General_Character:AddToggle("EnableCharacterSlide", {
	Text = "Enable Sliding", Default = false, Tooltip = "Allows your character to slide."
})
Groupboxes.General_Character:AddToggle("InfiniteJumps", {
	Text = "Infinite Jumps", Default = false, Tooltip = "Allows you to jump while in the air."
})

Groupboxes.General_Character:AddToggle("GlueToGround", {
	Text = "Glue To Ground", Default = false,
	Tooltip = "Keeps you on the floor at high speed (no bounce/airborne from collisions). Only leaves ground when Jump is enabled and you jump."
})

local OldJump = false
local OldSlide = false
local GlueToGroundConnection = nil
local GlueJumpPressed = false
local GlueWasEnabledBeforePositionSpoof = false

pcall(function()
	Connections.GlueJumpInput = Services.UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.ButtonA then
			GlueJumpPressed = true
			task.delay(0.35, function() GlueJumpPressed = false end)
		end
	end)
end)

if Toggles.GlueToGround then
	Toggles.GlueToGround:OnChanged(function(Value)
		if GlueToGroundConnection then
			pcall(function() GlueToGroundConnection:Disconnect() end)
			GlueToGroundConnection = nil
		end
		if not Value then return end

		local rayParams = RaycastParams.new()
		rayParams.FilterType = Enum.RaycastFilterType.Exclude
		rayParams.IgnoreWater = true

		-- Heartbeat + Stepped: high speed needs tighter snaps than FloorMaterial alone
		GlueToGroundConnection = Services.RunService.Heartbeat:Connect(function()
			pcall(function()
				if not (Toggles.GlueToGround and Toggles.GlueToGround.Value) then return end
				local char = Character or LocalPlayer.Character
				if not char then return end
				local hum = Humanoid or char:FindFirstChildOfClass("Humanoid")
				local root = RootPart or char:FindFirstChild("HumanoidRootPart")
				if not hum or not root or hum.Health <= 0 then return end
				if char:GetAttribute("Hiding") then return end
				if Toggles.FlyToggle and Toggles.FlyToggle.Value then return end
				if Toggles.NoclipToggle and Toggles.NoclipToggle.Value then return end

				local allowJump = Toggles.EnableCharacterJump and Toggles.EnableCharacterJump.Value
				local jumping = allowJump and GlueJumpPressed
				local state = hum:GetState()

				-- Always kill upward / float unless intentionally jumping
				if not jumping then
					local vel = root.AssemblyLinearVelocity
					if vel.Y > 0 then
						root.AssemblyLinearVelocity = Vector3.new(vel.X, 0, vel.Z)
					end
					if state == Enum.HumanoidStateType.Jumping
						or state == Enum.HumanoidStateType.Freefall
						or state == Enum.HumanoidStateType.FallingDown
					then
						hum:ChangeState(Enum.HumanoidStateType.Running)
					end
				end

				-- Ray down: stick to ground under feet (works when FloorMaterial lags at high speed)
				rayParams.FilterDescendantsInstances = { char }
				local hip = (hum.HipHeight and hum.HipHeight > 0) and hum.HipHeight or 2.0
				local probe = root.Position + Vector3.new(0, 0.5, 0)
				local ray = workspace:Raycast(probe, Vector3.new(0, -(hip + 8), 0), rayParams)
				if not ray then
					-- wider / longer fallback
					ray = workspace:Raycast(root.Position, Vector3.new(0, -14, 0), rayParams)
				end
				if ray and not jumping then
					local targetY = ray.Position.Y + hip + 0.15
					local dy = root.Position.Y - targetY
					-- Snap if slightly airborne or sunk (collision bounce)
					if dy > 0.08 and dy < 6 then
						root.CFrame = CFrame.new(root.Position.X, targetY, root.Position.Z)
							* (root.CFrame - root.CFrame.Position)
						local vel = root.AssemblyLinearVelocity
						root.AssemblyLinearVelocity = Vector3.new(vel.X, math.min(vel.Y, 0), vel.Z)
						hum:ChangeState(Enum.HumanoidStateType.Running)
					elseif dy < -0.2 and dy > -3 then
						-- sunk into floor a bit — lift back
						root.CFrame = CFrame.new(root.Position.X, targetY, root.Position.Z)
							* (root.CFrame - root.CFrame.Position)
					end
				end
			end)
		end)
	end)
end



local OldJump = false
local OldSlide = false

Toggles.SpeedBoostToggle:OnChanged(function(Value)
	if Humanoid then
		Humanoid.WalkSpeed = Functions.GetCurrentSpeed() + (Value and Options.SpeedBoostSlider.Value or 0)
	end
end)
Toggles.EnableCharacterJump:OnChanged(function(Value)
	if Character then
		Character:SetAttribute("CanJump", Value and true or OldJump)
	end
end)
Toggles.EnableCharacterSlide:OnChanged(function(Value)
	if Character then
		Character:SetAttribute("CanSlide", Value and true or OldSlide)
	end
end)

Groupboxes.General_Self = Tabs.General:AddLeftGroupbox("Self")
Groupboxes.General_Self:AddToggle("DoorReachToggle", {
	Text = "Door Reach", Default = false, Tooltip = "Allows you to open doors from further away."
})
Groupboxes.General_Self:AddToggle("DisableIdleKick", {
	Text = "Disable Idle Kick", Default = false, Tooltip = "Prevents the kick from being idle for 20 minutes."
})
Toggles.DisableIdleKick:OnChanged(function(Value)
	if Functions.CheckCompatability({"getconnections"}) then
		for _, Conn in Abysall.Environment.getconnections(LocalPlayer.Idled) do
			if Value then Conn:Disable() else Conn:Enable() end
		end
	end
end)
LocalPlayer.Idled:Connect(function()
	if Toggles.DisableIdleKick.Value then
		Services.VirtualUser:CaptureController()
		Services.VirtualUser:ClickButton2(Vector2.new())
	end
end)

Groupboxes.General_Self:AddDivider()
Groupboxes.General_Self:AddSlider("PromptReachSlider", {
	Text = "Prompt Reach Multiplier", Min = 1, Max = 2, Default = 1, Rounding = 1, Compact = true
})
Groupboxes.General_Self:AddToggle("InstantPrompts", {
	Text = "Instant Prompts", Default = false, Tooltip = "Allows you to trigger all prompts instantly."
})
Groupboxes.General_Self:AddToggle("PromptClip", {
	Text = "Prompt Clip", Default = false, Tooltip = "Allows you to interact with prompts through walls."
})

Options.PromptReachSlider:OnChanged(function(Value)
	for _, Prompt in Objects.Prompts do
		Prompt.MaxActivationDistance = Prompt:GetAttribute("MaxActivationDistance_Old") * Value
	end
end)
Toggles.InstantPrompts:OnChanged(function(Value)
	for _, Prompt in Objects.Prompts do
		Prompt.HoldDuration = Value and 0 or Prompt:GetAttribute("HoldDuration_Old")
	end
end)
Toggles.PromptClip:OnChanged(function(Value)
	for _, Prompt in Objects.Prompts do
		Prompt.RequiresLineOfSight = Value and false or Prompt:GetAttribute("RequiresLineOfSight_Old")
	end
end)

Groupboxes.Self_Automation = Tabs.General:AddRightGroupbox("Automation")
Groupboxes.Self_Automation:AddToggle("AutoBreakerBox", {
	Text = "Auto Breaker Box", Default = false, Tooltip = "Automatically solves the breaker box."
})
Groupboxes.Self_Automation:AddToggle("AutoSolveAnchors", {
	Text = "Auto Solve Anchors", Default = false,
	Tooltip = "Automatically enters the correct code into anchors when you are near them."
})
Toggles.AutoBreakerBox:OnChanged(function(Value)
	if Value and CurrentRooms:FindFirstChild("ElevatorBreaker", true) then
		if not Globals.BreakerBoxInteracted then
			if not Globals.BreakerBoxNotified then
				Functions.Notify({ Title = "Interact with the breaker box.", Body = "It will be automatically solved." })
				Globals.BreakerBoxInteracted = true
			end
		else
			RemotesFolder.EBF:FireServer()
		end
	end
end)

Groupboxes.Self_Automation:AddToggle("AutoHeartbeatMinigame", { Text = "Auto Heartbeat Minigame", Default = false, Tooltip = "Prevents the 'Figure' minigame from ever failing.", Disabled = not Functions.CheckCompatability({"hookmetamethod", "newcclosure", "getnamecallmethod"}), DisabledTooltip = Globals.IncompatibleMessage })
Groupboxes.Self_Automation:AddDivider()
Groupboxes.Self_Automation:AddToggle("AutoUnlockPadlockToggle", {
	Text = "Auto Unlock Padlock", Default = false, Tooltip = "Automatically enters the code into the library padlock."
})
Groupboxes.Self_Automation:AddSlider("AutoUnlockPadlockSlider", {
	Text = "Unlock Distance", Min = 1, Max = 50, Default = 10, Rounding = 0, Compact = true
})
Groupboxes.Self_Automation:AddToggle("AutoLibraryGuessCode", {
	Text = "Guess Library Code", Default = false,
	Tooltip = "Attempts to guess the library code, but collecting some books is also necessary."
})
Groupboxes.Self_Automation:AddDivider()
Groupboxes.Self_Automation:AddToggle("AutoLibrary", {
	Text = "Auto Library", Default = false,
	Tooltip = "Automatically gets books and paper."
})
Groupboxes.Self_Automation:AddToggle("SkipSeekHotel", {
	Text = "Skip Seek (Hotel)",
	Default = false,
	Tooltip = "Skips the entire Seek sections.",
})
Groupboxes.Self_Automation:AddToggle("AutoBreakerRoom", {
	Text = "Auto Breaker Room",
	Default = false,
	Tooltip = "Automatically completes the breaker sequence in Hotel Room 100.",
})
Groupboxes.Self_Automation:AddDivider()
Toggles.AutoHotel = Groupboxes.Self_Automation:AddToggle("AutoHotel", {
	Text = "Auto Hotel",
	Tooltip = "Automatically progresses through the hotel floor.",
	Risky = Floor ~= "Ballz",
	Default = false
})
Toggles.AutoHotelIgnoreEntities = Groupboxes.Self_Automation:AddToggle("AutoHotelIgnoreEntities", {
	Text = "Ignore Entities",
	Tooltip = "Skip all entity waits and pauses.",
	Default = false
})
Groupboxes.Self_Automation:AddDivider()
Groupboxes.Self_Automation:AddToggle("AutoInteractToggle", {
	Text = "Auto Interact", Default = false, Tooltip = "Automatically triggers nearby prompts."
})
Toggles.AutoInteractToggle:AddKeyPicker("AutoInteractKeybind", {
    Text = "Auto Interact",
    Default = "R",
    Mode = "Toggle",
    SyncToggleState = true
})
Groupboxes.Self_Automation:AddDropdown("AutoInteractIgnoreList", {
	Text = "Ignore List",
	Values = { "Glitch Fragments", "Jeff Items", "Dropped Items", "Currency", "Minecarts", "Locks" },
	Default = { "Glitch Fragments", "Jeff Items", "Dropped Items" },
	Multi = true, AllowNull = true
})
Groupboxes.Self_Automation:AddDivider()
Groupboxes.Self_Automation:AddToggle("AutoClosetToggle", {
	Text = "Auto Closet", Default = false,
	Tooltip = "Automatically hides in a nearby closet when an entity is near."
})
Toggles.AutoClosetToggle:AddKeyPicker("AutoClosetKeybind", {
	Text = "Auto Closet", Default = "Q", Mode = "Toggle", SyncToggleState = true
})
Groupboxes.Self_Automation:AddDropdown("AutoClosetEntityList", {
	Text = "Ignore List",
	Values = { "Rush", "Ambush", "Blitz", "DronesStampede", "Scribbles", "A-60", "A-120", "AR0xMBUSH", "RNIUSHCG==" },
	Multi = true, AllowNull = true
})
Groupboxes.Self_Automation:AddToggle("SpectateEntityToggle", {
	Text = "Spectate Entity",
	Default = false,
	Tooltip = "Spectates the entity while auto hiding."
})
Groupboxes.Self_Automation:AddDropdown("SpecateEntityMode", {
	Values = {"Player to Entity", "Entity to Player"},
	Default = 1,
	AllowNull = true
})

Groupboxes.Self_Misc = Tabs.General:AddRightGroupbox("Miscellaneous")
Groupboxes.Self_Misc:AddButton({
	Text = "Play Again", Tooltip = "Makes you join a new run, click again to cancel.", DoubleClick = true,
	Func = function() RemotesFolder.PlayAgain:FireServer() end
})
Groupboxes.Self_Misc:AddButton({
	Text = "Return to Lobby", Tooltip = "Makes you teleport back to the lobby.", DoubleClick = true,
	Func = function() RemotesFolder.Lobby:FireServer() end
})
Groupboxes.Self_Misc:AddButton({
	Text = "Revive",
	Tooltip = "Makes you revive, if you have a revive and haven't already revived in this run.",
	DoubleClick = true,
	Func = function() RemotesFolder.Revive:FireServer() end
})
Groupboxes.Self_Misc:AddButton({
	Text = "Reset Character",
	Tooltip = "Kills your character on the server. (takes around 20 seconds if replicatesignal isn't supported)",
	DoubleClick = true,
	Func = function()
		Globals.SelfKilled = true
		if Functions.CheckCompatability({"replicatesignal"}) then
			Abysall.Environment.replicatesignal(LocalPlayer.Kill)
		else
			if RemotesFolder:FindFirstChild("Underwater") then
				RemotesFolder.Underwater:FireServer(true)
			else
				Humanoid.Health = 0
			end
		end
	end
})


Tabs.General:UpdateWarningBox({
	Visible = true,
	Title = "Risk Warning",
	Text = "Features highlighted in red are risky.",
})


Toggles.SkipSeekHotel:OnChanged(function(Value)
	if not Value then return end
	if Floor ~= "Hotel" then return end

	task.spawn(function()
		print("started")

		local currentRooms

		repeat
			if not Toggles.SkipSeekHotel.Value or Floor ~= "Hotel" then
				return
			end
			currentRooms = workspace:FindFirstChild("CurrentRooms")
			task.wait()
		until currentRooms

		print("got currentrooms")

		local lastTriggerRoom = nil

		while Toggles.SkipSeekHotel.Value and Floor == "Hotel" do
			local triggerRoom = nil

			print("waiting for trigger")

			repeat
				if not Toggles.SkipSeekHotel.Value or Floor ~= "Hotel" then
					return
				end

				currentRooms = workspace:FindFirstChild("CurrentRooms")
				local currentRoomNum = tonumber(LocalPlayer:GetAttribute("CurrentRoom"))

				if currentRoomNum and currentRoomNum ~= lastTriggerRoom then
					local room = currentRooms and currentRooms:FindFirstChild(tostring(currentRoomNum))
					if room then
						local trigger = room:WaitForChild("TriggerEventCollision", 0.5)
						if trigger then
							triggerRoom = currentRoomNum
							print("found trigger in", triggerRoom)
						end
					end
				end

				task.wait()
			until triggerRoom

			lastTriggerRoom = triggerRoom

			local roomNum = triggerRoom

			while Toggles.SkipSeekHotel.Value and Floor == "Hotel" do
				roomNum += 1
				print("looking for room", roomNum)

				local room
				repeat
					if not Toggles.SkipSeekHotel.Value or Floor ~= "Hotel" then
						return
					end
					currentRooms = workspace:FindFirstChild("CurrentRooms")
					room = currentRooms and currentRooms:FindFirstChild(tostring(roomNum))
					task.wait()
				until room

				print("found room", roomNum)

				local hasSeekArm = false
				local assets = room:FindFirstChild("Assets")
				if assets then
					for _, child in ipairs(assets:GetChildren()) do
						if child.Name == "Seek_Arm" then
							hasSeekArm = true
							print("found seek arm")
							break
						end
					end
				end

				local door
				repeat
					if not Toggles.SkipSeekHotel.Value or Floor ~= "Hotel" then
						return
					end
					door = room:FindFirstChild("Door", true)
					task.wait()
				until door

				print("found door, teleporting")

				repeat
					if not Toggles.SkipSeekHotel.Value or Floor ~= "Hotel" then
						return
					end
					if Character then
						Character:PivotTo(door:GetPivot())
					end
					task.wait()
				until door:GetAttribute("Opened") == true

				print("door opened")

				if hasSeekArm then
					if not Character then
						return
					end

					print("voiding")

					local voidCFrame = Character:GetPivot() + Vector3.new(0, -2500, 0)

					task.wait(0.25)

					for _ = 1, 20 do
						Character:PivotTo(voidCFrame)
						task.wait()
					end

					task.wait(0.3)

					for _ = 1, 15 do
						Character:PivotTo(voidCFrame)
						task.wait()
					end

					task.wait(0.2)

					for _ = 1, 10 do
						Character:PivotTo(voidCFrame)
						task.wait()
					end

					print("done voiding")
					break
				end
			end
		end
	end)
end)

Toggles.AutoLibrary:OnChanged(function(AutoLibraryEnabled)
	if AutoLibraryConnection then
		task.cancel(AutoLibraryConnection)
		AutoLibraryConnection = nil
	end

	if AutoLibraryRoomConnection then
		AutoLibraryRoomConnection:Disconnect()
		AutoLibraryRoomConnection = nil
	end

	if not AutoLibraryEnabled then
		return
	end

	AutoLibraryConnection = task.spawn(function()
		local AutoLibraryPlayers = game:GetService("Players")
		local AutoLibraryLocalPlayer = AutoLibraryPlayers.LocalPlayer
		local AutoLibraryCharacter = AutoLibraryLocalPlayer.Character or AutoLibraryLocalPlayer.CharacterAdded:Wait()
		local AutoLibraryHumanoidRootPart = AutoLibraryCharacter:WaitForChild("HumanoidRootPart")

		local AutoLibraryCurrentRooms = workspace:WaitForChild("CurrentRooms")
		local AutoLibraryRoom50 = AutoLibraryCurrentRooms:WaitForChild("50")
		local AutoLibraryLiveHintBooks = {}
		local AutoLibraryHintPaperObtained = false

		local function AutoLibraryIsInRoom50(AutoLibraryObject)
			return AutoLibraryObject
				and AutoLibraryObject:IsDescendantOf(AutoLibraryRoom50)
				and AutoLibraryObject:IsDescendantOf(AutoLibraryCurrentRooms)
				and AutoLibraryObject:IsDescendantOf(workspace)
		end

		local function AutoLibraryIsActuallyInRoom50()
			return tonumber(AutoLibraryLocalPlayer:GetAttribute("CurrentRoom")) == 50
		end

		while AutoLibraryEnabled and not AutoLibraryIsActuallyInRoom50() do
			task.wait(0.05)
		end

		if not AutoLibraryEnabled then
			return
		end

		local function AutoLibraryHasHintPaper()
			AutoLibraryCharacter = AutoLibraryLocalPlayer.Character

			if not AutoLibraryCharacter then
				return false
			end

			local AutoLibraryBackpackPaper = AutoLibraryLocalPlayer.Backpack:FindFirstChild("LibraryHintPaper", true)
			local AutoLibraryCharacterPaper = AutoLibraryCharacter:FindFirstChild("LibraryHintPaper", true)

			return AutoLibraryBackpackPaper ~= nil or AutoLibraryCharacterPaper ~= nil
		end

		local function AutoLibraryGetObjectCFrame(AutoLibraryObject)
			if not AutoLibraryIsActuallyInRoom50() then
				return nil
			end

			if not AutoLibraryIsInRoom50(AutoLibraryObject) then
				return nil
			end

			if AutoLibraryObject:IsA("Model") then
				return AutoLibraryObject:GetPivot()
			elseif AutoLibraryObject:IsA("BasePart") then
				return AutoLibraryObject.CFrame
			end

			local AutoLibraryObjectPart = AutoLibraryObject:FindFirstChildWhichIsA("BasePart", true)

			if AutoLibraryObjectPart then
				return AutoLibraryObjectPart.CFrame
			end

			return nil
		end

		local function AutoLibraryFindBooks(AutoLibraryObject)
			if not AutoLibraryIsActuallyInRoom50() then
				return
			end

			if not AutoLibraryIsInRoom50(AutoLibraryObject) then
				return
			end

			if AutoLibraryObject.Name == "LiveHintBook" then
				if not table.find(AutoLibraryLiveHintBooks, AutoLibraryObject) then
					table.insert(AutoLibraryLiveHintBooks, AutoLibraryObject)
				end
			end

			for _, AutoLibraryDescendant in ipairs(AutoLibraryObject:GetDescendants()) do
				if AutoLibraryDescendant.Name == "LiveHintBook"
					and AutoLibraryIsInRoom50(AutoLibraryDescendant) then

					if not table.find(AutoLibraryLiveHintBooks, AutoLibraryDescendant) then
						table.insert(AutoLibraryLiveHintBooks, AutoLibraryDescendant)
					end
				end
			end
		end

		for _, AutoLibraryDescendant in ipairs(AutoLibraryRoom50:GetDescendants()) do
			if not AutoLibraryEnabled or not AutoLibraryIsActuallyInRoom50() then
				return
			end

			if AutoLibraryDescendant.Name == "LiveHintBook"
				and AutoLibraryIsInRoom50(AutoLibraryDescendant) then

				if not table.find(AutoLibraryLiveHintBooks, AutoLibraryDescendant) then
					table.insert(AutoLibraryLiveHintBooks, AutoLibraryDescendant)
				end
			end
		end

		AutoLibraryRoomConnection = AutoLibraryRoom50.DescendantAdded:Connect(function(AutoLibraryAddedObject)
			if not AutoLibraryEnabled then
				return
			end

			if not AutoLibraryIsActuallyInRoom50() then
				return
			end

			if not AutoLibraryIsInRoom50(AutoLibraryAddedObject) then
				return
			end

			AutoLibraryFindBooks(AutoLibraryAddedObject)
		end)

		while AutoLibraryEnabled
			and AutoLibraryIsActuallyInRoom50()
			and #AutoLibraryLiveHintBooks < 3 do

			for _, AutoLibraryDescendant in ipairs(AutoLibraryRoom50:GetDescendants()) do
				if not AutoLibraryEnabled or not AutoLibraryIsActuallyInRoom50() then
					return
				end

				if AutoLibraryDescendant.Name == "LiveHintBook"
					and AutoLibraryIsInRoom50(AutoLibraryDescendant)
					and not table.find(AutoLibraryLiveHintBooks, AutoLibraryDescendant) then

					table.insert(AutoLibraryLiveHintBooks, AutoLibraryDescendant)
				end
			end

			if #AutoLibraryLiveHintBooks >= 3 then
				break
			end

			task.wait(0.05)
		end

		while AutoLibraryEnabled
			and AutoLibraryIsActuallyInRoom50()
			and not AutoLibraryHintPaperObtained do

			if AutoLibraryHasHintPaper() then
				AutoLibraryHintPaperObtained = true
				break
			end

			for AutoLibraryIndex = #AutoLibraryLiveHintBooks, 1, -1 do
				if not AutoLibraryIsActuallyInRoom50() then
					return
				end

				local AutoLibraryLiveHintBook = AutoLibraryLiveHintBooks[AutoLibraryIndex]

				if not AutoLibraryIsInRoom50(AutoLibraryLiveHintBook) then
					table.remove(AutoLibraryLiveHintBooks, AutoLibraryIndex)
					continue
				end

				while AutoLibraryEnabled
					and AutoLibraryIsActuallyInRoom50()
					and not AutoLibraryHintPaperObtained
					and AutoLibraryLiveHintBook.Parent
					and AutoLibraryIsInRoom50(AutoLibraryLiveHintBook) do

					if AutoLibraryHasHintPaper() then
						AutoLibraryHintPaperObtained = true
						break
					end

					AutoLibraryCharacter = AutoLibraryLocalPlayer.Character or AutoLibraryLocalPlayer.CharacterAdded:Wait()
					AutoLibraryHumanoidRootPart = AutoLibraryCharacter:FindFirstChild("HumanoidRootPart")

					if not AutoLibraryHumanoidRootPart then
						task.wait()
						continue
					end

					local AutoLibraryBookCFrame = AutoLibraryGetObjectCFrame(AutoLibraryLiveHintBook)

					if AutoLibraryBookCFrame
						and AutoLibraryIsActuallyInRoom50()
						and AutoLibraryIsInRoom50(AutoLibraryLiveHintBook) then

						AutoLibraryHumanoidRootPart.CFrame = AutoLibraryBookCFrame
					end

					for _, AutoLibraryPromptDescendant in ipairs(AutoLibraryLiveHintBook:GetDescendants()) do
						if AutoLibraryPromptDescendant:IsA("ProximityPrompt")
							and AutoLibraryIsInRoom50(AutoLibraryPromptDescendant)
							and AutoLibraryIsActuallyInRoom50() then

							fireproximityprompt(AutoLibraryPromptDescendant)
						end
					end

					task.wait(0.05)
				end

				if AutoLibraryHintPaperObtained then
					break
				end
			end

			if AutoLibraryHasHintPaper() then
				AutoLibraryHintPaperObtained = true
				break
			end

			local AutoLibraryHintPaper = AutoLibraryRoom50:FindFirstChild("LibraryHintPaper", true)

			if AutoLibraryHintPaper
				and AutoLibraryIsInRoom50(AutoLibraryHintPaper)
				and AutoLibraryIsActuallyInRoom50() then

				while AutoLibraryEnabled
					and AutoLibraryIsActuallyInRoom50()
					and not AutoLibraryHintPaperObtained
					and AutoLibraryHintPaper.Parent
					and AutoLibraryIsInRoom50(AutoLibraryHintPaper) do

					if AutoLibraryHasHintPaper() then
						AutoLibraryHintPaperObtained = true
						break
					end

					AutoLibraryCharacter = AutoLibraryLocalPlayer.Character or AutoLibraryLocalPlayer.CharacterAdded:Wait()
					AutoLibraryHumanoidRootPart = AutoLibraryCharacter:FindFirstChild("HumanoidRootPart")

					if not AutoLibraryHumanoidRootPart then
						task.wait()
						continue
					end

					local AutoLibraryPaperCFrame = AutoLibraryGetObjectCFrame(AutoLibraryHintPaper)

					if AutoLibraryPaperCFrame
						and AutoLibraryIsActuallyInRoom50()
						and AutoLibraryIsInRoom50(AutoLibraryHintPaper) then

						AutoLibraryHumanoidRootPart.CFrame = AutoLibraryPaperCFrame * CFrame.new(0, 5, 0)
					end

					for _, AutoLibraryPromptDescendant in ipairs(AutoLibraryHintPaper:GetDescendants()) do
						if AutoLibraryPromptDescendant:IsA("ProximityPrompt")
							and AutoLibraryIsInRoom50(AutoLibraryPromptDescendant)
							and AutoLibraryIsActuallyInRoom50() then

							fireproximityprompt(AutoLibraryPromptDescendant)
						end
					end

					task.wait(0.05)
				end
			end

			task.wait(0.05)
		end
	end)
end)

Toggles.AutoBreakerRoom:OnChanged(function(AutoBreakerRoomEnabled)
	if AutoBreakerRoomConnection then
		task.cancel(AutoBreakerRoomConnection)
		AutoBreakerRoomConnection = nil
	end

	if AutoBreakerRoomRoomConnection then
		AutoBreakerRoomRoomConnection:Disconnect()
		AutoBreakerRoomRoomConnection = nil
	end

	if not AutoBreakerRoomEnabled then
		return
	end

	local AutoBreakerRoomGateFireTime = 5
	local AutoBreakerRoomWaitAfterLever = 5
	local AutoBreakerRoomBreakerSecondTime = 10
	local AutoBreakerRoomWaitBeforeWeb = 4
	local AutoBreakerRoomWebDuration = 20

	AutoBreakerRoomConnection = task.spawn(function()
		local AutoBreakerRoomPlayers = game:GetService("Players")
		local AutoBreakerRoomCurrentRooms = workspace:WaitForChild("CurrentRooms")
		local AutoBreakerRoom100 = AutoBreakerRoomCurrentRooms:WaitForChild("100")

		local function AutoBreakerRoomIsActuallyInRoom100()
			return tonumber(AutoBreakerRoomPlayers.LocalPlayer:GetAttribute("CurrentRoom")) == 100
		end

		local function AutoBreakerRoomIsInRoom100(AutoBreakerRoomObject)
			return AutoBreakerRoomObject
				and AutoBreakerRoomObject.Parent
				and AutoBreakerRoomObject:IsDescendantOf(AutoBreakerRoom100)
				and AutoBreakerRoomObject:IsDescendantOf(AutoBreakerRoomCurrentRooms)
		end

		local function AutoBreakerRoomGetObjectCFrame(AutoBreakerRoomObject)
			if not AutoBreakerRoomIsActuallyInRoom100() or not AutoBreakerRoomIsInRoom100(AutoBreakerRoomObject) then
				return nil
			end

			if AutoBreakerRoomObject:IsA("Model") then
				return AutoBreakerRoomObject:GetPivot()
			elseif AutoBreakerRoomObject:IsA("BasePart") then
				return AutoBreakerRoomObject.CFrame
			end

			local AutoBreakerRoomPart = AutoBreakerRoomObject:FindFirstChildWhichIsA("BasePart", true)
			return AutoBreakerRoomPart and AutoBreakerRoomPart.CFrame
		end

		local function AutoBreakerRoomGetHRP()
			local AutoBreakerRoomCharacter = AutoBreakerRoomPlayers.LocalPlayer.Character
			return AutoBreakerRoomCharacter and AutoBreakerRoomCharacter:FindFirstChild("HumanoidRootPart")
		end

		local function AutoBreakerRoomActivate(AutoBreakerRoomObject)
			if not AutoBreakerRoomObject then
				return
			end

			if AutoBreakerRoomObject:IsA("ProximityPrompt") then
				fireproximityprompt(AutoBreakerRoomObject)
				return
			end

			for _, AutoBreakerRoomDescendant in ipairs(AutoBreakerRoomObject:GetDescendants()) do
				if AutoBreakerRoomDescendant:IsA("ProximityPrompt") then
					fireproximityprompt(AutoBreakerRoomDescendant)
				end
			end
		end

		local function AutoBreakerRoomConstantTPAndActivate(AutoBreakerRoomTarget, AutoBreakerRoomDuration, AutoBreakerRoomInterval, AutoBreakerRoomOffset)
			AutoBreakerRoomInterval = AutoBreakerRoomInterval or 0.04
			AutoBreakerRoomOffset = AutoBreakerRoomOffset or CFrame.new()
			local AutoBreakerRoomEndTime = os.clock() + (AutoBreakerRoomDuration or 3)

			while AutoBreakerRoomEnabled
				and AutoBreakerRoomIsActuallyInRoom100()
				and AutoBreakerRoomIsInRoom100(AutoBreakerRoomTarget)
				and os.clock() < AutoBreakerRoomEndTime do

				local AutoBreakerRoomHRP = AutoBreakerRoomGetHRP()
				local AutoBreakerRoomCF = AutoBreakerRoomGetObjectCFrame(AutoBreakerRoomTarget)

				if AutoBreakerRoomHRP and AutoBreakerRoomCF then
					AutoBreakerRoomHRP.CFrame = AutoBreakerRoomCF * AutoBreakerRoomOffset
				end

				AutoBreakerRoomActivate(AutoBreakerRoomTarget)
				task.wait(AutoBreakerRoomInterval)
			end
		end

		while AutoBreakerRoomEnabled do
			while AutoBreakerRoomEnabled and not AutoBreakerRoomIsActuallyInRoom100() do
				task.wait(0.1)
			end

			if not AutoBreakerRoomEnabled then
				return
			end

			local AutoBreakerRoomPoles = {}

			while AutoBreakerRoomEnabled and AutoBreakerRoomIsActuallyInRoom100() do
				AutoBreakerRoomPoles = {}

				for _, AutoBreakerRoomDescendant in ipairs(AutoBreakerRoom100:GetDescendants()) do
					if AutoBreakerRoomDescendant.Name == "LiveBreakerPolePickup" and AutoBreakerRoomIsInRoom100(AutoBreakerRoomDescendant) then
						if not table.find(AutoBreakerRoomPoles, AutoBreakerRoomDescendant) then
							table.insert(AutoBreakerRoomPoles, AutoBreakerRoomDescendant)
						end
					end
				end

				if #AutoBreakerRoomPoles == 0 then
					break
				end

				for _, AutoBreakerRoomPole in ipairs(AutoBreakerRoomPoles) do
					if not AutoBreakerRoomEnabled or not AutoBreakerRoomIsActuallyInRoom100() then
						break
					end

					if AutoBreakerRoomIsInRoom100(AutoBreakerRoomPole) then
						AutoBreakerRoomConstantTPAndActivate(AutoBreakerRoomPole, 2.8, 0.03)
						task.wait(0.12)
					end
				end

				task.wait(0.05)
			end

			if not AutoBreakerRoomEnabled or not AutoBreakerRoomIsActuallyInRoom100() then
				continue
			end

			local AutoBreakerRoomIndustrialGate = AutoBreakerRoom100:FindFirstChild("IndustrialGate")
			local AutoBreakerRoomBox = AutoBreakerRoomIndustrialGate and AutoBreakerRoomIndustrialGate:FindFirstChild("Box")
			local AutoBreakerRoomLever = AutoBreakerRoomBox and AutoBreakerRoomBox:FindFirstChild("Lever")
			local AutoBreakerRoomActivateEventPrompt = AutoBreakerRoomBox and AutoBreakerRoomBox:FindFirstChild("ActivateEventPrompt")

			if AutoBreakerRoomActivateEventPrompt and AutoBreakerRoomLever then
				local function AutoBreakerRoomGetLeverCFrame()
					if AutoBreakerRoomLever:IsA("Model") then
						return AutoBreakerRoomLever:GetPivot()
					elseif AutoBreakerRoomLever:IsA("BasePart") then
						return AutoBreakerRoomLever.CFrame
					end
					local AutoBreakerRoomPart = AutoBreakerRoomLever:FindFirstChildWhichIsA("BasePart", true)
					return AutoBreakerRoomPart and AutoBreakerRoomPart.CFrame
				end

				local AutoBreakerRoomInitialLeverCFrame = AutoBreakerRoomGetLeverCFrame()
				local AutoBreakerRoomLeverEndTime = os.clock() + 10

				while AutoBreakerRoomEnabled
					and AutoBreakerRoomIsActuallyInRoom100()
					and AutoBreakerRoomIsInRoom100(AutoBreakerRoomLever)
					and os.clock() < AutoBreakerRoomLeverEndTime do

					local AutoBreakerRoomCurrentLeverCFrame = AutoBreakerRoomGetLeverCFrame()

					if AutoBreakerRoomCurrentLeverCFrame and AutoBreakerRoomInitialLeverCFrame
						and AutoBreakerRoomCurrentLeverCFrame ~= AutoBreakerRoomInitialLeverCFrame then
						break
					end

					local AutoBreakerRoomHRP = AutoBreakerRoomGetHRP()
					local AutoBreakerRoomCF = AutoBreakerRoomGetObjectCFrame(AutoBreakerRoomBox)

					if AutoBreakerRoomHRP and AutoBreakerRoomCF then
						AutoBreakerRoomHRP.CFrame = AutoBreakerRoomCF
					end

					AutoBreakerRoomActivate(AutoBreakerRoomActivateEventPrompt)
					task.wait(0.04)
				end
			end

			if not AutoBreakerRoomEnabled or not AutoBreakerRoomIsActuallyInRoom100() then
				continue
			end

			task.wait(AutoBreakerRoomWaitAfterLever)

			if not AutoBreakerRoomEnabled or not AutoBreakerRoomIsActuallyInRoom100() then
				continue
			end

			local AutoBreakerRoomElevatorBreakerEmpty = AutoBreakerRoom100:FindFirstChild("ElevatorBreakerEmpty")
			if not AutoBreakerRoomElevatorBreakerEmpty then
				continue
			end

			local AutoBreakerRoomBreakerPrompt = AutoBreakerRoomElevatorBreakerEmpty:FindFirstChild("Prompt")
			if not AutoBreakerRoomBreakerPrompt then
				continue
			end

			local AutoBreakerRoomBreakerOffset = CFrame.new(0, -1.8, 0)

			while AutoBreakerRoomEnabled and AutoBreakerRoomIsActuallyInRoom100() do
				if AutoBreakerRoomElevatorBreakerEmpty:FindFirstChild("BreakerSwitchInBox") then
					break
				end

				local AutoBreakerRoomHRP = AutoBreakerRoomGetHRP()
				local AutoBreakerRoomCF = AutoBreakerRoomGetObjectCFrame(AutoBreakerRoomElevatorBreakerEmpty)

				if AutoBreakerRoomHRP and AutoBreakerRoomCF then
					AutoBreakerRoomHRP.CFrame = AutoBreakerRoomCF * AutoBreakerRoomBreakerOffset
				end

				AutoBreakerRoomActivate(AutoBreakerRoomBreakerPrompt)
				task.wait(0.04)
			end

			if not AutoBreakerRoomEnabled or not AutoBreakerRoomIsActuallyInRoom100() then
				continue
			end

			task.wait(10)

			AutoBreakerRoomConstantTPAndActivate(
				AutoBreakerRoomElevatorBreakerEmpty,
				AutoBreakerRoomBreakerSecondTime,
				0.04,
				AutoBreakerRoomBreakerOffset
			)

			task.wait(AutoBreakerRoomWaitBeforeWeb)

			if not AutoBreakerRoomEnabled or not AutoBreakerRoomIsActuallyInRoom100() then
				continue
			end

			local AutoBreakerRoomElevatorCar = AutoBreakerRoom100:FindFirstChild("ElevatorCar")
			local AutoBreakerRoomWeb = AutoBreakerRoomElevatorCar and AutoBreakerRoomElevatorCar:FindFirstChild("Web", true)

			if AutoBreakerRoomWeb then
				local AutoBreakerRoomEndTime = os.clock() + AutoBreakerRoomWebDuration

				while AutoBreakerRoomEnabled and AutoBreakerRoomIsActuallyInRoom100() and os.clock() < AutoBreakerRoomEndTime do
					local AutoBreakerRoomHRP = AutoBreakerRoomGetHRP()
					local AutoBreakerRoomCF = AutoBreakerRoomGetObjectCFrame(AutoBreakerRoomWeb)

					if AutoBreakerRoomHRP and AutoBreakerRoomCF then
						AutoBreakerRoomHRP.CFrame = AutoBreakerRoomCF
					end

					task.wait(0.04)
				end
			end

			while AutoBreakerRoomEnabled and AutoBreakerRoomIsActuallyInRoom100() do
				task.wait(0.5)
			end
		end
	end)
end)



local AutoHotelConnection
local AutoHotelLibraryConnection
local AutoHotelLibraryRoomConnection
local AutoHotelSeekConnection
local AutoHotelEntityPause = false
local AutoHotelRoomProcessTime = 0.5
local AutoHotelProcessedRooms = {}

local AutoHotelEntityNames = {
	["RushMoving"] = true,
	["Scribbles"] = true,
	["BashMoving"] = true,
	["DronesStampede"] = true,
	["AmbushMoving"] = true,
	["A60"] = true,
	["A120"] = true,
	["GlitchRush"] = true,
	["GlitchAmbush"] = true,
	["BackdoorRush"] = true,
	["CustomEntity"] = true,
}

local function AutoHotelIsEntityPresent()
	if Toggles.AutoHotelIgnoreEntities and Toggles.AutoHotelIgnoreEntities.Value then
		return false
	end
	for _, AutoHotelChild in ipairs(workspace:GetChildren()) do
		if AutoHotelEntityNames[AutoHotelChild.Name] then
			return true
		end
	end
	return false
end

local function AutoHotelWaitForEntities(AutoHotelSeconds)
	if Toggles.AutoHotelIgnoreEntities and Toggles.AutoHotelIgnoreEntities.Value then
		return
	end

	task.wait(AutoHotelSeconds or 5)

	while AutoHotelIsEntityPresent() do
		task.wait(0.15)
	end
end

local function AutoHotelGetNextClosedDoor()
	if not Character then return nil, nil end

	local AutoHotelGameData = game:GetService("ReplicatedStorage"):FindFirstChild("GameData")
	if not AutoHotelGameData then return nil, nil end

	local AutoHotelLatestRoom = AutoHotelGameData:FindFirstChild("LatestRoom")
	if not AutoHotelLatestRoom then return nil, nil end

	local AutoHotelStartRoom = AutoHotelLatestRoom.Value
	local AutoHotelBestDoor, AutoHotelBestNumber = nil, math.huge
	local AutoHotelCurrentRooms = workspace:FindFirstChild("CurrentRooms")

	if AutoHotelCurrentRooms then
		for _, AutoHotelRoom in ipairs(AutoHotelCurrentRooms:GetChildren()) do
			local AutoHotelRoomNum = tonumber(AutoHotelRoom.Name)
			if AutoHotelRoomNum and AutoHotelRoomNum ~= 100 and AutoHotelRoomNum >= AutoHotelStartRoom and AutoHotelRoomNum < AutoHotelBestNumber then
				local AutoHotelDoor = AutoHotelRoom:FindFirstChild("Door")
				if AutoHotelDoor and AutoHotelDoor:IsA("Model") then
					local AutoHotelOpenAttr = AutoHotelDoor:GetAttribute("Open")
					if AutoHotelOpenAttr == false or AutoHotelOpenAttr == nil then
						AutoHotelBestNumber = AutoHotelRoomNum
						AutoHotelBestDoor = AutoHotelDoor
					end
				end
			end
		end
	end

	return AutoHotelBestDoor, AutoHotelBestNumber
end

local function AutoHotelFindKeyObtain(AutoHotelRoom)
	local AutoHotelFound = nil
	local function AutoHotelScan(AutoHotelParent)
		if AutoHotelFound then return end
		for _, AutoHotelChild in ipairs(AutoHotelParent:GetChildren()) do
			if AutoHotelChild.Name == "KeyObtain" then
				AutoHotelFound = AutoHotelChild
				return
			end
			AutoHotelScan(AutoHotelChild)
			if AutoHotelFound then return end
		end
	end
	AutoHotelScan(AutoHotelRoom)
	return AutoHotelFound
end

local function AutoHotelHandleKey(AutoHotelRoomNum)
	local AutoHotelCurrentRooms = workspace:FindFirstChild("CurrentRooms")
	if not AutoHotelCurrentRooms then return false end

	local AutoHotelRoom = AutoHotelCurrentRooms:FindFirstChild(tostring(AutoHotelRoomNum))
	if not AutoHotelRoom then return false end

	local AutoHotelDoor = AutoHotelRoom:FindFirstChild("Door")
	if not AutoHotelDoor or not AutoHotelDoor:FindFirstChild("Lock") then
		return false
	end

	local AutoHotelKeyObtain = AutoHotelFindKeyObtain(AutoHotelRoom)
	if not AutoHotelKeyObtain then return false end

	local AutoHotelStart = tick()
	while tick() - AutoHotelStart < 12 do
		if LocalPlayer.Backpack:FindFirstChild("Key") or (Character and Character:FindFirstChild("Key")) then
			return true
		end

		if Character then
			Character:PivotTo(AutoHotelKeyObtain:GetPivot())
		end

		for _, AutoHotelDesc in ipairs(AutoHotelKeyObtain:GetDescendants()) do
			if AutoHotelDesc:IsA("ProximityPrompt") then
				fireproximityprompt(AutoHotelDesc)
			end
		end

		task.wait(0.12)
	end
	return false
end

local function AutoHotelProcessRoom(AutoHotelRoomNum)
	if AutoHotelProcessedRooms[AutoHotelRoomNum] then
		return
	end
	task.wait(AutoHotelRoomProcessTime)
	AutoHotelProcessedRooms[AutoHotelRoomNum] = true
end

local function AutoHotelRunLibrary()
	local AutoHotelCurrentRooms = workspace:WaitForChild("CurrentRooms")
	local AutoHotelRoom50 = AutoHotelCurrentRooms:WaitForChild("50")
	local AutoHotelLiveHintBooks = {}
	local AutoHotelHintPaperObtained = false

	local function AutoHotelIsInRoom50(AutoHotelObj)
		return AutoHotelObj and AutoHotelObj:IsDescendantOf(AutoHotelRoom50)
	end

	local function AutoHotelIsActuallyInRoom50()
		return tonumber(LocalPlayer:GetAttribute("CurrentRoom")) == 50
	end

	while Toggles.AutoHotel.Value and not AutoHotelIsActuallyInRoom50() do
		task.wait(0.1)
	end
	if not Toggles.AutoHotel.Value then return end

	AutoHotelWaitForEntities(5)

	local function AutoHotelHasHintPaper()
		local AutoHotelChar = LocalPlayer.Character
		if not AutoHotelChar then return false end
		return LocalPlayer.Backpack:FindFirstChild("LibraryHintPaper", true) or AutoHotelChar:FindFirstChild("LibraryHintPaper", true)
	end

	local function AutoHotelGetCFrame(AutoHotelObj)
		if not AutoHotelIsActuallyInRoom50() or not AutoHotelIsInRoom50(AutoHotelObj) then return nil end
		if AutoHotelObj:IsA("Model") then return AutoHotelObj:GetPivot() end
		if AutoHotelObj:IsA("BasePart") then return AutoHotelObj.CFrame end
		local AutoHotelPart = AutoHotelObj:FindFirstChildWhichIsA("BasePart", true)
		return AutoHotelPart and AutoHotelPart.CFrame
	end

	local function AutoHotelCollectBooks()
		for _, AutoHotelDesc in ipairs(AutoHotelRoom50:GetDescendants()) do
			if AutoHotelDesc.Name == "LiveHintBook" and AutoHotelIsInRoom50(AutoHotelDesc) and not table.find(AutoHotelLiveHintBooks, AutoHotelDesc) then
				table.insert(AutoHotelLiveHintBooks, AutoHotelDesc)
			end
		end
	end

	AutoHotelCollectBooks()

	AutoHotelLibraryRoomConnection = AutoHotelRoom50.DescendantAdded:Connect(function(AutoHotelAdded)
		if Toggles.AutoHotel.Value and AutoHotelIsActuallyInRoom50() and AutoHotelIsInRoom50(AutoHotelAdded) then
			if AutoHotelAdded.Name == "LiveHintBook" and not table.find(AutoHotelLiveHintBooks, AutoHotelAdded) then
				table.insert(AutoHotelLiveHintBooks, AutoHotelAdded)
			end
		end
	end)

	while Toggles.AutoHotel.Value and AutoHotelIsActuallyInRoom50() and #AutoHotelLiveHintBooks < 3 do
		AutoHotelCollectBooks()
		if #AutoHotelLiveHintBooks >= 3 then break end
		task.wait(0.1)
	end

	while Toggles.AutoHotel.Value and AutoHotelIsActuallyInRoom50() and not AutoHotelHintPaperObtained do
		if AutoHotelHasHintPaper() then
			AutoHotelHintPaperObtained = true
			break
		end

		for AutoHotelIndex = #AutoHotelLiveHintBooks, 1, -1 do
			local AutoHotelBook = AutoHotelLiveHintBooks[AutoHotelIndex]
			if not AutoHotelIsInRoom50(AutoHotelBook) then
				table.remove(AutoHotelLiveHintBooks, AutoHotelIndex)
				continue
			end

			while Toggles.AutoHotel.Value and AutoHotelIsActuallyInRoom50() and not AutoHotelHintPaperObtained and AutoHotelBook.Parent and AutoHotelIsInRoom50(AutoHotelBook) do
				if AutoHotelHasHintPaper() then
					AutoHotelHintPaperObtained = true
					break
				end

				local AutoHotelChar = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
				local AutoHotelHRP = AutoHotelChar:FindFirstChild("HumanoidRootPart")
				if not AutoHotelHRP then
					task.wait()
					continue
				end

				local AutoHotelCF = AutoHotelGetCFrame(AutoHotelBook)
				if AutoHotelCF then
					AutoHotelHRP.CFrame = AutoHotelCF
				end

				for _, AutoHotelPrompt in ipairs(AutoHotelBook:GetDescendants()) do
					if AutoHotelPrompt:IsA("ProximityPrompt") then
						fireproximityprompt(AutoHotelPrompt)
					end
				end
				task.wait(0.08)
			end
			if AutoHotelHintPaperObtained then break end
		end

		if AutoHotelHasHintPaper() then
			AutoHotelHintPaperObtained = true
			break
		end

		local AutoHotelPaper = AutoHotelRoom50:FindFirstChild("LibraryHintPaper", true)
		if AutoHotelPaper and AutoHotelIsInRoom50(AutoHotelPaper) then
			while Toggles.AutoHotel.Value and AutoHotelIsActuallyInRoom50() and not AutoHotelHintPaperObtained and AutoHotelPaper.Parent do
				if AutoHotelHasHintPaper() then
					AutoHotelHintPaperObtained = true
					break
				end

				local AutoHotelChar = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
				local AutoHotelHRP = AutoHotelChar:FindFirstChild("HumanoidRootPart")
				if AutoHotelHRP then
					local AutoHotelCF = AutoHotelGetCFrame(AutoHotelPaper)
					if AutoHotelCF then
						AutoHotelHRP.CFrame = AutoHotelCF * CFrame.new(0, 5, 0)
					end
				end

				for _, AutoHotelPrompt in ipairs(AutoHotelPaper:GetDescendants()) do
					if AutoHotelPrompt:IsA("ProximityPrompt") then
						fireproximityprompt(AutoHotelPrompt)
					end
				end
				task.wait(0.08)
			end
		end
		task.wait(0.1)
	end
end

local function AutoHotelHandleSeek()
	local AutoHotelLastTriggerRoom = nil

	while Toggles.AutoHotel.Value do
		local AutoHotelCurrentRooms = workspace:FindFirstChild("CurrentRooms")
		if not AutoHotelCurrentRooms then
			task.wait(0.2)
			continue
		end

		local TriggerRoomNum = nil

		for _, Room in ipairs(AutoHotelCurrentRooms:GetChildren()) do
			local Num = tonumber(Room.Name)
			if Num and Num ~= AutoHotelLastTriggerRoom then
				local Trigger = Room:FindFirstChild("TriggerEventCollision")
					or Room:FindFirstChild("TriggerEventCollision", true)

				if Trigger then
					TriggerRoomNum = Num
					break
				end
			end
		end

		if not TriggerRoomNum then
			task.wait(0.15)
			continue
		end

		AutoHotelLastTriggerRoom = TriggerRoomNum

		AutoHotelEntityPause = true
		AutoHotelWaitForEntities(10)
		AutoHotelEntityPause = false
	end
end

Toggles.AutoHotel:OnChanged(function(AutoHotelEnabled)
	if AutoHotelConnection then
		task.cancel(AutoHotelConnection)
		AutoHotelConnection = nil
	end
	if AutoHotelLibraryConnection then
		task.cancel(AutoHotelLibraryConnection)
		AutoHotelLibraryConnection = nil
	end
	if AutoHotelLibraryRoomConnection then
		AutoHotelLibraryRoomConnection:Disconnect()
		AutoHotelLibraryRoomConnection = nil
	end
	if AutoHotelSeekConnection then
		task.cancel(AutoHotelSeekConnection)
		AutoHotelSeekConnection = nil
	end

	AutoHotelEntityPause = false
	table.clear(AutoHotelProcessedRooms)

	if not AutoHotelEnabled then return end

	if Options.AutoHotelRoomProcess then
		AutoHotelRoomProcessTime = Options.AutoHotelRoomProcess.Value
		Options.AutoHotelRoomProcess:OnChanged(function(Value)
			AutoHotelRoomProcessTime = Value
		end)
	end

	local AutoHotelCurrentRooms = workspace:FindFirstChild("CurrentRooms")
	if AutoHotelCurrentRooms then
		AutoHotelCurrentRooms.ChildAdded:Connect(function(AutoHotelChild)
			local AutoHotelNum = tonumber(AutoHotelChild.Name)
			if AutoHotelNum then
				AutoHotelProcessRoom(AutoHotelNum)
			end
		end)
	end

	AutoHotelSeekConnection = task.spawn(AutoHotelHandleSeek)

	task.spawn(function()
		while Toggles.AutoHotel.Value do
			if AutoHotelIsEntityPresent() then
				AutoHotelEntityPause = true
				while AutoHotelIsEntityPresent() and Toggles.AutoHotel.Value do
					task.wait(0.15)
				end
				AutoHotelEntityPause = false
			end
			task.wait(0.2)
		end
	end)

	AutoHotelConnection = task.spawn(function()
		while Toggles.AutoHotel.Value do
			if AutoHotelEntityPause then
				task.wait(0.1)
				continue
			end

			local AutoHotelDoor, AutoHotelRoomNum = AutoHotelGetNextClosedDoor()

			if AutoHotelDoor and AutoHotelRoomNum and Character then
				if AutoHotelRoomNum == 50 then
					if not AutoHotelLibraryConnection then
						AutoHotelLibraryConnection = task.spawn(function()
							AutoHotelRunLibrary()
							AutoHotelLibraryConnection = nil
						end)
					end
					task.wait(0.4)
				else
					AutoHotelProcessRoom(AutoHotelRoomNum)
					AutoHotelHandleKey(AutoHotelRoomNum)
					if Character and not AutoHotelEntityPause then
						Character:PivotTo(AutoHotelDoor:GetPivot() * CFrame.new(0, -1, 0))
					end
				end
			end
			task.wait(0.15)
		end
	end)
end)


Groupboxes.Debug = Tabs.General:AddRightGroupbox("Debug")
Groupboxes.Debug:AddButton({
	Text = "Ladder Softlock Fix",
	Tooltip = "Ladder Softlock Fix.",
	Func = function()
   		LocalPlayer:SetAttribute("Climbing", false)
	end
})
Groupboxes.Debug:AddButton({
	Text = "Get Current Floor",
	Tooltip = "Prints the current floor to the console.",
	Func = function()
		print("Current Floor:", GameData:WaitForChild("Floor").Value)
	end
})
Groupboxes.Debug:AddButton({
	Text = "Get Current Room",
	Tooltip = "Prints the current room number to the console.",
	Func = function()
		print("Current Room:", LocalPlayer:GetAttribute("CurrentRoom"))
	end
})
Groupboxes.Debug:AddButton({
	Text = "Void",
	Tooltip = "Teleports your character to Y -120.",
	Func = function()
		if not Character then return end
		local Pivot = Character:GetPivot()
		-- Too lazy to loop this
		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
	end
})
Groupboxes.Debug:AddButton({
	Text = "Death",
	Tooltip = "Death",
	Func = function()
		Globals.Deathing = true
		LocalPlayer.Character.Humanoid.Health = 0
	end
})
Groupboxes.Debug:AddButton({
	Text = "Exit Closet",
	Tooltip = "Exits the current closet.",
	Func = function()
		if RemotesFolder and RemotesFolder:FindFirstChild("CamLock") then
			RemotesFolder.CamLock:FireServer()
		end
	end
})
local TpNextDoorConnection

local function getNextClosedDoor()
	if not Character then return nil end

	local GameData = game:GetService("ReplicatedStorage"):FindFirstChild("GameData")
	if not GameData then return nil end

	local LatestRoom = GameData:FindFirstChild("LatestRoom")
	if not LatestRoom then return nil end

	local startRoom = LatestRoom.Value
	local bestDoor = nil
	local bestNumber = math.huge

	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj.Name == "Door" and obj:IsA("Model") then
			local openAttr = obj:GetAttribute("Open")
			if openAttr == false or openAttr == nil then
				local roomModel = obj.Parent
				local roomNum = tonumber(roomModel and roomModel.Name)

				if roomNum and roomNum >= startRoom and roomNum < bestNumber then
					bestNumber = roomNum
					bestDoor = obj
				end
			end
		end
	end

	return bestDoor
end

Groupboxes.Debug:AddButton({
	Text = "Tp Next Door",
	Tooltip = "Teleports you to the next sequential unopened door.",
	Func = function()
		local door = getNextClosedDoor()
		if door then
			Character:PivotTo(door:GetPivot() * CFrame.new(0, -1, 0))
		end
	end
})

Toggles.TpNextDoor = Groupboxes.Debug:AddToggle("TpNextDoor", {
	Text = "Auto Tp Next Door",
	Tooltip = "Continuously teleports you to the next sequential unopened door.",
	Default = false
})

Toggles.TpNextDoor:OnChanged(function(TpNextDoorEnabled)
	if TpNextDoorConnection then
		task.cancel(TpNextDoorConnection)
		TpNextDoorConnection = nil
	end

	if not TpNextDoorEnabled then
		return
	end

	TpNextDoorConnection = task.spawn(function()
		while Toggles.TpNextDoor.Value do
			local door = getNextClosedDoor()
			if door and Character then
				Character:PivotTo(door:GetPivot() * CFrame.new(0, -1, 0))
			end
			task.wait(0.15)
		end
		TpNextDoorConnection = nil
	end)
end)


Groupboxes.Exploits_Bypass = Tabs.Exploits:AddLeftGroupbox("Bypass / Solve")

Groupboxes.Exploits_Bypass:AddToggle("BypassGiggle",         { Text = "Bypass Giggle",           Default = false, Tooltip = "Prevents 'Giggle' from attacking you." })
Groupboxes.Exploits_Bypass:AddToggle("BypassDupe",           { Text = "Bypass Dupe",             Default = false, Tooltip = "Prevents you from open 'Dupe' fake doors." })
Groupboxes.Exploits_Bypass:AddToggle("BypassEyes",           { Text = "Bypass Eyes",             Default = false, Tooltip = "Prevents 'Eyes' from hurting you." })
Groupboxes.Exploits_Bypass:AddToggle("BypassLookman",        { Text = "Bypass Lookman",          Default = false, Tooltip = "Prevents 'Lookman' from hurting you." })
Groupboxes.Exploits_Bypass:AddToggle("BypassGloombatEggs",   { Text = "Bypass Gloombat Eggs",    Default = false, Tooltip = "Prevents taking damage from stepping on 'Gloombat' eggs." })
Groupboxes.Exploits_Bypass:AddToggle("BypassSeekObstructions", { Text = "Bypass Seek Obstructions", Default = false, Tooltip = "Prevents obstacles in the 'Seek' chase from harming you." })
Groupboxes.Exploits_Bypass:AddToggle("BypassVacuum",         { Text = "Bypass Vacuum",           Default = false, Tooltip = "Prevents you from falling into 'Vacuum' fake doors." })
Groupboxes.Exploits_Bypass:AddToggle("BypassKillbricks",     { Text = "Bypass Killbricks",       Default = false, Tooltip = "Prevents 'Lava' from hurting you." })
Groupboxes.Exploits_Bypass:AddToggle("BypassSeekingWall",    { Text = "Bypass Seeking Wall",     Default = false, Tooltip = "Prevents 'ScaryWall' from hurting you." })
Groupboxes.Exploits_Bypass:AddToggle("BypassSnare",          { Text = "Bypass Snare",            Default = false, Tooltip = "Prevents 'Snare' from trapping you." })
Groupboxes.Exploits_Bypass:AddToggle("BypassBanana",         { Text = "Bypass Banana",           Default = false, Tooltip = "Prevents 'Banana Peel' from slipping you up (sometimes doesn't work)." })
Groupboxes.Exploits_Bypass:AddToggle("BypassJeff",           { Text = "Bypass Jeff",             Default = false, Tooltip = "Prevents 'Jeff the Killer' from stabbing you (sometimes doesn't work)." })


Toggles.BypassGiggle:OnChanged(function(Value)
	for _, Object in Objects.Entities do
		if Object.Name == "GiggleCeiling" then
			Object:WaitForChild("Hitbox").CanTouch = not Value
		end
	end
end)
Toggles.BypassDupe:OnChanged(function(Value)
	for _, Object in Objects.Entities do
		if Object.Name == "DoorFake" or Object.Name == "FakeDoor" then
			Object:WaitForChild("Hidden").CanTouch = not Value
			if Object:FindFirstChild("Lock") then
				Object.Lock.UnlockPrompt.Enabled = not Value
			end
		end
	end
end)
Toggles.BypassEyes:OnChanged(function(Value)
	if Value and Globals.IsEyes then
		if Floor == "Fools" or Floor == "OldHotel" then
			RemotesFolder.MotorReplication:FireServer(0, (Globals.SpoofOffset == 200 and 65 or -65), 0, false)
		else
			RemotesFolder.MotorReplication:FireServer(-650)
		end
	end
end)
Toggles.BypassLookman:OnChanged(function(Value)
	if Value and Globals.IsLookman then
		if Floor == "Fools" or Floor == "OldHotel" then
			RemotesFolder.MotorReplication:FireServer(0, (Globals.SpoofOffset == 200 and 65 or -65), 0, false)
		else
			RemotesFolder.MotorReplication:FireServer(-650)
		end
	end
end)
Toggles.BypassGloombatEggs:OnChanged(function(Value)
	for _, Object in Objects.Entities do
		for _, Part in Object:GetDescendants() do
			if Part:IsA("BasePart") then
				Part.CanTouch = not Value
			end
		end
	end
end)
Toggles.BypassSeekObstructions:OnChanged(function(Value)
	for _, Object in Objects.SeekObstructions do
		Object.CanTouch = not Value
		if Object.Name == "SeekFloodline" then
			Object.CanCollide = Value
		end
	end
	for _, Object in Objects.SeekBridges do
		Object.CanCollide = Value
		Object.Transparency = Value and 0 or 1
	end
end)
Toggles.BypassVacuum:OnChanged(function(Value)
	for _, Object in Objects.Entities do
		if Object.Name == "SideroomSpace" then
			Object:WaitForChild("Collision").CanCollide = Value
			Object:WaitForChild("Collision").CanTouch = not Value
		end
	end
end)
Toggles.BypassKillbricks:OnChanged(function(Value)
	for _, Object in Objects.Obstructions do
		if Object.Name == "Lava" then Object.CanTouch = not Value end
	end
end)
Toggles.BypassSeekingWall:OnChanged(function(Value)
	for _, Object in Objects.Obstructions do
		if Object.Name == "ScaryWall" then
			for _, Part in Object:GetDescendants() do
				if Part:IsA("BasePart") then
					Part.CanTouch = not Value
					Part.CanCollide = not Value
				end
			end
		end
	end
end)
Toggles.BypassSnare:OnChanged(function(Value)
	for _, Object in Objects.Entities do
		if Object.Name == "Snare" then
			for _, Part in Object:GetDescendants() do
				if Part:IsA("BasePart") then Part.CanTouch = not Value end
			end
		end
	end
end)
Toggles.BypassBanana:OnChanged(function(Value)
	for _, Object in Objects.Entities do
		if Object.Name == "BananaPeel" then Object.CanTouch = not Value end
	end
end)
Toggles.BypassJeff:OnChanged(function(Value)
	for _, Object in Objects.Entities do
		if Object.Name == "JeffTheKiller" then
			for _, Part in Object:GetDescendants() do
				if Part:IsA("BasePart") then
					Part.CanCollide = not Value
					Part.CanTouch = not Value
				end
			end
			Object:WaitForChild("Humanoid").Health = 0
		end
	end
end)







-- Archives

Groupboxes.Archives_Misc = Tabs.Archives:AddRightGroupbox("Exploits / Anti")
Groupboxes.Archives_Misc:AddToggle("AntiRansom", { Text = "Anti Ransom", Default = false, Tooltip = "Prevents 'Ransom' from attacking you." })
Groupboxes.Archives_Misc:AddToggle("AntiClosetTrash", { Text = "Anti Closet Trash", Default = false, Tooltip = "Prevents 'Closet Trash' from spawning." })
Groupboxes.Archives_Misc:AddToggle("ForgetMeNotSolver", { Text = "Forget Me Not Skipper", Default = false, Tooltip = "Automatically Skippes Forget Me Not doors." })
Groupboxes.Archives_Misc:AddToggle("TimeShower", { Text = "Time Shower", Default = false, Tooltip = "Shows the Archives clock time." })
Groupboxes.Archives_Misc:AddToggle("BypassDronesStampede", { Text = "Stop Time/Anti Stampede", Default = false, Tooltip = "Prevents 'The Drones Stampede' from attacking you." })
Groupboxes.Archives_Misc:AddToggle("HonchoCorrectBoxESP", { Text = "Correct Box ESP/Auto Interact", Default = false, Tooltip = "ESP correct Archives boxes in the Honcho sequence and automatically interact with the correct deposit." })

Groupboxes.Archives_Misc:AddDivider()
Groupboxes.Archives_Misc:AddToggle("ArchivesChairACBypass", {
	Text = "Chair Anticheat Bypass",
	Default = false,
	Risky = true,
	Tooltip = "Office chair anticheat bypass (Ms fent). Stand near a chair, then Start Bypass.",
})
Groupboxes.Archives_Misc:AddSlider("ChairSpeed", {
	Text = "Chair Speed",
	Default = 50,
	Min = 1,
	Max = 100,
	Rounding = 0,
	Tooltip = "Movement speed while chair anticheat bypass is active.",
})
Groupboxes.Archives_Misc:AddButton({
	Text = "Start Bypass",
	Tooltip = "Start chair anticheat bypass (stand near an office chair).",
	Func = function()
		if Functions.ArchivesChairAC_Start then
			Functions.ArchivesChairAC_Start()
		else
			warn("[Ms fent] Chair AC not ready yet")
		end
	end,
})
Groupboxes.Archives_Misc:AddButton({
	Text = "Stop Bypass",
	Tooltip = "Stop chair anticheat bypass and restore chair.",
	Func = function()
		if Functions.ArchivesChairAC_Stop then
			Functions.ArchivesChairAC_Stop()
		end
	end,
})


TimeShowerLabel = Instance.new("TextLabel")
TimeShowerLabel.Name = "TimeShower"
TimeShowerLabel.AnchorPoint = Vector2.new(0, 1)
TimeShowerLabel.Position = UDim2.new(0, 12, 1, -12)
TimeShowerLabel.Size = UDim2.new(0, 180, 0, 32)
TimeShowerLabel.BackgroundTransparency = 1
TimeShowerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TimeShowerLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
TimeShowerLabel.TextStrokeTransparency = 0.35
TimeShowerLabel.Font = Enum.Font.GothamBold
TimeShowerLabel.TextSize = 18
TimeShowerLabel.TextXAlignment = Enum.TextXAlignment.Left
TimeShowerLabel.Text = "Time: --:--"
TimeShowerLabel.Visible = false
TimeShowerLabel.Parent = Container



local function GetArchivesClockLabel(Room)
	local Assets = Room and Room:FindFirstChild("Assets", true)
	local Clock = Assets and Assets:FindFirstChild("ArchivesClock", true)
	local Time = Clock and Clock:FindFirstChild("Time", true)
	local TextLabel = Time and Time:FindFirstChild("TextLabel")
	return (TextLabel and TextLabel:IsA("TextLabel")) and TextLabel or nil
end

local function ResolveClockLabel()
	if TimeShowerSourceLabel and TimeShowerSourceLabel.Parent and TimeShowerSourceLabel:IsDescendantOf(game) then
		return TimeShowerSourceLabel
	end
	local currentRooms = workspace:FindFirstChild("CurrentRooms")
	if not currentRooms then return nil end
	local rooms = {}
	for _, room in ipairs(currentRooms:GetChildren()) do
		local num = tonumber(room.Name)
		if num then
			rooms[#rooms + 1] = { room = room, num = num }
		end
	end
	table.sort(rooms, function(a, b) return a.num > b.num end)
	for i = 1, math.min(6, #rooms) do
		local label = GetArchivesClockLabel(rooms[i].room)
		if label then
			TimeShowerSourceLabel = label
			return label
		end
	end
	return nil
end

local function ResolveClockRemote()
	local label = ResolveClockLabel()
	if not label then return nil end
	local clock = label:FindFirstAncestor("ArchivesClock")
	if not clock then return nil end
	local remote = clock:FindFirstChild("LookedAtRemote", true)
	return (remote and remote:IsA("RemoteEvent")) and remote or nil
end

task.spawn(function()
	local lastCheckedRoomCount = 0
	while game:IsLoaded() do
		local currentRooms = workspace:FindFirstChild("CurrentRooms")
		if currentRooms then
			local roomCount = 0
			for _, child in ipairs(currentRooms:GetChildren()) do
				if tonumber(child.Name) then
					roomCount += 1
				end
			end
			if roomCount > 0 and (lastCheckedRoomCount == 0 or roomCount - lastCheckedRoomCount >= 10) then
				ResolveClockLabel()
				lastCheckedRoomCount = roomCount
			end
		end
		task.wait(0.5)
	end
end)

local function StopTimeShower()
	TimeShowerToken += 1
	if TimeShowerConnection then
		TimeShowerConnection:Disconnect()
		TimeShowerConnection = nil
	end
	if TimeShowerLabel then
		TimeShowerLabel.Visible = false
		TimeShowerLabel.Text = "Time: --:--"
	end
end

Toggles.TimeShower:OnChanged(function(Value)
	StopTimeShower()
	if not Value then return end
	local Token = TimeShowerToken
	TimeShowerLabel.Visible = true
	TimeShowerConnection = Services.RunService.Heartbeat:Connect(function()
		if Token ~= TimeShowerToken then return end
		local TextLabel = ResolveClockLabel()
		TimeShowerLabel.Text = TextLabel and ("Time: " .. TextLabel.Text) or "Time: --:--"
	end)
end)

Toggles.BypassDronesStampede:OnChanged(function(enabled)
	if BypassDronesStampedeConnection then
		task.cancel(BypassDronesStampedeConnection)
		BypassDronesStampedeConnection = nil
	end
	if not enabled then return end
	BypassDronesStampedeConnection = task.spawn(function()
		while Toggles.BypassDronesStampede.Value do
			local remote = ResolveClockRemote()
			if remote then
				remote:FireServer()
				task.wait(0.5)
			else
				task.wait(0.25)
			end
		end
	end)
end)

local function ClearHonchoESP()
	if HonchoCorrectBoxConnection then
		HonchoCorrectBoxConnection:Disconnect()
		HonchoCorrectBoxConnection = nil
	end
	if HonchoAutoDepositConnection then
		HonchoAutoDepositConnection:Disconnect()
		HonchoAutoDepositConnection = nil
	end
	for _, Object in pairs(HonchoESPObjects) do
		if Object and Object.Parent then
			Functions.RemoveESP(Object)
		end
	end
	table.clear(HonchoESPObjects)
	table.clear(HonchoProcessedRooms)
	table.clear(HonchoDepositCache)
end

Toggles.HonchoCorrectBoxESP:OnChanged(function(Value)
	ClearHonchoESP()
	if not Value then return end
	-- DontGroup
	local CurrentRooms = workspace:FindFirstChild("CurrentRooms")
	if not CurrentRooms then return end

	local function GetESPColor()
		return (Options.ObjectiveESPColor and Options.ObjectiveESPColor.Value) or Color3.fromRGB(0, 255, 0)
	end

	local function AddHonchoESP(Object, Text)
		Functions.AddESP({ Object = Object, Text = Text, Color = GetESPColor() }, true)
		HonchoESPObjects[#HonchoESPObjects + 1] = Object
		Object.Destroying:Once(function()
			Functions.RemoveESP(Object)
			local pos = table.find(HonchoESPObjects, Object)
			if pos then table.remove(HonchoESPObjects, pos) end
		end)
	end

	local function ProcessHonchoRoom(Room)
		if not tonumber(Room.Name) or not Room.Parent or HonchoProcessedRooms[Room] then return end
		HonchoProcessedRooms[Room] = true
		task.wait(3)
		if not Toggles.HonchoCorrectBoxESP.Value or not Room.Parent then
			HonchoProcessedRooms[Room] = nil
			return
		end
		local HonchoRoom = Room:FindFirstChild("ArchivesHonchoRoom", true)
		if not HonchoRoom then
			HonchoProcessedRooms[Room] = nil
			return
		end
		local BoxIDs = {}
		local RoomNumber = tonumber(Room.Name)
		for _, Desc in ipairs(Room:GetDescendants()) do
			local name = Desc.Name
			if name == "ArchivesPackageDeposit" or name:match("^ArchivesPackageDeposit") then
				local id = Desc:GetAttribute("BoxID")
				if id ~= nil then
					local idStr = tostring(id)
					BoxIDs[idStr] = true
					HonchoDepositCache[idStr] = Desc
					AddHonchoESP(Desc, "Deposit (" .. idStr .. ")")
					Desc.Destroying:Once(function()
						if HonchoDepositCache[idStr] == Desc then
							HonchoDepositCache[idStr] = nil
						end
					end)
				end
			end
		end
		if not next(BoxIDs) then
			HonchoProcessedRooms[Room] = nil
			return
		end
		for _, Child in ipairs(HonchoRoom:GetDescendants()) do
			if Child.Name == "ArchivesStorageBox" then
				local ToolBoxID = Child:GetAttribute("Tool_BoxID")
				if ToolBoxID ~= nil and BoxIDs[tostring(ToolBoxID)] then
					if not Child:GetAttribute("ParentRoom") then
						Child:SetAttribute("ParentRoom", RoomNumber)
					end
					Child.Name = "ArchivesStorageBoxCorrect"
					AddHonchoESP(Child, "Correct Box (" .. tostring(ToolBoxID) .. ")")
				end
			end
		end
	end

	for _, Room in ipairs(CurrentRooms:GetChildren()) do
		task.spawn(ProcessHonchoRoom, Room)
	end

	HonchoCorrectBoxConnection = CurrentRooms.ChildAdded:Connect(function(Room)
		task.spawn(ProcessHonchoRoom, Room)
	end)

	local lastCheck = 0
	HonchoAutoDepositConnection = game:GetService("RunService").Heartbeat:Connect(function()
		if not Toggles.HonchoCorrectBoxESP.Value then return end
		local now = os.clock()
		if now - lastCheck < 0.1 then return end
		lastCheck = now
		local Character = LocalPlayer and LocalPlayer.Character
		local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
		if not Character or not HumanoidRootPart then return end
		local BoxCandidates = {}
		for _, Object in ipairs(Character:GetChildren()) do
			if (Object:IsA("Tool") or Object:IsA("Model")) and (Object.Name == "ArchivesStorageBox" or Object.Name == "ArchivesStorageBoxCorrect") then
				BoxCandidates[#BoxCandidates + 1] = Object
			end
		end
		local Drops = workspace:FindFirstChild("Drops")
		if Drops then
			for _, Object in ipairs(Drops:GetChildren()) do
				if Object.Name == "ArchivesStorageBox" or Object.Name == "ArchivesStorageBoxCorrect" then
					BoxCandidates[#BoxCandidates + 1] = Object
				end
			end
		end
		for _, Box in ipairs(BoxCandidates) do
			if not (Box and Box.Parent) then continue end
			local BoxID = Box:GetAttribute("Tool_BoxID") or Box:GetAttribute("BoxID")
			if BoxID == nil then continue end
			local Deposit = HonchoDepositCache[tostring(BoxID)]
			if not Deposit or not Deposit.Parent then continue end
			if Box.Parent == Drops and not Box:GetAttribute("HonchoCorrectESP") then
				Box:SetAttribute("HonchoCorrectESP", true)
				AddHonchoESP(Box, "Correct Box (" .. tostring(BoxID) .. ")")
			end
			if Box.Parent == Character then
				local DepositPart = Deposit:IsA("BasePart") and Deposit or Deposit:FindFirstChildWhichIsA("BasePart", true)
				if DepositPart and (HumanoidRootPart.Position - DepositPart.Position).Magnitude <= 10 then
					local Prompt = Deposit:FindFirstChildWhichIsA("ProximityPrompt", true)
					if Prompt then
						fireproximityprompt(Prompt)
					end
				end
			end
		end
	end)
end)


Groupboxes.Archives_Bypasses = Tabs.Archives:AddLeftGroupbox("Bypasses")
Groupboxes.Archives_Bypasses:AddToggle("BypassWater", { Text = "Bypass Electric Water", Default = false, Tooltip = "Prevents electric water from hurting you." })
Groupboxes.Archives_Bypasses:AddToggle("BypassAlma", { Text = "Bypass Alma", Default = false, Tooltip = "Prevents 'Alma' from spawning." })
Groupboxes.Archives_Bypasses:AddToggle("BypassDrones", { Text = "Bypass Drones", Default = false, Tooltip = "Prevents 'Drones' from attacking you." })
Groupboxes.Archives_Bypasses:AddToggle("AntiScribbles", { Text = "Bypass Scribbles", Default = false, Tooltip = "Prevents 'Scribbles' from attacking you." })

Groupboxes.Archives_Experimental = Tabs.Archives:AddLeftGroupbox("Experimental")

Toggles.AntiClosetTrash:OnChanged(function(Value)
	if AntiClosetTrash_Connection then
		AntiClosetTrash_Connection:Disconnect()
		AntiClosetTrash_Connection = nil
	end
	if not Value then return end
	AntiClosetTrash_Connection = workspace.ChildAdded:Connect(function(Child)
		if not Toggles.AntiClosetTrash.Value then return end
		local Name = Child.Name
		if Name:sub(1, 6) == "Binder" or Name:sub(1, 4) == "Shoe" or Name:sub(1, 5) == "Shelf" then
			Child:Destroy()
		end
	end)
end)

Toggles.AntiRansom:OnChanged(function(Value)
	if AntiRansom_Connection then
		AntiRansom_Connection:Disconnect()
		AntiRansom_Connection = nil
	end
	if not Value then return end
	AntiRansom_Connection = workspace.ChildAdded:Connect(function(Child)
		if Child.Name == "Ransom" and Toggles.AntiRansom.Value then
			Child:Destroy()
			print("Ransom gone hehehehehehehehe")
		end
	end)
end)

Toggles.ForgetMeNotSolver:OnChanged(function(Value)
	if ForgetMeNotConnection then
		ForgetMeNotConnection:Disconnect()
		ForgetMeNotConnection = nil
	end
	ForgetMeNotRunning = false
	table.clear(ForgetMeNotProcessing)
	table.clear(ForgetMeNotNotified)
	if not Value then return end
	ForgetMeNotRunning = true

	local function GetCharacter()
		return game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
	end

	local function GetNextRoom(Number)
		while ForgetMeNotRunning do
			for RoomNumber = Number + 1, Number + 5 do
				local NextRoom = workspace.CurrentRooms:FindFirstChild(tostring(RoomNumber))
				if NextRoom then return NextRoom end
			end
			task.wait(0.1)
		end
		return nil
	end

	local function FireLookAts(Room)
		for i = 1, 6 do
			local Obj = Room:FindFirstChild(tostring(i))
			if Obj then
				local LookAt = Obj:FindFirstChild("LookAt")
				if LookAt then
					pcall(function() LookAt:FireServer() end)
				end
			end
		end
	end

	local function VoidCharacter()
		local Character = GetCharacter()
		if not Character then return end

		local voidCF = CFrame.new(0, -120, 0)
		local start = tick()
		while ForgetMeNotRunning and tick() - start < 2 do
			Character:PivotTo(voidCF)
			task.wait(0.1)
		end
	end

	local function Run(Room)
		local RoomNumber = tonumber(Room.Name)
		if not RoomNumber or not ForgetMeNotRunning or ForgetMeNotProcessing[RoomNumber] then return end

		if not Room:FindFirstChild("ForgetMeNotVineDoors", true) then
			return
		end

		ForgetMeNotProcessing[RoomNumber] = true

		while ForgetMeNotRunning and Room.Parent do
			FireLookAts(Room)

			local NextRoom = GetNextRoom(RoomNumber)
			if not NextRoom then
				task.wait(0.4)
				continue
			end

			local Door = NextRoom:FindFirstChild("Door")

			if not Door then
				local Character = GetCharacter()
				if Character then
					local Target = NextRoom:FindFirstChildWhichIsA("BasePart") or NextRoom
					if Target:IsA("BasePart") then
						Character:PivotTo(Target.CFrame + Vector3.new(0, 3, 0))
					elseif Target:IsA("Model") then
						Character:PivotTo(Target:GetPivot() + Vector3.new(0, 3, 0))
					else
						Character:PivotTo(CFrame.new(NextRoom:GetPivot().Position + Vector3.new(0, 5, 0)))
					end
				end
				break
			end

			if Door:GetAttribute("Opened") == true then
				VoidCharacter()
				break
			end

			local Hidden = Door:FindFirstChild("Hidden") or Door:WaitForChild("Hidden", 2)
			if not Hidden then
				task.wait(0.3)
				continue
			end

			while ForgetMeNotRunning and Room.Parent and NextRoom.Parent and Door.Parent and Door:GetAttribute("Opened") ~= true do
				local Character = GetCharacter()
				if Character then
					if Hidden:IsA("BasePart") then
						Character:PivotTo(Hidden.CFrame)
					elseif Hidden:IsA("Model") then
						Character:PivotTo(Hidden:GetPivot())
					end
				end
				pcall(function() Door.ClientOpen:Fire() end)
				pcall(function() Door.ClientOpen:FireServer() end)
				task.wait()
			end

			if ForgetMeNotRunning and Door.Parent and Door:GetAttribute("Opened") == true then
				VoidCharacter()
			end

			break
		end

		ForgetMeNotProcessing[RoomNumber] = nil
	end

	local function CheckRooms()
		local LatestRoomNumber = tonumber(LatestRoom.Value) or 0
		local FirstRoomNumber = math.max(0, LatestRoomNumber - 3)
		for RoomNumber = FirstRoomNumber, LatestRoomNumber do
			if not ForgetMeNotRunning then return end
			local Room = workspace.CurrentRooms:FindFirstChild(tostring(RoomNumber))
			if Room and not ForgetMeNotProcessing[RoomNumber] then
				task.spawn(Run, Room)
			end
		end
	end

	ForgetMeNotConnection = workspace.CurrentRooms.ChildAdded:Connect(function(Room)
		if not tonumber(Room.Name) then return end
		task.spawn(function()
			task.wait(1)
			if ForgetMeNotRunning and Room.Parent then
				task.spawn(Run, Room)
			end
		end)
	end)

	task.spawn(function()
		while ForgetMeNotRunning do
			CheckRooms()
			task.wait(1)
		end
	end)

	CheckRooms()
end)

Toggles.BypassWater:OnChanged(function(Value)
	Functions.Notify({ Title = "PositionSpoof Will Break This!." })

	if WaterBypassConnection then
		WaterBypassConnection:Disconnect()
		WaterBypassConnection = nil
	end

	if not Value then
		for _, WaterBypassPart in pairs(WaterParts) do
			if WaterBypassPart then
				WaterBypassPart:Destroy()
			end
		end
		table.clear(WaterParts)
		return
	end
	-- DontGroup
	local CurrentRooms = workspace.CurrentRooms

	local function ProcessWaterBypassRoom(WaterBypassRoom)
		if not tonumber(WaterBypassRoom.Name) then return end

		task.wait(3)

		local WaterBypassWater = WaterBypassRoom:FindFirstChild("Water")
		if not WaterBypassWater or WaterParts[WaterBypassWater] then return end

		local WaterBypassPart = Instance.new("Part")
		WaterBypassPart.Name = "WaterBypass"
		WaterBypassPart.Anchored = true
		WaterBypassPart.CanCollide = true
		WaterBypassPart.CanTouch = false
		WaterBypassPart.CanQuery = false
		WaterBypassPart.Transparency = 0.25
		WaterBypassPart.Color = Color3.fromRGB(0, 150, 255)
		WaterBypassPart.Material = Enum.Material.ForceField

		local WaterBypassSize, WaterBypassCFrame
		if WaterBypassWater:IsA("BasePart") then
			WaterBypassSize = WaterBypassWater.Size
			WaterBypassCFrame = WaterBypassWater.CFrame
		elseif WaterBypassWater:IsA("Model") then
			WaterBypassCFrame, WaterBypassSize = WaterBypassWater:GetBoundingBox()
		else
			WaterBypassSize = Vector3.new(10, 1.5, 10)
			WaterBypassCFrame = WaterBypassWater:GetPivot()
		end

		WaterBypassPart.Size = WaterBypassSize + Vector3.new(0, 0.5, 0)
		WaterBypassPart.CFrame = WaterBypassCFrame * CFrame.new(0, 0.25, 0)

		if WaterBypassPart.Size.Y > 3 then
			WaterBypassPart:Destroy()
			Functions.Notify({ Title = "Water Bypass removed: Softlock." })
			return
		end

		WaterBypassPart.Parent = WaterBypassRoom
		WaterParts[WaterBypassWater] = WaterBypassPart
	end

	local WaterBypassLatestRoomNumber = tonumber(LatestRoom.Value) or 0
	for WaterBypassRoomNumber = math.max(0, WaterBypassLatestRoomNumber - 4), WaterBypassLatestRoomNumber do
		local WaterBypassRoom = CurrentRooms:FindFirstChild(tostring(WaterBypassRoomNumber))
		if WaterBypassRoom then
			task.spawn(ProcessWaterBypassRoom, WaterBypassRoom)
		end
	end

	WaterBypassConnection = CurrentRooms.ChildAdded:Connect(function(WaterBypassRoom)
		task.spawn(ProcessWaterBypassRoom, WaterBypassRoom)
	end)
end)

Toggles.BypassAlma:OnChanged(function(Value)
	if AlmaConnection then
		AlmaConnection:Disconnect()
		AlmaConnection = nil
	end
	if Value then
		for _, child in ipairs(workspace:GetChildren()) do
			if child.Name == "Alma" then child:Destroy() end
		end
		AlmaConnection = workspace.ChildAdded:Connect(function(child)
			if child.Name == "Alma" then child:Destroy() end
		end)
	end
end)

Toggles.AntiScribbles:OnChanged(function(Value)
	if AntiScribbles_Connection then
		AntiScribbles_Connection:Disconnect()
		AntiScribbles_Connection = nil
	end
	if not Value then return end
	AntiScribbles_Connection = workspace.ChildAdded:Connect(function(Child)
		if Child.Name == "Scribbles" and Toggles.AntiScribbles.Value then
			local ExploitSribbleWarning = Child:FindFirstChild("IfYoureExploitingDeleteThis")
			if ExploitSribbleWarning then ExploitSribbleWarning:Destroy() end
		end
	end)
end)

Toggles.BypassDrones:OnChanged(function(Value)
	local RS = game:GetService("ReplicatedStorage")
	local function ProcessDrones(drones)
		local WalkedInto = drones:FindFirstChild("WalkedInto") or drones:WaitForChild("WalkedInto", 3)
		if WalkedInto and not DroneWalkedIntoParents[WalkedInto] then
			DroneWalkedIntoParents[WalkedInto] = drones
			WalkedInto.Parent = RS
		end
	end
	if Value then
		for _, child in ipairs(workspace:GetChildren()) do
			if child.Name == "Drones" then ProcessDrones(child) end
		end
		if DroneConnection then DroneConnection:Disconnect() end
		DroneConnection = workspace.ChildAdded:Connect(function(child)
			if child.Name == "Drones" then ProcessDrones(child) end
		end)
	else
		for WalkedInto, originalParent in pairs(DroneWalkedIntoParents) do
			if WalkedInto and WalkedInto.Parent and originalParent and originalParent.Parent then
				WalkedInto.Parent = originalParent
			end
		end
		table.clear(DroneWalkedIntoParents)
		if DroneConnection then
			DroneConnection:Disconnect()
			DroneConnection = nil
		end
	end
end)

Groupboxes.Stairwell_Misc = Tabs.Stairwell:AddLeftGroupbox("Exploits / Anti / Misc")



Groupboxes.Stairwell_Misc:AddDivider()
Groupboxes.Stairwell_Misc:AddToggle("BypassNoise", { Text = "Noise Tv Breaker", Default = false, Tooltip = "Breaks the tv of noise while holding it." })
Groupboxes.Stairwell_Misc:AddToggle("AntiNoise", { Text = "Anti Noise", Default = false, Tooltip = "Prevents the game from making noise when moving (Visual studio auto ai lmfao ✌)." })


Groupboxes.Stairwell_Misc:AddToggle("DroppedItemValue", { Text = "Item Number", Default = false, Tooltip = "Shows the number of dropped items." })

Groupboxes.Stairwell_Misc:AddToggle("KillAllWithCart", {
	Text = "Kill All (Requires ≥1 Cart)",
	Default = false,
})
Groupboxes.Stairwell_Misc:AddToggle("FlingCreak", {
	Text = "Bug Out Creak (Requires ≥5 Cart)",
	Default = false,
	ToolTip = "DONT TOUCH THE CARTS URSELF, U WILL DIE"
})
Groupboxes.Stairwell_Misc:AddToggle("CreakAggressionMeter", {
    Text = "Creak Aggression Meter",
    Default = false,
    Tooltip = "Shows Creak's aggression above its head."
})

local CreakAggressionMetersTable = {}
local CreakAggressionCamera = Workspace.CurrentCamera
local CreakAggressionChildAddedConnection = nil

local function CleanupCreakAggressionMeter(CreakModel)
    local CreakMeterData = CreakAggressionMetersTable[CreakModel]
    if not CreakMeterData then return end

    CreakAggressionMetersTable[CreakModel] = nil

    if CreakMeterData.RenderConnection then
        CreakMeterData.RenderConnection:Disconnect()
    end
    if CreakMeterData.DestroyConnection then
        CreakMeterData.DestroyConnection:Disconnect()
    end

    for _, CreakDrawingObject in ipairs(CreakMeterData.Drawings) do
        pcall(function() CreakDrawingObject:Remove() end)
    end
end

local function GetCreakAggressionValue(CreakModel)
    local CreakAnimator = CreakModel:FindFirstChildOfClass("Animator")
        or (CreakModel:FindFirstChild("AnimationController") and CreakModel.AnimationController:FindFirstChildOfClass("Animator"))
        or CreakModel:FindFirstChildOfClass("AnimationController")

    if not CreakAnimator then return nil end

    for _, CreakAnimationTrack in ipairs(CreakAnimator:GetPlayingAnimationTracks()) do
        if CreakAnimationTrack.Name == "CreakGraph" or (CreakAnimationTrack.Animation and CreakAnimationTrack.Animation.Name == "CreakGraph") then
            local CreakSuccess, CreakAggressionValue = pcall(CreakAnimationTrack.GetParameter, CreakAnimationTrack, "Aggression")
            if CreakSuccess and typeof(CreakAggressionValue) == "number" then
                return math.clamp(CreakAggressionValue, 0, 1)
            end
        end
    end
    return nil
end

local function CreateCreakAggressionDrawings()
    local CreakDrawingList = {}

    local function CreateCreakDrawing(CreakDrawingType)
        local CreakNewDrawing = Drawing.new(CreakDrawingType)
        table.insert(CreakDrawingList, CreakNewDrawing)
        return CreakNewDrawing
    end

    local CreakTitleText = CreateCreakDrawing("Text")
    CreakTitleText.Text = "Aggression --%"
    CreakTitleText.Size = 16
    CreakTitleText.Font = Drawing.Fonts.Plex
    CreakTitleText.Color = Color3.fromRGB(255, 255, 255)
    CreakTitleText.Center = true
    CreakTitleText.Outline = true
    CreakTitleText.Visible = false

    local CreakBarBackground = CreateCreakDrawing("Square")
    CreakBarBackground.Size = Vector2.new(112, 6)
    CreakBarBackground.Filled = true
    CreakBarBackground.Color = Color3.fromRGB(58, 58, 64)
    CreakBarBackground.Transparency = 0.15
    CreakBarBackground.Visible = false

    local CreakBarFill = CreateCreakDrawing("Square")
    CreakBarFill.Size = Vector2.new(0, 6)
    CreakBarFill.Filled = true
    CreakBarFill.Visible = false

    return {
        Drawings = CreakDrawingList,
        TitleText = CreakTitleText,
        BarBackground = CreakBarBackground,
        BarFill = CreakBarFill
    }
end

local function AddCreakAggressionMeter(CreakModel)
    if not Toggles.CreakAggressionMeter.Value or CreakModel.Name ~= "Creak" or CreakAggressionMetersTable[CreakModel] then
        return
    end

    local CreakHeadPart = CreakModel:FindFirstChild("Head")
    if not CreakHeadPart or not CreakHeadPart:IsA("BasePart") then return end

    local CreakMeterData = CreateCreakAggressionDrawings()
    CreakAggressionMetersTable[CreakModel] = CreakMeterData

    CreakMeterData.RenderConnection = RunService.RenderStepped:Connect(function()
        if not Toggles.CreakAggressionMeter.Value or not CreakModel.Parent or not CreakHeadPart.Parent then
            CleanupCreakAggressionMeter(CreakModel)
            return
        end

        if not CreakAggressionCamera or not CreakAggressionCamera.Parent then
            CreakAggressionCamera = Workspace.CurrentCamera
            if not CreakAggressionCamera then return end
        end

        local CreakScreenPosition, CreakIsOnScreen = CreakAggressionCamera:WorldToViewportPoint(CreakHeadPart.Position + Vector3.new(0, 1.85, 0))
        if not (CreakIsOnScreen and CreakScreenPosition.Z > 0) then
            CreakMeterData.TitleText.Visible = false
            CreakMeterData.BarBackground.Visible = false
            CreakMeterData.BarFill.Visible = false
            return
        end

        CreakMeterData.TitleText.Position = Vector2.new(CreakScreenPosition.X, CreakScreenPosition.Y - 28)
        CreakMeterData.BarBackground.Position = Vector2.new(CreakScreenPosition.X - 56, CreakScreenPosition.Y - 6)
        CreakMeterData.BarFill.Position = CreakMeterData.BarBackground.Position

        local CreakAggressionValue = GetCreakAggressionValue(CreakModel)

        if not CreakAggressionValue then
            CreakMeterData.TitleText.Text = "Aggression --%"
            CreakMeterData.TitleText.Color = Color3.fromRGB(200, 200, 200)
            CreakMeterData.BarFill.Size = Vector2.new(0, 6)
            CreakMeterData.TitleText.Visible = true
            CreakMeterData.BarBackground.Visible = true
            CreakMeterData.BarFill.Visible = false
            return
        end

        CreakMeterData.TitleText.Text = "Aggression " .. math.floor(CreakAggressionValue * 100 + 0.5) .. "%"
        CreakMeterData.TitleText.Color = Color3.fromRGB(255, 255, 255)
        CreakMeterData.BarFill.Size = Vector2.new(112 * CreakAggressionValue, 6)
        CreakMeterData.BarFill.Color = Color3.fromRGB(70, 220, 100):Lerp(Color3.fromRGB(255, 55, 55), CreakAggressionValue)
        CreakMeterData.TitleText.Visible = true
        CreakMeterData.BarBackground.Visible = true
        CreakMeterData.BarFill.Visible = true
    end)

    CreakMeterData.DestroyConnection = CreakModel.Destroying:Connect(function()
        CleanupCreakAggressionMeter(CreakModel)
    end)
end

local function StartCreakAggressionListener()
    if CreakAggressionChildAddedConnection then return end

    local CreakLiveEntitiesFolder = Workspace:FindFirstChild("LiveEntities")
    if not CreakLiveEntitiesFolder then return end

    CreakAggressionChildAddedConnection = CreakLiveEntitiesFolder.ChildAdded:Connect(function(CreakNewChild)
        if CreakNewChild.Name == "Creak" then
            AddCreakAggressionMeter(CreakNewChild)
        end
    end)
end

local function StopCreakAggressionListener()
    if CreakAggressionChildAddedConnection then
        CreakAggressionChildAddedConnection:Disconnect()
        CreakAggressionChildAddedConnection = nil
    end
end

Toggles.CreakAggressionMeter:OnChanged(function(CreakToggleEnabled)
    if CreakToggleEnabled then
        for _, CreakEntityModel in ipairs(Objects.Entities or {}) do
            AddCreakAggressionMeter(CreakEntityModel)
        end

        local CreakLiveEntitiesFolder = Workspace:FindFirstChild("LiveEntities")
        local CreakExistingModel = CreakLiveEntitiesFolder and CreakLiveEntitiesFolder:FindFirstChild("Creak")
        if CreakExistingModel then
            AddCreakAggressionMeter(CreakExistingModel)
        end

        StartCreakAggressionListener()
    else
        StopCreakAggressionListener()

        for CreakEntityModel in pairs(CreakAggressionMetersTable) do
            CleanupCreakAggressionMeter(CreakEntityModel)
        end
    end
end)

Toggles.KillAllWithCart:OnChanged(function(KillAllWithCartState)
	if not KillAllWithCartState then return end

	local KillAllWithCartIndex = 1

	task.spawn(function()
		while Toggles.KillAllWithCart.Value do
			local KillAllWithCartCarts = {}
			for _, KillAllWithCartModel in ipairs(workspace.Misc:GetChildren()) do
				if KillAllWithCartModel.Name == "ShoppingCart" and KillAllWithCartModel:IsA("Model") then
					KillAllWithCartCarts[#KillAllWithCartCarts + 1] = KillAllWithCartModel
				end
			end

			local KillAllWithCartAlivePlayers = {}
			for _, KillAllWithCartPlayer in ipairs(game.Players:GetPlayers()) do
				if KillAllWithCartPlayer ~= game.Players.LocalPlayer and KillAllWithCartPlayer.Character then
					local KillAllWithCartHumanoid = KillAllWithCartPlayer.Character:FindFirstChildOfClass("Humanoid")
					if KillAllWithCartHumanoid and KillAllWithCartHumanoid.Health > 0 then
						KillAllWithCartAlivePlayers[#KillAllWithCartAlivePlayers + 1] = KillAllWithCartPlayer
					end
				end
			end

			if #KillAllWithCartCarts > 0 and #KillAllWithCartAlivePlayers > 0 then
				if KillAllWithCartIndex > #KillAllWithCartAlivePlayers then
					KillAllWithCartIndex = 1
				end
				local KillAllWithCartTarget = KillAllWithCartAlivePlayers[KillAllWithCartIndex]
				local KillAllWithCartTargetCFrame = KillAllWithCartTarget.Character:GetPivot()
				for KillAllWithCartCartIndex = 1, #KillAllWithCartCarts do
					KillAllWithCartCarts[KillAllWithCartCartIndex]:PivotTo(KillAllWithCartTargetCFrame)
				end
				KillAllWithCartIndex = KillAllWithCartIndex + 1
			end
			task.wait(0)
		end
	end)
end)

Toggles.FlingCreak:OnChanged(function(FlingCreakState)
	if not FlingCreakState then return end

	task.spawn(function()
		while Toggles.FlingCreak.Value do
			local creak = workspace:FindFirstChild("LiveEntities") and workspace.LiveEntities:FindFirstChild("Creak")
			if creak then
				local targetCFrame = creak:GetPivot()
				for _, model in ipairs(workspace.Misc:GetChildren()) do
					if model.Name == "ShoppingCart" and model:IsA("Model") then
						model:PivotTo(targetCFrame)
					end
				end
			end
			task.wait(0.10)
		end
	end)
end)




Groupboxes.Stairwell_Misc:AddDivider()


Groupboxes.Stairwell_Misc:AddToggle("DisableStairwellCrusherCollision", {
	Text = "Disable Crushers",
	Default = false,
})
Groupboxes.Stairwell_Misc:AddToggle("DeleteStairwellCrusherExceptBasicWall", {
	Text = "Delete Crushers",
	Default = false,
})
Groupboxes.Stairwell_Misc:AddToggle("MeldRemover", {
	Text = "Remove Meld",
	Default = false,
})

Groupboxes.Stairwell_Misc:AddToggle("StairwellLandingSpam", {
	Text = "TP to trash and drop trash.",
	Tooltip = "Combine with orbit, or bring all dropped items.",
	Default = false,
})

Toggles.DisableStairwellCrusherCollision:OnChanged(function(DisableStairwellCrusherCollisionState)
	if not DisableStairwellCrusherCollisionState then return end

	task.spawn(function()
		while Toggles.DisableStairwellCrusherCollision.Value do
			for _, DisableStairwellCrusherRoom in ipairs(workspace.CurrentRooms:GetChildren()) do
				local DisableStairwellCrusherAssets = DisableStairwellCrusherRoom:FindFirstChild("Assets")
				if DisableStairwellCrusherAssets then
					for _, DisableStairwellCrusherContainer in ipairs(DisableStairwellCrusherAssets:GetChildren()) do
						if DisableStairwellCrusherContainer.Name == "StairwellCrusherContainer1" then
							for _, DisableStairwellCrusherDescendant in ipairs(DisableStairwellCrusherContainer:GetDescendants()) do
								if DisableStairwellCrusherDescendant:IsA("BasePart") and DisableStairwellCrusherDescendant.CanCollide then
									local DisableStairwellCrusherUnderBasicWall = false
									local DisableStairwellCrusherParent = DisableStairwellCrusherDescendant.Parent
									while DisableStairwellCrusherParent and DisableStairwellCrusherParent ~= DisableStairwellCrusherContainer do
										if DisableStairwellCrusherParent.Name == "BasicWall" then
											DisableStairwellCrusherUnderBasicWall = true
											break
										end
										DisableStairwellCrusherParent = DisableStairwellCrusherParent.Parent
									end
									if not DisableStairwellCrusherUnderBasicWall then
										DisableStairwellCrusherDescendant.CanCollide = false
									end
								end
							end
						end

						local DisableStairwellCrusher = DisableStairwellCrusherContainer:FindFirstChild("StairwellCrusher")
						if DisableStairwellCrusher then
							local DisableStairwellCrusherOuterTrigger = DisableStairwellCrusher:FindFirstChild("OuterTrigger")
							local DisableStairwellCrusherCoreTrigger = DisableStairwellCrusher:FindFirstChild("CoreTrigger")
							if DisableStairwellCrusherOuterTrigger then
								DisableStairwellCrusherOuterTrigger:Destroy()
							end
							if DisableStairwellCrusherCoreTrigger then
								DisableStairwellCrusherCoreTrigger:Destroy()
							end
						end
					end
				end
			end
			task.wait(0.5)
		end
	end)
end)
Toggles.DeleteStairwellCrusherExceptBasicWall:OnChanged(function(DeleteStairwellCrusherExceptBasicWallState)
	if not DeleteStairwellCrusherExceptBasicWallState then return end

	task.spawn(function()
		while Toggles.DeleteStairwellCrusherExceptBasicWall.Value do
			for _, DeleteStairwellCrusherRoom in ipairs(workspace.CurrentRooms:GetChildren()) do
				local DeleteStairwellCrusherAssets = DeleteStairwellCrusherRoom:FindFirstChild("Assets")
				if DeleteStairwellCrusherAssets then
					for _, DeleteStairwellCrusherContainer in ipairs(DeleteStairwellCrusherAssets:GetChildren()) do
						if DeleteStairwellCrusherContainer.Name == "StairwellCrusherContainer1" then
							local DeleteStairwellCrusherToDestroy = {}
							for _, DeleteStairwellCrusherDescendant in ipairs(DeleteStairwellCrusherContainer:GetDescendants()) do
								local DeleteStairwellCrusherUnderBasicWall = false
								local DeleteStairwellCrusherParent = DeleteStairwellCrusherDescendant.Parent
								while DeleteStairwellCrusherParent and DeleteStairwellCrusherParent ~= DeleteStairwellCrusherContainer do
									if DeleteStairwellCrusherParent.Name == "BasicWall" then
										DeleteStairwellCrusherUnderBasicWall = true
										break
									end
									DeleteStairwellCrusherParent = DeleteStairwellCrusherParent.Parent
								end
								if not DeleteStairwellCrusherUnderBasicWall and DeleteStairwellCrusherDescendant.Name ~= "BasicWall" then
									DeleteStairwellCrusherToDestroy[#DeleteStairwellCrusherToDestroy + 1] = DeleteStairwellCrusherDescendant
								end
							end
							for _, DeleteStairwellCrusherInstance in ipairs(DeleteStairwellCrusherToDestroy) do
								if DeleteStairwellCrusherInstance and DeleteStairwellCrusherInstance.Parent then
									DeleteStairwellCrusherInstance:Destroy()
								end
							end
						end
					end
				end
			end
			task.wait(0.5)
		end
	end)
end)

Toggles.MeldRemover:OnChanged(function(State)
	if not State then return end
	task.spawn(function()
		while Toggles.MeldRemover.Value do
			for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
				for _, folderName in ipairs({"Assets", "Parts"}) do
					local folder = room:FindFirstChild(folderName)
					if folder then
						for _, child in ipairs(folder:GetChildren()) do
							if child.Name == "MeldWall"
								or child.Name == "Boleahghth29tdgfhy2thuy2htuu259uhh3u" -- no qeustions asked
							then
								child:Destroy()
							end
						end
					end
				end
				for _, name in ipairs({"MeldData", "MeldPads", "Meldview", "Meld"}) do
					local obj = room:FindFirstChild(name)
					if obj and obj:IsA("Folder") then
						obj:Destroy()
					end
				end
			end
			task.wait(0.5)
		end
	end)
end)




local StairwellLandingToken = 0

Toggles.StairwellLandingSpam:OnChanged(function(Value)
	StairwellLandingToken += 1

	if not Value then
		return
	end

	local CurrentToken = StairwellLandingToken

	task.spawn(function()
		-- DontGroup
		local CurrentRooms = workspace.CurrentRooms
		local LocalPlayer = Services.Players.LocalPlayer

		while Toggles.StairwellLandingSpam.Value and CurrentToken == StairwellLandingToken do
			local StairwellModels = {}

			for _, Room in ipairs(CurrentRooms:GetChildren()) do
				local StairwellLandingLogic = Room:FindFirstChild("StairwellLandingLogic")

				if StairwellLandingLogic then
					for _, Model in ipairs(StairwellLandingLogic:GetChildren()) do
						if Model:IsA("Model") then
							local Prompts = {}

							for _, Object in ipairs(Model:GetDescendants()) do
								if Object:IsA("ProximityPrompt") then
									Prompts[#Prompts + 1] = Object
								end
							end

							if #Prompts > 0 then
								StairwellModels[#StairwellModels + 1] = {
									Model = Model,
									Prompts = Prompts,
								}
							end
						end
					end
				end
			end

			table.sort(StairwellModels, function(First, Second)
				local FirstRoom = First.Model.Parent and First.Model.Parent.Parent
				local SecondRoom = Second.Model.Parent and Second.Model.Parent.Parent

				return (tonumber(FirstRoom and FirstRoom.Name) or math.huge) <
					(tonumber(SecondRoom and SecondRoom.Name) or math.huge)
			end)

			for _, Data in ipairs(StairwellModels) do
				if not Toggles.StairwellLandingSpam.Value or CurrentToken ~= StairwellLandingToken then
					break
				end

				local Model = Data.Model

				while Model.Parent
					and Model:IsDescendantOf(workspace)
					and Toggles.StairwellLandingSpam.Value
					and CurrentToken == StairwellLandingToken do

					local Character = LocalPlayer.Character
					local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")

					if HumanoidRootPart then
						HumanoidRootPart.CFrame = Model:GetPivot() + Vector3.new(0, 5, 0)

						for Index = 1, #Data.Prompts do
							local Prompt = Data.Prompts[Index]

							if Prompt.Parent and Prompt.Enabled and fireproximityprompt then
								fireproximityprompt(Prompt)
							end
						end

						if keypress and keyrelease then
							keypress(0x58)
							task.wait(0.03)
							keyrelease(0x58)
						elseif Abysall
							and Abysall.Environment
							and Abysall.Environment.keypress
							and Abysall.Environment.keyrelease then

							Abysall.Environment.keypress(0x58)
							task.wait(0.03)
							Abysall.Environment.keyrelease(0x58)
						end
					end

					Services.RunService.Heartbeat:Wait()
				end
			end

			Services.RunService.Heartbeat:Wait()
		end
	end)
end)


Groupboxes.Stairwell_Misc:AddDivider()

Groupboxes.Stairwell_Misc:AddButton("TP Shopping Carts To Player", function()
	local ShoppingCartTargetName = Options.ShoppingCartTarget.Value
	local ShoppingCartTargetPlayer = game.Players:FindFirstChild(ShoppingCartTargetName)
	if not ShoppingCartTargetPlayer or not ShoppingCartTargetPlayer.Character then return end
	local ShoppingCartTargetCFrame = ShoppingCartTargetPlayer.Character:GetPivot()
	for _, ShoppingCartModel in ipairs(workspace.Misc:GetChildren()) do
		if ShoppingCartModel.Name == "ShoppingCart" and ShoppingCartModel:IsA("Model") then
			ShoppingCartModel:PivotTo(ShoppingCartTargetCFrame)
		end
	end
end)

Groupboxes.Stairwell_Misc:AddDropdown("ShoppingCartTarget", {
	Text = "Shopping Cart Target",
	Values = (function()
		local ShoppingCartPlayerNames = {}
		for _, ShoppingCartPlayer in ipairs(game.Players:GetPlayers()) do
			ShoppingCartPlayerNames[#ShoppingCartPlayerNames + 1] = ShoppingCartPlayer.Name
		end
		return ShoppingCartPlayerNames
	end)(),
	Default = game.Players.LocalPlayer.Name,
})

Groupboxes.Stairwell_Misc:AddButton("Refresh Players", function()
	local ShoppingCartPlayerNames = {}
	for _, ShoppingCartPlayer in ipairs(game.Players:GetPlayers()) do
		ShoppingCartPlayerNames[#ShoppingCartPlayerNames + 1] = ShoppingCartPlayer.Name
	end
	Options.ShoppingCartTarget:SetValues(ShoppingCartPlayerNames)
end)

Groupboxes.Stairwell_Experimental = Tabs.Stairwell:AddRightGroupbox("Experimental")


local function TPDropsToNearestGrinder()
    local TPDropsToNearestGrinderDropsFolder =
        workspace:FindFirstChild("Drops")

    local TPDropsToNearestGrinderRootPart =
        Character and Character:FindFirstChild("HumanoidRootPart")

    if not TPDropsToNearestGrinderDropsFolder
        or not TPDropsToNearestGrinderRootPart
        or not CurrentRooms then
        return
    end

    local TPDropsToNearestGrinderPlayerPosition =
        TPDropsToNearestGrinderRootPart.Position

    local TPDropsToNearestGrinderNearestGrinder = nil
    local TPDropsToNearestGrinderNearestDistance = math.huge

    for _, TPDropsToNearestGrinderRoom in
        ipairs(CurrentRooms:GetChildren()) do

        local TPDropsToNearestGrinderScrapper =
            TPDropsToNearestGrinderRoom:FindFirstChild(
                "StairwellScrapper",
                true
            )

        if TPDropsToNearestGrinderScrapper then
            for _, TPDropsToNearestGrinderObject in
                ipairs(TPDropsToNearestGrinderScrapper:GetDescendants()) do

                if TPDropsToNearestGrinderObject.Name == "Grinder1"
                    and (
                        TPDropsToNearestGrinderObject:IsA("Model")
                        or TPDropsToNearestGrinderObject:IsA("BasePart")
                    ) then

                    local TPDropsToNearestGrinderPosition =
                        TPDropsToNearestGrinderObject:GetPivot().Position

                    local TPDropsToNearestGrinderDistance =
                        (
                            TPDropsToNearestGrinderPlayerPosition
                            - TPDropsToNearestGrinderPosition
                        ).Magnitude

                    if TPDropsToNearestGrinderDistance
                        < TPDropsToNearestGrinderNearestDistance then

                        TPDropsToNearestGrinderNearestDistance =
                            TPDropsToNearestGrinderDistance

                        TPDropsToNearestGrinderNearestGrinder =
                            TPDropsToNearestGrinderObject
                    end
                end
            end
        end
    end

    if not TPDropsToNearestGrinderNearestGrinder then
        return
    end

    local TPDropsToNearestGrinderCFrame =
        TPDropsToNearestGrinderNearestGrinder:GetPivot()

    for _, TPDropsToNearestGrinderDropItem in
        ipairs(TPDropsToNearestGrinderDropsFolder:GetChildren()) do

        if TPDropsToNearestGrinderDropItem:IsA("Model")
            or TPDropsToNearestGrinderDropItem:IsA("BasePart") then

            TPDropsToNearestGrinderDropItem:PivotTo(
                TPDropsToNearestGrinderCFrame
            )
        end
    end
end

Groupboxes.Stairwell_Experimental:AddButton({
    Text = "TP All Drops to Nearest Grinder",
    Func = TPDropsToNearestGrinder,
    DoubleClick = false,
    Tooltip = "Teleports every dropped item to the grinder closest to you",
})

local function BringDroppedItems()
	local workspaceDropsFolder = workspace:FindFirstChild("Drops")
	if LocalPlayer and LocalPlayer.Character then
		local playerHumanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if playerHumanoidRootPart and workspaceDropsFolder then
			for _, itemToBring in ipairs(workspaceDropsFolder:GetChildren()) do
				if itemToBring:IsA("Model") then
					itemToBring:PivotTo(playerHumanoidRootPart.CFrame)
				elseif itemToBring:IsA("BasePart") then
					itemToBring.CFrame = playerHumanoidRootPart.CFrame
				end
			end
		end
	end
end

Groupboxes.Stairwell_Experimental:AddButton({
	Text = "Bring Dropped Items",
	Func = function() BringDroppedItems() end,
	DoubleClick = false,
	Tooltip = "Brings all dropped items."
})

Groupboxes.Stairwell_Experimental:AddToggle("EnableDroppedItemsInterval", {
	Text = "Enable Interval",
	Default = false,
	Tooltip = "Automatically brings dropped items at the selected interval."
})

Groupboxes.Stairwell_Experimental:AddSlider("DroppedItemsInterval", {
	Text = "Interval",
	Default = 1,
	Min = 0,
	Max = 60,
	Rounding = 1,
	Compact = false,
	Tooltip = "How often dropped items are brought."
})

Toggles.EnableDroppedItemsInterval:OnChanged(function(enabled)
	if enabled then
		if droppedItemsIntervalRunning then return end
		droppedItemsIntervalRunning = true
		task.spawn(function()
			while Toggles.EnableDroppedItemsInterval.Value do
				BringDroppedItems()
				local interval = Options.DroppedItemsInterval.Value
				if interval <= 0 then
					task.wait()
				else
					task.wait(interval)
				end
			end
			droppedItemsIntervalRunning = false
		end)
	end
end)

Groupboxes.Stairwell_Experimental:AddDivider()

Groupboxes.Stairwell_Experimental:AddToggle("OrbitDroppedItems", {
	Text = "Orbit Dropped Items",
	Default = false,
	Tooltip = "Orbits dropped items around you. Teleports them to you every 10s to prevent despawn."
})

Groupboxes.Stairwell_Experimental:AddSlider("OrbitDroppedItemsHeight", {
	Text = "Height",
	Default = 2,
	Min = -20,
	Max = 20,
	Rounding = 1,
	Compact = false,
	Tooltip = "The height of the orbit."
})

Groupboxes.Stairwell_Experimental:AddSlider("OrbitDroppedItemsDistance", {
	Text = "Distance",
	Default = 5,
	Min = 0,
	Max = 50,
	Rounding = 1,
	Compact = false,
	Tooltip = "The distance of the orbit."
})

Groupboxes.Stairwell_Experimental:AddSlider("OrbitDroppedItemsSpeed", {
	Text = "Speed",
	Default = 2,
	Min = 0,
	Max = 20,
	Rounding = 1,
	Compact = false,
	Tooltip = "The speed of the orbit."
})

Toggles.OrbitDroppedItems:OnChanged(function(OrbitDroppedItemsEnabled)
	if OrbitDroppedItemsConnection then
		OrbitDroppedItemsConnection:Disconnect()
		OrbitDroppedItemsConnection = nil
	end
	if not OrbitDroppedItemsEnabled then return end
	OrbitDroppedItemsAngle = 0
	OrbitDroppedItemsLastTeleport = tick()
	OrbitDroppedItemsPauseUntil = 0
	OrbitDroppedItemsConnection = RunService.Heartbeat:Connect(function(OrbitDroppedItemsDeltaTime)
		if not LocalPlayer or not LocalPlayer.Character then return end
		local OrbitDroppedItemsHumanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		local OrbitDroppedItemsDropsFolder = workspace:FindFirstChild("Drops")
		if not OrbitDroppedItemsHumanoidRootPart or not OrbitDroppedItemsDropsFolder then return end
		local OrbitDroppedItemsHeightValue = Options.OrbitDroppedItemsHeight.Value
		local OrbitDroppedItemsDistanceValue = Options.OrbitDroppedItemsDistance.Value
		local OrbitDroppedItemsSpeedValue = Options.OrbitDroppedItemsSpeed.Value
		local OrbitDroppedItemsCurrentTime = tick()
		local OrbitDroppedItemsList = {}
		for _, OrbitDroppedItemsObject in ipairs(OrbitDroppedItemsDropsFolder:GetChildren()) do
			if OrbitDroppedItemsObject:IsA("Model") or OrbitDroppedItemsObject:IsA("BasePart") then
				OrbitDroppedItemsList[#OrbitDroppedItemsList + 1] = OrbitDroppedItemsObject
			end
		end
		local OrbitDroppedItemsCount = #OrbitDroppedItemsList
		if OrbitDroppedItemsCount == 0 then return end
		if OrbitDroppedItemsCurrentTime - OrbitDroppedItemsLastTeleport >= 10 then
			OrbitDroppedItemsLastTeleport = OrbitDroppedItemsCurrentTime
			OrbitDroppedItemsPauseUntil = OrbitDroppedItemsCurrentTime + 2
			local OrbitDroppedItemsCenterPosition = OrbitDroppedItemsHumanoidRootPart.Position
			for _, OrbitDroppedItemsObject in ipairs(OrbitDroppedItemsList) do
				if OrbitDroppedItemsObject:IsA("Model") then
					OrbitDroppedItemsObject:PivotTo(CFrame.new(OrbitDroppedItemsCenterPosition))
				else
					OrbitDroppedItemsObject.CFrame = CFrame.new(OrbitDroppedItemsCenterPosition)
				end
			end
		end
		if OrbitDroppedItemsCurrentTime < OrbitDroppedItemsPauseUntil then return end
		OrbitDroppedItemsAngle += OrbitDroppedItemsDeltaTime * OrbitDroppedItemsSpeedValue
		for OrbitDroppedItemsIndex, OrbitDroppedItemsObject in ipairs(OrbitDroppedItemsList) do
			local OrbitDroppedItemsObjectAngle = OrbitDroppedItemsAngle + ((OrbitDroppedItemsIndex - 1) / OrbitDroppedItemsCount) * math.pi * 2
			local OrbitDroppedItemsOffset = Vector3.new(
				math.cos(OrbitDroppedItemsObjectAngle) * OrbitDroppedItemsDistanceValue,
				OrbitDroppedItemsHeightValue,
				math.sin(OrbitDroppedItemsObjectAngle) * OrbitDroppedItemsDistanceValue
			)
			local OrbitDroppedItemsPosition = OrbitDroppedItemsHumanoidRootPart.Position + OrbitDroppedItemsOffset
			if OrbitDroppedItemsObject:IsA("Model") then
				OrbitDroppedItemsObject:PivotTo(CFrame.new(OrbitDroppedItemsPosition))
			else
				OrbitDroppedItemsObject.CFrame = CFrame.new(OrbitDroppedItemsPosition)
			end
		end
	end)
end)

Toggles.AntiNoise:OnChanged(function(value)
	for i = #Connections, 1, -1 do
		local conn = Connections[i]
		if conn and conn.Disconnect then
			conn:Disconnect()
		end
		table.remove(Connections, i)
	end
	if not value then return end
	local antiNoiseConn = RunService.PreSimulation:Connect(function(dt)
		if not value then return end
		if not LocalPlayer:GetAttribute("Alive") then return end
		local character = LocalPlayer.Character
		if not character then return end
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local camera = workspace.CurrentCamera
		if not rootPart or not humanoid or not camera then return end
		if humanoid.Health <= 0 then return end
		if rootPart.Anchored then return end
		local state = humanoid:GetState()
		if state == Enum.HumanoidStateType.Dead
			or state == Enum.HumanoidStateType.Ragdoll
			or state == Enum.HumanoidStateType.Climbing
			or state == Enum.HumanoidStateType.Swimming then
			return
		end
		humanoid.AutoRotate = false
		humanoid:Move(Vector3.zero, false)
		local inputVector = Controls:GetMoveVector()
		local inputMagnitude = inputVector.Magnitude
		if inputMagnitude <= 0 then
			rootPart.AssemblyLinearVelocity = Vector3.zero
			return
		end
		local cameraCFrame = camera.CFrame
		local cameraForward = Vector3.new(cameraCFrame.LookVector.X, 0, cameraCFrame.LookVector.Z)
		local cameraRight = Vector3.new(cameraCFrame.RightVector.X, 0, cameraCFrame.RightVector.Z)
		if cameraForward.Magnitude < 0.001 or cameraRight.Magnitude < 0.001 then return end
		cameraForward = cameraForward.Unit
		cameraRight = cameraRight.Unit
		local worldDirection = (cameraRight * inputVector.X) + (cameraForward * -inputVector.Z)
		if worldDirection.Magnitude <= 0 then return end
		worldDirection = worldDirection.Unit
		local finalSpeed = humanoid.WalkSpeed * math.clamp(inputMagnitude, 0, 1)
		local clampedDt = math.clamp(dt, 0, 1 / 30)
		rootPart.AssemblyLinearVelocity = Vector3.zero
		rootPart.CFrame = rootPart.CFrame + (worldDirection * finalSpeed * clampedDt)
		rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + worldDirection)
	end)
	Connections[#Connections + 1] = antiNoiseConn
end)

Toggles.BypassNoise:OnChanged(function(value)
	for i = #Connections, 1, -1 do
		local existingConnection = Connections[i]
		if existingConnection and existingConnection.Disconnect then
			existingConnection:Disconnect()
		end
		table.remove(Connections, i)
	end

	if not value then return end

	local function checkBypassNoiseTvStand(targetTvStand)
		if not targetTvStand:IsA("Model") then return end
		if targetTvStand.Name ~= "TV_Stand" then return end

		local tvStandCurrentCFrame = targetTvStand:GetPivot()

		if tvStandCurrentCFrame.Position.Y > -119 then
			targetTvStand:PivotTo(CFrame.new(
				tvStandCurrentCFrame.Position.X,
				-120,
				tvStandCurrentCFrame.Position.Z
			))
		end
	end

	local bypassNoiseMiscFolder = workspace:FindFirstChild("Misc")
	if not bypassNoiseMiscFolder then return end

	local bypassNoiseMiscChildAddedConnection = bypassNoiseMiscFolder.ChildAdded:Connect(function(bypassNoiseNewChild)
		checkBypassNoiseTvStand(bypassNoiseNewChild)
	end)

	Connections[#Connections + 1] = bypassNoiseMiscChildAddedConnection

	for _, bypassNoiseMiscChild in ipairs(bypassNoiseMiscFolder:GetChildren()) do
		checkBypassNoiseTvStand(bypassNoiseMiscChild)
	end
end)

Toggles.DroppedItemValue:OnChanged(function(DroppedItemValue)
	local DroppedItemValueScreenGui = game:GetService("CoreGui"):FindFirstChild("DropsCoinCounter")
	if not DroppedItemValue then
		if DroppedItemValueScreenGui then DroppedItemValueScreenGui:Destroy() end
		return
	end
	local DroppedItemValueWorkspaceDrops = workspace:WaitForChild("Drops")
	if DroppedItemValueScreenGui then DroppedItemValueScreenGui:Destroy() end
	DroppedItemValueScreenGui = Instance.new("ScreenGui")
	DroppedItemValueScreenGui.Name = "DropsCoinCounter"
	DroppedItemValueScreenGui.ResetOnSpawn = false
	DroppedItemValueScreenGui.Parent = game:GetService("CoreGui")
	local DroppedItemValueCoinText = Instance.new("TextLabel")
	DroppedItemValueCoinText.Name = "CoinText"
	DroppedItemValueCoinText.AnchorPoint = Vector2.new(0.5, 0)
	DroppedItemValueCoinText.Position = UDim2.new(0.5, 0, 0.02, 0)
	DroppedItemValueCoinText.Size = UDim2.new(0, 250, 0, 40)
	DroppedItemValueCoinText.BackgroundTransparency = 1
	DroppedItemValueCoinText.Text = "Items: 0"
	DroppedItemValueCoinText.TextSize = 24
	DroppedItemValueCoinText.Font = Enum.Font.GothamBold
	DroppedItemValueCoinText.TextColor3 = Color3.fromRGB(255, 255, 255)
	DroppedItemValueCoinText.TextStrokeTransparency = 0.5
	DroppedItemValueCoinText.Parent = DroppedItemValueScreenGui
	local DroppedItemValueCountedDrops = {}
	task.spawn(function()
		while Toggles.DroppedItemValue.Value do
			for _, DroppedItemValueDrop in ipairs(DroppedItemValueWorkspaceDrops:GetChildren()) do
				if DroppedItemValueDrop:IsA("Model") and not DroppedItemValueCountedDrops[DroppedItemValueDrop] then
					DroppedItemValueDrop:SetAttribute("CoinsChecked", true)
					DroppedItemValueCountedDrops[DroppedItemValueDrop] = true
				end
			end
			for DroppedItemValueDrop in pairs(DroppedItemValueCountedDrops) do
				if not DroppedItemValueDrop.Parent or DroppedItemValueDrop.Parent ~= DroppedItemValueWorkspaceDrops then
					DroppedItemValueCountedDrops[DroppedItemValueDrop] = nil
				end
			end
			local DroppedItemValueTotalItems = 0
			for DroppedItemValueDrop in pairs(DroppedItemValueCountedDrops) do
				if DroppedItemValueDrop.Parent == DroppedItemValueWorkspaceDrops then
					DroppedItemValueTotalItems += 1
				end
			end
			DroppedItemValueCoinText.Text = "Items: " .. DroppedItemValueTotalItems
			task.wait(1)
		end
		if DroppedItemValueScreenGui and DroppedItemValueScreenGui.Parent then
			DroppedItemValueScreenGui:Destroy()
		end
	end)
end)

-- Halloween
Groupboxes.Halloween_Misc = Tabs.Halloween:AddLeftGroupbox("Exploits / Anti")
--[[
 Groupboxes.Halloween_Misc:AddButton({
	Text = "Candy Farm",
	Func = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/coolcookiebusiness/AbysallHubContinued/refs/heads/main/Games/Doors/verity's%20auto%20farm.txt")) end,
	DoubleClick = false,
	Tooltip = "By Indexell."
}) 
--]]
Groupboxes.Halloween_Misc:AddToggle("SkipCutsenesHalloween", {
	Text = "Skip Cutsenes", Default = false,
	Tooltip = "Skip cutsenes."
})
Groupboxes.Halloween_Misc:AddToggle("RemoveFogHalloween", {
    Text = "Remove Extra Fog",
    Default = false,
    Tooltip = "Removes The extra fog."
})
Groupboxes.Halloween_Misc:AddButton({
	Text = "Bring Dropped Candy",
	Func = function() BringDroppedItems() end,
	DoubleClick = false,
	Tooltip = "Brings all dropped Candy (use for the depot)."
})

Groupboxes.Halloween_Misc:AddToggle("EnableDroppedItemsIntervalHalloween", {
	Text = "Enable Interval",
	Default = false,
	Tooltip = "Automatically brings candy items at the selected interval."
})

Groupboxes.Halloween_Misc:AddSlider("DroppedItemsIntervalHalloween", {
	Text = "Interval",
	Default = 1,
	Min = 0,
	Max = 60,
	Rounding = 1,
	Compact = false,
	Tooltip = "How often dropped items are brought."
})

Toggles.EnableDroppedItemsIntervalHalloween:OnChanged(function(enabled)
	if enabled then
		if droppedItemsIntervalRunning then return end
		droppedItemsIntervalRunning = true
		task.spawn(function()
			while Toggles.EnableDroppedItemsIntervalHalloween.Value do
				BringDroppedItems()
				local interval = Options.DroppedItemsIntervalHalloween.Value
				if interval <= 0 then
					task.wait()
				else
					task.wait(interval)
				end
			end
			droppedItemsIntervalRunning = false
		end)
	end
end)

Toggles.SkipCutsenesHalloween:OnChanged(function(Value)
    if Value then
        task.spawn(function()
            local Event = game:GetService("ReplicatedStorage").FloorReplicated.ClientRemote.SkipCutscene.Remote

            while Toggles.SkipCutsenesHalloween.Value do
                Event:FireServer(1, true)
                Event:FireServer(2, true)


                task.wait(0.5)
            end
        end)
    end
end)
Toggles.RemoveFogHalloween:OnChanged(function(Value)
    if Value then
        task.spawn(function()
            while Toggles.RemoveFogHalloween.Value do
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v.Name == "FogScout" or v.Name == "FogHolder" then
                        v:Destroy()
                    end
                end

                task.wait(0.5)
            end
        end)
    end
end)
-- hi

Groupboxes.Exploits_BypassRight = Tabs.Exploits:AddRightGroupbox("Bypass")
Groupboxes.Exploits_BypassRight:AddToggle("DisableAnticheat", {
	Text = "Anticheat Bypass", Default = false,
	Tooltip = "Completely disables the anticheat, after interacting with a ladder."
})
Groupboxes.Exploits_BypassRight:AddToggle("VelocityManipulationToggle", {
	Text = "Velocity Manipulation", Default = false,
	Tooltip = "Moves your character forward slowly, mitigating the game's anti-noclip."
})
Toggles.DisableAnticheat:OnChanged(function(Value)
	if Globals.AnticheatDisabled == true and not Value then
		RemotesFolder.ClimbLadder:FireServer()
		Globals.AnticheatDisabled = false
	end
end)
Toggles.VelocityManipulationToggle:AddKeyPicker("VelocityManipulationKeybind", {
	Text = "Velocity Manipulation", Default = "V",
	Mode = Library.IsMobile and "Toggle" or "Hold", SyncToggleState = true
})
Groupboxes.Exploits_BypassRight:AddDropdown("VelocityManipulationMode", {
	Values = {"Velocity", "Pivot"}, Text = "Manipulation Method",
	Default = 1,
})

Groupboxes.Exploits_BypassRight:AddDivider()
Groupboxes.Exploits_BypassRight:AddToggle("InfiniteItemsToggle", {
	Text = "Infinite Items", Default = false,
	Tooltip = "Allows certain items to be used without draining their uses.",
	Disabled = not Functions.CheckCompatability({"fireproximityprompt"}),
	DisabledTooltip = Globals.IncompatibleMessage
})
Groupboxes.Exploits_BypassRight:AddDropdown("InfiniteItemsList", {
	Text = "Item List",
	Values = { "Lockpicks", "Skeleton Key", "Shears", "Multitool" },
	Multi = true, AllowNull = true,
	Disabled = not Functions.CheckCompatability({"fireproximityprompt"}),
	DisabledTooltip = Globals.IncompatibleMessage
})

Groupboxes.Exploits_BypassRight:AddToggle("InfCrucifix", {
	Text = "Infinite Crucifix",
	Default = false,
	Tooltip = "Risky! You can die or lose the Crucifix. Recommended to have low ping and stable fps.",
	Risky = Floor ~= "Ballz",
})


local InfCrucifixDropTable = {
	RushMoving   = 54,
	AmbushMoving = 67,
	A60          = 70,
	GlitchRush   = 120,
	GlitchAmbush = 155,
	A120         = 75,

}



Toggles.InfCrucifix:OnChanged(function(Value)
	print("i allive")
	local InfCrucifixRaycastParams = RaycastParams.new()
	InfCrucifixRaycastParams.FilterType = Enum.RaycastFilterType.Blacklist

	local InfCrucifixConnection
	InfCrucifixConnection = RunService.RenderStepped:Connect(function()
		if not Toggles.InfCrucifix.Value then
			if InfCrucifixConnection then
				InfCrucifixConnection:Disconnect()
			end
			return
		end

		local InfCrucifixCharacter = game.Players.LocalPlayer
		if not InfCrucifixCharacter then
			return
		end

		local InfCrucifixCollision = InfCrucifixCharacter:FindFirstChild("CollisionPart")
		if not InfCrucifixCollision then
			return
		end

		InfCrucifixRaycastParams.FilterDescendantsInstances = {InfCrucifixCharacter}

		for _, InfCrucifixEntity in ipairs(Workspace:GetChildren()) do
			local InfCrucifixMaxDistance = InfCrucifixDropTable[InfCrucifixEntity.Name]
			if not InfCrucifixMaxDistance or not InfCrucifixEntity.PrimaryPart then
				continue
			end

			InfCrucifixEntity.PrimaryPart.CanCollide = true
			InfCrucifixEntity.PrimaryPart.CanQuery = true

			local InfCrucifixOrigin = InfCrucifixCollision.Position
			local InfCrucifixDirection = InfCrucifixEntity.PrimaryPart.Position - InfCrucifixOrigin
			local InfCrucifixRayResult = Workspace:Raycast(InfCrucifixOrigin, InfCrucifixDirection, InfCrucifixRaycastParams)

			if not InfCrucifixRayResult or not InfCrucifixRayResult.Instance:IsDescendantOf(InfCrucifixEntity) then
				continue
			end

			local InfCrucifixDistance = (InfCrucifixCollision.Position - InfCrucifixEntity.PrimaryPart.Position).Magnitude
			if InfCrucifixDistance >= InfCrucifixMaxDistance then
				continue
			end

			local InfCrucifixTool = InfCrucifixCharacter:FindFirstChildOfClass("Tool")
			if not InfCrucifixTool or InfCrucifixTool.Name ~= "Crucifix" then
				continue
			end

			task.spawn(function()
				ReplicatedStorage.RemotesFolder.DropItem:FireServer(InfCrucifixTool)
				task.wait(0.54)
				print("hi")
				local InfCrucifixDrops = Workspace:FindFirstChild("Drops")
				if not InfCrucifixDrops then
					return
				end

				local InfCrucifixDropped = InfCrucifixDrops:FindFirstChild("Crucifix")
				if not InfCrucifixDropped then
					return
				end

				local InfCrucifixPrompt = InfCrucifixDropped:FindFirstChildOfClass("ProximityPrompt")
				if InfCrucifixPrompt then
					fireproximityprompt(InfCrucifixPrompt)
				end
			end)
			print ("hi")
			task.wait(0.6)
		end
	end)
end)


Groupboxes.Exploits_BypassRight:AddDivider()
Groupboxes.Exploits_BypassRight:AddToggle("PositionSpoof", {
	Text = "Position Spoof", Default = false,
	Tooltip = "Makes your character appear underground on the server, protecting you from rush-like entities."
})
Groupboxes.Exploits_BypassRight:AddToggle("CrouchSpoof", {
	Text = "Crouch Spoof", Default = false, Tooltip = "Makes the game think you are always crouching."
})
Toggles.PositionSpoof:OnChanged(function(Value)
	-- Glue fights Position Spoof
	if Value then
		if Toggles.GlueToGround and Toggles.GlueToGround.Value then
			GlueWasEnabledBeforePositionSpoof = true
			Toggles.GlueToGround:SetValue(false)
		else
			GlueWasEnabledBeforePositionSpoof = false
		end
	else
		if GlueWasEnabledBeforePositionSpoof and Toggles.GlueToGround then
			GlueWasEnabledBeforePositionSpoof = false
			Toggles.GlueToGround:SetValue(true)
		end
	end
	if Floor ~= "Fools" and Floor ~= "OldHotel" then
		if Value then
			if RootPart then RootPart.CFrame = RootPart.CFrame * CFrame.new(0, -2.346, 0) end
			if Humanoid then Humanoid.HipHeight = 0.05 end
			if RemotesFolder and RemotesFolder:FindFirstChild("Crouch") then
				RemotesFolder.Crouch:FireServer(true, true)
			end
		else
			if RootPart then RootPart.CFrame = RootPart.CFrame * CFrame.new(0, 2.346, 0) end
			if Humanoid then Humanoid.HipHeight = 2.396 end
		end
	end
end)
Toggles.PositionSpoof:AddKeyPicker("PositionSpoof", {
	Text = "Position Spoof", Default = "B", Mode = "Toggle", SyncToggleState = true
})
Toggles.CrouchSpoof:OnChanged(function(Value)
	if RemotesFolder:FindFirstChild("Crouch") then
		RemotesFolder.Crouch:FireServer(Value and true or Functions.IsCrouching(), true)
	end
end)

Groupboxes.Exploits_Remove = Tabs.Exploits:AddRightGroupbox("Remove")
Groupboxes.Exploits_Remove:AddToggle("RemoveScreech", { Text = "Remove Screech",  Default = false, Tooltip = "Prevents 'Screech' from spawning." })
Groupboxes.Exploits_Remove:AddToggle("RemoveHalt",    { Text = "Remove Halt",     Default = false, Tooltip = "Prevents 'Halt' from spawning." })
Groupboxes.Exploits_Remove:AddToggle("RemoveA90",     { Text = "Remove A-90",     Default = false, Tooltip = "Prevents 'A-90' from spawning." })
Groupboxes.Exploits_Remove:AddToggle("RemoveDread",   { Text = "Remove Dread",    Default = false, Tooltip = "Prevents 'Dread' from spawning." })
Groupboxes.Exploits_Remove:AddToggle("RemoveSurge", { Text = "Remove Surge", Default = false, Tooltip = "Prevents 'Surge' from spawning."})
Groupboxes.Exploits_Remove:AddDivider()
Groupboxes.Exploits_Remove:AddToggle("NoScreechDamage", { Text = "No Screech Damage", Default = false, Tooltip = "Prevents 'Screech' from hurting you." })
Groupboxes.Exploits_Remove:AddToggle("NoHaltDamage",    { Text = "No Halt Damage",    Default = false, Tooltip = "Prevents 'Halt' from hurting you." })
Groupboxes.Exploits_Remove:AddToggle("NoA90Damage",     { Text = "No A-90 Damage",    Default = false, Tooltip = "Prevents 'A-90' from hurting you." })
Groupboxes.Exploits_Remove:AddToggle("NoSurgeDamage",   { Text = "No Surge Damage",   Default = false, Tooltip = "Prevents 'Surge' from hurting you." })

Toggles.NoScreechDamage:OnChanged(function(Value)
	if Value then
		FakeEvents.Screech.Parent = RemotesFolder
		FakeEvents.Screech_Real.Parent = nil
	else
		FakeEvents.Screech_Real.Parent = RemotesFolder
		FakeEvents.Screech.Parent = nil
	end
end)
Toggles.NoHaltDamage:OnChanged(function(Value)
	if Value then
		FakeEvents.Shade.Parent = RemotesFolder
		FakeEvents.Shade_Real.Parent = nil
	else
		FakeEvents.Shade_Real.Parent = RemotesFolder
		FakeEvents.Shade.Parent = nil
	end
end)
Toggles.NoA90Damage:OnChanged(function(Value)
	if RemotesFolder:FindFirstChild("A90") then
		if Value then
			FakeEvents.A90.Parent = RemotesFolder
			FakeEvents.A90_Real.Parent = nil
		else
			FakeEvents.A90_Real.Parent = RemotesFolder
			FakeEvents.A90.Parent = nil
		end
	end
end)
Toggles.NoSurgeDamage:OnChanged(function(Value)
	if RemotesFolder:FindFirstChild("SurgeRemote") then
		if Value then
			FakeEvents.Surge.Parent = RemotesFolder
			FakeEvents.Surge_Real.Parent = nil
		else
			FakeEvents.Surge_Real.Parent = RemotesFolder
			FakeEvents.Surge.Parent = nil
		end
	end
end)

local Modules = {}

Toggles.RemoveScreech:OnChanged(function(Value)
	if Value then
		task.spawn(function()
			while Toggles.RemoveScreech.Value do
				local Camera = workspace:FindFirstChild("Camera")

				if Camera then
					local Screech = Camera:FindFirstChild("Screech")

					if Screech then
						Screech:Destroy()
					end
				end

				task.wait()
			end
		end)
	end
end)
Toggles.RemoveHalt:OnChanged(function(Value)
	Modules.Shade.Name = Value and "Shade_Disabled" or "Shade"
end)
Toggles.RemoveA90:OnChanged(function(Value)
	if Modules.A90 then
		Modules.A90.Name = Value and "A90_Disabled" or "A90"
	end
end)
Toggles.RemoveDread:OnChanged(function(Value)
	if Modules.Dread then
		Modules.Dread.Name = Value and "Dread_Disabled" or "Dread"
	end
end)
Toggles.RemoveSurge:OnChanged(function(Value)
	if Globals.SurgeFrame then
		Globals.SurgeFrame.Name = (Value and "SurgeVignette_Disabled" or "SurgeVignette")
	end
end)

Groupboxes.Exploits_Audio = Tabs.Exploits:AddLeftGroupbox("Audio")
Globals.JamMuffle = Services.SoundService:WaitForChild("Main"):FindFirstChild("Jamming") or Instance.new("EqualizerSoundEffect")

Groupboxes.Exploits_Audio:AddToggle("RemoveFootstepSounds",    { Text = "Remove Footstep Sounds",    Default = false, Tooltip = "Removes the sounds when walking." })
Groupboxes.Exploits_Audio:AddToggle("RemoveJamminMusic",       { Text = "Remove Jammin Music",       Default = false, Tooltip = "Removes the music and muffle effect from the 'Jammin' modifier." })
Groupboxes.Exploits_Audio:AddToggle("RemoveInteractingSounds", { Text = "Remove Interacting Sounds", Default = false, Tooltip = "Removes the sounds when interacting with proximity prompts." })

Toggles.RemoveJamminMusic:OnChanged(function(Value)
	local Jam = Globals.MainUI.Initiator.Main_Game.Health:FindFirstChild("Jam")
	if Jam then
		Jam.Volume = Value and 0 or 0.45
		Globals.JamMuffle.Enabled = LiveModifiers:FindFirstChild("Jammin") and not Value or false
	end
end)
Toggles.RemoveInteractingSounds:OnChanged(function(Value)
	local PS = Globals.MainUI.Initiator.Main_Game.PromptService
	PS.Triggered.Volume   = Value and 0 or 0.04
	PS.Holding.Volume     = Value and 0 or 0.1
	PS.Notification.Volume = Value and 0 or 0.03
	Globals.MainUI.Initiator.Main_Game.Reminder.Caption.Volume = Value and 0 or 0.1
end)

Groupboxes.Visuals_LeftTab = Tabs.Visuals:AddLeftTabbox("Camera / Effects")
Groupboxes.Visuals_Camera = Groupboxes.Visuals_LeftTab:AddTab("Camera")
Groupboxes.Visuals_Camera:AddToggle("AmbientToggle", { Text = "Ambient", Default = false, Tooltip = "Changes the lighting color to the specified value." })
Groupboxes.Visuals_Camera:AddSlider("FieldOfView", { Text = "Field of View", Min = 1, Max = 120, Default = 70, Rounding = 0 })
Groupboxes.Visuals_Camera:AddToggle("FOVToggle", {    Text = "Custom FOV",    Default = false,    Tooltip = "Only applies the Field of View slider when enabled." })
Toggles.FOVToggle:AddKeyPicker("FovToggle", {Text = "Custom Fov", Default = "O", Mode = "Toggle", SyncToggleState = true})
Groupboxes.Visuals_Camera:AddDivider()
Groupboxes.Visuals_Camera:AddToggle("RemoveCameraShake", {
	Text = "Remove Camera Shake", Default = false, Tooltip = "Prevents the camera from shaking.",
	Disabled = not Functions.CheckCompatability({"require"}), DisabledTooltip = Globals.IncompatibleMessage
})
Groupboxes.Visuals_Camera:AddToggle("RemoveCameraBobbing", {
	Text = "Remove Camera Bobbing", Default = false, Tooltip = "Prevents the camera from bobbing when moving.",
	Disabled = not Functions.CheckCompatability({"require"}), DisabledTooltip = Globals.IncompatibleMessage
})
Groupboxes.Visuals_Camera:AddToggle("RemoveCutscenes", { Text = "Remove Cutscenes", Default = false, Tooltip = "Removes all non-necessary cutscenes." })
Groupboxes.Visuals_Camera:AddToggle("RemoveCameraFog", { Text = "Remove Fog", Default = false, Tooltip = "Removes all fog effects from the camera." })
Groupboxes.Visuals_Camera:AddDivider()
Groupboxes.Visuals_Camera:AddToggle("ThirdPersonToggle", { Text = "Third Person", Default = false, Tooltip = "Zooms out your camera, allowing you to see your character from behind." })
Toggles.ThirdPersonToggle:AddKeyPicker("ThirdPersonKeybind", { Text = "Third Person", Default = "T", Mode = "Toggle", SyncToggleState = true })
Groupboxes.Visuals_Camera:AddSlider("ThirdPersonOffsetX", { Text = "X Offset", Min = -10, Max = 10, Default = 1.5, Rounding = 1, Compact = true })
Groupboxes.Visuals_Camera:AddSlider("ThirdPersonOffsetY", { Text = "Y Offset", Min = -10, Max = 10, Default = 1,   Rounding = 1, Compact = true })
Groupboxes.Visuals_Camera:AddSlider("ThirdPersonOffsetZ", { Text = "Z Offset", Min = -10, Max = 10, Default = 5,   Rounding = 1, Compact = true })
Groupboxes.Visuals_Camera:AddToggle("ThirdPersonWallCheck", { Text = "Wall Check", Default = false, Tooltip = "Prevents third person from going through walls." })
Groupboxes.Visuals_Camera:AddDivider()
Groupboxes.Visuals_Camera:AddToggle("ViewmodelOffsetToggle", {
	Text = "Viewmodel Offset", Default = false, Tooltip = "Changes the offset of your viewmodel while holding an item.",
	Disabled = not Functions.CheckCompatability({"require"}), DisabledTooltip = Globals.IncompatibleMessage
})
Groupboxes.Visuals_Camera:AddSlider("ViewmodelOffsetX", { Text = "X Offset", Min = -10, Max = 10, Default = 0, Rounding = 1, Compact = true, Disabled = not Functions.CheckCompatability({"require"}), DisabledTooltip = Globals.IncompatibleMessage })
Groupboxes.Visuals_Camera:AddSlider("ViewmodelOffsetY", { Text = "Y Offset", Min = -10, Max = 10, Default = 0, Rounding = 1, Compact = true, Disabled = not Functions.CheckCompatability({"require"}), DisabledTooltip = Globals.IncompatibleMessage })
Groupboxes.Visuals_Camera:AddSlider("ViewmodelOffsetZ", { Text = "Z Offset", Min = -10, Max = 10, Default = 0, Rounding = 1, Compact = true, Disabled = not Functions.CheckCompatability({"require"}), DisabledTooltip = Globals.IncompatibleMessage })

Toggles.AmbientToggle:AddColorPicker("AmbientColor", { Text = "Ambient", Default = Color3.fromRGB(255, 255, 255), Transparency = 0 })
Toggles.AmbientToggle:OnChanged(function(Value)
	local OldAmbient = CurrentRooms:FindFirstChild(tostring(LocalPlayer:GetAttribute("CurrentRoom"))):GetAttribute("Ambient")
	Services.TweenService:Create(Services.Lighting, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {
		Ambient = Value and Options.AmbientColor.Value or OldAmbient
	}):Play()
end)

local Main_Game
local ClientModules

Toggles.RemoveCameraBobbing:OnChanged(function(Value)
	if Main_Game then Main_Game.spring.Speed = Value and 9e9 or 8 end
end)
Toggles.RemoveCameraFog:OnChanged(function(Value)
	Services.Lighting.FogEnd = Value and 10000000 or Globals.OldFog
	for _, Object in Globals.FogInstances do
		Object.Density = Value and 0 or Object:GetAttribute("Density_Old")
	end
end)
Toggles.RemoveCutscenes:OnChanged(function(Value)
    local Cutscenes = Globals.MainUI.Initiator.Main_Game.RemoteListener.Cutscenes
    for _, Object in pairs(Cutscenes:GetChildren()) do
        if table.find(CutsceneNames, Object.Name) and Object:IsA("ModuleScript") or table.find(CutsceneNames, Object:GetAttribute("OriginalName")) and Object:IsA("ModuleScript") then
            Object.Name = (Value and Object.Name .. "_Disabled" or Object:GetAttribute("OriginalName"))
        end
    end
    for _, Object in pairs(FloorReplicated:GetChildren()) do
        if table.find(CutsceneNames, Object.Name) and Object:IsA("ModuleScript") or table.find(CutsceneNames, Object:GetAttribute("OriginalName")) and Object:IsA("ModuleScript") then
            Object.Name = (Value and Object.Name .. "_Disabled" or Object:GetAttribute("OriginalName"))
        end
    end
end)

Groupboxes.Visuals_Effects = Groupboxes.Visuals_LeftTab:AddTab("Effects")
Groupboxes.Visuals_Effects:AddToggle("TransparentHidingSpotsToggle", { Text = "Transparent Hiding Spots", Default = false, Tooltip = "Makes a hiding spot transparent when you enter it." })
Groupboxes.Visuals_Effects:AddSlider("TransparentHidingSpotsSlider", { Text = "Transparency", Min = 0, Max = 1, Default = 0.5, Rounding = 2, Compact = true })

local function ApplyHidingTransparency(Value, SliderValue)
	for _, Object in Objects.HidingSpots do
		local IsHiding = false
		for _, Child in Object:GetDescendants() do
			if Child.Name == "HiddenPlayer" and Child.Value == Character then
				IsHiding = true
				break
			end
		end
		for _, Part in Object:GetDescendants() do
			if Part:IsA("BasePart") and Part:GetAttribute("Transparency_Old") then
				Services.TweenService:Create(Part, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
					Transparency = (Value and IsHiding) and SliderValue or Part:GetAttribute("Transparency_Old")
				}):Play()
			end
		end
	end
end

Toggles.TransparentHidingSpotsToggle:OnChanged(function(Value)
	ApplyHidingTransparency(Value, Options.TransparentHidingSpotsSlider.Value)
end)
Options.TransparentHidingSpotsSlider:OnChanged(function(Value)
	ApplyHidingTransparency(Toggles.TransparentHidingSpotsToggle.Value, Value)
end)

Groupboxes.Visuals_Effects:AddDivider()
Groupboxes.Visuals_Effects:AddToggle("DisableGlitchJumpscare",   { Text = "Disable Glitch Jumpscare",   Default = false, Tooltip = "Disables the jumpscare from 'Glitch'" })
Groupboxes.Visuals_Effects:AddToggle("DisableTimothyJumpscare",  { Text = "Disable Timothy Jumpscare",  Default = false, Tooltip = "Disables the jumpscare from 'Timothy'" })
Groupboxes.Visuals_Effects:AddToggle("DisableVoidJumpscare",     { Text = "Disable Void Jumpscare",     Default = false, Tooltip = "Disables the jumpscare from 'Void'" })
Groupboxes.Visuals_Effects:AddDivider()
Groupboxes.Visuals_Effects:AddToggle("DisableHideVignette",      { Text = "Disable Hide Vignette",      Default = false, Tooltip = "Disables the hiding screen effect." })
Groupboxes.Visuals_Effects:AddToggle("DisableFiredampEffect",    { Text = "Disable Firedamp Effect",    Default = false, Tooltip = "Disables the firedamp screen effect." })
Groupboxes.Visuals_Effects:AddToggle("DisableEntityJumpscares",  { Text = "Disable Entity Jumpscares",  Default = false, Tooltip = "Disables jumpscares from entities like Rush and Ambush." })

Toggles.DisableGlitchJumpscare:OnChanged(function(Value)
	Modules.Glitch.Name = Value and "Glitch_Disabled" or "Glitch"
end)
Toggles.DisableTimothyJumpscare:OnChanged(function(Value)
	Modules.SpiderJumpscare.Name = Value and "SpiderJumpscare_Disabled" or "SpiderJumpscare"
end)
Toggles.DisableVoidJumpscare:OnChanged(function(Value)
	if Modules.Void then Modules.Void.Name = Value and "Void_Disabled" or "Void" end
end)
Toggles.DisableHideVignette:OnChanged(function(Value)
	local Vignette = Globals.MainUI:FindFirstChild("HideVignette") or Globals.MainUI.MainFrame:FindFirstChild("HideVignette")
	if Vignette then Vignette.Image = Value and "Disabled" or "rbxassetid://6100076320" end
end)
Toggles.DisableFiredampEffect:OnChanged(function(Value)
	for _, Object in CurrentRooms:GetChildren() do
		if Value then
			Object:SetAttribute("Firedamp", false)
			for _, FiredampObj in Camera:GetChildren() do
				if FiredampObj.Name == "LiveFiredamp" then FiredampObj:Destroy() end
			end
		else
			Object:SetAttribute("Firedamp", Object:GetAttribute("Firedamp_Old"))
		end
	end
	local Old = LocalPlayer:GetAttribute("CurrentRoom")
	LocalPlayer:SetAttribute("CurrentRoom", 0)
	task.wait()
	LocalPlayer:SetAttribute("CurrentRoom", Old)
end)
Toggles.DisableEntityJumpscares:OnChanged(function(Value)
	local Jumpscares = Globals.MainUI.Initiator.Main_Game.RemoteListener:FindFirstChild("Jumpscares")
		or Globals.MainUI.Initiator.Main_Game.RemoteListener:FindFirstChild("Jumpscares_Disabled")
	if Jumpscares then
		Jumpscares.Name = Value and "Jumpscares_Disabled" or "Jumpscares"
		for _, Object in Objects.JumpscareModules do
			Object.Name = Value and (Object:GetAttribute("OriginalName") .. "_Disabled") or Object:GetAttribute("OriginalName")
		end
	end
end)

Groupboxes.Visuals_RightTab     = Tabs.Visuals:AddRightTabbox("Entities / Settings / Entity Nodes")
Groupboxes.Visuals_Entities     = Groupboxes.Visuals_RightTab:AddTab("Entities")
Groupboxes.Visuals_EntitySettings = Groupboxes.Visuals_RightTab:AddTab("Settings")

Groupboxes.Visuals_Entities:AddDropdown("EntityList", {
	Text = "Entity List",
	Values = { "Rush","Bash","Scribbles","Teller","DronesStampede","Creak","Noise","Noise_TV","Balls","Portrait","CreakHalloween","Weaveling","Ambush","Eyes","Halt","Blitz","Lookman","Gloombat Swarm","A-60","A-120","Sally","Jeff the Killer","Groundskeeper","Monument","AR0xMBUSH","RNIUSHCG==" },
	Multi = true, AllowNull = true
})
Groupboxes.Visuals_Entities:AddToggle("NotifyEntities",    { Text = "Notify Entities",    Default = false, Tooltip = "Sends a notification when an entity spawns." })
Groupboxes.Visuals_Entities:AddDivider()
Groupboxes.Visuals_Entities:AddToggle("ShowEntityPath", {
    Text = "Show Entity Path",
    Default = false,
    Tooltip = "Shows the path of entitys."
})


Groupboxes.Visuals_Entities:AddSlider("ShowEntityPathNodeTransparency", {
    Text = "Node Transparency",
    Default = 0,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = false,
    Tooltip = "Transparency of the path nodes when shown"
})

Groupboxes.Visuals_Entities:AddSlider("ShowEntityPathLineTransparency", {
    Text = "Line Transparency",
    Default = 0.15,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = false,
    Tooltip = "Transparency of the path lines"
})

Groupboxes.Visuals_Entities:AddSlider("ShowEntityPathLineThickness", {
    Text = "Line Thickness",
    Default = 0.3,
    Min = 0.08,
    Max = 1.2,
    Rounding = 2
})

local ShowEntityPathLines = {}

local function ShowEntityPathClearAllLines()
    for _, ShowEntityPathRoomLines in pairs(ShowEntityPathLines) do
        for _, ShowEntityPathLine in ipairs(ShowEntityPathRoomLines) do
            if ShowEntityPathLine and ShowEntityPathLine.Parent then
                ShowEntityPathLine:Destroy()
            end
        end
    end
    table.clear(ShowEntityPathLines)
end

local function ShowEntityPathCreateLine(ShowEntityPathPoint1, ShowEntityPathPoint2, ShowEntityPathTransparency, ShowEntityPathThickness, ShowEntityPathParent)
    local ShowEntityPathDistance = (ShowEntityPathPoint1 - ShowEntityPathPoint2).Magnitude
    if ShowEntityPathDistance < 0.05 then
        return nil
    end

    local ShowEntityPathLinePart = Instance.new("Part")
    ShowEntityPathLinePart.Name = "PathLine"
    ShowEntityPathLinePart.Anchored = true
    ShowEntityPathLinePart.CanCollide = false
    ShowEntityPathLinePart.CanQuery = false
    ShowEntityPathLinePart.CanTouch = false
    ShowEntityPathLinePart.CastShadow = false
    ShowEntityPathLinePart.Material = Enum.Material.ForceField
    ShowEntityPathLinePart.Color = Color3.fromRGB(0, 255, 210)
    ShowEntityPathLinePart.Transparency = ShowEntityPathTransparency
    ShowEntityPathLinePart.Size = Vector3.new(ShowEntityPathThickness, ShowEntityPathThickness, ShowEntityPathDistance)
    ShowEntityPathLinePart.CFrame = CFrame.lookAt(ShowEntityPathPoint1, ShowEntityPathPoint2) * CFrame.new(0, 0, -ShowEntityPathDistance / 2)
    ShowEntityPathLinePart.Parent = ShowEntityPathParent
    return ShowEntityPathLinePart
end

local function ShowEntityPathGetSortedNodes(ShowEntityPathNodes)
    local ShowEntityPathSortedNodes = {}
    for _, ShowEntityPathNode in ipairs(ShowEntityPathNodes:GetChildren()) do
        if ShowEntityPathNode:IsA("BasePart") then
            local ShowEntityPathNodeNumber = tonumber(ShowEntityPathNode.Name)
            if ShowEntityPathNodeNumber then
                table.insert(ShowEntityPathSortedNodes, {
                    Part = ShowEntityPathNode,
                    Number = ShowEntityPathNodeNumber
                })
            end
        end
    end
    table.sort(ShowEntityPathSortedNodes, function(a, b)
        return a.Number < b.Number
    end)
    return ShowEntityPathSortedNodes
end

local function ShowEntityPathSetNodeTransparency(ShowEntityPathTransparency)
    for _, ShowEntityPathRoom in ipairs(workspace.CurrentRooms:GetChildren()) do
        local ShowEntityPathNodes = ShowEntityPathRoom:FindFirstChild("PathfindNodes")
        if ShowEntityPathNodes then
            for _, ShowEntityPathNode in ipairs(ShowEntityPathNodes:GetChildren()) do
                if ShowEntityPathNode:IsA("BasePart") then
                    ShowEntityPathNode.Transparency = ShowEntityPathTransparency
                end
            end
        end
    end
end

local function ShowEntityPathSetLineTransparency(ShowEntityPathTransparency)
    for _, ShowEntityPathRoomLines in pairs(ShowEntityPathLines) do
        for _, ShowEntityPathLine in ipairs(ShowEntityPathRoomLines) do
            if ShowEntityPathLine and ShowEntityPathLine.Parent then
                ShowEntityPathLine.Transparency = ShowEntityPathTransparency
            end
        end
    end
end

local function ShowEntityPathUpdateAll()
    local ShowEntityPathShow = Toggles.ShowEntityPath.Value
    local ShowEntityPathNodeTransparency = ShowEntityPathShow and Options.ShowEntityPathNodeTransparency.Value or 1
    local ShowEntityPathLineTransparency = Options.ShowEntityPathLineTransparency.Value
    local ShowEntityPathLineThickness = Options.ShowEntityPathLineThickness.Value

    ShowEntityPathClearAllLines()

    if not ShowEntityPathShow then
        ShowEntityPathSetNodeTransparency(1)
        return
    end

    ShowEntityPathSetNodeTransparency(ShowEntityPathNodeTransparency)

    local ShowEntityPathValidRooms = {}
    for _, ShowEntityPathRoom in ipairs(workspace.CurrentRooms:GetChildren()) do
        if ShowEntityPathRoom:FindFirstChild("PathfindNodes") then
            table.insert(ShowEntityPathValidRooms, ShowEntityPathRoom)
        end
    end

    table.sort(ShowEntityPathValidRooms, function(a, b)
        return (tonumber(a.Name) or 0) < (tonumber(b.Name) or 0)
    end)

    for _, ShowEntityPathRoom in ipairs(ShowEntityPathValidRooms) do
        local ShowEntityPathNodes = ShowEntityPathRoom.PathfindNodes
        local ShowEntityPathSortedNodes = ShowEntityPathGetSortedNodes(ShowEntityPathNodes)

        if #ShowEntityPathSortedNodes > 0 then
            local ShowEntityPathRoomLines = {}

            for i = 1, #ShowEntityPathSortedNodes - 1 do
                local ShowEntityPathFrom = ShowEntityPathSortedNodes[i].Part
                local ShowEntityPathTo = ShowEntityPathSortedNodes[i + 1].Part

                local ShowEntityPathLine = ShowEntityPathCreateLine(
                    ShowEntityPathFrom.Position,
                    ShowEntityPathTo.Position,
                    ShowEntityPathLineTransparency,
                    ShowEntityPathLineThickness,
                    ShowEntityPathRoom
                )
                if ShowEntityPathLine then
                    table.insert(ShowEntityPathRoomLines, ShowEntityPathLine)
                end
            end

            if #ShowEntityPathRoomLines > 0 then
                ShowEntityPathLines[ShowEntityPathRoom] = ShowEntityPathRoomLines
            end
        end
    end
end

Toggles.ShowEntityPath:OnChanged(function()
    if ShowEntityPathChildAddedConnection then
        ShowEntityPathChildAddedConnection:Disconnect()
        ShowEntityPathChildAddedConnection = nil
    end

    ShowEntityPathUpdateAll()

    if Toggles.ShowEntityPath.Value then
        ShowEntityPathChildAddedConnection = workspace.CurrentRooms.ChildAdded:Connect(function(ShowEntityPathRoom)
            if ShowEntityPathRoom:WaitForChild("PathfindNodes", 5) then
                task.wait(0.1)
                ShowEntityPathUpdateAll()
            end
        end)
    end
end)

Options.ShowEntityPathNodeTransparency:OnChanged(function()
    if Toggles.ShowEntityPath.Value then
        ShowEntityPathSetNodeTransparency(Options.ShowEntityPathNodeTransparency.Value)
    end
end)

Options.ShowEntityPathLineTransparency:OnChanged(function()
    if Toggles.ShowEntityPath.Value then
        ShowEntityPathSetLineTransparency(Options.ShowEntityPathLineTransparency.Value)
    end
end)

Options.ShowEntityPathLineThickness:OnChanged(function()
    if Toggles.ShowEntityPath.Value then
        ShowEntityPathUpdateAll()
    end
end)


Groupboxes.Visuals_Entities:AddDivider()

local ItemsToNotify = {}
for Index, Name in pairs(ItemNames) do
	if not table.find(ItemsToNotify, Name) then
		table.insert(ItemsToNotify, Name)
	end
end
table.sort(ItemsToNotify)

Groupboxes.Visuals_Entities:AddDropdown("NotifyItemList", {
	Text = "Item List",
	Values = ItemsToNotify,
	Multi = true, AllowNull = true
})
Groupboxes.Visuals_Entities:AddToggle("NotifyItemsToggle",    { Text = "Notify Items",    Default = false, Tooltip = "Sends a notification when an item spawns." })
Groupboxes.Visuals_Entities:AddToggle("NotifyItemsShowDistance",    { Text = "Show Distance",    Default = false, Tooltip = "Shows how far away the item is in the notification." })
Groupboxes.Visuals_Entities:AddDivider()
Groupboxes.Visuals_Entities:AddToggle("NotifyLibraryCode", { Text = "Notify Library Code", Default = false, Tooltip = "Automatically solves the code for the library padlock." })
Groupboxes.Visuals_Entities:AddToggle("NotifyOxygen",      { Text = "Notify Oxygen Level", Default = false, Tooltip = "Shows how much oxygen you have remaining." })
Groupboxes.Visuals_Entities:AddToggle("NotifyHasteTime",   { Text = "Notify Haste Time",   Default = false, Tooltip = "Shows how much time you have remaining before 'Haste' spawns." })

Globals.LibraryCodeFound = false
Toggles.NotifyLibraryCode:OnChanged(function(Value)
	if Value then
		local Code = Functions.GetLibraryCode()
		if Code and not Code:find("_") and not Globals.LibraryCodeFound and CurrentRooms:FindFirstChild("50") then
			local Lock = Services.Workspace:FindFirstChild("Padlock", true)
			Functions.Notify({ Title = "Padlock code found!", Body = "The code is: '" .. Code .. "'", Time = Toggles.NotifyKeepNotifications.Value and Lock or 15 })
			Globals.LibraryCodeFound = true
		end
	end
end)

Groupboxes.Visuals_EntitySettings:AddToggle("EntityChatToggle", { Text = "Notify Chat", Default = false, Tooltip = "Sends a message in the chat when an entity spawns." })
Groupboxes.Visuals_EntitySettings:AddInput("EntityChatMessage", { Text = "Message", Default = "spawned!", Numeric = false, Placeholder = "Message" })
Groupboxes.Visuals_EntitySettings:AddDivider()
Groupboxes.Visuals_EntitySettings:AddDropdown("NotifyStyle", { Text = "Notify Style", Values = { "MsFent", "Doors", "STX", "Library" }, Default = 1 })
Groupboxes.Visuals_EntitySettings:AddSlider("NotifySoundVolume", { Text = "Sound Volume", Min = 0, Max = 10, Default = 3, Rounding = 1 })
Groupboxes.Visuals_EntitySettings:AddToggle("NotifyPlaySound", { Text = "Play Sound", Default = true, Tooltip = "Makes notifications play an alert sound." })
Groupboxes.Visuals_EntitySettings:AddToggle("NotifyKeepNotifications", { Text = "Keep Notifications", Default = false, Tooltip = "Certain notifications will stay on screen until they are no longer needed." })
Groupboxes.Visuals_EntitySettings:AddButton({ Text = "Test Notification", DoubleClick = false, Tooltip = "Sends a test notifcation, so you can see how your settings look.", Func = function()
	Functions.Notify({Title = "This is a test."})
end})

Groupboxes.Visuals_ESP          = Tabs.Visuals:AddRightTabbox("ESP/Settings")
Groupboxes.Visuals_ESP_Toggles  = Groupboxes.Visuals_ESP:AddTab("ESP")
Groupboxes.Visuals_ESP_Settings = Groupboxes.Visuals_ESP:AddTab("Settings")

local function MakeESPToggle(ToggleKey, ColorKey, Text, Tooltip, ObjectsTable, LabelFunc, RoomBased)
	Groupboxes.Visuals_ESP_Toggles:AddToggle(ToggleKey, { Text = Text, Default = false, Tooltip = Tooltip })
	Toggles[ToggleKey]:AddColorPicker(ColorKey, { Text = Text, Default = Options[ColorKey] and Options[ColorKey].Value or Color3.new(1,1,1), Transparency = 0 })
	Toggles[ToggleKey]:OnChanged(function(Value)
		for _, Object in ObjectsTable do
			if Value then
				local Label, UseRoom = LabelFunc(Object)
				if Label then
					Functions.AddESP({ Object = Object, Text = Label, Color = Options[ColorKey].Value }, UseRoom ~= nil and UseRoom or RoomBased)
				end
			else
				Functions.RemoveESP(Object)
			end
		end
	end)
	Options[ColorKey]:OnChanged(function(Value)
		for _, Object in ObjectsTable do
			Abysall.ESPLibrary:UpdateObjectColor(Object, Value)
		end
	end)
end

Groupboxes.Visuals_ESP_Toggles:AddToggle("ObjectiveESPToggle", { Text = "Objectives", Default = false, Tooltip = "Highlights all objects required to progress." })
Toggles.ObjectiveESPToggle:AddColorPicker("ObjectiveESPColor", { Text = "Objectives", Default = Color3.fromRGB(0, 255, 0), Transparency = 0 })

local ObjectiveLabels = {
	["DepotHalloween"] 		   = "Candy Magic",
	["StairwellLockpickDoor"]  = "Garage Door",
	["Mirror"]				   = "Mirror",
	["ShoppingCart"]		   = "Shopping Cart",
	["StairwellFireAlarm"]     = "Fire Alarm",
	["StairwellScrapper"]	   = "Scrapper",
	["ArchivesPackageDeposit"] = "BoxDeposit",
	["Cellar"] 				   = "Cellar",
	["ArchivesFihTank"]        = "Fih Tank",
	["KeyObtain"]              = "Door Key",
	["ElectricalKeyObtain"]    = "Electrical Key",
	["MinesGenerator"]         = "Generator",
	["FuseObtain"]             = "Generator Fuse",
	["LiveHintBook"]           = "Hint Book",
	["LiveBreakerPolePickup"]  = "Fuse Breaker",
	["LibraryHintPaper"]       = "Hint Paper",
	["PickupItem"]             = "Hint Paper",
	["CringlePresent"]         = "Present",
	["LeverForGate"]           = "Gate Lever",
	["MinesGateButton"]        = "Gate Button",
	["GardenGateButton"]       = "Gate Button",
}

Toggles.ObjectiveESPToggle:OnChanged(function(Value)
	for _, Object in Objects.Objectives do
		if Value then
			local Label = ObjectiveLabels[Object.Name]
			if Object.Name == "TimerLever" then
				Label = "Time Lever [+" .. Object:GetAttribute("AddTime") .. "s]"
			elseif Object.Name == "MinesAnchor" then
				Label = "Anchor [" .. Object:WaitForChild("Sign").TextLabel.Text .. "]"
			elseif Object.Name == "WaterPump" then
				Functions.AddESP({ Object = Object.Wheel, Text = "Water Pump", Color = Options.ObjectiveESPColor.Value }, true)
			elseif Object.Name == "VineGuillotine" then
				Functions.AddESP({ Object = Object.Lever, Text = "Vine Lever", Color = Options.ObjectiveESPColor.Value }, true)
			end
			if Label then
				Functions.AddESP({ Object = Object, Text = Label, Color = Options.ObjectiveESPColor.Value }, true)
			end
		else
			Functions.RemoveESP(Object)
		end
	end
end)
Options.ObjectiveESPColor:OnChanged(function(Value)
	for _, Object in Objects.Objectives do
		Abysall.ESPLibrary:UpdateObjectColor(Object, Value)
	end
end)

Groupboxes.Visuals_ESP_Toggles:AddToggle("DoorESPToggle",       { Text = "Doors",        Default = false, Tooltip = "Highlights the next door." })
Groupboxes.Visuals_ESP_Toggles:AddToggle("HidingSpotESPToggle", { Text = "Hiding Spots", Default = false, Tooltip = "Highlights places where you can hide from entities" })
Groupboxes.Visuals_ESP_Toggles:AddToggle("PlayerESPToggle",     { Text = "Players",      Default = false, Tooltip = "Highlights other players." })
Groupboxes.Visuals_ESP_Toggles:AddToggle("ChestESPToggle",      { Text = "Chests",       Default = false, Tooltip = "Highlights objects that can contain loot." })
Groupboxes.Visuals_ESP_Toggles:AddToggle("ItemESPToggle",       { Text = "Items",        Default = false, Tooltip = "Highlights all collectable items/consumables." })
Groupboxes.Visuals_ESP_Toggles:AddToggle("CurrencyESPToggle",   { Text = "Currency",     Default = false, Tooltip = "Highlights all currency that spawns." })
Groupboxes.Visuals_ESP_Toggles:AddToggle("LadderESPToggle",     { Text = "Ladders",      Default = false, Tooltip = "Highlights ladders that can be used to disable the anticheat." })
Groupboxes.Visuals_ESP_Toggles:AddToggle("MiscESPToggle",       { Text = "Misc",         Default = false, Tooltip = "Highlights miscellaneous objects that can be used to disable the anticheat." })
Groupboxes.Visuals_ESP_Toggles:AddDivider()
Groupboxes.Visuals_ESP_Toggles:AddDropdown("EntityESPOptions",     { 
	Text = "Entity List",
	Values = { "Rush","Bash","Scribbles","Teller","DronesStampede","Creak","Noise","Noise_TV","Balls","Portrait","CreakHalloween","Weaveling","Ambush","Eyes","Dupe","Figure","Blitz","Lookman","Snare","Giggle","Gloombat Eggs","Grumble","A-60","A-120","Sally","Jeff the Killer","Groundskeeper","Mandrake Hole","Monument","Bramble","AR0xMBUSH","RNIUSHCG==" },
	Multi = true,
	AllowNull = true
})
Groupboxes.Visuals_ESP_Toggles:AddToggle("EntityESPToggle",     { Text = "Entities",      Default = false, Tooltip = "Highlights all entities that spawn." })

Toggles.DoorESPToggle:AddColorPicker("DoorESPColor",           { Text = "Doors",        Default = Color3.fromRGB(0, 200, 255),  Transparency = 0 })
Toggles.HidingSpotESPToggle:AddColorPicker("HidingSpotESPColor", { Text = "Hiding Spots", Default = Color3.fromRGB(255, 170, 0),  Transparency = 0 })
Toggles.PlayerESPToggle:AddColorPicker("PlayerESPColor",       { Text = "Players",      Default = Color3.fromRGB(255, 255, 255), Transparency = 0 })
Toggles.ChestESPToggle:AddColorPicker("ChestESPColor",         { Text = "Chests",       Default = Color3.fromRGB(255, 255, 0),   Transparency = 0 })
Toggles.ItemESPToggle:AddColorPicker("ItemESPColor",           { Text = "Items",        Default = Color3.fromRGB(170, 0, 255),   Transparency = 0 })
Toggles.CurrencyESPToggle:AddColorPicker("CurrencyESPColor",   { Text = "Currency",     Default = Color3.fromRGB(255, 255, 0),   Transparency = 0 })
Toggles.LadderESPToggle:AddColorPicker("LadderESPColor",       { Text = "Ladders",      Default = Color3.fromRGB(3, 67, 71), Transparency = 0 })
Toggles.MiscESPToggle:AddColorPicker("MiscESPColor",           { Text = "Misc",         Default = Color3.fromRGB(255, 255, 255), Transparency = 0 })
Toggles.EntityESPToggle:AddColorPicker("EntityESPColor",       { Text = "Entities",     Default = Color3.fromRGB(255, 0, 0),     Transparency = 0 })

local HidingSpotLabels = {
	Wardrobe = "Closet", ["Backdoor_Wardrobe"] = "Closet", Toolshed = "Closet",
	RetroWardrobe = "Closet", ["Wardrobe-FOOLS26"] = "Closet",
	Locker_Large = "Locker", Rooms_Locker = "Hiding_Spot", Rooms_Locker_Fridge = "Locker",
	Bed = "Bed", Double_Bed = "Double Bed", CircularVent = "Vent", Dumpster = "Dumpster"
}
local ChestLabels = {
	ChestBox = true, ChestBoxLocked = true, Toolbox = true, Toolbox_Locked = true,
	Chest_Vine = "Vine Chest", Toolshed_Small = "Toolshed", Locker_Small_Locked = "Locked Item Locker", MouseHole = "Mouse"
}
local EntityESPLabels = {
	JeffTheKiller = "Jeff the Killer", GiggleCeiling = "Giggle",
	Snare = "Snare", GrumbleRig = "Grumble",
	Drakobloxxer = "Drakobloxxer", Hole = "Mandrake Hole", Groundskeeper = "Groundskeeper",
	LiveEntityBramble = "Bramble", Figure = "Figure", FigureRig = "Figure", FigureRagdoll = "Figure",
	FakeDoor = "Dupe", DoorFake = "Dupe"
}

local NodeEntities = {
	Rush = true, Bash = true, Scribbles = true, DronesStampede = true, Ambush = true, Eyes = true, Blitz = true, Lookman = true, ["A-60"] = true, ["A-120"] = true, Sally = true, ["Jeff The Killer"] = true, Monument = true, ["AR0xMBUSH"] = true, ["RNIUSHCG=="] = true
}

Toggles.DoorESPToggle:OnChanged(function(Value)
	for _, Object in Objects.Doors do
		if Value then Functions.AddESP({ Object = Object, Text = "Door " .. Functions.GetDoorNumber(Object), Color = Options.DoorESPColor.Value }, true)
		else Functions.RemoveESP(Object) end
	end
end)
Options.DoorESPColor:OnChanged(function(Value)
	for _, Object in Objects.Doors do Abysall.ESPLibrary:UpdateObjectColor(Object, Value) end
end)

Toggles.HidingSpotESPToggle:OnChanged(function(Value)
	for _, Object in Objects.HidingSpots do
		local Label = HidingSpotLabels[Object.Name]
		if Value and Label then Functions.AddESP({ Object = Object, Text = Label, Color = Options.HidingSpotESPColor.Value }, true)
		elseif not Value then Functions.RemoveESP(Object) end
	end
end)
Options.HidingSpotESPColor:OnChanged(function(Value)
	for _, Object in Objects.HidingSpots do Abysall.ESPLibrary:UpdateObjectColor(Object, Value) end
end)

Toggles.PlayerESPToggle:OnChanged(function(Value)
	task.wait()
	for _, Player in Services.Players:GetPlayers() do
		if Player.Character and Player ~= LocalPlayer then
			if Value and Player:GetAttribute("Alive") == true then
				Functions.AddESP({ Object = Player.Character, Text = Player.Name, Color = Options.PlayerESPColor.Value })
			else
				Functions.RemoveESP(Player.Character)
			end
		end
	end
end)
Options.PlayerESPColor:OnChanged(function(Value)
	for _, Player in Services.Players:GetPlayers() do
		if Player.Character and Player ~= LocalPlayer then
			Abysall.ESPLibrary:UpdateObjectColor(Player.Character, Value)
		end
	end
end)

Toggles.ChestESPToggle:OnChanged(function(Value)
	for _, Object in Objects.Chests do
		if Value then
			local Label
			if Object.Name == "ChestBox" or Object.Name == "ChestBoxLocked" then
				Label = Object:GetAttribute("Locked") and "Locked Chest" or "Chest"
			elseif Object.Name == "Toolbox" or Object.Name == "Toolbox_Locked" then
				Label = Object:GetAttribute("Locked") and "Locked Toolbox" or "Toolbox"
			elseif ChestLabels[Object.Name] and ChestLabels[Object.Name] ~= true then
				Label = ChestLabels[Object.Name]
			end
			if Label then Functions.AddESP({ Object = Object, Text = Label, Color = Options.ChestESPColor.Value }, true) end
		else
			Functions.RemoveESP(Object)
		end
	end
end)

Options.ChestESPColor:OnChanged(function(Value)
	for _, Object in Objects.Chests do Abysall.ESPLibrary:UpdateObjectColor(Object, Value) end
end)

Toggles.ItemESPToggle:OnChanged(function(Value)
	for _, Object in Objects.Items do
		if Value then
			local Label = ItemNames[Object.Name] or (Object.Name == "Green_Herb" and "Green Herb")
			if Label then
				Functions.AddESP({ Object = Object, Text = Label, Color = Options.ItemESPColor.Value }, Object:GetAttribute("ParentRoom") ~= nil)
			end
		else
			Functions.RemoveESP(Object)
		end
	end
end)
Options.ItemESPColor:OnChanged(function(Value)
	for _, Object in Objects.Items do Abysall.ESPLibrary:UpdateObjectColor(Object, Value) end
end)

Toggles.CurrencyESPToggle:OnChanged(function(Value)
	for _, Object in Objects.Currency do
		if Value then
			local Label
			if Object.Name == "GoldPile" and Object:GetAttribute("GoldValue") then
				Label = "Gold Pile [" .. Object:GetAttribute("GoldValue") .. "]"
			elseif Object.Name == "StardustPickup" then
				Label = "Stardust Pile"
			end
			if Label then Functions.AddESP({ Object = Object, Text = Label, Color = Options.CurrencyESPColor.Value }, true) end
		else
			Functions.RemoveESP(Object)
		end
	end
end)
Options.CurrencyESPColor:OnChanged(function(Value)
	for _, Object in Objects.Currency do Abysall.ESPLibrary:UpdateObjectColor(Object, Value) end
end)

Toggles.EntityESPToggle:OnChanged(function(Value)
	for _, Object in Objects.Entities do
		if Value then
			local Label = EntityESPLabels[Object.Name]
			if not Label and Entities[Object.Name] then Label = Entities[Object.Name].Alias end
			if Label and Options.EntityESPOptions.Value[Label] then
				Functions.AddESP({ Object = Object, Text = Label, Color = Options.EntityESPColor.Value }, NodeEntities[Label] ~= true)
			else
				Functions.RemoveESP(Object)
			end
		else
			Functions.RemoveESP(Object)
		end
	end
end)

Options.EntityESPOptions:OnChanged(function(Value)
	for _, Object in Objects.Entities do
		if Toggles.EntityESPToggle.Value then
			local Label = EntityESPLabels[Object.Name]
			if not Label and Entities[Object.Name] then Label = Entities[Object.Name].Alias end
			if Label and Options.EntityESPOptions.Value[Label] then
				Functions.AddESP({ Object = Object, Text = Label, Color = Options.EntityESPColor.Value }, NodeEntities[Label] ~= true)
			else
				Functions.RemoveESP(Object)
			end
		else
			Functions.RemoveESP(Object)
		end
	end
end)

Options.EntityESPColor:OnChanged(function(Value)
	for _, Object in Objects.Entities do Abysall.ESPLibrary:UpdateObjectColor(Object, Value) end
end)

Toggles.LadderESPToggle:OnChanged(function(Value)
	for _, Object in Objects.Ladders do
		if Value then Functions.AddESP({ Object = Object, Text = "Ladder", Color = Options.LadderESPColor.Value }, true)
		else Functions.RemoveESP(Object) end
	end
end)
Options.LadderESPColor:OnChanged(function(Value)
	for _, Object in Objects.Ladders do Abysall.ESPLibrary:UpdateObjectColor(Object, Value) end
end)

Toggles.MiscESPToggle:OnChanged(function(Value)
	for _, Object in Objects.Misc do
		if Value then
			local Label = Object.Name
			if Object.Name == "StairwellLockpickDoor" or Object.Name == "StiarwellLockpickDoor" then
				Label = "Garage Door"
			elseif Object.Name == "StairwellFireAlarm" then
				Label = "Fire Alarm"
			elseif Object.Name == "ShoppingCart" then
				Label = "Shopping Cart"
			elseif Object.Name == "ArchivesFihTank" or Object.Name == "ArchivesFishTank" then
				Label = "Fish Tank"
			end
			Functions.AddESP({ Object = Object, Text = Label, Color = Options.MiscESPColor.Value }, true)
		else
			Functions.RemoveESP(Object)
		end
	end
end)
Options.MiscESPColor:OnChanged(function(Value)
	for _, Object in Objects.Misc do Abysall.ESPLibrary:UpdateObjectColor(Object, Value) end
end)

Groupboxes.Visuals_ESP_Settings:AddToggle("ESPRainbow",     { Text = "Rainbow Effect", Default = false, Tooltip = "Makes the esp objects change colour like a rainbow." })
Groupboxes.Visuals_ESP_Settings:AddToggle("ESPShowDistance",{ Text = "Show Distance",  Default = true,  Tooltip = "Shows how far away your character is from the object." })
Groupboxes.Visuals_ESP_Settings:AddDivider()
Groupboxes.Visuals_ESP_Settings:AddSlider("ESPFillTransparency",        { Text = "Fill Transparency",         Min = 0, Max = 1, Default = 0.75, Rounding = 2, Compact = true })
Groupboxes.Visuals_ESP_Settings:AddSlider("ESPOutlineTransparency",     { Text = "Outline Transparency",      Min = 0, Max = 1, Default = 0,    Rounding = 2, Compact = true })
Groupboxes.Visuals_ESP_Settings:AddSlider("ESPTextTransparency",        { Text = "Text Transparency",         Min = 0, Max = 1, Default = 0,    Rounding = 2, Compact = true })
Groupboxes.Visuals_ESP_Settings:AddSlider("ESPTextOutlineTransparency", { Text = "Text Outline Transparency", Min = 0, Max = 1, Default = 0,    Rounding = 2, Compact = true })
Groupboxes.Visuals_ESP_Settings:AddSlider("ESPFadeTime",                { Text = "Fade Time",                 Min = 0, Max = 1, Default = 0.25, Rounding = 2, Compact = true })
Groupboxes.Visuals_ESP_Settings:AddSlider("ESPRenderLimit",             { Text = "Render Limit",              Min = 30, Max = 240, Default = 240, Rounding = 0, Compact = true })
Groupboxes.Visuals_ESP_Settings:AddSlider("ESPTextSize",                { Text = "Text Size",                 Min = 12, Max = 24, Default = 20, Rounding = 0, Compact = true })
Groupboxes.Visuals_ESP_Settings:AddDropdown("ESPTextFont", {
	Text = "Text Font",
	Values = { "Legacy","Arial","ArialBold","SourceSans","SourceSansBold","SourceSansLight","SourceSansItalic","Bodoni","Garamond","Cartoon","Code","Highway","SciFi","Arcade","Fantasy","Antique","SourceSansSemibold","Gotham","GothamMedium","GothamBold","GothamBlack","AmaticSC","Bangers","Creepster","DenkOne","Fondamento","FredokaOne","GrenzeGotisch","IndieFlower","JosefinSans","Jura","Kalam","LuckiestGuy","Merriweather","Michroma","Nunito","Oswald","PatrickHand","PermanentMarker","Roboto","RobotoCondensed","RobotoMono","Sarpanch","SpecialElite","TitilliumWeb","Ubuntu","BuilderSans","BuilderSansMedium","BuilderSansBold","BuilderSansExtraBold","Arimo","ArimoBold" },
	Default = 12
})
Groupboxes.Visuals_ESP_Settings:AddDivider()
Groupboxes.Visuals_ESP_Settings:AddDropdown("ESPTracersOrigin",  { Text = "Tracer Origin", Values = { "Bottom","Center","Top","Mouse" }, Default = 1 })
Groupboxes.Visuals_ESP_Settings:AddSlider("ESPTracerThickness",  { Text = "Tracer Thickness", Min = 0.5, Max = 2, Default = 0.75, Rounding = 2, Compact = true })
Groupboxes.Visuals_ESP_Settings:AddToggle("ESPTracersToggle",    { Text = "Enable Tracers", Default = false, Tooltip = "Draws a line to highlighted objects." })
Groupboxes.Visuals_ESP_Settings:AddDivider()
Groupboxes.Visuals_ESP_Settings:AddSlider("ESPArrowsRadius",     { Text = "Arrow Radius", Min = 100, Max = 500, Default = 250, Rounding = 0, Compact = true })
Groupboxes.Visuals_ESP_Settings:AddToggle("ESPArrowsToggle",     { Text = "Enable Arrows", Default = false, Tooltip = "Shows arrow that point to off-screen objects." })

Abysall.ESPLibrary:SetRainbow(false)
Abysall.ESPLibrary:SetShowDistance(true)
Abysall.ESPLibrary:SetFillTransparency(0.75)
Abysall.ESPLibrary:SetOutlineTransparency(0)
Abysall.ESPLibrary:SetTextTransparency(0)
Abysall.ESPLibrary:SetTextOutlineTransparency(0)
Abysall.ESPLibrary:SetRenderLimit(240)
Abysall.ESPLibrary:SetFadeTime(0.25)
Abysall.ESPLibrary:SetTextSize(20)
Abysall.ESPLibrary:SetFont(Enum.Font.Highway)
Abysall.ESPLibrary:SetTracers(false)
Abysall.ESPLibrary:SetTracerSize(0.75)
Abysall.ESPLibrary:SetTracerOrigin("Bottom")
Abysall.ESPLibrary:SetArrows(false)
Abysall.ESPLibrary:SetArrowRadius(250)
Abysall.ESPLibrary:SetDistanceSizeRatio(0.8)

Toggles.ESPRainbow:OnChanged(function(V)        Abysall.ESPLibrary:SetRainbow(V) end)
Toggles.ESPShowDistance:OnChanged(function(V)   Abysall.ESPLibrary:SetShowDistance(V) end)
Options.ESPFillTransparency:OnChanged(function(V)        Abysall.ESPLibrary:SetFillTransparency(V) end)
Options.ESPOutlineTransparency:OnChanged(function(V)     Abysall.ESPLibrary:SetOutlineTransparency(V) end)
Options.ESPTextTransparency:OnChanged(function(V)        Abysall.ESPLibrary:SetTextTransparency(V) end)
Options.ESPTextOutlineTransparency:OnChanged(function(V) Abysall.ESPLibrary:SetTextOutlineTransparency(V) end)
Options.ESPFadeTime:OnChanged(function(V)        Abysall.ESPLibrary:SetFadeTime(V) end)
Options.ESPRenderLimit:OnChanged(function(V)     Abysall.ESPLibrary:SetRenderLimit(V) end)
Options.ESPTextSize:OnChanged(function(V)        Abysall.ESPLibrary:SetTextSize(V) end)
Options.ESPTextFont:OnChanged(function(V)        Abysall.ESPLibrary:SetFont(Enum.Font[V]) end)
Toggles.ESPTracersToggle:OnChanged(function(V)   Abysall.ESPLibrary:SetTracers(V) end)
Options.ESPTracersOrigin:OnChanged(function(V)   Abysall.ESPLibrary:SetTracerOrigin(V) end)
Options.ESPTracerThickness:OnChanged(function(V) Abysall.ESPLibrary:SetTracerSize(V) end)
Toggles.ESPArrowsToggle:OnChanged(function(V)    Abysall.ESPLibrary:SetArrows(V) end)
Options.ESPArrowsRadius:OnChanged(function(V)    Abysall.ESPLibrary:SetArrowRadius(V) end)

Tabs.Floors:UpdateWarningBox({
	Visible = true,
	Title = "Compatability/Risk Warning",
	Text = "Features highlighted in red are risky / dont work in the current floor.",
})
Groupboxes.Floors_Automation = Tabs.Floors:AddRightGroupbox("Automation")

Groupboxes.Floors_Automation:AddToggle("SkipSeekMines", {
	Text = "Skip Seek (Mines)",
	Default = false,
	Tooltip = "Skips the entire Seek sections.",
	Risky = Floor ~= "Mines"
})

Toggles.SkipSeekMines:OnChanged(function(Value)
	if Value then
		if Floor ~= "Mines" then
			return
		end
		task.spawn(function()
			local MinesSkipSeekCurrentRooms

			repeat
				if not Toggles.SkipSeekMines.Value then
					return
				end

				MinesSkipSeekCurrentRooms = workspace:FindFirstChild("CurrentRooms")
				task.wait()
			until MinesSkipSeekCurrentRooms

			local MinesSkipSeekStartRoom

			repeat
				if not Toggles.SkipSeekMines.Value then
					return
				end

				MinesSkipSeekCurrentRooms = workspace:FindFirstChild("CurrentRooms")

				if MinesSkipSeekCurrentRooms then
					MinesSkipSeekStartRoom = MinesSkipSeekCurrentRooms:FindFirstChild("42")
				end

				task.wait()
			until MinesSkipSeekStartRoom

			local MinesSkipSeekStartDoor

			repeat
				if not Toggles.SkipSeekMines.Value then
					return
				end

				MinesSkipSeekStartDoor = MinesSkipSeekStartRoom:FindFirstChild("Door", true)
				task.wait()
			until MinesSkipSeekStartDoor

			repeat
				if not Toggles.SkipSeekMines.Value then
					return
				end

				task.wait()
			until MinesSkipSeekStartDoor:GetAttribute("Opened") == true

			if Character and Character:GetAttribute("Minecarting") == true then
				Character:SetAttribute("Minecarting", false)
			end

			for _, MinesSkipSeekRoomNumber in ipairs({
				43, 44, 45, 46, 47, 48, 49,
				78, 79, 80, 81, 82, 83
			}) do
				if not Toggles.SkipSeekMines.Value then
					return
				end

				local MinesSkipSeekRoom

				repeat
					if not Toggles.SkipSeekMines.Value then
						return
					end

					MinesSkipSeekCurrentRooms = workspace:FindFirstChild("CurrentRooms")

					if MinesSkipSeekCurrentRooms then
						MinesSkipSeekRoom = MinesSkipSeekCurrentRooms:FindFirstChild(
							tostring(MinesSkipSeekRoomNumber)
						)
					end

					task.wait()
				until MinesSkipSeekRoom

				local MinesSkipSeekDoor

				repeat
					if not Toggles.SkipSeekMines.Value then
						return
					end

					MinesSkipSeekDoor = MinesSkipSeekRoom:FindFirstChild("Door", true)
					task.wait()
				until MinesSkipSeekDoor

				repeat
					if not Toggles.SkipSeekMines.Value then
						return
					end

					if Character then
						Character:PivotTo(MinesSkipSeekDoor:GetPivot())
					end

					task.wait()
				until MinesSkipSeekDoor:GetAttribute("Opened") == true

				if MinesSkipSeekRoomNumber == 49 or MinesSkipSeekRoomNumber == 83 then
					if not Character then
						return
					end

					local MinesSkipSeekVoidPivot = Character:GetPivot()
					MinesSkipSeekVoidPivot = MinesSkipSeekVoidPivot + Vector3.new(0, -1000, 0)

					task.wait(0.3)

					for MinesSkipSeekVoidCount = 1, 12 do
						Character:PivotTo(MinesSkipSeekVoidPivot)
					end

					for MinesSkipSeekVoidCount = 1, 12 do
						Character:PivotTo(MinesSkipSeekVoidPivot)
					end

					for MinesSkipSeekVoidCount = 1, 12 do
						Character:PivotTo(MinesSkipSeekVoidPivot)
					end

					task.wait(0.3)

					for MinesSkipSeekVoidCount = 1, 6 do
						Character:PivotTo(MinesSkipSeekVoidPivot)
					end
				end

				if MinesSkipSeekRoomNumber == 83 then
					return
				end
			end
		end)
	end
end)

Groupboxes.Floors_Automation:AddToggle("AutoSteerMinecart", {
	Text = "Auto Steer Minecart", Default = false, Tooltip = "Automatically completes the minecart chase.",
	Disabled = not Functions.CheckCompatability({"require"}), DisabledTooltip = Globals.IncompatibleMessage
})
Groupboxes.Floors_Automation:AddSlider("AutoSteerMinecartTurnDistance", {
	Text = "Turn Distance", Min = 20, Max = 40, Default = 30, Rounding = 0,
	Disabled = not Functions.CheckCompatability({"require"}), DisabledTooltip = Globals.IncompatibleMessage
})
Groupboxes.Floors_Automation:AddSlider("AutoSteerMinecartDuckDistance", {
	Text = "Crouch Distance", Min = 20, Max = 40, Default = 30, Rounding = 0,
	Disabled = not Functions.CheckCompatability({"require"}), DisabledTooltip = Globals.IncompatibleMessage
})
Groupboxes.Floors_Automation:AddDivider()
Groupboxes.Floors_Automation:AddToggle("RoomsAutoWalk",             { Text = "Auto Rooms",       Default = false, Tooltip = "Automatically moves and hides from entities in The Rooms." })
Groupboxes.Floors_Automation:AddSlider("RoomsAutoWalkPathfindTimeout", { Text = "Pathfind Timeout", Min = 0.5, Max = 3, Default = 1, Rounding = 1 })
Groupboxes.Floors_Automation:AddToggle("RoomsAutoWalkIgnoreA60",    { Text = "Ignore A-60",      Default = false, Tooltip = "Continues to walk if entity 'A-60' is present, enables position spoof automatically." })
Groupboxes.Floors_Automation:AddToggle("RoomsAutoWalkShowPathToggle", { Text = "Show Path",       Default = false, Tooltip = "Shows the current path of rooms auto-walk." })
Groupboxes.Floors_Automation:AddToggle("RoomsAutoWalkSpoofFootsteps", {
    Text = "Spoof Footsteps", Default = false, Tooltip = "Makes it appear as if your character is walking normally.",
    Disabled = not Functions.CheckCompatability({"hookmetamethod", "newcclosure", "getnamecallmethod"}), DisabledTooltip = Globals.IncompatibleMessage
})

Toggles.RoomsAutoWalk:OnChanged(function()
	for _, Object in Globals.RoomsNodesFolder:GetChildren() do
		if Object.Name == "PathNode" then Object:Destroy() end
	end
end)
Toggles.RoomsAutoWalkShowPathToggle:AddColorPicker("RoomsAutoWalkShowPathColor", { Text = "Path", Default = Color3.fromRGB(0, 255, 0), Transparency = 0 })
Toggles.RoomsAutoWalkShowPathToggle:OnChanged(function(Value)
	for _, Object in Globals.RoomsNodesFolder:GetChildren() do
		if Object.Name == "PathNode" then Object.Transparency = Value and 0.5 or 1 end
	end
end)
Options.RoomsAutoWalkShowPathColor:OnChanged(function(Value)
	for _, Object in Globals.RoomsNodesFolder:GetChildren() do
		if Object.Name == "PathNode" then Object.Color = Value end
	end
end)

Functions.RoomsAutoWalk = {}
Functions.RoomsAutoWalk.GetNearestHidingSpot = function()
	local Nearest = { Distance = math.huge, Object = nil }
	for _, Object in Objects.HidingSpots do
		if Object.PrimaryPart and Object:FindFirstChild("HidePrompt") then
			local Distance = LocalPlayer:DistanceFromCharacter(Object.PrimaryPart.Position)
			if Distance < Nearest.Distance and Object.PrimaryPart.Position.Y > -10 then
				local HiddenPlayer = Object:FindFirstChild("HiddenPlayer", true)
				if HiddenPlayer and not HiddenPlayer.Value then
					Nearest.Distance = Distance
					Nearest.Object = Object
				end
			end
		end
	end
	return Nearest.Object
end

local RoomsEntityList = { "RushMoving","AmbushMoving","BackdoorRush","A60","A120","CustomEntity","GlitchRush","GlitchAmbush" }
Functions.RoomsAutoWalk.GetPathfindTarget = function()
	for _, Object in Services.Workspace:GetChildren() do
		if table.find(RoomsEntityList, Object.Name) and Object.PrimaryPart then
			local Y = Object.PrimaryPart.Position.Y
			if Y > -10 and Y < 150 then
				if Object.Name == "A60" and not Toggles.RoomsAutoWalkIgnoreA60.Value or Object.Name ~= "A60" then
					return Functions.RoomsAutoWalk.GetNearestHidingSpot() or CurrentRooms[tostring(LatestRoom.Value)]:FindFirstChild("RoomExit")
				end
			end
		end
	end
	return CurrentRooms[tostring(LatestRoom.Value)]:FindFirstChild("RoomExit")
end

Connections.RoomsAutoWalkHandler = Services.RunService.Heartbeat:Connect(function()
	if Floor ~= "Rooms" or not Toggles.RoomsAutoWalk.Value or Globals.RoomsAutoWalkActive or not CollisionPart or LatestRoom.Value >= 1000 then return end
	Globals.RoomsAutoWalkActive = true

	local Path = Services.PathfindingService:CreatePath({
		AgentCanJump = true, AgentCanClimb = false, WaypointSpacing = 4,
		AgentRadius = 1.5, AgentHeight = 1.5, Costs = { StuckPart = 8 }
	})

	if Toggles.RoomsAutoWalkIgnoreA60.Value and not Toggles.PositionSpoof.Value then
		Toggles.PositionSpoof:SetValue(true)
	end

	local TargetPart = Functions.RoomsAutoWalk.GetPathfindTarget()
	if not TargetPart then
		Globals.RoomsAutoWalkActive = false
		return
	end

	local TargetPosition
	if TargetPart.Name == "RoomExit" then
		TargetPosition = TargetPart.Position
	elseif TargetPart:FindFirstChild("HidePrompt") then
		for _, Part in TargetPart:GetDescendants() do
			if Part:IsA("BasePart") then Part.CanCollide = false end
		end
		TargetPosition = TargetPart.PrimaryPart.Position
	end

	if CollisionPart.Anchored and not TargetPart:FindFirstChild("HidePrompt") then
		Character:SetAttribute("Hiding", true)
		RemotesFolder.CamLock:FireServer()
		Character:SetAttribute("Hiding", false)
	end
	-- DontGroup
	local CurrentRoom = CurrentRooms[tostring(LatestRoom.Value)]
	if CurrentRoom:FindFirstChild("Door") then
		CurrentRoom.Door.Door.CanCollide = false
	end

	if not TargetPosition or LocalPlayer:DistanceFromCharacter(TargetPosition) >= 750 then
		Globals.RoomsAutoWalkActive = false
		return
	end

	Path:ComputeAsync(CollisionPart.Position, TargetPosition)
	local Waypoints = Path:GetWaypoints()

	if #Waypoints == 0 then
		local RoomExit = CurrentRoom:FindFirstChild("RoomExit")
		if RoomExit then Humanoid:MoveTo(RoomExit.Position) end
		Globals.RoomsAutoWalkActive = false
		return
	end

	for _, Node in Globals.RoomsNodesFolder:GetChildren() do
		if Node.Name == "PathNode" then Node:Destroy() end
	end

	for _, Waypoint in Waypoints do
		local Block = Instance.new("Part", Globals.RoomsNodesFolder)
		Block.Transparency = Toggles.RoomsAutoWalkShowPathToggle.Value and 0.5 or 1
		Block.Size = Vector3.one
		Block.Position = Waypoint.Position
		Block.Shape = Enum.PartType.Ball
		Block.CanCollide = false
		Block.Anchored = true
		Block.Name = "PathNode"
		Block.Color = Options.RoomsAutoWalkShowPathColor.Value
		Block.Material = Enum.Material.Neon
	end

	local Stuck = false
	for _, Waypoint in Waypoints do
		if Stuck or not Toggles.RoomsAutoWalk.Value then break end

		local Finished = false
		local Start = tick()

		local StepConnection = Services.RunService.RenderStepped:Connect(function()
			if Stuck or not Toggles.RoomsAutoWalk.Value then Finished = true return end

			local NewTarget = Functions.RoomsAutoWalk.GetPathfindTarget()
			if NewTarget and NewTarget:FindFirstChild("HidePrompt") and not TargetPart:FindFirstChild("HidePrompt") then
				Finished = true return
			end
			if TargetPart:FindFirstChild("HidePrompt") then
				local HidePrompt = TargetPart:FindFirstChild("HidePrompt")
				if LocalPlayer:DistanceFromCharacter(TargetPosition) < HidePrompt.MaxActivationDistance
					and Character:GetAttribute("Hiding") ~= true
				then
					Functions.ForceFirePrompt(HidePrompt)
				end
			end
			local FlatPos = Vector3.new(Waypoint.Position.X, RootPart.Position.Y, Waypoint.Position.Z)
			if LocalPlayer:DistanceFromCharacter(FlatPos) < 5 then Finished = true end
			Humanoid:MoveTo(Waypoint.Position)
		end)

		while not Finished do
			if tick() - Start > Options.RoomsAutoWalkPathfindTimeout.Value then
				local StuckBlock = Instance.new("Part", Globals.RoomsNodesFolder)
				StuckBlock.Transparency = 1
				StuckBlock.Size = Vector3.one
				StuckBlock.CFrame = Collision.CFrame
				StuckBlock.Shape = Enum.PartType.Ball
				StuckBlock.CanCollide = false
				StuckBlock.Anchored = true
				StuckBlock.Name = "StuckPart"
				local Modifier = Instance.new("PathfindingModifier", StuckBlock)
				Modifier.Label = "StuckPart"
				Stuck = true
				break
			end
			task.wait()
		end
		StepConnection:Disconnect()
		Humanoid:MoveTo(RootPart.Position)
	end

	Globals.RoomsAutoWalkActive = false
end)

Connections.RoomsHandler = CurrentRooms.ChildAdded:Connect(function(Room)
	for _, Object in Globals.RoomsNodesFolder:GetChildren() do
		if Object.Name == "StuckPart" then Object:Destroy() end
	end

	if Room:GetAttribute("RawName") and string.find(Room:GetAttribute("RawName"), "Eyestalk") then
        local PreviousNode = nil

		local function CreateEyestalkNode(WaypointPos)
			local NewNode = Instance.new("Part")
			NewNode.Size = Vector3.one
			NewNode.Transparency = 1
			NewNode.Parent = Globals.SeekNodesFolder
			NewNode.Anchored = true
			NewNode.Position = WaypointPos
			NewNode.CanCollide = false
			NewNode.Name = "SeekLightNode"

			local PrevNode = PreviousNode or NewNode
			PreviousNode = NewNode

			local NewBeam = Instance.new("Beam")
			NewBeam.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Options.ShowEyestalkPathColor.Value), ColorSequenceKeypoint.new(1, Options.ShowEyestalkPathColor.Value) })
			NewBeam.FaceCamera = true
			NewBeam.Width0 = 0.2
			NewBeam.Width1 = 0.2
			NewBeam.Brightness = 10
			NewBeam.LightInfluence = 0
			NewBeam.LightEmission = 0
			NewBeam.Enabled = true

			local Vis = Toggles.ShowEyestalkPathToggle.Value and 0 or 1
			NewBeam.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, Vis), NumberSequenceKeypoint.new(1, Vis) })
			NewBeam.Parent = Globals.SeekNodesFolder

			local A0 = Instance.new("Attachment", NewNode)
			local A1 = Instance.new("Attachment", PrevNode)
			NewBeam.Attachment0 = A0
			NewBeam.Attachment1 = A1

			table.insert(Objects.EyestalkHighlights, NewBeam)
		end

		Room:WaitForChild("RoomEntrance", 9e9)
		Room:WaitForChild("RoomExit", 9e9)

		while not Room:GetAttribute("PathFound") do
			if Toggles.ShowEyestalkPathToggle.Value then
				local EyePath = game:GetService("PathfindingService"):CreatePath({
					AgentCanJump = false, AgentCanClimb = false, WaypointSpacing = 2, AgentRadius = 1, AgentHeight = 1
				})
				EyePath:ComputeAsync(RootPart.Position, Room.RoomExit.Position)
				if EyePath.Status == Enum.PathStatus.Success then
					Room:SetAttribute("PathFound", true)
					for _, Waypoint in EyePath:GetWaypoints() do
						CreateEyestalkNode(Waypoint.Position)
						task.wait()
					end
                    break
				end
			end
			task.wait(0.25)
		end
	end
end)

Groupboxes.Floors_Completion = Tabs.Floors:AddRightGroupbox("Completion")
Groupboxes.Floors_Completion:AddButton({
    Text = "Auto Complete Dam Seek",
    Tooltip = "Automatically teleports to and interacts with each water pump.",
    Func = function()
        if LatestRoom.Value < 100 or Floor ~= "Mines" then
            Functions.Notify({Title = "You must be in Room 200 to do this."})
            return
        end

		local IsCutscene = false
		local CutsceneConnection = RemotesFolder.Cutscene.OnClientEvent:Connect(function()
			IsCutscene = true
			task.wait(7)
			IsCutscene = false
		end)

        local function GetNextPump()
            local Highest = {
                Height = -69420,
                Object = nil
            }
            for _, Object in pairs(Objects.Objectives) do
                if Object.Name == "WaterPump" and Object:GetAttribute("Abysall_Completed") ~= true then
                    if Object.PrimaryPart and Object.PrimaryPart.Position.Y > Highest.Height then
                        Highest.Object = Object
                        Highest.Height = Object.PrimaryPart.Position.Y
                    end
                end
            end
            return Highest.Object
        end

        local function HandlePump(Pump)

            while task.wait(0.1) do
				if IsCutscene then
					continue
				end

                Character:PivotTo(Pump:GetPivot())

                local Prompt = Pump:FindFirstChild("ValvePrompt", true)
                if Prompt then
                    Functions.ForceFirePrompt(Prompt)
                end

                if Pump:GetAttribute("Abysall_Completed") then
                    break
                end
            end
        end

        Functions.Notify({Title = "Attempting to complete the valves.", Body = "Please wait."})
        while task.wait(0.1) do
            local Pump = GetNextPump()
            if Pump then
                HandlePump(Pump)
            else
                break
            end
        end
        Functions.Notify({Title = "Successfully completed the valves."})
    end
})

Groupboxes.Floors_Completion:AddButton({
    Text = "Auto Complete Cringle",
    Tooltip = "Instantly completes the quest.",
    Func = function()
        local TouchPart = CurrentRooms:FindFirstChild("RippleExitDoor", true)
        if TouchPart then
            Character:PivotTo(TouchPart:GetPivot())
        end
    end
})

Groupboxes.Floors_Visuals = Tabs.Floors:AddLeftGroupbox("Visuals")
Groupboxes.Floors_Visuals:AddToggle("ShowSeekPathToggle", {
	Text = "Show Seek Path", Default = false, Tooltip = "Shows you the correct path in seek chases.",
	Risky = Floor ~= "Mines"
})
Toggles.ShowSeekPathToggle:AddColorPicker("ShowSeekPathColor", { Text = "Seek Path", Default = Color3.fromRGB(0, 255, 0), Transparency = 0 })

local function UpdateBeamVisibility(BeamTable, ColorKey, Visible)
	local Vis = Visible and 0 or 1
	local Seq = NumberSequence.new({ NumberSequenceKeypoint.new(0, Vis), NumberSequenceKeypoint.new(1, Vis) })
	for _, Beam in BeamTable do Beam.Transparency = Seq end
end
local function UpdateBeamColor(BeamTable, Value)
	local Seq = ColorSequence.new({ ColorSequenceKeypoint.new(0, Value), ColorSequenceKeypoint.new(1, Value) })
	for _, Beam in BeamTable do Beam.Color = Seq end
end

Toggles.ShowSeekPathToggle:OnChanged(function(V)  UpdateBeamVisibility(Objects.SeekHighlights, "ShowSeekPathColor", V) end)
Options.ShowSeekPathColor:OnChanged(function(V)   UpdateBeamColor(Objects.SeekHighlights, V) end)

Groupboxes.Floors_Visuals:AddToggle("ShowEyestalkPathToggle", {
	Text = "Show Eyestalk Path", Default = false, Tooltip = "Shows you the correct path in the eyestalk chase.",
	Risky = Floor ~= "Garden"
})
Toggles.ShowEyestalkPathToggle:AddColorPicker("ShowEyestalkPathColor", { Text = "Eyestalk Path", Default = Color3.fromRGB(0, 255, 0), Transparency = 0 })
Toggles.ShowEyestalkPathToggle:OnChanged(function(V) UpdateBeamVisibility(Objects.EyestalkHighlights, "ShowEyestalkPathColor", V) end)
Options.ShowEyestalkPathColor:OnChanged(function(V)  UpdateBeamColor(Objects.EyestalkHighlights, V) end)

Groupboxes.Floors_Bypass = Tabs.Floors:AddLeftGroupbox("Bypass")
Groupboxes.Floors_Bypass:AddToggle("RemoveSeekTrigger", {
	Text = "Delete Seek Trigger", Default = false, Tooltip = "Diables the 'Seek' chase trigger.",
	Risky = not (Floor == "Fools" or Floor == "OldHotel"),
	Disabled = not Functions.CheckCompatability({"firetouchinterest"}), DisabledTooltip = Globals.IncompatibleMessage
})
Groupboxes.Floors_Bypass:AddToggle("RemoveFigure", {
	Text = "Delete Figure", Default = false, Tooltip = "Completely removes the entity 'Figure' (doesn't always work).",
	Risky = not (Floor == "Fools" or Floor == "OldHotel" or Floor == "Mines"),
	Disabled = not Functions.CheckCompatability({"isnetworkowner"}), DisabledTooltip = Globals.IncompatibleMessage
})
Groupboxes.Floors_Bypass:AddToggle("AutoRevive", {
	Text = "Infinite Revives", Default = false, Tooltip = "Automatically revives after dying, with unlimited respawns.",
	Risky = not (Floor == "Fools" or Floor == "OldHotel")
})
Groupboxes.Floors_Bypass:AddToggle("FigureGodmode", {
	Text = "Figure Godmode", Default = false, Tooltip = "Prevents 'Figure' from hurting you.",
	Risky = not (Floor == "Fools" or Floor == "OldHotel")
})
Groupboxes.Floors_Bypass:AddDivider()
Groupboxes.Floors_Bypass:AddToggle("RemoveBasementGate",  { Text = "Remove Basement Gate",   Default = false, Tooltip = "Removes the gate from basement rooms.",            Risky = not (Floor == "Fools" or Floor == "OldHotel") })
Groupboxes.Floors_Bypass:AddToggle("RemovePaintingsDoor", { Text = "Remove Paintings Door",  Default = false, Tooltip = "Removes the fireplace doors from painting rooms.", Risky = not (Floor == "Fools" or Floor == "OldHotel") })
Groupboxes.Floors_Bypass:AddToggle("RemoveSkeletonDoor",  { Text = "Remove Skeleton Door",   Default = false, Tooltip = "Removes the skeleton door from the infirmary.",    Risky = Floor ~= "Fools" })

local ObstructionNames = { ThingToOpen = "RemoveBasementGate", MovingDoor = "RemovePaintingsDoor", Wax_Door = "RemoveSkeletonDoor" }
for ObjName, ToggleName in ObstructionNames do
	Toggles[ToggleName]:OnChanged(function(Value)
		for _, Object in Objects.Obstructions do
			if Object.Name == ObjName then
				Object:PivotTo(Value and CFrame.new(-10000, -10000, -10000) or Object:GetAttribute("OriginalPosition"))
			end
		end
	end)
end

Groupboxes.Floors_Farming = Tabs.Floors:AddLeftGroupbox("Farming")
Groupboxes.Floors_Farming:AddToggle("KnobFarm", {
    Text = "Knob Farm",
    Default = false,
    Tooltip = "Automatically gains knobs for you, dies and revives repeatedly.",
	Risky = Floor ~= "Ballz",
})

Groupboxes.Floors_Farming:AddButton({
    Text = "Start Knob Farm",
    Tooltip = "Starts farming knobs, click this when you have enough gold.",
    Func = function()
		if LatestRoom.Value ~= 0 then
			Functions.Notify({Title = "You must be in Room 0 to use this."})
			return
		end

		if LocalPlayer.PlayerGui:FindFirstChild("TopbarUI") then 
			local GoldCount = LocalPlayer.PlayerGui.TopbarUI.Topbar.StatsTopbarHandler.StatModules.Gold.GoldVal
			if GoldCount.Value <= 0 then
				Functions.Notify({Title = "You must have gold to do this."})
				return
			end
		end

        Globals.KnobFarmStarted = true
    end
})

Groupboxes.Floors_Farming:AddDivider()
Groupboxes.Floors_Farming:AddButton({
	Text = "Start Death Farm",
	DoubleClick = true,
	Tooltip = "Automatically farms deaths, joining new runs.",
	Func = function()
		warn("[Ms fent] DeathFarm button disabled (no remote Abysall scripts)")
	end,

	Disabled = not Functions.CheckCompatability({"fireproximityprompt", "firesignal"}),
	DisabledTooltip = Globals.ImcompatibleMessage
})
Groupboxes.Floors_Farming:AddButton({
	Text = "Copy Death Farm Loadstring",
	DoubleClick = false,
	Tooltip = "Copies the death farm loadstring to your clipboard.",
	Func = function()
		toclipboard([==[
			warn("[Ms fent] DeathFarm button disabled (no remote Abysall scripts)")
		]==])
		Library:Notify("Loadstring has been copied to your clipboard.")
	end,

	Disabled = not Functions.CheckCompatability({"fireproximityprompt", "firesignal"}),
	DisabledTooltip = Globals.ImcompatibleMessage
})

Toggles.KnobFarm:OnChanged(function(Value)
    if Value then
        Functions.Notify({Title = "Please collect some gold to earn knobs.", Body = "Click 'Start Knob Farm' when you're ready."})
	else
		Globals.KnobFarmStarted = false
    end
end)

Globals.KnobFarmActive = false
Globals.KnobFarmStarted = false
Connections.KnobFarm = Services.RunService.Heartbeat:Connect(function()
	if Toggles.KnobFarm.Value and Globals.KnobFarmStarted then
		if not Globals.KnobFarmActive then
			Globals.KnobFarmActive = true
			if Functions.CheckCompatability({"replicatesignal"}) then
				Abysall.Environment.replicatesignal(LocalPlayer.Kill)
			else
				LocalPlayer.Character.Humanoid.Health = 0
			end
			while task.wait() do
				if LocalPlayer:GetAttribute("Alive") then
					break
				end
			end
			RemotesFolder.Statistics:FireServer()
			task.wait(0.25)
			Globals.KnobFarmActive = false
		end
	end
end)

local MainHook
local OtherHook
if Functions.CheckCompatability({"hookmetamethod", "newcclosure", "getnamecallmethod"}) then
	MainHook = Abysall.Environment.hookmetamethod(game, "__namecall", Abysall.Environment.newcclosure(function(Self, ...)
		local Args = { ... }
		if Abysall and Abysall.Environment then
			local Method = Abysall.Environment.getnamecallmethod()

			if Self.Name == "Crouch" and Method == "FireServer" then
				if Toggles.CrouchSpoof.Value or Toggles.PositionSpoof.Value then
					Args[1] = true
				end
				Args[2] = true
			end

			if Self.Name == "ClutchHeartbeat" and Method == "FireServer" and Toggles.AutoHeartbeatMinigame.Value or Self.Name == "HideMonster" and Method == "FireServer" and Toggles.AutoHeartbeatMinigame.Value then
				return
			end

			if Self.Name == "MotorReplication" and Method == "FireServer" then
				local DoBypass = (Toggles.BypassEyes.Value and Globals.IsEyes) or (Toggles.BypassLookman.Value and Globals.IsLookman)
				if DoBypass then
					if Floor == "Fools" or Floor == "OldHotel" then
						Args[1] = 0 Args[2] = (Globals.SpoofOffset == 200 and 65 or -65) Args[3] = 0 Args[4] = false
					else
						Args[1] = -650
					end
				end
			end
		end
		return MainHook(Self, table.unpack(Args))
	end))

    OtherHook = Abysall.Environment.hookmetamethod(game, "__index", Abysall.Environment.newcclosure(function(Self, Property)
        local Real = OtherHook(Self, Property)

        if Property == "MoveDirection" and Self == Humanoid and Globals.RoomsAutoWalkActive and Toggles.RoomsAutoWalkSpoofFootsteps.Value and Floor == "Rooms" and not Character:GetAttribute("Hiding") then
            return RootPart.CFrame.LookVector
        end
        
        return Real
    end))
end

if Services.ReplicatedStorage:FindFirstChild("ModulesClient") then
	ClientModules = Services.ReplicatedStorage.ModulesClient
else
	ClientModules = Services.ReplicatedStorage.ClientModules
end

Modules = {
	Glitch         = ClientModules.EntityModules.Glitch,
	Shade          = ClientModules.EntityModules.Shade,
	Void           = ClientModules.EntityModules:FindFirstChild("Void"),
	SpiderJumpscare = nil,
	A90            = nil,
	Screech        = nil,
	Dread          = nil,
	GlitchScreech  = nil,
}

local CharacterOldConnectionKeys = {
	"MainHandler", "JumpHandler", "SlideHandler", "LibraryCodeHandler1", "LibraryCodeHandler2",
	"OxygenConnection", "AnimationHandler", "AutoHideConnection", "AutoReviveHandler",
	"SHMFixer", "AnticheatDisabler", "AnticheatEnableDetector1", "AnticheatEnableDetector2",
	"AutoSteerMinecartDuckHandler", "AutoSolveAnchorsConnection", "InfiniteJumpsConnection1", "InfiniteJumpsConnection2",
	"FootstepHandler"
}

Globals.IsTyping = false
Connections.TextBoxConnection1 = Services.UserInputService.TextBoxFocused:Connect(function()
	Globals.IsTyping = true
end)
Connections.TextBoxConnection2 = Services.UserInputService.TextBoxFocusReleased:Connect(function()
	Globals.IsTyping = false
end)

Functions.HandleCharacter = function(NewCharacter)
	for _, Key in CharacterOldConnectionKeys do
		if Connections[Key] then
			Connections[Key]:Disconnect()
			Connections[Key] = nil
		end
	end

	while not LocalPlayer.PlayerGui:FindFirstChild("MainUI") do
		task.wait()
	end

	Character = NewCharacter
	Humanoid = NewCharacter:WaitForChild("Humanoid", 9e9)
	RootPart = NewCharacter:FindFirstChild("HumanoidRootPart")
	Camera   = Services.Workspace.CurrentCamera

	Globals.OldCamera = Camera
	Globals.MainUI = LocalPlayer.PlayerGui.MainUI

	Collision = NewCharacter:WaitForChild("Collision")
	CollisionPart  = NewCharacter:FindFirstChild("CollisionPart") or NewCharacter:FindFirstChild("Collision")
	CollisionClone = Collision:Clone()
	CollisionClone.Parent = NewCharacter
	CollisionClone.Name = "CollisionClone"
	CollisionClone.Massless = true

	CollisionPartClone = CollisionPart:Clone()
	CollisionPartClone.Parent = NewCharacter
	CollisionPartClone.Name = "CollisionPartClone"
	CollisionPartClone.CanCollide = false
	CollisionPartClone.Massless = true

	if CollisionPartClone:FindFirstChild("CollisionCrouch") then
		CollisionPartClone.CollisionCrouch:Destroy()
	end

	Character:SetAttribute("SpeedBoost", 0)
	Character:SetAttribute("SpeedBoostBehind", 0)
	Character:SetAttribute("SpeedBoostExtra", 0)

	OldJump  = NewCharacter:GetAttribute("CanJump")
	OldSlide = NewCharacter:GetAttribute("CanSlide")

	if Toggles.EnableCharacterJump.Value  then Character:SetAttribute("CanJump",  true) end
	if Toggles.EnableCharacterSlide.Value then Character:SetAttribute("CanSlide", true) end

	if Functions.CheckCompatability({"require"}) then
		Main_Game = Abysall.Environment.require(Globals.MainUI.Initiator.Main_Game)
	end

	if Main_Game and Toggles.RemoveCameraBobbing.Value then
		Main_Game.spring.Speed = 9e9
	end

	if Main_Game and Functions.CheckCompatability({"require"}) then
		local Controls = require(LocalPlayer.PlayerScripts.PlayerModule):GetControls()
		local OriginalGetMoveVector = Controls.GetMoveVector
		Globals.OriginalGetMoveVector = OriginalGetMoveVector
		Controls.GetMoveVector = function(...)
			if Toggles.AutoSteerMinecart.Value and Floor == "Mines" then
				local Node = Globals.NearestTurnNode
				if Node and Functions.GetMinecart() then
					local Turn = Node:GetAttribute("Turn")
					return Turn == "Left" and Vector3.new(-1, 0, 0) or Turn == "Right" and Vector3.new(1, 0, 0) or Vector3.zero
				end
			end
			return OriginalGetMoveVector(...)
		end
	end

	Globals.AutoMinecartDucked = false
	Globals.LastDuck = tick()
	Connections.AutoSteerMinecartDuckHandler = Services.RunService.Heartbeat:Connect(function()
		if not Toggles.AutoSteerMinecart.Value or not Functions.GetMinecart() or tick() - Globals.LastDuck < 0.1 then return end
		Globals.NearestTurnNode = Functions.GetNearestTurnNode()

		if not Globals.AutoMinecartDucked and Functions.GetNearestDuckBoard() then
			Main_Game.crouch(true)
			Globals.AutoMinecartDucked = true
		elseif not Functions.GetNearestDuckBoard() and Globals.AutoMinecartDucked then
			Main_Game.crouch(false)
			Globals.AutoMinecartDucked = false
		end
		if Main_Game then
			Main_Game.fovtarget = Options.FieldOfView.Value
		else
			Camera.FieldOfView = Options.FieldOfView.Value
		end
		Globals.LastDuck = tick()
	end)

	Globals.AnticheatDisabled = false

	local UIModules = Globals.MainUI.Initiator.Main_Game.RemoteListener.Modules
	Modules.A90             = UIModules:FindFirstChild("A90")
	Modules.Screech         = UIModules.Screech
	Modules.Dread           = UIModules:FindFirstChild("Dread")
	Modules.SpiderJumpscare = UIModules.SpiderJumpscare

	if Toggles.RemoveScreech.Value    then Modules.Screech.Name = "Screech_Disabled" print ("screech gone") end
	if Toggles.RemoveA90.Value and Modules.A90   then Modules.A90.Name = "A90_Disabled" end
	if Toggles.RemoveDread.Value and Modules.Dread then Modules.Dread.Name = "Dread_Disabled" end
	if Toggles.DisableTimothyJumpscare.Value then Modules.SpiderJumpscare.Name = "SpiderJumpscare_Disabled" end

	if Toggles.DisableHideVignette.Value then
		local Vignette = Globals.MainUI:FindFirstChild("HideVignette") or Globals.MainUI.MainFrame:FindFirstChild("HideVignette")
		if Vignette then Vignette.Image = "Disabled" end
	end
	if Toggles.RemoveInteractingSounds.Value then
		local PS = Globals.MainUI.Initiator.Main_Game.PromptService
		PS.Triggered.Volume = 0
		PS.Holding.Volume   = 0
		PS.Notification.Volume = 0
		Globals.MainUI.Initiator.Main_Game.Reminder.Caption.Volume = 0
	end
	if Toggles.DisableEntityJumpscares.Value then
		local JS = Globals.MainUI.Initiator.Main_Game.RemoteListener:FindFirstChild("Jumpscares")
		if JS then JS.Name = "Jumpscares_Disabled" end
	end
    local Cutscenes = Globals.MainUI.Initiator.Main_Game.RemoteListener.Cutscenes
    for _, Object in pairs(Cutscenes:GetChildren()) do
        if table.find(CutsceneNames, Object.Name) and Object:IsA("ModuleScript") then
            Object:SetAttribute("OriginalName", Object.Name)
            if Toggles.RemoveCutscenes.Value then
                Object.Name = Object.Name .. "_Disabled"
            end
        end
    end
    for _, Object in pairs(FloorReplicated:GetChildren()) do
        if table.find(CutsceneNames, Object.Name) and Object:IsA("ModuleScript") then
            Object:SetAttribute("OriginalName", Object.Name)
            if Toggles.RemoveCutscenes.Value then
                Object.Name = Object.Name .. "_Disabled"
            end
        end
    end

	CustomPhysics = PhysicalProperties.new(
		100,
		RootPart.CustomPhysicalProperties.Friction,
		RootPart.CustomPhysicalProperties.Elasticity,
		RootPart.CustomPhysicalProperties.FrictionWeight,
		RootPart.CustomPhysicalProperties.ElasticityWeight
	)
	for _, Part in NewCharacter:GetDescendants() do
		if Part:IsA("BasePart") then
			PartProperties[Part] = Part.CustomPhysicalProperties
			if Toggles.RemoveAcceleration.Value then
				Part.CustomPhysicalProperties = CustomPhysics
			end
		end
	end

	Connections.LibraryCodeHandler1 = LocalPlayer.PlayerGui.PermUI.Hints.ChildAdded:Connect(function()
		if Toggles.NotifyLibraryCode.Value then
			local Code = Functions.GetLibraryCode()
			if Code and not Code:find("_") and not Globals.LibraryCodeFound then
				local Lock = Services.Workspace:FindFirstChild("Padlock", true)
				Functions.Notify({ Title = "Padlock code found!", Body = "The code is: '" .. Code .. "'", Time = Toggles.NotifyKeepNotifications.Value and Lock or 15 })
				Globals.LibraryCodeFound = true
			end
		end
	end)

	Connections.LibraryCodeHandler2 = Character.ChildAdded:Connect(function(Child)
		if (Child.Name == "LibraryHintPaper" or Child.Name == "LibraryHintPaperHard") and Toggles.NotifyLibraryCode.Value then
			local Code = Functions.GetLibraryCode()
			if Code and not Code:find("_") and not Globals.LibraryCodeFound then
				local Lock = Services.Workspace:FindFirstChild("Padlock", true)
				Functions.Notify({ Title = "Padlock code found!", Body = "The code is: '" .. Code .. "'", Time = Toggles.NotifyKeepNotifications.Value and Lock or 15 })
				Globals.LibraryCodeFound = true
			end
		end
	end)

	Connections.FootstepHandler = Character.ChildAdded:Connect(function(Object)
		if Object:IsA("Sound") and Object.Name == "Sound" and Toggles.RemoveFootstepSounds.Value then
			Object.Volume = 0
		end
	end)

	Globals.OldOxygen = Character:GetAttribute("Oxygen")
	Connections.OxygenConnection = Character:GetAttributeChangedSignal("Oxygen"):Connect(function()
		local NewOxy = Character:GetAttribute("Oxygen")
		if NewOxy < Globals.OldOxygen and Toggles.NotifyOxygen.Value then
			Functions.Caption(Functions.FormatOxygen(NewOxy), true)
		end
		Globals.OldOxygen = NewOxy
	end)

	Connections.AutoReviveHandler = LocalPlayer:GetAttributeChangedSignal("Alive"):Connect(function()
		if LocalPlayer:GetAttribute("Alive") == false and Toggles.AutoRevive.Value then
			if Floor == "Fools" or Floor == "OldHotel" then
				while LocalPlayer:GetAttribute("Alive") ~= true do
					RemotesFolder.Revive:FireServer()
					task.wait(0.5)
				end
			end
		end
	end)

	Connections.SHMFixer = RootPart:GetPropertyChangedSignal("Anchored"):Connect(function()
		task.wait()
		if Floor == "Fools" and RootPart.Anchored and Character:GetAttribute("Hiding") ~= true then
			RootPart.Anchored = false
		end
	end)

	Connections.AnticheatDisabler = Character:GetAttributeChangedSignal("Climbing"):Connect(function()
		if Character:GetAttribute("Climbing") == true and Toggles.DisableAnticheat.Value and not Globals.AnticheatDisabled then
			task.wait(0.25)
			Character:SetAttribute("Climbing", false)
			Functions.Notify({ Title = "Successfully disabled the anticheat.", Body = "It will be re-enabled after a cutscene or halt room." })
			Globals.AnticheatDisabled = true
		end
	end)

	Connections.AnticheatEnableDetector1 = RemotesFolder:WaitForChild("Cutscene").OnClientEvent:Connect(function(CutsceneName)
		if Globals.AnticheatDisabled and not CutsceneName:find("SewerSeek") then
			Globals.AnticheatDisabled = false
			Functions.Notify({ Title = "The anticheat has been re-enabled.", Body = "Interact with a ladder to disable it again." })
		end
	end)

	Connections.AnticheatEnableDetector2 = RemotesFolder:WaitForChild("UseEnemyModule").OnClientEvent:Connect(function(ModuleName)
		if ModuleName == "Void" or ModuleName == "Glitch" then
			if Globals.AnticheatDisabled then
				Globals.AnticheatDisabled = false
				Functions.Notify({ Title = "The anticheat has been re-enabled.", Body = "Interact with a ladder to disable it again." })
			end
			LocalPlayer:SetAttribute("CurrentRoom", LatestRoom.Value)
		end
	end)

	Connections.AnimationHandler = Character.ChildAdded:Connect(function()
		local ToolNames = { "Lockpick","Shears","SkeletonKey","Key","GeneratorFuse","KeyElectrical","KeyBackdoor","KeyIron", "Multitool" }
		local Tool
		for _, Name in ToolNames do
			Tool = Character:FindFirstChild(Name)
			if Tool then break end
		end
		if not Tool then return end

		local UseAnim = Tool:FindFirstChild("use", true) or Tool:FindFirstChild("promptanim", true)
		if UseAnim then
			UseAnim = Humanoid:LoadAnimation(UseAnim)
			UseAnim.Priority = Enum.AnimationPriority.Action4
			Globals.UseAnimation = UseAnim
		end
		local UseAnimBreak = Tool:FindFirstChild("usefinish", true) or Tool:FindFirstChild("promptanimend", true) or Tool:FindFirstChild("lockpickuse", true)
		if UseAnimBreak then
			UseAnimBreak = Humanoid:LoadAnimation(UseAnimBreak)
			UseAnimBreak.Priority = Enum.AnimationPriority.Action4
			Globals.UseAnimationBreak = UseAnimBreak
		end
	end)

	Connections.JumpHandler = Character:GetAttributeChangedSignal("CanJump"):Connect(function()
		local Val = Character:GetAttribute("CanJump")
		if Toggles.EnableCharacterJump.Value and Val ~= true or not Toggles.EnableCharacterJump.Value then
			OldJump = Val
		end
		if Toggles.EnableCharacterJump.Value then Character:SetAttribute("CanJump", true) end
	end)

	Connections.SlideHandler = Character:GetAttributeChangedSignal("CanSlide"):Connect(function()
		local Val = Character:GetAttribute("CanSlide")
		if Toggles.EnableCharacterSlide.Value and Val ~= true or not Toggles.EnableCharacterSlide.Value then
			OldSlide = Val
		end
		if Toggles.EnableCharacterSlide.Value then Character:SetAttribute("CanSlide", true) end
	end)

	Connections.InfiniteJumpsConnection1 = Services.UserInputService.InputBegan:Connect(function(Input)
		if Input.KeyCode == Enum.KeyCode.Space and Toggles.InfiniteJumps.Value and not Globals.IsTyping then
			Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end)

	local JumpButton = Globals.MainUI.MainFrame.MobileButtons:FindFirstChild("JumpButton")
	if JumpButton then
		Connections.InfiniteJumpsConnection2 = JumpButton.MouseButton1Down:Connect(function()
			if Toggles.InfiniteJumps.Value then
				Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end)
	end

	Globals.SpoofOffset = 0
	Globals.LastAutoHide = tick()
	Connections.AutoHideConnection = Services.RunService.Heartbeat:Connect(function()
		if not Toggles.AutoClosetToggle.Value or tick() - Globals.LastAutoHide <= 0.1 then
			Globals.AutoClosetActive = false
			return
		end
		local Entity = Functions.GetNearestEntity(true, Options.AutoClosetEntityList.Value)
		local EntityNearby = Entity and LocalPlayer:DistanceFromCharacter(Entity.PrimaryPart.Position) <= (EntityDistances[Entity.Name] or 150)
		if Character:GetAttribute("Hiding") == true then
			Globals.AutoClosetActive = false
			Globals.SpectateEntity = nil
			if not EntityNearby then
				RemotesFolder.CamLock:FireServer()
			end
			Globals.LastAutoHide = tick()
			return
		end
		if not Entity then
			Globals.SpectateEntity = nil
			Globals.AutoClosetActive = false
			Globals.LastAutoHide = tick()
			return
		end
		if not EntityNearby then
			Globals.SpectateEntity = nil
			Globals.AutoClosetActive = false
			Globals.LastAutoHide = tick()
			return
		end
		local Closet = Functions.GetNearestHidingSpot()
		if Character:GetAttribute("Hiding") ~= true and Closet then
			local Prompt = Closet:FindFirstChild("HidePrompt")
				or Closet:FindFirstChild("HidingPrompt")
				or Closet:FindFirstChild("HidePrompt", true)
				or Closet:FindFirstChild("HidingPrompt", true)

			if not Prompt then
				for _, Child in Closet:GetDescendants() do
					if (Child:IsA("ProximityPrompt") or Child:IsA("InteractPrompt"))
						and (Child.Name == "HidePrompt" or Child.Name == "HidingPrompt")
					then
						Prompt = Child
						break
					end
				end
			end

			if Prompt then
				Globals.AutoClosetActive = true
				Functions.ForceFirePrompt(Prompt)
			end
		end
		if Character:GetAttribute("Hiding") then
			if Toggles.SpectateEntityToggle.Value and Entity.PrimaryPart then
				Globals.SpectateEntity = Entity
			end
		end
		Globals.LastAutoHide = tick()
	end)

	Globals.LastAutoAnchor = tick()
	Connections.AutoSolveAnchorsConnection = Services.RunService.Heartbeat:Connect(function()
		if not Toggles.AutoSolveAnchors.Value then return end
		if not Globals.MainUI:FindFirstChild("AnchorHintFrame") then return end
		if tick() - Globals.LastAutoAnchor <= 0.1 then return end
		local Anchor = Functions.GetCurrentAnchor()
		if Anchor and LocalPlayer:DistanceFromCharacter(Anchor.PrimaryPart.Position) < Anchor.ActivateEventPrompt.MaxActivationDistance and not Anchor:GetAttribute("Activated") then
			Anchor:WaitForChild("AnchorRemote"):InvokeServer(Globals.MainUI.AnchorHintFrame.Code.Text)
		end
		Globals.LastAutoAnchor = tick()
	end)

	Globals.ManipulateBody = Instance.new("BodyVelocity")
	Globals.ManipulateBody.MaxForce = Vector3.new(9e9, 9e9, 9e9)

	Globals.FlyBody = Instance.new("BodyVelocity")
	Globals.FlyBody.MaxForce = Vector3.new(9e9, 9e9, 9e9)

	Globals.SelfKilled = false
	Globals.ThirdPersonParts = {}
	for _, Object in Character:GetDescendants() do
		if Object:IsA("Accessory") and Object:FindFirstChild("Handle") then
			table.insert(Globals.ThirdPersonParts, Object.Handle)
		end
	end
	table.insert(Globals.ThirdPersonParts, Character:WaitForChild("Head"))

	Globals.LastAnimationCheck = tick()
	Globals.LastCrouchFire = tick()
	Globals.OriginalC1 = Character.LowerTorso.Root.C1

	local RayParams = RaycastParams.new()
	RayParams.FilterType = Enum.RaycastFilterType.Exclude

	local MainFrame = Globals.MainUI:FindFirstChild("MainFrame")
	if MainFrame and MainFrame:FindFirstChild("SurgeVignette") then
		Globals.SurgeFrame = MainFrame.SurgeVignette
		if Toggles.RemoveSurge.Value then
			Globals.SurgeFrame.Name = "SurgeVignette_Disabled"
		end
	end

	Connections.MainHandler = Services.RunService.RenderStepped:Connect(function()
		if Services.Workspace:FindFirstChild("Camera") then
			Camera = Services.Workspace:FindFirstChild("Camera")
		end

		if Toggles.SpeedBoostToggle.Value then
			Humanoid.WalkSpeed = Functions.GetCurrentSpeed() + Options.SpeedBoostSlider.Value
		end

		if Globals.Lagging or (Options.SpeedBoostSlider.Value <= 6 and Options.FlySpeed.Value <= 21) then
			CollisionPartClone.Massless = true
		end

		Globals.IsEyes    = Services.Workspace:FindFirstChild("Eyes") ~= nil or Services.Workspace:FindFirstChild("Lookman") ~= nil
		Globals.IsLookman = Services.Workspace:FindFirstChild("BackdoorLookman") ~= nil

		if Toggles.AmbientToggle.Value then
			Services.TweenService:Create(Services.Lighting, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), { Ambient = Options.AmbientColor.Value }):Play()
		end

		if Main_Game then
			if Toggles.RemoveCameraShake.Value     then Main_Game.csgo = CFrame.new() end
			if Toggles.ViewmodelOffsetToggle.Value then
				Main_Game.tooloffset = Vector3.new(Options.ViewmodelOffsetX.Value, Options.ViewmodelOffsetY.Value, Options.ViewmodelOffsetZ.Value)
			else
				Main_Game.tooloffset = Vector3.zero
			end
		end

		if Globals.SelfKilled and Globals.MainUI:FindFirstChild("Statistics") then
			Globals.MainUI.Statistics.Death.Text = "Died to Ms fent | Doors Hub"
		end

		if Globals.Deathing and Globals.MainUI:FindFirstChild("Statistics") then
			Globals.MainUI.Statistics.Death.Text = "Died to Verity"
		end

		local MainFrame = Globals.MainUI:FindFirstChild("MainFrame")
		if MainFrame then
			local Effects = MainFrame.Healthbar:FindFirstChild("Effects")
			if Effects and Effects:FindFirstChild("Crouching") then
				Effects.Crouching.Visible = Functions.IsCrouching()
			end
		end

		if (Toggles.CrouchSpoof.Value or Toggles.PositionSpoof.Value) and RemotesFolder:FindFirstChild("Crouch") then
			RemotesFolder.Crouch:FireServer(true, true)
		end

		if Floor ~= "Fools" and Floor ~= "OldHotel" and not Camera:FindFirstChild("MinecartRig") then
			RootPart.CanCollide = false
		end

		for _, Part in Character:GetChildren() do
			if Part:IsA("BasePart") then Part.CanCollide = false end
		end

		if LocalPlayer:GetAttribute("Alive") == true then
			Services.SoundService:WaitForChild("Main").Volume = 1
		end

		if Floor == "OldHotel" or Floor == "Fools" then
			local SpoofOffset = Toggles.PositionSpoof.Value and Functions.GetNearestEntity() and 200 or Toggles.FigureGodmode.Value and Functions.GetNearestFigure() and 200 or 0
			Globals.SpoofOffset = SpoofOffset
			Collision.Position = RootPart.Position + Vector3.new(0, SpoofOffset, 0)
			Collision.CanCollide = false
			if Floor == "Fools" then
				Collision.CollisionCrouch.CanCollide = false
				CollisionClone.CollisionCrouch.CanCollide = false
			end
			RootPart.CanCollide = not (Toggles.NoclipToggle.Value or Toggles.VelocityManipulationToggle.Value)
		else
			Collision.CanCollide = false
			if Collision:FindFirstChild("CollisionCrouch") then Collision.CollisionCrouch.CanCollide = false end

			if CollisionClone:FindFirstChild("CollisionCrouch") then
				local IsCrouch = Functions.IsCrouching()
				CollisionClone.CanCollide = not (Toggles.NoclipToggle.Value or Toggles.VelocityManipulationToggle.Value or IsCrouch)
				CollisionClone.CollisionCrouch.CanCollide = not (Toggles.NoclipToggle.Value or Toggles.VelocityManipulationToggle.Value or not IsCrouch)
			else
				RootPart.CanCollide = not (Toggles.NoclipToggle.Value or Toggles.VelocityManipulationToggle.Value)
			end

			local SpoofY = Toggles.PositionSpoof.Value and 2.328 or 0.18
			Collision.Position     = RootPart.Position + Vector3.new(0, SpoofY, 0)
			CollisionPart.Position = RootPart.Position + Vector3.new(0, SpoofY, 0)

			if Collision:FindFirstChild("CollisionCrouch") and CollisionClone:FindFirstChild("CollisionCrouch") then
				local CrouchY = Toggles.PositionSpoof.Value and 1.328 or -0.982
				Collision.CollisionCrouch.Position = RootPart.Position + Vector3.new(0, CrouchY, 0)
				CollisionClone.CollisionCrouch.CollisionGroup = Collision.CollisionCrouch.CollisionGroup
			end
			if CollisionClone:FindFirstChild("CollisionCrouch") then
				CollisionClone.CollisionCrouch.Position = RootPart.Position + Vector3.new(0, Toggles.PositionSpoof.Value and 0.75 or -0.982, 0)
			end
		end

		CollisionClone.CollisionGroup = Collision.CollisionGroup
		CollisionClone.Position = RootPart.Position + Vector3.new(0, Toggles.PositionSpoof.Value and 1.75 or 0.18, 0)

		if Toggles.VelocityManipulationToggle.Value and Options.VelocityManipulationMode.Value == "Velocity" then
			Globals.ManipulateBody.Parent = RootPart
			Globals.ManipulateBody.Velocity = RootPart.CFrame.LookVector * 2.25
		else
			Globals.ManipulateBody.Parent = nil
		end

		if Toggles.VelocityManipulationToggle.Value and Options.VelocityManipulationMode.Value == "Pivot" and Floor ~= "Fools" and Floor ~= "OldHotel" then
			Character:PivotTo(Camera:GetPivot() * CFrame.new(0, 0, 2560))
		end

		if Toggles.FlyToggle.Value then
			Globals.FlyBody.Parent = RootPart
			Globals.FlyBody.Velocity = Functions.GetFlyVelocity() * Options.FlySpeed.Value
		else
			Globals.FlyBody.Parent = nil
		end

		local DoEyesBypass = (Toggles.BypassEyes.Value and Globals.IsEyes) or (Toggles.BypassLookman.Value and Globals.IsLookman)
		if DoEyesBypass then
			if Floor == "Fools" or Floor == "OldHotel" then
				RemotesFolder.MotorReplication:FireServer(0, (Globals.SpoofOffset == 200 and 65 or -65), 0, false)
			else
				RemotesFolder.MotorReplication:FireServer(-650)
			end
		end

		if RemotesFolder:FindFirstChild("Crouch") and tick() - Globals.LastCrouchFire > 0.1 then
			local IsCrouch = Functions.IsCrouching()
			if Toggles.CrouchSpoof.Value or Toggles.PositionSpoof.Value then IsCrouch = true end
			RemotesFolder.Crouch:FireServer(IsCrouch, true)
			Globals.LastCrouchFire = tick()
		end

		if tick() - Globals.LastAnimationCheck > 0.1 then
			local Sliding = false
			for _, Anim in Humanoid:GetPlayingAnimationTracks() do
				if Anim.Name == "Slide" then Sliding = true break end
			end
			Globals.Sliding = Sliding
			Globals.LastAnimationCheck = tick()
		end

		Character:SetAttribute("Sliding", Globals.Sliding)
		if Character:GetAttribute("Crouching") ~= Functions.IsCrouching() then
			Character:SetAttribute("Crouching", Functions.IsCrouching())
		end

		RayParams.FilterDescendantsInstances = { Character }
		local TPOffset = CFrame.new(Options.ThirdPersonOffsetX.Value, Options.ThirdPersonOffsetY.Value, Options.ThirdPersonOffsetZ.Value)
		local Direction = (Camera.CFrame * TPOffset).Position - Camera.CFrame.Position
		local WallResult = Services.Workspace:Spherecast(Camera.CFrame.Position, 0.2, Direction, RayParams)

		if Toggles.ThirdPersonToggle.Value then
			if Toggles.ThirdPersonWallCheck.Value and WallResult and WallResult.Instance.CanCollide then
				local NewPos = Camera.CFrame.Position + Direction.Unit * WallResult.Distance
				Camera.CFrame = CFrame.new(NewPos, NewPos + Camera.CFrame.LookVector)
			else
				Camera.CFrame = Camera.CFrame * TPOffset
			end
		end

		for _, Part in Globals.ThirdPersonParts do
			Part.Transparency = Toggles.ThirdPersonToggle.Value and 0 or 1
			Part.LocalTransparencyModifier = Toggles.ThirdPersonToggle.Value and 0 or 1
		end

		if Globals.SpectateEntity and Toggles.AutoClosetToggle.Value and Toggles.SpectateEntityToggle.Value then
			local Entity = Globals.SpectateEntity

			local CamPosition
			if Options.SpecateEntityMode.Value == "Player to Entity" then
				CamPosition = CFrame.lookAt(Character.Head.Position, Entity.PrimaryPart.Position)
			else
				CamPosition = CFrame.lookAt(Entity.PrimaryPart.Position, Character.Head.Position)
			end

			Camera.CFrame = CamPosition
		end

		if Toggles.FOVToggle.Value then
			if Main_Game then
				task.wait()
				Main_Game.fovtarget = Options.FieldOfView.Value
			else
				Camera.FieldOfView = Options.FieldOfView.Value
			end
		end

		if Toggles.RemoveClosetDelay.Value
			and Humanoid.MoveDirection ~= Vector3.zero
			and (CollisionPart.Anchored or RootPart.Anchored)
			and Character:GetAttribute("AnimatingClient") ~= true
			and Character:GetAttribute("Hiding") == true
		then
			RemotesFolder.CamLock:FireServer()
		end

		local ClosestPlayer = { Distance = math.huge, Object = nil }
		for _, Player in Services.Players:GetPlayers() do
			if Player.Character and Player ~= LocalPlayer then
				local Root = Player.Character:FindFirstChild("HumanoidRootPart")
				if Root then
					local D = (Camera.CFrame.Position - Root.Position).Magnitude
					if D < ClosestPlayer.Distance then
						ClosestPlayer.Distance = D
						ClosestPlayer.Object = Player
					end
				end
			end
		end
		if ClosestPlayer.Object and LocalPlayer:GetAttribute("Alive") ~= true then
			LocalPlayer:SetAttribute("CurrentRoom", ClosestPlayer.Object:GetAttribute("CurrentRoom"))
		end
	end)

	task.wait(1)
	if Toggles.PositionSpoof.Value and Floor ~= "Fools" and Floor ~= "OldHotel" then
		RootPart.CFrame = RootPart.CFrame * CFrame.new(0, -2.346, 0)
		Humanoid.HipHeight = 0.05
		RemotesFolder.Crouch:FireServer(true, true)
	end

	local Jam = Globals.MainUI.Initiator.Main_Game.Health:FindFirstChild("Jam")
	if Jam and Toggles.RemoveJamminMusic.Value then
		Jam.Volume = 0
		Globals.JamMuffle.Enabled = false
	end
end

Functions.HandleHidingTransparency = function(Model)
	local Parts = {}
	for _, Part in Model:GetDescendants() do
		if Part:IsA("BasePart") then
			Part:SetAttribute("Transparency_Old", Part.Transparency)
			table.insert(Parts, Part)
		end
		if Part.Name == "HiddenPlayer" then
			local HideConn = Part:GetPropertyChangedSignal("Value"):Connect(function()
				for _, P in Parts do
					if P:GetAttribute("Transparency_Old") then
						Services.TweenService:Create(P, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
							Transparency = (Part.Value == Character and Toggles.TransparentHidingSpotsToggle.Value)
								and Options.TransparentHidingSpotsSlider.Value
								or P:GetAttribute("Transparency_Old")
						}):Play()
					end
				end
			end)
			table.insert(Connections, HideConn)
			Model.Destroying:Once(function()
				HideConn:Disconnect()
				local Pos = table.find(Connections, HideConn)
				if Pos then table.remove(Connections, Pos) end
			end)
		end
	end
end

Functions.HandleObject = function(Object)
	for _, Room in CurrentRooms:GetChildren() do
		if Object:IsDescendantOf(Room) then
			Object:SetAttribute("ParentRoom", tonumber(Room.Name))
			break
		end
		task.wait()
	end

	if Object.Parent == CurrentRooms then
		local FiredampVal = Object:GetAttribute("Firedamp")
		Object:SetAttribute("Firedamp_Old", FiredampVal ~= nil and FiredampVal or false)
		if Toggles.DisableFiredampEffect.Value then
			Object:SetAttribute("Firedamp", false)
		end
	end

	local Name = Object.Name

	if Name == "KeyObtain" then
		task.spawn(function()
			task.wait(0.5)
			if Object.Parent then
				if Toggles.ObjectiveESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Door Key", Color = Options.ObjectiveESPColor.Value }, true) end
				table.insert(Objects.Objectives, Object)
			end
		end)
	elseif Name == "ElectricalKeyObtain" then
		task.spawn(function()
			task.wait(0.5)
			if Object.Parent then
				if Toggles.ObjectiveESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Electrical Key", Color = Options.ObjectiveESPColor.Value }, true) end
				table.insert(Objects.Objectives, Object)
			end
		end)
	elseif Name == "TimerLever" then
		task.spawn(function()
			task.wait(0.5)
			if Object.Parent then
				Object:SetAttribute("AddTime", Object.TakeTimer.TextLabel.Text == "01:00" and 60 or 30)
				if Toggles.ObjectiveESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Time Lever [+" .. Object:GetAttribute("AddTime") .. "s]", Color = Options.ObjectiveESPColor.Value }, true) end
				Object:WaitForChild("Main").SoundToPlay.Played:Once(function()
					Functions.RemoveESP(Object)
					Functions.BlacklistESP(Object)
				end)
				table.insert(Objects.Objectives, Object)
			end
		end)
	elseif Name == "DepotHalloween" then
		if Toggles.ObjectiveESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Candy Magic", Color = Options.ObjectiveESPColor.Value }, true) end
		table.insert(Objects.Objectives, Object)
	elseif Name == "StairwellLockpickDoor" then
		if Toggles.MiscESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Garage Door", Color = Options.MiscESPColor.Value }, true) end
		table.insert(Objects.Misc, Object)
	elseif Name == "Mirror" then
		if Toggles.MiscESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Mirror", Color = Options.MiscESPColor.Value }, true) end
		table.insert(Objects.Misc, Object)
	elseif Name == "StairwellFireAlarm" then
		if Toggles.MiscESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Fire Alarm", Color = Options.MiscESPColor.Value }, true) end
		table.insert(Objects.Misc, Object)
	elseif Name == "ShoppingCart" then
		if Toggles.MiscESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Shopping Cart", Color = Options.MiscESPColor.Value }, true) end
		table.insert(Objects.Misc, Object)
	elseif Name == "StairwellScrapper" then
		if Toggles.ObjectiveESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Scrapper", Color = Options.ObjectiveESPColor.Value }, true) end
		table.insert(Objects.Objectives, Object)
	elseif Name == "ArchivesPackageDeposit" then
		if Toggles.ObjectiveESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Package Deposit", Color = Options.ObjectiveESPColor.Value }, true) end
		table.insert(Objects.Objectives, Object)
	elseif Name == "Cellar" then
		if Toggles.ObjectiveESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Cellar", Color = Options.ObjectiveESPColor.Value }, true) end
		table.insert(Objects.Objectives, Object)
	elseif Name == "ArchivesFihTank" then
		if Toggles.MiscESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Fih Tank", Color = Options.MiscESPColor.Value }, true) end
		table.insert(Objects.Misc, Object)
	elseif Name == "LiveHintBook" then
		if Toggles.ObjectiveESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Hint Book", Color = Options.ObjectiveESPColor.Value }, true) end
		table.insert(Objects.Objectives, Object)
	elseif Name == "LiveBreakerPolePickup" then
		if Toggles.ObjectiveESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Fuse Breaker", Color = Options.ObjectiveESPColor.Value }, true) end
		for _, Child in Object:GetChildren() do
			if Child.Name == "ActivateEventPrompt" and (Child.MaxActivationDistance == 5 or Child:GetAttribute("MaxActivationDistance_Old") == 5) then
				Child:Destroy()
			end
		end
		table.insert(Objects.Objectives, Object)
	elseif Name == "LibraryHintPaper" or Name == "PickupItem" then
		if Toggles.ObjectiveESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Hint Paper", Color = Options.ObjectiveESPColor.Value }, true) end
		table.insert(Objects.Objectives, Object)
	elseif Name == "MinesAnchor" then
		if Toggles.ObjectiveESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Anchor [" .. Object:WaitForChild("Sign").TextLabel.Text .. "]", Color = Options.ObjectiveESPColor.Value }, true) end
		Object:GetAttributeChangedSignal("Activated"):Once(function()
			Functions.RemoveESP(Object)
			Functions.BlacklistESP(Object)
		end)
		table.insert(Objects.Objectives, Object)
	elseif Name == "WaterPump" then
		if Toggles.ObjectiveESPToggle.Value then Functions.AddESP({ Object = Object:WaitForChild("Wheel"), Text = "Water Pump", Color = Options.ObjectiveESPColor.Value }, true) end
		Object:WaitForChild("Wheel").Sound.Played:Once(function()
			Object:SetAttribute("Abysall_Completed", true)

			Functions.RemoveESP(Object.Wheel)
			Functions.BlacklistESP(Object.Wheel)
		end)
		table.insert(Objects.Objectives, Object)
	elseif Name == "CringlePresent" then
		if Toggles.ObjectiveESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Present", Color = Options.ObjectiveESPColor.Value }, true) end
		Object:WaitForChild("ToolProp").Highlight:Destroy()
		table.insert(Objects.Objectives, Object)
	elseif Name == "LeverForGate" then
		if Toggles.ObjectiveESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Gate Lever", Color = Options.ObjectiveESPColor.Value }, true) end
		Object:WaitForChild("Main").SoundToPlay.Played:Once(function()
			Functions.RemoveESP(Object)
			Functions.BlacklistESP(Object)
		end)
		table.insert(Objects.Objectives, Object)
	elseif Name == "VineGuillotine" then
		if Toggles.ObjectiveESPToggle.Value then Functions.AddESP({ Object = Object.Lever, Text = "Vine Lever", Color = Options.ObjectiveESPColor.Value }, true) end
		Object.Lever:WaitForChild("ActivateEventPrompt"):GetAttributeChangedSignal("Interactions"):Once(function()
			Functions.RemoveESP(Object)
			Functions.BlacklistESP(Object)
		end)
		table.insert(Objects.Objectives, Object)
	elseif Name == "MandrakeLive" then
		if Toggles.ObjectiveESPToggle.Value and Options.EntityESPOptions.Value["Mandrake Hole"] then Functions.AddESP({ Object = Object.Hole, Text = "Mandrake Hole", Color = Options.EntityESPColor.Value }, true) end
		table.insert(Objects.Entities, Object.Hole)
	elseif Name == "MinesGenerator" then
		task.spawn(function()
			task.wait(0.75)
			if Object.Parent then
				if Toggles.ObjectiveESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Generator", Color = Options.ObjectiveESPColor.Value }, true) end
				Object:WaitForChild("Lever").Sound.Played:Once(function()
					Functions.RemoveESP(Object)
					Functions.BlacklistESP(Object)
				end)
				table.insert(Objects.Objectives, Object)
			end
		end)
	elseif Name == "FuseObtain" then
		if Toggles.ObjectiveESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Generator Fuse", Color = Options.ObjectiveESPColor.Value }, true) end
		Object:WaitForChild("Hitbox").FuseModel:GetPropertyChangedSignal("LocalTransparencyModifier"):Once(function()
			Functions.RemoveESP(Object)
			Functions.BlacklistESP(Object)
		end)
		table.insert(Objects.Objectives, Object)
	elseif Name == "MinesGateButton" then
		if Toggles.ObjectiveESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Gate Button", Color = Options.ObjectiveESPColor.Value }, true) end
		Object.Parent:WaitForChild("MinesGate").Main.SoundOpen.Played:Once(function()
			Functions.RemoveESP(Object)
			Functions.BlacklistESP(Object)
		end)
		table.insert(Objects.Objectives, Object)
	elseif Name == "GardenGateButton" then
		if Toggles.ObjectiveESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Gate Button", Color = Options.ObjectiveESPColor.Value }, true) end
		Object.Parent:WaitForChild("GardenGate").Collision.Sound.Played:Once(function()
			Functions.RemoveESP(Object)
			Functions.BlacklistESP(Object)
		end)
		table.insert(Objects.Objectives, Object)
	elseif Name == "Ladder" then
		if Toggles.LadderESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Ladder", Color = Options.LadderESPColor.Value }, true) end
		table.insert(Objects.Ladders, Object)
	elseif Name == "Door" and Object.Parent and tonumber(Object.Parent.Name) then
		local DoorParts = {}
		for _, Child in Object:GetChildren() do
			if Child.Name == "Door" and Child:IsA("BasePart") then
				table.insert(DoorParts, Child)
			end
		end

		if #DoorParts == 2 then
			local HighlightModel = Instance.new("Model", Object)
			HighlightModel.Name = "HighlightModel"
			Instance.new("Humanoid", HighlightModel).Name = "HighlightHumanoid"
			HighlightModel:SetAttribute("ParentRoom", tonumber(Object.Parent.Name))

			for _, DoorPart in DoorParts do
				local HP = Instance.new("Part", HighlightModel)
				HP.Transparency = 0.999
				HP.Size = DoorPart.Size
				HP.CanCollide = false
				HP.CFrame = DoorPart.CFrame
				HP.Name = "HighlightPart"
				HP.Material = Enum.Material.Plastic
				HP:SetAttribute("ParentRoom", tonumber(Object.Parent.Name))
				local W = Instance.new("WeldConstraint", HP)
				W.Part0 = HP W.Part1 = DoorPart W.Enabled = true
			end
			table.insert(Objects.Doors, HighlightModel)
			if Toggles.DoorESPToggle.Value then Functions.AddESP({ Object = HighlightModel, Text = "Door " .. Functions.GetDoorNumber(Object), Color = Options.DoorESPColor.Value }, true) end
		else
			local Root = Object:WaitForChild("Door", 9e9)
			local HP = Instance.new("Part", Object)
			HP.Transparency = 0.999
			HP.Size = Root.Size
			HP.CanCollide = false
			HP.CFrame = Root.CFrame
			HP.Name = "HighlightPart"
			HP.Material = Enum.Material.Plastic
			HP:SetAttribute("ParentRoom", tonumber(Object.Parent.Name))
			local W = Instance.new("WeldConstraint", HP)
			W.Part0 = HP W.Part1 = Root W.Enabled = true
			Instance.new("Humanoid", Object).Name = "HighlightHumanoid"
			table.insert(Objects.Doors, HP)
			if Toggles.DoorESPToggle.Value then Functions.AddESP({ Object = HP, Text = "Door " .. Functions.GetDoorNumber(Object), Color = Options.DoorESPColor.Value }, true) end
		end

		local LastDoorFire = tick()
		local DoorConn = Services.RunService.Heartbeat:Connect(function()
			if Object:FindFirstChild("Door") and Object:FindFirstChild("ClientOpen") then
				if LocalPlayer:DistanceFromCharacter(Object.Door.Position) < 75
					and tick() - LastDoorFire > 0.1
					and (Toggles.DoorReachToggle.Value or Functions.GetMinecart())
				then
					Object.ClientOpen:FireServer()
					LastDoorFire = tick()
				end
			end
		end)
		Object.Destroying:Once(function()
			DoorConn:Disconnect()
		end)
		Object:WaitForChild("Door"):WaitForChild("Open").Played:Once(function()
			DoorConn:Disconnect()
		end)
		table.insert(Connections, DoorConn)

	elseif Name == "PathLights" then
		local ObjectsToHighlight = {}
		local PLConn = Object.ChildAdded:Connect(function(Child)
			table.insert(ObjectsToHighlight, Child)
		end)
		for _, Child in Object:GetChildren() do
			table.insert(ObjectsToHighlight, Child)
		end

		local function CreateSeekNode(Light)
			if Light.Name ~= "SeekGuidingLight" or Light:GetAttribute("Highlighted") then return end
			Light:SetAttribute("Highlighted", true)

			local NewNode = Instance.new("Part")
			NewNode.Size = Vector3.one
			NewNode.Transparency = 1
			NewNode.Parent = Globals.SeekNodesFolder
			NewNode.Anchored = true
			NewNode.CFrame = Light.CFrame
			NewNode.CanCollide = false
			NewNode.Name = "SeekLightNode"

			local PrevNode2 = PreviousNode or NewNode
			PreviousNode = NewNode

			local Beam = Instance.new("Beam")
			Beam.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Options.ShowSeekPathColor.Value), ColorSequenceKeypoint.new(1, Options.ShowSeekPathColor.Value) })
			Beam.FaceCamera = true
			Beam.Width0 = 0.2
			Beam.Width1 = 0.2
			Beam.Brightness = 10
			Beam.LightInfluence = 0
			Beam.LightEmission = 0
			Beam.Enabled = true
			local Vis = Toggles.ShowSeekPathToggle.Value and 0 or 1
			Beam.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, Vis), NumberSequenceKeypoint.new(1, Vis) })
			Beam.Parent = Globals.SeekNodesFolder
			local A0 = Instance.new("Attachment", NewNode)
			local A1 = Instance.new("Attachment", PrevNode2)
			Beam.Attachment0 = A0
			Beam.Attachment1 = A1
			table.insert(Objects.SeekHighlights, Beam)
			Light:Destroy()
		end

		task.spawn(function()
			while task.wait() do
				local Light = table.remove(ObjectsToHighlight, 1)
				if Light then CreateSeekNode(Light) end
			end
		end)

		table.insert(Connections, PLConn)
		table.insert(Objects.PathLights, Object)
		Object.Destroying:Once(function() PLConn:Disconnect() end)
	elseif Name == "SeekMovingNewClone" then
		local Connection = Object.Destroying:Connect(function()
			for _, Folder in pairs(Objects.PathLights) do
				Folder:ClearAllChildren()
			end
			Globals.SeekNodesFolder:ClearAllChildren()
		end)
		table.insert(Connections, Connection)
	elseif Name == "Bridge" then
		for _, Child in Object:GetChildren() do
			if Child.Name == "PlayerBarrier" and Child.Size.Y == 2.75 and (Child.Rotation.X == 0 or Child.Rotation.X == 180) then
				local NewBridge = Child:Clone()
				NewBridge.CFrame = NewBridge.CFrame * CFrame.new(0, 0, -5)
				NewBridge.Name = Abysall.ESPLibrary:GenerateRandomString()
				NewBridge.Size = Vector3.new(NewBridge.Size.X, NewBridge.Size.Y, 11)
				NewBridge.Parent = Object
				NewBridge.CanCollide = Toggles.BypassSeekObstructions.Value
				NewBridge.Color = Color3.fromRGB(0, 255, 255)
				NewBridge.Transparency = Toggles.BypassSeekObstructions.Value and 0 or 1
				NewBridge.Material = Enum.Material.ForceField
				table.insert(Objects.SeekBridges, NewBridge)
			end
			task.wait()
		end
    elseif Name == "MinecartRig" then
        Globals.Minecart = Object
	elseif Name == "RunnerNodes" then
		local function IsBehind(Part1, Part2)
			local P1 = (Part1.CFrame + Part1.CFrame.LookVector).Position
			local P2 = (Part1.CFrame + Part1.CFrame.LookVector * -1).Position
			return (P1 - Part2.Position).Magnitude > (P2 - Part2.Position).Magnitude
		end
		local function GetDirection(Part1, Part2)
			local RightDist = Part1.CFrame.RightVector:Dot(Part1.Position - Part2.Position)
			if RightDist > 0.5    then return IsBehind(Part1, Part2) and "Right" or "Left" end
			if RightDist < -0.5   then return IsBehind(Part1, Part2) and "Left" or "Right" end
			return "Straight"
		end
		local function GetClosestNode(Node)
			local Best, BestDist = nil, math.huge
			local NodeID2 = tonumber(Node.Name:split("MinecartNode")[2])
			for _, OtherNode in Object:GetChildren() do
				local OtherID = tonumber(OtherNode.Name:split("MinecartNode")[2])
				if OtherNode ~= Node and OtherID and NodeID2 and OtherID > NodeID2 then
					local D = (Node.Position - OtherNode.Position).Magnitude
					if D < BestDist and OtherNode:GetAttribute("DistanceBlacklist") ~= true then
						BestDist = D Best = OtherNode
					end
				end
			end
			return Best
		end

		for _, Node in Object:GetChildren() do
			local NodeID = tonumber(Node.Name:split("MinecartNode")[2])
			if Node:GetAttribute("DeathType") then Node:SetAttribute("DistanceBlacklist", true) end
			for I = 1, 20 do
				local NextNode = NodeID and Object:FindFirstChild("MinecartNode" .. NodeID + I)
				if NextNode and NextNode:GetAttribute("DeathType") ~= nil then
					Node:SetAttribute("DistanceBlacklist", true)
				end
			end
			local PrevNode3 = NodeID and Object:FindFirstChild("MinecartNode" .. NodeID - 1)
			if PrevNode3 and PrevNode3:GetAttribute("ForceConnect") then
				Node:SetAttribute("DistanceBlacklist", nil)
			end
			task.wait()
		end

		for _, Node in Object:GetChildren() do
			if Node:GetAttribute("ForceConnect") then
				local NextNode = GetClosestNode(Node)
				if NextNode then
					Node:SetAttribute("Turn", GetDirection(Node, NextNode))
					table.insert(Objects.SeekNodes, Node)
				end
			end
			task.wait()
		end

	elseif Name == "EyestalkEndCutscene" then
		Object.Name = "_EyestalkEndCutscene"
	elseif Name == "DuckBoard" then
		table.insert(Objects.SeekDuckBoards, Object)
	elseif HidingSpotLabels[Name] or string.find(string.lower(Name), "hidingspot") then
		local Label = HidingSpotLabels[Name] or (string.find(string.lower(Name), "hidingspot") and "Hiding Spot" or nil)
		if Label and Toggles.HidingSpotESPToggle.Value then Functions.AddESP({ Object = Object, Text = Label, Color = Options.HidingSpotESPColor.Value }, true) end
		Functions.HandleHidingTransparency(Object)
		table.insert(Objects.HidingSpots, Object)
	elseif Object:FindFirstChild("HidingPrompt") or Object:FindFirstChild("HidePrompt") then
		Functions.HandleHidingTransparency(Object)
		table.insert(Objects.HidingSpots, Object)
	elseif Name == "Lava" then
		if Toggles.BypassKillbricks.Value then Object.CanTouch = false end
		table.insert(Objects.Obstructions, Object)
	elseif Name == "ScaryWall" then
		for _, Part in Object:GetDescendants() do
			if Part:IsA("BasePart") then
				Part.CanTouch = not Toggles.BypassSeekingWall.Value
				Part.CanCollide = not Toggles.BypassSeekingWall.Value

                local Connection1 = Part:GetPropertyChangedSignal("CanTouch"):Connect(function()
                    if Part.CanTouch == Toggles.BypassSeekingWall.Value then
                        Part.CanTouch = not Toggles.BypassSeekingWall.Value
                    end
                end)
                local Connection2 = Part:GetPropertyChangedSignal("CanCollide"):Connect(function()
                    if Part.CanCollide == Toggles.BypassSeekingWall.Value then
                        Part.CanCollide = not Toggles.BypassSeekingWall.Value
                    end
                end)

                table.insert(Connections, Connection1)
                table.insert(Connections, Connection2)
            end
		end
		table.insert(Objects.Obstructions, Object)
	elseif Name == "ChestBox" or Name == "ChestBoxLocked" then
		if Toggles.ChestESPToggle.Value then Functions.AddESP({ Object = Object, Text = Object:GetAttribute("Locked") and "Locked Chest" or "Chest", Color = Options.ChestESPColor.Value }, true) end
		table.insert(Objects.Chests, Object)
	elseif Name == "Toolbox" or Name == "Toolbox_Locked" then
		if Toggles.ChestESPToggle.Value then Functions.AddESP({ Object = Object, Text = Object:GetAttribute("Locked") and "Locked Toolbox" or "Toolbox", Color = Options.ChestESPColor.Value }, true) end
		table.insert(Objects.Chests, Object)
	elseif Name == "Chest_Vine" then
		if Toggles.ChestESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Vine Chest", Color = Options.ChestESPColor.Value }, true) end
		table.insert(Objects.Chests, Object)
	elseif Name == "Toolshed_Small" then
		if Toggles.ChestESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Toolshed", Color = Options.ChestESPColor.Value }, true) end
		table.insert(Objects.Chests, Object)
	elseif Name == "Locker_Small_Locked" then
		if Toggles.ChestESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Locked Item Locker", Color = Options.ChestESPColor.Value }, true) end
		table.insert(Objects.Chests, Object)
	elseif Name == "MouseHole" then
		if Toggles.ChestESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Mouse", Color = Options.ChestESPColor.Value }, true) end
		table.insert(Objects.Chests, Object)
	elseif ItemNames[Name] and Object:FindFirstChild("ModulePrompt") then
		if Toggles.ItemESPToggle.Value then Functions.AddESP({ Object = Object, Text = ItemNames[Name], Color = Options.ItemESPColor.Value }, Object:GetAttribute("ParentRoom") ~= nil) end
		if Name == "LotusHolder" or Name == "LotusPetalPickup" then
			Object.Handle:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(function()
				Abysall.ESPLibrary:RemoveESP(Object)
				Functions.BlacklistESP(Object)
			end)
		end

		if Toggles.NotifyItemsToggle.Value and Options.NotifyItemList.Value[ItemNames[Name]] and Object.Parent.Name ~= "Drops" then
			if Toggles.NotifyItemsShowDistance.Value then
				Functions.Notify({ Title = "Item '" .. ItemNames[Name] .. "' has spawned.", Body = "It is '" .. math.round(LocalPlayer:DistanceFromCharacter(Object.PrimaryPart.Position)) .. "' studs away from you." })
			else
				Functions.Notify({ Title = "Item '" .. ItemNames[Name] .. "' has spawned."})
			end
		end

		table.insert(Objects.Items, Object)
	elseif Name == "Green_Herb" then
		if Toggles.ItemESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Green Herb", Color = Options.ItemESPColor.Value }, true) end
		table.insert(Objects.Items, Object)
	elseif Name == "GoldPile" and Object:GetAttribute("GoldValue") then
		if Toggles.CurrencyESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Gold Pile [" .. Object:GetAttribute("GoldValue") .. "]", Color = Options.CurrencyESPColor.Value }, true) end
		table.insert(Objects.Currency, Object)
	elseif Name == "StardustPickup" then
		if Toggles.CurrencyESPToggle.Value then Functions.AddESP({ Object = Object, Text = "Stardust Pile", Color = Options.CurrencyESPColor.Value }, true) end
		table.insert(Objects.Currency, Object)
	elseif Name == "GiggleCeiling" then
		if Toggles.EntityESPToggle.Value and Options.EntityESPOptions.Value["Giggle"] then Functions.AddESP({ Object = Object, Text = "Giggle", Color = Options.EntityESPColor.Value }, true) end
		if Toggles.BypassGiggle.Value then Object:WaitForChild("Hitbox").CanTouch = false end
		table.insert(Objects.Entities, Object)
	elseif Name == "GloomPile" then
		if Toggles.BypassGloombatEggs.Value then
			for _, Part in Object:GetDescendants() do
				if Part:IsA("BasePart") then Part.CanTouch = false
				end
			end
		end
		local Connection = Object.DescendantAdded:Connect(function(Part)
			if Part:IsA("BasePart") then Part.CanTouch = false end
		end)

		if Toggles.EntityESPToggle.Value and Options.EntityESPOptions.Value["Gloombat Eggs"] then
			Functions.AddESP({ Object = Object, Text = "Gloombat Eggs", Color = Options.EntityESPColor.Value })
		end

		table.insert(Connections, Connection)
		table.insert(Objects.Entities, Object)
	elseif Name == "TriggerEventCollision" and Functions.CheckCompatability({"firetouchinterest"}) then
		if (Floor == "Fools" or Floor == "OldHotel") and Toggles.RemoveSeekTrigger.Value then
			task.spawn(function()
				while Object:IsDescendantOf(game) do
					for _, Part in Object:GetChildren() do
						if Part:IsA("BasePart") then
							Abysall.Environment.firetouchinterest(RootPart, Part, 0)
							task.wait()
							Abysall.Environment.firetouchinterest(RootPart, Part, 1)
						end
					end
					task.wait()
				end
			end)
		end
		table.insert(Objects.EventTriggers, Object)
	elseif Name == "DoorFake" or Name == "FakeDoor" then
		if Object.Parent and Object:FindFirstChild("Hidden") then
			if Toggles.BypassDupe.Value then
				Object:WaitForChild("Hidden").CanTouch = false
				local Lock = Object:FindFirstChild("Lock")
				if Lock and Lock:FindFirstChild("UnlockPrompt") then Lock.UnlockPrompt.Enabled = false end
			end
			if Toggles.EntityESPToggle.Value and Options.EntityESPOptions.Value["Dupe"] then
				Functions.AddESP({ Object = Object, Text = "Dupe", Color = Options.EntityESPColor.Value }, true)
			end
			table.insert(Objects.Entities, Object)
		end
	elseif Name == "SideroomSpace" then
		if Toggles.BypassVacuum.Value then
			Object:WaitForChild("Collision").CanCollide = true
			Object:WaitForChild("Collision").CanTouch = false
		end
		table.insert(Objects.Entities, Object)
	elseif Name == "Snare" then
		if Toggles.EntityESPToggle.Value and Options.EntityESPOptions.Value["Snare"] then Functions.AddESP({ Object = Object, Text = "Snare", Color = Options.EntityESPColor.Value }, true) end
		for _, Part in Object:GetDescendants() do
			if Part:IsA("BasePart") then Part.CanTouch = not Toggles.BypassSnare.Value end
		end
		local Connection = Object.DescendantAdded:Connect(function(Part)
			if Part:IsA("BasePart") then Part.CanTouch = not Toggles.BypassSnare.Value end
		end)
		table.insert(Connections, Connection)
		table.insert(Objects.Entities, Object)

		if Object:FindFirstChild("Snare") then
			Object:WaitForChild("Snare"):WaitForChild("Roots").Transparency = 1
			Object:WaitForChild("Snare"):WaitForChild("SnareBase").Transparency = 1
		end
		if Object:FindFirstChild("Void") then
			Object.Void.Transparency = 0
			Object.Void.Color = Color3.fromRGB(76, 67, 55)
		end
	elseif Name == "Seek_Arm" or Name == "ChandelierObstruction" then
		for _, Part in Object:GetDescendants() do
			if Part:IsA("BasePart") then
				Part.CanTouch = not Toggles.BypassSeekObstructions.Value
				table.insert(Objects.SeekObstructions, Part)
			end
		end
	elseif Name == "SeekFloodline" then
		Object.CanCollide = Toggles.BypassSeekObstructions.Value
		local FloodConn = Object:GetPropertyChangedSignal("CanCollide"):Connect(function()
			if Object.CanCollide ~= Toggles.BypassSeekObstructions.Value then
				Object.CanCollide = Toggles.BypassSeekObstructions.Value
			end
		end)
		Object.Destroying:Once(function() FloodConn:Disconnect() end)
		table.insert(Objects.SeekObstructions, Object)
	elseif Object:GetAttribute("RawName") and Object:GetAttribute("RawName"):find("Halt") or Object:GetAttribute("Shade") == true then
		if Toggles.NotifyEntities.Value and Options.EntityList.Value["Halt"] then
			Functions.Notify({ Title = "Entity 'Halt' will spawn in the next room.", Image = EntityIcons["Halt"] })
			if Toggles.EntityChatToggle.Value then Functions.SendChat("Halt next room!") end
		end
		local HaltLogConn
		HaltLogConn = Services.LogService.MessageOut:Connect(function(Message)
			if Message == "client teleporting" then
				if Globals.AnticheatDisabled then
					Globals.AnticheatDisabled = false
					Functions.Notify({ Title = "The anticheat has been re-enabled.", Body = "Interact with a ladder to disable it again." })
				end
				HaltLogConn:Disconnect()
			end
		end)
	elseif Name == "BananaPeel" then
		if Toggles.BypassBanana.Value then Object.CanTouch = false end
		table.insert(Objects.Entities, Object)
	elseif Name == "JeffTheKiller" then
		if Toggles.BypassJeff.Value then
			for _, Part in Object:GetDescendants() do
				if Part:IsA("BasePart") then Part.CanCollide = false Part.CanTouch = false end
			end
			Object:WaitForChild("Humanoid").Health = 0
		end
	elseif Name == "GrumbleRig" then
		if Toggles.EntityESPToggle.Value and Options.EntityESPOptions.Value["Grumble"] then Functions.AddESP({ Object = Object, Text = "Grumble", Color = Options.EntityESPColor.Value }, true) end
		table.insert(Objects.Entities, Object)
	elseif Name == "LiveEntityBramble" then
		if Toggles.EntityESPToggle.Value and Options.EntityESPOptions.Value["Bramble"] then Functions.AddESP({ Object = Object, Text = "Bramble", Color = Options.EntityESPColor.Value }, true) end
		table.insert(Objects.Entities, Object)
	elseif Name == "Groundskeeper" then
		if Toggles.EntityESPToggle.Value and Options.EntityESPOptions.Value["Groundskeeper"] then Functions.AddESP({ Object = Object, Text = "Groundskeeper", Color = Options.EntityESPColor.Value }, true) end
		if Toggles.NotifyEntities.Value and Options.EntityList.Value["Groundskeeper"] then
			local ED = Entities["Groundskeeper"]
			Functions.Notify({ Title = ED.NotifyMessage.Title, Body = ED.NotifyMessage.Body, Image = EntityIcons["Groundskeeper"] })
		end
		table.insert(Objects.Entities, Object)
	elseif Name == "Figure" or Name == "FigureRig" or Name == "FigureRagdoll" then
		for _, Part in Object:GetDescendants() do
			if Part:IsA("BasePart") then
				Part.CanTouch = false
			end
		end
		if Toggles.EntityESPToggle.Value and Options.EntityESPOptions.Value["Figure"] then Functions.AddESP({ Object = Object, Text = "Figure", Color = Options.EntityESPColor.Value }, true) end
		table.insert(Objects.Entities, Object)
		if Toggles.RemoveFigure.Value and Functions.CheckCompatability({"isnetworkowner"}) then
			if Floor == "Mines" then
				for _, Part in Object:GetDescendants() do
					if Part:IsA("BasePart") then
						task.spawn(function()
							if Abysall.Environment.isnetworkowner(Part) then
								Part.Position = Vector3.new(-49999, -49999, -49999)
							end
						end)
					end
				end
			elseif Floor == "OldHotel" or Floor == "Fools" then
				CurrentRooms.ChildAdded:Wait()
				for _, Part in Object:GetDescendants() do
					if Part:IsA("BasePart") then
						Part.CanCollide = false
						task.spawn(function()
							while Abysall.Environment.isnetworkowner(Part) do
								Part.Position = Vector3.new(math.random(-29999,29999), math.random(-29999,29999), math.random(-29999,29999))
								task.wait()
							end
						end)
					end
				end
			end
		end
	elseif (Name == "ThingToOpen" or Name == "MovingDoor") and (Floor == "Fools" or Floor == "OldHotel")
		or Name == "Wax_Door" and Floor == "Fools"
	then
		Object:SetAttribute("OriginalPosition", Object:GetPivot())
		local ToggleMap = { ThingToOpen = "RemoveBasementGate", MovingDoor = "RemovePaintingsDoor", Wax_Door = "RemoveSkeletonDoor" }
		if ToggleMap[Name] and Toggles[ToggleMap[Name]].Value then
			Object:PivotTo(CFrame.new(-10000, -10000, -10000))
		end
		table.insert(Objects.Obstructions, Object)
	elseif Name == "ElevatorBreaker" then
		if Toggles.AutoBreakerBox.Value and not Globals.BreakerBoxNotified then
			Functions.Notify({ Title = "Interact with the breaker box.", Body = "It will be automatically solved." })
			Globals.BreakerBoxNotified = true
		end
		Connections.BreakerConnection = Object:WaitForChild("SurfaceGui").Frame.Code:GetPropertyChangedSignal("Text"):Connect(function()
			if Toggles.AutoBreakerBox.Value then
				if not Globals.BreakerBoxStartNotified and (Floor == "Fools" or Floor == "OldHotel") then
					Functions.Notify({ Title = "Attempting to solve the breaker box.", Body = "Please wait." })
					Globals.BreakerBoxStartNotified = true
				end
				RemotesFolder.EBF:FireServer()
			end
			Globals.BreakerBoxInteracted = true
		end)
	elseif Name == "ElevatorCar" then
		local ElevConn = Object.DescendantAdded:Connect(function(Desc)
			if Toggles.AutoBreakerBox.Value and Desc.Name == "TouchInterest" and not Globals.BreakerBoxFinishedNotified then
				Functions.Notify({ Title = "Successfully solved the breaker box.", Body = "Try going to the elevator!" })
				Globals.BreakerBoxFinishedNotified = true
			end
		end)
		Object.Destroying:Once(function() ElevConn:Disconnect() end)
	elseif Object.ClassName == "ProximityPrompt" and not Object:GetAttribute("FakePrompt") then
		if Object:HasTag("DisableWhenEnabledOnClient") then Object:RemoveTag("DisableWhenEnabledOnClient") end

		Object:SetAttribute("HoldDuration_Old", Object.HoldDuration)
		Object:SetAttribute("RequiresLineOfSight_Old", Object.RequiresLineOfSight)
		Object:SetAttribute("MaxActivationDistance_Old", Object.MaxActivationDistance)

		if Toggles.InstantPrompts.Value    then Object.HoldDuration = 0 end
		if Toggles.PromptClip.Value        then Object.RequiresLineOfSight = false end
		Object.MaxActivationDistance = Object:GetAttribute("MaxActivationDistance_Old") * Options.PromptReachSlider.Value

		local LockPromptNames = { UnlockPrompt=true, SkullPrompt=true, LockPrompt=true, ThingToEnable=true, FusesPrompt=true }

		if Functions.CheckCompatability({"fireproximityprompt"}) and Floor ~= "OldHotel" and Floor ~= "Fools" then
			local IsLockPrompt = LockPromptNames[Object.Name] and Object.Parent.Name ~= "Handle" and Object.Parent.Name ~= "LockHolder"
				or (Object.Parent and Object.Parent:GetAttribute("Locked") == true)
				or (Object.Parent and Object.Parent.Parent and Object.Parent.Parent.Name == "Locker_Small_Locked" and Object.Name == "ActivateEventPrompt")

			if IsLockPrompt then
				local FakePrompt = Object:Clone()
				FakePrompt:SetAttribute("FakePrompt", true)
				task.wait()
				FakePrompt.Parent = Object.Parent

				FakePrompt:SetAttribute("HoldDuration_Old", Object:GetAttribute("HoldDuration_Old"))
				FakePrompt:SetAttribute("RequiresLineOfSight_Old", Object:GetAttribute("RequiresLineOfSight_Old"))
				FakePrompt:SetAttribute("MaxActivationDistance_Old", Object:GetAttribute("MaxActivationDistance_Old"))

				FakePrompt.HoldDuration = Object.HoldDuration
				FakePrompt.RequiresLineOfSight = Object.RequiresLineOfSight
				FakePrompt.MaxActivationDistance = Object.MaxActivationDistance

				if Toggles.InstantPrompts.Value    then FakePrompt.HoldDuration = 0 end
				if Toggles.PromptClip.Value        then FakePrompt.RequiresLineOfSight = false end
				FakePrompt.MaxActivationDistance = FakePrompt:GetAttribute("MaxActivationDistance_Old") * Options.PromptReachSlider.Value

				FakePrompts[FakePrompt] = Object
				pcall(function() Object.Parent = Globals.PromptContainer end)

				local FPEnabledConn = Object:GetPropertyChangedSignal("Enabled"):Connect(function()
					FakePrompt.Enabled = Object.Enabled
				end)
				Object:GetPropertyChangedSignal("ActionText"):Once(function()
					Object.Parent = FakePrompt.Parent
					FakePrompt:Destroy()
					FPEnabledConn:Disconnect()
				end)
				Object.Destroying:Once(function()
					FakePrompt:Destroy()
					FPEnabledConn:Disconnect()
				end)
				table.insert(Connections, FPEnabledConn)
				table.insert(Objects.Prompts, FakePrompt)

				FakePrompt.Enabled = false
				task.wait()
				FakePrompt.Enabled = Object.Enabled
			end
		end
		table.insert(Objects.Prompts, Object)
	elseif Name == "Padlock" then
		local PadlockConn = Services.RunService.Heartbeat:Connect(function()
			if Object.PrimaryPart then
				local Distance = LocalPlayer:DistanceFromCharacter(Object.PrimaryPart.Position)
				if Toggles.AutoUnlockPadlockToggle.Value then
					local Code = Functions.GetLibraryCode()
					if Code and tonumber(Code) and Distance < Options.AutoUnlockPadlockSlider.Value then
						RemotesFolder.PL:FireServer(Code)
					end
				end
				if Toggles.AutoLibraryGuessCode.Value and LatestRoom.Value == 50 then
					local Code = Functions.GetRandomCode()
					if Code then RemotesFolder.PL:FireServer(Code) end
				end
			end
		end)
		Object.Destroying:Once(function()
			PadlockConn:Disconnect()
		end)
	end
end

Connections.PromptAnimationFixer1 = Services.ProximityPromptService.PromptButtonHoldBegan:Connect(function(Object)
	if not Object:GetAttribute("FakePrompt") then return end
	local ToolNames = { "Lockpick","Shears","SkeletonKey","Key","GeneratorFuse","KeyElectrical","KeyBackdoor","KeyIron", "Multitool" }
	local AnimateToolNames = { "Lockpick","Shears","SkeletonKey","Key","KeyElectrical","KeyBackdoor","KeyIron", "Multitool" }
	local Tool
	for _, N in ToolNames do Tool = Character:FindFirstChild(N) if Tool then break end end

	local Prompt = Object
	local LockPromptNames = { UnlockPrompt=true, SkullPrompt=true, LockPrompt=true, ThingToEnable=true, FusesPrompt=true }
	local IsLockPrompt = LockPromptNames[Object.Name]
		or (Object.Parent and Object.Parent:GetAttribute("Locked") == true)
		or (Object.Parent and Object.Parent.Parent and Object.Parent.Parent.Name == "Locker_Small_Locked" and Object.Name == "ActivateEventPrompt")
	if IsLockPrompt then
		if Options.AutoInteractIgnoreList.Value["Locks"] then return end
		local KeyItems = { "Key","GeneratorFuse","KeyBackdoor","KeyElectrical","KeyIron","Lockpick","SkeletonKey","Shears","Multitool" }
		local OffhandKeyItems = { "Key","GeneratorFuse","KeyElectrical","KeyIron" }
		local HasKey = false
		for _, K in KeyItems do if Functions.HasItem(K, true) then HasKey = true break end end
		for _, K in OffhandKeyItems do if Functions.HasItem(K) then HasKey = true break end end
		if not HasKey then return end
	end

	if Prompt.Parent.Name == "CuttableVines" and not Functions.HasItem("Shears", true) and not Functions.HasItem("Multitool", true) or Prompt.Parent.Name == "Chest_Vine" and not Functions.HasItem("Shears", true) and not Functions.HasItem("Multitool", true) or Prompt.Parent.Name == "Cellar" and not Functions.HasItem("Shears", true) and not Functions.HasItem("Multitool", true) then return end
	if Prompt.Parent.Name == "SkullLock" and not Functions.HasItem("SkeletonKey", true) then return end
	if Prompt.Parent.Name == "Lock1" and not Functions.HasItem("Lockpick", true) and not Functions.HasItem("Multitool", true) or Prompt.Parent.Name == "Lock2" and not Functions.HasItem("Lockpick", true) and not Functions.HasItem("Multitool", true) then return end
	if Functions.HasItem("Shears", true) and IsLockPrompt and Prompt.Parent.Name ~= "CuttableVines" and Prompt.Parent.Name ~= "Chest_Vine" and Prompt.Parent.Name ~= "Cellar" then return end
	
	if Tool and table.find(AnimateToolNames, Tool.Name) and Globals.UseAnimation then
		Globals.UseAnimationBreak:Stop()
		Globals.UseAnimation:Stop()
		Globals.UseAnimation:Play()
		if Tool.Name == "Shears" then Tool:WaitForChild("Handle"):WaitForChild("sound_prompt"):Play() end
	end
end)

Globals.ObjectQueue = {}
local AllowedInstances = {
	Lava=true, GoldPile=true, KeyObtain=true, Drakobloxxer=true, FuseObtain=true,
	MinesGenerator=true, JeffTheKiller=true, Snare=true, FakeDoor=true, DoorFake=true, SideroomSpace=true,
	ChestBox=true, ChestBoxLocked=true, Chest_Vine=true, Locker_Small_Locked=true, Toolbox=true,
	Toolbox_Locked=true, Wardrobe=true, ["Wardrobe-FOOLS26"]=true, Toolshed=true, Toolshed_Small=true,
	Bed=true, MinesAnchor=true, Double_Bed=true, RetroWardrobe=true, Backdoor_Wardrobe=true,
	Rooms_Locker=true, Rooms_Locker_Fridge=true, Locker_Large=true, FigureRig=true, FigureRagdoll=true,
	TimerLever=true, Lever=true, Seek_Arm=true, ChandelierObstruction=true, ScaryWall=true, Ladder=true,
	CircularVent=true, Dumpster=true, SquareGrate=true, TriggerEventCollision=true, GrumbleRig=true,
	GiggleCeiling=true, MinesGateButton=true, ElectricalKeyObtain=true, LibraryHintPaper=true,
	WaterPump=true, CringlePresent=true, Wheel=true, PickupItem=true, LiveHintBook=true,
	LiveBreakerPolePickup=true, LeverForGate=true, GloomPile=true, SeekFloodline=true, Door=true,
	Green_Herb=true, Bridge=true, MouseHole=true, BananaPeel=true, NannerPeel=true, PowerupPad=true,
	IndustrialGate=true, CollisionFloor=true, ElevatorCar=true, Wax_Door=true, ThingToOpen=true,
	MovingDoor=true, StardustPickup=true, Hole=true, Groundskeeper=true, MandrakeLive=true,
	GardenGateButton=true, LotusPetalPickup=true, VineGuillotine=true, LiveEntityBramble=true, ArchivesFihTank=true,
	RiftSpawn=true, ElevatorBreaker=true, RunnerNodes=true, PathLights=true, DuckBoard=true,
	Padlock=true, EyestalkEndCutscene=true, MinecartRig=true, SeekMovingNewClone=true, Cellar=true, ArchivesPackageDeposit=true, StairwellScrapper=true,
	StairwellFireAlarm=true, ShoppingCart=true, Mirror=true, StairwellLockpickDoor=true, DepotHalloween=true
}

Functions.QueueObject = function(Object)
	if TimeShowerClone and Object:IsDescendantOf(TimeShowerClone) then
		return
	end
	local IsHidingSpot = typeof(Object.Name) == "string" and string.find(string.lower(Object.Name), "hidingspot")
	if not AllowedInstances[Object.Name] and not IsHidingSpot and Object.ClassName ~= "ProximityPrompt" and Object.Parent ~= CurrentRooms and not ItemNames[Object.Name] then
		return
	end
	table.insert(Globals.ObjectQueue, Object)
end

Globals.QueueDone = true
Connections.QueueConnection = Services.RunService.RenderStepped:Connect(function()
	local Object = table.remove(Globals.ObjectQueue, 1)
	if Object then
		Functions.HandleObject(Object)
	end
end)

for _, Object in Services.Workspace:GetDescendants() do
	task.spawn(function() Functions.QueueObject(Object) end)
end

Connections.InstanceHandler = Services.Workspace.DescendantAdded:Connect(function(Object)
	Functions.QueueObject(Object)
end)

for _, Player in Services.Players:GetPlayers() do
	if Player ~= LocalPlayer then
		if Player.Character and Toggles.PlayerESPToggle.Value then
			Functions.AddESP({ Object = Player.Character, Text = Player.Name, Color = Options.PlayerESPColor.Value })
		end
		local CharConn = Player.CharacterAdded:Connect(function(NewCharacter)
			if Toggles.PlayerESPToggle.Value then
				Functions.AddESP({ Object = NewCharacter, Text = Player.Name, Color = Options.PlayerESPColor.Value })
			end
		end)
		local DeadConn = Player:GetAttributeChangedSignal("Alive"):Connect(function()
			if Player:GetAttribute("Alive") ~= true and Player.Character then
				Functions.RemoveESP(Player.Character)
			end
		end)
		table.insert(Connections, CharConn)
		table.insert(Connections, DeadConn)
		Player.Destroying:Once(function()
			CharConn:Disconnect()
			DeadConn:Disconnect()
		end)
	end
end

Connections.PlayerHandler = Services.Players.PlayerAdded:Connect(function(Player)
	if Player == LocalPlayer then return end
	if Player.Character and Toggles.PlayerESPToggle.Value then
		Functions.AddESP({ Object = Player.Character, Text = Player.Name, Color = Options.PlayerESPColor.Value })
	end
	local CharConn = Player.CharacterAdded:Connect(function(NewCharacter)
		if Toggles.PlayerESPToggle.Value then
			Functions.AddESP({ Object = NewCharacter, Text = Player.Name, Color = Options.PlayerESPColor.Value })
		end
	end)
	local DeadConn = Player:GetAttributeChangedSignal("Alive"):Connect(function()
		if Player:GetAttribute("Alive") ~= true and Player.Character then
			Functions.RemoveESP(Player.Character)
		end
	end)
	table.insert(Connections, CharConn)
	table.insert(Connections, DeadConn)
	Player.Destroying:Once(function()
		CharConn:Disconnect()
		DeadConn:Disconnect()
	end)
end)

local PromptsToFire = {}
local PromptCooldown = {}

Functions.FirePrompt      = Abysall.Environment.fireproximityprompt
Functions.ForceFirePrompt = Abysall.Environment.fireproximityprompt

if not Functions.FirePrompt then
	Functions.FirePrompt = function(Prompt)
		if not Prompt:IsA("ProximityPrompt") or PromptCooldown[Prompt] or table.find(PromptsToFire, Prompt) or not Camera then return end
		table.insert(PromptsToFire, Prompt)
	end
	Functions.ForceFirePrompt = Functions.FirePrompt

	task.spawn(function()
		while task.wait() do
			local Prompt = table.remove(PromptsToFire, 1)
			if not Prompt then continue end
			PromptCooldown[Prompt] = true

			local OldDist   = Prompt.MaxActivationDistance
			local OldEnable = Prompt.Enabled
			local OldParent = Prompt.Parent
			local OldHold   = Prompt.HoldDuration
			local OldLOS    = Prompt.RequiresLineOfSight

			Prompt.MaxActivationDistance = 99999
			Prompt.Enabled = true
			Prompt.HoldDuration = 0
			Prompt.RequiresLineOfSight = false

			local TempPart = Instance.new("Part")
			TempPart.Parent = Services.Workspace
			TempPart.CanCollide = false TempPart.CanQuery = false TempPart.CanTouch = false
			TempPart.Anchored = true TempPart.Transparency = 1
			TempPart.Size = Vector3.new(0.001, 0.001, 0.001)
			TempPart.Position = Camera.CFrame:ToWorldSpace(CFrame.new(0, 0, -0.1)).Position

			if not Prompt or not OldParent then
				TempPart:Destroy()
				PromptCooldown[Prompt] = nil
				continue
			end

			pcall(function() Prompt.Parent = TempPart end)

			local Shown, Fired = false, false

			local ShownConn = Services.ProximityPromptService.PromptShown:Connect(function(P)
				if P == Prompt then Shown = true end
			end)
			local FiredConn = Prompt.Triggered:Connect(function() Fired = true end)

			local T1 = 0
			while not Shown and T1 < 5 do T1 += 1 task.wait() end

			local T2 = 0
			while not Fired and T2 < 5 do
				Prompt:InputHoldBegin()
				Prompt:InputHoldEnd()
				T2 += 1 task.wait()
			end

			Prompt.MaxActivationDistance = OldDist
			Prompt.Enabled = OldEnable
			Prompt.HoldDuration = OldHold
			Prompt.RequiresLineOfSight = OldLOS
			pcall(function() Prompt.Parent = OldParent end)
			task.wait()
			PromptCooldown[Prompt] = nil
			TempPart:Destroy()
			ShownConn:Disconnect()
			FiredConn:Disconnect()
		end
	end)
end

local AutoInteractBlacklist = {
	HidePrompt=true, RiftPrompt=true, StarRiftPrompt=true, InteractPrompt=true, ClimbPrompt=true,
	DonatePrompt=true, DialoguePrompt=true, RevivePrompt=true, EnterPrompt=true, AnimatePrompt=true,
	ToolEventPrompt=true, Prompt=true, PropPrompt=true
}

local TriggerDebounce = false

local function GetHidingSpotModel(Prompt)
	if not Prompt or not Prompt.Parent then return false end
	local Model = Prompt.Parent
	while Model and not Model:IsA("Model") do
		Model = Model.Parent
	end
	if not Model then return nil end

	local Name = string.lower(Model.Name)
	if not string.find(Name, "hidingspot") and not string.find(Name, "hiding_spot") then
		return nil
	end
	return Model
end

local function HasHidePrompt(Model)
	return Model and (Model:FindFirstChild("HidePrompt") or Model:FindFirstChild("HidingPrompt")) ~= nil
end

local function IsHidingSpotPrompt(Prompt)
	if not Prompt or not Prompt.Parent then return false end
	if Prompt.Name ~= "HidePrompt" and Prompt.Name ~= "HidingPrompt" then return false end
	return HasHidePrompt(GetHidingSpotModel(Prompt))
end

Functions.TriggerPrompt = function(Prompt)
	if not Prompt or not Prompt.Parent then return end
	if Character:GetAttribute("Hiding") == true then return end
	local HidingSpot = GetHidingSpotModel(Prompt)
	if HidingSpot and Prompt.Name ~= "InteractPrompt" then return end
	local IsHidingSpotInteractPrompt = HidingSpot and Prompt.Name == "InteractPrompt"
	if AutoInteractBlacklist[Prompt.Name] and not IsHidingSpotPrompt(Prompt) and not IsHidingSpotInteractPrompt then return end
	if (Prompt.Name == "HidePrompt" or Prompt.Name == "HidingPrompt") and not IsHidingSpotPrompt(Prompt) then return end
	if (Prompt.Name == "HidePrompt" or Prompt.Name == "HidingPrompt" or IsHidingSpotPrompt(Prompt)) then
		if not Toggles.AutoClosetToggle.Value then return end
		local Entity = Functions.GetNearestEntity(true, Options.AutoClosetEntityList.Value)
		if not Entity then return end
		local EntityDistance = LocalPlayer:DistanceFromCharacter(Entity.PrimaryPart.Position)
		if EntityDistance > (EntityDistances[Entity.Name] or 150) then return end
	end
	if TriggerDebounce then return end

	local ParentItem = Functions.HasItem(Prompt.Parent.Name)
	if ParentItem and ParentItem:GetAttribute("Durability") and ParentItem:GetAttribute("DurabilityMax")
		and ParentItem:GetAttribute("Durability") >= ParentItem:GetAttribute("DurabilityMax")
	then return end

	local LockPromptNames = { UnlockPrompt=true, SkullPrompt=true, LockPrompt=true, ThingToEnable=true, FusesPrompt=true }
	local IsLockPrompt = LockPromptNames[Prompt.Name]
		or (Prompt.Parent and Prompt.Parent:GetAttribute("Locked") == true)
		or (Prompt.Parent and Prompt.Parent.Parent and Prompt.Parent.Parent.Name == "Locker_Small_Locked" and Prompt.Name == "ActivateEventPrompt")

	if IsLockPrompt then
		if Options.AutoInteractIgnoreList.Value["Locks"] then return end
		local KeyItems = { "Key","GeneratorFuse","KeyBackdoor","KeyElectrical","KeyIron","Lockpick","SkeletonKey","Shears","Multitool" }
		local OffhandKeyItems = { "Key","GeneratorFuse","KeyElectrical","KeyIron" }
		local HasKey = false
		for _, K in KeyItems do if Functions.HasItem(K, true) then HasKey = true break end end
		for _, K in OffhandKeyItems do if Functions.HasItem(K) then HasKey = true break end end
		if not HasKey then return end
	end

	if Prompt.Parent.Name == "CuttableVines" and not Functions.HasItem("Shears", true) and not Functions.HasItem("Multitool", true) or Prompt.Parent.Name == "Chest_Vine" and not Functions.HasItem("Shears", true) and not Functions.HasItem("Multitool", true) or Prompt.Parent.Name == "Cellar" and not Functions.HasItem("Shears", true) and not Functions.HasItem("Multitool", true) then return end
	if Prompt.Parent.Name == "SkullLock" and not Functions.HasItem("SkeletonKey", true) then return end
	if Prompt.Parent.Name == "Lock1" and not Functions.HasItem("Lockpick", true) and not Functions.HasItem("Multitool", true) or Prompt.Parent.Name == "Lock2" and not Functions.HasItem("Lockpick", true) and not Functions.HasItem("Multitool", true) then return end
	if Functions.HasItem("Shears", true) and IsLockPrompt and Prompt.Parent.Name ~= "CuttableVines" and Prompt.Parent.Name ~= "Chest_Vine" and Prompt.Parent.Name ~= "Cellar" then return end

	if Prompt.Parent.Name == "GlitchCube" and Options.AutoInteractIgnoreList.Value["Glitch Fragments"] then return end

	if (Prompt.Parent.Name == "KeyObtain" and (Functions.HasItem("Key") or Functions.HasItem("KeyBackdoor")))
		or (Prompt.Parent.Name == "ElectricalKeyObtain" and Functions.HasItem("KeyElectrical"))
	then return end

	if Prompt:IsDescendantOf(Drops) and Options.AutoInteractIgnoreList.Value["Dropped Items"] then return end
	if Prompt.Parent.Name == "TrackLever" then return end
	if Prompt.Name == "ActivateEventPrompt" and (Prompt.ActionText == "Close"
		or Prompt.Parent.Name == "ElevatorBreaker"
		or (Prompt.Parent.Parent and Prompt.Parent.Parent.Name == "IndustrialGate"))
	then return end
	if Prompt.Name == "ActivateEventPrompt" and (Prompt.Parent.Name == "Padlock" or Prompt.Parent.Name == "MinesAnchor") then return end
	if Prompt.Parent.Name == "LeverForGate" and Prompt:GetAttribute("Interactions") then return end
	if Prompt.Parent.Parent and (Prompt.Parent.Parent.Name == "DoorFake" or Prompt.Parent.Parent.Name == "FakeDoor") then return end
	if Prompt.Parent:GetAttribute("JeffShop") and Options.AutoInteractIgnoreList.Value["Jeff Items"] then return end
	if Prompt:GetAttribute("AutoInteractIgnore") then return end
	if Prompt.Name == "PushPrompt" and Options.AutoInteractIgnoreList.Value["Minecarts"] then return end
	if (Prompt.Parent.Name == "GoldPile" or Prompt.Parent.Name == "StardustPickup") and Options.AutoInteractIgnoreList.Value["Currency"] then return end

	if Prompt.Parent.Name == "Bandage" then
		local BPack = Functions.HasItem("BandagePack")
		if Humanoid.Health >= Humanoid.MaxHealth and not BPack then return end
		if BPack and BPack:GetAttribute("Durability") >= BPack:GetAttribute("DurabilityMax") then return end
	end

	if Prompt.Parent.Name == "Battery" then
		local Tool = Character:FindFirstChildOfClass("Tool")
		local BPack = Functions.HasItem("BatteryPack")
		if not Tool and not BPack then return end
		if Tool and Tool:GetAttribute("LightSource") then
			if Tool:GetAttribute("Durability") and Tool:GetAttribute("DurabilityMax")
				and Tool:GetAttribute("Durability") > Tool:GetAttribute("DurabilityMax")
			then return end
		elseif not BPack then
			return
		end
		if BPack and BPack:GetAttribute("Durability") >= BPack:GetAttribute("DurabilityMax") then return end
	end

	if Prompt.Name == "HerbPrompt" then
		local Effects = Globals.MainUI.MainFrame.Healthbar:FindFirstChild("Effects")
		if Effects and Effects.HerbGreenEffect.Visible then return end
	end

	if (Prompt.Parent.Name == "LibraryHintPaper" or Prompt.Parent.Name == "PickupItem") and (Functions.HasItem("LibraryHintPaper") or Functions.HasItem("LibraryHintPaperHard")) then return end
	if Prompt.Parent.Name == "AlarmClock" and Functions.HasItem("AlarmClock") then return end
	if Prompt.Parent.Name == "KeyObtainFake" or Prompt.Parent.Name == "TithingPlate" then return end
	if Prompt.Parent.Name == "StarBottle" then return end
    -- archives
	if Prompt.parent.Name == "ArchivesStorageBox" then return end
	if Prompt.Parent.Name == "Briefcase" then return end
	if Prompt.Name == "SinkPrompt" or Prompt.Parent.Name == "Faucet" then return end
	if Prompt.Parent.Name == "PaperPlanePickup" or Prompt.Parent.Name == "PaperPlane" then return end
	if Prompt.Name == "ManualOpenPrompt" or Prompt.Name == "EntryPrompt" then return end
	if Prompt.Parent.Parent.Name == "ArchivesLargePrinter" then return end
	if Prompt.Name == "TrashcanPrompt" then return end
	if Prompt.Parent.Name == "Keyboard" then return end
	if Prompt.Name == "CartPrompt" or Prompt.Parent.Parent.Name == "ArchivesOfficeChair" then return end
	if Prompt.Parent.Name == "ArchivesTerminal" then return end
	if Prompt.Name == "VendorPrompt" then return end
    if Prompt.Parent.Name == "SeatPart" or Prompt.Name == "SeatPrompt" then return end


	-- Stairwell
	if Prompt.Parent.Parent.Parent.Parent.Name == "CandyVault" then return end
	if Prompt.Parent.Name == "StairwellScrapper" then return end
	if Prompt.Name == "PortraitDupePrompt" or Prompt.Parent.Name == "MirrorTool" then return end
	if Prompt.Name == "LaptopPrompt" or Prompt.Parent.Name == "SecretLaptop" then return end
	if Prompt.Parent.Name == "StairwellFireAlarm" or Prompt.Parent.Parent.Name == "StairwellFireAlarm" then return end
	if Prompt.Parent.name == "CobblerFriendly" then return end
	if Prompt.Parent.Name == "StairwellTerminal" then return end
	if Prompt.Parent.Parent.Name == "MeldChord" then return end

	Functions.FirePrompt(Prompt)
	TriggerDebounce = true
	if Floor == "OldHotel" then task.wait() end
	TriggerDebounce = false
end

Globals.LastAutoInteractFire = tick()
Connections.AutoInteract = Services.RunService.Heartbeat:Connect(function()
	local Active = Toggles.AutoInteractToggle.Value or Options.AutoInteractKeybind:GetState()
    if not Active then return end
    if tick() - Globals.LastAutoInteractFire < 1/60 then return end

	for _, Prompt in Objects.Prompts do
        if Prompt:GetAttribute("ParentRoom") and tonumber(Prompt:GetAttribute("ParentRoom")) ~= tonumber(LocalPlayer:GetAttribute("CurrentRoom")) then continue end

		if Prompt.Parent and (Prompt.Parent:IsA("BasePart") or Prompt.Parent:IsA("Model")) then
			local Distance
			if Prompt.Parent:IsA("BasePart") then
				Distance = LocalPlayer:DistanceFromCharacter(Prompt.Parent.Position)
			else
				Distance = LocalPlayer:DistanceFromCharacter(Prompt.Parent:GetPivot().Position)
			end
			if Distance <= Prompt.MaxActivationDistance and Prompt.Enabled or Distance <= Prompt.MaxActivationDistance and Prompt.Name == "LongPushPrompt" or Distance <= Prompt.MaxActivationDistance and Prompt.Name == "BigPropPrompt" then
				task.spawn(Functions.TriggerPrompt, Prompt)
			end
		end
	end
    Globals.LastAutoInteractFire = tick()
end)

Connections.InfiniteItemsHandler = Services.ProximityPromptService.PromptTriggered:Connect(function(Object)
	if not Object:GetAttribute("FakePrompt") then return end

	local ToolNames = { "Lockpick","Shears","SkeletonKey","Key","GeneratorFuse","KeyElectrical","KeyBackdoor","KeyIron", "Multitool" }
	local AnimateToolNames = { "Lockpick","Shears","SkeletonKey","Key","KeyElectrical","KeyBackdoor","KeyIron", "Multitool" }
	local Tool
	for _, N in ToolNames do Tool = Character:FindFirstChild(N) if Tool then break end end

	local Prompt = Object
	local LockPromptNames = { UnlockPrompt=true, SkullPrompt=true, LockPrompt=true, ThingToEnable=true, FusesPrompt=true }
	local IsLockPrompt = LockPromptNames[Object.Name]
		or (Object.Parent and Object.Parent:GetAttribute("Locked") == true)
		or (Object.Parent and Object.Parent.Parent and Object.Parent.Parent.Name == "Locker_Small_Locked" and Object.Name == "ActivateEventPrompt")
	if IsLockPrompt then
		if Options.AutoInteractIgnoreList.Value["Locks"] then return end
		local KeyItems = { "Key","GeneratorFuse","KeyBackdoor","KeyElectrical","KeyIron","Lockpick","SkeletonKey","Shears","Multitool" }
		local OffhandKeyItems = { "Key","GeneratorFuse","KeyElectrical","KeyIron" }
		local HasKey = false
		for _, K in KeyItems do if Functions.HasItem(K, true) then HasKey = true break end end
		for _, K in OffhandKeyItems do if Functions.HasItem(K) then HasKey = true break end end
		if not HasKey then return end
	end

	if Prompt.Parent.Name == "CuttableVines" and not Functions.HasItem("Shears", true) and not Functions.HasItem("Multitool", true) or Prompt.Parent.Name == "Chest_Vine" and not Functions.HasItem("Shears", true) and not Functions.HasItem("Multitool", true) or Prompt.Parent.Name == "Cellar" and not Functions.HasItem("Shears", true) and not Functions.HasItem("Multitool", true) then return end
	if Prompt.Parent.Name == "SkullLock" and not Functions.HasItem("SkeletonKey", true) then return end
	if Prompt.Parent.Name == "Lock1" and not Functions.HasItem("Lockpick", true) and not Functions.HasItem("Multitool", true) or Prompt.Parent.Name == "Lock2" and not Functions.HasItem("Lockpick", true) and not Functions.HasItem("Multitool", true) then return end
	if Functions.HasItem("Shears", true) and IsLockPrompt and Prompt.Parent.Name ~= "CuttableVines" and Prompt.Parent.Name ~= "Chest_Vine" and Prompt.Parent.Name ~= "Cellar" then return end

	if Tool and table.find(AnimateToolNames, Tool.Name) and Globals.UseAnimation and Globals.UseAnimationBreak then
		Globals.UseAnimation:Stop()
		Globals.UseAnimationBreak:Stop()
		Globals.UseAnimationBreak:Play()
		if Tool.Name == "Shears" then Tool:WaitForChild("Handle"):WaitForChild("sound_prompt"):Play() end
	end

	local AnyTool = Character:FindFirstChildOfClass("Tool")
	local ToolData = AnyTool and ItemNames[AnyTool.Name]
	if AnyTool and ToolData and Toggles.InfiniteItemsToggle.Value and Options.InfiniteItemsList.Value[ToolData] then
		Drops.ChildAdded:Once(function(NewTool)
			local Prompt = NewTool:FindFirstChild("ModulePrompt")
			local RealPrompt = FakePrompts[Object]
			Functions.FirePrompt(Prompt)
			Functions.FirePrompt(RealPrompt)
		end)
		Character.ChildAdded:Once(function(NewTool)
			if NewTool.Name == "Shears" then NewTool:WaitForChild("Handle"):WaitForChild("sound_promptend"):Play() end
		end)
		RemotesFolder.DropItem:FireServer(AnyTool)
	else
		local RealPrompt = FakePrompts[Object]
		Functions.FirePrompt(RealPrompt)
	end
end)

Connections.FloorReplicatedHandler = FloorReplicated.DescendantAdded:Connect(function(Object)
	if Object.Name == "GlitchScreech" then
		Modules.GlitchScreech = Object
		if Toggles.RemoveScreech.Value then Object.Name = "GlitchScreech_Disabled" end
	end
	if Object.Name:find("Jumpscare") and Object:IsA("ModuleScript")
		and not Object.Name:find("Eyestalk") and not Object.Name:find("Groundskeeper") and not Object.Name:find("Monument")
	then
		Object:SetAttribute("OriginalName", Object.Name)
		if Toggles.DisableEntityJumpscares.Value then Object.Name = Object.Name .. "_Disabled" end
		table.insert(Objects.JumpscareModules, Object)
	end
end)

if FloorReplicated:FindFirstChild("DigitalTimer") then
	Connections.HasteTimerConnection = FloorReplicated.DigitalTimer:GetPropertyChangedSignal("Value"):Connect(function()
		if Toggles.NotifyHasteTime.Value then Functions.Caption(Functions.GetHasteTime(), true) end
	end)
end

Connections.FogHandler = Services.Lighting:GetPropertyChangedSignal("FogEnd"):Connect(function()
	if Services.Lighting.FogEnd ~= 10000000 then
		Globals.OldFog = Services.Lighting.FogEnd
	end
	if Toggles.RemoveCameraFog.Value then
		Services.Lighting.FogEnd = 10000000
	end
end)

Connections.FogHandler2 = Services.Lighting.DescendantAdded:Connect(function(Object)
	if not Object:IsA("Atmosphere") then return end
	Object:SetAttribute("Density_Old", Object.Density)
	if Toggles.RemoveCameraFog.Value then Object.Density = 0 end

	local AtmoConn2 = Object:GetPropertyChangedSignal("Density"):Connect(function()
		if Object.Density ~= 0 then Object:SetAttribute("Density_Old", Object.Density) end
		if Toggles.RemoveCameraFog.Value then Object.Density = 0 end
	end)
	Object.Destroying:Once(function() AtmoConn2:Disconnect() end)
	table.insert(Connections, AtmoConn2)
	table.insert(Globals.FogInstances, Object)
end)

local RusherAliases = { Rush=true, Bash=true, Scribbles=true, DronesStampede=true, Ambush=true, Eyes=true, Lookman=true, Blitz=true, ["A-60"]=true, ["A-120"]=true, AR0xMBUSH=true, ["RNIUSHCG=="]=true, ["Custom Entity"]=true }

local function HandleEntitySpawn(Entity)
	if not Entity or typeof(Entity) ~= "Instance" then return end

	local Model = Entity
	if Entity:IsA("Humanoid") then
		Model = Entity.Parent
	end
	if not Model or not Model:IsA("Model") then return end

	local EntityData = Entities[Model.Name]
	if not EntityData then return end
	if Model:GetAttribute("Abysall_EntityHandled") then return end
	Model:SetAttribute("Abysall_EntityHandled", true)

	while not Model.PrimaryPart do
		for _, Child in Model:GetChildren() do
			if Child:IsA("BasePart") then Model.PrimaryPart = Child end
		end
		if not Model.PrimaryPart then task.wait() end
	end
	task.wait(0.1)

	if not Model.PrimaryPart or LocalPlayer:DistanceFromCharacter(Model.PrimaryPart.Position) >= 10000 then return end

	local Alias = EntityData.Alias
	local RealAlias = Alias
	if Options.EntityList.Value[Alias] and Toggles.NotifyEntities.Value then
		local NotifyTitle = EntityData.NotifyMessage.Title
		local NotifyBody  = EntityData.NotifyMessage.Body
		local NotifyImage = EntityIcons[Model.Name]

		if Model.Name == "RushMoving" and Model.PrimaryPart.Name ~= "RushNew" then
			NotifyTitle = NotifyTitle:gsub("Rush", Model.PrimaryPart.Name)
			NotifyImage = Model.PrimaryPart:WaitForChild("Attachment").ParticleEmitter.Texture
			Alias = Model.PrimaryPart.Name
		end

		Functions.Notify({ Title = NotifyTitle, Body = NotifyBody, Image = NotifyImage, Time = Toggles.NotifyKeepNotifications.Value and Model or nil })

		if Toggles.EntityChatToggle.Value then
			Functions.SendChat(Alias .. " " .. Options.EntityChatMessage.Value)
		end
	end

	if Model.Name ~= "GloombatSwarm" then
		if Toggles.EntityESPToggle.Value and Options.EntityESPOptions.Value[RealAlias] then
			if Model.Name == "MonumentEntity" then
				Functions.AddESP({ Object = Model.Top, Text = Alias, Color = Options.EntityESPColor.Value })
			else
				Functions.AddESP({ Object = Model, Text = Alias, Color = Options.EntityESPColor.Value })
			end
		end
		table.insert(Objects.Entities, Model)
	end

	if RusherAliases[EntityData.Alias] then
		Instance.new("Humanoid", Model).Name = "HighlightHumanoid"
		local Root = Model.PrimaryPart
		if Root then Root.Transparency = 0.999 Root.Material = Enum.Material.Plastic end
	end

	if Model.Name == "Lookman" then
		CurrentRooms.ChildAdded:Wait()
		task.wait(10)
		Model:Destroy()
	end
end

Connections.EntityHandler = Services.Workspace.ChildAdded:Connect(HandleEntitySpawn)
Connections.EntityDescendantHandler = Services.Workspace.DescendantAdded:Connect(function(Descendant)
	local EntityModel = Descendant:IsA("Humanoid") and Descendant.Parent or Descendant
	if EntityModel and EntityModel:IsA("Model") and Entities[EntityModel.Name] then
		task.defer(function()
			HandleEntitySpawn(Descendant)
		end)
	end
end)

local LastClean = tick()
Connections.Cleaner = Services.RunService.Heartbeat:Connect(function()
	if tick() - LastClean <= 0.5 then return end
	LastClean = tick()

	for ArrayName, Array in Objects do
		local I = #Array
		while I >= 1 do
			local Object = Array[I]
			if Object == nil or not Object:IsDescendantOf(Services.Workspace) then
				table.remove(Array, I)
				local Conn = ESPConnections[Object]
				if Conn then
					Conn:Disconnect()
					ESPConnections[Object] = nil
					local Pos = table.find(Connections, Conn)
					if Pos then table.remove(Connections, Pos) end
				end
			end
			I -= 1
		end
	end
end)

local LastPromptFix = tick()
Connections.PromptFixer = Services.RunService.Heartbeat:Connect(function()
	if tick() - LastPromptFix <= 0.5 then return end
	LastPromptFix = tick()
	for _, Prompt in Objects.Prompts do
		if Prompt:HasTag("DisableWhenEnabledOnClient") then
			Prompt:RemoveTag("DisableWhenEnabledOnClient")
		end
	end
end)

if LocalPlayer.Character then
	task.spawn(function() Functions.HandleCharacter(LocalPlayer.Character) end)
end

LocalPlayer.CharacterAdded:Connect(function(NewCharacter)
	if Connections.MainHandler then
		Connections.MainHandler:Disconnect()
		Connections.MainHandler = nil
	end
	task.wait(0.5)
	Functions.HandleCharacter(NewCharacter)
end)


-- Ms fent Archives Chair AC (from old hub)
do
-- Archives Chair Anticheat Bypass (Start Bypass + Chair Speed)
	local ArchivesChairAC_Active = false
	local ArchivesChairAC_RenderConn = nil
	local ArchivesChairAC_Heartbeat = nil
	local ArchivesChairAC_RoomConn = nil
	local ArchivesChairAC_LagbackConns = {}
	local ArchivesChairAC_LagbackDisabled = false
	local ArchivesChairAC_Held = nil
	local ArchivesChairAC_PartProps = {}
	local ArchivesChairAC_OrigParent = nil
	local ArchivesChairAC_DesiredCF = nil
	local ArchivesChairAC_AtBoundary = false

	local function ArchivesChairAC_IsBoundary(roomVal)
		local n = tonumber(roomVal)
		return n and n > 0 and (n % 50 == 0)
	end

	local function ArchivesChairAC_LooksLikeChair(inst)
		if not inst then return false end
		local n = string.lower(tostring(inst.Name))
		for _, k in ipairs({ "chair", "office", "rolling", "impact", "cart", "caster", "stool" }) do
			if n:find(k, 1, true) then return true end
		end
		if inst:IsA("Model") then
			if inst:FindFirstChild("Collider", true) or inst:FindFirstChild("SeatAttachment", true) then return true end
			if inst:FindFirstChildWhichIsA("Seat", true) or inst:FindFirstChildWhichIsA("VehicleSeat", true) then return true end
		end
		return false
	end

	local function ArchivesChairAC_NearestChair(maxDist)
		maxDist = maxDist or 22
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then return nil end
		local best, bestD = nil, maxDist
		for _, m in ipairs(workspace:GetDescendants()) do
			if m:IsA("Model") and ArchivesChairAC_LooksLikeChair(m) then
				local ok, pos = pcall(function() return m:GetPivot().Position end)
				if ok and pos then
					local d = (pos - hrp.Position).Magnitude
					if d < bestD then bestD, best = d, m end
				end
			end
		end
		return best
	end

	local function ArchivesChairAC_Hide(model)
		if not model then return end
		ArchivesChairAC_Held = model
		ArchivesChairAC_OrigParent = model.Parent
		table.clear(ArchivesChairAC_PartProps)
		pcall(function()
			for _, p in ipairs(model:GetDescendants()) do
				if p:IsA("BasePart") then
					ArchivesChairAC_PartProps[p] = {
						ltm = p.LocalTransparencyModifier, trans = p.Transparency,
						cc = p.CanCollide, cq = p.CanQuery, ct = p.CanTouch,
					}
					p.LocalTransparencyModifier = 1
					p.Transparency = 1
					p.CanCollide = false
					p.CanQuery = false
					p.CanTouch = false
				elseif p:IsA("Decal") or p:IsA("Texture") then
					pcall(function() p.Transparency = 1 end)
				elseif p:IsA("ProximityPrompt") then
					pcall(function() p.Enabled = false end)
				end
			end
			model.Parent = nil
		end)
	end

	local function ArchivesChairAC_Show(model)
		if not model then return end
		local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		pcall(function()
			for part, props in pairs(ArchivesChairAC_PartProps) do
				if part and part.Parent then
					if props.ltm ~= nil then part.LocalTransparencyModifier = props.ltm end
					if props.trans ~= nil then part.Transparency = props.trans end
					if props.cc ~= nil then part.CanCollide = props.cc end
					if props.cq ~= nil then part.CanQuery = props.cq end
					if props.ct ~= nil then part.CanTouch = props.ct end
				end
			end
			if ArchivesChairAC_OrigParent and ArchivesChairAC_OrigParent.Parent then
				model.Parent = ArchivesChairAC_OrigParent
			else
				model.Parent = workspace
			end
			if hrp then
				pcall(function() model:PivotTo(hrp.CFrame * CFrame.new(0, 0, -3)) end)
			end
		end)
	end

	local function ArchivesChairAC_SetLagbackBlocked(block)
		if block == ArchivesChairAC_LagbackDisabled then return end
		ArchivesChairAC_LagbackDisabled = block
		pcall(function()
			if not getconnections then return end
			local remotes = {}
			if RemotesFolder then
				table.insert(remotes, RemotesFolder:FindFirstChild("ServerTeleported"))
				table.insert(remotes, RemotesFolder:FindFirstChild("Teleport"))
			end
			for _, d in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
				if d:IsA("RemoteEvent") and (d.Name == "ServerTeleported" or d.Name == "Teleport") then
					table.insert(remotes, d)
				end
			end
			if block then
				for _, remote in ipairs(remotes) do
					if not remote then continue end
					for _, conn in ipairs(getconnections(remote.OnClientEvent)) do
						local already = false
						for _, rec in ipairs(ArchivesChairAC_LagbackConns) do
							if rec[1] == conn then already = true break end
						end
						if not already then
							local enabled = true
							pcall(function() enabled = conn.Enabled end)
							table.insert(ArchivesChairAC_LagbackConns, { conn, enabled })
							pcall(function() conn:Disable() end)
						end
					end
				end
			else
				for _, rec in ipairs(ArchivesChairAC_LagbackConns) do
					if rec[2] then pcall(function() rec[1]:Enable() end) end
				end
				table.clear(ArchivesChairAC_LagbackConns)
			end
		end)
	end

	local function ArchivesChairAC_StopInternal(reason)
		ArchivesChairAC_Active = false
		Globals.AnticheatDisabled = false
		ArchivesChairAC_SetLagbackBlocked(false)
		ArchivesChairAC_DesiredCF = nil
		if ArchivesChairAC_RenderConn then pcall(function() ArchivesChairAC_RenderConn:Disconnect() end) ArchivesChairAC_RenderConn = nil end
		if ArchivesChairAC_Heartbeat then pcall(function() ArchivesChairAC_Heartbeat:Disconnect() end) ArchivesChairAC_Heartbeat = nil end
		if ArchivesChairAC_Held then
			ArchivesChairAC_Show(ArchivesChairAC_Held)
			ArchivesChairAC_Held = nil
		end
		table.clear(ArchivesChairAC_PartProps)
		if reason then
			Functions.Notify({ Title = "Anti-Cheat Bypass", Body = reason })
		end
	end

	Functions.ArchivesChairAC_Stop = function()
		ArchivesChairAC_StopInternal("Anti-Cheat bypass disabled due to leaving cart prop.")
	end

	Functions.ArchivesChairAC_Start = function()
		if not Toggles.ArchivesChairACBypass or not Toggles.ArchivesChairACBypass.Value then
			Functions.Notify({ Title = "Anti-Cheat Bypass", Body = "Turn Chair Anticheat Bypass ON first." })
			return
		end
		if ArchivesChairAC_AtBoundary then
			Functions.Notify({ Title = "Anti-Cheat Bypass", Body = "At *-50 — use console, bypass paused." })
			return
		end
		if ArchivesChairAC_Active then
			Functions.Notify({ Title = "Anti-Cheat Bypass", Body = "Already active." })
			return
		end

		local chair = ArchivesChairAC_NearestChair(22)
		if not chair then
			Functions.Notify({ Title = "Anti-Cheat Bypass", Body = "No office chair nearby. Stand closer." })
			return
		end

		ArchivesChairAC_Hide(chair)
		ArchivesChairAC_Active = true
		Globals.AnticheatDisabled = true
		ArchivesChairAC_SetLagbackBlocked(true)

		local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if hrp then ArchivesChairAC_DesiredCF = hrp.CFrame end

		Functions.Notify({
			Title = "Anti-Cheat Bypass",
			Body = "You have successfully bypassed the anti-cheat!",
		})
		print("[ChairAC] Start Bypass", chair:GetFullName())

		ArchivesChairAC_RenderConn = Services.RunService.RenderStepped:Connect(function(dt)
			if not ArchivesChairAC_Active or ArchivesChairAC_AtBoundary then return end
			local char = LocalPlayer.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if not hrp or not hum then return end

			local speed = 50
			pcall(function()
				if Options.ChairSpeed then
					speed = math.clamp(tonumber(Options.ChairSpeed.Value) or 50, 1, 100)
				end
			end)

			local move = hum.MoveDirection
			if not ArchivesChairAC_DesiredCF then
				ArchivesChairAC_DesiredCF = hrp.CFrame
			end
			if move.Magnitude > 0.05 then
				local nextPos = ArchivesChairAC_DesiredCF.Position + move.Unit * speed * dt
				local rot = hrp.CFrame - hrp.Position
				ArchivesChairAC_DesiredCF = CFrame.new(nextPos) * rot
			else
				local rot = hrp.CFrame - hrp.Position
				ArchivesChairAC_DesiredCF = CFrame.new(ArchivesChairAC_DesiredCF.Position) * rot
			end

			pcall(function()
				hrp.CFrame = ArchivesChairAC_DesiredCF
				hrp.AssemblyLinearVelocity = move.Magnitude > 0.05 and (move.Unit * speed) or Vector3.zero
				hrp.AssemblyAngularVelocity = Vector3.zero
			end)
		end)

		ArchivesChairAC_Heartbeat = Services.RunService.Heartbeat:Connect(function()
			if not ArchivesChairAC_Active then return end
			if ArchivesChairAC_Held then
				pcall(function()
					if ArchivesChairAC_Held.Parent ~= nil then ArchivesChairAC_Held.Parent = nil end
					for p, _ in pairs(ArchivesChairAC_PartProps) do
						if p and p.Parent then
							p.LocalTransparencyModifier = 1
							p.Transparency = 1
							p.CanCollide = false
						end
					end
				end)
			end
			local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if hrp and Globals.ManipulateBody then
				pcall(function()
					Globals.ManipulateBody.Parent = hrp
					local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
					local move = hum and hum.MoveDirection or Vector3.zero
					local spd = 2.25
					pcall(function()
						if Options.ChairSpeed then
							spd = math.clamp((tonumber(Options.ChairSpeed.Value) or 50) / 25, 1, 4)
						end
					end)
					Globals.ManipulateBody.Velocity = move.Magnitude > 0.05 and (move.Unit * spd) or (hrp.CFrame.LookVector * spd)
				end)
			end
		end)
	end

	pcall(function()
		if LatestRoom then
			ArchivesChairAC_RoomConn = LatestRoom:GetPropertyChangedSignal("Value"):Connect(function()
				local boundary = ArchivesChairAC_IsBoundary(LatestRoom.Value)
				if boundary and not ArchivesChairAC_AtBoundary then
					ArchivesChairAC_AtBoundary = true
					if ArchivesChairAC_Active then
						ArchivesChairAC_StopInternal("*-50 — AC off for console (chair restored).")
					end
				elseif not boundary and ArchivesChairAC_AtBoundary then
					ArchivesChairAC_AtBoundary = false
				end
			end)
		end
	end)

	Toggles.ArchivesChairACBypass:OnChanged(function(Value)
		if not Value and ArchivesChairAC_Active then
			ArchivesChairAC_StopInternal("Chair Anticheat Bypass disabled.")
		elseif Value then
			Functions.Notify({
				Title = "Chair Anticheat Bypass",
				Body = "ON — stand by a chair, set Chair Speed, press Start Bypass.",
			})
		end
	end)

end

Library:OnUnload(function()
	StopTimeShower(true)
	for Key, Connection in Connections do
		if type(Key) == "string" then
			pcall(function() Connection:Disconnect() end)
		else
			pcall(function() Key:Disconnect() end)
			pcall(function() Connection:Disconnect() end)
		end
	end

	for _, Object in Objects.Entities do
		if Object.Name == "Snare" or Object.Name == "GiggleCeiling" then
			local Hitbox = Object:FindFirstChild("Hitbox")
			if Hitbox then Hitbox.CanTouch = true end
		end
		if Object.Name == "GloomPile" then
			for _, Part in Object:GetDescendants() do
				if Part:IsA("BasePart") then Part.CanTouch = true end
			end
		end
		if Object.Name == "FakeDoor" or Object.Name == "DoorFake" then
			local Hidden = Object:FindFirstChild("Hidden")
			if Hidden then Hidden.CanTouch = true end
			local Lock = Object:FindFirstChild("Lock")
			if Lock and Lock:FindFirstChild("UnlockPrompt") then Lock.UnlockPrompt.Enabled = true end
		end
		if Object.Name == "SideroomSpace" then
			local Coll = Object:FindFirstChild("Collision")
			if Coll then Coll.CanCollide = false Coll.CanTouch = true end
		end
	end

	for _, Object in Objects.SeekBridges do Object:Destroy() end

	for _, Fog in Globals.FogInstances do
		Fog.Density = Fog:GetAttribute("Density_Old")
	end
	Services.Lighting.FogEnd = Globals.OldFog

	local Vignette = Globals.MainUI:FindFirstChild("HideVignette") or Globals.MainUI.MainFrame:FindFirstChild("HideVignette")
	if Vignette then Vignette.Image = "rbxassetid://6100076320" end

	local ModuleRestores = {
		Screech = "Screech", Glitch = "Glitch", Shade = "Shade",
		SpiderJumpscare = "SpiderJumpscare", A90 = "A90", Dread = "Dread", Void = "Void"
	}
	for Key, OriginalName in ModuleRestores do
		if Modules[Key] then Modules[Key].Name = OriginalName end
	end

	FakeEvents.Screech:Destroy()
	FakeEvents.Screech_Real.Parent = RemotesFolder
	FakeEvents.Shade:Destroy()
	FakeEvents.Shade_Real.Parent = RemotesFolder

	if FakeEvents.A90_Real then
		FakeEvents.A90:Destroy()
		FakeEvents.A90_Real.Parent = RemotesFolder
	end
	if FakeEvents.Surge_Real then
		FakeEvents.Surge:Destroy()
		FakeEvents.Surge_Real.Parent = RemotesFolder
	end

	Globals.SeekNodesFolder:Destroy()
	Globals.RoomsNodesFolder:Destroy()
	Globals.ManipulateBody:Destroy()

	local OldAmbient = CurrentRooms:FindFirstChild(tostring(LocalPlayer:GetAttribute("CurrentRoom"))):GetAttribute("Ambient")
	Services.TweenService:Create(Services.Lighting, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), { Ambient = OldAmbient }):Play()

	for _, Prompt in Objects.Prompts do
		if FakePrompts[Prompt] then
			FakePrompts[Prompt].Parent = Prompt.Parent
			Prompt:Destroy()
		end
		if Prompt.Parent then
			Prompt.HoldDuration = Prompt:GetAttribute("HoldDuration_Old") or Prompt.HoldDuration
			Prompt.RequiresLineOfSight = Prompt:GetAttribute("RequiresLineOfSight_Old") or Prompt.RequiresLineOfSight
			Prompt.MaxActivationDistance = Prompt:GetAttribute("MaxActivationDistance_Old") or Prompt.MaxActivationDistance
		end
	end

	Character:SetAttribute("CanJump",  OldJump)
	Character:SetAttribute("CanSlide", OldSlide)

	for _, Object in Services.Workspace:GetDescendants() do
		task.spawn(function() Functions.RemoveESP(Object) end)
	end

	Humanoid.WalkSpeed  = Functions.GetCurrentSpeed()
	Humanoid.JumpPower  = 5
	Humanoid.HipHeight  = 2.367

	local BaseY = 0.18
	Collision.Position          = RootPart.Position + Vector3.new(0, BaseY, 0)
	CollisionPart.Position      = RootPart.Position + Vector3.new(0, BaseY, 0)
	CollisionPartClone.Position = RootPart.Position + Vector3.new(0, BaseY, 0)

	if Character:FindFirstChild("LowerTorso") and Character.LowerTorso:FindFirstChild("Root") then
		Character.LowerTorso.Root.C1 = Globals.OriginalC1
	end
	if Collision:FindFirstChild("CollisionCrouch") then
		Collision.CollisionCrouch.Position = RootPart.Position + Vector3.new(0, -0.982, 0)
	end

	CollisionClone:Destroy()
	CollisionPartClone:Destroy()
	Abysall.ESPLibrary:Unload()

	if Main_Game then
		Main_Game.fovtarget   = 70
		Main_Game.spring.Speed = 8
		Main_Game.tooloffset   = Vector3.zero
	end

	if Globals.OriginalGetMoveVector then 
		local Controls = require(LocalPlayer.PlayerScripts.PlayerModule):GetControls()
		Controls.GetMoveVector = Globals.OriginalGetMoveVector
	end

	getgenv().Abysall = nil
	shared.Hastelepasta = false
end)



do
	local t0 = tick()
	while not Globals.MainUI and tick() - t0 < 20 do
		task.wait(0.1)
	end
	if not Globals.MainUI then
		warn("[Ms fent] MainUI missing after 20s — continuing anyway")
	end
end


pcall(__MsFent_ApplySettings, Window)
Functions.Notify({ Title = "Successfully loaded in " .. math.floor((tick() - LoadStart) * 1000) / 1000 .. " seconds." , Body = "Press '" .. tostring(Options.MenuKeybind.Value) .. "' to toggle the UI."})


-- Ensure settings if Main didn't call it
pcall(__MsFent_ApplySettings, nil)

getgenv().MsFent = getgenv().Abysall
print("[Ms fent] Doors ready (no Abysall remotes) in", math.floor((tick()-LoadStart)*1000)/1000, "s")


-- OWNER TAB (UserId 2320681142 only)
task.spawn(function()
	local OWNER_USER_ID = 2320681142
	local lp = game:GetService("Players").LocalPlayer
	if not lp or lp.UserId ~= OWNER_USER_ID then return end
	task.wait(1)
	local ok, err = pcall(function()
		if not Library or not Library.CreateWindow and not Tabs then return end
		-- Window may already exist; add tab to main Window via Tabs global if present
		local win = nil
		pcall(function()
			-- Obsidian windows
			for _, w in pairs(Library.Windows or {}) do win = w break end
		end)
		if not win and getgenv().MsFent and getgenv().MsFent._Window then
			win = getgenv().MsFent._Window
		end
		-- Fallback: use first tab's parent
		local ownerTab
		if Tabs and Tabs.General then
			-- AddTab on same window as General
			-- Library stores window reference poorly; use CreateWindow's return was local Window
		end
		-- Store window when CreateWindow runs - patch below sets MsFent._Window
		local tries = 0
		while tries < 50 and not getgenv().MsFent._Window do
			task.wait(0.1)
			tries += 1
		end
		win = getgenv().MsFent._Window
		if not win then
			warn("[Ms fent] Owner tab: window not found")
			return
		end
		ownerTab = win:AddTab("Owner", "crown")
		local box = ownerTab:AddLeftGroupbox("Owner")
		box:AddLabel("Welcome Gabrieltod112", true)
		box:AddLabel("UserId " .. tostring(OWNER_USER_ID), true)
		box:AddButton({
			Text = "Print place / job",
			Func = function()
				print("[Ms fent Owner]", game.PlaceId, game.JobId)
				pcall(function()
					Library:Notify({ Title = "Owner", Description = "Place " .. tostring(game.PlaceId) })
				end)
			end,
		})
		box:AddButton({
			Text = "Clear load lock",
			Func = function()
				getgenv().MsFentLoaded = nil
				shared.Hastelepasta = nil
				Library:Notify({ Title = "Owner", Description = "Load lock cleared" })
			end,
		})
		local right = ownerTab:AddRightGroupbox("Telemetry")
		right:AddLabel("msfent-api worker", true)
		right:AddButton({
			Text = "Force telemetry ping",
			Func = function()
				if __MsFent_SendTelemetry then
					__MsFent_SendTelemetry("Ms fent Owner ping")
				end
			end,
		})
	end)
	if not ok then warn("[Ms fent] Owner tab error", err) end
end)

