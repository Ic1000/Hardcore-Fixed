-- ========================================================
--         SHOCKER ENTITY SCRIPT (FIXED ACHIEVEMENT)
-- ========================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- TẠO BIẾN TOÀN CỤC KHÓA THÀNH TỰU (Tránh bị hiện 2 lần)
if getgenv().ShockerAchievementEarned == nil then
	getgenv().ShockerAchievementEarned = false
end

local function GiveAchievement()
	if getgenv().ShockerAchievementEarned then
		return
	end
	getgenv().ShockerAchievementEarned = true

	task.spawn(function()
		local success, achievementGiver = pcall(function()
			return loadstring(game:HttpGet(
				"https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Custom%20Achievements/Source.lua"
			))()
		end)

		if success and achievementGiver then
			pcall(function()
				achievementGiver({
					Title = "Shocking Experience",
					Desc = "Look at me.",
					Reason = "Encounter Shocker.",
					Image = "rbxassetid://17857830685"
				})
			end)
		end
	end)
end

local function spawnShocker()
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	
	local successAsset, shockerModel = pcall(function()
		return game:GetObjects("rbxassetid://81809115282785")[1]
	end)

	if not successAsset or not shockerModel then
		warn("[SHOCKER] Không thể tải asset model!")
		return
	end

	local camera = Workspace.CurrentCamera

	local rootPart = shockerModel:FindFirstChild("HumanoidRootPart") or shockerModel:FindFirstChildWhichIsA("Part")
	shockerModel.PrimaryPart = rootPart
	shockerModel:SetPrimaryPartCFrame(camera.CFrame * CFrame.new(0, 0, -7))
	shockerModel.Parent = Workspace

	local oogaBoogaaPart = shockerModel:WaitForChild("OOGA BOOGAAAA")
	local horrorScream = oogaBoogaaPart:WaitForChild("HORROR SCREAM 15")

	local lookDuration = 2
	local lookStart = nil
	local hasTriggered = false
	local hasFallen = false

	local function fallToGround()
		if hasFallen then return end
		hasFallen = true

		oogaBoogaaPart.Anchored = false
		oogaBoogaaPart.CanCollide = false

		task.delay(1.2, function()
			if shockerModel and shockerModel.Parent then
				shockerModel:Destroy()
			end
		end)
	end

	local connection
	connection = RunService.RenderStepped:Connect(function()
		local currentCharacter = player.Character
		if not currentCharacter or not currentCharacter:FindFirstChild("HumanoidRootPart") then return end
		if hasTriggered then 
			if connection then connection:Disconnect() end
			return 
		end

		local directionToShocker = (oogaBoogaaPart.Position - camera.CFrame.Position).Unit
		local playerLookVector = camera.CFrame.LookVector
		local dot = directionToShocker:Dot(playerLookVector)

		if dot > 0.85 then
			-- Đang nhìn vào mặt Shocker
			if not lookStart then
				lookStart = tick()
			elseif tick() - lookStart >= lookDuration then
				hasTriggered = true
				if connection then connection:Disconnect() end

				horrorScream:Play()
				humanoid:TakeDamage(30)

				-- Tween lao tới player
				local targetPos = currentCharacter.HumanoidRootPart.Position + Vector3.new(0, 2, 0)
				local tweenInfo = TweenInfo.new(1.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
				local tween = TweenService:Create(oogaBoogaaPart, tweenInfo, {Position = targetPos})
				tween:Play()

				tween.Completed:Connect(function()
					fallToGround()
				end)

				-- Death message nếu máu bằng 0 hoặc bị hạ gục
				pcall(function()
					ReplicatedStorage.GameStats["Player_".. player.Name].Total.DeathCause.Value = "Shocker"
					firesignal(ReplicatedStorage.RemotesFolder.DeathHint.OnClientEvent, {
						"You died to who you call Shocker...",
						"Don't look at it or it stuns you!"
					}, "Blue")
				end)
			end
		else
			-- Không nhìn hoặc quay đi -> Rơi xuống đất
			if connection then connection:Disconnect() end
			fallToGround()
		end
	end)

	-- Dự phòng thời gian tự hủy
	task.delay(5, function()
		if not hasTriggered and not hasFallen then
			if connection then connection:Disconnect() end
			fallToGround()
		end
	end)

	-- Kích hoạt nhận thành tựu (Đã được khóa bằng biến toàn cục, không lo bị lặp 2 lần)
	GiveAchievement()
end

spawnShocker()
