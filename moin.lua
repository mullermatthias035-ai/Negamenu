--// Rayfield laden
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

--// Services
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local function humanoid()
    local char = player.Character
    if char then
        return char:FindFirstChildOfClass("Humanoid")
    end
end

--// Fenster
local Window = Rayfield:CreateWindow({
    Name = "Fun Menü",
    LoadingTitle = "Fun Menü",
    LoadingSubtitle = "Client Side",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "FunMenu",
        FileName = "FunConfig"
    }
})

--// Tabs
local PlayerTab = Window:CreateTab("Player")
local FunTab = Window:CreateTab("Fun")
local VisualTab = Window:CreateTab("Visuals")
local TrollTab = Window:CreateTab("Troll")

-------------------------------------------------
-- PLAYER
-------------------------------------------------

-- WalkSpeed
PlayerTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 200},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(v)
        if humanoid() then humanoid().WalkSpeed = v end
    end
})

-- JumpPower
PlayerTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 350},
    Increment = 5,
    CurrentValue = 50,
    Callback = function(v)
        if humanoid() then humanoid().JumpPower = v end
    end
})

-- Infinite Jump
local infJump = false
PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = function(v)
        infJump = v
    end
})

UIS.JumpRequest:Connect(function()
    if infJump and humanoid() then
        humanoid():ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Godmode (Client)
PlayerTab:CreateToggle({
    Name = "Godmode (Client)",
    CurrentValue = false,
    Callback = function(v)
        if humanoid() then
            humanoid().Health = v and math.huge or humanoid().MaxHealth
        end
    end
})

-------------------------------------------------
-- FUN
-------------------------------------------------

-- Sit
FunTab:CreateButton({
    Name = "Sit",
    Callback = function()
        if humanoid() then humanoid().Sit = true end
    end
})

-- Reset
FunTab:CreateButton({
    Name = "Reset Character",
    Callback = function()
        player.Character:BreakJoints()
    end
})

-- Super Punch (Animation Fake)
FunTab:CreateButton({
    Name = "Super Punch",
    Callback = function()
        local char = player.Character
        if not char then return end
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://484200742"
        local track = humanoid():LoadAnimation(anim)
        track:Play()
    end
})

-- Fly (Simple)
local flying = false
FunTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Callback = function(state)
        flying = state
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        if state then
            local bv = Instance.new("BodyVelocity", hrp)
            bv.Name = "FlyVelocity"
            bv.MaxForce = Vector3.new(1e5,1e5,1e5)

            RunService.RenderStepped:Connect(function()
                if flying and bv then
                    bv.Velocity = camera.CFrame.LookVector * 60
                end
            end)
        else
            if hrp:FindFirstChild("FlyVelocity") then
                hrp.FlyVelocity:Destroy()
            end
        end
    end
})

-------------------------------------------------
-- VISUALS
-------------------------------------------------

-- FOV
VisualTab:CreateSlider({
    Name = "Field of View",
    Range = {70, 120},
    Increment = 1,
    CurrentValue = 70,
    Callback = function(v)
        camera.FieldOfView = v
    end
})

-- Fullbright
VisualTab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false,
    Callback = function(v)
        if v then
            game.Lighting.Brightness = 5
            game.Lighting.ClockTime = 12
            game.Lighting.FogEnd = 100000
        end
    end
})

-------------------------------------------------
-- TROLL
-------------------------------------------------

-- Spin
local spinning = false
TrollTab:CreateToggle({
    Name = "Spin",
    CurrentValue = false,
    Callback = function(v)
        spinning = v
        RunService.RenderStepped:Connect(function()
            if spinning and player.Character then
                player.Character:SetPrimaryPartCFrame(
                    player.Character.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(10), 0)
                )
            end
        end)
    end
})

-- Big Head
TrollTab:CreateButton({
    Name = "Big Head",
    Callback = function()
        local char = player.Character
        if char and char:FindFirstChild("Head") then
            char.Head.Size = Vector3.new(5,5,5)
        end
    end
})

-------------------------------------------------
Rayfield:Notify({
    Title = "Fun Menü geladen",
    Content = "Viel Spaß 😄",
    Duration = 5
})
