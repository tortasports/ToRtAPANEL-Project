-- ToRtAPANEL v4.7 "Unlocked Edition"
-- Author: 5569422247
-- Optimization: Xeno Executor Compatible

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- Variables de Estado
local Toggles = {
    Aimbot = false,
    ESP = false,
    Noclip = false,
    Fly = false,
    InfJump = false,
    Hitbox = false,
    Tracers = false
}

local Config = {
    AimbotLerp = 0.2,
    FOVSize = 150,
    WalkSpeed = 16,
    JumpPower = 50,
    HitboxSize = 6
}

-- UI Principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ToRtAPANEL_v4.7"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Size = UDim2.new(0, 450, 0, 320)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Titulo con Efecto Rainbow
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "ToRtAPANEL v4.7 [UNLOCKED]"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.BuilderSansBold
Title.TextSize = 18
Title.Parent = MainFrame

task.spawn(function()
    while task.wait() do
        local hue = tick() % 5 / 5
        Title.TextColor3 = Color3.fromHSV(hue, 0.8, 1)
    end
end)

-- Contenedor de Botones (Scrolling)
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -50)
Scroll.Position = UDim2.new(0, 10, 0, 40)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 1.5, 0)
Scroll.ScrollBarThickness = 2
Scroll.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Parent = Scroll
Layout.Padding = UDim.new(0, 5)

-- Función para crear botones estilo Apple
local function CreateButton(name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.BuilderSans
    btn.TextSize = 14
    btn.AutoButtonColor = true
    btn.Parent = Scroll
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    btn.MouseButton1Down:Connect(function()
        callback()
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        task.wait(0.1)
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    end)
end

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 60
FOVCircle.Radius = Config.FOVSize
FOVCircle.Filled = false
FOVCircle.Visible = false

task.spawn(function()
    while task.wait() do
        FOVCircle.Color = Color3.fromHSV(tick() % 5 / 5, 0.8, 1)
    end
end)

-- SISTEMA DE COMBATE (Preciso)
local function GetClosestPlayer()
    local target = nil
    local dist = Config.FOVSize
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            if onScreen then
                local magnitude = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if magnitude < dist then
                    target = v
                    dist = magnitude
                end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    if Toggles.Aimbot then
        FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
        FOVCircle.Visible = true
        local target = GetClosestPlayer()
        if target and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Character.HumanoidRootPart.Position), Config.AimbotLerp)
        end
    else
        FOVCircle.Visible = false
    end
end)

-- NOCLIP (Filtro por Partes)
local NoclipParts = {"HumanoidRootPart", "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "UpperTorso", "LowerTorso"}
RunService.Stepped:Connect(function()
    if Toggles.Noclip and LocalPlayer.Character then
        for _, partName in pairs(NoclipParts) do
            local p = LocalPlayer.Character:FindFirstChild(partName)
            if p then p.CanCollide = false end
        end
    end
end)

-- Botones de Funciones
CreateButton("Toggle Aimbot", function() Toggles.Aimbot = not Toggles.Aimbot end)

CreateButton("Expand Hitboxes (6,6,6)", function()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
            v.Character.Head.Size = Vector3.new(6, 6, 6)
            v.Character.Head.Transparency = 0.5
            v.Character.Head.CanCollide = false
        end
    end
end)

CreateButton("Rainbow ESP", function()
    Toggles.ESP = not Toggles.ESP
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character then
            if Toggles.ESP then
                local highlight = Instance.new("Highlight", v.Character)
                highlight.Name = "ToRtA_ESP"
                task.spawn(function()
                    while highlight.Parent do
                        highlight.FillColor = Color3.fromHSV(tick() % 5 / 5, 0.7, 1)
                        highlight.OutlineColor = Color3.new(1, 1, 1)
                        task.wait()
                    end
                end)
            else
                if v.Character:FindFirstChild("ToRtA_ESP") then v.Character.ToRtA_ESP:Destroy() end
            end
        end
    end
end)

CreateButton("Speed + Jump Boost", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 60
        LocalPlayer.Character.Humanoid.JumpPower = 100
    end
end)

CreateButton("Click TP (LCtrl + Click)", function()
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            if Mouse.Target and LocalPlayer.Character then
                LocalPlayer.Character:MoveTo(Mouse.Hit.p)
            end
        end
    end)
end)

-- Toggle Menu (Right Shift) con TweenPosition
local Visible = true
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        Visible = not Visible
        if Visible then
            MainFrame:TweenPosition(UDim2.new(0.5, -225, 0.5, -160), "Out", "Quad", 0.3, true)
        else
            MainFrame:TweenPosition(UDim2.new(0.5, -225, 1.1, 0), "In", "Quad", 0.3, true)
        end
    end
end)

-- Anti-AFK
local vu = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

print("ToRtAPANEL v4.7 Cargado para ID: 5569422247")
