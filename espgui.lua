local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer

-- ESP variables
local espEnabled = false
local maxDistance = 250 -- Distance threshold for ESP

-- NoClip variables
local noClipEnabled = false

-- GUI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Script GUI", "Serpent")
local Tab = Window:NewTab("Main")
local Section = Tab:NewSection("Scripts")

-- ESP functions
local function createESP(player)
    if player == localPlayer then return end
    
    local character = player.Character
    if not character then return end

    -- Create name tag (BillboardGui)
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

    -- Create outline (Highlight)
    local highlight = Instance.new("Highlight")
    highlight.Adornee = character
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency = 1
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.Name = "ESPHighlight"
    highlight.Parent = character

    -- Create tracer (Beam)
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
            if distance <= maxDistance then
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
                if player.Character:FindFirstChild("ESPHighlight") then
                    removeESP(player)
                end
            end
        end
    end
end

local function onPlayerAdded(player)
    player.CharacterAdded:Connect(function()
        wait(1) -- Ensure character is fully loaded
        if espEnabled then
            createESP(player)
        end
    end)
end

local function toggleESP(enabled)
    espEnabled = enabled
    if not enabled then
        for _, player in pairs(Players:GetPlayers()) do
            removeESP(player)
        end
    end
end

-- NoClip functions
local function setNoclip(enabled)
    noClipEnabled = enabled

    if noClipEnabled then
        -- Make all parts in the character non-collidable
        for _, part in pairs(localPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    else
        -- Make all parts in the character collidable again
        for _, part in pairs(localPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and not part.CanCollide then
                part.CanCollide = true
            end
        end
    end
end

local function toggleNoClip(enabled)
    noClipEnabled = enabled
    setNoclip(enabled)
end

-- GUI Elements
Section:NewToggle("ESP", "Enable/Disable ESP", function(state)
    espEnabled = state
    toggleESP(espEnabled)
    print("ESP: " .. (espEnabled and "ON" or "OFF"))
end)

Section:NewToggle("NoClip", "Enable/Disable NoClip", function(state)
    noClipEnabled = state
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

-- Input Events
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.N then
        toggleNoClip(not noClipEnabled)
    end
end)

-- Player Events
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

localPlayer.CharacterAdded:Connect(function(char)
    if noClipEnabled then
        setNoclip(true)
    end
end)

-- Final Initialization
initESP()
