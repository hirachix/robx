-- ============================================================ 
-- CORE (fungsi asli + log/notify) 
-- ============================================================ 
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local hrp = nil

local Packs = {
    lucide = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/lucide/dist/Icons.lua"))(),
    craft = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/craft/dist/Icons.lua"))(),
    geist = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/geist/dist/Icons.lua"))(),
}

-- notify placeholder DIPINDAH KE ATAS
local notify = function(title, content, duration) 
    print("[NOTIFY] " .. title .. ": " .. (content or ""))
end

local function refreshHRP(char)
    if not char then
        char = player.Character or player.CharacterAdded:Wait()
    end
    hrp = char:WaitForChild("HumanoidRootPart")
end

if player.Character then
    refreshHRP(player.Character)
end
player.CharacterAdded:Connect(refreshHRP)

local frameTime = 1/30
local playbackRate = 1.0
local isRunning = false
local routes = {}

-- ============================================================
-- AUTO DETECTION SYSTEM (SMART HEIGHT ADJUST)
-- ============================================================

-- Ambil tinggi avatar sekarang
local function getCurrentHeight()
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")
    return humanoid.HipHeight + (char:FindFirstChild("Head") and char.Head.Size.Y or 2)
end

-- Smart auto-adjust system - DIPERBAIKI
local function smartAdjustRoute(frames)
    local adjusted = {}
    
    if #frames > 0 then
        local firstFrameY = frames[1].Position.Y
        local currentHeight = getCurrentHeight()
        
        -- Deteksi jika route butuh penyesuaian tinggi
        -- Jika posisi Y frame pertama ekstrem, lakukan adjustment
        if firstFrameY > 100 or firstFrameY < -50 then
            local offsetY = currentHeight - 5.0 -- Tinggi standar untuk adjustment
            
            for _, cf in ipairs(frames) do
                local pos, rot = cf.Position, cf - cf.Position
                local newPos = Vector3.new(pos.X, pos.Y + offsetY, pos.Z)
                table.insert(adjusted, CFrame.new(newPos) * rot)
            end
            
            -- Notify auto-adjust - DIPERBAIKI (gunakan print dulu)
            print(string.format("[AUTO-ADJUST] Tinggi disesuaikan: %.2f → %.2f", firstFrameY, adjusted[1].Position.Y))
            return adjusted
        end
    end
    
    -- Jika tidak perlu adjustment, return original
    return frames
end

-- ============================================================
-- ROUTE LOADING & PROCESSING
-- ============================================================

local intervalFlip = false -- toggle interval rotation

-- Hapus frame duplikat
local function removeDuplicateFrames(frames, tolerance)
    tolerance = tolerance or 0.01 -- toleransi kecil
    if #frames < 2 then
        return frames
    end
    
    local newFrames = {frames[1]}
    for i = 2, #frames do
        local prev = frames[i-1]
        local curr = frames[i]
        local prevPos, currPos = prev.Position, curr.Position
        local prevRot, currRot = prev - prev.Position, curr - curr.Position
        
        local posDiff = (prevPos - currPos).Magnitude
        local rotDiff = (prevRot.Position - currRot.Position).Magnitude -- rot diff sederhana
        
        if posDiff > tolerance or rotDiff > tolerance then
            table.insert(newFrames, curr)
        end
    end
    
    return newFrames
end

-- Apply interval flip
local function applyIntervalRotation(cf)
    if intervalFlip then
        local pos = cf.Position
        local rot = cf - pos
        local newRot = CFrame.Angles(0, math.pi, 0) * rot
        return CFrame.new(pos) * newRot
    else
        return cf
    end
end

-- Load route dengan auto adjust + hapus duplikat - DIPERBAIKI
local function loadRoute(url)
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if ok and type(result) == "table" then
        local cleaned = removeDuplicateFrames(result, 0.01)
        return smartAdjustRoute(cleaned) -- AUTO-ADJUST DISINI
    else
        warn("Gagal load route dari: "..url)
        return {}
    end
end

-- daftar link raw route (ubah ke link punyamu)
routes = {
{"BASE → CP1", loadRoute("https://raw.githubusercontent.com/LlyXCode/ANTARTIKA/refs/heads/main/01.lua")},
    {"CP1 → CP2", loadRoute("https://raw.githubusercontent.com/LlyXCode/ANTARTIKA/refs/heads/main/12.lua")},
    {"CP2 → CP3", loadRoute("https://raw.githubusercontent.com/LlyXCode/ANTARTIKA/refs/heads/main/23.lua")},
    {"CP3 → CP4", loadRoute("https://raw.githubusercontent.com/LlyXCode/ANTARTIKA/refs/heads/main/34.lua")},
    {"CP4 → SUMMIT", loadRoute("https://raw.githubusercontent.com/LlyXCode/ANTARTIKA/refs/heads/main/45.lua")},
}

-- ============================================================
-- Fungsi bantu & core logic
-- ============================================================

local VirtualUser = game:GetService("VirtualUser")
local antiIdleActive = true -- langsung aktif
local antiIdleConn

local function respawnPlayer()
    player.Character:BreakJoints()
end

local function getNearestRoute()
    local nearestIdx, dist = 1, math.huge
    if hrp then
        local pos = hrp.Position
        for i,data in ipairs(routes) do
            for _,cf in ipairs(data[2]) do
                local d = (cf.Position - pos).Magnitude
                if d < dist then
                    dist = d
                    nearestIdx = i
                end
            end
        end
    end
    return nearestIdx
end

local function getNearestFrameIndex(frames)
    local startIdx, dist = 1, math.huge
    if hrp then
        local pos = hrp.Position
        for i,cf in ipairs(frames) do
            local d = (cf.Position - pos).Magnitude
            if d < dist then
                dist = d
                startIdx = i
            end
        end
    end
    if startIdx >= #frames then
        startIdx = math.max(1, #frames - 1)
    end
    return startIdx
end

-- ============================================================
-- Modifikasi lerpCF untuk interval flip
-- ============================================================

local function lerpCF(fromCF, toCF)
    fromCF = applyIntervalRotation(fromCF)
    toCF = applyIntervalRotation(toCF)
    
    local duration = frameTime / math.max(0.05, playbackRate)
    local t = 0
    while t < duration do
        if not isRunning then break end
        local dt = task.wait()
        t += dt
        local alpha = math.min(t / duration, 1)
        
        if hrp and hrp.Parent and hrp:IsDescendantOf(workspace) then
            hrp.CFrame = fromCF:Lerp(toCF, alpha)
        end
    end
end

local function logAndNotify(msg, val)
    local text = val and (msg .. " " .. tostring(val)) or msg
    print(text)
    notify(msg, tostring(val or ""), 3)
end

-- === VAR BYPASS ===
local bypassActive = false
local bypassConn

local function setupBypass(char)
    local humanoid = char:WaitForChild("Humanoid")
    local hrp = char:WaitForChild("HumanoidRootPart")
    local lastPos = hrp.Position
    
    if bypassConn then
        bypassConn:Disconnect()
    end
    
    bypassConn = RunService.RenderStepped:Connect(function()
        if not hrp or not hrp.Parent then return end
        
        if bypassActive then
            local direction = (hrp.Position - lastPos)
            local dist = direction.Magnitude
            
            -- Deteksi perbedaan ketinggian (Y)
            local yDiff = hrp.Position.Y - lastPos.Y
            if yDiff > 0.5 then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            elseif yDiff < -1 then
                humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
            end
            
            if dist > 0.01 then
                local moveVector = direction.Unit * math.clamp(dist * 5, 0, 1)
                humanoid:Move(moveVector, false)
            else
                humanoid:Move(Vector3.zero, false)
            end
        end
        lastPos = hrp.Position
    end)
end

player.CharacterAdded:Connect(setupBypass)
if player.Character then
    setupBypass(player.Character)
end

-- helper otomatis bypass
local function setBypass(state)
    bypassActive = state
    notify("Bypass Animasi", state and "✅ Aktif" or "❌ Nonaktif", 2)
end

-- Jalankan 1 route dari checkpoint terdekat
local function runRouteOnce()
    if #routes == 0 then return end
    if not hrp then refreshHRP() end
    
    setBypass(true) -- otomatis ON
    isRunning = true
    
    local idx = getNearestRoute()
    logAndNotify("Mulai dari cp : ", routes[idx][1])
    
    local frames = routes[idx][2]
    if #frames < 2 then
        isRunning = false
        setBypass(false)
        return
    end
    
    local startIdx = getNearestFrameIndex(frames)
    for i = startIdx, #frames - 1 do
        if not isRunning then break end
        lerpCF(frames[i], frames[i+1])
    end
    
    isRunning = false
    setBypass(false) -- otomatis OFF
end

local function runAllRoutes()
    if #routes == 0 then return end
    isRunning = true
    
    while isRunning do
        if not hrp then refreshHRP() end
        setBypass(true)
        
        local idx = getNearestRoute()
        logAndNotify("Sesuaikan dari cp : ", routes[idx][1])
        
        for r = idx, #routes do
            if not isRunning then break end
            local frames = routes[r][2]
            if #frames < 2 then continue end
            
            local startIdx = getNearestFrameIndex(frames)
            for i = startIdx, #frames - 1 do
                if not isRunning then break end
                lerpCF(frames[i], frames[i+1])
            end
        end
        
        setBypass(false)
        
        -- Respawn + delay 5 detik HANYA jika masih running
        if not isRunning then break end
        respawnPlayer()
        task.wait(5)
    end
end

local function stopRoute()
    if isRunning then
        logAndNotify("Stop route", "Semua route dihentikan!")
    end
    
    -- hentikan loop utama
    isRunning = false
    
    -- matikan bypass kalau aktif
    if bypassActive then
        bypassActive = false
        notify("Bypass Animasi", "❌ Nonaktif", 2)
    end
end

local function runSpecificRoute(routeIdx)
    if not routes[routeIdx] then return end
    if not hrp then refreshHRP() end
    
    isRunning = true
    local frames = routes[routeIdx][2]
    if #frames < 2 then
        isRunning = false
        return
    end
    
    logAndNotify("Memulai track : ", routes[routeIdx][1])
    local startIdx = getNearestFrameIndex(frames)
    
    for i = startIdx, #frames - 1 do
        if not isRunning then break end
        lerpCF(frames[i], frames[i+1])
    end
    
    isRunning = false
end

-- ===============================
-- Anti Beton Ultra-Smooth
-- ===============================
local antiBetonActive = false
local antiBetonConn

local function enableAntiBeton()
    if antiBetonConn then
        antiBetonConn:Disconnect()
    end
    
    antiBetonConn = RunService.Stepped:Connect(function(_, dt)
        local char = player.Character
        if not char then return end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChild("Humanoid")
        if not hrp or not humanoid then return end
        
        if antiBetonActive and humanoid.FloorMaterial == Enum.Material.Air then
            local targetY = -50
            local currentY = hrp.Velocity.Y
            local newY = currentY + (targetY - currentY) * math.clamp(dt * 2.5, 0, 1)
            hrp.Velocity = Vector3.new(hrp.Velocity.X, newY, hrp.Velocity.Z)
        end
    end)
end

local function disableAntiBeton()
    if antiBetonConn then
        antiBetonConn:Disconnect()
        antiBetonConn = nil
    end
end

-- ============================================================
-- UI: WindUI
-- ============================================================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "HIRAKO | ANTARTIKA",
    Icon = "lucide:mountain-snow", 
    Author = "Hirako",
    Folder = "Hirako",
    Size = UDim2.fromOffset(580, 460),
    Theme = "Midnight",
    Resizable = true,
    SideBarWidth = 200,
    Watermark = "Hirako",
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function()
            WindUI:Notify({
                Title = "User Profile",
                Content = "User profile clicked!",
                Duration = 3
            })
        end
    }
})

-- inject notify - OVERRIDE dengan WindUI notify
notify = function(title, content, duration)
    pcall(function()
        WindUI:Notify({
            Title = title,
            Content = content or "",
            Duration = duration or 3,
            Icon = "bell",
        })
    end)
end

local function enableAntiIdle()
    if antiIdleConn then
        antiIdleConn:Disconnect()
    end
    
    local player = Players.LocalPlayer
    antiIdleConn = player.Idled:Connect(function()
        if antiIdleActive then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
            notify("Anti Idle", "Klik otomatis dilakukan.", 2)
        end
    end)
end

-- Jalankan saat script load
enableAntiIdle()

-- Tabs
local MainTab = Window:Tab({
    Title = "Main",
    Icon = "geist:shareplay",
    Default = true
})

local SettingsTab = Window:Tab({
    Title = "Tools", 
    Icon = "geist:settings-sliders",
})

local tampTab = Window:Tab({
    Title = "Tampilan",
    Icon = "lucide:app-window",
})

local CreditsTab = Window:Tab({
    Title = "Credit",
    Icon = "lucide:info",
})

-- ============================================================
-- Main Tab (Dropdown speed mulai dari 0.25x)
-- ============================================================
local speeds = {}
for v = 0.25, 3, 0.25 do
    table.insert(speeds, string.format("%.2fx", v))
end

MainTab:Dropdown({
    Title = "Speed",
    Icon = "lucide:zap",
    Values = speeds,
    Value = "1.00x",
    Callback = function(option)
        local num = tonumber(option:match("([%d%.]+)"))
        if num then
            playbackRate = num
            logAndNotify("Speed : ", string.format("%.2fx", playbackRate))
        else
            notify("Playback Speed", "Gagal membaca opsi speed!", 3)
        end
    end
})

MainTab:Toggle({
    Title = "Freestyle Belakang", 
    Icon = "lucide:refresh-ccw",
    Desc = "Untuk Freestyle Madep Belakang",
    Value = false,
    Callback = function(state)
        intervalFlip = state
        notify("Interval Flip", state and "✅ Aktif" or "❌ Nonaktif", 2)
    end
})

MainTab:Toggle({
    Title = "Anti Lag",
    Icon = "lucide:shield",
    Desc = "Mencegah Lag Saat Walk", 
    Value = false,
    Callback = function(state)
        antiBetonActive = state
        if state then
            enableAntiBeton()
            WindUI:Notify({
                Title = "Anti Lag",
                Content = "✅ Aktif (Ultra-Smooth)",
                Duration = 2
            })
        else
            disableAntiBeton()
            WindUI:Notify({
                Title = "Anti Lag", 
                Content = "❌ Nonaktif",
                Duration = 2
            })
        end
    end
})

-- Main Tab Buttons
MainTab:Button({
    Title = "START",
    Icon = "craft:back-to-start-stroke", 
    Desc = "Mulai dari checkpoint terdekat",
    Callback = function()
        pcall(runRouteOnce)
    end
})

MainTab:Button({
    Title = "AWAL KE AKHIR",
    Desc = "Jalankan semua checkpoint",
    Icon = "craft:back-to-start-stroke",
    Callback = function()
        pcall(runAllRoutes)
    end
})

MainTab:Button({
    Title = "Stop track",
    Icon = "geist:stop-circle",
    Desc = "Hentikan route", 
    Callback = function()
        pcall(stopRoute)
    end
})

for idx, data in ipairs(routes) do
    MainTab:Button({
        Title = "TRACK "..data[1],
        Icon = "lucide:train-track",
        Desc = "Jalankan dari "..data[1],
        Callback = function()
            pcall(function()
                runSpecificRoute(idx)
            end)
        end
    })
end

-- Settings
SettingsTab:Slider({
    Title = "WalkSpeed",
    Icon = "lucide:zap",
    Desc = "Atur kecepatan berjalan karakter",
    Value = { Min = 10, Max = 500, Default = 16 },
    Step = 1,
    Suffix = "Speed",
    Callback = function(val)
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = val
        end
    end
})

SettingsTab:Slider({
    Title = "Jump Height", 
    Icon = "lucide:zap",
    Desc = "Atur kekuatan lompat karakter",
    Value = { Min = 10, Max = 500, Default = 50 },
    Step = 1,
    Suffix = "Height", 
    Callback = function(val)
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = val
        end
    end
})

SettingsTab:Button({
    Title = "Respawn Player",
    Icon = "lucide:user-minus",
    Desc = "Respawn karakter saat ini",
    Icon = "lucide:refresh-ccw",
    Callback = function()
        respawnPlayer()
    end
})

SettingsTab:Button({
    Title = "Speed Coil",
    Icon = "lucide:zap", 
    Desc = "Tambah Speed Coil ke karakter",
    Callback = function()
        local Players = game:GetService("Players")
        local player = Players.LocalPlayer
        local speedValue = 23
        
        local function giveCoil(char)
            local backpack = player:WaitForChild("Backpack")
            if backpack:FindFirstChild("Speed Coil") or char:FindFirstChild("Speed Coil") then
                return
            end
            
            local tool = Instance.new("Tool")
            tool.Name = "Speed Coil"
            tool.RequiresHandle = false
            tool.Parent = backpack
            
            tool.Equipped:Connect(function()
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = speedValue
                end
            end)
            
            tool.Unequipped:Connect(function()
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = 16
                end
            end)
        end
        
        if player.Character then
            giveCoil(player.Character)
        end
        
        player.CharacterAdded:Connect(function(char)
            task.wait(1)
            giveCoil(char)
        end)
    end
})

SettingsTab:Button({
    Title = "Teleport Tool",
    Icon = "lucide:chevrons-up-down",
    Desc = "Click Teleport Using Teleport Tools",
    Callback = function()
        local Players = game:GetService("Players")
        local player = Players.LocalPlayer
        local mouse = player:GetMouse()
        
        local tool = Instance.new("Tool")
        tool.RequiresHandle = false
        tool.Name = "Teleport"
        tool.Parent = player.Backpack
        
        tool.Activated:Connect(function()
            if mouse.Hit then
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0,3,0))
                end
            end
        end)
    end
})

SettingsTab:Button({
    Title = "Gling GUI",
    Icon = "lucide:layers-2", 
    Desc = "Gling For Troll",
    Callback = function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Fling-Gui-Op-47914"))()
    end
})

tampTab:Button({
    Title = "Animasi Walk",
    Icon = "lucide:layers-2",
    Desc = "Klik untuk mengubah animasi mu",
    Callback = function()
        loadstring(game:HttpGet("https://pastefy.app/uoZdJykS/raw"))()
    end
})


CreditsTab:Section({
    Title = "Credits List",
    TextSize = 16,
})

CreditsTab:Paragraph({
    Title = "UI Framework",
    Desc = "WindUI Interface Suite",
    Image = "layout",
    ImageSize = 20,
})

CreditsTab:Paragraph({
    Title = "Developer", 
    Desc = "Hirako",
    Image = "user",
    ImageSize = 20,
})

CreditsTab:Button({
    Title = "Copy Telegram",
    Icon = "message-circle",
    Desc = "Salin link Telegram ke clipboard",
    Callback = function()
        if setclipboard then
            setclipboard("hirakoxs.t.me")
            WindUI:Notify({
                Title = "Telegram",
                Content = "Link berhasil disalin!",
                Duration = 3,
                Icon = "check"
            })
        else
            WindUI:Notify({
                Title = "Error",
                Content = "Clipboard tidak tersedia",
                Duration = 3,
                Icon = "x"
            })
        end
    end
})

-- Open button cantik
Window:EditOpenButton({
    Title = "Hirako",
    Icon = "geist:logo-nuxt",
    CornerRadius = UDim.new(0,16),
    StrokeThickness = 2,
    Color = ColorSequence.new(
        Color3.fromHex("FF0F7B"),
        Color3.fromHex("F89B29")
    ),
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
})

-- Tambah tag
Window:Tag({
    Title = "V1.0.1",
    Color = Color3.fromHex("#30ff6a"),
    Radius = 10,
})

-- Tag Jam
local TimeTag = Window:Tag({
    Title = "--:--:--",
    Icon = "lucide:timer", 
    Radius = 10,
    Color = WindUI:Gradient({
        ["0"] = { Color = Color3.fromHex("#FF0F7B"), Transparency = 0 },
        ["100"] = { Color = Color3.fromHex("#F89B29"), Transparency = 0 },
    }, {
        Rotation = 45,
    }),
})

local hue = 0

-- Rainbow + Jam Real-time
task.spawn(function()
    while true do
        -- Ambil waktu sekarang
        local now = os.date("*t")
        local hours = string.format("%02d", now.hour)
        local minutes = string.format("%02d", now.min) 
        local seconds = string.format("%02d", now.sec)
        
        -- Update warna rainbow
        hue = (hue + 0.01) % 1
        local color = Color3.fromHSV(hue, 1, 1)
        
        -- Update judul tag jadi jam lengkap
        TimeTag:SetTitle(hours .. ":" .. minutes .. ":" .. seconds)
        
        -- Kalau mau rainbow berjalan, aktifkan ini:
        TimeTag:SetColor(color)
        
        task.wait(0.06) -- refresh cepat
    end
end)



-- Final notif
notify("HirakoHUB Script sudah di load", 3)
notify("Auto-Height", "Sistem otomatis aktif! Tinggi route akan disesuaikan.", 3)

pcall(function()
    Window:Show()
    MainTab:Show()
end)