--// ⚡ Hirako | Script Loader (Resizable + Neon + Icon Toggle)
--// Dibuat oleh Hirako | Delta Executor Compatible

if game.CoreGui:FindFirstChild("HirakoLoader") then
    game.CoreGui.HirakoLoader:Destroy()
end

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "HirakoLoader"
ScreenGui.ResetOnSpawn = false

-- FRAME UTAMA
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 420, 0, 400)
Frame.Position = UDim2.new(0.5, -210, 0.5, -200)
Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

local UIStroke = Instance.new("UIStroke", Frame)
UIStroke.Thickness = 3
UIStroke.Color = Color3.fromRGB(160, 0, 255)
local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 12)

-- TITLE BAR
local TopBar = Instance.new("Frame", Frame)
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(20, 0, 40)
TopBar.BorderSizePixel = 0

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ Just Hirako | Auto Walk Loader"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(180, 0, 255)
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left

-- CLOSE BUTTON
local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 40, 1, 0)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "❌"
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.TextSize = 22
CloseBtn.Font = Enum.Font.GothamBold

-- RESIZE HANDLE
local ResizeHandle = Instance.new("Frame", Frame)
ResizeHandle.Size = UDim2.new(0, 22, 0, 22)
ResizeHandle.Position = UDim2.new(1, -22, 1, -22)
ResizeHandle.BackgroundColor3 = Color3.fromRGB(120, 0, 255)
ResizeHandle.BorderSizePixel = 0
ResizeHandle.Active = true
local corner = Instance.new("UICorner", ResizeHandle)
corner.CornerRadius = UDim.new(1, 0)

-- === DRAG RESIZE REAL-TIME ===
local resizing = false
local startPos
local startSize

ResizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizing = true
        startPos = input.Position
        startSize = Frame.AbsoluteSize
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - startPos
        local newX = math.max(300, startSize.X + delta.X)
        local newY = math.max(250, startSize.Y + delta.Y)
        Frame.Size = UDim2.new(0, newX, 0, newY)
        ResizeHandle.Position = UDim2.new(1, -22, 1, -22)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizing = false
    end
end)

-- HOLDER
local Holder = Instance.new("ScrollingFrame", Frame)
Holder.Size = UDim2.new(1, -20, 1, -80)
Holder.Position = UDim2.new(0, 10, 0, 60)
Holder.BackgroundTransparency = 1
Holder.ScrollBarThickness = 6
Holder.CanvasSize = UDim2.new(0, 0, 0, 0)
local UIListLayout = Instance.new("UIListLayout", Holder)
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function updateCanvas()
    Holder.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end
UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

-- SCRIPT LIST
local Scripts = {
    {Name = "Create Private Server", URL = "https://raw.githubusercontent.com/RullzsyHUB/roblox-scripts/refs/heads/main/RullzsyHUB%20-%20PRIVATE%20SERVER/main.lua"},
    {Name = "Mount Arunika", URL = "https://raw.githubusercontent.com/hirachix/robx/main/arunika.lua"},
    {Name = "Kota Bukan Gunung", URL = "https://raw.githubusercontent.com/hirachix/robx/main/kota.lua"},
    {Name = "Mount Atin", URL = "https://raw.githubusercontent.com/hirachix/robx/main/atin.lua"},
    {Name = "Mount Daun", URL = "https://raw.githubusercontent.com/hirachix/robx/main/daun.lua"},
    {Name = "Mount Pengangguran", URL = "https://raw.githubusercontent.com/hirachix/robx/main/pengangguran.lua"},
    {Name = "Mount Yahayuk V1", URL = "https://raw.githubusercontent.com/hirachix/robx/main/yahyuk.lua"},
   {Name = "Mount Yahayuk V2", URL = "https://raw.githubusercontent.com/hirachix/robx/main/yahyuk.lua"},
    {Name = "Mount HMMM", URL = "https://raw.githubusercontent.com/hirachix/robx/main/hmm.lua"},
    {Name = "Mount Setecu", URL = "https://raw.githubusercontent.com/hirachix/robx/main/hmm.lua"},
    {Name = "Mount Yntkts", URL = "https://raw.githubusercontent.com/hirachix/robx/main/yntkts.lua"},
    {Name = "Mount Yacape", URL = "https://raw.githubusercontent.com/hirachix/robx/main/yacape.lua"},
    {Name = "Mount Yukari", URL = "https://raw.githubusercontent.com/hirachix/robx/main/yukari.lua"},
    {Name = "NIGHTMARE EXPEDITION", URL = "https://raw.githubusercontent.com/hirachix/robx/main/night.lua"},
}

-- BUTTON
local function createButton(name, url)
    local btn = Instance.new("TextButton", Holder)
    btn.Size = UDim2.new(0, 340, 0, 42)
    btn.BackgroundColor3 = Color3.fromRGB(25, 0, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.Text = "▶ " .. string.upper(name)
    btn.TextSize = 18
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 8)
    local glow = Instance.new("UIStroke", btn)
    glow.Thickness = 1.5
    glow.Color = Color3.fromRGB(160, 0, 255)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(80, 0, 150)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(25, 0, 50)}):Play()
    end)

    btn.MouseButton1Click:Connect(function()
        Frame.Visible = false
        game.StarterGui:SetCore("SendNotification", {Title="Hirako Loader", Text="Memuat script " .. name .. "...", Duration=2})
        local s, e = pcall(function() loadstring(game:HttpGet(url))() end)
        if s then
            game.StarterGui:SetCore("SendNotification", {Title="Hirako Loader", Text="✅ Script " .. name .. " berhasil dijalankan!", Duration=3})
            ScreenGui:Destroy()
        else
            game.StarterGui:SetCore("SendNotification", {Title="Hirako Loader", Text="❌ Error: "..tostring(e), Duration=4})
            Frame.Visible = true
        end
    end)
end

for _,v in ipairs(Scripts) do
    createButton(v.Name, v.URL)
end

-- FOOTER
local Footer = Instance.new("TextLabel", Frame)
Footer.Size = UDim2.new(1, 0, 0, 28)
Footer.Position = UDim2.new(0, 0, 1, -28)
Footer.BackgroundTransparency = 1
Footer.Text = "Made by Hirako ⚡"
Footer.Font = Enum.Font.GothamSemibold
Footer.TextColor3 = Color3.fromRGB(160, 0, 255)
Footer.TextSize = 14

-- REOPEN ICON
local ReopenBtn = Instance.new("TextButton", ScreenGui)
ReopenBtn.Size = UDim2.new(0, 40, 0, 40)
ReopenBtn.Position = UDim2.new(0, 20, 0.8, 0)
ReopenBtn.BackgroundColor3 = Color3.fromRGB(25, 0, 50)
ReopenBtn.Text = "⚡"
ReopenBtn.TextColor3 = Color3.fromRGB(180, 0, 255)
ReopenBtn.Font = Enum.Font.GothamBold
ReopenBtn.TextSize = 24
ReopenBtn.Visible = false
local cornerR = Instance.new("UICorner", ReopenBtn)
cornerR.CornerRadius = UDim.new(1, 0)
local stroke = Instance.new("UIStroke", ReopenBtn)
stroke.Thickness = 1.5
stroke.Color = Color3.fromRGB(160, 0, 255)

CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(Frame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    wait(0.2)
    Frame.Visible = false
    ReopenBtn.Visible = true
end)
ReopenBtn.MouseButton1Click:Connect(function()
    ReopenBtn.Visible = false
    Frame.Visible = true
    TweenService:Create(Frame, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
end)

-- FADE IN
Frame.BackgroundTransparency = 1
TweenService:Create(Frame, TweenInfo.new(0.4), {BackgroundTransparency = 0}):Play()