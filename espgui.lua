local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Script Toggles", "DarkTheme")
local Tab = Window:NewTab("Main")
local Section = Tab:NewSection("Toggles")

-- Services and Variables
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local espEnabled = false
local aimEnabled = false
local noClipEnabled = false

-- ESP Functions
local function createESP(player)
    if player == localPlayer then return end
    
    local character = player.Character
    if not character then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = character:WaitForChild("HumanoidRootPart")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Name = "ESPNameTag"

    local textLabel = Instance.new("TextLabel")
    textLabel.Text = player.Name
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.BackgroundTransparency = 1
    textLabel.TextScaled = true
    textLabel.Name = "ESPNameLabel"
    textLabel.Parent = billboard
    billboard.Parent = character

    local highlight = Instance.new("Highlight")
    highlight.Adornee = character
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency = 1
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.Name = "ESPHighlight"
    highlight.Parent = character

    local tracerAttachment0 = Instance.new("Attachment")
    tracerAttachment0.Name = "TracerAttachment0"
    tracerAttachment0.Parent = character:WaitForChild("HumanoidRootPart")

    local tracerAttachment1 = Instance.new("Attachment")
    tracerAttachment1.Name = "TracerAttachment1"
    tracerAttachment1.Parent = localPlayer.Character:WaitForChild("HumanoidRootPart")

    local tracer = Instance.new("Beam")
    tracer.Attachment0 = tracerAttachment0
    tracer.Attachment1 = tracerAttachment1
    tracer.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
    tracer.FaceCamera = true
    tracer.Width0 = 0.1
    tracer.Width1 = 0.1
    tracer.Name = "ESPTracer"
    tracer.Parent = character
end

local function removeESP(player)
    local character = player.Character
    if character then
        local highlight = character:FindFirstChild("ESPHighlight")
        if highlight then
            highlight:Destroy()
        end
        local billboard = character:FindFirstChild("ESPNameTag")
        if billboard then
            billboard:Destroy()
        end
        local tracer = character:FindFirstChild("ESPTracer")
        if tracer then
            tracer:Destroy()
        end
        local tracerAttachment0 = character:FindFirstChild("TracerAttachment0")
        if tracerAttachment0 then
            tracerAttachment0:Destroy()
        end
    end
end

local function updateESP()
    if not espEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= localPlayer then
                removeESP(player)
            end
        end
        return
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (localPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if distance <= 250 then
                if not player.Character:FindFirstChild("ESPHighlight") then
                    createESP(player)
                end
                local billboard = player.Character:FindFirstChild("ESPNameTag")
                if billboard then
                    local textLabel = billboard:FindFirstChild("ESPNameLabel")
                    if textLabel then
                        textLabel.Text = player.Name .. " (" .. math.floor(distance) .. "m)"
                    end
                end
            else
                removeESP(player)
            end
        end
    end
end

local function toggleESP(enabled)
    espEnabled = enabled
    if not espEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= localPlayer then
                removeESP(player)
            end
        end
    end
end

-- Aim Functions
local function updateFovCircle(fovCircle)
    local screenCenter = workspace.CurrentCamera.ViewportSize / 2
    fovCircle.Position = Vector2.new(screenCenter.X, screenCenter.Y)
end

local function getClosestPlayerInFov(fovCircle, fovRadius)
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, targetPlayer in pairs(game.Players:GetPlayers()) do
        if targetPlayer ~= localPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local screenPosition, onScreen = workspace.CurrentCamera:WorldToViewportPoint(targetPlayer.Character.HumanoidRootPart.Position)
            if onScreen then
                local distanceFromCenter = (Vector2.new(screenPosition.X, screenPosition.Y) - fovCircle.Position).Magnitude
                if distanceFromCenter <= fovRadius and distanceFromCenter < shortestDistance then
                    shortestDistance = distanceFromCenter
                    closestPlayer = targetPlayer
                end
            end
        end
    end

    return closestPlayer
end

local function addShake(position, aimShakeIntensity)
    local shake = Vector3.new(
        math.random() * aimShakeIntensity - aimShakeIntensity / 2,
        math.random() * aimShakeIntensity - aimShakeIntensity / 2,
        math.random() * aimShakeIntensity - aimShakeIntensity / 2
    )
    return position + shake
end

local function toggleAim(enabled)
    aimEnabled = enabled
    if not aimEnabled then
        -- Clean up any aim-related objects or states if necessary
    end
end

RunService.RenderStepped:Connect(function()
    if aimEnabled then
        local fovCircle = Drawing.new("Circle")
        fovCircle.Radius = 125
        fovCircle.Thickness = 2
        fovCircle.Color = Color3.new(1, 0, 0)
        fovCircle.Filled = false
        fovCircle.Visible = true
        updateFovCircle(fovCircle)

        local closestPlayer = getClosestPlayerInFov(fovCircle, 125)
        if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local targetPosition = closestPlayer.Character.HumanoidRootPart.Position
            targetPosition = addShake(targetPosition, 0.05)

            local direction = (targetPosition - localPlayer.Character.Head.Position).unit
            local targetCFrame = CFrame.new(localPlayer.Character.Head.Position, localPlayer.Character.Head.Position + direction)

            workspace.CurrentCamera.CFrame = targetCFrame
        end
    end
end)

-- NoClip Functions
local function setNoclip(enabled)
    noClipEnabled = enabled
    local character = localPlayer.Character
    if character then
        if noClipEnabled then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        else
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

local function toggleNoClip(enabled)
    noClipEnabled = enabled
    setNoclip(noClipEnabled)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.N then
        toggleNoClip(not noClipEnabled)
    end
end)

RunService.Stepped:Connect(function()
    if noClipEnabled then
        local character = localPlayer.Character
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        wait(1)
        if espEnabled then
            createESP(player)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    if espEnabled then
        removeESP(player)
    end
end)

-- GUI Buttons
Section:NewButton("Toggle ESP", "Enable/Disable ESP", function()
    espEnabled = not espEnabled
    toggleESP(espEnabled)
    print("ESP: " .. (espEnabled and "ON" or "OFF"))
end)

Section:NewButton("Toggle ESP", "Enable/Disable ESP", function()
    espEnabled = not espEnabled
    toggleESP(espEnabled)
    print("ESP: " .. (espEnabled and "ON" or "OFF"))
end)

Section:NewButton("Toggle Aim", "Enable/Disable Aim", function()
    aimEnabled = not aimEnabled
    toggleAim(aimEnabled)
    print("Aim: " .. (aimEnabled and "ON" or "OFF"))
end)

Section:NewButton("Toggle NoClip", "Enable/Disable NoClip", function()
    noClipEnabled = not noClipEnabled
    toggleNoClip(noClipEnabled)
    print("NoClip: " .. (noClipEnabled and "ON" or "OFF"))
end)

-- GUI Initialization
local function initGUI()
    -- Ensure ESP is applied to all existing players if enabled
    if espEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= localPlayer then
                createESP(player)
            end
        end
    end

    -- Ensure NoClip is applied to the local player if enabled
    if noClipEnabled then
        setNoclip(true)
    end
end

-- Initialize
initGUI()

-- RunService Events
RunService.Heartbeat:Connect(updateESP)
RunService.RenderStepped:Connect(function()
    if aimEnabled then
        local fovCircle = Drawing.new("Circle")
        fovCircle.Radius = 125
        fovCircle.Thickness = 2
        fovCircle.Color = Color3.new(1, 0, 0)
        fovCircle.Filled = false
        fovCircle.Visible = true
        updateFovCircle(fovCircle)

        local closestPlayer = getClosestPlayerInFov(fovCircle, 125)
        if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local targetPosition = closestPlayer.Character.HumanoidRootPart.Position
            targetPosition = addShake(targetPosition, 0.05)

            local direction = (targetPosition - localPlayer.Character.Head.Position).unit
            local targetCFrame = CFrame.new(localPlayer.Character.Head.Position, localPlayer.Character.Head.Position + direction)

            workspace.CurrentCamera.CFrame = targetCFrame
        end
    end
end)
