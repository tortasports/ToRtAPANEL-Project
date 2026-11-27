--[[
    🍰 ToRtAPANEL v4.7 - "THE UNLOCKED EDITION" (EXTENDED)
    Mantenida la base original del usuario + 6 Nuevas Funciones.
    Tecla: Right Shift para ocultar.
]]

-- 1. SERVICIOS
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

-- 2. CONFIGURACIÓN (Aumentada)
local cfg = {
	aimbot = false,
	esp = false,
	tracers = false,
	noclip = false,
	hitbox = false,
	speed = false,
	infjump = false,
	fov = false,
	bright = false,
	antiafk = true,
	clicktp = false,
	-- Nuevas opciones:
	fly = false,
	spinbot = false,
	xray = false,
	noanim = false,
	
	fovRadius = 150,
	walkSpeed = 16,
	jumpPower = 50,
	aimSmooth = 0.3,
	camFOV = 70,
	flySpeed = 50,
	gravity = 196.2
}

local panelVisible = true
local animating = false

local collisionParts = {
	["HumanoidRootPart"] = true, ["Head"] = true, ["UpperTorso"] = true,
	["LowerTorso"] = true, ["Torso"] = true, ["Left Arm"] = true,
	["Right Arm"] = true, ["Left Leg"] = true, ["Right Leg"] = true
}

-- TIPOGRAFÍA
local FONT_REGULAR = Enum.Font.BuilderSans
local FONT_BOLD = Enum.Font.BuilderSansBold

-- 3. INTERFAZ
local sg = Instance.new("ScreenGui")
sg.Name = "ToRtAPANEL"
sg.IgnoreGuiInset = true 
sg.ResetOnSpawn = false
sg.Parent = player:WaitForChild("PlayerGui")

-- Círculo de FOV
local fovFrame = Instance.new("Frame")
fovFrame.Size = UDim2.new(0, cfg.fovRadius * 2, 0, cfg.fovRadius * 2)
fovFrame.BackgroundTransparency = 1
fovFrame.Visible = false
fovFrame.Parent = sg

local fovStroke = Instance.new("UIStroke")
fovStroke.Thickness = 2
fovStroke.Parent = fovFrame
Instance.new("UICorner", fovFrame).CornerRadius = UDim.new(1, 0)

-- Panel Principal
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 200, 0, 420)
main.Position = UDim2.new(0.05, 0, 0.2, 0) -- Iniciamos en posición visible
main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
main.Active = true
main.Draggable = true 
main.Parent = sg
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.Text = "ToRtAPANEL v4.7"
title.Font = FONT_BOLD
title.TextSize = 18
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.Parent = main

local divider = Instance.new("Frame")
divider.Size = UDim2.new(0.85, 0, 0, 1)
divider.Position = UDim2.new(0.075, 0, 0, 44)
divider.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
divider.BorderSizePixel = 0
divider.Parent = main

-- Contenedor Scroll
local container = Instance.new("ScrollingFrame")
container.Size = UDim2.new(1, 0, 1, -52)
container.Position = UDim2.new(0, 0, 0, 50)
container.BackgroundTransparency = 1
container.BorderSizePixel = 0
container.ScrollBarThickness = 2
container.CanvasSize = UDim2.new(0, 0, 6, 0) -- Más espacio para extras
container.Parent = main

local layout = Instance.new("UIListLayout", container)
layout.Padding = UDim.new(0, 6)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- 4. COMPONENTES DE LA UI (Tus funciones originales)
local function addSeparator(text)
	local sep = Instance.new("TextLabel")
	sep.Size = UDim2.new(0.9, 0, 0, 25)
	sep.Text = text:upper()
	sep.Font = FONT_BOLD
	sep.TextSize = 10
	sep.TextColor3 = Color3.fromRGB(90, 90, 95)
	sep.BackgroundTransparency = 1
	sep.Parent = container
end

local function makeButton(text, configKey, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.9, 0, 0, 34)
	btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	btn.Text = "  " .. text .. ": OFF"
	btn.TextColor3 = Color3.fromRGB(200, 200, 200)
	btn.Font = FONT_REGULAR
	btn.TextSize = 12
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.Parent = container
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

	btn.MouseButton1Down:Connect(function()
		cfg[configKey] = not cfg[configKey]
		btn.Text = "  " .. text .. (cfg[configKey] and ": ON" or ": OFF")
		btn.BackgroundColor3 = cfg[configKey] and Color3.fromRGB(40, 120, 40) or Color3.fromRGB(30, 30, 35)
		btn.TextColor3 = cfg[configKey] and Color3.new(1, 1, 1) or Color3.fromRGB(200, 200, 200)

		if configKey == "noclip" and cfg.noclip == false then
			if player.Character then
				for _, v in pairs(player.Character:GetDescendants()) do
					if v:IsA("BasePart") and collisionParts[v.Name] then v.CanCollide = true end
				end
			end
		end
		if callback then callback(cfg[configKey]) end
	end)
end

local function makeSlider(text, min, max, default, callback)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(0.9, 0, 0, 48)
	holder.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	holder.Parent = container
	Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 8)
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -15, 0, 20)
	label.Position = UDim2.new(0, 10, 0, 4)
	label.Text = text .. ": " .. default
	label.Font = FONT_REGULAR
	label.TextSize = 11
	label.TextColor3 = Color3.fromRGB(200, 200, 200)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1
	label.Parent = holder
	
	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(0.85, 0, 0, 4)
	bar.Position = UDim2.new(0.075, 0, 0, 32)
	bar.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
	bar.Parent = holder
	Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
	
	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
	fill.BackgroundColor3 = Color3.new(1, 1, 1)
	fill.Parent = bar
	Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
	
	local sliding = false
	local function update(input)
		local pct = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
		local value = math.floor(min + (max - min) * pct)
		fill.Size = UDim2.new(pct, 0, 1, 0)
		label.Text = text .. ": " .. value
		callback(value)
	end

	bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true update(i) end end)
	UserInputService.InputChanged:Connect(function(i) if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then update(i) end end)
	UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end end)
end

-- 5. LÓGICA DE TRACERS
local tracers = {}
local tracerLabels = {}
local function createTracer(p)
	local line = Instance.new("Frame", sg)
	line.BorderSizePixel = 0
	line.AnchorPoint = Vector2.new(0.5, 0.5)
	line.Visible = false
	local label = Instance.new("TextLabel", sg)
	label.Size = UDim2.new(0, 130, 0, 25)
	label.BackgroundTransparency = 1
	label.Font = FONT_REGULAR
	label.TextSize = 10
	label.TextStrokeTransparency = 0.5
	label.Visible = false
	return line, label
end

-- 6. BUCLE PRINCIPAL (Tu lógica + Nuevos Updates)
RunService.RenderStepped:Connect(function()
	local h = (tick() * 0.4) % 1
	local rainbow = Color3.fromHSV(h, 0.7, 1)
	
	title.TextColor3 = rainbow
	fovStroke.Color = rainbow
	
	local mPos = UserInputService:GetMouseLocation()
	fovFrame.Size = UDim2.new(0, cfg.fovRadius * 2, 0, cfg.fovRadius * 2)
	fovFrame.Position = UDim2.new(0, mPos.X - cfg.fovRadius, 0, mPos.Y - cfg.fovRadius)
	
	-- Aimbot
	if cfg.aimbot then
		local target = nil
		local dist = cfg.fovRadius
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
				local pos, onScreen = camera:WorldToViewportPoint(p.Character.Head.Position)
				if onScreen then
					local mag = (Vector2.new(pos.X, pos.Y) - mPos).Magnitude
					if mag < dist then target = p.Character.Head dist = mag end
				end
			end
		end
		if target then
			local look = CFrame.new(camera.CFrame.Position, target.Position)
			camera.CFrame = camera.CFrame:Lerp(look, cfg.aimSmooth)
		end
	end
	
	-- Fly & Spinbot & NoAnim
	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		if cfg.spinbot then
			player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(20), 0)
		end
		if cfg.fly then
			local dir = Vector3.new(0,0,0)
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + camera.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - camera.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - camera.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + camera.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
			player.Character.HumanoidRootPart.Velocity = dir * cfg.flySpeed
			player.Character.HumanoidRootPart.Anchored = (dir == Vector3.new(0,0,0))
		else
			player.Character.HumanoidRootPart.Anchored = false
		end
	end

	-- Noclip
	if cfg.noclip and player.Character then
		for _, part in pairs(player.Character:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = false end
		end
	end
	camera.FieldOfView = cfg.camFOV
	workspace.Gravity = cfg.gravity
	
	-- Speed
	if player.Character and player.Character:FindFirstChild("Humanoid") then
		if cfg.speed then
			player.Character.Humanoid.WalkSpeed = cfg.walkSpeed
			player.Character.Humanoid.JumpPower = cfg.jumpPower
		end
	end
	
	-- ESP & Tracers
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= player and p.Character then
			local char = p.Character
			local high = char:FindFirstChild("T_ESP")
			if cfg.esp then
				if not high then high = Instance.new("Highlight", char) high.Name = "T_ESP" end
				high.FillColor = rainbow
			elseif high then high:Destroy() end
			
			if char:FindFirstChild("Head") then
				char.Head.Size = cfg.hitbox and Vector3.new(6, 6, 6) or Vector3.new(1, 1, 1)
				char.Head.Transparency = cfg.hitbox and 0.5 or 0
			end

			if cfg.tracers and char:FindFirstChild("HumanoidRootPart") then
				if not tracers[p.Name] then tracers[p.Name], tracerLabels[p.Name] = createTracer(p) end
				local tracer = tracers[p.Name]
				local label = tracerLabels[p.Name]
				local hrpPos, onScreen = camera:WorldToViewportPoint(char.HumanoidRootPart.Position)
				if onScreen then
					local start = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
					local destination = Vector2.new(hrpPos.X, hrpPos.Y)
					local d = (destination - start).Magnitude
					local realDist = math.floor((player.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude)
					tracer.Visible = true
					tracer.Size = UDim2.new(0, d, 0, 1)
					tracer.Position = UDim2.new(0, (start.X + destination.X)/2, 0, (start.Y + destination.Y)/2)
					tracer.Rotation = math.deg(math.atan2(destination.Y - start.Y, destination.X - start.X))
					tracer.BackgroundColor3 = rainbow
					label.Visible = true
					label.Position = UDim2.new(0, hrpPos.X - 65, 0, hrpPos.Y - 25)
					label.Text = p.Name .. " [" .. realDist .. "m]"
					label.TextColor3 = rainbow
				else tracer.Visible = false label.Visible = false end
			elseif tracers[p.Name] then tracers[p.Name].Visible = false tracerLabels[p.Name].Visible = false end
		end
	end
end)

-- 7. EVENTOS EXTRA
UserInputService.JumpRequest:Connect(function() if cfg.infjump and player.Character then player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end end)

-- Click TP (Ctrl + Mouse Click)
mouse.Button1Down:Connect(function()
	if cfg.clicktp and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
		if mouse.Target and player.Character then
			player.Character:MoveTo(mouse.Hit.p)
		end
	end
end)

-- Anti AFK
player.Idled:Connect(function()
	if cfg.antiafk then
		game:GetService("VirtualUser"):CaptureController()
		game:GetService("VirtualUser"):ClickButton2(Vector2.new())
	end
end)

-- 8. BOTONES Y SLIDERS (Tus originales + Nuevos)
addSeparator("COMBAT")
makeButton("AIMBOT", "aimbot")
makeButton("SHOW FOV", "fov", function(val) fovFrame.Visible = val end)
makeButton("HITBOX", "hitbox")
makeButton("SPINBOT", "spinbot")

addSeparator("VISUALS")
makeButton("ESP", "esp")
makeButton("TRACERS", "tracers")
makeButton("BRIGHTNESS", "bright", function(val) Lighting.Brightness = val and 5 or 2 Lighting.GlobalShadows = not val end)
makeButton("X-RAY", "xray", function(val)
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") and not v:IsDescendantOf(player.Character) and not Players:GetPlayerFromCharacter(v.Parent) then
			v.LocalTransparencyModifier = val and 0.5 or 0
		end
	end
end)

addSeparator("MOVEMENT")
makeButton("FLY", "fly")
makeButton("NOCLIP", "noclip")
makeButton("INF. JUMP", "infjump")
makeButton("SPEED", "speed", function(val) if not val and player.Character then player.Character.Humanoid.WalkSpeed = 16 player.Character.Humanoid.JumpPower = 50 end end)
makeButton("CLICK TP (Ctrl)", "clicktp")

addSeparator("MISC")
makeButton("ANTI-AFK", "antiafk")

addSeparator("PARAMETERS")
makeSlider("FOV Radius", 50, 400, 150, function(v) cfg.fovRadius = v end)
makeSlider("Walk Speed", 16, 200, 16, function(v) cfg.walkSpeed = v end)
makeSlider("Jump Power", 50, 300, 50, function(v) cfg.jumpPower = v end)
makeSlider("Aim Smooth", 1, 10, 3, function(v) cfg.aimSmooth = v / 10 end)
makeSlider("Fly Speed", 10, 300, 50, function(v) cfg.flySpeed = v end)
makeSlider("Gravity", 0, 400, 196, function(v) cfg.gravity = v end)
makeSlider("Camera FOV", 30, 120, 70, function(v) cfg.camFOV = v end)

-- 9. ANIMACIONES (Tus originales)
task.spawn(function()
	main.Position = UDim2.new(-0.5, 0, 0.2, 0)
	task.wait(0.3)
	main:TweenPosition(UDim2.new(0.05, 0, 0.2, 0), "Out", "Elastic", 1.2, true)
end)

local lastPos = UDim2.new(0.05, 0, 0.2, 0)
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.RightShift and not animating then
		animating = true
		if panelVisible then
			lastPos = main.Position
			main:TweenPosition(UDim2.new(-0.5, 0, lastPos.Y.Scale, lastPos.Y.Offset), "In", "Back", 0.5, true, function() main.Visible = false animating = false end)
		else
			main.Visible = true
			main:TweenPosition(lastPos, "Out", "Elastic", 1, true, function() animating = false end)
		end
		panelVisible = not panelVisible
	end
end)

print("ToRtAPANEL v4.7 Unlocked · Right Shift to toggle")
