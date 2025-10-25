-- ============================================================
-- CORE (fungsi asli + log/notify)
-- ============================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local hrp = nil
local Packs = {
    lucide = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/lucide/dist/Icons.lua"))(),
    craft  = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/craft/dist/Icons.lua"))(),
    geist  = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/geist/dist/Icons.lua"))(),
}

local function refreshHRP(char)
    if not char then
        char = player.Character or player.CharacterAdded:Wait()
    end
    hrp = char:WaitForChild("HumanoidRootPart")
end
if player.Character then refreshHRP(player.Character) end
player.CharacterAdded:Connect(refreshHRP)

local frameTime = 1/30
local playbackRate = 1.0
local isRunning = false
local routes = {}

-- ============================================================
-- ROUTE EXAMPLE (isi CFrame)
-- ============================================================
-- Tinggi default waktu record
local DEFAULT_HEIGHT = 2.900038719177
-- 4.882498383522034 

-- Ambil tinggi avatar sekarang
local function getCurrentHeight()
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")
    return humanoid.HipHeight + (char:FindFirstChild("Head") and char.Head.Size.Y or 2)
end

-- Adjustment posisi sesuai tinggi avatar
local function adjustRoute(frames)
    local adjusted = {}
    local currentHeight = getCurrentHeight()
    local offsetY = currentHeight - DEFAULT_HEIGHT  -- full offset
    for _, cf in ipairs(frames) do
        local pos, rot = cf.Position, cf - cf.Position
        local newPos = Vector3.new(pos.X, pos.Y + offsetY, pos.Z)
        table.insert(adjusted, CFrame.new(newPos) * rot)
    end
    return adjusted
end

-- ============================================================
-- ROUTE EXAMPLE (isi CFrame)
-- ============================================================
local intervalFlip = false -- toggle interval rotation

-- ============================================================
-- Hapus frame duplikat
-- ============================================================
local function removeDuplicateFrames(frames, tolerance)
    tolerance = tolerance or 0.01 -- toleransi kecil
    if #frames < 2 then return frames end
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
-- ============================================================
-- Apply interval flip
-- ============================================================
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

-- ============================================================
-- Load route dengan auto adjust + hapus duplikat
-- ============================================================
local function loadRoute(url)
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if ok and type(result) == "table" then
        local cleaned = removeDuplicateFrames(result, 0.01) -- tambahkan tolerance
        return adjustRoute(cleaned)
    else
        warn("Gagal load route dari: "..url)
        return {}
    end
end

-- daftar link raw route (ubah ke link punyamu)
routes = {
    {"BASE → CP8", loadRoute("https://raw.githubusercontent.com/LlyXCode/CKPTW/refs/heads/main/01.lua")},
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


-- notify placeholder
local notify = function() end
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

    if bypassConn then bypassConn:Disconnect() end
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
if player.Character then setupBypass(player.Character) end

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
    if antiBetonConn then antiBetonConn:Disconnect() end

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
    Title = "HIRAKO | CKPTW",
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

-- inject notify
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
    if antiIdleConn then antiIdleConn:Disconnect() end
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
local InfoTab = Window:Tab({
    Title = "Info",
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
    Title = "Interval Flip",
    Icon = "lucide:refresh-ccw",
    Desc = "ON → Hadap belakang tiap frame",
    Value = false,
    Callback = function(state)
        intervalFlip = state
        notify("Interval Flip", state and "✅ Aktif" or "❌ Nonaktif", 2)
    end
})

MainTab:Toggle({
    Title = "Anti Beton Ultra-Smooth",
    Icon = "lucide:shield",
    Desc = "Mencegah jatuh secara kaku saat melayang",
    Value = false,
    Callback = function(state)
        antiBetonActive = state
        if state then
            enableAntiBeton()
            WindUI:Notify({
                Title = "Anti Beton",
                Content = "✅ Aktif (Ultra-Smooth)",
                Duration = 2
            })
        else
            disableAntiBeton()
            WindUI:Notify({
                Title = "Anti Beton",
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
    Callback = function() pcall(runRouteOnce) end
})
MainTab:Button({
    Title = "AWAL KE AKHIR",
    Desc = "Jalankan semua checkpoint",
    Icon = "craft:back-to-start-stroke",
    Callback = function() pcall(runAllRoutes) end
})
MainTab:Button({
    Title = "Stop track",
    Icon = "geist:stop-circle",
    Desc = "Hentikan route",
    Callback = function() pcall(stopRoute) end
})
for idx, data in ipairs(routes) do
    MainTab:Button({
        Title = "TRACK "..data[1],
        Icon = "lucide:train-track",
        Desc = "Jalankan dari "..data[1],
        Callback = function()
            pcall(function() runSpecificRoute(idx) end)
        end
    })
end

-- Settings
-- ============================================================
-- Setup teleport options: BASE + CP1, CP2, dst
-- ============================================================
local teleportOptions = {"BASE"}
for idx, _ in ipairs(routes) do
    table.insert(teleportOptions, "CP "..idx)
end

-- Delay dropdown (1–10 detik)
local delayValues = {}
for i = 1, 10 do table.insert(delayValues, tostring(i).."s") end
local teleportDelay = 3 -- default 3 detik

SettingsTab:Dropdown({
    Title = "Delay Teleport",
    Icon = "lucide:timer",
    Values = delayValues,
    Value = "3s",
    Callback = function(val)
        local n = tonumber(val:match("(%d+)"))
        if n then teleportDelay = n end
    end
})

-- Dropdown teleport satu checkpoint
SettingsTab:Dropdown({
    Title = "Teleport ke Checkpoint",
    Icon = "lucide:map-pin",
    Values = teleportOptions,
    SearchBarEnabled = true,
    Value = teleportOptions[1], -- default BASE
    Callback = function(selected)
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local targetCF
        if selected == "BASE" then
            targetCF = routes[1][2][1] -- frame pertama route 1
        else
            local idx = tonumber(selected:match("%d+"))
            if idx and routes[idx] then
                local frames = routes[idx][2]
                targetCF = frames[#frames] -- frame terakhir route idx
            end
        end

        if targetCF then
            hrp.CFrame = targetCF
            notify("Teleport", "Berhasil ke "..selected, 2)
        else
            notify("Teleport", "Gagal teleport!", 2)
        end
    end
})

-- Loop teleport dari BASE → CP terakhir
SettingsTab:Button({
    Title = "Loop Teleport",
    Icon = "lucide:refresh-ccw",
    Desc = "Teleport dari BASE sampai CP terakhir sesuai route",
    Callback = function()
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        task.spawn(function()
            -- BASE dulu
            hrp.CFrame = routes[1][2][1]
            notify("Loop Teleport", "Teleport ke BASE", 2)
            task.wait(teleportDelay)

            -- Loop dari CP1 sampai CP terakhir
            for idx, _ in ipairs(routes) do
                local frames = routes[idx][2]
                hrp.CFrame = frames[#frames] -- frame terakhir route
                notify("Loop Teleport", "Teleport ke CP "..idx, 2)
                task.wait(teleportDelay)
            end

            notify("Loop Teleport", "Selesai!", 3)
        end)
    end
})
SettingsTab:Slider({
    Title = "WalkSpeed",
    Icon = "lucide:zap",
    Desc = "Atur kecepatan berjalan karakter",
    Value = { 
        Min = 10,
        Max = 500,
        Default = 16
    },
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
    Value = { 
        Min = 10,
        Max = 500,
        Default = 50
    },
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
    Icon = "lucide:refresh-ccw", -- opsional, pakai icon dari Packs
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
            if backpack:FindFirstChild("Speed Coil") or char:FindFirstChild("Speed Coil") then return end

            local tool = Instance.new("Tool")
            tool.Name = "Speed Coil"
            tool.RequiresHandle = false
            tool.Parent = backpack

            tool.Equipped:Connect(function()
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then humanoid.WalkSpeed = speedValue end
            end)

            tool.Unequipped:Connect(function()
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then humanoid.WalkSpeed = 16 end
            end)
        end

        if player.Character then giveCoil(player.Character) end
        player.CharacterAdded:Connect(function(char)
            task.wait(1)
            giveCoil(char)
        end)
    end
})

SettingsTab:Button({
    Title = "TP Tool",
    Icon = "lucide:chevrons-up-down",
    Desc = "Teleport pakai tool",
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
    Desc = "Load Gling GUI",
    Callback = function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Fling-Gui-Op-47914"))()
    end
})

InfoTab:Button({
    Title = "Copy Telegram",
    Icon = "geist:logo-telegram",
    Desc = "Salin link Telegram ke clipboard",
    Callback = function()
        if setclipboard then
            setclipboard("hirakoxs.t.me")
            logAndNotify("Telegram", "Link berhasil disalin!")
        else
            notify("Clipboard Error", "setclipboard tidak tersedia!", 2)
        end
    end
})

-- Info Tab
InfoTab:Section({
    Title = "INFO",
    TextSize = 20,
})
InfoTab:Section({
    Title = [[
Replay/route system untuk checkpoint.

- Start CP = mulai dari checkpoint terdekat
- Start To End = jalankan semua checkpoint
- Run CPx → CPy = jalur spesifik
- Playback Speed = atur kecepatan replay (0.25x - 3.00x)

Own Hirako 
    ]],
    TextSize = 16,
    TextTransparency = 0.25,
})

-- Topbar custom
Window:DisableTopbarButtons({
    "Close",
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
        ["0"]   = { Color = Color3.fromHex("#FF0F7B"), Transparency = 0 },
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
		local hours   = string.format("%02d", now.hour)
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

Window:CreateTopbarButton("theme-switcher", "moon", function()
    WindUI:SetTheme(WindUI:GetCurrentTheme() == "Dark" and "Light" or "Dark")
    WindUI:Notify({
        Title = "Theme Changed",
        Content = "Current theme: "..WindUI:GetCurrentTheme(),
        Duration = 2
    })
end, 990)

-- Animation data
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

-- Animation system variables
local OriginalAnimations = {}
local CurrentPack = nil
local ActiveToggle = nil

-- Function to save original animations
local function SaveOriginalAnimations(Animate)
    OriginalAnimations = {}
    for _, child in ipairs(Animate:GetDescendants()) do
        if child:IsA("Animation") then
            OriginalAnimations[child] = child.AnimationId
        end
    end
end

-- Function to apply animations
local function ApplyAnimations(Animate, Humanoid, AnimPack)
    if Animate:FindFirstChild("idle") and Animate.idle:FindFirstChild("Animation1") then
        Animate.idle.Animation1.AnimationId = AnimPack.Idle1
    end
    if Animate:FindFirstChild("idle") and Animate.idle:FindFirstChild("Animation2") then
        Animate.idle.Animation2.AnimationId = AnimPack.Idle2
    end
    if Animate:FindFirstChild("walk") and Animate.walk:FindFirstChild("WalkAnim") then
        Animate.walk.WalkAnim.AnimationId = AnimPack.Walk
    end
    if Animate:FindFirstChild("run") and Animate.run:FindFirstChild("RunAnim") then
        Animate.run.RunAnim.AnimationId = AnimPack.Run
    end
    if Animate:FindFirstChild("jump") and Animate.jump:FindFirstChild("JumpAnim") then
        Animate.jump.JumpAnim.AnimationId = AnimPack.Jump
    end
    if Animate:FindFirstChild("fall") and Animate.fall:FindFirstChild("FallAnim") then
        Animate.fall.FallAnim.AnimationId = AnimPack.Fall
    end
    if Animate:FindFirstChild("climb") and Animate.climb:FindFirstChild("ClimbAnim") then
        Animate.climb.ClimbAnim.AnimationId = AnimPack.Climb
    end
    if Animate:FindFirstChild("swim") and Animate.swim:FindFirstChild("Swim") then
        Animate.swim.Swim.AnimationId = AnimPack.Swim
    end
    if Animate:FindFirstChild("swimidle") and Animate.swimidle:FindFirstChild("SwimIdle") then
        Animate.swimidle.SwimIdle.AnimationId = AnimPack.SwimIdle
    end
    Humanoid.Jump = true
end

-- Function to restore original animations
local function RestoreOriginal()
    for anim, id in pairs(OriginalAnimations) do
        if anim and anim:IsA("Animation") then
            anim.AnimationId = id
        end
    end
end

-- Function to setup character animations
local function SetupCharacter(Char)
    local Animate = Char:WaitForChild("Animate")
    local Humanoid = Char:WaitForChild("Humanoid")
    SaveOriginalAnimations(Animate)
    if CurrentPack then
        ApplyAnimations(Animate, Humanoid, CurrentPack)
    end
end

-- Character added event
player.CharacterAdded:Connect(function(Char)
    task.wait(1)
    SetupCharacter(Char)
end)

-- Setup current character
if player.Character then
    SetupCharacter(player.Character)
end

-- ============================================================
-- ANIMATION TAB UI
-- ============================================================

tampTab:Section({
    Title = "Animation Packs",
    TextSize = 18,
})

tampTab:Paragraph({
    Title = "Custom Animations",
    Desc = "Pilih pack animasi untuk mengganti animasi karakter",
    Image = "activity",
    ImageSize = 20,
    Color = "White"
})

-- Create toggles for each animation pack
for i = 1, 18 do
    local name = "Run Animation " .. i
    local pack = RunAnimations[name]

    tampTab:Toggle({
        Title = name,
        Desc = "Aktifkan " .. name,
        Value = false,
        Callback = function(Value)
            if Value then
                -- Turn off previous toggle
                if ActiveToggle and ActiveToggle ~= name then
                    -- You might want to store toggle references to turn them off
                end
                
                CurrentPack = pack
                ActiveToggle = name
                
                local Char = player.Character
                if Char and Char:FindFirstChild("Animate") and Char:FindFirstChild("Humanoid") then
                    ApplyAnimations(Char.Animate, Char.Humanoid, CurrentPack)
                end
                
                notify("Animation", "✅ " .. name .. " diaktifkan", 3)
            else
                if ActiveToggle == name then
                    CurrentPack = nil
                    ActiveToggle = nil
                    RestoreOriginal()
                    notify("Animation", "🔄 Animasi dikembalikan ke default", 3)
                end
            end
        end
    })
end

-- Reset animations button
tampTab:Section({
    Title = "Animation Controls",
    TextSize = 16,
})

tampTab:Button({
    Title = "🔄 Reset Animations",
    Icon = "lucide:refresh-ccw",
    Desc = "Kembalikan animasi ke default",
    Callback = function()
        CurrentPack = nil
        ActiveToggle = nil
        RestoreOriginal()
        notify("Animation", "🔄 Semua animasi dikembalikan ke default", 3)
    end
})

tampTab:Button({
    Title = "📊 Animation Info",
    Icon = "lucide:info",
    Desc = "Lihat info animasi saat ini",
    Callback = function()
        if CurrentPack then
            notify("Animation", "🎭 Animasi aktif: " .. ActiveToggle, 3)
        else
            notify("Animation", "🎭 Animasi default aktif", 3)
        end
    end
})

-- Status display
tampTab:Section({
    Title = "Status",
    TextSize = 16,
})

tampTab:Label({
    Title = "Active Animation: " .. (ActiveToggle or "Default"),
    Icon = ActiveToggle and "lucide:check-circle" or "lucide:circle",
})

-- ============================================================
-- UPDATE TAGS FOR ANIMATION STATUS
-- ============================================================

-- Add animation tag to existing tags
local AnimationTag = Window:Tag({
    Title = "Anim: " .. (ActiveToggle and "Custom" or "Default"),
    Icon = "lucide:activity",
    Color = ActiveToggle and Color3.fromHex("#AA00FF") or Color3.fromHex("#666666"),
    Radius = 8,
})

-- Update animation tag in real-time
task.spawn(function()
    while true do
        AnimationTag:SetTitle("Anim: " .. (ActiveToggle and "Custom" or "Default"))
        AnimationTag:SetColor(ActiveToggle and Color3.fromHex("#AA00FF") or Color3.fromHex("#666666"))
        task.wait(2)
    end
end)

local themes = {}
for themeName, _ in pairs(WindUI:GetThemes()) do
    table.insert(themes, themeName)
end
table.sort(themes)

local canchangetheme = true
local canchangedropdown = true

local themeDropdown = tampTab:Dropdown({
    Title = "Pilih tema",
    Values = themes,
    SearchBarEnabled = true,
    MenuWidth = 280,
    Value = "Dark",
    Callback = function(theme)
        canchangedropdown = false
        WindUI:SetTheme(theme)
        WindUI:Notify({
            Title = "Tema disesuaikan",
            Content = theme,
            Icon = "palette",
            Duration = 2
        })
        canchangedropdown = true
    end
})

local transparencySlider = tampTab:Slider({
    Title = "Transparasi",
    Value = { 
        Min = 0,
        Max = 1,
        Default = 0.2,
    },
    Step = 0.1,
    Callback = function(value)
        WindUI.TransparencyValue = tonumber(value)
        Window:ToggleTransparency(tonumber(value) > 0)
    end
})

local ThemeToggle = tampTab:Toggle({
    Title = "Enable Dark Mode",
    Desc = "Use dark color scheme",
    Value = true,
    Callback = function(state)
        if canchangetheme then
            WindUI:SetTheme(state and "Dark" or "Light")
        end
        if canchangedropdown then
            themeDropdown:Select(state and "Dark" or "Light")
        end
    end
})

WindUI:OnThemeChange(function(theme)
    canchangetheme = false
    ThemeToggle:Set(theme == "Dark")
    canchangetheme = true
end)


tampTab:Button({
    Title = "Create New Theme",
    Icon = "plus",
    Callback = function()
        Window:Dialog({
            Title = "Create Theme",
            Content = "This feature is coming soon!",
            Buttons = {
                {
                    Title = "OK",
                    Variant = "Primary"
                }
            }
        })
    end
})

-- Final notif
notify("Hirako", "Script sudan di load, gunakan dengan bijak.", 3)

pcall(function()
    Window:Show()
    MainTab:Show()
end)
