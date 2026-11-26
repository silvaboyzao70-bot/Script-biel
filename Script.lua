--========================================================
-- PAINEL CNP BIEL975OI (TIKTOK: _LONGLIIFEE)
--========================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local cam = workspace.CurrentCamera

for _, guiName in ipairs({ "PainelCNP", "Erick_Ultra_Hub", "Lup_Jump_Hub" }) do
	if CoreGui:FindFirstChild(guiName) then
		CoreGui[guiName]:Destroy()
	end
end

--========================
-- CORES DO TEMA (PRETO + ROXO + BRANCO)
--========================
local COLOR_BG_MAIN      = Color3.fromRGB(16, 16, 20)
local COLOR_BG_HEADER    = Color3.fromRGB(24, 20, 34)
local COLOR_BTN_OFF      = Color3.fromRGB(228, 84, 96)
local COLOR_BTN_ON       = Color3.fromRGB(82, 198, 118)
local COLOR_BTN_EXEC     = Color3.fromRGB(30, 26, 42)
local COLOR_BTN_ACTIVE   = Color3.fromRGB(115, 62, 195)
local COLOR_TOGGLE_BG    = Color3.fromRGB(22, 18, 32)
local COLOR_STROKE_MAIN  = Color3.fromRGB(152, 102, 235)
local COLOR_STROKE_BTN   = Color3.fromRGB(152, 102, 235)
local COLOR_TEXT_WHITE   = Color3.fromRGB(255, 255, 255)
local COLOR_TEXT_SUB     = Color3.fromRGB(240, 235, 255)

--========================
-- TAMANHOS DISPONÍVEIS
--========================
local PANEL_SIZES = {
	Pequeno = UDim2.new(0, 205, 0, 295),
	Medio   = UDim2.new(0, 245, 0, 350),
	Grande  = UDim2.new(0, 275, 0, 385),
}
local SIZE_CYCLE = { "Pequeno", "Medio", "Grande" }

--========================
-- CONFIG DO SCRIPT
--========================
local SIDE_ACCEL = 210
local SIDE_MAX_SPEED = 210
local TURN_SPEED_BONUS = 45
local TURN_ACCEL_BONUS = 135

local BOOST_FORCE = 110
local BOOST_COOLDOWN = 0.20
local TURN_WINDOW = 0.35
local TURN_DEG_REQUIRED = 50

local BACK_BIAS = 1.00
local FORWARD_ONLY_DOT = 0.92
local SIDE_ONLY_MAX = 0.12

local WALL_DIST = 2.5
local MAX_VERTICAL_SPEED = 90

local INCLINE_UPVECTOR_Y = 0.7
local JUMP_INCLINE_FORCE_Y = 170
local JUMP_SPEED_BOOST = 300

local BALLOON_TOOL_NAME = "Water Balloon"
local BALLOON_COLOR = Color3.fromRGB(236, 92, 114)
local BALLOON_TIP_COLOR = Color3.fromRGB(132, 36, 54)
local BALLOON_SPLASH_COLOR = Color3.fromRGB(130, 215, 255)
local BALLOON_SPEED = 105
local BALLOON_COOLDOWN = 0.20

local REMOTE_URLS = {
	coins = "https://raw.githubusercontent.com/oipdrin971-source/mm2-script/main/anti_coins_mm2.lua",
	yd7   = "https://raw.githubusercontent.com/7yd7/Hub/refs/heads/Branch/GUIS/Emotes.lua",
	alt   = "https://pastefy.app/w0BKiXTR/raw",
	mira  = "https://pastebin.com/raw/UVB1v26b",
	v2    = "https://scriptblox.com/raw/Universal-Script-Gold-bomb-script-223141",
}

--========================
-- STATE
--========================
local deviceType = nil
local currentSizeName = "Medio"

local spOn = false
local man = false
local jpOn = false
local ltOn = false
local blOn = false
local acOn = false
local nrOn = false
local miraOn = false

local loaded = {}
local char, hum, hrp
local baseWalkSpeed = 16
local dirPressed = nil
local pendingTurn = nil
local lastBoost = 0
local lastBalloonThrow = 0
local lastYaw = nil

local lightingBackup = nil
local lightingObjects = {}

local emoteActive = false
local emoteTracks = {}
local holdingS = false
local holdingAD = false
local debounceCombo = false

local animPlayedConn, toolAddedConn, toolRemovedConn, inclineJumpConn, jumpBoostConn

--========================
-- HELPERS
--========================
local function notify(text, dur)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = "PAINEL CNP BIEL975OI",
			Text = tostring(text or ""),
			Duration = dur or 2
		})
	end)
end

local function flat(v)
	local xz = Vector3.new(v.X, 0, v.Z)
	return xz.Magnitude < 1e-6 and Vector3.zero or xz.Unit
end

local function wrap(a)
	return (a + math.pi) % (2 * math.pi) - math.pi
end

local function getYaw()
	local lv = cam.CFrame.LookVector
	return math.atan2(lv.X, lv.Z)
end

local function inAir()
	return hum and hum.FloorMaterial == Enum.Material.Air and hum:GetState() ~= Enum.HumanoidStateType.Climbing
end

local function wallBlocked(d)
	if not hrp or not char then return false end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { char }
	return workspace:Raycast(hrp.Position, d * WALL_DIST, params) ~= nil
end

local function setVel(v)
	if hrp then
		hrp.AssemblyLinearVelocity = Vector3.new(
			v.X,
			math.clamp(v.Y, -MAX_VERTICAL_SPEED, MAX_VERTICAL_SPEED),
			v.Z
		)
	end
end

local function isSheriff()
	local bp = player:FindFirstChild("Backpack")
	if bp and (bp:FindFirstChild("Sheriff") or bp:FindFirstChild("Gun")) then return true end
	if char and (char:FindFirstChild("Sheriff") or char:FindFirstChild("Gun")) then return true end

	local ok, res = pcall(function()
		local rf = ReplicatedStorage:FindFirstChild("GetPlayerData") or ReplicatedStorage:FindFirstChildWhichIsA("RemoteFunction", true)
		if rf and rf:IsA("RemoteFunction") then
			local data = rf:InvokeServer()
			if type(data) == "table" and data[player.Name] and tostring(data[player.Name].Role):lower():find("sheriff", 1, true) then
				return true
			end
		end
		for _, obj in ipairs(player:GetDescendants()) do
			if (obj:IsA("StringValue") or obj:IsA("ObjectValue")) and tostring(obj.Value):lower():find("sheriff", 1, true) then
				return true
			end
		end
		return false
	end)

	return ok and res or false
end

local function hasWaterBalloon()
	if char then
		for _, obj in ipairs(char:GetChildren()) do
			if obj:IsA("Tool") and obj.Name:lower():find("balloon", 1, true) then
				return true
			end
		end
	end
	local bp = player:FindFirstChild("Backpack")
	if bp then
		for _, obj in ipairs(bp:GetChildren()) do
			if obj:IsA("Tool") and obj.Name:lower():find("balloon", 1, true) then
				return true
			end
		end
	end
	return false
end

local function isEmoteWheelTrack(track)
	if not track then return false end
	local nm = (track.Name or ""):lower()
	local id = track.Animation and tostring(track.Animation.AnimationId or ""):lower() or ""
	if nm:find("yungblud", 1, true) or nm:find("salto", 1, true) or nm:find("feliz", 1, true) or id:find("yungblud", 1, true) then
		return true
	end
	local p = track.Priority
	return (p == Enum.AnimationPriority.Action
		or p == Enum.AnimationPriority.Action2
		or p == Enum.AnimationPriority.Action3
		or p == Enum.AnimationPriority.Action4)
		and not nm:find("dance", 1, true)
		and not id:find("dance", 1, true)
end

--========================
-- GRÁFICO 2020
--========================
local function clearLighting2020()
	for _, obj in ipairs(lightingObjects) do
		if obj and obj.Parent then
			obj:Destroy()
		end
	end
	lightingObjects = {}
end

local function setGrafico2020(on)
	if on then
		if not lightingBackup then
			local saved = {}
			for _, item in ipairs(Lighting:GetChildren()) do
				if item:IsA("PostEffect") or item:IsA("Sky") or item:IsA("Atmosphere") then
					pcall(function()
						table.insert(saved, item:Clone())
					end)
				end
			end
			lightingBackup = {
				Brightness = Lighting.Brightness,
				Ambient = Lighting.Ambient,
				OutdoorAmbient = Lighting.OutdoorAmbient,
				GlobalShadows = Lighting.GlobalShadows,
				ClockTime = Lighting.ClockTime,
				Children = saved
			}
		end

		clearLighting2020()
		for _, item in ipairs(Lighting:GetChildren()) do
			if item:IsA("PostEffect") or item:IsA("Sky") or item:IsA("Atmosphere") then
				item:Destroy()
			end
		end

		Lighting.Brightness = 2.5
		Lighting.Ambient = Color3.fromRGB(145, 145, 145)
		Lighting.OutdoorAmbient = Color3.fromRGB(165, 165, 165)
		Lighting.GlobalShadows = false
		Lighting.ClockTime = 14

		local cc = Instance.new("ColorCorrectionEffect", Lighting)
		cc.Brightness, cc.Contrast, cc.Saturation = 0.06, 0.18, 0.25

		local bl = Instance.new("BloomEffect", Lighting)
		bl.Intensity, bl.Size, bl.Threshold = 0.3, 20, 1.3

		table.insert(lightingObjects, cc)
		table.insert(lightingObjects, bl)
	else
		clearLighting2020()
		if not lightingBackup then return end
		for _, item in ipairs(Lighting:GetChildren()) do
			if item:IsA("PostEffect") or item:IsA("Sky") or item:IsA("Atmosphere") then
				item:Destroy()
			end
		end
		Lighting.Brightness = lightingBackup.Brightness
		Lighting.Ambient = lightingBackup.Ambient
		Lighting.OutdoorAmbient = lightingBackup.OutdoorAmbient
		Lighting.GlobalShadows = lightingBackup.GlobalShadows
		Lighting.ClockTime = lightingBackup.ClockTime
		for _, c in ipairs(lightingBackup.Children) do
			pcall(function()
				c:Clone().Parent = Lighting
			end)
		end
	end
end

--========================
-- REFERÊNCIAS DE UI
--========================
local MainFrame
local SizeCycleBtn
local SmallSizeBtn, MediumSizeBtn, LargeSizeBtn
local SpeedBtn, JumpSpeedBtn, InclineBtn, Lighting2020Btn
local AntiCoinsBtn, AntiClickBtn, NoReloadBtn, WaterBalloonBtn, MiraBtn
local Yd7EmotesBtn, AltPanelBtn, V2PanelBtn
local StatusLabel
local ExtraFrame, ExtraAntiBtn, ExtraReloadBtn
local JumpFrame, JumpToggleBtn

local function applyPanelSize(sizeName)
	local target = PANEL_SIZES[sizeName] or PANEL_SIZES.Medio
	currentSizeName = sizeName

	if MainFrame then
		MainFrame.Size = target
		MainFrame.Position = UDim2.new(0.5, -target.X.Offset / 2, 0.5, -target.Y.Offset / 2)
	end
	if SizeCycleBtn then
		SizeCycleBtn.Text = "Tamanho: " .. currentSizeName
	end
	if SmallSizeBtn then SmallSizeBtn.BackgroundColor3 = (currentSizeName == "Pequeno") and COLOR_BTN_ACTIVE or COLOR_BTN_EXEC end
	if MediumSizeBtn then MediumSizeBtn.BackgroundColor3 = (currentSizeName == "Medio") and COLOR_BTN_ACTIVE or COLOR_BTN_EXEC end
	if LargeSizeBtn then LargeSizeBtn.BackgroundColor3 = (currentSizeName == "Grande") and COLOR_BTN_ACTIVE or COLOR_BTN_EXEC end
end

local function setJumpSpeedState(ativo)
	jpOn = ativo
	if not jpOn and hum then
		hum.WalkSpeed = baseWalkSpeed
		dirPressed = nil
	end
	if JumpToggleBtn then
		JumpToggleBtn.Text = jpOn and "Sistema: ON" or "Sistema: OFF"
		JumpToggleBtn.TextColor3 = COLOR_TEXT_WHITE
		JumpToggleBtn.BackgroundColor3 = jpOn and COLOR_BTN_ON or COLOR_BTN_OFF
	end
	if JumpSpeedBtn then
		JumpSpeedBtn.Text = jpOn and "Impulso no Pulo: ON" or "Impulso no Pulo: OFF"
		JumpSpeedBtn.TextColor3 = COLOR_TEXT_WHITE
		JumpSpeedBtn.BackgroundColor3 = jpOn and COLOR_BTN_ON or COLOR_BTN_OFF
	end
	if JumpFrame then
		JumpFrame.Visible = jpOn
	end
end

local function updateUI()
	local toggleRows = {
		{ SpeedBtn, spOn, "Old Speed: ON", "Old Speed: OFF" },
		{ JumpSpeedBtn, jpOn, "Impulso no Pulo: ON", "Impulso no Pulo: OFF" },
		{ Lighting2020Btn, ltOn, "2020 grafico: ON", "2020 grafico: OFF" },
		{ AntiClickBtn, acOn, "ANTI-CLICK: ON", "ANTI-CLICK: OFF" },
		{ NoReloadBtn, nrOn, "NO RELOAD: ON", "NO RELOAD: OFF" },
		{ WaterBalloonBtn, blOn, "Water Balloon: ON", "Water Balloon: OFF" },
		{ MiraBtn, miraOn, "Mira Mobilador: ON", "Mira Mobilador: OFF" },
	}

	for _, row in ipairs(toggleRows) do
		local btn = row[1]
		if btn then
			btn.Text = row[2] and row[3] or row[4]
			btn.TextColor3 = COLOR_TEXT_WHITE
			btn.BackgroundColor3 = row[2] and COLOR_BTN_ON or COLOR_BTN_OFF
		end
	end

	if ExtraAntiBtn then
		ExtraAntiBtn.Text = acOn and "ANTI-CLICK: ON" or "ANTI-CLICK: OFF"
		ExtraAntiBtn.TextColor3 = COLOR_TEXT_WHITE
		ExtraAntiBtn.BackgroundColor3 = acOn and COLOR_BTN_ON or COLOR_BTN_OFF
	end
	if ExtraReloadBtn then
		ExtraReloadBtn.Text = nrOn and "NO RELOAD: ON" or "NO RELOAD: OFF"
		
