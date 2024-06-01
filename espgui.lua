local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local localPlayer = game.Workspace:WaitForChild(localPlayer)
local maxDistance = 100 -- Default max distance for ESP
local lerpSpeed = 1 -- Default lerp speed

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("ESP GUI", "DarkTheme")
local EspTab = Window:NewTab("ESP")
local TeleportTab = Window:NewTab("Teleport")
local LocalTab = Window:NewTab("Local") -- Add a new tab for local player settings

-- ESP Settings
local EspSection = EspTab:NewSection("ESP Settings")
local showName = false
local showDistance = false
local showTracers = false

EspSection:NewToggle("Show Name", "Toggle showing player names", function(state)
    showName = state
    updateAllESP()
end)

EspSection:NewToggle("Show Distance", "Toggle showing player distance", function(state)
    showDistance = state
    updateAllESP()
end)

EspSection:NewToggle("Show Tracers", "Toggle showing tracers", function(state)
    showTracers = state
    updateAllESP()
end)

EspSection:NewSlider("Max Distance", "Set maximum distance for ESP", 500, 0, function(value)
    maxDistance = value
    updateAllESP()
end)

-- Teleport Settings
local TeleportSection = TeleportTab:NewSection("Teleport")
local playerList = {}

local lerpSpeedSlider = TeleportSection:NewSlider("Lerp Speed", "Set lerp speed", 5, 1, function(value)
    lerpSpeed = value
end)

local function lerpToPlayer(player)
    local character = player.Character
    if character then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            local targetPosition = humanoidRootPart.Position
            
            local startPosition = localPlayer.Character.HumanoidRootPart.Position
            local duration = (targetPosition - startPosition).Magnitude / 100 -- Duration based on distance
            
            local startTime = tick()
            while tick() - startTime < duration do
                local t = (tick() - startTime) / duration
                local newPosition = startPosition:Lerp(targetPosition, t)
                local newPositionCFrame = CFrame.new(newPosition)
                
                -- Update local player's position
                local humanoidRootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    humanoidRootPart.CFrame = newPositionCFrame
                end
                
                -- Update camera's position to follow the local player
                local camera = game.Workspace.CurrentCamera
                camera.CFrame = CFrame.new(newPosition + Vector3.new(0, 5, -10), newPosition)
                
                RunService.RenderStepped:Wait()
            end
        end
    end
end

local function createPlayerButton(player)
    local button = TeleportSection:NewButton(player.Name, "Teleport to " .. player.Name, function()
        lerpToPlayer(player)
    end)
    playerList[player.Name] = button
end

local function updatePlayerList()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            if not playerList[player.Name] then
                createPlayerButton(player)
            end
        end
    end
end

local function removePlayerButton(player)
    if playerList[player.Name] then
        playerList[player.Name]:Destroy()
        playerList[player.Name] = nil
    end
end

local function onPlayerAdded(player)
    createPlayerButton(player)
end

local function onPlayerRemoving(player)
    removePlayerButton(player)
end

local function initPlayerList()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            createPlayerButton(player)
        end
    end

    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(onPlayerRemoving)
end

local function createESP(player)
    local character = player.Character
    if not character then return end
    
    -- Create BillboardGui for name
    if showName then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESPBillboard"
        billboard.Adornee = character:WaitForChild("HumanoidRootPart")
        billboard.Size = UDim2.new(0, 100, 0, 25)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true

        local textLabel = Instance.new("TextLabel")
        textLabel.Text = player.Name
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        textLabel.BackgroundTransparency = 1
        textLabel.TextScaled = true
        textLabel.Font = Enum.Font.SourceSans
        textLabel.TextSize = 14
        textLabel.Parent = billboard
        billboard.Parent = character
    end

    -- Create BillboardGui for distance
    if showDistance then
        local distanceBillboard = Instance.new("BillboardGui")
        distanceBillboard.Name = "ESPDistanceBillboard"
        distanceBillboard.Adornee = character:WaitForChild("HumanoidRootPart")
        distanceBillboard.Size = UDim2.new(0, 100, 0, 25)
        distanceBillboard.StudsOffset = Vector3.new(0, -3, 0)
        distanceBillboard.AlwaysOnTop = true

        local distanceLabel = Instance.new("TextLabel")
        distanceLabel.Text = math.floor((character.HumanoidRootPart.Position - localPlayer.Character.HumanoidRootPart.Position).Magnitude) .. "m"
        distanceLabel.Size = UDim2.new(1, 0, 1, 0)
        distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        distanceLabel.BackgroundTransparency = 1
        distanceLabel.TextScaled = true
        distanceLabel.Font = Enum.Font.SourceSans
        distanceLabel.TextSize = 14
        distanceLabel.Parent = distanceBillboard
        distanceBillboard.Parent = character
    end

    -- Create Tracers
    if showTracers then
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
end

local function removeESP(player)
    local character = player.Character
    if character then
        local billboard = character:FindFirstChild("ESPBillboard")
        if billboard then billboard:Destroy() end

        local distanceBillboard = character:FindFirstChild("ESPDistanceBillboard")
        if distanceBillboard then distanceBillboard:Destroy() end

        local tracer = character:FindFirstChild("ESPTracer")
        if tracer then tracer:Destroy() end

        local tracerAttachment0 = character:FindFirstChild("TracerAttachment0")
        if tracerAttachment0 then tracerAttachment0:Destroy() end
    end
end

local function updateESP(player)
    local character = player.Character
    if not character then return end
    removeESP(player)
    local distance = (localPlayer.Character.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude
    if distance <= maxDistance then
        createESP(player)
    end
end

local function updateAllESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            updateESP(player)
        end
    end
end

local function onPlayerAdded(player)
    player.CharacterAdded:Connect(function()
        wait(1) -- Ensure character is fully loaded
        updateESP(player)
    end)
end

local function initESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            updateESP(player)
        end
    end

    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(removeESP)
end

RunService.Heartbeat:Connect(updateAllESP)
initESP()
initPlayerList()

-- Toggle GUI visibility with a key press
local guiVisible = true

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.G then -- Change this to the key you want to use for toggling
        guiVisible = not guiVisible
        if guiVisible then
            Library:ToggleUI() -- Ensure this calls the correct method to open the GUI
        else
            Library:ToggleUI() -- Ensure this calls the correct method to close the GUI
        end
    end
end)

-- Local Player Settings
local LocalSection = LocalTab:NewSection("Local Player Settings")

LocalSection:NewSlider("Walk Speed", "Set your walk speed", 100, 16, function(value)
    localPlayer.Character.Humanoid.WalkSpeed = value
end)

LocalSection:NewSlider("Jump Power", "Set your jump power", 100, 50, function(value)
    localPlayer.Character.Humanoid.JumpPower = value
end)
