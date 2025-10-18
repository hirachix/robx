-------------------------------------------------------------
-- LOAD LIBRARY UI
-------------------------------------------------------------
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/RullzsyHUB/roblox-scripts/refs/heads/main/UI%20Liblary/Rayfield.lua'))()

-------------------------------------------------------------
-- WINDOW PROCESS
-------------------------------------------------------------
local Window = Rayfield:CreateWindow({
   Name = "HIRAKO | NIGHTMARE EXPEDITION",
   Icon = "braces",
   LoadingTitle = "Created By Hirakoxs",
   LoadingSubtitle = "Telegram: @Hirakoxs",
   ShowText = "Hirako",
   Theme = "DarkBlue",
})

-------------------------------------------------------------
-- TAB MENU
-------------------------------------------------------------
--local AccountTab = Window:CreateTab("Account", "user")
local BypassTab = Window:CreateTab("Bypass", "shield")
local AutoWalkTab = Window:CreateTab("Auto Walk", "bot")
local VisualTab = Window:CreateTab("Visual", "layers")
local RunAnimationTab = Window:CreateTab("Run Animation", "person-standing")
local UpdateTab = Window:CreateTab("Update Script", "file")
local CreditsTab = Window:CreateTab("Credits", "scroll-text")

-------------------------------------------------------------
-- SERVICES
-------------------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")

-------------------------------------------------------------
-- IMPORT
-------------------------------------------------------------
local LocalPlayer = Players.LocalPlayer
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local setclipboard = setclipboard or toclipboard

-------------------------------------------------------------
-- FILE SYSTEM CONFIGURATION
-------------------------------------------------------------
-- Check if authenticated
--if not getgenv().AuthComplete then
--    warn("[MAIN] Not authenticated! Please run auth script first.")
--    return
--end



-- =============================================================
-- BYPAS AFK
-- =============================================================
getgenv().AntiIdleActive = false
local AntiIdleConnection
local MovementLoop

-- Fungsi untuk mulai bypass AFK
local function StartAntiIdle()
    -- Disconnect lama biar tidak dobel
    if AntiIdleConnection then
        AntiIdleConnection:Disconnect()
        AntiIdleConnection = nil
    end
    if MovementLoop then
        MovementLoop:Disconnect()
        MovementLoop = nil
    end
    AntiIdleConnection = LocalPlayer.Idled:Connect(function()
        if getgenv().AntiIdleActive then
            VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        Enda 
    end)
    MovementLoop = RunService.Heartbeat:Connect(function()
        if getgenv().AntiIdleActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local root = LocalPlayer.Character.HumanoidRootPart
            if tick() % 60 < 0.05 then
                root.CFrame = root.CFrame * CFrame.new(0, 0, 0.1)
                task.wait(0.1)
                root.CFrame = root.CFrame * CFrame.new(0, 0, -0.1)
            end
        end
    end)
end

-- Respawn Validation
local function SetupCharacterListener()
    LocalPlayer.CharacterAdded:Connect(function(newChar)
        newChar:WaitForChild("HumanoidRootPart", 10)
        if getgenv().AntiIdleActive then
            StartAntiIdle()
        end
    end)
end

StartAntiIdle()
SetupCharacterListener()

-- Section
local Section = BypassTab:CreateSection("List All Bypass")

BypassTab:CreateToggle({
    Name = "Bypass AFK",
    CurrentValue = false,
    Flag = "AntiIdleToggle",
    Callback = function(Value)
        getgenv().AntiIdleActive = Value
        if Value then
            StartAntiIdle()
            Rayfield:Notify({
                Image = "shield",
                Title = "Bypass AFK",
                Content = "Bypass AFK diaktifkan",
                Duration = 5
            })
        else
            if AntiIdleConnection then
                AntiIdleConnection:Disconnect()
                AntiIdleConnection = nil
            end
            if MovementLoop then
                MovementLoop:Disconnect()
                MovementLoop = nil
            end
            Rayfield:Notify({
                Image = "shield",
                Title = "Bypass AFK",
                Content = "Bypass AFK dimatikan",
                Duration = 5
            })
        end
    end,
})
-- =============================================================
-- BYPAS AFK - END
-- =============================================================



-------------------------------------------------------------
-- AUTO WALK
-------------------------------------------------------------
-----| AUTO WALK VARIABLES |-----
-- Setup folder save file json
local mainFolder = "RullzsyHUB"
local jsonFolder = mainFolder .. "/js_mount_nightmare_expedition"
if not isfolder(mainFolder) then
    makefolder(mainFolder)
end
if not isfolder(jsonFolder) then
    makefolder(jsonFolder)
end

-- Server URL and JSON checkpoint file list
local baseURL = "https://raw.githubusercontent.com/RullzsyHUB/roblox-scripts-json/refs/heads/main/json_mount_nightmare_expedition/"
local jsonFiles = {
    "spawnpoint.json",
    "checkpoint_1.json",
	"checkpoint_2.json",
	"checkpoint_3.json",
	"checkpoint_4.json",
	"checkpoint_5.json",
    "checkpoint_6.json",
    "checkpoint_7.json",
    "checkpoint_8.json",
    "checkpoint_9.json",
    "checkpoint_10.json",
    "checkpoint_11.json",
    "checkpoint_12.json",
    "checkpoint_13.json",
    "checkpoint_14.json",
    "checkpoint_15.json",
    "checkpoint_16.json",
    "checkpoint_17.json",
    "checkpoint_18.json",
    "checkpoint_19.json",
    "checkpoint_20.json",
    "checkpoint_21.json",
    "checkpoint_22.json",
    "checkpoint_23.json",
    "checkpoint_24.json",
    "checkpoint_25.json",
    "checkpoint_26.json",
    "checkpoint_27.json",
    "checkpoint_28.json",
    "checkpoint_29.json",
    "checkpoint_30.json",
    "checkpoint_31.json",
    "checkpoint_32.json",
    "checkpoint_33.json",
}

-- Variables to control auto walk status
local isPlaying = false
local playbackConnection = nil
local autoLoopEnabled = false
local currentCheckpoint = 0

--Variables for pause and resume features
local isPaused = false
local manualLoopEnabled = false
local pausedTime = 0
local pauseStartTime = 0

-- FPS Independent Playback Variables
local lastPlaybackTime = 0
local accumulatedTime = 0

-- Looping Variables
local loopingEnabled = false
local isManualMode = false
local manualStartCheckpoint = 0

-- NEW: Avatar Size Compensation Variables
local recordedHipHeight = nil
local currentHipHeight = nil
local hipHeightOffset = 0

-- NEW: Speed Control Variables
local playbackSpeed = 1.0

-- NEW: Footstep Sound Variables
local lastFootstepTime = 0
local footstepInterval = 0.35
local leftFootstep = true
-------------------------------------------------------------

-----| AUTO WALK FUNCTIONS |-----
-- Function to convert Vector3 to table
local function vecToTable(v3)
    return {x = v3.X, y = v3.Y, z = v3.Z}
end

-- Function to convert a table to Vector3
local function tableToVec(t)
    return Vector3.new(t.x, t.y, t.z)
end

-- Linear interpolation function for numbers
local function lerp(a, b, t)
    return a + (b - a) * t
end

-- Linear interpolation function for Vector3
local function lerpVector(a, b, t)
    return Vector3.new(lerp(a.X, b.X, t), lerp(a.Y, b.Y, t), lerp(a.Z, b.Z, t))
end

-- Linear interpolation function for rotation angle
local function lerpAngle(a, b, t)
    local diff = (b - a)
    while diff > math.pi do diff = diff - 2*math.pi end
    while diff < -math.pi do diff = diff + 2*math.pi end
    return a + diff * t
end

-- NEW: Function to calculate HipHeight offset
local function calculateHipHeightOffset()
    if not humanoid then return 0 end
    
    currentHipHeight = humanoid.HipHeight
    
    -- If no recorded hip height, assume standard avatar (2.0)
    if not recordedHipHeight then
        recordedHipHeight = 2.0
    end
    
    -- Calculate offset based on hip height difference
    hipHeightOffset = recordedHipHeight - currentHipHeight
    
    return hipHeightOffset
end

-- NEW: Function to adjust position based on avatar size
local function adjustPositionForAvatarSize(position)
    if hipHeightOffset == 0 then return position end
    
    -- Apply vertical offset to compensate for hip height difference
    return Vector3.new(
        position.X,
        position.Y - hipHeightOffset,
        position.Z
    )
end

-- NEW: Function to play footstep sounds
local function playFootstepSound()
    if not humanoid or not character then return end
    
    pcall(function()
        -- Get the HumanoidRootPart for raycasting
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        -- Raycast downward to detect floor material
        local rayOrigin = hrp.Position
        local rayDirection = Vector3.new(0, -5, 0)
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {character}
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        
        local rayResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
        
        if rayResult and rayResult.Instance then
            local material = rayResult.Material
            
            -- Create a sound instance for footstep
            local sound = Instance.new("Sound")
            sound.Volume = 0.8 -- Increased volume for louder footsteps
            sound.RollOffMaxDistance = 100
            sound.RollOffMinDistance = 10
            
            -- Assign sound based on material
            -- Using Roblox's built-in footstep sounds
            local soundId = "rbxasset://sounds/action_footsteps_plastic.mp3"
            
            -- Different sounds for different materials
            if material == Enum.Material.Grass then
                soundId = "rbxasset://sounds/action_footsteps_plastic.mp3"
            elseif material == Enum.Material.Wood or material == Enum.Material.WoodPlanks then
                soundId = "rbxasset://sounds/action_footsteps_plastic.mp3"
            elseif material == Enum.Material.Metal or material == Enum.Material.DiamondPlate or material == Enum.Material.CorrodedMetal then
                soundId = "rbxasset://sounds/action_footsteps_plastic.mp3"
            elseif material == Enum.Material.Water then
                soundId = "rbxasset://sounds/action_footsteps_plastic.mp3"
            elseif material == Enum.Material.Snow or material == Enum.Material.Glacier or material == Enum.Material.Ice then
                soundId = "rbxasset://sounds/action_footsteps_plastic.mp3"
            elseif material == Enum.Material.Sand then
                soundId = "rbxasset://sounds/action_footsteps_plastic.mp3"
            else
                soundId = "rbxasset://sounds/action_footsteps_plastic.mp3"
            end
            
            sound.SoundId = soundId
            sound.Parent = hrp
            sound:Play()
            
            -- Cleanup sound after it finishes
            game:GetService("Debris"):AddItem(sound, 1)
        end
    end)
end

-- NEW: Function to simulate natural movement for footsteps
local function simulateNaturalMovement(moveDirection, velocity)
    if not humanoid or not character then return end
    
    -- Calculate horizontal movement speed (ignore Y axis)
    local horizontalVelocity = Vector3.new(velocity.X, 0, velocity.Z)
    local speed = horizontalVelocity.Magnitude
    
    -- Check if character is on ground
    local onGround = false
    pcall(function()
        local state = humanoid:GetState()
        onGround = (state == Enum.HumanoidStateType.Running or 
                    state == Enum.HumanoidStateType.RunningNoPhysics or 
                    state == Enum.HumanoidStateType.Landed)
    end)
    
    -- Only play footsteps if moving and on ground
    if speed > 0.5 and onGround then
        local currentTime = tick()
        
        -- Adjust footstep interval based on speed and playback speed
        local speedMultiplier = math.clamp(speed / 16, 0.3, 2)
        local adjustedInterval = footstepInterval / (speedMultiplier * playbackSpeed)
        
        if currentTime - lastFootstepTime >= adjustedInterval then
            playFootstepSound()
            lastFootstepTime = currentTime
            leftFootstep = not leftFootstep -- Alternate feet
        end
    end
end

-- Function to ensure the JSON file is available (download if it does not exist)
local function EnsureJsonFile(fileName)
    local savePath = jsonFolder .. "/" .. fileName
    if isfile(savePath) then return true, savePath end
    local ok, res = pcall(function() return game:HttpGet(baseURL..fileName) end)
    if ok and res and #res > 0 then
        writefile(savePath, res)
        return true, savePath
    end
    return false, nil
end

-- Function to read and decode JSON checkpoint files
local function loadCheckpoint(fileName)
    local filePath = jsonFolder .. "/" .. fileName
    
    if not isfile(filePath) then
        warn("File not found:", filePath)
        return nil
    end
    
    local success, result = pcall(function()
        local jsonData = readfile(filePath)
        if not jsonData or jsonData == "" then
            error("Empty file")
        end
        return HttpService:JSONDecode(jsonData)
    end)
    
    if success and result then
        -- NEW: Try to extract recorded hip height from first frame
        if result[1] and result[1].hipHeight then
            recordedHipHeight = result[1].hipHeight
        end
        return result
    else
        warn("❌ Load error for", fileName, ":", result)
        return nil
    end
end

-- Binary search for better performance
local function findSurroundingFrames(data, t)
    if #data == 0 then return nil, nil, 0 end
    if t <= data[1].time then return 1, 1, 0 end
    if t >= data[#data].time then return #data, #data, 0 end
    
    -- Binary search for efficiency
    local left, right = 1, #data
    while left < right - 1 do
        local mid = math.floor((left + right) / 2)
        if data[mid].time <= t then
            left = mid
        else
            right = mid
        end
    end
    
    local i0, i1 = left, right
    local span = data[i1].time - data[i0].time
    local alpha = span > 0 and math.clamp((t - data[i0].time) / span, 0, 1) or 0
    
    return i0, i1, alpha
end

-- Function to stop auto walk playback
local function stopPlayback()
    isPlaying = false
    isPaused = false
    pausedTime = 0
    accumulatedTime = 0
    lastPlaybackTime = 0
    lastFootstepTime = 0 -- Reset footstep timer
    recordedHipHeight = nil
    hipHeightOffset = 0
    if playbackConnection then
        playbackConnection:Disconnect()
        playbackConnection = nil
    end
end

-- IMPROVED: FPS-independent playback with avatar size compensation
local function startPlayback(data, onComplete)
    if not data or #data == 0 then
        warn("No data to play!")
        if onComplete then onComplete() end
        return
    end
    
    if isPlaying then stopPlayback() end
    
    isPlaying = true
    isPaused = false
    pausedTime = 0
    accumulatedTime = 0
    local playbackStartTime = tick()
    lastPlaybackTime = playbackStartTime
    local lastJumping = false
    
    -- NEW: Calculate hip height offset at start
    calculateHipHeightOffset()
    
    if playbackConnection then
        playbackConnection:Disconnect()
        playbackConnection = nil
    end

    -- Teleport directly to the starting point JSON with size adjustment
    local first = data[1]
    if character and character:FindFirstChild("HumanoidRootPart") then
        local hrp = character.HumanoidRootPart
        local firstPos = tableToVec(first.position)
        -- NEW: Apply avatar size adjustment
        firstPos = adjustPositionForAvatarSize(firstPos)
        local firstYaw = first.rotation or 0
        local startCFrame = CFrame.new(firstPos) * CFrame.Angles(0, firstYaw, 0)
        hrp.CFrame = startCFrame
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

        if humanoid then
            humanoid:Move(tableToVec(first.moveDirection or {x=0,y=0,z=0}), false)
        end
    end

    -- FPS-INDEPENDENT PLAYBACK LOOP
    playbackConnection = RunService.Heartbeat:Connect(function(deltaTime)
        if not isPlaying then return end
        
        -- Handle pause
        if isPaused then
            if pauseStartTime == 0 then
                pauseStartTime = tick()
            end
            lastPlaybackTime = tick()
            return
        else
            if pauseStartTime > 0 then
                pausedTime = pausedTime + (tick() - pauseStartTime)
                pauseStartTime = 0
                lastPlaybackTime = tick()
            end
        end
        
        if not character or not character:FindFirstChild("HumanoidRootPart") then return end
        if not humanoid or humanoid.Parent ~= character then
            humanoid = character:FindFirstChild("Humanoid")
            -- Recalculate offset if humanoid changed
            calculateHipHeightOffset()
        end
        
        -- FPS-independent time tracking using deltaTime
        local currentTime = tick()
        local actualDelta = currentTime - lastPlaybackTime
        lastPlaybackTime = currentTime
        
        -- Clamp delta to prevent huge jumps on lag spikes
        actualDelta = math.min(actualDelta, 0.1)
        
        -- NEW: Apply playback speed multiplier
        accumulatedTime = accumulatedTime + (actualDelta * playbackSpeed)
        
        local totalDuration = data[#data].time
        
        -- Check if playback is complete
        if accumulatedTime > totalDuration then
            local final = data[#data]
            if character and character:FindFirstChild("HumanoidRootPart") then
                local hrp = character.HumanoidRootPart
                local finalPos = tableToVec(final.position)
                -- NEW: Apply avatar size adjustment
                finalPos = adjustPositionForAvatarSize(finalPos)
                local finalYaw = final.rotation or 0
                local targetCFrame = CFrame.new(finalPos) * CFrame.Angles(0, finalYaw, 0)
                hrp.CFrame = targetCFrame
                if humanoid then
                    humanoid:Move(tableToVec(final.moveDirection or {x=0,y=0,z=0}), false)
                end
            end
            stopPlayback()
            if onComplete then onComplete() end
            return
        end
        
        -- Interpolation with binary search
        local i0, i1, alpha = findSurroundingFrames(data, accumulatedTime)
        local f0, f1 = data[i0], data[i1]
        if not f0 or not f1 then return end
        
        local pos0 = tableToVec(f0.position)
        local pos1 = tableToVec(f1.position)
        local vel0 = tableToVec(f0.velocity or {x=0,y=0,z=0})
        local vel1 = tableToVec(f1.velocity or {x=0,y=0,z=0})
        local move0 = tableToVec(f0.moveDirection or {x=0,y=0,z=0})
        local move1 = tableToVec(f1.moveDirection or {x=0,y=0,z=0})
        local yaw0 = f0.rotation or 0
        local yaw1 = f1.rotation or 0
        
        local interpPos = lerpVector(pos0, pos1, alpha)
        -- NEW: Apply avatar size adjustment to interpolated position
        interpPos = adjustPositionForAvatarSize(interpPos)
        
        local interpVel = lerpVector(vel0, vel1, alpha)
        local interpMove = lerpVector(move0, move1, alpha)
        local interpYaw = lerpAngle(yaw0, yaw1, alpha)
        
        local hrp = character.HumanoidRootPart
        local targetCFrame = CFrame.new(interpPos) * CFrame.Angles(0, interpYaw, 0)
        
        -- Dynamic lerp factor based on deltaTime
        local lerpFactor = math.clamp(1 - math.exp(-10 * actualDelta), 0, 1)
        hrp.CFrame = hrp.CFrame:Lerp(targetCFrame, lerpFactor)
        
        -- Apply velocity more directly
        pcall(function()
            hrp.AssemblyLinearVelocity = interpVel
        end)
        
        if humanoid then
            humanoid:Move(interpMove, false)
        end
        
        -- NEW: Simulate footstep sounds
        simulateNaturalMovement(interpMove, interpVel)
        
        -- Handle jumping
        local jumpingNow = f0.jumping or false
        if f1.jumping then jumpingNow = true end
        if jumpingNow and not lastJumping then
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
        lastJumping = jumpingNow
    end)
end

-- Function to run the auto walk sequence from start to finish
local function startAutoWalkSequence()
    currentCheckpoint = 0

    local function playNext()
        if not autoLoopEnabled then return end
        
        currentCheckpoint = currentCheckpoint + 1
        if currentCheckpoint > #jsonFiles then
            -- All checkpoints completed
            if loopingEnabled then
                -- Loop kembali dari awal
                Rayfield:Notify({
                    Title = "Auto Walk",
                    Content = "Semua checkpoint selesai! Looping dari awal...",
                    Duration = 3,
                    Image = "repeat"
                })
                task.wait(1)
                startAutoWalkSequence()
            else
                autoLoopEnabled = false
                Rayfield:Notify({
                    Title = "Auto Walk",
                    Content = "Auto walk selesai! Semua checkpoint sudah dilewati.",
                    Duration = 5,
                    Image = "check-check"
                })
            end
            return
        end

        local checkpointFile = jsonFiles[currentCheckpoint]

        local ok, path = EnsureJsonFile(checkpointFile)
        if not ok then
            Rayfield:Notify({
                Title = "Error",
                Content = "Failed to download: ",
                Duration = 5,
                Image = "ban"
            })
            autoLoopEnabled = false
            return
        end

        local data = loadCheckpoint(checkpointFile)
        if data and #data > 0 then
            Rayfield:Notify({
                Title = "Auto Walk (Automatic)",
                Content = "Auto walk berhasil di jalankan",
                Duration = 2,
                Image = "bot"
            })
            task.wait(0.5)
            startPlayback(data, playNext)
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Error loading: " .. checkpointFile,
                Duration = 5,
                Image = "ban"
            })
            autoLoopEnabled = false
        end
    end

    playNext()
end

-- Function to run manual auto walk with looping (fixed: walk to start for the first checkpoint)
local function startManualAutoWalkSequence(startCheckpoint)
    currentCheckpoint = startCheckpoint - 1
    isManualMode = true
    autoLoopEnabled = true

    -- helper: try walk to first frame's start position (returns true if reached)
    local function walkToStartIfNeeded(data)
        if not character or not character:FindFirstChild("HumanoidRootPart") then
            Rayfield:Notify({
                Title = "Auto Walk (Manual)",
                Content = "Character belum siap (HRP tidak ditemukan).",
                Duration = 3,
                Image = "ban"
            })
            return false
        end

        local hrp = character.HumanoidRootPart
        if not data or not data[1] or not data[1].position then
            return true -- nothing to walk to
        end

        local startPos = tableToVec(data[1].position)
        local distance = (hrp.Position - startPos).Magnitude

        -- jarak maksimum
        if distance > 100 then
            Rayfield:Notify({
                Title = "Auto Walk (Manual)",
                Content = string.format("Terlalu jauh (%.0f studs). Maks 100 studs untuk memulai.", distance),
                Duration = 4,
                Image = "alert-triangle"
            })
            autoLoopEnabled = false
            isManualMode = false
            return false
        end

        Rayfield:Notify({
            Title = "Auto Walk (Manual)",
            Content = string.format("Menuju titik awal... (%.0f studs)", distance),
            Duration = 3,
            Image = "walk"
        })

        local humanoidLocal = character:FindFirstChildOfClass("Humanoid")
        if not humanoidLocal then
            Rayfield:Notify({
                Title = "Auto Walk (Manual)",
                Content = "Humanoid tidak ditemukan, gagal berjalan.",
                Duration = 3,
                Image = "ban"
            })
            autoLoopEnabled = false
            isManualMode = false
            return false
        end

        -- Mulai MoveTo
        local reached = false
        local reachedConnection
        reachedConnection = humanoidLocal.MoveToFinished:Connect(function(r)
            reached = r
            if reachedConnection then
                reachedConnection:Disconnect()
                reachedConnection = nil
            end
        end)

        humanoidLocal:MoveTo(startPos)

        -- Timeout & monitor (boleh dibatalkan jika autoLoopEnabled diubah)
        local timeout = 20
        local waited = 0
        while not reached and waited < timeout and autoLoopEnabled do
            task.wait(0.25)
            waited = waited + 0.25
        end

        if reached then
            Rayfield:Notify({
                Title = "Auto Walk (Manual)",
                Content = "Sudah sampai titik awal. Memulai playback...",
                Duration = 2,
                Image = "play"
            })
            return true
        else
            -- jika gagal (timeout atau dibatalkan)
            if reachedConnection then
                reachedConnection:Disconnect()
                reachedConnection = nil
            end
            Rayfield:Notify({
                Title = "Auto Walk (Manual)",
                Content = "Gagal mencapai titik awal (timeout atau dibatalkan).",
                Duration = 3,
                Image = "ban"
            })
            autoLoopEnabled = false
            isManualMode = false
            return false
        end
    end

    local function playNext()
        if not autoLoopEnabled then return end

        currentCheckpoint = currentCheckpoint + 1
        
        -- [[ PERUBAHAN DI SINI ]]
        -- Jika sudah melewati checkpoint terakhir, hentikan proses.
        -- Ini mencegahnya looping kembali ke spawnpoint saat mode manual.
        if currentCheckpoint > #jsonFiles then
            autoLoopEnabled = false
            isManualMode = false
            Rayfield:Notify({
                Title = "Auto Walk Selesai",
                Content = "Telah mencapai checkpoint terakhir.",
                Duration = 5,
                Image = "check-check"
            })
            return -- Hentikan fungsi di sini
        end
        -- [[ AKHIR DARI PERUBAHAN ]]

        local checkpointFile = jsonFiles[currentCheckpoint]

        local ok, path = EnsureJsonFile(checkpointFile)
        if not ok then
            Rayfield:Notify({
                Title = "Error",
                Content = "Failed to download checkpoint",
                Duration = 5,
                Image = "ban"
            })
            autoLoopEnabled = false
            isManualMode = false
            return
        end

        local data = loadCheckpoint(checkpointFile)
        if data and #data > 0 then
            task.wait(0.5)

            -- Jika ini checkpoint pertama yang diminta user (ketika mulai manual+loop),
            -- maka jalan dulu ke titik awal sebelum startPlayback agar tidak teleport.
            if isManualMode and currentCheckpoint == startCheckpoint then
                local okWalk = walkToStartIfNeeded(data)
                if not okWalk then
                    -- walk gagal / dibatalkan -> hentikan sequence
                    return
                end
            end

            -- Mulai playback (startPlayback masih melakukan penyesuaian posisi internal,
            -- tetapi sekarang character sudah berada di posisi awal sehingga teleport tidak terlihat)
            startPlayback(data, playNext)
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Error loading: " .. checkpointFile,
                Duration = 5,
                Image = "ban"
            })
            autoLoopEnabled = false
            isManualMode = false
        end
    end

    playNext()
end


-- Function to rotate a single checkpoint (manual)
local function playSingleCheckpointFile(fileName, checkpointIndex)
    if loopingEnabled then
        stopPlayback()
        startManualAutoWalkSequence(checkpointIndex)
        return
    end

    autoLoopEnabled = false
    isManualMode = false
    stopPlayback()

    local ok, path = EnsureJsonFile(fileName)
    if not ok then
        Rayfield:Notify({
            Title = "Error",
            Content = "Failed to ensure JSON checkpoint",
            Duration = 4,
            Image = "ban"
        })
        return
    end

    local data = loadCheckpoint(fileName)
    if not data or #data == 0 then
        Rayfield:Notify({
            Title = "Error",
            Content = "File invalid / kosong",
            Duration = 4,
            Image = "ban"
        })
        return
    end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        Rayfield:Notify({
            Title = "Error",
            Content = "HumanoidRootPart tidak ditemukan!",
            Duration = 4,
            Image = "ban"
        })
        return
    end

    -- Titik awal checkpoint dari JSON
    local startPos = tableToVec(data[1].position)
    local distance = (hrp.Position - startPos).Magnitude

    -- Jika jarak > 100 studs, batalkan
    if distance > 100 then
        Rayfield:Notify({
            Title = "Auto Walk (Manual)",
            Content = string.format("Terlalu jauh (%.0f studs)! Harus dalam jarak 100.", distance),
            Duration = 4,
            Image = "alert-triangle"
        })
        return
    end

    Rayfield:Notify({
        Title = "Auto Walk (Manual)",
        Content = string.format("Menuju ke titik awal... (%.0f studs)", distance),
        Duration = 3,
        Image = "walk"
    })

    -- Buat fungsi untuk berjalan otomatis menuju titik awal
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local moving = true
    humanoid:MoveTo(startPos)

    -- Pastikan karakter benar-benar berjalan (tidak teleport)
    local reachedConnection
    reachedConnection = humanoid.MoveToFinished:Connect(function(reached)
        if reached then
            moving = false
            reachedConnection:Disconnect()

            Rayfield:Notify({
                Title = "Auto Walk (Manual)",
                Content = "Sudah sampai di titik awal, mulai playback...",
                Duration = 2,
                Image = "play"
            })

            -- Setelah sampai, mulai playback seperti biasa
            task.wait(0.5)
            startPlayback(data, function()
                Rayfield:Notify({
                    Title = "Auto Walk (Manual)",
                    Content = "Auto walk selesai!",
                    Duration = 2,
                    Image = "check-check"
                })
            end)
        else
            Rayfield:Notify({
                Title = "Auto Walk (Manual)",
                Content = "Gagal mencapai titik awal!",
                Duration = 3,
                Image = "ban"
            })
            moving = false
            reachedConnection:Disconnect()
        end
    end)

    -- Timeout antisipasi jika macet (misalnya terhalang)
    task.spawn(function()
        local timeout = 20
        local elapsed = 0
        while moving and elapsed < timeout do
            task.wait(1)
            elapsed += 1
        end
        if moving then
            Rayfield:Notify({
                Title = "Auto Walk (Manual)",
                Content = "Tidak bisa mencapai titik awal (timeout)!",
                Duration = 3,
                Image = "ban"
            })
            humanoid:Move(Vector3.new(0,0,0))
            moving = false
            if reachedConnection then reachedConnection:Disconnect() end
        end
    end)
end

-- Event listener when the player respawns
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    if isPlaying then stopPlayback() end
end)

-------------------------------------------------------------

-------------------------------------------------------------

-----| MENU 1 > AUTO WALK SETTINGS |-----
local Section = AutoWalkTab:CreateSection("Auto Walk (Settings)")

-------------------------------------------------------------
-- PAUSE FUNCTION (NO BACKGROUND VERSION)
-------------------------------------------------------------
local BTN_COLOR = Color3.fromRGB(38, 38, 38)
local BTN_HOVER = Color3.fromRGB(55, 55, 55)
local TEXT_COLOR = Color3.fromRGB(230, 230, 230)
local WARN_COLOR = Color3.fromRGB(255, 140, 0)
local SUCCESS_COLOR = Color3.fromRGB(0, 170, 85)

local function createPauseResumeUI()
    local ui = Instance.new("ScreenGui")
    ui.Name = "PauseResumeUI"
    ui.IgnoreGuiInset = true
    ui.ResetOnSpawn = false
    ui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ui.Parent = CoreGui

    -- Hilangkan frame utama (jadi cuma wadah transparan)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "PR_Main"
    mainFrame.BackgroundTransparency = 1 -- <- transparan penuh
    mainFrame.BorderSizePixel = 0
    mainFrame.AnchorPoint = Vector2.new(0.5, 1)
    mainFrame.Position = UDim2.new(0.5, 0, 1, -120)
    mainFrame.AutomaticSize = Enum.AutomaticSize.XY
    mainFrame.Visible = false
    mainFrame.Parent = ui

    local layout = Instance.new("UIListLayout", mainFrame)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 10)

    -- helper create button
    local function createButton(text, icon, color)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 110, 0, 34)
        btn.BackgroundColor3 = BTN_COLOR
        btn.BackgroundTransparency = 0.1
        btn.TextColor3 = TEXT_COLOR
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.Text = icon .. "  " .. text
        btn.AutoButtonColor = false
        btn.BorderSizePixel = 0
        btn.Parent = mainFrame

        local c = Instance.new("UICorner", btn)
        c.CornerRadius = UDim.new(0, 8)

        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.12, Enum.EasingStyle.Quad), {BackgroundColor3 = BTN_HOVER}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.12, Enum.EasingStyle.Quad), {BackgroundColor3 = BTN_COLOR}):Play()
        end)

        return btn
    end

    local pauseBtn = createButton("PAUSE", "⏸️", WARN_COLOR)
    local resumeBtn = createButton("RESUME", "▶️", SUCCESS_COLOR)

    -- Animasi muncul / hilang tanpa background
    local tweenTime = 0.3
    local finalYOffset = -120
    local hiddenYOffset = 20

    local function showUI()
        mainFrame.Position = UDim2.new(0.5, 0, 1, hiddenYOffset)
        mainFrame.Visible = true
        TweenService:Create(mainFrame, TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, 0, 1, finalYOffset)
        }):Play()
    end

    local function hideUI()
        TweenService:Create(mainFrame, TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, 0, 1, hiddenYOffset)
        }):Play()
        task.delay(tweenTime, function()
            mainFrame.Visible = false
        end)
    end

    -- Integrasi pause/resume
    pauseBtn.MouseButton1Click:Connect(function()
        if not isPlaying then
            Rayfield:Notify({Title = "Auto Walk", Content = "Tidak ada auto walk yang sedang berjalan.", Duration = 3, Image = "alert-triangle"})
            return
        end
        if not isPaused then
            isPaused = true
            Rayfield:Notify({Title = "Auto Walk", Content = "Auto walk dijeda.", Duration = 2, Image = "pause"})
        end
    end)

    resumeBtn.MouseButton1Click:Connect(function()
        if not isPlaying then
            Rayfield:Notify({Title = "Auto Walk", Content = "Tidak ada auto walk yang sedang berjalan.", Duration = 3, Image = "alert-triangle"})
            return
        end
        if isPaused then
            isPaused = false
            Rayfield:Notify({Title = "Auto Walk", Content = "Auto walk dilanjutkan.", Duration = 2, Image = "play"})
        end
    end)

    return {
        mainFrame = mainFrame,
        showUI = showUI,
        hideUI = hideUI
    }
end

-- Buat UI instance
local pauseResumeUI = createPauseResumeUI()

-------------------------------------------------------------
-- TOGGLE
-------------------------------------------------------------
local Toggle = AutoWalkTab:CreateToggle({
    Name = "Pause/Resume Menu",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            pauseResumeUI.showUI()
        else
            pauseResumeUI.hideUI()
        end
    end,
})

-- Slider Speed Auto
local SpeedSlider = AutoWalkTab:CreateSlider({
    Name = "⚡ Set Speed",
    Range = {0.5, 1.2},
    Increment = 0.01,
    Suffix = "x Speed",
    CurrentValue = 1.0,
    Callback = function(Value)
        playbackSpeed = Value

        local speedText = "Normal"
        if Value < 1.0 then
            speedText = "Lambat (" .. string.format("%.1f", Value) .. "x)"
        elseif Value > 1.0 then
            speedText = "Cepat (" .. string.format("%.1f", Value) .. "x)"
        else
            speedText = "Normal (" .. Value .. "x)"
        end
    end,
})
-------------------------------------------------------------

-----| MENU 1.5 > AUTO WALK LOOPING |-----
local Section = AutoWalkTab:CreateSection("Auto Walk (Looping)")

local LoopingToggle = AutoWalkTab:CreateToggle({
   Name = "🔄 Enable Looping",
   CurrentValue = false,
   Callback = function(Value)
        loopingEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Looping",
                Content = "Fitur looping diaktifkan!",
                Duration = 3,
                Image = "repeat"
            })
        else
            Rayfield:Notify({
                Title = "Looping",
                Content = "Fitur looping dinonaktifkan!",
                Duration = 3,
                Image = "x"
            })
        end
   end,
})

-------------------------------------------------------------

-----| MENU 3 > AUTO WALK (MANUAL) |-----
local Section = AutoWalkTab:CreateSection("Auto Walk (Manual)")

-- Toggle Auto Walk (Spawnpoint)
local CPSToggle = AutoWalkTab:CreateToggle({
    Name = "Auto Walk (Spawnpoint)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            playSingleCheckpointFile("spawnpoint.json", 1)
        else
            autoLoopEnabled = false
            isManualMode = false
            stopPlayback()
        end
    end,
})

-- Toggle Auto Walk (Checkpoint 1)
local CP1Toggle = AutoWalkTab:CreateToggle({
    Name = "Auto Walk (Checkpoint 1)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            playSingleCheckpointFile("checkpoint_1.json", 2)
        else
            autoLoopEnabled = false
            isManualMode = false
            stopPlayback()
        end
    end,
})

-- Toggle Auto Walk (Checkpoint 2)
local CP2Toggle = AutoWalkTab:CreateToggle({
    Name = "Auto Walk (Checkpoint 2)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            playSingleCheckpointFile("checkpoint_2.json", 3)
        else
            autoLoopEnabled = false
            isManualMode = false
            stopPlayback()
        end
    end,
})

-- Toggle Auto Walk (Checkpoint 3)
local CP3Toggle = AutoWalkTab:CreateToggle({
    Name = "Auto Walk (Checkpoint 3)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            playSingleCheckpointFile("checkpoint_3.json", 4)
        else
            autoLoopEnabled = false
            isManualMode = false
            stopPlayback()
        end
    end,
})

-- Toggle Auto Walk (Checkpoint 4)
local CP4Toggle = AutoWalkTab:CreateToggle({
    Name = "Auto Walk (Checkpoint 4)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            playSingleCheckpointFile("checkpoint_4.json", 5)
        else
            autoLoopEnabled = false
            isManualMode = false
            stopPlayback()
        end
    end,
})

-- Toggle Auto Walk (Checkpoint 5)
local CP5Toggle = AutoWalkTab:CreateToggle({
    Name = "Auto Walk (Checkpoint 5)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            playSingleCheckpointFile("checkpoint_5.json", 6)
        else
            autoLoopEnabled = false
            isManualMode = false
            stopPlayback()
        end
    end,
})

-- Toggle Auto Walk (Checkpoint 6)
local CP6Toggle = AutoWalkTab:CreateToggle({
    Name = "Auto Walk (Checkpoint 6)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            playSingleCheckpointFile("checkpoint_6.json", 7)
        else
            autoLoopEnabled = false
            isManualMode = false
            stopPlayback()
        end
    end,
})

-- Toggle Auto Walk (Checkpoint 7)
local CP7Toggle = AutoWalkTab:CreateToggle({
    Name = "Auto Walk (Checkpoint 7)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            playSingleCheckpointFile("checkpoint_7.json", 8)
        else
            autoLoopEnabled = false
            isManualMode = false
            stopPlayback()
        end
    end,
})

-- Toggle Auto Walk (Checkpoint 8)
local CP8Toggle = AutoWalkTab:CreateToggle({
    Name = "Auto Walk (Checkpoint 8)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            playSingleCheckpointFile("checkpoint_8.json", 9)
        else
            autoLoopEnabled = false
            isManualMode = false
            stopPlayback()
        end
    end,
})

-- Toggle Auto Walk (Checkpoint 9)
local CP9Toggle = AutoWalkTab:CreateToggle({
    Name = "Auto Walk (Checkpoint 9)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            playSingleCheckpointFile("checkpoint_9.json", 10)
        else
            autoLoopEnabled = false
            isManualMode = false
            stopPlayback()
        end
    end,
})

-- Toggle Auto Walk (Checkpoint 10)
local CP10Toggle = AutoWalkTab:CreateToggle({
    Name = "Auto Walk (Checkpoint 10)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            playSingleCheckpointFile("checkpoint_10.json", 11)
        else
            autoLoopEnabled = false
            isManualMode = false
            stopPlayback()
        end
    end,
})

-- Toggle Auto Walk (Checkpoint 11)
local CP11Toggle = AutoWalkTab:CreateToggle({
    Name = "Auto Walk (Checkpoint 11)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            playSingleCheckpointFile("checkpoint_11.json", 12)
        else
            autoLoopEnabled = false
            isManualMode = false
            stopPlayback()
        end
    end,
})

-- Toggle Auto Walk (Checkpoint 12)
local CP12Toggle = AutoWalkTab:CreateToggle({
    Name = "Auto Walk (Checkpoint 12)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            playSingleCheckpointFile("checkpoint_12.json", 13)
        else
            autoLoopEnabled = false
            isManualMode = false
            stopPlayback()
        end
    end,
})

-- Toggle Auto Walk (Checkpoint 13)
local CP13Toggle = AutoWalkTab:CreateToggle({
    Name = "Auto Walk (Checkpoint 13)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            playSingleCheckpointFile("checkpoint_13.json", 14)
        else
            autoLoopEnabled = false
            isManualMode = false
            stopPlayback()
        end
    end,
})

-- Toggle Auto Walk (Checkpoint 14)
local CP14Toggle = AutoWalkTab:CreateToggle({
    Name = "Auto Walk (Checkpoint 14)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            playSingleCheckpointFile("checkpoint_14.json", 15)
        else
            autoLoopEnabled = false
            isManualMode = false
            stopPlayback()
        end
    end,
})

-- Toggle Auto Walk (Checkpoint 15)
local CP15Toggle = AutoWalkTab:CreateToggle({
    Name = "Auto Walk (Checkpoint 15)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            playSingleCheckpointFile("checkpoint_15.json", 16)
        else
            autoLoopEnabled = false
            isManualMode = false
            stopPlayback()
        end
    end,
})

-- Toggle Auto Walk (Checkpoint 16)
local CP16Toggle = AutoWalkTab:CreateToggle({
    Name = "Auto Walk (Checkpoint 16)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            playSingleCheckpointFile("checkpoint_16.json", 17)
        else
            autoLoopEnabled = false
            isManualMode = false
            stopPlayback()
        end
    end,
})

-- Toggle Auto Walk (Checkpoint 17)
local CP17Toggle = AutoWalkTab:CreateToggle({
    Name = "Auto Walk (Checkpoint 17)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            playSingleCheckpointFile("checkpoint_17.json", 18)
        else
            autoLoopEnabled = false
            isManualMode = false
            stopPlayback()
        end
    end,
})

-- Toggle Auto Walk (Checkpoint 18)
local CP18Toggle = AutoWalkTab:CreateToggle({
    Name = "Auto Walk (Checkpoint 18)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            playSingleCheckpointFile("checkpoint_18.json", 19)
        else
            autoLoopEnabled = false
            isManualMode = false
            stopPlayback()
        end
    end,
})

-- Toggle Auto Walk (Checkpoint 19)
local CP19Toggle = AutoWalkTab:CreateToggle({
    Name = "Auto Walk (Checkpoint 19)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            playSingleCheckpointFile("checkpoint_19.json", 20)
        else
            autoLoopEnabled = false
            isManualMode = false
            stopPlayback()
        end
    end,
})

-- Toggle Auto Walk (Checkpoint 20)
local CP20Toggle = AutoWalkTab:CreateToggle({
    Name = "Auto Walk (Checkpoint 20)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            playSingleCheckpointFile("checkpoint_20.json", 21)
        else
            autoLoopEnabled = false
            isManualMode = false
            stopPlayback()
        end
    end,
})

-- Toggle Auto Walk (Checkpoint 21)
local CP21Toggle = AutoWalkTab:CreateToggle({
    Name = "Auto Walk (Checkpoint 21)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            playSingleCheckpointFile("checkpoint_21.json", 22)
        else
            autoLoopEnabled = false
            isManualMode = false
            stopPlayback()
        end
    end,
})

-- Toggle Auto Walk (Checkpoint 22)
local CP22Toggle = AutoWalkTab:CreateToggle({
    Name = "Auto Walk (Checkpoint 22)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            playSingleCheckpointFile("checkpoint_22.json", 23)
        else
            autoLoopEnabled = false
            isManualMode = false
            stopPlayback()
        end
    end,
})

-- Toggle Auto Walk (Checkpoint 23)
local CP23Toggle = AutoWalkTab:CreateToggle({
    Name = "Auto Walk (Checkpoint 23)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            playSingleCheckpointFile("checkpoint_23.json", 24)
        else
            autoLoopEnabled = false
            isManualMode = false
            stopPlayback()
        end
    end,
})

-- Toggle Auto Walk (Checkpoint 24)
local CP24Toggle = AutoWalkTab:CreateToggle({
    Name = "Auto Walk (Checkpoint 24)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            playSingleCheckpointFile("checkpoint_24.json", 25)
        else
            autoLoopEnabled = false
            isManualMode = false
            stopPlayback()
        end
    end,
})

-- Toggle Auto Walk (Checkpoint 25)
local CP25Toggle = AutoWalkTab:CreateToggle({
    Name = "Auto Walk (Checkpoint 25)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            playSingleCheckpointFile("checkpoint_25.json", 26)
        else
            autoLoopEnabled = false
            isManualMode = false
            stopPlayback()
        end
    end,
})

-- Toggle Auto Walk (Checkpoint 26)
local CP26Toggle = AutoWalkTab:CreateToggle({
    Name = "Auto Walk (Checkpoint 26)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            playSingleCheckpointFile("checkpoint_26.json", 27)
        else
            autoLoopEnabled = false
            isManualMode = false
            stopPlayback()
        end
    end,
})

-- Toggle Auto Walk (Checkpoint 27)
local CP27Toggle = AutoWalkTab:CreateToggle({
    Name = "Auto Walk (Checkpoint 27)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            playSingleCheckpointFile("checkpoint_27.json", 28)
        else
            autoLoopEnabled = false
            isManualMode = false
            stopPlayback()
        end
    end,
})

-- Toggle Auto Walk (Checkpoint 28)
local CP28Toggle = AutoWalkTab:CreateToggle({
    Name = "Auto Walk (Checkpoint 28)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            playSingleCheckpointFile("checkpoint_28.json", 29)
        else
            autoLoopEnabled = false
            isManualMode = false
            stopPlayback()
        end
    end,
})

-- Toggle Auto Walk (Checkpoint 29)
local CP29Toggle = AutoWalkTab:CreateToggle({
    Name = "Auto Walk (Checkpoint 29)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            playSingleCheckpointFile("checkpoint_29.json", 30)
        else
            autoLoopEnabled = false
            isManualMode = false
            stopPlayback()
        end
    end,
})

-- Toggle Auto Walk (Checkpoint 30)
local CP30Toggle = AutoWalkTab:CreateToggle({
    Name = "Auto Walk (Checkpoint 30)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            playSingleCheckpointFile("checkpoint_30.json", 31)
        else
            autoLoopEnabled = false
            isManualMode = false
            stopPlayback()
        end
    end,
})

-- Toggle Auto Walk (Checkpoint 31)
local CP31Toggle = AutoWalkTab:CreateToggle({
    Name = "Auto Walk (Checkpoint 31)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            playSingleCheckpointFile("checkpoint_31.json", 32)
        else
            autoLoopEnabled = false
            isManualMode = false
            stopPlayback()
        end
    end,
})

-- Toggle Auto Walk (Checkpoint 32)
local CP32Toggle = AutoWalkTab:CreateToggle({
    Name = "Auto Walk (Checkpoint 32)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            playSingleCheckpointFile("checkpoint_32.json", 33)
        else
            autoLoopEnabled = false
            isManualMode = false
            stopPlayback()
        end
    end,
})

-- Toggle Auto Walk (Checkpoint 33)
local CP33Toggle = AutoWalkTab:CreateToggle({
    Name = "Auto Walk (Checkpoint 33)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            playSingleCheckpointFile("checkpoint_33.json", 34)
        else
            autoLoopEnabled = false
            isManualMode = false
            stopPlayback()
        end
    end,
})
-------------------------------------------------------------
-- AUTO WALK - END
-------------------------------------------------------------



-- =============================================================
-- VISUAL
-- =============================================================

-- ===== | TIME MENU | ===== --
local VisualSection = VisualTab:CreateSection("Time Menu")

-- Variables
local Lighting = game:GetService("Lighting")

-- Slider Time Changer
local TimeSlider = VisualTab:CreateSlider({
   Name = "🕒 Time Changer",
   Range = {0, 24},
   Increment = 1,
   Suffix = "Hours",
   CurrentValue = Lighting.ClockTime,
   Callback = function(Value)
       Lighting.ClockTime = Value

       if Value >= 6 and Value < 18 then
           Lighting.Brightness = 2
           Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
       else
           Lighting.Brightness = 0.5
           Lighting.OutdoorAmbient = Color3.fromRGB(50, 50, 100)
       end
   end,
})
-- ===== | TIME MENU - END | ===== --
-- =============================================================
-- VISUAL - END
-- =============================================================



-------------------------------------------------------------
-- RUN ANIMATION
-------------------------------------------------------------
local Section = RunAnimationTab:CreateSection("Animation Pack List")

-----| ID ANIMATION |-----
local RunAnimations = {
    ["Run Animation 1"] = {
        Idle1   = "rbxassetid://122257458498464",
        Idle2   = "rbxassetid://102357151005774",
        Walk    = "http://www.roblox.com/asset/?id=18537392113",
        Run     = "rbxassetid://82598234841035",
        Jump    = "rbxassetid://75290611992385",
        Fall    = "http://www.roblox.com/asset/?id=11600206437",
        Climb   = "http://www.roblox.com/asset/?id=10921257536",
        Swim    = "http://www.roblox.com/asset/?id=10921264784",
        SwimIdle= "http://www.roblox.com/asset/?id=10921265698"
    },
    ["Run Animation 2"] = {
        Idle1   = "rbxassetid://122257458498464",
        Idle2   = "rbxassetid://102357151005774",
        Walk    = "rbxassetid://122150855457006",
        Run     = "rbxassetid://82598234841035",
        Jump    = "rbxassetid://75290611992385",
        Fall    = "rbxassetid://98600215928904",
        Climb   = "rbxassetid://88763136693023",
        Swim    = "rbxassetid://133308483266208",
        SwimIdle= "rbxassetid://109346520324160"
    },
    ["Run Animation 3"] = {
        Idle1   = "http://www.roblox.com/asset/?id=18537376492",
        Idle2   = "http://www.roblox.com/asset/?id=18537371272",
        Walk    = "http://www.roblox.com/asset/?id=18537392113",
        Run     = "http://www.roblox.com/asset/?id=18537384940",
        Jump    = "http://www.roblox.com/asset/?id=18537380791",
        Fall    = "http://www.roblox.com/asset/?id=18537367238",
        Climb   = "http://www.roblox.com/asset/?id=10921271391",
        Swim    = "http://www.roblox.com/asset/?id=99384245425157",
        SwimIdle= "http://www.roblox.com/asset/?id=113199415118199"
    },
    ["Run Animation 4"] = {
        Idle1   = "http://www.roblox.com/asset/?id=118832222982049",
        Idle2   = "http://www.roblox.com/asset/?id=76049494037641",
        Walk    = "http://www.roblox.com/asset/?id=92072849924640",
        Run     = "http://www.roblox.com/asset/?id=72301599441680",
        Jump    = "http://www.roblox.com/asset/?id=104325245285198",
        Fall    = "http://www.roblox.com/asset/?id=121152442762481",
        Climb   = "http://www.roblox.com/asset/?id=507765644",
        Swim    = "http://www.roblox.com/asset/?id=99384245425157",
        SwimIdle= "http://www.roblox.com/asset/?id=113199415118199"
    },
    ["Run Animation 5"] = {
        Idle1   = "http://www.roblox.com/asset/?id=656117400",
        Idle2   = "http://www.roblox.com/asset/?id=656118341",
        Walk    = "http://www.roblox.com/asset/?id=656121766",
        Run     = "http://www.roblox.com/asset/?id=656118852",
        Jump    = "http://www.roblox.com/asset/?id=656117878",
        Fall    = "http://www.roblox.com/asset/?id=656115606",
        Climb   = "http://www.roblox.com/asset/?id=656114359",
        Swim    = "http://www.roblox.com/asset/?id=910028158",
        SwimIdle= "http://www.roblox.com/asset/?id=910030921"
    },
    ["Run Animation 6"] = {
        Idle1   = "http://www.roblox.com/asset/?id=616006778",
        Idle2   = "http://www.roblox.com/asset/?id=616008087",
        Walk    = "http://www.roblox.com/asset/?id=616013216",
        Run     = "http://www.roblox.com/asset/?id=616010382",
        Jump    = "http://www.roblox.com/asset/?id=616008936",
        Fall    = "http://www.roblox.com/asset/?id=616005863",
        Climb   = "http://www.roblox.com/asset/?id=616003713",
        Swim    = "http://www.roblox.com/asset/?id=910028158",
        SwimIdle= "http://www.roblox.com/asset/?id=910030921"
    },
    ["Run Animation 7"] = {
        Idle1   = "http://www.roblox.com/asset/?id=1083195517",
        Idle2   = "http://www.roblox.com/asset/?id=1083214717",
        Walk    = "http://www.roblox.com/asset/?id=1083178339",
        Run     = "http://www.roblox.com/asset/?id=1083216690",
        Jump    = "http://www.roblox.com/asset/?id=1083218792",
        Fall    = "http://www.roblox.com/asset/?id=1083189019",
        Climb   = "http://www.roblox.com/asset/?id=1083182000",
        Swim    = "http://www.roblox.com/asset/?id=910028158",
        SwimIdle= "http://www.roblox.com/asset/?id=910030921"
    },
    ["Run Animation 8"] = {
        Idle1   = "http://www.roblox.com/asset/?id=616136790",
        Idle2   = "http://www.roblox.com/asset/?id=616138447",
        Walk    = "http://www.roblox.com/asset/?id=616146177",
        Run     = "http://www.roblox.com/asset/?id=616140816",
        Jump    = "http://www.roblox.com/asset/?id=616139451",
        Fall    = "http://www.roblox.com/asset/?id=616134815",
        Climb   = "http://www.roblox.com/asset/?id=616133594",
        Swim    = "http://www.roblox.com/asset/?id=910028158",
        SwimIdle= "http://www.roblox.com/asset/?id=910030921"
    },
    ["Run Animation 9"] = {
        Idle1   = "http://www.roblox.com/asset/?id=616088211",
        Idle2   = "http://www.roblox.com/asset/?id=616089559",
        Walk    = "http://www.roblox.com/asset/?id=616095330",
        Run     = "http://www.roblox.com/asset/?id=616091570",
        Jump    = "http://www.roblox.com/asset/?id=616090535",
        Fall    = "http://www.roblox.com/asset/?id=616087089",
        Climb   = "http://www.roblox.com/asset/?id=616086039",
        Swim    = "http://www.roblox.com/asset/?id=910028158",
        SwimIdle= "http://www.roblox.com/asset/?id=910030921"
    },
    ["Run Animation 10"] = {
        Idle1   = "http://www.roblox.com/asset/?id=910004836",
        Idle2   = "http://www.roblox.com/asset/?id=910009958",
        Walk    = "http://www.roblox.com/asset/?id=910034870",
        Run     = "http://www.roblox.com/asset/?id=910025107",
        Jump    = "http://www.roblox.com/asset/?id=910016857",
        Fall    = "http://www.roblox.com/asset/?id=910001910",
        Climb   = "http://www.roblox.com/asset/?id=616086039",
        Swim    = "http://www.roblox.com/asset/?id=910028158",
        SwimIdle= "http://www.roblox.com/asset/?id=910030921"
    },
    ["Run Animation 11"] = {
        Idle1   = "http://www.roblox.com/asset/?id=742637544",
        Idle2   = "http://www.roblox.com/asset/?id=742638445",
        Walk    = "http://www.roblox.com/asset/?id=742640026",
        Run     = "http://www.roblox.com/asset/?id=742638842",
        Jump    = "http://www.roblox.com/asset/?id=742637942",
        Fall    = "http://www.roblox.com/asset/?id=742637151",
        Climb   = "http://www.roblox.com/asset/?id=742636889",
        Swim    = "http://www.roblox.com/asset/?id=910028158",
        SwimIdle= "http://www.roblox.com/asset/?id=910030921"
    },
    ["Run Animation 12"] = {
        Idle1   = "http://www.roblox.com/asset/?id=616111295",
        Idle2   = "http://www.roblox.com/asset/?id=616113536",
        Walk    = "http://www.roblox.com/asset/?id=616122287",
        Run     = "http://www.roblox.com/asset/?id=616117076",
        Jump    = "http://www.roblox.com/asset/?id=616115533",
        Fall    = "http://www.roblox.com/asset/?id=616108001",
        Climb   = "http://www.roblox.com/asset/?id=616104706",
        Swim    = "http://www.roblox.com/asset/?id=910028158",
        SwimIdle= "http://www.roblox.com/asset/?id=910030921"
    },
    ["Run Animation 13"] = {
        Idle1   = "http://www.roblox.com/asset/?id=657595757",
        Idle2   = "http://www.roblox.com/asset/?id=657568135",
        Walk    = "http://www.roblox.com/asset/?id=657552124",
        Run     = "http://www.roblox.com/asset/?id=657564596",
        Jump    = "http://www.roblox.com/asset/?id=658409194",
        Fall    = "http://www.roblox.com/asset/?id=657600338",
        Climb   = "http://www.roblox.com/asset/?id=658360781",
        Swim    = "http://www.roblox.com/asset/?id=910028158",
        SwimIdle= "http://www.roblox.com/asset/?id=910030921"
    },
    ["Run Animation 14"] = {
        Idle1   = "http://www.roblox.com/asset/?id=616158929",
        Idle2   = "http://www.roblox.com/asset/?id=616160636",
        Walk    = "http://www.roblox.com/asset/?id=616168032",
        Run     = "http://www.roblox.com/asset/?id=616163682",
        Jump    = "http://www.roblox.com/asset/?id=616161997",
        Fall    = "http://www.roblox.com/asset/?id=616157476",
        Climb   = "http://www.roblox.com/asset/?id=616156119",
        Swim    = "http://www.roblox.com/asset/?id=910028158",
        SwimIdle= "http://www.roblox.com/asset/?id=910030921"
    },
    ["Run Animation 15"] = {
        Idle1   = "http://www.roblox.com/asset/?id=845397899",
        Idle2   = "http://www.roblox.com/asset/?id=845400520",
        Walk    = "http://www.roblox.com/asset/?id=845403856",
        Run     = "http://www.roblox.com/asset/?id=845386501",
        Jump    = "http://www.roblox.com/asset/?id=845398858",
        Fall    = "http://www.roblox.com/asset/?id=845396048",
        Climb   = "http://www.roblox.com/asset/?id=845392038",
        Swim    = "http://www.roblox.com/asset/?id=910028158",
        SwimIdle= "http://www.roblox.com/asset/?id=910030921"
    },
    ["Run Animation 16"] = {
        Idle1   = "http://www.roblox.com/asset/?id=782841498",
        Idle2   = "http://www.roblox.com/asset/?id=782845736",
        Walk    = "http://www.roblox.com/asset/?id=782843345",
        Run     = "http://www.roblox.com/asset/?id=782842708",
        Jump    = "http://www.roblox.com/asset/?id=782847020",
        Fall    = "http://www.roblox.com/asset/?id=782846423",
        Climb   = "http://www.roblox.com/asset/?id=782843869",
        Swim    = "http://www.roblox.com/asset/?id=18537389531",
        SwimIdle= "http://www.roblox.com/asset/?id=18537387180"
    },
    ["Run Animation 17"] = {
        Idle1   = "http://www.roblox.com/asset/?id=891621366",
        Idle2   = "http://www.roblox.com/asset/?id=891633237",
        Walk    = "http://www.roblox.com/asset/?id=891667138",
        Run     = "http://www.roblox.com/asset/?id=891636393",
        Jump    = "http://www.roblox.com/asset/?id=891627522",
        Fall    = "http://www.roblox.com/asset/?id=891617961",
        Climb   = "http://www.roblox.com/asset/?id=891609353",
        Swim    = "http://www.roblox.com/asset/?id=18537389531",
        SwimIdle= "http://www.roblox.com/asset/?id=18537387180"
    },
    ["Run Animation 18"] = {
        Idle1   = "http://www.roblox.com/asset/?id=750781874",
        Idle2   = "http://www.roblox.com/asset/?id=750782770",
        Walk    = "http://www.roblox.com/asset/?id=750785693",
        Run     = "http://www.roblox.com/asset/?id=750783738",
        Jump    = "http://www.roblox.com/asset/?id=750782230",
        Fall    = "http://www.roblox.com/asset/?id=750780242",
        Climb   = "http://www.roblox.com/asset/?id=750779899",
        Swim    = "http://www.roblox.com/asset/?id=18537389531",
        SwimIdle= "http://www.roblox.com/asset/?id=18537387180"
    },
}

-------------------------------------------------------------
-----| FUNCTION RUN ANIMATION |-----
local OriginalAnimations = {}
local CurrentPack = nil

local function SaveOriginalAnimations(Animate)
    OriginalAnimations = {}
    for _, child in ipairs(Animate:GetDescendants()) do
        if child:IsA("Animation") then
            OriginalAnimations[child] = child.AnimationId
        end
    end
end

local function ApplyAnimations(Animate, Humanoid, AnimPack)
    Animate.idle.Animation1.AnimationId = AnimPack.Idle1
    Animate.idle.Animation2.AnimationId = AnimPack.Idle2
    Animate.walk.WalkAnim.AnimationId   = AnimPack.Walk
    Animate.run.RunAnim.AnimationId     = AnimPack.Run
    Animate.jump.JumpAnim.AnimationId   = AnimPack.Jump
    Animate.fall.FallAnim.AnimationId   = AnimPack.Fall
    Animate.climb.ClimbAnim.AnimationId = AnimPack.Climb
    Animate.swim.Swim.AnimationId       = AnimPack.Swim
    Animate.swimidle.SwimIdle.AnimationId = AnimPack.SwimIdle
    Humanoid.Jump = true
end

local function RestoreOriginal()
    for anim, id in pairs(OriginalAnimations) do
        if anim and anim:IsA("Animation") then
            anim.AnimationId = id
        end
    end
end

local function SetupCharacter(Char)
    local Animate = Char:WaitForChild("Animate")
    local Humanoid = Char:WaitForChild("Humanoid")
    SaveOriginalAnimations(Animate)
    if CurrentPack then
        ApplyAnimations(Animate, Humanoid, CurrentPack)
    end
end

Players.LocalPlayer.CharacterAdded:Connect(function(Char)
    task.wait(1)
    SetupCharacter(Char)
end)

if Players.LocalPlayer.Character then
    SetupCharacter(Players.LocalPlayer.Character)
end

-------------------------------------------------------------
-----| TOGGLES RUN ANIMATION |-----
for i = 1, 18 do
    local name = "Run Animation " .. i
    local pack = RunAnimations[name]

    RunAnimationTab:CreateToggle({
        Name = name,
        CurrentValue = false,
        Flag = name .. "Toggle",
        Callback = function(Value)
            if Value then
                CurrentPack = pack
            elseif CurrentPack == pack then
                CurrentPack = nil
                RestoreOriginal()
            end

            local Char = Players.LocalPlayer.Character
            if Char and Char:FindFirstChild("Animate") and Char:FindFirstChild("Humanoid") then
                if CurrentPack then
                    ApplyAnimations(Char.Animate, Char.Humanoid, CurrentPack)
                else
                    RestoreOriginal()
                end
            end
        end,
    })
end
-------------------------------------------------------------
-- RUN ANIMATION - END
-------------------------------------------------------------



-------------------------------------------------------------
-- UPDATE SCRIPT
-------------------------------------------------------------
-----| UPDATE SCRIPT VARIABLES |-----
-- Variables to control the update process
local updateEnabled = false
local stopUpdate = {false}

-------------------------------------------------------------

-----| MENU 1 > UPDATE SCRIPT STATUS |-----
-- Label to display the status of checking JSON files
local Section = UpdateTab:CreateSection("Update Script Menu")

local Label = UpdateTab:CreateLabel("Pengecekan file...")

-- Task for checking JSON files during startup
task.spawn(function()
    for i, f in ipairs(jsonFiles) do
        local ok = EnsureJsonFile(f)
        Label:Set((ok and "✔ Proses Cek File: " or "❌ Gagal: ").." ("..i.."/"..#jsonFiles..")")
        task.wait(0.5)
    end
    Label:Set("✔ Semua file aman")
end)

-------------------------------------------------------------

-----| MENU 2 > UPDATE SCRIPT TOGGLE |-----
-- Toggle to start the script update process (redownload all JSON)
UpdateTab:CreateToggle({
    Name = "Mulai Update Script",
    CurrentValue = false,
    Callback = function(state)
        if state then
            updateEnabled = true
            stopUpdate[1] = false
            task.spawn(function()
                Label:Set("🔄 Proses update file...")
                
                -- Delete all existing JSON files
                for _, f in ipairs(jsonFiles) do
                    local savePath = jsonFolder .. "/" .. f
                    if isfile(savePath) then
                        delfile(savePath)
                    end
                end
                
                -- Re-download all JSON files
                for i, f in ipairs(jsonFiles) do
                    if stopUpdate[1] then break end
                    
                    Rayfield:Notify({
                        Title = "Update Script",
                        Content = "Proses Update " .. " ("..i.."/"..#jsonFiles..")",
                        Duration = 2,
                        Image = "file",
                    })
                    
                    local ok, res = pcall(function() return game:HttpGet(baseURL..f) end)
                    if ok and res and #res > 0 then
                        writefile(jsonFolder.."/"..f, res)
                        Label:Set("📥 Proses Update: ".. " ("..i.."/"..#jsonFiles..")")
                    else
                        Rayfield:Notify({
                            Title = "Update Script",
                            Content = "❌ Update script gagal",
                            Duration = 3,
                            Image = "file",
                        })
                        Label:Set("❌ Gagal: ".. " ("..i.."/"..#jsonFiles..")")
                    end
                    task.wait(0.3)
                end
                
                -- Update result notification
                if not stopUpdate[1] then
                    Rayfield:Notify({
                        Title = "Update Script",
                        Content = "Telah berhasil!",
                        Duration = 5,
                        Image = "check-check",
                    })
                else
                    Rayfield:Notify({
                        Title = "Update Script",
                        Content = "❌ Update canceled",
                        Duration = 3,
                        Image = 4483362458,
                    })
                end
				
                -- Re-check all files after updating
                for i, f in ipairs(jsonFiles) do
                    local ok = EnsureJsonFile(f)
                    Label:Set((ok and "✔ Cek File: " or "❌ Failed: ").." ("..i.."/"..#jsonFiles..")")
                    task.wait(0.3)
                end
                Label:Set("✔ Semua file aman")
            end)
        else
            updateEnabled = false
            stopUpdate[1] = true
        end
    end,
})
-------------------------------------------------------------
-- UPDATE SCRIPT - END
-------------------------------------------------------------



-------------------------------------------------------------
-- CREDITS
-------------------------------------------------------------
local Section = CreditsTab:CreateSection("Credits List")

-- Credits: 1
CreditsTab:CreateLabel("UI: Rayfield Interface")
-- Credits: 2
CreditsTab:CreateLabel("Dev: Hirako")
-------------------------------------------------------------
-- CREDITS - END
-------------------------------------------------------------



