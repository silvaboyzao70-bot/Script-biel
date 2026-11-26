--========================================================
-- PAINEL CNP BIEL975OI + SELETOR PC/CELULAR + TAMANHO AJUSTÁVEL + AIR SPEED / BOOST + JUMP SPEED + INCLINE JUMP + LIGHTING 2020 + ANTI COINS + ANTI-CLICK / NO RELOAD + GUN CROSSHAIR + WATER BALLOON + EMOTES + 7YD7 EMOTES
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

-- Remove versão anterior do painel se já existir
if CoreGui:FindFirstChild("PainelCNP") then
	CoreGui.PainelCNP:Destroy()
end

--========================
-- CORES DO TEMA (AMARELO CLARO COM TOM BRANCO)
--========================
local COLOR_BG_MAIN      = Color3.fromRGB(255, 253, 232) -- Amarelo bem claro com tom branco
local COLOR_BG_HEADER    = Color3.fromRGB(255, 250, 212) -- Cabeçalho creme claro
local COLOR_BTN_OFF      = Color3.fromRGB(255, 254, 240) -- Botão desligado (amarelo pastel/branco)
local COLOR_BTN_ON       = Color3.fromRGB(255, 244, 178) -- Botão ligado/ativo (amarelo claro destacado)
local COLOR_TOGGLE_BG    = Color3.fromRGB(255, 252, 224) -- Botão flutuante da engrenagem
local COLOR_STROKE_MAIN  = Color3.fromRGB(225, 214, 155) -- Borda suave
local COLOR_STROKE_BTN   = Color3.fromRGB(215, 202, 140) -- Borda dos botões
local COLOR_TEXT_DARK    = Color3.fromRGB(48, 44, 24)    -- Texto escuro legível
local COLOR_TEXT_MUTED   = Color3.fromRGB(105, 96, 54)   -- Texto secundário

--========================
-- TAMANHOS DISPONÍVEIS DO PAINEL
--========================
local PANEL_SIZES = {
	Pequeno = UDim2.new(0, 210, 0, 295),
	Medio   = UDim2.new(0, 250, 0, 355),
	Grande  = UDim2.new(0, 300, 0, 420),
}
local SIZE_CYCLE = { "Pequeno", "Medio", "Grande" }

--========================
-- CONFIG DO SCRIPT
--========================
local ENABLED_DEFAULT = false -- começa OFF

local SIDE_ACCEL = 210
local SIDE_MAX_SPEED = 210

local BOOST_FORCE = 110
local BOOST_COOLDOWN = 0.20
local TURN_WINDOW = 0.35
local TURN_DEG_REQUIRED = 50

local BACK_BIAS = 1.00

local FORWARD_ONLY_DOT = 0.92
local SIDE_ONLY_MAX = 0.12

local WALL_DIST = 2.5
local MAX_VERTICAL_SPEED = 90

-- IMPULSO PULO INCLINADO
local INCLINE_UPVECTOR_Y = 0.7
local JUMP_INCLINE_FORCE_Y = 170

-- IMPULSO NO PULO (A/D/S OU NÃO-FRENTE)
local JUMP_SPEED_BOOST = 700 -- ajuste aqui se quiser menos

-- WATER BALLOON (VISUAL - BASEADO NA IMAGEM ENVIADA)
local BALLOON_TOOL_NAME = "Water Balloon"
local BALLOON_ASSET_ID = "" -- se tiver um rbxassetid:// dessa imagem, coloque aqui
local BALLOON_COLOR = Color3.fromRGB(228, 86, 108)
local BALLOON_TIP_COLOR = Color3.fromRGB(145, 42, 62)
local BALLOON_SPLASH_COLOR = Color3.fromRGB(125, 215, 255)
local BALLOON_SPEED = 95
local BALLOON_COOLDOWN = 0.25

-- LINKS EXTERNOS
local ANTI_COINS_URL = "https://raw.githubusercontent.com/oipdrin971-source/mm2-script/main/anti_coins_mm2.lua"
local YD7_EMOTES_URL = "https://raw.githubusercontent.com/7yd7/Hub/refs/heads/Branch/GUIS/Emotes.lua"
local EXTRA_PASTE_URL = "https://api.pastes.dev/WICaOZ4GgY"
local ALTERNATIVE_PANEL_URL = "https://pastefy.app/w0BKiXTR/raw"

-- GUN CROSSHAIR
local WHITE_CROSSHAIR = "rbxassetid://85711744324486"
local TARGET_TOOL_NAME = "Gun"

--========================
-- STATE
--========================
local deviceType = nil -- "Computador" ou "Celular"
local currentSizeName = "Medio"

local enabled = ENABLED_DEFAULT
local manualOverride = false -- quando true, o botão ON/OFF mantém ligado
local jumpSpeedAtivo = false
local lighting2020Ativo = false
local waterBalloonAtivo = false
local antiCoinsLoaded = false
local yd7EmotesLoaded = false
local extraPasteLoaded = false
local alternativePanelLoaded = false
local antiClickAtivo = false
local noReloadAtivo = false
local crosshairAtivo = false

local char, hum, hrp
local baseWalkSpeed = 16
local direcaoPressionada = nil -- "A", "D", "S" ou nil
local pendingTurn = nil
local lastBoost = 0
local lastBalloonThrow = 0

-- Backup de iluminação para restaurar ao desligar
local lightingBackup = nil
local lighting2020Objects = {}

-- Emote state
local emoteActive = false
local emoteTracks = {} -- [track] = true

local toolConnAdded, toolConnRemoved
local animPlayedConn
local debounceToolEvent = false

-- input states (pulo inclinado)
local holdingS = false
local holdingAD = false

-- connections por personagem (pra não duplicar)
local jumpConn
local jumpBoostConn
local landedConn

--========================
-- NOTIFICAÇÃO
--========================
local function notify(title, text, dur)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = tostring(title or "Painel CNP Biel975oi"),
			Text = tostring(text or ""),
			Duration = dur or 2.5
		})
	end)
end

--========================
-- HELPERS
--========================
local function flat(v)
	local xz = Vector3.new(v.X, 0, v.Z)
	if xz.Magnitude < 1e-6 then return Vector3.zero end
	return xz.Unit
end

local function camForward() return flat(cam.CFrame.LookVector) end
local function camRight()   return flat(cam.CFrame.RightVector) end

local function charRight()  return flat(hrp.CFrame.RightVector) end
local function charBack()   return -flat(hrp.CFrame.LookVector) end

local function wrap(a)
	return (a + math.pi) % (2 * math.pi) - math.pi
end

local function getYaw()
	local lv = cam.CFrame.LookVector
	return math.atan2(lv.X, lv.Z)
end

local function inAir()
	if not hum then return false end
	if hum.FloorMaterial ~= Enum.Material.Air then return false end
	return hum:GetState() ~= Enum.HumanoidStateType.Climbing
end

local function wallBlocked(dir)
	if not hrp or not char then return false end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {char}
	return workspace:Raycast(hrp.Position, dir * WALL_DIST, params) ~= nil
end

local function setVel(v)
	if not hrp then return end
	hrp.AssemblyLinearVelocity = Vector3.new(
		v.X,
		math.clamp(v.Y, -MAX_VERTICAL_SPEED, MAX_VERTICAL_SPEED),
		v.Z
	)
end

--========================
-- ILUMINAÇÃO ESTILO 2020
--========================
local function clearLighting2020Effects()
	for _, obj in ipairs(lighting2020Objects) do
		if obj and obj.Parent then
			obj:Destroy()
		end
	end
	lighting2020Objects = {}
end

local function captureLightingBackup()
	local savedChildren = {}
	for _, item in ipairs(Lighting:GetChildren()) do
		if item:IsA("PostEffect") or item:IsA("Sky") or item:IsA("Atmosphere") then
			pcall(function()
				table.insert(savedChildren, item:Clone())
			end)
		end
	end

	lightingBackup = {
		Brightness = Lighting.Brightness,
		Ambient = Lighting.Ambient,
		OutdoorAmbient = Lighting.OutdoorAmbient,
		GlobalShadows = Lighting.GlobalShadows,
		ClockTime = Lighting.ClockTime,
		Children = savedChildren
	}
end

local function applyLighting2020()
	if not lightingBackup then
		captureLightingBackup()
	end

	clearLighting2020Effects()

	for _, item in ipairs(Lighting:GetChildren()) do
		if item:IsA("PostEffect") or item:IsA("Sky") or item:IsA("Atmosphere") then
			item:Destroy()
		end
	end

	Lighting.Brightness = 2.2
	Lighting.Ambient = Color3.fromRGB(115, 115, 115)
	Lighting.OutdoorAmbient = Color3.fromRGB(140, 140, 140)
	Lighting.GlobalShadows = true
	Lighting.ClockTime = 14.5

	local colorCorrection = Instance.new("ColorCorrectionEffect")
	colorCorrection.Name = "CNP_ColorCorrection2020"
	colorCorrection.Brightness = 0.05
	colorCorrection.Contrast = 0.25
	colorCorrection.Saturation = 0.3
	colorCorrection.Parent = Lighting
	table.insert(lighting2020Objects, colorCorrection)

	local bloom = Instance.new("BloomEffect")
	bloom.Name = "CNP_Bloom2020"
	bloom.Intensity = 0.4
	bloom.Size = 24
	bloom.Threshold = 1.2
	bloom.Parent = Lighting
	table.insert(lighting2020Objects, bloom)

	local sunRays = Instance.new("SunRaysEffect")
	sunRays.Name = "CNP_SunRays2020"
	sunRays.Intensity = 0.15
	sunRays.Spread = 0.8
	sunRays.Parent = Lighting
	table.insert(lighting2020Objects, sunRays)
end

local function restoreLightingBackup()
	clearLighting2020Effects()

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

	for _, cloned in ipairs(lightingBackup.Children) do
		pcall(function()
			cloned:Clone().Parent = Lighting
		end)
	end
end

--========================
-- INTERFACE DO PAINEL (REFERÊNCIAS)
--========================
local MainFrame
local SizeCycleBtn
local SmallSizeBtn
local MediumSizeBtn
local LargeSizeBtn
local SpeedBtn
local JumpSpeedBtn
local InclineBtn
local Lighting2020Btn
local AntiCoinsBtn
local AntiClickBtn
local NoReloadBtn
local CrosshairBtn
local WaterBalloonBtn
local Yd7EmotesBtn
local ExtraPasteBtn
local AlternativePanelBtn
local StatusLabel

local function applyPanelSize(sizeName)
	local targetSize = PANEL_SIZES[sizeName] or PANEL_SIZES.Medio
	currentSizeName = sizeName

	if MainFrame then
		MainFrame.Size = targetSize
		MainFrame.Position = UDim2.new(0.5, -targetSize.X.Offset / 2, 0.5, -targetSize.Y.Offset / 2)
	end

	if SizeCycleBtn then
		SizeCycleBtn.Text = "Tamanho: " .. currentSizeName
	end
	if SmallSizeBtn then
		SmallSizeBtn.BackgroundColor3 = (currentSizeName == "Pequeno") and COLOR_BTN_ON or COLOR_BTN_OFF
	end
	if MediumSizeBtn then
		MediumSizeBtn.BackgroundColor3 = (currentSizeName == "Medio") and COLOR_BTN_ON or COLOR_BTN_OFF
	end
	if LargeSizeBtn then
		LargeSizeBtn.BackgroundColor3 = (currentSizeName == "Grande") and COLOR_BTN_ON or COLOR_BTN_OFF
	end
end

local function cyclePanelSize()
	local idx = 1
	for i, name in ipairs(SIZE_CYCLE) do
		if name == currentSizeName then
			idx = i
			break
		end
	end
	local nextName = SIZE_CYCLE[(idx % #SIZE_CYCLE) + 1]
	applyPanelSize(nextName)
end

local function updatePanelUI()
	if SpeedBtn then
		if enabled then
			SpeedBtn.Text = "Speed: ON"
			SpeedBtn.BackgroundColor3 = COLOR_BTN_ON
		else
			SpeedBtn.Text = "Speed: OFF"
			SpeedBtn.BackgroundColor3 = COLOR_BTN_OFF
		end
	end
	if JumpSpeedBtn then
		JumpSpeedBtn.Text = jumpSpeedAtivo and "Impulso no Pulo: ON" or "Impulso no Pulo: OFF"
		JumpSpeedBtn.BackgroundColor3 = jumpSpeedAtivo and COLOR_BTN_ON or COLOR_BTN_OFF
	end
	if Lighting2020Btn then
		Lighting2020Btn.Text = lighting2020Ativo and "Iluminação 2020: ON" or "Iluminação 2020: OFF"
		Lighting2020Btn.BackgroundColor3 = lighting2020Ativo and COLOR_BTN_ON or COLOR_BTN_OFF
	end
	if AntiCoinsBtn then
		if antiCoinsLoaded then
			AntiCoinsBtn.Text = "Anti Coins MM2: ATIVO"
			AntiCoinsBtn.BackgroundColor3 = COLOR_BTN_ON
		else
			AntiCoinsBtn.Text = "Anti Coins MM2: EXECUTAR"
			AntiCoinsBtn.BackgroundColor3 = COLOR_BTN_OFF
		end
	end
	if AntiClickBtn then
		AntiClickBtn.Text = antiClickAtivo and "ANTI-CLICK: ON" or "ANTI-CLICK: OFF"
		AntiClickBtn.BackgroundColor3 = antiClickAtivo and COLOR_BTN_ON or COLOR_BTN_OFF
	end
	if NoReloadBtn then
		NoReloadBtn.Text = noReloadAtivo and "NO RELOAD: ON" or "NO RELOAD: OFF"
		NoReloadBtn.BackgroundColor3 = noReloadAtivo and COLOR_BTN_ON or COLOR_BTN_OFF
	end
	if CrosshairBtn then
		CrosshairBtn.Text = crosshairAtivo and "Crosshair Gun: ON" or "Crosshair Gun: OFF"
		CrosshairBtn.BackgroundColor3 = crosshairAtivo and COLOR_BTN_ON or COLOR_BTN_OFF
	end
	if WaterBalloonBtn then
		WaterBalloonBtn.Text = waterBalloonAtivo and "Water Balloon: ON" or "Water Balloon: OFF"
		WaterBalloonBtn.BackgroundColor3 = waterBalloonAtivo and COLOR_BTN_ON or COLOR_BTN_OFF
	end
	if Yd7EmotesBtn then
		if yd7EmotesLoaded then
			Yd7EmotesBtn.Text = "7yd7 Emotes: ATIVO"
			Yd7EmotesBtn.BackgroundColor3 = COLOR_BTN_ON
		else
			Yd7EmotesBtn.Text = "7yd7 Emotes: EXECUTAR"
			Yd7EmotesBtn.BackgroundColor3 = COLOR_BTN_OFF
		end
	end
	if ExtraPasteBtn then
		if extraPasteLoaded then
			ExtraPasteBtn.Text = "Script Externo: ATIVO"
			ExtraPasteBtn.BackgroundColor3 = COLOR_BTN_ON
		else
			ExtraPasteBtn.Text = "Script Externo: EXECUTAR"
			ExtraPasteBtn.BackgroundColor3 = COLOR_BTN_OFF
		end
	end
	if AlternativePanelBtn then
		if alternativePanelLoaded then
			AlternativePanelBtn.Text = "Painel Alternativo: ATIVO"
			AlternativePanelBtn.BackgroundColor3 = COLOR_BTN_ON
		else
			AlternativePanelBtn.Text = "Painel Alternativo: EXECUTAR"
			AlternativePanelBtn.BackgroundColor3 = COLOR_BTN_OFF
		end
	end
	if StatusLabel then
		local stateTxt = enabled and "ATIVADO" or "DESATIVADO"
		local modeTxt = manualOverride and "Botão ON" or "Auto"
		local devTxt = deviceType and (" | " .. deviceType) or ""
		StatusLabel.Text = "Status: " .. stateTxt .. " (" .. modeTxt .. ")" .. devTxt
	end
	applyPanelSize(currentSizeName)
end

local function setLighting2020State(ativo)
	lighting2020Ativo = ativo
	if lighting2020Ativo then
		applyLighting2020()
		notify("Painel CNP Biel975oi", "Iluminação 2020 ativada.", 2)
	else
		restoreLightingBackup()
		notify("Painel CNP Biel975oi", "Iluminação restaurada.", 2)
	end
	updatePanelUI()
end

--========================
-- EMOTES (PLAY EMOTE)
--========================
local function playEmoteName(emoteName)
	local remote = ReplicatedStorage:FindFirstChild("PlayEmote")
	if remote then
		pcall(function()
			remote:Fire(emoteName)
		end)
	else
		notify("Painel CNP Biel975oi", "Evento PlayEmote não encontrado neste mapa.", 2)
	end
end

--========================
-- WATER BALLOON (VISUAL + EFEITO D'ÁGUA)
--========================
local function enableGameBar()
	pcall(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
	end)
end

local function buildBalloonModel(cframe, anchored)
	local model = Instance.new("Model")
	model.Name = "WaterBalloonModel"

	local body = Instance.new("Part")
	body.Name = "Body"
	body.Shape = Enum.PartType.Ball
	body.Size = Vector3.new(1.3, 1.55, 1.3)
	body.Material = Enum.Material.SmoothPlastic
	body.Color = BALLOON_COLOR
	body.Transparency = 0.08
	body.Anchored = anchored
	body.CanCollide = false
	body.CanQuery = false
	body.CanTouch = false
	body.CFrame = cframe
	body.Parent = model

	local knot = Instance.new("Part")
	knot.Name = "Knot"
	knot.Size = Vector3.new(0.65, 0.22, 0.45)
	knot.Material = Enum.Material.SmoothPlastic
	knot.Color = BALLOON_TIP_COLOR
	knot.Transparency = 0.05
	knot.Anchored = anchored
	knot.CanCollide = false
	knot.CanQuery = false
	knot.CanTouch = false
	knot.CFrame = cframe * CFrame.new(0, 0.82, 0)
	knot.Parent = model

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = body
	weld.Part1 = knot
	weld.Parent = body

	model.PrimaryPart = body
	return model, body
end

local function spawnWaterSplash(position)
	local fxHolder = Instance.new("Part")
	fxHolder.Name = "WaterBalloonSplashVisual"
	fxHolder.Size = Vector3.new(0.5, 0.5, 0.5)
	fxHolder.Position = position
	fxHolder.Anchored = true
	fxHolder.CanCollide = false
	fxHolder.CanQuery = false
	fxHolder.CanTouch = false
	fxHolder.Transparency = 1
	fxHolder.Parent = workspace

	local emitter = Instance.new("ParticleEmitter")
	emitter.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, BALLOON_SPLASH_COLOR),
		ColorSequenceKeypoint.new(0.6, BALLOON_COLOR),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(235, 250, 255))
	})
	emitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(0.5, 0.95),
		NumberSequenceKeypoint.new(1, 0.08)
	})
	emitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.1),
		NumberSequenceKeypoint.new(1, 1)
	})
	emitter.Lifetime = NumberRange.new(0.25, 0.55)
	emitter.Speed = NumberRange.new(9, 22)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Drag = 6
	emitter.Rate = 0
	emitter.Parent = fxHolder

	emitter:Emit(28)
	Debris:AddItem(fxHolder, 1.2)
end

local function throwVisualWaterBalloon(originPos)
	if os.clock() - lastBalloonThrow < BALLOON_COOLDOWN then return end
	lastBalloonThrow = os.clock()

	local targetPos = (mouse and mouse.Hit) and mouse.Hit.Position or (originPos + cam.CFrame.LookVector * 50)
	local dir = (targetPos - originPos)
	if dir.Magnitude < 0.1 then
		dir = cam.CFrame.LookVector
	else
		dir = dir.Unit
	end

	local startCFrame = CFrame.new(originPos + dir * 2.2, targetPos)
	local balloonModel, body = buildBalloonModel(startCFrame, true)
	balloonModel.Parent = workspace

	local trail = Instance.new("Trail")
	local att0 = Instance.new("Attachment", body)
	att0.Position = Vector3.new(0, 0.45, 0)
	local att1 = Instance.new("Attachment", body)
	att1.Position = Vector3.new(0, -0.45, 0)
	trail.Attachment0 = att0
	trail.Attachment1 = att1
	trail.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, BALLOON_COLOR),
		ColorSequenceKeypoint.new(1, BALLOON_SPLASH_COLOR)
	})
	trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(1, 1)
	})
	trail.Lifetime = 0.18
	trail.Parent = body

	local exploded = false
	local vel = dir * BALLOON_SPEED + Vector3.new(0, 8, 0)
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = {char, balloonModel}

	local stepConn
	stepConn = RunService.RenderStepped:Connect(function(dt)
		if exploded or not balloonModel.Parent or not body.Parent then
			if stepConn then stepConn:Disconnect() end
			return
		end

		vel = vel + Vector3.new(0, -workspace.Gravity * 0.35 * dt, 0)
		local displacement = vel * dt
		local hit = workspace:Raycast(body.Position, displacement, rayParams)

		if hit then
			exploded = true
			if stepConn then stepConn:Disconnect() end
			spawnWaterSplash(hit.Position)
			balloonModel:Destroy()
			return
		end

		local nextPos = body.Position + displacement
		body.CFrame = CFrame.new(nextPos, nextPos + vel.Unit)
	end)

	Debris:AddItem(balloonModel, 4)
end

local function createVisualBalloonTool()
	local backpack = player:FindFirstChild("Backpack")
	if not backpack then return end

	if backpack:FindFirstChild(BALLOON_TOOL_NAME) then
		backpack[BALLOON_TOOL_NAME]:Destroy()
	end
	if char and char:FindFirstChild(BALLOON_TOOL_NAME) then
		char[BALLOON_TOOL_NAME]:Destroy()
	end

	local tool = Instance.new("Tool")
	tool.Name = BALLOON_TOOL_NAME
	tool.RequiresHandle = true
	tool.CanBeDropped = false
	if BALLOON_ASSET_ID ~= "" then
		tool.TextureId = BALLOON_ASSET_ID
	end

	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Shape = Enum.PartType.Ball
	handle.Size = Vector3.new(1.15, 1.4, 1.15)
	handle.Color = BALLOON_COLOR
	handle.Material = Enum.Material.SmoothPlastic
	handle.Transparency = 0.08
	handle.CanCollide = false
	handle.Parent = tool

	local knot = Instance.new("Part")
	knot.Name = "Knot"
	knot.Size = Vector3.new(0.6, 0.2, 0.42)
	knot.Color = BALLOON_TIP_COLOR
	knot.Material = Enum.Material.SmoothPlastic
	knot.Transparency = 0.05
	knot.CanCollide = false
	knot.Parent = tool

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = handle
	weld.Part1 = knot
	weld.Parent = handle

	tool.Equipped:Connect(function()
		knot.CFrame = handle.CFrame * CFrame.new(0, 0.75, 0)
	end)

	tool.Activated:Connect(function()
		if not waterBalloonAtivo then return end
		local startPos = handle and handle.Position or (hrp and hrp.Position + Vector3.new(0, 2, 0))
		if startPos then
			throwVisualWaterBalloon(startPos)
		end
	end)

	tool.Parent = backpack
	if hum then
		pcall(function()
			hum:EquipTool(tool)
		end)
	end
end

local function removeVisualBalloonTool()
	local backpack = player:FindFirstChild("Backpack")
	if backpack and backpack:FindFirstChild(BALLOON_TOOL_NAME) then
		backpack[BALLOON_TOOL_NAME]:Destroy()
	end
	if char and char:FindFirstChild(BALLOON_TOOL_NAME) then
		char[BALLOON_TOOL_NAME]:Destroy()
	end
end

local function setWaterBalloonState(ativo)
	waterBalloonAtivo = ativo
	enableGameBar()
	if waterBalloonAtivo then
		createVisualBalloonTool()
		notify("Painel CNP Biel975oi", "Water Balloon ativado na game bar.", 2)
	else
		removeVisualBalloonTool()
		notify("Painel CNP Biel975oi", "Water Balloon removido.", 2)
	end
	updatePanelUI()
end

--========================
-- GUN CROSSHAIR
--========================
local function setCrosshairState(ativo)
	crosshairAtivo = ativo
	if crosshairAtivo then
		mouse.Icon = WHITE_CROSSHAIR
	else
		mouse.Icon = ""
	end
	updatePanelUI()
end

local function monitorarTool(tool)
	if not tool:IsA("Tool") or tool.Name ~= TARGET_TOOL_NAME then return end
	if tool:GetAttribute("CrosshairConectado") then return end
	tool:SetAttribute("CrosshairConectado", true)

	tool.Equipped:Connect(function()
		setCrosshairState(true)
	end)

	tool.Unequipped:Connect(function()
		setCrosshairState(false)
	end)
end

local function hookCrosshairTools(character)
	setCrosshairState(false)

	for _, child in ipairs(character:GetChildren()) do
		monitorarTool(child)
	end
	character.ChildAdded:Connect(monitorarTool)

	local backpack = player:WaitForChild("Backpack")
	for _, tool in ipairs(backpack:GetChildren()) do
		monitorarTool(tool)
	end
	backpack.ChildAdded:Connect(monitorarTool)
end

--========================
-- EXECUTAR SCRIPTS EXTERNOS
--========================
local function isScriptLoaded(flagName)
	if flagName == "antiCoins" then return antiCoinsLoaded end
	if flagName == "yd7Emotes" then return yd7EmotesLoaded end
	if flagName == "extraPaste" then return extraPasteLoaded end
	if flagName == "alternativePanel" then return alternativePanelLoaded end
	return false
end

local function markScriptLoaded(flagName)
	if flagName == "antiCoins" then
		antiCoinsLoaded = true
	elseif flagName == "yd7Emotes" then
		yd7EmotesLoaded = true
	elseif flagName == "extraPaste" then
		extraPasteLoaded = true
	elseif flagName == "alternativePanel" then
		alternativePanelLoaded = true
	end
end

local function runRemoteScript(url, loadedFlagName, labelName)
	if isScriptLoaded(loadedFlagName) then
		notify("Painel CNP Biel975oi", labelName .. " já foi executado.", 2)
		return
	end

	local ok, err = pcall(function()
		local code = game:HttpGet(url)
		local fn = loadstring(code)
		if type(fn) == "function" then
			fn()
		else
			error("Falha ao compilar o script remoto.")
		end
	end)

	if ok then
		markScriptLoaded(loadedFlagName)
		updatePanelUI()
		notify("Painel CNP Biel975oi", labelName .. " carregado.", 2.5)
	else
		notify("Painel CNP Biel975oi", "Erro ao carregar " .. labelName .. ": " .. tostring(err), 3)
	end
end

--========================
-- DETECTAR "EMOTE DA RODELA" (via AnimationPlayed)
--========================
local function isDanceTrack(track)
	local nm = (track and track.Name or ""):lower()
	local animId = ""
	if track and track.Animation and track.Animation.AnimationId then
		animId = tostring(track.Animation.AnimationId):lower()
	end
	return (nm:find("dance", 1, true) ~= nil) or (animId:find("dance", 1, true) ~= nil)
end

local function isEmoteWheelTrack(track)
	if not track then return false end

	local p = track.Priority
	local isAction = (p == Enum.AnimationPriority.Action
		or p == Enum.AnimationPriority.Action2
		or p == Enum.AnimationPriority.Action3
		or p == Enum.AnimationPriority.Action4)

	if not isAction then return false end
	if isDanceTrack(track) then return false end

	return true
end

local function clearEmoteState()
	emoteActive = false
	emoteTracks = {}
	updatePanelUI()
end

local function refreshEmoteActive()
	for tr in pairs(emoteTracks) do
		if tr and tr.IsPlaying then
			emoteActive = true
			updatePanelUI()
			return
		end
	end
	emoteActive = false
	updatePanelUI()
end

local function hookEmoteDetector()
	if animPlayedConn then animPlayedConn:Disconnect() animPlayedConn = nil end
	clearEmoteState()
	if not hum then return end

	animPlayedConn = hum.AnimationPlayed:Connect(function(track)
		if not isEmoteWheelTrack(track) then return end

		emoteTracks[track] = true
		emoteActive = true
		updatePanelUI()

		track.Stopped:Connect(function()
			emoteTracks[track] = nil
			refreshEmoteActive()
		end)
	end)
end

--========================
-- MOVIMENTO (Air Speed + Boost)
--========================
local function getMove()
	local md = hum.MoveDirection
	if md.Magnitude < 0.05 then return md, 0 end
	local dotR = md:Dot(camRight())
	return md, dotR
end

local function isForwardOnly(md, dotR)
	return md:Dot(camForward()) >= FORWARD_ONLY_DOT
		and math.abs(dotR) <= SIDE_ONLY_MAX
end

local function applySideSpeed(dt, md, dotR)
	if not enabled or not inAir() then return end
	if md.Magnitude < 0.05 then return end
	if isForwardOnly(md, dotR) then return end

	local dir = flat(md)
	if wallBlocked(dir) then return end

	local v = hrp.AssemblyLinearVelocity
	local along = v:Dot(dir)

	if along < SIDE_MAX_SPEED then
		local add = math.min(SIDE_ACCEL * dt, SIDE_MAX_SPEED - along)
		setVel(v + dir * add)
	end
end

local function tryBoost()
	if not enabled or not pendingTurn then return end
	if not inAir() then pendingTurn = nil return end
	if os.clock() - lastBoost < BOOST_COOLDOWN then return end

	local dy = wrap(getYaw() - pendingTurn.yaw)
	local deg = math.abs(math.deg(dy))
	if deg < TURN_DEG_REQUIRED then return end

	local left = -charRight()
	local back = charBack()
	local dir = flat(left * (1 - BACK_BIAS) + back * BACK_BIAS)

	if wallBlocked(dir) then
		pendingTurn = nil
		return
	end

	setVel(hrp.AssemblyLinearVelocity + dir * BOOST_FORCE)
	lastBoost = os.clock()
	pendingTurn = nil
end

--========================
-- IMPULSO NO PULO (A/D/S OU NÃO-FRENTE)
--========================
local function isMovingForward()
	if not hum then return false end
	local move = hum.MoveDirection
	if move.Magnitude <= 0.01 then
		return false
	end
	local currentCam = workspace.CurrentCamera or cam
	if not currentCam then return false end
	local forward = currentCam.CFrame.LookVector
	local dot = forward:Dot(move.Unit)
	return dot > 0.5
end

local function setJumpSpeedState(ativo)
	jumpSpeedAtivo = ativo
	if not jumpSpeedAtivo and hum then
		hum.WalkSpeed = baseWalkSpeed
	end
	updatePanelUI()
end

local function hookJumpSpeed()
	if jumpBoostConn then jumpBoostConn:Disconnect() jumpBoostConn = nil end
	if landedConn then landedConn:Disconnect() landedConn = nil end
	if not hum then return end

	jumpBoostConn = hum.Jumping:Connect(function()
		if not jumpSpeedAtivo or not hum then return end

		if direcaoPressionada ~= nil then
			hum.WalkSpeed = baseWalkSpeed + JUMP_SPEED_BOOST
			return
		end

		if hum.MoveDirection.Magnitude > 0.01 and not isMovingForward() then
			hum.WalkSpeed = baseWalkSpeed + JUMP_SPEED_BOOST
			return
		end
	end)

	landedConn = hum.StateChanged:Connect(function(_, newState)
		if newState == Enum.HumanoidStateType.Landed and hum then
			hum.WalkSpeed = baseWalkSpeed
		end
	end)
end

--========================
-- TRAVA / DESTRAVA
--========================
local function setEnabled(newValue, reason, fromButton)
	if fromButton ~= nil then
		manualOverride = newValue
	end

	if enabled == newValue then
		updatePanelUI()
		return
	end

	enabled = newValue
	pendingTurn = nil
	updatePanelUI()

	if enabled then
		notify("Painel CNP Biel975oi", "Speed ATIVADO (" .. (reason or "botão") .. ")", 2.0)
	else
		notify("Painel CNP Biel975oi", "Speed DESATIVADO (" .. (reason or "botão") .. ")", 2.0)
	end
end

local function onToolChanged()
	if debounceToolEvent then return end
	debounceToolEvent = true
	task.delay(0.08, function() debounceToolEvent = false end)

	if manualOverride then
		setEnabled(true, "botão ON ativo", nil)
		return
	end

	if emoteActive then
		setEnabled(true, "emote (rodela) + tool", nil)
	else
		setEnabled(false, "tool fora do emote", nil)
	end
end

local function disconnectToolHooks()
	if toolConnAdded then toolConnAdded:Disconnect() toolConnAdded = nil end
	if toolConnRemoved then toolConnRemoved:Disconnect() toolConnRemoved = nil end
end

local function hookTools(character)
	disconnectToolHooks()

	toolConnAdded = character.ChildAdded:Connect(function(obj)
		if obj and obj:IsA("Tool") then
			onToolChanged()
		end
	end)

	toolConnRemoved = character.ChildRemoved:Connect(function(obj)
		if obj and obj:IsA("Tool") then
			onToolChanged()
		end
	end)
end

--========================
-- PULO INCLINADO (S + A/D)
--========================
local function isInclined()
	return hrp and (hrp.CFrame.UpVector.Y < INCLINE_UPVECTOR_Y)
end

local function triggerInclineImpulse()
	if not hrp then return end
	local v = hrp.AssemblyLinearVelocity
	setVel(Vector3.new(v.X, JUMP_INCLINE_FORCE_Y, v.Z))
end

local function hookInclineJump()
	if jumpConn then jumpConn:Disconnect() jumpConn = nil end
	if not hum then return end

	jumpConn = hum.Jumping:Connect(function()
		if not hrp then return end
		if isInclined() and holdingS and holdingAD then
			triggerInclineImpulse()
		end
	end)
end

--========================
-- INPUT (unificado)
--========================
UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end

	if input.KeyCode == Enum.KeyCode.A then
		direcaoPressionada = "A"
		holdingAD = true
		if inAir() then
			pendingTurn = { t0 = os.clock(), yaw = getYaw() }
		end
	elseif input.KeyCode == Enum.KeyCode.D then
		direcaoPressionada = "D"
		holdingAD = true
		if inAir() then
			pendingTurn = { t0 = os.clock(), yaw = getYaw() }
		end
	elseif input.KeyCode == Enum.KeyCode.S then
		direcaoPressionada = "S"
		holdingS = true
	elseif input.KeyCode == Enum.KeyCode.R then
		setJumpSpeedState(not jumpSpeedAtivo)
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.D then
		holdingAD = false
		if direcaoPressionada == "A" or direcaoPressionada == "D" then
			direcaoPressionada = nil
		end
	elseif input.KeyCode == Enum.KeyCode.S then
		holdingS = false
		if direcaoPressionada == "S" then
			direcaoPressionada = nil
		end
	end
end)

--========================
-- LOOP MOVIMENTO
--========================
RunService.Heartbeat:Connect(function(dt)
	if not hum or not hrp then return end
	if not inAir() then pendingTurn = nil return end

	local md, dotR = getMove()
	applySideSpeed(dt, md, dotR)

	if pendingTurn then
		if os.clock() - pendingTurn.t0 > TURN_WINDOW then
			pendingTurn = nil
		else
			tryBoost()
		end
	end
end)

--========================
-- LOOP ANTI-CLICK E NO RELOAD
--========================
RunService.RenderStepped:Connect(function()
	local currentChar = player.Character
	if not currentChar then return end
	local tool = currentChar:FindFirstChildOfClass("Tool")

	if tool then
		if antiClickAtivo then
			tool.Enabled = false
			for _, v in pairs(tool:GetDescendants()) do
				if v:IsA("BasePart") then
					v.CanTouch = false
				end
			end
		else
			tool.Enabled = true
		end

		if noReloadAtivo then
			for _, obj in pairs(tool:GetDescendants()) do
				if obj.Name == "Reloading" or obj.Name == "Debounce" or obj.Name == "Delay" then
					if obj:IsA("BoolValue") then
						obj.Value = false
					end
					if obj:IsA("NumberValue") then
						obj.Value = 0
					end
				end
			end

			local currentHum = currentChar:FindFirstChildOfClass("Humanoid")
			if currentHum then
				for _, anim in pairs(currentHum:GetPlayingAnimationTracks()) do
					if string.find(string.lower(anim.Name), "reload") then
						anim:Stop()
					end
				end
			end
		end
	end
end)

--========================
-- PAINEL CNP BIEL975OI FLUTUANTE
--========================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PainelCNP"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local function MakeDraggable(guiObject)
	local dragging, dragInput, dragStart, startPos

	guiObject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = guiObject.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	guiObject.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			guiObject.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleButton"
ToggleBtn.Size = UDim2.new(0, 45, 0, 45)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
ToggleBtn.BackgroundColor3 = COLOR_TOGGLE_BG
ToggleBtn.Text = "⚙️"
ToggleBtn.TextSize = 22
ToggleBtn.TextColor3 = COLOR_TEXT_DARK
ToggleBtn.Visible = false
ToggleBtn.Parent = ScreenGui
MakeDraggable(ToggleBtn)

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleBtn

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = COLOR_STROKE_MAIN
ToggleStroke.Thickness = 1.5
ToggleStroke.Parent = ToggleBtn

MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = PANEL_SIZES.Medio
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -177)
MainFrame.BackgroundColor3 = COLOR_BG_MAIN
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
MakeDraggable(MainFrame)

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = COLOR_STROKE_MAIN
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 34)
Title.BackgroundColor3 = COLOR_BG_HEADER
Title.Text = "  PAINEL CNP BIEL975OI"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextColor3 = COLOR_TEXT_DARK
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 34)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.TextColor3 = COLOR_TEXT_MUTED
CloseBtn.Parent = Title

CloseBtn.MouseButton1Click:Connect(function()
	MainFrame.Visible = false
end)

ToggleBtn.MouseButton1Click:Connect(function()
	MainFrame.Visible = not MainFrame.Visible
end)

local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -16, 1, -44)
Container.Position = UDim2.new(0, 8, 0, 39)
Container.BackgroundTransparency = 1
Container.ScrollBarThickness = 4
Container.ScrollBarImageColor3 = COLOR_STROKE_MAIN
Container.CanvasSize = UDim2.new(0, 0, 0, 0)
Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
Container.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 6)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Parent = Container

StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -4, 0, 20)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: DESATIVADO (Auto)"
StatusLabel.Font = Enum.Font.GothamSemibold
StatusLabel.TextSize = 12
StatusLabel.TextColor3 = COLOR_TEXT_MUTED
StatusLabel.Parent = Container

local function CreateButton(text)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -4, 0, 35)
	btn.BackgroundColor3 = COLOR_BTN_OFF
	btn.Text = text
	btn.Font = Enum.Font.GothamSemibold
	btn.TextSize = 13
	btn.TextColor3 = COLOR_TEXT_DARK
	btn.Parent = Container

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = btn

	local stroke = Instance.new("UIStroke")
	stroke.Color = COLOR_STROKE_BTN
	stroke.Thickness = 1
	stroke.Parent = btn

	return btn
end

--========================
-- CONTROLE DE TAMANHO DO PAINEL
--========================
SizeCycleBtn = CreateButton("Tamanho: Medio")
SizeCycleBtn.MouseButton1Click:Connect(function()
	cyclePanelSize()
end)

local SizeRow = Instance.new("Frame")
SizeRow.Name = "SizeRow"
SizeRow.Size = UDim2.new(1, -4, 0, 30)
SizeRow.BackgroundTransparency = 1
SizeRow.Parent = Container

local SizeRowLayout = Instance.new("UIListLayout")
SizeRowLayout.FillDirection = Enum.FillDirection.Horizontal
SizeRowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SizeRowLayout.Padding = UDim.new(0, 5)
SizeRowLayout.Parent = SizeRow

local function CreateMiniSizeButton(label, targetName)
	local mini = Instance.new("TextButton")
	mini.Size = UDim2.new(0.32, 0, 1, 0)
	mini.BackgroundColor3 = COLOR_BTN_OFF
	mini.Text = label
	mini.Font = Enum.Font.GothamSemibold
	mini.TextSize = 11
	mini.TextColor3 = COLOR_TEXT_DARK
	mini.Parent = SizeRow

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 6)
	c.Parent = mini

	local s = Instance.new("UIStroke")
	s.Color = COLOR_STROKE_BTN
	s.Thickness = 1
	s.Parent = mini

	mini.MouseButton1Click:Connect(function()
		applyPanelSize(targetName)
	end)
	return mini
end

SmallSizeBtn = CreateMiniSizeButton("Peq", "Pequeno")
MediumSizeBtn = CreateMiniSizeButton("Med", "Medio")
LargeSizeBtn = CreateMiniSizeButton("Grd", "Grande")

SpeedBtn = CreateButton("Speed: OFF")
SpeedBtn.MouseButton1Click:Connect(function()
	setEnabled(not enabled, "botão ON/OFF", true)
end)

JumpSpeedBtn = CreateButton("Impulso no Pulo: OFF")
JumpSpeedBtn.MouseButton1Click:Connect(function()
	setJumpSpeedState(not jumpSpeedAtivo)
end)

InclineBtn = CreateButton("Impulso Inclinado")
InclineBtn.MouseButton1Click:Connect(function()
	triggerInclineImpulse()
end)

Lighting2020Btn = CreateButton("Iluminação 2020: OFF")
Lighting2020Btn.MouseButton1Click:Connect(function()
	setLighting2020State(not lighting2020Ativo)
end)

AntiCoinsBtn = CreateButton("Anti Coins MM2: EXECUTAR")
AntiCoinsBtn.MouseButton1Click:Connect(function()
	runRemoteScript(ANTI_COINS_URL, "antiCoins", "Anti Coins MM2")
end)

AntiClickBtn = CreateButton("ANTI-CLICK: OFF")
AntiClickBtn.MouseButton1Click:Connect(function()
	antiClickAtivo = not antiClickAtivo
	updatePanelUI()
end)

NoReloadBtn = CreateButton("NO RELOAD: OFF")
NoReloadBtn.MouseButton1Click:Connect(function()
	noReloadAtivo = not noReloadAtivo
	updatePanelUI()
end)

CrosshairBtn = CreateButton("Crosshair Gun: OFF")
CrosshairBtn.MouseButton1Click:Connect(function()
	setCrosshairState(not crosshairAtivo)
end)

WaterBalloonBtn = CreateButton("Water Balloon: OFF")
WaterBalloonBtn.MouseButton1Click:Connect(function()
	setWaterBalloonState(not waterBalloonAtivo)
end)

local EmoteSitBtn = CreateButton("Emote: Sit")
EmoteSitBtn.MouseButton1Click:Connect(function()
	playEmoteName("sit")
end)

local EmoteZenBtn = CreateButton("Emote: Zen")
EmoteZenBtn.MouseButton1Click:Connect(function()
	playEmoteName("zen")
end)

local EmoteNinjaBtn = CreateButton("Emote: Ninja Rest")
EmoteNinjaBtn.MouseButton1Click:Connect(function()
	playEmoteName("ninja")
end)

local EmoteDabBtn = CreateButton("Emote: Dab")
EmoteDabBtn.MouseButton1Click:Connect(function()
	playEmoteName("dab")
end)

local EmoteFlossBtn = CreateButton("Emote: Floss")
EmoteFlossBtn.MouseButton1Click:Connect(function()
	playEmoteName("floss")
end)

Yd7EmotesBtn = CreateButton("7yd7 Emotes: EXECUTAR")
Yd7EmotesBtn.MouseButton1Click:Connect(function()
	runRemoteScript(YD7_EMOTES_URL, "yd7Emotes", "7yd7 Emotes")
end)

ExtraPasteBtn = CreateButton("Script Externo: EXECUTAR")
ExtraPasteBtn.MouseButton1Click:Connect(function()
	runRemoteScript(EXTRA_PASTE_URL, "extraPaste", "Script Externo")
end)

AlternativePanelBtn = CreateButton("Painel Alternativo: EXECUTAR")
AlternativePanelBtn.MouseButton1Click:Connect(function()
	runRemoteScript(ALTERNATIVE_PANEL_URL, "alternativePanel", "Painel Alternativo")
end)

--========================
-- PAINEL ANTERIOR: PERGUNTA COMPUTADOR OU CELULAR
--========================
local DeviceFrame = Instance.new("Frame")
DeviceFrame.Name = "DeviceSelectorFrame"
DeviceFrame.Size = UDim2.new(0, 250, 0, 175)
DeviceFrame.Position = UDim2.new(0.5, -125, 0.5, -87)
DeviceFrame.BackgroundColor3 = COLOR_BG_MAIN
DeviceFrame.BorderSizePixel = 0
DeviceFrame.Visible = true
DeviceFrame.Parent = ScreenGui
MakeDraggable(DeviceFrame)

local DeviceCorner = Instance.new("UICorner")
DeviceCorner.CornerRadius = UDim.new(0, 10)
DeviceCorner.Parent = DeviceFrame

local DeviceStroke = Instance.new("UIStroke")
DeviceStroke.Color = COLOR_STROKE_MAIN
DeviceStroke.Thickness = 1.5
DeviceStroke.Parent = DeviceFrame

local DeviceHeader = Instance.new("TextLabel")
DeviceHeader.Size = UDim2.new(1, 0, 0, 34)
DeviceHeader.BackgroundColor3 = COLOR_BG_HEADER
DeviceHeader.Text = "  PAINEL CNP BIEL975OI"
DeviceHeader.Font = Enum.Font.GothamBold
DeviceHeader.TextSize = 13
DeviceHeader.TextColor3 = COLOR_TEXT_DARK
DeviceHeader.TextXAlignment = Enum.TextXAlignment.Left
DeviceHeader.Parent = DeviceFrame

local DeviceHeaderCorner = Instance.new("UICorner")
DeviceHeaderCorner.CornerRadius = UDim.new(0, 10)
DeviceHeaderCorner.Parent = DeviceHeader

local DeviceQuestion = Instance.new("TextLabel")
DeviceQuestion.Size = UDim2.new(1, -20, 0, 42)
DeviceQuestion.Position = UDim2.new(0, 10, 0, 42)
DeviceQuestion.BackgroundTransparency = 1
DeviceQuestion.Text = "Qual é o seu aparelho?\nComputador ou Celular?"
DeviceQuestion.Font = Enum.Font.GothamSemibold
DeviceQuestion.TextSize = 13
DeviceQuestion.TextColor3 = COLOR_TEXT_DARK
DeviceQuestion.TextWrapped = true
DeviceQuestion.Parent = DeviceFrame

local function createDeviceChoiceBtn(text, posX, chosenDevice, chosenSize)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.44, 0, 0, 42)
	btn.Position = UDim2.new(posX, 0, 0, 104)
	btn.BackgroundColor3 = COLOR_BTN_OFF
	btn.Text = text
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 13
	btn.TextColor3 = COLOR_TEXT_DARK
	btn.Parent = DeviceFrame

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 7)
	c.Parent = btn

	local s = Instance.new("UIStroke")
	s.Color = COLOR_STROKE_BTN
	s.Thickness = 1
	s.Parent = btn

	btn.MouseButton1Click:Connect(function()
		deviceType = chosenDevice
		currentSizeName = chosenSize
		DeviceFrame.Visible = false
		ToggleBtn.Visible = true
		MainFrame.Visible = true
		updatePanelUI()
		notify("Painel CNP Biel975oi", "Modo " .. chosenDevice .. " selecionado (" .. chosenSize .. ").", 2.5)
	end)
end

createDeviceChoiceBtn("Computador", 0.04, "Computador", "Medio")
createDeviceChoiceBtn("Celular", 0.52, "Celular", "Pequeno")

--========================
-- CHARACTER
--========================
local function hook(c)
	char = c
	hum = c:WaitForChild("Humanoid")
	hrp = c:WaitForChild("HumanoidRootPart")
	baseWalkSpeed = hum.WalkSpeed

	direcaoPressionada = nil
	pendingTurn = nil
	lastBoost = 0

	enabled = manualOverride
	clearEmoteState()

	hookEmoteDetector()
	hookTools(c)
	hookInclineJump()
	hookJumpSpeed()
	hookCrosshairTools(c)

	if waterBalloonAtivo then
		enableGameBar()
		createVisualBalloonTool()
	end

	updatePanelUI()

	notify("Painel CNP Biel975oi", enabled and "Iniciou ATIVADO" or "Iniciou DESATIVADO", 2)
end

if player.Character then hook(player.Character) end
player.CharacterAdded:Connect(hook)

notify("Painel CNP Biel975oi", "Selecione Computador ou Celular para abrir.", 2.5)
