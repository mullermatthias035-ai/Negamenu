--==================================================
-- SERVICES
--==================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

--==================================================
-- LOADING SCREEN
--==================================================
local loadingGui = Instance.new("ScreenGui")
loadingGui.Parent = player:WaitForChild("PlayerGui")
loadingGui.ResetOnSpawn = false

local loadingFrame = Instance.new("Frame", loadingGui)
loadingFrame.Size = UDim2.fromScale(1,1)
loadingFrame.BackgroundColor3 = Color3.fromRGB(10,10,15)

local loadingText = Instance.new("TextLabel", loadingFrame)
loadingText.AnchorPoint = Vector2.new(0.5,0.5)
loadingText.Position = UDim2.fromScale(0.5,0.5)
loadingText.Size = UDim2.fromOffset(300,60)
loadingText.Text = "LEON SCRIPTS\nLoading..."
loadingText.Font = Enum.Font.GothamBlack
loadingText.TextSize = 24
loadingText.TextColor3 = Color3.fromRGB(0,255,190)
loadingText.BackgroundTransparency = 1
loadingText.TextWrapped = true

task.wait(1.5)
TweenService:Create(loadingFrame, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
task.wait(0.4)
loadingGui:Destroy()

--==================================================
-- UI ROOT
--==================================================
local gui = Instance.new("ScreenGui")
gui.Name = "LeonScriptsUI"
gui.ResetOnSpawn = false
gui.Parent = player.PlayerGui

local scale = Instance.new("UIScale", gui)
scale.Scale = UserInputService.TouchEnabled and 0.9 or 1

--==================================================
-- MAIN FRAME
--==================================================
local frame = Instance.new("Frame", gui)
frame.AnchorPoint = Vector2.new(0.5,0.5)
frame.Position = UDim2.fromScale(0.5,0.5)
frame.Size = UDim2.fromOffset(460,300)
frame.BackgroundColor3 = Color3.fromRGB(15,15,20)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,20)

-- TITLE
local title = Instance.new("TextLabel", frame)
title.Text = "LEON SCRIPTS"
title.Font = Enum.Font.GothamBlack
title.TextSize = 26
title.TextColor3 = Color3.fromRGB(0,255,190)
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(20,14)
title.Size = UDim2.new(1,-40,30)
title.TextXAlignment = Enum.TextXAlignment.Left

--==================================================
-- TAB BUTTONS
--==================================================
local tabHolder = Instance.new("Frame", frame)
tabHolder.Position = UDim2.fromOffset(20,55)
tabHolder.Size = UDim2.fromOffset(120,225)
tabHolder.BackgroundTransparency = 1

local function tabButton(text,y)
	local b = Instance.new("TextButton", tabHolder)
	b.Size = UDim2.fromOffset(120,40)
	b.Position = UDim2.fromOffset(0,y)
	b.Text = text
	b.Font = Enum.Font.GothamBold
	b.TextSize = 14
	b.TextColor3 = Color3.fromRGB(200,200,200)
	b.BackgroundColor3 = Color3.fromRGB(25,25,35)
	b.BorderSizePixel = 0
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,12)
	return b
end

local tabPlayer = tabButton("Player",0)
local tabESP = tabButton("ESP",50)
local tabVisual = tabButton("Visuals",100)

--==================================================
-- CONTENT PAGES
--==================================================
local content = Instance.new("Frame", frame)
content.Position = UDim2.fromOffset(160,55)
content.Size = UDim2.fromOffset(280,225)
content.BackgroundTransparency = 1

local function page()
	local f = Instance.new("Frame", content)
	f.Size = UDim2.fromScale(1,1)
	f.Visible = false
	f.BackgroundTransparency = 1
	return f
end

local pagePlayer = page()
local pageESP = page()
local pageVisual = page()
pagePlayer.Visible = true

local function switch(p)
	for _,v in pairs(content:GetChildren()) do
		v.Visible = false
	end
	p.Visible = true
end

tabPlayer.MouseButton1Click:Connect(function() switch(pagePlayer) end)
tabESP.MouseButton1Click:Connect(function() switch(pageESP) end)
tabVisual.MouseButton1Click:Connect(function() switch(pageVisual) end)

--==================================================
-- UI BUTTON HELPER
--==================================================
local function uiButton(parent,text,y,callback)
	local b = Instance.new("TextButton", parent)
	b.Size = UDim2.fromOffset(260,44)
	b.Position = UDim2.fromOffset(10,y)
	b.Text = text
	b.Font = Enum.Font.GothamBold
	b.TextSize = 14
	b.TextColor3 = Color3.fromRGB(10,10,10)
	b.BackgroundColor3 = Color3.fromRGB(0,255,190)
	b.BorderSizePixel = 0
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,14)
	b.MouseButton1Click:Connect(callback)
end

--==================================================
-- PLAYER PAGE
--==================================================
uiButton(pagePlayer,"Reset Character",10,function()
	player.Character:BreakJoints()
end)

--==================================================
-- ESP SYSTEM
--==================================================
local ESP_ENABLED = false
local ESP_COLOR = Color3.fromRGB(0,255,190)
local ESP_CACHE = {}

local R15_BONES = {
	{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
	{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
	{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
	{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
	{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}
}

local R6_BONES = {
	{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}
}

local function newText()
	local t = Drawing.new("Text")
	t.Center = true
	t.Outline = true
	t.Size = 14
	t.Color = ESP_COLOR
	return t
end

local function newLine()
	local l = Drawing.new("Line")
	l.Thickness = 2
	l.Color = ESP_COLOR
	return l
end

local function newSquare(color)
	local s = Drawing.new("Square")
	s.Filled = true
	s.Color = color
	return s
end

local function createESP(plr)
	if plr == player then return end
	local data = {
		Name = newText(),
		HealthBG = newSquare(Color3.fromRGB(40,40,40)),
		Health = newSquare(Color3.fromRGB(0,255,0)),
		Skeleton = {}
	}
	for i=1,15 do table.insert(data.Skeleton,newLine()) end
	ESP_CACHE[plr] = data
end

local function removeESP(plr)
	local d = ESP_CACHE[plr]
	if not d then return end
	d.Name:Remove()
	d.HealthBG:Remove()
	d.Health:Remove()
	for _,l in pairs(d.Skeleton) do l:Remove() end
	ESP_CACHE[plr] = nil
end

uiButton(pageESP,"Toggle ESP",10,function()
	ESP_ENABLED = not ESP_ENABLED
	if not ESP_ENABLED then
		for plr in pairs(ESP_CACHE) do removeESP(plr) end
	end
end)

RunService.RenderStepped:Connect(function()
	if not ESP_ENABLED then return end
	for _,plr in pairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			if not ESP_CACHE[plr] then createESP(plr) end
			local hum = plr.Character:FindFirstChildOfClass("Humanoid")
			local hrp = plr.Character.HumanoidRootPart
			local pos, onscreen = camera:WorldToViewportPoint(hrp.Position)
			local esp = ESP_CACHE[plr]
			if onscreen and hum then
				-- Name
				esp.Name.Visible = true
				esp.Name.Text = plr.Name
				esp.Name.Position = Vector2.new(pos.X,pos.Y-40)

				-- Healthbar
				local hp = hum.Health/hum.MaxHealth
				esp.HealthBG.Visible = true
				esp.Health.Visible = true
				esp.HealthBG.Size = Vector2.new(4,40)
				esp.HealthBG.Position = Vector2.new(pos.X-30,pos.Y-20)
				esp.Health.Size = Vector2.new(4,40*hp)
				esp.Health.Position = Vector2.new(pos.X-30,pos.Y-20+(40-40*hp))
				esp.Health.Color = Color3.fromRGB(255*(1-hp),255*hp,0)

				-- Skeleton
				local bones = hum.RigType == Enum.HumanoidRigType.R15 and R15_BONES or R6_BONES
				for i,b in ipairs(bones) do
					local p1 = plr.Character:FindFirstChild(b[1])
					local p2 = plr.Character:FindFirstChild(b[2])
					local line = esp.Skeleton[i]
					if p1 and p2 then
						local v1,ok1 = camera:WorldToViewportPoint(p1.Position)
						local v2,ok2 = camera:WorldToViewportPoint(p2.Position)
						if ok1 and ok2 then
							line.Visible = true
							line.From = Vector2.new(v1.X,v1.Y)
							line.To = Vector2.new(v2.X,v2.Y)
						else
							line.Visible = false
						end
					else
						line.Visible = false
					end
				end
			else
				esp.Name.Visible = false
				esp.HealthBG.Visible = false
				esp.Health.Visible = false
				for _,l in pairs(esp.Skeleton) do l.Visible = false end
			end
		end
	end
end)

--==================================================
-- VISUAL PAGE
--==================================================
uiButton(pageVisual,"Fullbright",10,function()
	game.Lighting.Brightness = 5
	game.Lighting.ClockTime = 12
	game.Lighting.FogEnd = 1e6
end)

--==================================================
-- MINIMIZE / HOTKEY / MOBILE
--==================================================
local open = true
local function toggleUI()
	open = not open
	frame.Visible = open
end

UserInputService.InputBegan:Connect(function(i,gp)
	if not gp and i.KeyCode == Enum.KeyCode.K then
		toggleUI()
	end
end)

if UserInputService.TouchEnabled then
	local btn = Instance.new("TextButton", gui)
	btn.Size = UDim2.fromOffset(60,60)
	btn.Position = UDim2.fromScale(0.05,0.5)
	btn.Text = "≡"
	btn.Font = Enum.Font.GothamBlack
	btn.TextSize = 28
	btn.BackgroundColor3 = Color3.fromRGB(0,255,190)
	btn.TextColor3 = Color3.fromRGB(10,10,10)
	Instance.new("UICorner", btn).CornerRadius = UDim.new(1,0)
	btn.MouseButton1Click:Connect(toggleUI)
end

--==================================================
-- INTRO ANIMATION
--==================================================
frame.Size = UDim2.fromOffset(0,0)
TweenService:Create(frame,TweenInfo.new(0.45,Enum.EasingStyle.Back),{
	Size = UDim2.fromOffset(460,300)
}):Play()
