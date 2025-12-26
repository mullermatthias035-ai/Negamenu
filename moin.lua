
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
local loadingGui = Instance.new("ScreenGui", player.PlayerGui)
loadingGui.ResetOnSpawn = false

local lf = Instance.new("Frame", loadingGui)
lf.Size = UDim2.fromScale(1,1)
lf.BackgroundColor3 = Color3.fromRGB(10,10,15)

local lt = Instance.new("TextLabel", lf)
lt.AnchorPoint = Vector2.new(0.5,0.5)
lt.Position = UDim2.fromScale(0.5,0.5)
lt.Size = UDim2.fromOffset(300,80)
lt.Text = "LEON SCRIPTS\nLoading..."
lt.Font = Enum.Font.GothamBlack
lt.TextSize = 24
lt.TextColor3 = Color3.fromRGB(0,255,190)
lt.BackgroundTransparency = 1
lt.TextWrapped = true

task.wait(1.3)
TweenService:Create(lf,TweenInfo.new(0.4),{BackgroundTransparency=1}):Play()
task.wait(0.4)
loadingGui:Destroy()

--==================================================
-- UI ROOT
--==================================================
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "LeonScriptsUI"
gui.ResetOnSpawn = false

local scale = Instance.new("UIScale", gui)
scale.Scale = UserInputService.TouchEnabled and 0.9 or 1

--==================================================
-- MAIN FRAME
--==================================================
local frame = Instance.new("Frame", gui)
frame.AnchorPoint = Vector2.new(0.5,0.5)
frame.Position = UDim2.fromScale(0.5,0.5)
frame.Size = UDim2.fromOffset(460,320)
frame.BackgroundColor3 = Color3.fromRGB(15,15,20)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,20)

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
-- TABS
--==================================================
local tabHolder = Instance.new("Frame", frame)
tabHolder.Position = UDim2.fromOffset(20,60)
tabHolder.Size = UDim2.fromOffset(120,240)
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
local tabESP    = tabButton("ESP",50)
local tabVisual = tabButton("Visuals",100)

--==================================================
-- CONTENT
--==================================================
local content = Instance.new("Frame", frame)
content.Position = UDim2.fromOffset(160,60)
content.Size = UDim2.fromOffset(280,240)
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
	for _,v in pairs(content:GetChildren()) do v.Visible = false end
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
	return b
end

--==================================================
-- PLAYER TAB
--==================================================
uiButton(pagePlayer,"Reset Character",10,function()
	if player.Character then player.Character:BreakJoints() end
end)

--==================================================
-- ESP (Name + Health + Skeleton)
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

local function dText()
	local t = Drawing.new("Text")
	t.Center=true; t.Outline=true; t.Size=14; t.Color=ESP_COLOR
	return t
end
local function dLine()
	local l = Drawing.new("Line")
	l.Thickness=2; l.Color=ESP_COLOR
	return l
end
local function dSquare(c)
	local s = Drawing.new("Square")
	s.Filled=true; s.Color=c
	return s
end

local function createESP(plr)
	if plr==player then return end
	local e = {Name=dText(), HealthBG=dSquare(Color3.fromRGB(40,40,40)), Health=dSquare(Color3.fromRGB(0,255,0)), Skeleton={}}
	for i=1,15 do table.insert(e.Skeleton,dLine()) end
	ESP_CACHE[plr]=e
end

local function clearESP(plr)
	local e=ESP_CACHE[plr]; if not e then return end
	e.Name:Remove(); e.HealthBG:Remove(); e.Health:Remove()
	for _,l in pairs(e.Skeleton) do l:Remove() end
	ESP_CACHE[plr]=nil
end

uiButton(pageESP,"Toggle ESP",10,function()
	ESP_ENABLED = not ESP_ENABLED
	if not ESP_ENABLED then
		for p in pairs(ESP_CACHE) do clearESP(p) end
	end
end)

RunService.RenderStepped:Connect(function()
	if not ESP_ENABLED then return end
	for _,plr in pairs(Players:GetPlayers()) do
		if plr~=player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			if not ESP_CACHE[plr] then createESP(plr) end
			local hum = plr.Character:FindFirstChildOfClass("Humanoid")
			local hrp = plr.Character.HumanoidRootPart
			local pos,on = camera:WorldToViewportPoint(hrp.Position)
			local e = ESP_CACHE[plr]
			if on and hum then
				e.Name.Visible=true
				e.Name.Text=plr.Name
				e.Name.Position=Vector2.new(pos.X,pos.Y-40)

				local hp=hum.Health/hum.MaxHealth
				e.HealthBG.Visible=true; e.Health.Visible=true
				e.HealthBG.Size=Vector2.new(4,40)
				e.HealthBG.Position=Vector2.new(pos.X-30,pos.Y-20)
				e.Health.Size=Vector2.new(4,40*hp)
				e.Health.Position=Vector2.new(pos.X-30,pos.Y-20+(40-40*hp))
				e.Health.Color=Color3.fromRGB(255*(1-hp),255*hp,0)

				local bones = hum.RigType==Enum.HumanoidRigType.R15 and R15_BONES or R6_BONES
				for i,b in ipairs(bones) do
					local p1=plr.Character:FindFirstChild(b[1])
					local p2=plr.Character:FindFirstChild(b[2])
					local l=e.Skeleton[i]
					if p1 and p2 then
						local v1,o1=camera:WorldToViewportPoint(p1.Position)
						local v2,o2=camera:WorldToViewportPoint(p2.Position)
						if o1 and o2 then
							l.Visible=true
							l.From=Vector2.new(v1.X,v1.Y)
							l.To=Vector2.new(v2.X,v2.Y)
						else l.Visible=false end
					else l.Visible=false end
				end
			else
				e.Name.Visible=false; e.HealthBG.Visible=false; e.Health.Visible=false
				for _,l in pairs(e.Skeleton) do l.Visible=false end
			end
		end
	end
end)

--==================================================
-- FLY + FREECAM + TELEPORT
--==================================================
local fly=false
local flySpeed=60
local bv,bg
local freecam=false
local oldType,oldSubject

local function startFly()
	if not player.Character then return end
	local hrp=player.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	bv=Instance.new("BodyVelocity",hrp)
	bv.MaxForce=Vector3.new(1e5,1e5,1e5)
	bg=Instance.new("BodyGyro",hrp)
	bg.MaxTorque=Vector3.new(1e5,1e5,1e5)

	RunService:BindToRenderStep("Fly",Enum.RenderPriority.Camera.Value,function()
		if not fly then return end
		local dir=Vector3.zero
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir+=camera.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir-=camera.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir-=camera.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir+=camera.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir+=Vector3.new(0,1,0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir-=Vector3.new(0,1,0) end
		bv.Velocity = dir.Magnitude>0 and dir.Unit*flySpeed or Vector3.zero
		bg.CFrame=camera.CFrame
	end)
end

local function stopFly()
	RunService:UnbindFromRenderStep("Fly")
	if bv then bv:Destroy() end
	if bg then bg:Destroy() end
end

local function toggleFreecam()
	freecam = not freecam
	if freecam then
		oldType=camera.CameraType
		oldSubject=camera.CameraSubject
		camera.CameraType=Enum.CameraType.Scriptable
	else
		camera.CameraType=oldType or Enum.CameraType.Custom
		camera.CameraSubject=oldSubject or player.Character
	end
end

local function tpToCam()
	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		player.Character.HumanoidRootPart.CFrame = camera.CFrame
	end
end

-- PC Teleport Key
UserInputService.InputBegan:Connect(function(i,gp)
	if not gp and i.KeyCode==Enum.KeyCode.M then
		tpToCam()
	end
end)

-- UI VISUAL TAB
uiButton(pageVisual,"Fly Toggle",10,function()
	fly=not fly
	if fly then startFly() else stopFly() end
end)

uiButton(pageVisual,"Fly Speed +10",60,function()
	flySpeed = math.clamp(flySpeed+10,20,200)
end)

uiButton(pageVisual,"Freecam Toggle",110,toggleFreecam)
uiButton(pageVisual,"TP to Camera",160,tpToCam)

--==================================================
-- MINIMIZE
--==================================================
local open=true
local function toggleUI() open=not open; frame.Visible=open end

UserInputService.InputBegan:Connect(function(i,gp)
	if not gp and i.KeyCode==Enum.KeyCode.K then toggleUI() end
end)

if UserInputService.TouchEnabled then
	local b=Instance.new("TextButton",gui)
	b.Size=UDim2.fromOffset(60,60)
	b.Position=UDim2.fromScale(0.05,0.5)
	b.Text="≡"
	b.Font=Enum.Font.GothamBlack
	b.TextSize=28
	b.BackgroundColor3=Color3.fromRGB(0,255,190)
	b.TextColor3=Color3.fromRGB(10,10,10)
	Instance.new("UICorner",b).CornerRadius=UDim.new(1,0)
	b.MouseButton1Click:Connect(toggleUI)
end

-- INTRO
frame.Size=UDim2.fromOffset(0,0)
TweenService:Create(frame,TweenInfo.new(0.45,Enum.EasingStyle.Back),{
	Size=UDim2.fromOffset(460,320)
}):Play()
