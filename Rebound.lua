--========================================================--
--          REBOUND ENTITY SCRIPT (FIXED BLUE ROOM)       --
--========================================================--

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

-- Variables
local maxRebounds = 5
local reboundCount = 0
local isJumpscaring = false

-- ====== UTILS & AUDIO ======
local function GitAud(soundgit, filename)
    local url = soundgit
    local FileName = filename
    pcall(function()
        writefile(FileName .. ".mp3", game:HttpGet(url))
    end)
    return (getcustomasset or getsynasset)(FileName .. ".mp3")
end

local function CustomGitSound(soundlink, vol, filename)
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = GitAud(soundlink, filename)
        sound.Parent = workspace
        sound.Name = "reboundspawn"
        sound.Volume = vol or 5
        sound.PlaybackSpeed = 1
        sound:Play()
    end)
end

-- Camera Shake Setup
local cameraShaker = require(ReplicatedStorage:WaitForChild("CameraShaker"))
local camera = workspace.CurrentCamera
local camShake = cameraShaker.new(Enum.RenderPriority.Camera.Value, function(cf)
    camera.CFrame = camera.CFrame * cf
end)

-- Asset Loader
local function LoadCustomInstance(assetId, parent)
    local model = nil
    local retryCount = 0

    while not model and retryCount < 5 do
        retryCount = retryCount + 1
        local success, result = pcall(function()
            local loadedObjects = game:GetObjects(assetId)
            return loadedObjects and loadedObjects[1]
        end)

        if success and result then
            model = result
            model.Parent = parent or workspace

            task.spawn(function()
                for _, obj in ipairs(model:GetDescendants()) do
                    if obj:IsA("Script") or obj:IsA("LocalScript") then
                        obj:Destroy()
                    end
                end
            end)

            pcall(function()
                model:SetAttribute("LoadedByExecutor", true)
            end)
        else
            task.wait(0.5)
        end
    end

    return model
end

-- ====== MOVEMENT & JUMPSCARE LOGIC ======
local function MoveRebound()
    isJumpscaring = false
    
    local s = LoadCustomInstance("rbxassetid://12254145022", workspace)
    if not s then return end

    local entity = s:FindFirstChild("Rebound") or s.PrimaryPart or s:FindFirstChildWhichIsA("BasePart")
    
    if not entity then
        s:Destroy()
        return
    end

    -- Phát âm thanh hù dọa an toàn bằng GitAud
    pcall(function()
        local jumpscareSound = Instance.new("Sound")
        jumpscareSound.SoundId = GitAud("https://github.com/Kotyara19k-Doorsspawner/Random-files/raw/main/Y2meta.app%20-%20DOORS%20HARDCORE_REBOUND%20MOVING%20START%20(320%20kbps).mp3", "Moving2")
        jumpscareSound.Parent = entity
        jumpscareSound.Volume = 2
        jumpscareSound.Name = "am"
        jumpscareSound:Play()
    end)

    local val = 60
    local killed = false
    local gruh = workspace:WaitForChild("CurrentRooms")
    local latestRoomVal = ReplicatedStorage.GameData.LatestRoom.Value

    reboundCount = reboundCount + 1
    local directionType = (reboundCount % 2 == 1) and "ExitToEntrance" or "EntranceToExit"

    if directionType == "ExitToEntrance" then
        local targetRoom = gruh:FindFirstChild(tostring(latestRoomVal + 1)) or gruh:FindFirstChild(tostring(latestRoomVal))
        if targetRoom and targetRoom:FindFirstChild("RoomExit") then
            entity.CFrame = targetRoom.RoomExit.CFrame
        elseif targetRoom and targetRoom:FindFirstChild("RoomEntrance") then
            entity.CFrame = targetRoom.RoomEntrance.CFrame
        end
    else
        local startRoom = gruh:FindFirstChild("1")
        if startRoom and startRoom:FindFirstChild("RoomEntrance") then
            entity.CFrame = startRoom.RoomEntrance.CFrame
        end
    end

    task.wait(0.1)

    local function canSeeTarget(target, size)
        if killed or isJumpscaring then return false end
        local origin = entity.Position
        local hrp = target:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end

        local direction = (hrp.Position - origin).unit * size
        local ray = Ray.new(origin, direction)
        local hit = workspace:FindPartOnRay(ray, entity)
        if hit and hit:IsDescendantOf(target) then
            killed = true
            return true
        end
        return false
    end

    task.wait(1)

    local killCheckConnection
    killCheckConnection = RunService.Heartbeat:Connect(function()
        if not entity or not entity.Parent then
            if killCheckConnection then killCheckConnection:Disconnect() end
            return
        end

        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") and not char:GetAttribute("Hiding") then
            if (entity.Position - char.HumanoidRootPart.Position).Magnitude <= val then
                camShake:Start()
                camShake:ShakeOnce(17, 6, 0.1, 1)
            end

            if canSeeTarget(char, 50) and not isJumpscaring then
                isJumpscaring = true

                -- UI Jumpscare
                local JumpscareGui = Instance.new("ScreenGui")
                local Background = Instance.new("Frame")
                local Face = Instance.new("ImageLabel")

                JumpscareGui.Name = "JumpscareGui"
                JumpscareGui.IgnoreGuiInset = true
                JumpscareGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                JumpscareGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

                Background.Name = "Background"
                Background.BackgroundColor3 = Color3.fromRGB(3, 25, 99)
                Background.BorderSizePixel = 0
                Background.Size = UDim2.new(1, 0, 1, 0)
                Background.ZIndex = 999

                Face.Name = "Face"
                Face.AnchorPoint = Vector2.new(0.5, 0.5)
                Face.BackgroundTransparency = 1
                Face.Position = UDim2.new(0.5, 0, 0.5, 0)
                Face.ResampleMode = Enum.ResamplerMode.Pixelated
                Face.Size = UDim2.new(0, 150, 0, 150)
                Face.Image = "rbxassetid://10914800940"

                Background.Parent = JumpscareGui
                Face.Parent = Background

                local scare = Instance.new("Sound")
                scare.Parent = JumpscareGui
                scare.Name = "MyEarsBurn"
                scare.SoundId = "rbxassetid://74885373257467"
                scare.PlaybackSpeed = 1
                scare.Volume = 7
                scare.TimePosition = 0

                local shift = Instance.new("PitchShiftSoundEffect")
                shift.Octave = 0.8
                shift.Parent = scare

                local distort = Instance.new("DistortionSoundEffect")
                distort.Parent = scare
                distort.Level = 0.98

                task.spawn(function()
                    while JumpscareGui.Parent do
                        Background.BackgroundColor3 = Color3.fromRGB(3, 25, 99)
                        task.wait(math.random(25, 100) / 1000)
                        Background.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        task.wait(math.random(25, 100) / 1000)
                    end
                end)

                TweenService:Create(Face, TweenInfo.new(0.6), {Size = UDim2.new(0, 1850, 0, 1050), ImageTransparency = 0}):Play()
                scare:Play()

                task.spawn(function()
                    task.wait(0.3)
                    local hum = char:FindFirstChildWhichIsA("Humanoid")
                    if hum then hum.Health = 0 end

                    pcall(function()
                        local gameStats = ReplicatedStorage:FindFirstChild("GameStats")
                        if gameStats then
                            local playerStat = gameStats:FindFirstChild("Player_" .. LocalPlayer.Name)
                            if playerStat and playerStat:FindFirstChild("Total") and playerStat.Total:FindFirstChild("DeathCause") then
                                playerStat.Total.DeathCause.Value = "Rebound"
                            end
                        end
                        
                        local remotesFolder = ReplicatedStorage:FindFirstChild("RemotesFolder") or ReplicatedStorage:FindFirstChild("Bricks")
                        if remotesFolder and remotesFolder:FindFirstChild("DeathHint") then
                            firesignal(remotesFolder.DeathHint.OnClientEvent, {
                                "You died to who you call Rebound...",
                                "He makes his presence known and keeps coming back...",
                                "Hide when this happens!"
                            }, "Blue")
                        end
                    end)
                end)

                task.wait(0.6)
                JumpscareGui:Destroy()
            end
        end
    end)

    if directionType == "ExitToEntrance" then
        for i = latestRoomVal, 1, -1 do
            if gruh:FindFirstChild(tostring(i)) then
                local room = gruh[tostring(i)]
                if room:FindFirstChild("RoomEntrance") then
                    local a = room.RoomEntrance
                    local tween = TweenService:Create(entity, TweenInfo.new(1.8, Enum.EasingStyle.Sine), {CFrame = a.CFrame})
                    tween:Play()
                    tween.Completed:Wait()
                end
            end
        end
    else
        for i = 1, latestRoomVal + 1 do
            if gruh:FindFirstChild(tostring(i)) then
                local room = gruh[tostring(i)]
                if room:FindFirstChild("RoomExit") then
                    local a = room.RoomExit
                    local tween = TweenService:Create(entity, TweenInfo.new(1.8, Enum.EasingStyle.Sine), {CFrame = a.CFrame})
                    tween:Play()
                    tween.Completed:Wait()
                end
            end
        end
    end

    if killCheckConnection then killCheckConnection:Disconnect() end

    if entity and entity:IsA("BasePart") then
        entity.Anchored = false
        entity.CanCollide = false
    end
    Debris:AddItem(s, 2)
end

-- ====== RUN REBOUND SEQUENCE ======
local function RunReboundSequence()
    -- 1. Tạo hiệu ứng làm xanh phòng ngay lập tức từ đầu
    local Warn = Instance.new("ColorCorrectionEffect")
    Warn.Name = "ReboundWarn"
    Warn.TintColor = Color3.fromRGB(65, 138, 255)
    Warn.Saturation = -0.7
    Warn.Contrast = 0.2
    Warn.Parent = Lighting

    TweenService:Create(Warn, TweenInfo.new(15), {
        TintColor = Color3.fromRGB(255, 255, 255),
        Saturation = 0,
        Contrast = 0
    }):Play()

    -- 2. Âm thanh cảnh báo & Rung màn hình
    CustomGitSound("https://github.com/Kotyara19k-Doorsspawner/Random-files/raw/main/Y2meta.app%20-%20DOORS%20HARDCORE_REBOUND%20MOVING%20START%20(320%20kbps).mp3", 5, "reboundspawn")
    
    camShake:Start()
    camShake:ShakeOnce(10, 3, 0.1, 6, 2, 0.5)
    
    -- 3. Thời gian chờ người chơi trú ẩn
    task.wait(3)

    reboundCount = 0
    local currentMax = maxRebounds
    
    task.wait(2)

    -- 4. Bắt đầu di chuyển lượt đầu tiên
    pcall(MoveRebound)

    while currentMax > 0 do
        ReplicatedStorage.GameData.LatestRoom.Changed:Wait()
        task.wait(2)
        pcall(MoveRebound)
        currentMax = currentMax - 1
    end

    task.wait(2)

    -- 5. Tween chuyển hiệu ứng màu về bình thường mượt mà
    local fadeOutInfo = TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local fadeTween = TweenService:Create(Warn, fadeOutInfo, {
        TintColor = Color3.fromRGB(255, 255, 255),
        Saturation = 0,
        Contrast = 0,
        Brightness = 0
    })
    
    fadeTween:Play()
    
    fadeTween.Completed:Connect(function()
        if Warn and Warn.Parent then
            Warn:Destroy()
        end
    end)
    
    Debris:AddItem(Warn, 7)
end

-- Kích hoạt thực thể Rebound
RunReboundSequence()
