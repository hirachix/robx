
-- Basic helpers
local toChar = string.char
local toByte = string.byte
local subStr = string.sub
local bitLib = bit32 or bit
local xorFunc = bitLib.bxor
local tableConcat = table.concat
local tableInsert = table.insert

-- XOR decode helper (if needed by the script)
local function xorDecode(dataStr, keyStr)
    local out = {}
    for i = 1, #dataStr do
        tableInsert(out,
            toChar(
                xorFunc(
                    toByte(subStr(dataStr, i, i + 1)),
                    toByte(subStr(keyStr, 1 + (i % #keyStr), 1 + (i % #keyStr) + 1))
                ) % 256
            )
        )
    end
    return tableConcat(out)
end

-- Load UI library (Rayfield)
local UILibrary = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/fachriaziz/rayfield/refs/heads/main/rayfield.lua"
))()

-- Create window and tabs
local MainWindow = UILibrary:CreateWindow({
    ["Name"] = "IM HIRAKO | MOUNT YAHAYUK",
    ["Icon"] = "braces",
    ["LoadingTitle"] = "Created By Hirakoxs",
    ["LoadingSubtitle"] = "Follow Tiktok: @iskaalwayslose"
})

local AccountTab = MainWindow:CreateTab("Account", "user")
local AutoWalkTab = MainWindow:CreateTab("Auto Walk", "bot")
local TeleportTab = MainWindow:CreateTab("Teleport", "layers")
local UpdateTab = MainWindow:CreateTab("Update Script", "file")
local CreditsTab = MainWindow:CreateTab("Credits", "scroll-text")

-- Services & player refs
local PlayersService = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = PlayersService.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local Clipboard = setclipboard or toclipboard

-- API config
local APIConfig = {
    base_url = "https://monotonal-unhoneyed-rita.ngrok-free.dev",
    get_user_endpoint = "/get_user.php"
}

-- HTTP request helper with fallbacks
local function HttpRequestHelper(url, method, body, headers)
    method = method or "GET"
    local requestData = { Url = url, Method = method }

    if headers then requestData.Headers = headers end
    if (body and (method == "POST")) then requestData.Body = body end

    local ok, resp = pcall(function() return HttpService:RequestAsync(requestData) end)
    if ok and resp and resp.Success and (resp.StatusCode == 200) then
        return true, resp.Body
    end

    if method == "GET" then
        local ok2, res2 = pcall(function() return HttpService:GetAsync(url, false) end)
        if ok2 and res2 then return true, res2 end

        local ok3, res3 = pcall(function() return game:HttpGet(url) end)
        if ok3 and res3 then return true, res3 end
    end

    return false, tostring(resp)
end

-- Token & user data
local UserToken = getgenv().UserToken or nil
local UserData = { username = "Guest", role = "Member", expire_timestamp = os.time() }

-- Account UI
local AccountSection = AccountTab:CreateSection("Informasi Akun")
local AccountStatusParagraph = AccountTab:CreateParagraph({
    ["Title"] = "📊 Akun Status",
    ["Content"] = "🔄 Menginisialisasi...\n⏳ Tunggu sebentar..."
})
local PurchaseParagraph = AccountTab:CreateParagraph({
    ["Title"] = "💡 Ingin beli kunci nya lagi?",
    ["Content"] = "Silahkan untuk membuat ticket di discord"
})

-- format seconds to readable string
local function formatTime(seconds)
    if seconds <= 0 then return "Expired" end
    local d = math.floor(seconds / 86400)
    local h = math.floor((seconds % 86400) / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = math.floor(seconds % 60)
    return string.format("%d Hari | %02d Jam | %02d Menit | %02d Detik", d, h, m, s)
end

-- return icon + formatted remaining
local function statusIconForTimestamp(timestamp)
    local remain = timestamp - os.time()
    local icon = "🟢"
    if remain <= 0 then
        icon = "🔴"
        return icon, "Expired"
    elseif remain <= 86400 then
        icon = "🟠"
    elseif remain <= 259200 then
        icon = "🟠"
    end
    return icon, formatTime(remain)
end

-- load user account from server
local function loadAccountData()
    if (not UserToken or (UserToken == "")) then
        AccountStatusParagraph:Set({
            ["Title"] = "🚫 Error",
            ["Content"] = "- Kamu tidak memiliki token.\n- Silakan lakukan otentikasi terlebih dahulu di tab otentikasi."
        })
        return
    end

    AccountStatusParagraph:Set({
        ["Title"] = "🔄 Muat Data Akun",
        ["Content"] = "⏳ Menghubungkan ke server...\n📡 Mendapatkan informasi akun Anda..."
    })

    local tokenEncoded = HttpService:UrlEncode(tostring(UserToken))
    local url = APIConfig.base_url .. APIConfig.get_user_endpoint .. "?token=" .. tokenEncoded
    local headers = {
        ["Content-Type"] = "application/json",
        ["User-Agent"] = "Roblox/WinInet",
        ["ngrok-skip-browser-warning"] = "true"
    }

    local ok, body = HttpRequestHelper(url, "GET", nil, headers)
    if not ok then
        AccountStatusParagraph:Set({
            ["Title"] = "🚨 Connection Error",
            ["Content"] = "❌ Failed to connect to server.\n🌐 Please check your internet connection.\n\nError: " .. tostring(body)
        })
        return
    end

    local decodeOk, decoded = pcall(function() return HttpService:JSONDecode(body) end)
    if (not decodeOk or (type(decoded) ~= "table")) then
        AccountStatusParagraph:Set({
            ["Title"] = "🔐 Server Error",
            ["Content"] = "❌ Invalid server response format.\n🛠️ Please try again later."
        })
        return
    end

    if (decoded.status ~= "success") then
        local msg = tostring(decoded.message or "Authentication failed")
        AccountStatusParagraph:Set({
            ["Title"] = "🔐 Authentication Failed",
            ["Content"] = "❌ " .. msg .. "\n🔄 Please re-authenticate di tab Authentication."
        })
        return
    end

    -- set user data
    UserData.username = tostring(decoded.name or "Unknown")
    UserData.role = tostring(decoded.role or "Member")
    UserData.expire_timestamp = tonumber(decoded.expire_timestamp) or (os.time() + 86400)

    -- update UI each heartbeat
    RunService.Heartbeat:Connect(function()
        local icon, txt = statusIconForTimestamp(UserData.expire_timestamp)
        AccountStatusParagraph:Set({
            ["Title"] = "👨🏻‍💼 Welcome, " .. UserData.username,
            ["Content"] = string.format("🏷️ Role         : %s\n⏰ Expire       : %s %s", UserData.role, icon, txt)
        })
    end)
end

-- Quick actions
local QuickActionsSection = AccountTab:CreateSection("Quick Actions")
AccountTab:CreateButton({
    ["Name"] = "🔄 Refresh Informasi Akun",
    ["Callback"] = function()
        UserToken = getgenv().UserToken
        loadAccountData()
    end
})

AccountTab:CreateButton({
    ["Name"] = "🛒 Klik disini untuk membeli kunci",
    ["Callback"] = function()
        local discordLink = "https://discord.gg/KEajwZQaRd"
        if Clipboard then
            Clipboard(discordLink)
            UILibrary:Notify({
                ["Title"] = "📋 Link Copied!",
                ["Content"] = "Link Discord disalin ke clipboard.\nJoin Hirakoxs Discord server",
                ["Duration"] = 4
            })
        else
            UILibrary:Notify({
                ["Title"] = "🌐 Discord Link",
                ["Content"] = discordLink .. "\nJoin Hirakoxs Discord server",
                ["Duration"] = 5
            })
        end
    end
})

-- auto-load account info shortly after start
task.spawn(function()
    task.wait(2)
    loadAccountData()
end)

-- ======================================
-- File & AutoWalk data setup
-- ======================================
local DownloadFolder = "RullzsyHUB"
local JsonFolder = DownloadFolder .. "/json_mt_yahayuk"
if not isfolder(DownloadFolder) then makefolder(DownloadFolder) end
if not isfolder(JsonFolder) then makefolder(JsonFolder) end

local RawJsonBaseUrl = "https://raw.githubusercontent.com/RullzsyHUB/roblox-scripts-json/refs/heads/main/json_mt_yahayuk/"
local Checkpoints = {
    "spawnpoint.json", "checkpoint_1.json", "checkpoint_2.json",
    "checkpoint_3.json", "checkpoint_4.json", "checkpoint_5.json"
}

-- Auto Walk state vars
local isPlaying = false         -- whether playback is active
local heartbeatConn = nil       -- RunService connection for playback
local autoWalkRunning = false   -- auto walk mode running
local currentIndex = 0          -- index used in automatic/manual loops
local isPaused = false
local accumDelta = 0
local pauseStart = 0
local lastTick = 0
local elapsedTime = 0
local loopingEnabled = false
local manualMode = false

-- Vector/table helpers
local function vecTableFromVector3(v3)
    return { x = v3.X, y = v3.Y, z = v3.Z }
end

local function vector3FromTable(t)
    return Vector3.new(t.x, t.y, t.z)
end

local function lerpNumber(a, b, t) return a + ((b - a) * t) end

local function lerpVector3(aVec, bVec, t)
    return Vector3.new(
        lerpNumber(aVec.X, bVec.X, t),
        lerpNumber(aVec.Y, bVec.Y, t),
        lerpNumber(aVec.Z, bVec.Z, t)
    )
end

-- shortest angle interpolation (handles wraparound)
local function lerpAngle(a, b, t)
    local delta = b - a
    while delta > math.pi do delta = delta - (2 * math.pi) end
    while delta < -math.pi do delta = delta + (2 * math.pi) end
    return a + (delta * t)
end

-- ensure file exists locally; if not, download and write
local function ensureFile(filename)
    local path = JsonFolder .. "/" .. filename
    if isfile(path) then return true, path end

    local ok, contents = pcall(function() return game:HttpGet(RawJsonBaseUrl .. filename) end)
    if ok and contents and (#contents > 0) then
        writefile(path, contents)
        return true, path
    end

    return false, nil
end

-- load and parse json file
local function loadJsonFile(filename)
    local path = JsonFolder .. "/" .. filename
    if not isfile(path) then
        warn("File not found:", path)
        return nil
    end

    local ok, parsed = pcall(function()
        local raw = readfile(path)
        if (not raw or (raw == "")) then error("Empty file") end
        return HttpService:JSONDecode(raw)
    end)

    if ok and parsed then
        return parsed
    else
        warn("❌ Load error for", filename, ":", parsed)
        return nil
    end
end

-- find interpolation indices & alpha for given time (binary-search style)
local function findInterpolationIndices(frames, ttime)
    if (#frames == 0) then return nil, nil, 0 end
    if (ttime <= frames[1].time) then return 1, 1, 0 end
    if (ttime >= frames[#frames].time) then return #frames, #frames, 0 end

    local lo, hi = 1, #frames
    while lo < (hi - 1) do
        local mid = math.floor((lo + hi) / 2)
        if (frames[mid].time <= ttime) then
            lo = mid
        else
            hi = mid
        end
    end

    local aIdx, bIdx = lo, hi
    local dt = frames[bIdx].time - frames[aIdx].time
    local alpha = ((dt > 0) and math.clamp((ttime - frames[aIdx].time) / dt, 0, 1)) or 0
    return aIdx, bIdx, alpha
end

-- stop playback & cleanup
local function stopPlayback()
    isPlaying = false
    isPaused = false
    accumDelta = 0
    elapsedTime = 0
    lastTick = 0
    if heartbeatConn then
        heartbeatConn:Disconnect()
        heartbeatConn = nil
    end
end

-- core playback engine: framesData = array of frames, onComplete = optional callback
local function playData(framesData, onComplete)
    if (not framesData or (#framesData == 0)) then
        warn("No data to play!")
        if onComplete then onComplete() end
        return
    end

    if isPlaying then stopPlayback() end

    isPlaying = true
    isPaused = false
    accumDelta = 0
    elapsedTime = 0
    lastTick = tick()
    local wasJumping = false

    if heartbeatConn then
        heartbeatConn:Disconnect()
        heartbeatConn = nil
    end

    local firstFrame = framesData[1]

    -- snap character to first frame
    if (Character and Character:FindFirstChild("HumanoidRootPart")) then
        local root = Character.HumanoidRootPart
        local firstPos = vector3FromTable(firstFrame.position)
        local firstRot = firstFrame.rotation or 0
        local snapCFrame = CFrame.new(firstPos) * CFrame.Angles(0, firstRot, 0)
        root.CFrame = snapCFrame
        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        if Humanoid then Humanoid:Move(vector3FromTable(firstFrame.moveDirection or { x = 0, y = 0, z = 0 }), false) end
    end

    -- heartbeat-driven interpolation
    heartbeatConn = RunService.Heartbeat:Connect(function(dt)
        if not isPlaying then return end

        -- paused handling
        if isPaused then
            if (pauseStart == 0) then pauseStart = tick() end
            lastTick = tick()
            return
        elseif (pauseStart > 0) then
            accumDelta = accumDelta + (tick() - pauseStart)
            pauseStart = 0
            lastTick = tick()
        end

        if (not Character or not Character:FindFirstChild("HumanoidRootPart")) then return end
        if (not Humanoid or (Humanoid.Parent ~= Character)) then Humanoid = Character:FindFirstChild("Humanoid") end

        local nowTick = tick()
        local elapsed = nowTick - lastTick
        lastTick = nowTick
        elapsed = math.min(elapsed, 0.1)
        elapsedTime = elapsedTime + elapsed

        local endTime = framesData[#framesData].time
        if (elapsedTime > endTime) then
            -- snap to last frame at end
            local lastFrame = framesData[#framesData]
            if (Character and Character:FindFirstChild("HumanoidRootPart")) then
                local root = Character.HumanoidRootPart
                local pos = vector3FromTable(lastFrame.position)
                local rot = lastFrame.rotation or 0
                local finalCFrame = CFrame.new(pos) * CFrame.Angles(0, rot, 0)
                root.CFrame = finalCFrame
                if Humanoid then Humanoid:Move(vector3FromTable(lastFrame.moveDirection or { x = 0, y = 0, z = 0 }), false) end
            end

            stopPlayback()
            if onComplete then onComplete() end
            return
        end

        -- interpolation between frames
        local aIdx, bIdx, alpha = findInterpolationIndices(framesData, elapsedTime)
        local frameA, frameB = framesData[aIdx], framesData[bIdx]
        if (not frameA or not frameB) then return end

        local posA = vector3FromTable(frameA.position)
        local posB = vector3FromTable(frameB.position)
        local velA = vector3FromTable(frameA.velocity or { x = 0, y = 0, z = 0 })
        local velB = vector3FromTable(frameB.velocity or { x = 0, y = 0, z = 0 })
        local moveA = vector3FromTable(frameA.moveDirection or { x = 0, y = 0, z = 0 })
        local moveB = vector3FromTable(frameB.moveDirection or { x = 0, y = 0, z = 0 })
        local rotA = frameA.rotation or 0
        local rotB = frameB.rotation or 0

        local interpPos = lerpVector3(posA, posB, alpha)
        local interpVel = lerpVector3(velA, velB, alpha)
        local interpMove = lerpVector3(moveA, moveB, alpha)
        local interpRot = lerpAngle(rotA, rotB, alpha)

        local rootPart = Character.HumanoidRootPart
        local targetCFrame = CFrame.new(interpPos) * CFrame.Angles(0, interpRot, 0)
        local lerpFactor = math.clamp(1 - math.exp(-10 * elapsed), 0, 1)
        rootPart.CFrame = rootPart.CFrame:Lerp(targetCFrame, lerpFactor)

        pcall(function() rootPart.AssemblyLinearVelocity = interpVel end)
        if Humanoid then Humanoid:Move(interpMove, false) end

        local isJumpingNow = frameA.jumping or false
        if frameB.jumping then isJumpingNow = true end
        if (isJumpingNow and not wasJumping) then
            if Humanoid then Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
        wasJumping = isJumpingNow
    end)
end

-- automatic sequence runner
local function startAutomaticWalk()
    currentIndex = 0

    local function step()
        if not autoWalkRunning then return end
        currentIndex = currentIndex + 1

        if (currentIndex > #Checkpoints) then
            if loopingEnabled then
                UILibrary:Notify({
                    ["Title"] = "Auto Walk",
                    ["Content"] = "Semua checkpoint selesai! Looping dari awal...",
                    ["Duration"] = 3,
                    ["Image"] = "repeat"
                })
                task.wait(1)
                startAutomaticWalk()
            else
                autoWalkRunning = false
                UILibrary:Notify({
                    ["Title"] = "Auto Walk",
                    ["Content"] = "Auto walk selesai! Semua checkpoint sudah dilewati.",
                    ["Duration"] = 5,
                    ["Image"] = "check-check"
                })
            end
            return
        end

        local filename = Checkpoints[currentIndex]
        local okEnsure = ensureFile(filename)
        if not okEnsure then
            UILibrary:Notify({ ["Title"] = "Error", ["Content"] = "Failed to download: " .. tostring(filename), ["Duration"] = 5, ["Image"] = "ban" })
            autoWalkRunning = false
            return
        end

        local data = loadJsonFile(filename)
        if (data and (#data > 0)) then
            UILibrary:Notify({ ["Title"] = "Auto Walk (Automatic)", ["Content"] = "Auto walk berhasil di jalankan", ["Duration"] = 2, ["Image"] = "bot" })
            task.wait(0.5)
            playData(data, step)
        else
            UILibrary:Notify({ ["Title"] = "Error", ["Content"] = "Error loading: " .. filename, ["Duration"] = 5, ["Image"] = "ban" })
            autoWalkRunning = false
        end
    end

    step()
end

-- manual runner starting from index
local function startManualWalk(startIdx)
    currentIndex = startIdx - 1
    manualMode = true
    autoWalkRunning = true

    local function step()
        if not autoWalkRunning then return end
        currentIndex = currentIndex + 1

        if (currentIndex > #Checkpoints) then
            if loopingEnabled then
                UILibrary:Notify({
                    ["Title"] = "Auto Walk (Manual)",
                    ["Content"] = "Checkpoint terakhir selesai! Looping dari spawnpoint...",
                    ["Duration"] = 3,
                    ["Image"] = "repeat"
                })
                task.wait(1)
                currentIndex = 0
                step()
            else
                autoWalkRunning = false
                manualMode = false
                UILibrary:Notify({ ["Title"] = "Auto Walk (Manual)", ["Content"] = "Auto walk selesai!", ["Duration"] = 2, ["Image"] = "check-check" })
            end
            return
        end

        local filename = Checkpoints[currentIndex]
        local okEnsure = ensureFile(filename)
        if not okEnsure then
            UILibrary:Notify({ ["Title"] = "Error", ["Content"] = "Failed to download checkpoint", ["Duration"] = 5, ["Image"] = "ban" })
            autoWalkRunning = false
            manualMode = false
            return
        end

        local data = loadJsonFile(filename)
        if (data and (#data > 0)) then
            task.wait(0.5)
            playData(data, step)
        else
            UILibrary:Notify({ ["Title"] = "Error", ["Content"] = "Error loading: " .. filename, ["Duration"] = 5, ["Image"] = "ban" })
            autoWalkRunning = false
            manualMode = false
        end
    end

    step()
end

-- convenience to ensure a file then play it
local function startPlaybackForFile(filename, startIndex)
    if loopingEnabled then
        stopPlayback()
        startManualWalk(startIndex)
        return
    end

    autoWalkRunning = false
    manualMode = false
    stopPlayback()

    local okEnsure = ensureFile(filename)
    if not okEnsure then
        UILibrary:Notify({ ["Title"] = "Error", ["Content"] = "Failed to ensure", ["Duration"] = 4, ["Image"] = "ban" })
        return
    end

    local data = loadJsonFile(filename)
    if (not data or (#data == 0)) then
        UILibrary:Notify({ ["Title"] = "Error", ["Content"] = "File invalid", ["Duration"] = 4, ["Image"] = "ban" })
        return
    end

    UILibrary:Notify({ ["Title"] = "Auto Walk (Manual)", ["Content"] = "Auto walk berhasil di jalankan", ["Duration"] = 3, ["Image"] = "bot" })
    playData(data, function()
        UILibrary:Notify({ ["Title"] = "Auto Walk (Manual)", ["Content"] = "Auto walk selesai!", ["Duration"] = 2, ["Image"] = "check-check" })
    end)
end

-- refresh character refs on respawn
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = Character:WaitForChild("Humanoid")
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    if isPlaying then stopPlayback() end
end)

-- ======================================
-- Auto Walk UI
-- ======================================
AutoWalkTab:CreateSection("Informasi")
AutoWalkTab:CreateParagraph({
    ["Title"] = "Keterangan !!!",
    ["Content"] = "- Auto Walk (Settings)\nPada menu ini kamu dapat menjeda Auto Walk yang sedang berjalan atau melanjutkannya kembali.\n\n- Auto Walk (Looping)\nAktifkan fitur looping untuk mengulangi auto walk secara otomatis setelah mencapai checkpoint terakhir.\n\n- Auto Walk (Automatic)\nPada menu ini kamu bisa menjalankan Auto Walk secara otomatis, mulai dari spawnpoint hingga checkpoint terakhir.\n\n- Auto Walk (Manual)\nPada menu ini kamu dapat memilih dari titik mana Auto Walk akan dimulai.\n\n⚠️ Catatan:\nAktifkan hanya salah satu menu (Automatic atau Manual). Menyalakan lebih dari satu auto walk sekaligus dapat menyebabkan bug."
})

AutoWalkTab:CreateSection("Auto Walk (Settings)")

AutoWalkTab:CreateButton({
    ["Name"] = "⏸️ Pause (Auto Walk)",
    ["Callback"] = function()
        if not isPlaying then
            UILibrary:Notify({ ["Title"] = "Auto Walk", ["Content"] = "Tidak ada auto walk yang berjalan", ["Duration"] = 3, ["Image"] = "pause" })
            return
        end
        if isPaused then
            UILibrary:Notify({ ["Title"] = "Auto Walk", ["Content"] = "Auto walk sebelum nya sudah di pause", ["Duration"] = 2, ["Image"] = "pause" })
            return
        end
        isPaused = true
        UILibrary:Notify({ ["Title"] = "Auto Walk", ["Content"] = "Behasil di pause", ["Duration"] = 2, ["Image"] = "pause" })
    end
})

AutoWalkTab:CreateButton({
    ["Name"] = "▶️ Resume (Auto Walk)",
    ["Callback"] = function()
        if not isPlaying then
            UILibrary:Notify({ ["Title"] = "Auto Walk", ["Content"] = "Tidak ada auto walk yang berjalan", ["Duration"] = 3, ["Image"] = "play" })
            return
        end
        if not isPaused then
            UILibrary:Notify({ ["Title"] = "Auto Walk", ["Content"] = "Auto walk sedang berjalan", ["Duration"] = 2, ["Image"] = "play" })
            return
        end
        isPaused = false
        UILibrary:Notify({ ["Title"] = "Auto Walk", ["Content"] = "Berhasil di resume", ["Duration"] = 2, ["Image"] = "play" })
    end
})

AutoWalkTab:CreateSection("Auto Walk (Looping)")

AutoWalkTab:CreateToggle({
    ["Name"] = "🔄 Enable Looping",
    ["CurrentValue"] = false,
    ["Callback"] = function(val)
        loopingEnabled = val
        if val then
            UILibrary:Notify({ ["Title"] = "Looping", ["Content"] = "Fitur looping diaktifkan!", ["Duration"] = 3, ["Image"] = "repeat" })
        else
            UILibrary:Notify({ ["Title"] = "Looping", ["Content"] = "Fitur looping dinonaktifkan!", ["Duration"] = 3, ["Image"] = "x" })
        end
    end
})

AutoWalkTab:CreateSection("Auto Walk (Automatic)")

AutoWalkTab:CreateToggle({
    ["Name"] = "Auto Walk (Start To End)",
    ["CurrentValue"] = false,
    ["Callback"] = function(val)
        if val then
            manualMode = false
            autoWalkRunning = true
            startAutomaticWalk()
        else
            autoWalkRunning = false
            manualMode = false
            stopPlayback()
        end
    end
})

AutoWalkTab:CreateSection("Auto Walk (Manual)")

AutoWalkTab:CreateToggle({
    ["Name"] = "Auto Walk (Spawnpoint)",
    ["CurrentValue"] = false,
    ["Callback"] = function(val)
        if val then startPlaybackForFile("spawnpoint.json", 1) else autoWalkRunning = false manualMode = false stopPlayback() end
    end
})

AutoWalkTab:CreateToggle({
    ["Name"] = "Auto Walk (Checkpoint 1)",
    ["CurrentValue"] = false,
    ["Callback"] = function(val)
        if val then startPlaybackForFile("checkpoint_1.json", 2) else autoWalkRunning = false manualMode = false stopPlayback() end
    end
})

AutoWalkTab:CreateToggle({
    ["Name"] = "Auto Walk (Checkpoint 2)",
    ["CurrentValue"] = false,
    ["Callback"] = function(val)
        if val then startPlaybackForFile("checkpoint_2.json", 3) else autoWalkRunning = false manualMode = false stopPlayback() end
    end
})

AutoWalkTab:CreateToggle({
    ["Name"] = "Auto Walk (Checkpoint 3)",
    ["CurrentValue"] = false,
    ["Callback"] = function(val)
        if val then startPlaybackForFile("checkpoint_3.json", 4) else autoWalkRunning = false manualMode = false stopPlayback() end
    end
})

AutoWalkTab:CreateToggle({
    ["Name"] = "Auto Walk (Checkpoint 4)",
    ["CurrentValue"] = false,
    ["Callback"] = function(val)
        if val then startPlaybackForFile("checkpoint_4.json", 5) else autoWalkRunning = false manualMode = false stopPlayback() end
    end
})

AutoWalkTab:CreateToggle({
    ["Name"] = "Auto Walk (Checkpoint 5)",
    ["CurrentValue"] = false,
    ["Callback"] = function(val)
        if val then startPlaybackForFile("checkpoint_5.json", 6) else autoWalkRunning = false manualMode = false stopPlayback() end
    end
})

-- ======================================
-- Teleport helpers & UI
-- ======================================
local TeleportOffset = 10 -- offset above ground
local function teleportTo(x, y, z)
    local plr = game.Players.LocalPlayer
    if (plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")) then
        plr.Character.HumanoidRootPart.CFrame = CFrame.new(x, y + TeleportOffset, z)
    end
    UILibrary:Notify({ ["Title"] = "Teleport", ["Content"] = "Teleport berhasil", ["Duration"] = 3, ["Image"] = "check-check" })
end

TeleportTab:CreateSection("Informasi")
TeleportTab:CreateParagraph({
    ["Title"] = "Keterangan !!!",
    ["Content"] = "- Teleport (Spawnpoint)\nMenu ini akan memindahkanmu langsung ke titik awal (Spawnpoint).\n\n- Teleport (Checkpoint 1 - Puncak)\nMenu ini akan memindahkanmu ke checkpoint sesuai pilihan tombol yang ditekan"
})

TeleportTab:CreateSection("List All Checkpoint")
TeleportTab:CreateButton({ ["Name"] = "Teleport (Spawnpoints)", ["Callback"] = function() teleportTo(-958.08, 169.18, 874.98) end })
TeleportTab:CreateButton({ ["Name"] = "Teleport (Checkpoint 1)", ["Callback"] = function() teleportTo(-416.99, 248.93, 776.39) end })
TeleportTab:CreateButton({ ["Name"] = "Teleport (Checkpoint 2)", ["Callback"] = function() teleportTo(-324.53, 388.26, 524.55) end })
TeleportTab:CreateButton({ ["Name"] = "Teleport (Checkpoint 3)", ["Callback"] = function() teleportTo(299.76, 429.78, 496.15) end })
TeleportTab:CreateButton({ ["Name"] = "Teleport (Checkpoint 4)", ["Callback"] = function() teleportTo(322.77, 490.26, 362.51) end })
TeleportTab:CreateButton({ ["Name"] = "Teleport (Checkpoint 5)", ["Callback"] = function() teleportTo(232.47, 314.26, -144.8) end })
TeleportTab:CreateButton({ ["Name"] = "Teleport (Puncak)", ["Callback"] = function() teleportTo(-583.93, 912, -520.09) end })

-- ======================================
-- Update Script menu
-- ======================================
local UpdateInProgress = false
local updateCancelFlag = { false }

UpdateTab:CreateSection("Update Script Menu")
UpdateTab:CreateParagraph({
    ["Title"] = "Keterangan !!!",
    ["Content"] = "Pada menu Update Script berfungsi untuk memperbarui script secara manual."
})

local updateStatusLabel = UpdateTab:CreateLabel("Pengecekan file...")

-- initial file check (async)
task.spawn(function()
    for idx, fname in ipairs(Checkpoints) do
        local ok = ensureFile(fname)
        updateStatusLabel:Set(((ok and "✔ Proses Cek File: ") or "❌ Gagal: ") .. " (" .. idx .. "/" .. #Checkpoints .. ")")
        task.wait(0.5)
    end
    updateStatusLabel:Set("✔ Semua file aman")
end)

UpdateTab:CreateToggle({
    ["Name"] = "Mulai Update Script",
    ["CurrentValue"] = false,
    ["Callback"] = function(enabled)
        if enabled then
            UpdateInProgress = true
            updateCancelFlag[1] = false

            task.spawn(function()
                updateStatusLabel:Set("🔄 Proses update file...")
                -- delete existing local files
                for _, fname in ipairs(Checkpoints) do
                    local path = JsonFolder .. "/" .. fname
                    if isfile(path) then delfile(path) end
                end

                -- download fresh copies
                for i, fname in ipairs(Checkpoints) do
                    if updateCancelFlag[1] then break end
                    UILibrary:Notify({ ["Title"] = "Update Script", ["Content"] = "Proses Update (" .. i .. "/" .. #Checkpoints .. ")", ["Duration"] = 2, ["Image"] = "file" })
                    local ok, contents = pcall(function() return game:HttpGet(RawJsonBaseUrl .. fname) end)
                    if (ok and contents and (#contents > 0)) then
                        writefile(JsonFolder .. "/" .. fname, contents)
                        updateStatusLabel:Set("📥 Proses Update: (" .. i .. "/" .. #Checkpoints .. ")")
                    else
                        UILibrary:Notify({ ["Title"] = "Update Script", ["Content"] = "❌ Update script gagal", ["Duration"] = 3, ["Image"] = "file" })
                        updateStatusLabel:Set("❌ Gagal: (" .. i .. "/" .. #Checkpoints .. ")")
                    end
                    task.wait(0.3)
                end

                if not updateCancelFlag[1] then
                    UILibrary:Notify({ ["Title"] = "Update Script", ["Content"] = "Successfully!", ["Duration"] = 5, ["Image"] = 4483362458 })
                else
                    UILibrary:Notify({ ["Title"] = "Update Script", ["Content"] = "❌ Update canceled", ["Duration"] = 3, ["Image"] = 4483362458 })
                end

                -- re-check files
                for i, fname in ipairs(Checkpoints) do
                    local okFile = ensureFile(fname)
                    updateStatusLabel:Set(((okFile and "✔ Cek File: ") or "❌ Failed: ") .. " (" .. i .. "/" .. #Checkpoints .. ")")
                    task.wait(0.3)
                end
                updateStatusLabel:Set("✔ Semua file aman")
            end)
        else
            UpdateInProgress = false
            updateCancelFlag[1] = true
        end
    end
})

-- ======================================
-- Credits tab
-- ======================================
CreditsTab:CreateSection("Credits List")
CreditsTab:CreateLabel("UI: Rayfield Interface")
CreditsTab:CreateLabel("Dev: Hirakoxs")

-- End of script