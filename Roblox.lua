-- // Library
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()

-- // Main Window
local Window = Rayfield:CreateWindow({
    Name = "Kill Aura 1.0",
    LoadingTitle = "Kill Aura - Initializing",
    LoadingSubtitle = "by TLG",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "KillAuraConfig",
        FileName = "Settings"
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false
})

-- // Variables
local killAuraEnabled = false
local killRange = 100
local autoFixLagEnabled = false
local originalGraphicsSettings = {}

-- // Main Tab
local MainTab = Window:CreateTab("Main", 4483362458) 

-- // Kill Aura Section
local KillAuraSection = MainTab:CreateSection("Combat Automation")

MainTab:CreateToggle({
    Name = "Kill Aura Beta",
    Callback = function(Value)
        killAuraEnabled = Value
        if killAuraEnabled then
            coroutine.wrap(function()
                while killAuraEnabled and task.wait(0.1) do
                    local localPlayer = game:GetService("Players").LocalPlayer
                    local character = localPlayer.Character
                    if not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then continue end

                    local bestWeapon = nil
                    for _, tool in pairs(localPlayer.Backpack:GetChildren()) do
                        if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
                            bestWeapon = tool
                            break
                        end
                    end
                    if not bestWeapon and character:FindFirstChildOfClass("Tool") then
                         bestWeapon = character:FindFirstChildOfClass("Tool")
                    end

                    if not bestWeapon then continue end
                    
                    character.Humanoid:EquipTool(bestWeapon)

                    local target = nil
                    local closestDist = killRange
                    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
                        if player ~= localPlayer and player.Team ~= localPlayer.Team then
                            local enemyChar = player.Character
                            if enemyChar and enemyChar:FindFirstChild("Humanoid") and enemyChar.Humanoid.Health > 0 and enemyChar:FindFirstChild("Head") then
                                local distance = (character.HumanoidRootPart.Position - enemyChar.Head.Position).Magnitude
                                if distance < closestDist then
                                    closestDist = distance
                                    target = enemyChar
                                end
                            end
                        end
                    end

                    if target and bestWeapon:FindFirstChild("Handle") then
                         -- Simulate attack through remote events to ensure server-side damage
                        pcall(function()
                            game:GetService("ReplicatedStorage"):WaitForChild("DefaultRemotes"):WaitForChild("Combat"):WaitForChild("Damage"):FireServer(target.Humanoid)
                        end)
                        pcall(function()
                             bestWeapon.Activated:Wait()
                        end)
                    end
                end
            end)()
        end
    end,
    Default = false,
    Description = "Automatically attacks hostile targets within range."
})

MainTab:CreateSlider({
    Name = "Attack Range",
    Range = {10, 500},
    Increment = 5,
    Suffix = "studs",
    Default = 100,
    Callback = function(Value)
        killRange = Value
    end,
    Description = "Adjusts the maximum distance for Kill Aura to find targets."
})

-- // Optimization Section
local OptimizationSection = MainTab:CreateSection("Performance")

local function storeOriginalSettings()
    local lighting = game:GetService("Lighting")
    originalGraphicsSettings.GlobalShadows = lighting.GlobalShadows
    originalGraphicsSettings.Technology = lighting.Technology
    originalGraphicsSettings.RenderDistance = workspace.StreamingTargetRadius
    if settings() and settings().Rendering then
        originalGraphicsSettings.QualityLevel = settings().Rendering.QualityLevel
        originalGraphicsSettings.MeshPartDetailLevel = settings().Rendering.MeshPartDetailLevel
    end
end

local function applyLowSettings()
    local lighting = game:GetService("Lighting")
    lighting.GlobalShadows = false
    lighting.Technology = Enum.Technology.Compatibility
    workspace.StreamingEnabled = true
    workspace.StreamingTargetRadius = 128 
    
    if settings() and settings().Rendering then
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
    end

    for _, descendant in pairs(workspace:GetDescendants()) do
        if descendant:IsA("BasePart") and descendant.Material == Enum.Material.Neon then
            descendant.Material = Enum.Material.Plastic
        end
        if descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") then
            descendant.Enabled = false
        end
    end
end

local function restoreOriginalSettings()
    local lighting = game:GetService("Lighting")
    lighting.GlobalShadows = originalGraphicsSettings.GlobalShadows
    lighting.Technology = originalGraphicsSettings.Technology
    workspace.StreamingTargetRadius = originalGraphicsSettings.RenderDistance

    if settings() and settings().Rendering then
        settings().Rendering.QualityLevel = originalGraphicsSettings.QualityLevel
        settings().Rendering.MeshPartDetailLevel = originalGraphicsSettings.MeshPartDetailLevel
    end
    
    -- Re-enabling effects is more complex, a simple approach is left out to avoid breaking games.
    -- For a full revert, you'd need to store the state of every particle emitter.
end

storeOriginalSettings() -- Store settings on script start

MainTab:CreateToggle({
    Name = "Auto Fix Lag",
    Callback = function(Value)
        autoFixLagEnabled = Value
        if autoFixLagEnabled then
            applyLowSettings()
        else
            restoreOriginalSettings()
        end
    end,
    Default = false,
    Description = "Lowers graphics and effects to improve performance on weak devices."
})

-- // Footer Section
local FooterSection = MainTab:CreateSection("") -- Empty name for spacing

MainTab:CreateLabel({
    Name = "Demo for Testing Purposes Only",
    FontSize = 16,
    Color = Color3.fromRGB(255, 100, 100)
})

MainTab:CreateLabel({
    Name = "Made by TLG",
    FontSize = 18,
    Color = Color3.fromRGB(0, 0, 0),
    BackgroundColor = Color3.fromRGB(255, 255, 255)
})
