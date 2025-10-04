--[[
    Skrip:  | MOUNT STECU
    Developer: Hirako
    UI Library: Rayfield
    Deskripsi: Skrip ini menyediakan fitur auto-walk, auto-summit, dan teleportasi
               untuk game "MOUNT STECU" di Roblox.
]]

-- =============================================================================
-- Services & Libraries
-- =============================================================================

-- Memuat UI Library Rayfield
local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/RullzsyHUB/roblox-scripts/refs/heads/main/UI%20Liblary/Rayfield.lua"))()

-- Localize Roblox Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- Localize Standard Library Functions untuk Performa
local s_char = string.char
local s_byte = string.byte
local s_sub = string.sub
local s_format = string.format
local t_concat = table.concat
local t_insert = table.insert
local math_clamp = math.clamp
local math_floor = math.floor
local math_pi = math.pi
local math_exp = math.exp
local bit_lib = bit32 or bit
local bit_bxor = bit_lib.bxor

-- =============================================================================
-- Player & Character Variables
-- =============================================================================
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- =============================================================================
-- Konfigurasi & Variabel Global
-- =============================================================================

-- Konfigurasi Folder & URL
local FOLDER_NAME = "Hirako"
local SUBFOLDER_NAME = FOLDER_NAME .. "/json_mt_stecu"
local JSON_BASE_URL = "https://raw.githubusercontent.com/RullzsyHUB/roblox-scripts-json/refs/heads/main/json_mt_stecu/"

-- Nama file checkpoint untuk auto-walk
local CHECKPOINT_FILES = {
    "spawnpoint.json", "checkpoint_1.json", "checkpoint_2.json", "checkpoint_3.json",
    "checkpoint_4.json", "checkpoint_5.json", "checkpoint_6.json", "checkpoint_7.json",
    "checkpoint_8.json", "checkpoint_9.json", "checkpoint_10.json", "checkpoint_11.json",
    "checkpoint_12.json", "checkpoint_13.json", "checkpoint_14.json", "checkpoint_15.json",
    "checkpoint_16.json", "checkpoint_17.json", "checkpoint_18.json", "checkpoint_19.json",
    "checkpoint_20.json", "checkpoint_21.json", "checkpoint_22.json", "checkpoint_23.json",
    "checkpoint_24.json", "checkpoint_25.json"
}

-- Konfigurasi API untuk otentikasi
local API_CONFIG = {
    base_url = "https://monotonal-unhoneyed-rita.ngrok-free.dev",
    get_user_endpoint = "/get_user.php"
}

-- Status Auto-Walk
local isPathPlaying = false
local pathPlaybackConnection = nil
local isAutoWalkActive = false
local currentCheckpointIndex = 0
isPathPaused = false
local isUpdateScriptActive = false

-- Variabel Waktu untuk Playback
local timePaused = 0
local timeStarted = 0
local totalTimeElapsed = 0

-- Variabel Auto-Summit
local TELEPORT_OFFSET_Y = 10
local isAutoSummitActive = false
local autoSummitDelay = 3
local autoSummitManualDelay = 3
local godModeHealthConnection = nil
local godModeStateConnection = nil
local selectedCheckpointIndex = 1

-- =============================================================================
-- Utility Functions
-- =============================================================================

-- Fungsi enkripsi/dekripsi XOR (tidak digunakan dalam skrip ini, tapi ada di asli)
local function xorEncryptDecrypt(text, key)
    local result = {}
    for i = 1, #text do
        local textByte = s_byte(s_sub(text, i, i))
        local keyByte = s_byte(s_sub(key, 1 + ((i - 1) % #key), 1 + ((i - 1) % #key)))
        t_insert(result, s_char(bit_bxor(textByte, keyByte)))
    end
    return t_concat(result)
end

-- Wrapper untuk HTTP requests
local function makeRequest(url, method, body, headers)
    method = method or "GET"
    local requestParams = { Url = url, Method = method }
    if headers then requestParams.Headers = headers end
    if body and (method == "POST") then requestParams.Body = body end

    local success, response = pcall(function() return HttpService:RequestAsync(requestParams) end)

    if success and response then
        if response.Success and response.StatusCode == 200 then
            return true, response.Body
        else
            local errorMessage = "HTTP Error: " .. (response.StatusCode or "Unknown") .. " - " .. (response.StatusMessage or "Unknown error")
            return false, errorMessage
        end
    end
    
    -- Fallback untuk GET jika RequestAsync gagal
    if method == "GET" then
        local getSuccess, getResponse = pcall(function() return HttpService:GetAsync(url, false) end)
        if getSuccess and getResponse then return true, getResponse end
        
        local httpGetSuccess, httpGetResponse = pcall(function() return game:HttpGet(url) end)
        if httpGetSuccess and httpGetResponse then return true, httpGetResponse end
    end
    
    return false, tostring(response)
end

-- Konversi dari Instance Vector3 ke table
local function vector3ToTable(vec3)
    return { x = vec3.X, y = vec3.Y, z = vec3.Z }
end

-- Konversi dari table ke Instance Vector3
local function tableToVector3(tbl)
    return Vector3.new(tbl.x, tbl.y, tbl.z)
end

-- Interpolasi linear (Lerp) untuk angka
local function lerpNumber(start, goal, alpha)
    return start + (goal - start) * alpha
end

-- Interpolasi linear (Lerp) untuk Vector3
local function lerpVector3(start, goal, alpha)
    return Vector3.new(
        lerpNumber(start.X, goal.X, alpha),
        lerpNumber(start.Y, goal.Y, alpha),
        lerpNumber(start.Z, goal.Z, alpha)
    )
end

-- Interpolasi linear sirkular (Slerp) untuk sudut (rotasi)
local function slerpAngle(start, goal, alpha)
    local delta = goal - start
    while delta > math_pi do delta = delta - (2 * math_pi) end
    while delta < -math_pi do delta = delta + (2 * math_pi) end
    return start + (delta * alpha)
end

-- Memastikan file JSON ada (download jika tidak)
local function ensureJsonFile(fileName)
    local filePath = SUBFOLDER_NAME .. "/" .. fileName
    if isfile(filePath) then
        return true, filePath
    end
    
    local success, content = pcall(function() return game:HttpGet(JSON_BASE_URL .. fileName) end)
    
    if success and content and #content > 0 then
        writefile(filePath, content)
        return true, filePath
    end
    
    return false, nil
end

-- Memuat dan mendekode data dari file JSON
local function loadJsonFile(fileName)
    local filePath = SUBFOLDER_NAME .. "/" .. fileName
    if not isfile(filePath) then
        warn("File not found:", filePath)
        return nil
    end
    
    local success, data = pcall(function()
        local content = readfile(filePath)
        if not content or content == "" then
            error("Empty file content")
        end
        return HttpService:JSONDecode(content)
    end)
    
    if success and data then
        return data
    else
        warn("❌ Load error for", fileName, ":", data)
        return nil
    end
end

-- Cari frame kunci berdasarkan waktu
local function findKeyframes(pathData, currentTime)
    if #pathData == 0 then return nil, nil, 0 end
    if currentTime <= pathData[1].time then return 1, 1, 0 end
    if currentTime >= pathData[#pathData].time then return #pathData, #pathData, 0 end

    local left, right = 1, #pathData
    while left < (right - 1) do
        local mid = math_floor((left + right) / 2)
        if pathData[mid].time <= currentTime then
            left = mid
        else
            right = mid
        end
    end

    local keyframe1, keyframe2 = left, right
    local timeDiff = pathData[keyframe2].time - pathData[keyframe1].time
    local alpha = (timeDiff > 0) and math_clamp((currentTime - pathData[keyframe1].time) / timeDiff, 0, 1) or 0
    
    return keyframe1, keyframe2, alpha
end

-- =============================================================================
-- Core Logic Functions
-- =============================================================================

-- Menghentikan dan mereset semua status auto-walk
local function stopAndResetAutoWalk()
    isPathPlaying = false
    isPathPaused = false
    timePaused = 0
    totalTimeElapsed = 0
    timeStarted = 0
    if pathPlaybackConnection then
        pathPlaybackConnection:Disconnect()
        pathPlaybackConnection = nil
    end
end

-- Memainkan path yang direkam dari data JSON
local function playRecordedPath(pathData, onCompleteCallback)
    if not pathData or #pathData == 0 then
        warn("No path data to play!")
        if onCompleteCallback then onCompleteCallback() end
        return
    end

    if isPathPlaying then stopAndResetAutoWalk() end

    isPathPlaying = true
    isPathPaused = false
    timePaused = 0
    totalTimeElapsed = 0
    timeStarted = tick()
    
    local wasJumping = false
    
    -- Teleport ke titik awal path
    local startFrame = pathData[1]
    if Character and HumanoidRootPart then
        local startPosition = tableToVector3(startFrame.position)
        local startRotation = startFrame.rotation or 0
        local startCFrame = CFrame.new(startPosition) * CFrame.Angles(0, startRotation, 0)
        HumanoidRootPart.CFrame = startCFrame
        HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
        HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
        if Humanoid then
            Humanoid:Move(tableToVector3(startFrame.moveDirection or {x=0, y=0, z=0}), false)
        end
    end
    
    -- Koneksi Heartbeat untuk memproses setiap frame
    pathPlaybackConnection = RunService.Heartbeat:Connect(function(deltaTime)
        if not isPathPlaying then return end
        
        if isPathPaused then
            if timePaused == 0 then timePaused = tick() end
            timeStarted = tick()
            return
        elseif timePaused > 0 then
            timeStarted = tick()
            timePaused = 0
        end

        if not Character or not HumanoidRootPart then return end
        if not Humanoid or Humanoid.Parent ~= Character then
            Humanoid = Character:FindFirstChild("Humanoid")
        end

        totalTimeElapsed = tick() - timeStarted
        
        local totalPathDuration = pathData[#pathData].time
        if totalTimeElapsed > totalPathDuration then
            -- Selesaikan di frame terakhir
            local endFrame = pathData[#pathData]
            if Character and HumanoidRootPart then
                HumanoidRootPart.CFrame = CFrame.new(tableToVector3(endFrame.position)) * CFrame.Angles(0, endFrame.rotation or 0, 0)
                if Humanoid then Humanoid:Move(tableToVector3(endFrame.moveDirection or {x=0, y=0, z=0}), false) end
            end
            stopAndResetAutoWalk()
            if onCompleteCallback then onCompleteCallback() end
            return
        end

        local index1, index2, alpha = findKeyframes(pathData, totalTimeElapsed)
        local frame1, frame2 = pathData[index1], pathData[index2]

        if not frame1 or not frame2 then return end

        -- Interpolasi data antar frame
        local currentPosition = lerpVector3(tableToVector3(frame1.position), tableToVector3(frame2.position), alpha)
        local currentVelocity = lerpVector3(tableToVector3(frame1.velocity or {x=0,y=0,z=0}), tableToVector3(frame2.velocity or {x=0,y=0,z=0}), alpha)
        local currentMoveDir = lerpVector3(tableToVector3(frame1.moveDirection or {x=0,y=0,z=0}), tableToVector3(frame2.moveDirection or {x=0,y=0,z=0}), alpha)
        local currentRotation = slerpAngle(frame1.rotation or 0, frame2.rotation or 0, alpha)

        -- Terapkan ke karakter
        local targetCFrame = CFrame.new(currentPosition) * CFrame.Angles(0, currentRotation, 0)
        local lerpAlpha = math_clamp(1 - math_exp(-10 * deltaTime), 0, 1)
        HumanoidRootPart.CFrame = HumanoidRootPart.CFrame:Lerp(targetCFrame, lerpAlpha)
        pcall(function() HumanoidRootPart.AssemblyLinearVelocity = currentVelocity end)
        
        if Humanoid then
            Humanoid:Move(currentMoveDir, false)
            local isJumping = frame1.jumping or frame2.jumping
            if isJumping and not wasJumping then
                Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
            wasJumping = isJumping
        end
    end)
end

-- Mulai auto-walk otomatis dari awal sampai akhir
local function startAutomaticWalk()
    currentCheckpointIndex = 0
    
    local function walkNextCheckpoint()
        if not isAutoWalkActive then return end
        
        currentCheckpointIndex = currentCheckpointIndex + 1
        if currentCheckpointIndex > #CHECKPOINT_FILES then
            isAutoWalkActive = false
            Rayfield:Notify({ Title = "Auto Walk", Content = "Auto walk selesai! Semua checkpoint sudah dilewati.", Duration = 5, Image = "check-check" })
            return
        end
        
        local fileName = CHECKPOINT_FILES[currentCheckpointIndex]
        local success, _ = ensureJsonFile(fileName)
        
        if not success then
            Rayfield:Notify({ Title = "Error", Content = "Gagal mengunduh: " .. fileName, Duration = 5, Image = "ban" })
            isAutoWalkActive = false
            return
        end
        
        local pathData = loadJsonFile(fileName)
        if pathData and #pathData > 0 then
            Rayfield:Notify({ Title = "Auto Walk (Automatic)", Content = "Menuju checkpoint " .. currentCheckpointIndex, Duration = 2, Image = "bot" })
            task.wait(0.5)
            playRecordedPath(pathData, walkNextCheckpoint)
        else
            Rayfield:Notify({ Title = "Error", Content = "Gagal memuat data: " .. fileName, Duration = 5, Image = "ban" })
            isAutoWalkActive = false
        end
    end
    
    walkNextCheckpoint()
end

-- Mulai auto-walk manual dari checkpoint yang dipilih
local function startManualWalk(fileName)
    isAutoWalkActive = false
    stopAndResetAutoWalk()
    
    local success, _ = ensureJsonFile(fileName)
    if not success then
        Rayfield:Notify({ Title = "Error", Content = "Gagal memastikan file " .. fileName, Duration = 4, Image = "ban" })
        return
    end

    local pathData = loadJsonFile(fileName)
    if not pathData or #pathData == 0 then
        Rayfield:Notify({ Title = "Error", Content = "File path tidak valid atau kosong: " .. fileName, Duration = 4, Image = "ban" })
        return
    end
    
    Rayfield:Notify({ Title = "Auto Walk (Manual)", Content = "Auto walk berhasil dijalankan.", Duration = 3, Image = "bot" })
    playRecordedPath(pathData, function()
        Rayfield:Notify({ Title = "Auto Walk (Manual)", Content = "Auto walk selesai!", Duration = 2, Image = "check-check" })
    end)
end

-- Fungsi untuk mengontrol kecepatan jalan dan lompat player
local function setPlayerMovement(enabled)
    if Humanoid then
        Humanoid.WalkSpeed = enabled and 16 or 0
        Humanoid.JumpPower = enabled and 50 or 0
    end
end

-- Mengaktifkan 'God Mode' (HP tidak berkurang, anti-jatuh)
local function enableGodMode()
    if not Humanoid then return end
    Humanoid.Health = Humanoid.MaxHealth
    
    godModeHealthConnection = Humanoid.HealthChanged:Connect(function()
        if isAutoSummitActive then Humanoid.Health = Humanoid.MaxHealth end
    end)
    
    godModeStateConnection = Humanoid.StateChanged:Connect(function(oldState, newState)
        if isAutoSummitActive and newState == Enum.HumanoidStateType.Freefall then
            Humanoid:ChangeState(Enum.HumanoidStateType.PlatformStanding)
        end
    end)
end

-- Menonaktifkan 'God Mode'
local function disableGodMode()
    if godModeHealthConnection then godModeHealthConnection:Disconnect(); godModeHealthConnection = nil end
    if godModeStateConnection then godModeStateConnection:Disconnect(); godModeStateConnection = nil end
end

-- Fungsi teleport dengan countdown
local function teleportWithCountdown(location, delay, mode)
    for i = delay, 1, -1 do
        if (mode == "auto" and not isAutoSummitActive) or (mode == "manual" and not isAutoSummitManualActive) then
            return false -- Dibatalkan
        end
        Rayfield:Notify({ Title = "Teleport " .. location.Name, Content = "Teleport dalam: " .. i .. " detik", Duration = 1, Image = "timer" })
        task.wait(1)
    end
    
    if Character and HumanoidRootPart then
        HumanoidRootPart.CFrame = CFrame.new(location.X, location.Y + TELEPORT_OFFSET_Y, location.Z)
    end
    
    Rayfield:Notify({ Title = "Teleport " .. location.Name, Content = "Teleport berhasil!", Duration = 2, Image = "circle-check" })
    return true
end

-- =============================================================================
-- UI Setup
-- =============================================================================

-- Inisialisasi Window
local Window = Rayfield:CreateWindow({
    Name = "Hirako | MOUNT STECU",
    Icon = "braces",
    LoadingTitle = "Created By Hirako",
    LoadingSubtitle = "Follow Tiktok: @iskaalwayslose"
})

---
--- TAB: AKUN
---
local AccountTab = Window:CreateTab("Account", "user")
local userToken = getgenv().UserToken or nil
local userData = { username = "Guest", created_at = "N/A", expire_days = 0, last_update = 0 }

local AccountInfoSection = AccountTab:CreateSection("Informasi Akun")
local AccountStatusParagraph = AccountTab:CreateParagraph({
    Title = "📊 Akun Status",
    Content = "🔄 Menginisialisasi...\n⏳ Tunggu sebentar..."
})
local BuyKeyParagraph = AccountTab:CreateParagraph({
    Title = "💡 Ingin beli kunci nya lagi?",
    Content = "Silahkan untuk membuat ticket di discord."
})

local function getExpirationStatus(days)
    if days <= 0 then return { emoji = "🔴", status = "Expire" }
    elseif days <= 1 then return { emoji = "🟠", status = "1 day" }
    elseif days <= 7 then return { emoji = "🟡", status = days .. " days" }
    else return { emoji = "🟢", status = days .. " days" }
    end
end

local function updateAccountInfo()
    if not userToken or userToken == "" then
        AccountStatusParagraph:Set({ Title = "🚫 Error", Content = "- Kamu tidak memiliki token.\n- Silakan lakukan otentikasi terlebih dahulu." })
        return
    end

    AccountStatusParagraph:Set({ Title = "🔄 Memuat Data Akun", Content = "⏳ Menghubungkan ke server..." })
    
    local encodedToken = HttpService:UrlEncode(tostring(userToken))
    local url = API_CONFIG.base_url .. API_CONFIG.get_user_endpoint .. "?token=" .. encodedToken
    local headers = { ["Content-Type"] = "application/json", ["User-Agent"] = "Roblox/WinInet", ["ngrok-skip-browser-warning"] = "true" }
    
    local success, responseBody = makeRequest(url, "GET", nil, headers)
    
    if not success then
        AccountStatusParagraph:Set({ Title = "🚨 Kesalahan Koneksi", Content = "❌ Gagal terhubung ke server.\n\nError: " .. tostring(responseBody) })
        return
    end
    
    local decodeSuccess, data = pcall(function() return HttpService:JSONDecode(responseBody) end)
    
    if not decodeSuccess or not data or type(data) ~= "table" then
        AccountStatusParagraph:Set({ Title = "🔐 Kesalahan Server", Content = "❌ Format respons server tidak valid." })
        return
    end
    
    if data.status ~= "success" then
        local message = tostring(data.message or "Otentikasi gagal")
        AccountStatusParagraph:Set({ Title = "🔐 Otentikasi Gagal", Content = "❌ " .. message })
        return
    end
    
    userData.username = tostring(data.name or "Unknown")
    userData.created_at = tostring(data.created_at or "N/A")
    userData.expire_days = tonumber(data.expire_days) or 0
    userData.role = tostring(data.role or "Member")
    
    local expirationInfo = getExpirationStatus(userData.expire_days)
    local memberSince = userData.created_at:match("(%d+%-%d+%-%d+)") or userData.created_at
    
    AccountStatusParagraph:Set({
        Title = "👨🏻‍💼 Selamat Datang, " .. userData.username,
        Content = s_format("🏷️ Role          : %s\n⏰ Expire        : %s %s\n📅 Member Sejak  : %s", userData.role, expirationInfo.emoji, expirationInfo.status, memberSince)
    })
end

local QuickActionsSection = AccountTab:CreateSection("Aksi Cepat")
AccountTab:CreateButton({ Name = "🔄 Refresh Informasi Akun", Callback = function() userToken = getgenv().UserToken; updateAccountInfo() end })
AccountTab:CreateButton({
    Name = "🛒 Beli Kunci",
    Callback = function()
        local discordLink = "https://discord.gg/KEajwZQaRd"
        if setclipboard then
            setclipboard(discordLink)
            Rayfield:Notify({ Title = "📋 Link Disalin!", Content = "Link Discord telah disalin.", Duration = 4 })
        else
            Rayfield:Notify({ Title = "🌐 Link Discord", Content = discordLink, Duration = 5 })
        end
    end
})

---
--- TAB: AUTO WALK
---
local AutoWalkTab = Window:CreateTab("Auto Walk", "bot")
AutoWalkTab:CreateSection("Informasi")
AutoWalkTab:CreateParagraph({
    Title = "Keterangan !!!",
    Content = "- Auto Walk (Settings)\nJeda atau lanjutkan Auto Walk yang sedang berjalan.\n\n- Auto Walk (Automatic)\nMenjalankan Auto Walk dari awal hingga akhir.\n\n- Auto Walk (Manual)\nPilih titik awal untuk memulai Auto Walk.\n\n⚠️ Catatan:\nAktifkan hanya satu mode (Automatic atau Manual) untuk menghindari bug."
})

local AutoWalkSettingsSection = AutoWalkTab:CreateSection("Auto Walk (Settings)")
AutoWalkSettingsSection:CreateButton({
    Name = "⏸️ Jeda (Auto Walk)",
    Callback = function()
        if not isPathPlaying then
            Rayfield:Notify({ Title = "Auto Walk", Content = "Tidak ada auto walk yang berjalan.", Duration = 3, Image = "pause" })
            return
        end
        if isPathPaused then
            Rayfield:Notify({ Title = "Auto Walk", Content = "Auto walk sudah dijeda.", Duration = 2, Image = "pause" })
            return
        end
        isPathPaused = true
        Rayfield:Notify({ Title = "Auto Walk", Content = "Berhasil dijeda.", Duration = 2, Image = "pause" })
    end
})
AutoWalkSettingsSection:CreateButton({
    Name = "▶️ Lanjutkan (Auto Walk)",
    Callback = function()
        if not isPathPlaying then
            Rayfield:Notify({ Title = "Auto Walk", Content = "Tidak ada auto walk yang berjalan.", Duration = 3, Image = "play" })
            return
        end
        if not isPathPaused then
            Rayfield:Notify({ Title = "Auto Walk", Content = "Auto walk sedang berjalan.", Duration = 2, Image = "play" })
            return
        end
        isPathPaused = false
        Rayfield:Notify({ Title = "Auto Walk", Content = "Berhasil dilanjutkan.", Duration = 2, Image = "play" })
    end
})

local AutoWalkAutomaticSection = AutoWalkTab:CreateSection("Auto Walk (Automatic)")
AutoWalkAutomaticSection:CreateToggle({
    Name = "Auto Walk (Start To End)",
    CurrentValue = false,
    Callback = function(value)
        if value then
            isAutoWalkActive = true
            startAutomaticWalk()
        else
            isAutoWalkActive = false
            stopAndResetAutoWalk()
        end
    end
})

local AutoWalkManualSection = AutoWalkTab:CreateSection("Auto Walk (Manual)")
for i, fileName in ipairs(CHECKPOINT_FILES) do
    local toggleName = "Auto Walk (" .. (i == 1 and "Spawnpoint" or "Checkpoint " .. i - 1) .. ")"
    AutoWalkManualSection:CreateToggle({
        Name = toggleName,
        CurrentValue = false,
        Callback = function(value)
            if value then
                startManualWalk(fileName)
            else
                stopAndResetAutoWalk()
            end
        end
    })
end

---
--- TAB: AUTO SUMMIT
---
local AutoSummitTab = Window:CreateTab("Auto Summit", "flag")

-- Data lokasi checkpoint
local SUMMIT_LOCATIONS = {
    { Name = "Spawnpoint", X = 2269.61, Y = 805, Z = -2325.9 },
    { Name = "Checkpoint 1", X = 1707.53, Y = 778.17, Z = -2318.39 },
    { Name = "Checkpoint 2", X = 1268.03, Y = 778.56, Z = -2293.63 },
    { Name = "Checkpoint 3", X = 975.94, Y = 794.55, Z = -2095.81 },
    { Name = "Checkpoint 4", X = 1286.09, Y = 769.83, Z = -1751.06 },
    { Name = "Checkpoint 5", X = 2228.66, Y = 776.5, Z = -1384.23 },
    { Name = "Checkpoint 6", X = 2012.39, Y = 506.56, Z = -785.76 },
    { Name = "Checkpoint 7", X = 1100.82, Y = 514.56, Z = -1080.58 },
    { Name = "Checkpoint 8", X = 805.16, Y = 409.31, Z = -963.94 },
    { Name = "Checkpoint 9", X = 760.19, Y = 394.33, Z = -1166.98 },
    { Name = "Checkpoint 10", X = 216.41, Y = 388.7, Z = -1251.38 },
    { Name = "Checkpoint 11", X = 41.22, Y = 410.56, Z = -1532.51 },
    { Name = "Checkpoint 12", X = 18.46, Y = 538.49, Z = -1786.04 },
    { Name = "Checkpoint 13", X = -438.28, Y = 561.95, Z = -2165.36 },
    { Name = "Checkpoint 14", X = -1013.82, Y = 352.98, Z = -1913.11 },
    { Name = "Checkpoint 15", X = -1418.13, Y = 380.77, Z = -1861.31 },
    { Name = "Checkpoint 16", X = -1463.82, Y = 502.47, Z = -1783.54 },
    { Name = "Checkpoint 17", X = -1691.18, Y = 546.5, Z = -1781.49 },
    { Name = "Checkpoint 18", X = -2085.03, Y = 546.99, Z = -2033.55 },
    { Name = "Checkpoint 19", X = -2284.83, Y = 675.05, Z = -1831.06 },
    { Name = "Checkpoint 20", X = -1994.56, Y = 768.28, Z = -1487.71 },
    { Name = "Checkpoint 21", X = -1476.51, Y = 865.36, Z = -919.19 },
    { Name = "Checkpoint 22", X = -1259.77, Y = 857.76, Z = -777 },
    { Name = "Checkpoint 23", X = -737.19, Y = 1092.49, Z = -473.89 },
    { Name = "Checkpoint 24", X = -308.05, Y = 1309.97, Z = -326.06 },
    { Name = "Checkpoint 25", X = -93.53, Y = 1545.86, Z = 128.18 },
    { Name = "Puncak Mount Stecu", X = -257.35, Y = 1756.5, Z = 767.79 }
}

AutoSummitTab:CreateSection("Informasi")
AutoSummitTab:CreateParagraph({
    Title = "Keterangan !!!",
    Content = "- Auto Summit (Automatic)\nMenjalankan teleportasi otomatis dari awal hingga puncak.\n\n- Auto Summit (Manual)\nPilih checkpoint untuk memulai teleportasi secara manual.\n\n⚠️ Catatan:\nGunakan hanya salah satu mode untuk menghindari bug."
})

local AutoSummitAutomaticSection = AutoSummitTab:CreateSection("Auto Summit (Automatic)")
AutoSummitAutomaticSection:CreateToggle({
    Name = "Auto Summit (Start To End)",
    CurrentValue = false,
    Callback = function(value)
        isAutoSummitActive = value
        if isAutoSummitActive then
            task.spawn(function()
                setPlayerMovement(false)
                enableGodMode()
                while isAutoSummitActive do
                    for _, location in ipairs(SUMMIT_LOCATIONS) do
                        if not teleportWithCountdown(location, autoSummitDelay, "auto") then break end
                    end
                    if not isAutoSummitActive then break end
                    Rayfield:Notify({ Title = "Auto Summit (Automatic)", Content = "Auto summit selesai, mengulang.", Duration = 3, Image = "check-check" })
                    task.wait(1)
                end
                setPlayerMovement(true)
                disableGodMode()
            end)
        else
            setPlayerMovement(true)
            disableGodMode()
        end
    end
})
AutoSummitAutomaticSection:CreateSlider({
    Name = "Setting Speed (Automatic)",
    Range = {1, 10},
    Increment = 1,
    Suffix = "Detik",
    CurrentValue = 3,
    Callback = function(value) autoSummitDelay = value end
})

local AutoSummitManualSection = AutoSummitTab:CreateSection("Auto Summit (Manual)")
local isAutoSummitManualActive = false
local checkpointNames = {}
for _, loc in ipairs(SUMMIT_LOCATIONS) do table.insert(checkpointNames, loc.Name) end

AutoSummitManualSection:CreateDropdown({
    Name = "Pilih Checkpoint",
    Options = checkpointNames,
    CurrentOption = checkpointNames[1],
    Callback = function(option)
        for i, loc in ipairs(SUMMIT_LOCATIONS) do
            if loc.Name == option then
                selectedCheckpointIndex = i
                break
            end
        end
        Rayfield:Notify({ Title = "Auto Summit (Manual)", Content = "Dimulai dari: " .. option, Duration = 3, Image = "map-pin" })
    end
})
AutoSummitManualSection:CreateToggle({
    Name = "Mulai Auto Summit (Manual)",
    CurrentValue = false,
    Callback = function(value)
        isAutoSummitManualActive = value
        if isAutoSummitManualActive then
            task.spawn(function()
                setPlayerMovement(false)
                enableGodMode()
                while isAutoSummitManualActive do
                    for i = selectedCheckpointIndex, #SUMMIT_LOCATIONS do
                        if not isAutoSummitManualActive then break end
                        local location = SUMMIT_LOCATIONS[i]
                        if not teleportWithCountdown(location, autoSummitManualDelay, "manual") then break end
                    end
                    if not isAutoSummitManualActive then break end
                    selectedCheckpointIndex = 1
                    Rayfield:Notify({ Title = "Auto Summit (Manual)", Content = "Selesai, kembali ke spawnpoint.", Duration = 2, Image = "flags" })
                end
                setPlayerMovement(true)
                disableGodMode()
            end)
        else
            setPlayerMovement(true)
            disableGodMode()
            Rayfield:Notify({ Title = "Auto Summit (Manual)", Content = "Auto summit dibatalkan.", Duration = 1, Image = "ban" })
        end
    end
})
AutoSummitManualSection:CreateSlider({
    Name = "Setting Speed (Manual)",
    Range = {1, 10},
    Increment = 1,
    Suffix = "Detik",
    CurrentValue = 3,
    Callback = function(value) autoSummitManualDelay = value end
})


---
--- TAB: TELEPORT
---
local TeleportTab = Window:CreateTab("Teleport", "layers")
local function simpleTeleport(x, y, z, name)
    if Character and HumanoidRootPart then
        HumanoidRootPart.CFrame = CFrame.new(x, y + TELEPORT_OFFSET_Y, z)
        Rayfield:Notify({ Title = "Teleport", Content = "Berhasil teleport ke " .. name, Duration = 3, Image = "check-check" })
    end
end

TeleportTab:CreateSection("Informasi")
TeleportTab:CreateParagraph({
    Title = "Keterangan !!!",
    Content = "Menu ini akan memindahkanmu ke lokasi yang dipilih secara instan."
})

local ListTeleportSection = TeleportTab:CreateSection("List Semua Checkpoint")
for _, location in ipairs(SUMMIT_LOCATIONS) do
    ListTeleportSection:CreateButton({
        Name = "Teleport (" .. location.Name .. ")",
        Callback = function() simpleTeleport(location.X, location.Y, location.Z, location.Name) end
    })
end

---
--- TAB: UPDATE SCRIPT
---
local UpdateScriptTab = Window:CreateTab("Update Script", "file")
local updateCanceled = {false}

UpdateScriptTab:CreateSection("Update Script Menu")
UpdateScriptTab:CreateParagraph({
    Title = "Keterangan !!!",
    Content = "Gunakan menu ini untuk memperbarui file-file path script secara manual."
})
local fileCheckLabel = UpdateScriptTab:CreateLabel("Memeriksa file...")

UpdateScriptTab:CreateToggle({
    Name = "Mulai Update Script",
    CurrentValue = false,
    Callback = function(value)
        if value then
            isUpdateScriptActive = true
            updateCanceled[1] = false
            task.spawn(function()
                fileCheckLabel:Set("🔄 Proses update file...")
                -- Hapus file lama
                for _, fileName in ipairs(CHECKPOINT_FILES) do
                    local filePath = SUBFOLDER_NAME .. "/" .. fileName
                    if isfile(filePath) then delfile(filePath) end
                end
                -- Unduh file baru
                for i, fileName in ipairs(CHECKPOINT_FILES) do
                    if updateCanceled[1] then break end
                    Rayfield:Notify({ Title = "Update Script", Content = "Proses Update (" .. i .. "/" .. #CHECKPOINT_FILES .. ")", Duration = 2, Image = "file" })
                    local success, content = pcall(function() return game:HttpGet(JSON_BASE_URL .. fileName) end)
                    
                    if success and content and #content > 0 then
                        writefile(SUBFOLDER_NAME .. "/" .. fileName, content)
                        fileCheckLabel:Set("📥 Proses Update: (" .. i .. "/" .. #CHECKPOINT_FILES .. ")")
                    else
                        Rayfield:Notify({ Title = "Update Script", Content = "❌ Update script gagal", Duration = 3, Image = "file" })
                        fileCheckLabel:Set("❌ Gagal: (" .. i .. "/" .. #CHECKPOINT_FILES .. ")")
                    end
                    task.wait(0.3)
                end
                
                if not updateCanceled[1] then
                    Rayfield:Notify({ Title = "Update Script", Content = "Berhasil!", Duration = 5, Image = "4483362458" })
                else
                    Rayfield:Notify({ Title = "Update Script", Content = "❌ Update dibatalkan", Duration = 3, Image = "4483362458" })
                end
                
                -- Verifikasi ulang file setelah update
                for i, fileName in ipairs(CHECKPOINT_FILES) do
                    local success, _ = ensureJsonFile(fileName)
                    fileCheckLabel:Set((success and "✔ Cek File: " or "❌ Gagal: ") .. "(" .. i .. "/" .. #CHECKPOINT_FILES .. ")")
                    task.wait(0.3)
                end
                fileCheckLabel:Set("✔ Semua file aman")
            end)
        else
            isUpdateScriptActive = false
            updateCanceled[1] = true
        end
    end
})

---
--- TAB: CREDITS
---
local CreditsTab = Window:CreateTab("Credits", "scroll-text")
local CreditsSection = CreditsTab:CreateSection("Credits List")
CreditsSection:CreateLabel("UI: Rayfield Interface")
CreditsSection:CreateLabel("Dev: Hirako")

-- =============================================================================
-- Inisialisasi & Event Connections
-- =============================================================================

-- Pastikan folder ada
if not isfolder(FOLDER_NAME) then makefolder(FOLDER_NAME) end
if not isfolder(SUBFOLDER_NAME) then makefolder(SUBFOLDER_NAME) end

-- Handle saat karakter respawn
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = newCharacter:WaitForChild("Humanoid")
    HumanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart")
    if isPathPlaying then stopAndResetAutoWalk() end
end)

-- Verifikasi file saat skrip dijalankan
task.spawn(function()
    for i, fileName in ipairs(CHECKPOINT_FILES) do
        local success, _ = ensureJsonFile(fileName)
        fileCheckLabel:Set((success and "✔ Proses Cek File: " or "❌ Gagal: ") .. "(" .. i .. "/" .. #CHECKPOINT_FILES .. ")")
        task.wait(0.1) -- Sedikit lebih cepat untuk initial check
    end
    fileCheckLabel:Set("✔ Semua file aman")
end)

-- Muat informasi akun saat skrip dijalankan
task.spawn(function()
    task.wait(2)
    updateAccountInfo()
end)