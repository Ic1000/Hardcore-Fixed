--========================================================--
--      OGHUNGER NEW SPAWNER + ACHIEVEMENT SYSTEM         --
--========================================================--

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")

-- TẠO BIẾN TOÀN CỤC KHÓA THÀNH TỰU DÙ SCRIPT CÓ XẢY RA LỖI HOẶC CHẠY LẠI
if getgenv().RipperAchievementEarned == nil then
	getgenv().RipperAchievementEarned = false
end

-- Load Spawner
local success, Spawner = pcall(function()
	return loadstring(game:HttpGet(
		"https://raw.githubusercontent.com/eoyoustme/Mayhem-Remake/refs/heads/main/OgHungerNewSpawner"
	))()
end)

if not success or not Spawner then
	warn("[SPAWNER] Cannot load OgHungerNewSpawner")
	return
end

print("[SPAWNER] Successfully loaded!")

-- Khởi tạo Entity với FULL 100% tất cả các thông số cấu hình gốc
local ok, entity = pcall(function()
	return Spawner:Create({
		Entity = {
			Name = "Ripper Entity",
			Asset = "rbxassetid://12272798431",
			HeightOffset = -3
		},

		Lights = {
			Flicker = {
				Enabled = true,
				Duration = 1
			},
			Shatter = true,
			Repair = false
		},

		Earthquake = {
			Enabled = true
		},

		Spawned = {
			ChangeColorWhenSpawn = true,
			Rainbow = false,
			Color = Color3.fromRGB(255, 0, 0)
		},

		CameraShake = {
			Enabled = true,
			Range = 100,
			Values = {1.5, 40, 0.1, 1}
		},

		Movement = {
			Speed = 267,
			SpeedFast = 1700,
			MoveFastNotEnter = false,
			Delay = 5.2,
			Reversed = false,
			EndWhenEnterLatestRoom = false,
			EndDelay = 1.9,

			ReboundMoving = false,
			TweenSecond = 1.5,

			ReboundMoveStyle = false,
			ReboundStyleTimes = 3,

			ReboundStyleSound = "rbxassetid://130994177179386",
			ReboundStyleVolume = 5
		},

		Jumpscare = {
			Enabled = false,
			Image1 = "rbxassetid://11253398403",
			Image2 = "rbxassetid://12293509957",
			Sound1 = "rbxassetid://0",
			Sound2 = "rbxassetid://109582246349306",
			Tease = {
				[1] = true,
				Min = 1,
				Max = 1
			},
			Flashing = {
				[1] = true,
				[2] = Color3.fromRGB(255, 255, 255)
			},
			Shake = true
		},

		Rebounding = {
			Enabled = false,
			Type = "Ambush",
			Min = 1,
			Max = 1,
			Delay = 0
		},

		Damage = {
			Enabled = true,
			KillOnMove = false,
			Range = 40,
			Amount = 125,
			IgnoreHiding = false,

			JumpscareRipper = {
				Enabled = true,
				TargetPartName = "Ripe",
				AttachmentName = "ripe",
				ParticleName = "ParticleEmitter",
				ParticleTexture = "rbxassetid://12737595583",
				SoundUrl = "https://github.com/eoyoustme/back/raw/main/Kill_with_static.mp3",
				SlamSoundId = "rbxassetid://126631007956569",
				EndSoundId = "rbxassetid://4988621968",
				Images = {
					"rbxassetid://8482795900",
					"rbxassetid://236542974",
					"rbxassetid://184251462",
					"rbxassetid://236777652"
				},
				FlashDuration = 1.6
			}
		},

		Crucifixion = {
			Enabled = true,
			Range = 40,
			Resist = false,
			Break = true
		},

		Death = {
			Type = "Guiding",
			Cause = "Ripper"
		}
	})
end)

if not ok or not entity then
	warn("[SPAWNER] Entity creation failed!")
	return
end

-- ========================================================
-- HỆ THỐNG THÀNH TỰU (ACHIEVEMENT)
-- ========================================================

local function GiveAchievement()
	if getgenv().RipperAchievementEarned then
		return
	end

	getgenv().RipperAchievementEarned = true

	task.spawn(function()
		local ok, achievementGiver = pcall(function()
			return loadstring(game:HttpGet(
				"https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Custom%20Achievements/Source.lua"
			))()
		end)

		if not ok or not achievementGiver then
			warn("[RIPPER] Achievement loader failed")
			return
		end

		pcall(function()
			achievementGiver({
				Title = "Hide or be Torn Apart",
				Desc = "Don't Leave Stand still..",
				Reason = "Encounter and survive Ripper.",
				Image = "rbxassetid://12231244908"
			})
		end)

		print("[RIPPER] Achievement granted successfully!")
	end)
end

-- ========================================================
-- CÁC CALLBACKS MẶC ĐỊNH & KIỂM TRA SỐNG SÓT NHẬN THÀNH TỰU
-- ========================================================

entity:SetCallback("OnSpawned", function()
	print("[SPAWNER] Entity has spawned.")
end)

entity:SetCallback("OnStartMoving", function()
	print("[SPAWNER] Entity has started moving.")
end)

entity:SetCallback("OnEnterRoom", function(room, firstTime)
	print("[SPAWNER] Entered room:", room.Name)
end)

entity:SetCallback("OnDespawning", function()
	print("[SPAWNER] Entity is despawning.")
end)

entity:SetCallback("OnDespawned", function()
	print("[SPAWNER] Entity has despawned completely.")
	
	-- Nếu người chơi còn sống sau khi Ripper biến mất -> Nhận thành tựu
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum and hum.Health > 0 then
		GiveAchievement()
	end
end)

-- Chạy Spawner
task.spawn(function()
	task.wait(0.1)
	entity:Run(true)
end)
