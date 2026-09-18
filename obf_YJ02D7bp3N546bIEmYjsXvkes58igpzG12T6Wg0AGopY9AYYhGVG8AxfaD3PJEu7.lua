-- // wallz.lol Advanced Framework v28 (Fixed & Stabilized Edition)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- // Configuration State
local Config = {
    AimbotEnabled = false,
    Smoothness = 5,      -- Lower value = smoother tracking interpolation
    FOVRadius = 350,     -- Detection boundary radius
    ESPEnabled = false,
    HitboxEnabled = false,
    HitboxSize = Vector3.new(4, 4, 4),
    FullbrightEnabled = false,
    MenuVisible = true
}

-- // GUI Construction (Modern Glassmorphism Theme)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WallzLolFramework"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 380, 0, 480)
MainFrame.Position = UDim2.new(0.15, 0, 0.15, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
MainFrame.BackgroundTransparency = 0.04
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(50, 50, 75)
UIStroke.Thickness = 1.5
UIStroke.Parent = MainFrame

-- Top Bar / Title
local TitleBar = Instance.new("TextButton")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundTransparency = 1
TitleBar.Text = ""
TitleBar.AutoButtonColor = false
TitleBar.Active = true
TitleBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -24, 1, 0)
TitleLabel.Position = UDim2.new(0, 16, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "wallz.lol <font color=\"#7c3aed\">//</font> menu (Fixed)"
TitleLabel.RichText = true
TitleLabel.TextColor3 = Color3.fromRGB(245, 245, 255)
TitleLabel.TextSize = 15
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local AccentGlow = Instance.new("Frame")
AccentGlow.Size = UDim2.new(1, -32, 0, 2)
AccentGlow.Position = UDim2.new(0, 16, 0, 48)
AccentGlow.BackgroundColor3 = Color3.fromRGB(124, 58, 237)
AccentGlow.BorderSizePixel = 0
AccentGlow.Parent = MainFrame

local UICornerGlow = Instance.new("UICorner")
UICornerGlow.CornerRadius = UDim.new(1, 0)
UICornerGlow.Parent = AccentGlow

local ContentContainer = Instance.new("ScrollingFrame")
ContentContainer.Size = UDim2.new(1, 0, 1, -55)
ContentContainer.Position = UDim2.new(0, 0, 0, 55)
ContentContainer.BackgroundTransparency = 1
ContentContainer.BorderSizePixel = 0
ContentContainer.CanvasSize = UDim2.new(0, 0, 0, 340)
ContentContainer.ScrollBarThickness = 3
ContentContainer.ScrollBarImageColor3 = Color3.fromRGB(124, 58, 237)
ContentContainer.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ContentContainer
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)

local Spacer = Instance.new("Frame")
Spacer.Size = UDim2.new(1, 0, 0, 4)
Spacer.BackgroundTransparency = 1
Spacer.Parent = ContentContainer

-- // Notification System
local function ShowNotification(messageText, customColor)
    pcall(function()
        local existing = ScreenGui:FindFirstChild("NotifyToast")
        if existing then existing:Destroy() end

        local toast = Instance.new("Frame")
        toast.Name = "NotifyToast"
        toast.Size = UDim2.new(0, 320, 0, 48)
        toast.Position = UDim2.new(0.5, -160, 0, -70)
        toast.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
        toast.BackgroundTransparency = 0.08
        toast.BorderSizePixel = 0
        toast.Parent = ScreenGui

        local tCorner = Instance.new("UICorner")
        tCorner.CornerRadius = UDim.new(0, 8)
        tCorner.Parent = toast

        local tStroke = Instance.new("UIStroke")
        tStroke.Color = customColor or Color3.fromRGB(255, 90, 90)
        tStroke.Thickness = 1.2
        tStroke.Parent = toast

        local tLabel = Instance.new("TextLabel")
        tLabel.Size = UDim2.new(1, -16, 1, 0)
        tLabel.Position = UDim2.new(0, 8, 0, 0)
        tLabel.BackgroundTransparency = 1
        tLabel.Text = messageText
        tLabel.TextColor3 = customColor or Color3.fromRGB(255, 140, 140)
        tLabel.TextSize = 12
        tLabel.Font = Enum.Font.GothamBold
        tLabel.TextWrapped = true
        tLabel.Parent = toast

        toast:TweenPosition(UDim2.new(0.5, -160, 0, 20), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.25, true)
        task.delay(3, function()
            if toast and toast.Parent then
                toast:TweenPosition(UDim2.new(0.5, -160, 0, -70), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.25, true)
                task.wait(0.25)
                toast:Destroy()
            end
        end)
    end)
end

-- // Universal Draggable Window Logic
local dragging = false
local dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- // UI Element Builders
local function CreateToggle(name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 340, 0, 44)
    btn.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    btn.TextColor3 = Color3.fromRGB(200, 200, 215)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamMedium
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Active = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(38, 38, 55)
    stroke.Thickness = 1.2
    stroke.Parent = btn

    local textLbl = Instance.new("TextLabel")
    textLbl.Size = UDim2.new(1, -75, 1, 0)
    textLbl.Position = UDim2.new(0, 14, 0, 0)
    textLbl.BackgroundTransparency = 1
    textLbl.Text = name
    textLbl.TextColor3 = Color3.fromRGB(210, 210, 225)
    textLbl.TextSize = 13
    textLbl.Font = Enum.Font.GothamMedium
    textLbl.TextXAlignment = Enum.TextXAlignment.Left
    textLbl.Parent = btn

    local statusLbl = Instance.new("TextLabel")
    statusLbl.Size = UDim2.new(0, 60, 1, 0)
    statusLbl.Position = UDim2.new(1, -70, 0, 0)
    statusLbl.BackgroundTransparency = 1
    statusLbl.Text = "OFF"
    statusLbl.TextColor3 = Color3.fromRGB(130, 130, 150)
    statusLbl.TextSize = 12
    statusLbl.Font = Enum.Font.GothamBold
    statusLbl.TextXAlignment = Enum.TextXAlignment.Right
    statusLbl.Parent = btn
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(24, 24, 35)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(18, 18, 26)}):Play()
    end)
    
    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        statusLbl.Text = active and "ACTIVE" or "OFF"
        statusLbl.TextColor3 = active and Color3.fromRGB(52, 211, 153) or Color3.fromRGB(130, 130, 150)
        stroke.Color = active and Color3.fromRGB(52, 211, 153) or Color3.fromRGB(38, 38, 55)
        callback(active)
    end)
    btn.Parent = ContentContainer
end

local function CreateActionButton(name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 340, 0, 44)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    btn.TextColor3 = Color3.fromRGB(147, 197, 253)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.Text = "    " .. name
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    btn.Active = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(59, 130, 246)
    stroke.Thickness = 1.2
    stroke.Parent = btn
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(26, 26, 40)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(20, 20, 30)}):Play()
    end)
    
    btn.MouseButton1Click:Connect(function()
        callback()
    end)
    btn.Parent = ContentContainer
end

-- // Code Redeemer Loop
local isRedeeming = false
local function ClaimAllCodes()
    if isRedeeming then return end
    isRedeeming = true
    task.spawn(function()
        pcall(function()
            local remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage:FindFirstChild("Network")
            local redeemRemote, redeemFunction = nil, nil

            if remotes then
                for _, v in ipairs(remotes:GetDescendants()) do
                    if v:IsA("RemoteFunction") and (v.Name:lower()..v.Parent.Name:lower()):match("code") then
                        redeemFunction = v
                        break
                    elseif v:IsA("RemoteEvent") and (v.Name:lower()..v.Parent.Name:lower()):match("code") then
                        redeemRemote = v
                        break
                    end
                end
            end

            local activeCodes = {"FREE197", "COMMUNITY25", "FREE196", "IMMELTINGHELP", "CANNONBALLLLL", "COCONUTBONK", "RIVALSSUMMER", "BONUS", "BOOST", "roblox_rtc"}
            
            if redeemFunction or redeemRemote then
                ShowNotification("Processing code queue...", Color3.fromRGB(96, 165, 250))
                for _, code in ipairs(activeCodes) do
                    pcall(function()
                        if redeemFunction then redeemFunction:InvokeServer(code)
                        elseif redeemRemote then redeemRemote:FireServer(code) end
                    end)
                    task.wait(1.5)
                end
                ShowNotification("Code sequence finished!", Color3.fromRGB(52, 211, 153))
            else
                ShowNotification("Code remote function not found.", Color3.fromRGB(255, 90, 90))
            end
        end)
        isRedeeming = false
    end)
end

-- // Open All Crates Loop
local isOpenCrates = false
local function OpenAllCrates()
    if isOpenCrates then return end
    isOpenCrates = true
    task.spawn(function()
        pcall(function()
            local remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage:FindFirstChild("Network")
            local crateRemote, crateFunction = nil, nil

            if remotes then
                for _, v in ipairs(remotes:GetDescendants()) do
                    local nameLower = (v.Name:lower() .. v.Parent.Name:lower())
                    if (v:IsA("RemoteFunction") or v:IsA("RemoteEvent")) and (nameLower:match("crate") or nameLower:match("box") or nameLower:match("open")) then
                        if v:IsA("RemoteFunction") then crateFunction = v else crateRemote = v end
                    end
                end
            end

            if crateFunction or crateRemote then
                ShowNotification("Opening inventory crates...", Color3.fromRGB(96, 165, 250))
                for i = 1, 3 do
                    pcall(function()
                        if crateFunction then crateFunction:InvokeServer("StandardCrate")
                        elseif crateRemote then crateRemote:FireServer("StandardCrate") end
                    end)
                    task.wait(1.5)
                end
                ShowNotification("Crate opening completed!", Color3.fromRGB(52, 211, 153))
            else
                ShowNotification("No crates found.", Color3.fromRGB(251, 191, 36))
            end
        end)
        isOpenCrates = false
    end)
end

-- // High-Visibility Rainbow ESP Container
local ESPContainer = {}

local function RemoveESP(player)
    if ESPContainer[player] then
        for _, obj in pairs(ESPContainer[player]) do
            pcall(function() obj:Remove() end)
        end
        ESPContainer[player] = nil
    end
end

local function ToggleESP(state)
    Config.ESPEnabled = state
    if not state then
        for player, _ in pairs(ESPContainer) do
            RemoveESP(player)
        end
    end
end

-- // Hitbox Expander Logic
local function ToggleHitbox(state)
    Config.HitboxEnabled = state
    task.spawn(function()
        while Config.HitboxEnabled do
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.Size = state and Config.HitboxSize or Vector3.new(2, 2, 1)
                        hrp.Transparency = state and 0.6 or 1
                        hrp.CanCollide = false
                    end
                end
            end
            task.wait(1)
        end
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                hrp.Size = Vector3.new(2, 2, 1)
                hrp.Transparency = 1
                hrp.CanCollide = true
            end
        end
    end)
end

-- // Fullbright Utility
local originalBrightness = Lighting.Brightness
local originalClockTime = Lighting.ClockTime
local originalGlobalShadows = Lighting.GlobalShadows

local function ToggleFullbright(state)
    Config.FullbrightEnabled = state
    if state then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
    else
        Lighting.Brightness = originalBrightness
        Lighting.ClockTime = originalClockTime
        Lighting.GlobalShadows = originalGlobalShadows
    end
end

RunService.RenderStepped:Connect(function()
    if Config.ESPEnabled then
        local rainbowColor = Color3.fromHSV((tick() % 5) / 5, 1, 1)

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local char = player.Character
                local hrp = char.HumanoidRootPart
                local head = char:FindFirstChild("Head")
                local humanoid = char:FindFirstChildOfClass("Humanoid")

                if humanoid and humanoid.Health > 0 and head then
                    local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        if not ESPContainer[player] then
                            local drawings = {}
                            drawings.TL1 = Drawing.new("Line") drawings.TL2 = Drawing.new("Line")
                            drawings.TR1 = Drawing.new("Line") drawings.TR2 = Drawing.new("Line")
                            drawings.BL1 = Drawing.new("Line") drawings.BL2 = Drawing.new("Line")
                            drawings.BR1 = Drawing.new("Line") drawings.BR2 = Drawing.new("Line")
                            
                            drawings.TopNameText = Drawing.new("Text")
                            drawings.TopNameText.Size = 14
                            drawings.TopNameText.Center = true
                            drawings.TopNameText.Outline = true
                            drawings.TopNameText.Font = 2

                            drawings.BottomNameText = Drawing.new("Text")
                            drawings.BottomNameText.Size = 14
                            drawings.BottomNameText.Center = true
                            drawings.BottomNameText.Outline = true
                            drawings.BottomNameText.Font = 2

                            for _, line in pairs(drawings) do
                                if typeof(line) == "Instance" and line.ClassName == "Line" then
                                    line.Thickness = 3
                                end
                            end
                            ESPContainer[player] = drawings
                        end

                        local drawings = ESPContainer[player]
                        local size = Vector2.new(2400 / vector.Z, 3400 / vector.Z)
                        local pos = Vector2.new(vector.X - size.X / 2, vector.Y - size.Y / 2)
                        
                        for _, line in pairs(drawings) do
                            if typeof(line) == "Instance" and line.ClassName == "Line" then
                                line.Color = rainbowColor
                                line.Visible = true
                            end
                        end

                        local lineLenX = size.X / 3.5
                        local lineLenY = size.Y / 3.5

                        drawings.TL1.From = pos drawings.TL2.From = pos
                        drawings.TL1.To = Vector2.new(pos.X + lineLenX, pos.Y)
                        drawings.TL2.To = Vector2.new(pos.X, pos.Y + lineLenY)

                        local tr = Vector2.new(pos.X + size.X, pos.Y)
                        drawings.TR1.From = tr drawings.TR2.From = tr
                        drawings.TR1.To = Vector2.new(tr.X - lineLenX, tr.Y)
                        drawings.TR2.To = Vector2.new(tr.X, tr.Y + lineLenY)

                        local bl = Vector2.new(pos.X, pos.Y + size.Y)
                        drawings.BL1.From = bl drawings.BL2.From = bl
                        drawings.BL1.To = Vector2.new(bl.X + lineLenX, bl.Y)
                        drawings.BL2.To = Vector2.new(bl.X, bl.Y - lineLenY)

                        local br = Vector2.new(pos.X + size.X, pos.Y + size.Y)
                        drawings.BR1.From = br drawings.BR2.From = br
                        drawings.BR1.To = Vector2.new(br.X - lineLenX, br.Y)
                        drawings.BR2.To = Vector2.new(br.X, br.Y - lineLenY)

                        drawings.TopNameText.Text = player.Name
                        drawings.TopNameText.Position = Vector2.new(pos.X + size.X / 2, pos.Y - 20)
                        drawings.TopNameText.Color = Color3.fromRGB(255, 255, 255)
                        drawings.TopNameText.Visible = true

                        drawings.BottomNameText.Text = "@" .. player.Name
                        drawings.BottomNameText.Position = Vector2.new(pos.X + size.X / 2, pos.Y + size.Y + 4)
                        drawings.BottomNameText.Color = rainbowColor
                        drawings.BottomNameText.Visible = true
                    else
                        RemoveESP(player)
                    end
                else
                    RemoveESP(player)
                end
            else
                RemoveESP(player)
            end
        end
    else
        for player, _ in pairs(ESPContainer) do
            RemoveESP(player)
        end
    end
end)

-- // Stable Fixed Aimbot Engine (Mouse Delta / Viewport Sync)
RunService.RenderStepped:Connect(function()
    if not Config.AimbotEnabled then return end
    
    local isRightMouseDown = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    if not isRightMouseDown then return end

    local closestTarget = nil
    local shortestDist = Config.FOVRadius
    local mouseLocation = UserInputService:GetMouseLocation()
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local head = player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and head then
                -- Team check check (if applicable, ignores teammates)
                if player.Team ~= LocalPlayer.Team or not player.Team then
                    local screenPoint, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local magnitude = (Vector2.new(mouseLocation.X, mouseLocation.Y) - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
                        if magnitude < shortestDist then
                            shortestDist = magnitude
                            closestTarget = head
                        end
                    end
                end
            end
        end
    end
    
    if closestTarget then
        local targetScreenPoint, onScreen = Camera:WorldToViewportPoint(closestTarget.Position)
        if onScreen then
            local targetPos = Vector2.new(targetScreenPoint.X, targetScreenPoint.Y)
            local moveX = (targetPos.X - mouseLocation.X) / Config.Smoothness
            local moveY = (targetPos.Y - mouseLocation.Y) / Config.Smoothness
            
            if mousemoverel then
                mousemoverel(moveX, moveY)
            else
                -- Fallback for executors lacking mousemoverel
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, closestTarget.Position), 0.2)
            end
        end
    end
end)

-- // UI Menu Initialization
CreateToggle("Aimbot (Hold Right Click)", function(state) Config.AimbotEnabled = state end)
CreateToggle("Rainbow ESP", function(state) ToggleESP(state) end)
CreateToggle("Hitbox Expander", function(state) ToggleHitbox(state) end)
CreateToggle("Fullbright (Lighting Fix)", function(state) ToggleFullbright(state) end)
CreateActionButton("Claim All Codes", function() ClaimAllCodes() end)
CreateActionButton("Open All Crates", function() OpenAllCrates() end)

-- // Keybind to toggle menu visibility (Insert key)
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        Config.MenuVisible = not Config.MenuVisible
        MainFrame.Visible = Config.MenuVisible
    end
end)