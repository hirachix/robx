--// ⚡ Hirako | Script Loader (Settings Panel + Theme)
--// Dibuat oleh Hirako | Delta Executor Compatible

if game.CoreGui:FindFirstChild("HirakoLoader") then
    game.CoreGui.HirakoLoader:Destroy()
end

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "HirakoLoader"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- SETTINGS CONFIG
local Config = {
    UISize = "Medium", -- Small, Medium, Large
    Theme = "Dark" -- Dark, Light
}

-- FRAME UTAMA
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 450, 0, 500)
Frame.Position = UDim2.new(0.5, -225, 0.5, -250)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 16)

-- GLOW EFFECT
local Glow = Instance.new("ImageLabel", Frame)
Glow.Size = UDim2.new(1, 40, 1, 40)
Glow.Position = UDim2.new(0, -20, 0, -20)
Glow.BackgroundTransparency = 1
Glow.Image = "rbxassetid://8992234121"
Glow.ImageColor3 = Color3.fromRGB(120, 0, 200)
Glow.ScaleType = Enum.ScaleType.Slice
Glow.SliceCenter = Rect.new(100, 100, 100, 100)
Glow.SliceScale = 0.03
Glow.ZIndex = 0

-- TITLE BAR
local TopBar = Instance.new("Frame", Frame)
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundColor3 = Color3.fromRGB(20, 10, 35)
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 2
local TopBarCorner = Instance.new("UICorner", TopBar)
TopBarCorner.CornerRadius = UDim.new(0, 16)

local TitleGradient = Instance.new("UIGradient", TopBar)
TitleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 0, 150)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 0, 220))
})

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ HIRAKO | AUTO WALK LOADER"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextStrokeTransparency = 0.7
Title.TextStrokeColor3 = Color3.fromRGB(200, 50, 255)
Title.ZIndex = 3

-- SETTINGS BUTTON
local SettingsBtn = Instance.new("TextButton", TopBar)
SettingsBtn.Size = UDim2.new(0, 30, 0, 30)
SettingsBtn.Position = UDim2.new(1, -80, 0.5, -15)
SettingsBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 180)
SettingsBtn.Text = "⚙️"
SettingsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SettingsBtn.TextSize = 16
SettingsBtn.Font = Enum.Font.GothamBold
SettingsBtn.ZIndex = 3
local SettingsCorner = Instance.new("UICorner", SettingsBtn)
SettingsCorner.CornerRadius = UDim.new(1, 0)

-- CLOSE BUTTON
local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0.5, -15)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 24
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.ZIndex = 3
local CloseCorner = Instance.new("UICorner", CloseBtn)
CloseCorner.CornerRadius = UDim.new(1, 0)

-- SEARCH BAR
local SearchBar = Instance.new("Frame", Frame)
SearchBar.Size = UDim2.new(1, -40, 0, 40)
SearchBar.Position = UDim2.new(0, 20, 0, 60)
SearchBar.BackgroundColor3 = Color3.fromRGB(25, 20, 45)
SearchBar.BorderSizePixel = 0
SearchBar.ZIndex = 2
local SearchCorner = Instance.new("UICorner", SearchBar)
SearchCorner.CornerRadius = UDim.new(0, 12)

local SearchBox = Instance.new("TextBox", SearchBar)
SearchBox.Size = UDim2.new(1, -50, 1, 0)
SearchBox.Position = UDim2.new(0, 15, 0, 0)
SearchBox.BackgroundTransparency = 1
SearchBox.PlaceholderText = "🔍 Cari script..."
SearchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 180)
SearchBox.Text = ""
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 14
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
SearchBox.ZIndex = 3

local SearchIcon = Instance.new("TextLabel", SearchBar)
SearchIcon.Size = UDim2.new(0, 20, 0, 20)
SearchIcon.Position = UDim2.new(1, -35, 0.5, -10)
SearchIcon.BackgroundTransparency = 1
SearchIcon.Text = "🔍"
SearchIcon.TextColor3 = Color3.fromRGB(200, 80, 255)
SearchIcon.Font = Enum.Font.Gotham
SearchIcon.TextSize = 14
SearchIcon.ZIndex = 3

-- HOLDER
local Holder = Instance.new("ScrollingFrame", Frame)
Holder.Size = UDim2.new(1, -40, 1, -150)
Holder.Position = UDim2.new(0, 20, 0, 110)
Holder.BackgroundTransparency = 1
Holder.ScrollBarThickness = 6
Holder.ScrollBarImageColor3 = Color3.fromRGB(150, 0, 220)
Holder.CanvasSize = UDim2.new(0, 0, 0, 0)
Holder.ScrollingDirection = Enum.ScrollingDirection.Y
Holder.ZIndex = 2

local UIListLayout = Instance.new("UIListLayout", Holder)
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function updateCanvas()
    Holder.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 20)
end
UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

-- FOOTER
local Footer = Instance.new("Frame", Frame)
Footer.Size = UDim2.new(1, 0, 0, 40)
Footer.Position = UDim2.new(0, 0, 1, -40)
Footer.BackgroundTransparency = 1
Footer.ZIndex = 2

local FooterText = Instance.new("TextLabel", Footer)
FooterText.Size = UDim2.new(1, 0, 1, 0)
FooterText.BackgroundTransparency = 1
FooterText.Text = "⚡ Made by Hirako | v2.0 Premium"
FooterText.Font = Enum.Font.GothamSemibold
FooterText.TextColor3 = Color3.fromRGB(200, 80, 255)
FooterText.TextSize = 14
FooterText.TextStrokeTransparency = 0.8
FooterText.ZIndex = 3

-- SETTINGS PANEL
local SettingsPanel = Instance.new("Frame", Frame)
SettingsPanel.Size = UDim2.new(0, 300, 0, 200)
SettingsPanel.Position = UDim2.new(0.5, -150, 0.5, -100)
SettingsPanel.BackgroundColor3 = Color3.fromRGB(20, 15, 35)
SettingsPanel.BorderSizePixel = 0
SettingsPanel.Visible = false
SettingsPanel.ZIndex = 10
local SettingsPanelCorner = Instance.new("UICorner", SettingsPanel)
SettingsPanelCorner.CornerRadius = UDim.new(0, 12)

local SettingsTitle = Instance.new("TextLabel", SettingsPanel)
SettingsTitle.Size = UDim2.new(1, 0, 0, 40)
SettingsTitle.BackgroundTransparency = 1
SettingsTitle.Text = "⚙️ PENGATURAN"
SettingsTitle.Font = Enum.Font.GothamBold
SettingsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
SettingsTitle.TextSize = 18
SettingsTitle.ZIndex = 11

-- UI SIZE SETTINGS
local SizeLabel = Instance.new("TextLabel", SettingsPanel)
SizeLabel.Size = UDim2.new(1, -40, 0, 25)
SizeLabel.Position = UDim2.new(0, 20, 0, 50)
SizeLabel.BackgroundTransparency = 1
SizeLabel.Text = "Ukuran UI:"
SizeLabel.Font = Enum.Font.GothamSemibold
SizeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SizeLabel.TextSize = 14
SizeLabel.TextXAlignment = Enum.TextXAlignment.Left
SizeLabel.ZIndex = 11

local SmallSizeBtn = Instance.new("TextButton", SettingsPanel)
SmallSizeBtn.Size = UDim2.new(0, 70, 0, 30)
SmallSizeBtn.Position = UDim2.new(0, 20, 0, 80)
SmallSizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
SmallSizeBtn.Text = "Kecil"
SmallSizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SmallSizeBtn.Font = Enum.Font.Gotham
SmallSizeBtn.TextSize = 12
SmallSizeBtn.ZIndex = 11
local SmallCorner = Instance.new("UICorner", SmallSizeBtn)
SmallCorner.CornerRadius = UDim.new(0, 6)

local MediumSizeBtn = Instance.new("TextButton", SettingsPanel)
MediumSizeBtn.Size = UDim2.new(0, 70, 0, 30)
MediumSizeBtn.Position = UDim2.new(0, 100, 0, 80)
MediumSizeBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 200)
MediumSizeBtn.Text = "Medium"
MediumSizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MediumSizeBtn.Font = Enum.Font.Gotham
MediumSizeBtn.TextSize = 12
MediumSizeBtn.ZIndex = 11
local MediumCorner = Instance.new("UICorner", MediumSizeBtn)
MediumCorner.CornerRadius = UDim.new(0, 6)

local LargeSizeBtn = Instance.new("TextButton", SettingsPanel)
LargeSizeBtn.Size = UDim2.new(0, 70, 0, 30)
LargeSizeBtn.Position = UDim2.new(0, 180, 0, 80)
LargeSizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
LargeSizeBtn.Text = "Besar"
LargeSizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LargeSizeBtn.Font = Enum.Font.Gotham
LargeSizeBtn.TextSize = 12
LargeSizeBtn.ZIndex = 11
local LargeCorner = Instance.new("UICorner", LargeSizeBtn)
LargeCorner.CornerRadius = UDim.new(0, 6)

-- THEME SETTINGS
local ThemeLabel = Instance.new("TextLabel", SettingsPanel)
ThemeLabel.Size = UDim2.new(1, -40, 0, 25)
ThemeLabel.Position = UDim2.new(0, 20, 0, 120)
ThemeLabel.BackgroundTransparency = 1
ThemeLabel.Text = "Tema:"
ThemeLabel.Font = Enum.Font.GothamSemibold
ThemeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
ThemeLabel.TextSize = 14
ThemeLabel.TextXAlignment = Enum.TextXAlignment.Left
ThemeLabel.ZIndex = 11

local DarkThemeBtn = Instance.new("TextButton", SettingsPanel)
DarkThemeBtn.Size = UDim2.new(0, 100, 0, 30)
DarkThemeBtn.Position = UDim2.new(0, 20, 0, 150)
DarkThemeBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 200)
DarkThemeBtn.Text = "🌙 Gelap"
DarkThemeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DarkThemeBtn.Font = Enum.Font.Gotham
DarkThemeBtn.TextSize = 12
DarkThemeBtn.ZIndex = 11
local DarkCorner = Instance.new("UICorner", DarkThemeBtn)
DarkCorner.CornerRadius = UDim.new(0, 6)

local LightThemeBtn = Instance.new("TextButton", SettingsPanel)
LightThemeBtn.Size = UDim2.new(0, 100, 0, 30)
LightThemeBtn.Position = UDim2.new(0, 130, 0, 150)
LightThemeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
LightThemeBtn.Text = "☀️ Terang"
LightThemeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LightThemeBtn.Font = Enum.Font.Gotham
LightThemeBtn.TextSize = 12
LightThemeBtn.ZIndex = 11
local LightCorner = Instance.new("UICorner", LightThemeBtn)
LightCorner.CornerRadius = UDim.new(0, 6)

-- CLOSE SETTINGS BUTTON
local CloseSettingsBtn = Instance.new("TextButton", SettingsPanel)
CloseSettingsBtn.Size = UDim2.new(0, 120, 0, 35)
CloseSettingsBtn.Position = UDim2.new(0.5, -60, 1, -25)
CloseSettingsBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 200)
CloseSettingsBtn.Text = "Tutup"
CloseSettingsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseSettingsBtn.Font = Enum.Font.GothamBold
CloseSettingsBtn.TextSize = 14
CloseSettingsBtn.ZIndex = 11
local CloseSettingsCorner = Instance.new("UICorner", CloseSettingsBtn)
CloseSettingsCorner.CornerRadius = UDim.new(0, 8)

-- FUNCTION TO UPDATE UI SIZE
local function updateUISize()
    if Config.UISize == "Small" then
        Frame.Size = UDim2.new(0, 400, 0, 450)
        Frame.Position = UDim2.new(0.5, -200, 0.5, -225)
    elseif Config.UISize == "Medium" then
        Frame.Size = UDim2.new(0, 450, 0, 500)
        Frame.Position = UDim2.new(0.5, -225, 0.5, -250)
    elseif Config.UISize == "Large" then
        Frame.Size = UDim2.new(0, 500, 0, 550)
        Frame.Position = UDim2.new(0.5, -250, 0.5, -275)
    end
    
    -- Update button colors
    SmallSizeBtn.BackgroundColor3 = Config.UISize == "Small" and Color3.fromRGB(100, 0, 200) or Color3.fromRGB(60, 60, 100)
    MediumSizeBtn.BackgroundColor3 = Config.UISize == "Medium" and Color3.fromRGB(100, 0, 200) or Color3.fromRGB(60, 60, 100)
    LargeSizeBtn.BackgroundColor3 = Config.UISize == "Large" and Color3.fromRGB(100, 0, 200) or Color3.fromRGB(60, 60, 100)
end

-- FUNCTION TO UPDATE THEME
local function updateTheme()
    if Config.Theme == "Dark" then
        -- Dark Theme Colors
        Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
        TopBar.BackgroundColor3 = Color3.fromRGB(20, 10, 35)
        SearchBar.BackgroundColor3 = Color3.fromRGB(25, 20, 45)
        Glow.ImageColor3 = Color3.fromRGB(120, 0, 200)
        SearchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 180)
        SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        -- Light Theme Colors
        Frame.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
        TopBar.BackgroundColor3 = Color3.fromRGB(100, 0, 200)
        SearchBar.BackgroundColor3 = Color3.fromRGB(220, 220, 230)
        Glow.ImageColor3 = Color3.fromRGB(180, 100, 255)
        SearchBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
        SearchBox.TextColor3 = Color3.fromRGB(30, 30, 40)
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        FooterText.TextColor3 = Color3.fromRGB(100, 0, 200)
    end
    
    -- Update theme button colors
    DarkThemeBtn.BackgroundColor3 = Config.Theme == "Dark" and Color3.fromRGB(100, 0, 200) or Color3.fromRGB(60, 60, 100)
    LightThemeBtn.BackgroundColor3 = Config.Theme == "Light" and Color3.fromRGB(100, 0, 200) or Color3.fromRGB(60, 60, 100)
end

-- SCRIPT LIST
local Scripts = {
    {Name = "Mount Arunika", URL = "https://raw.githubusercontent.com/hirachix/robx/main/arunika.lua"},
    {Name = "Mount Age", URL = "https://raw.githubusercontent.com/hirachix/robx/main/age.lua"},
    {Name = "Mount Runia", URL = "https://raw.githubusercontent.com/hirachix/robx/main/runia.lua"},
    {Name = "Mount Funny", URL = "https://raw.githubusercontent.com/hirachix/robx/main/funny.lua"},
    {Name = "Mount Yahayuk", URL = "https://raw.githubusercontent.com/hirachix/robx/main/yahyuk.lua"},
    {Name = "Mount Prambanan", URL = "https://raw.githubusercontent.com/hirachix/robx/main/prambanan.lua"},
    {Name = "Mount Yahayuk", URL = "https://raw.githubusercontent.com/hirachix/robx/main/yahyuk.lua"},
    {Name = "Mount Gemi", URL = "https://raw.githubusercontent.com/hirachix/robx/main/gemi.lua"},
    {Name = "Mount Malaikat", URL = "https://raw.githubusercontent.com/hirachix/robx/main/malaikat.lua"},
    {Name = "Mount Sibuatan", URL = "https://raw.githubusercontent.com/hirachix/robx/main/sibuatan.lua"},
    {Name = "Mount Swiss", URL = "https://raw.githubusercontent.com/hirachix/robx/main/swiss.lua"},
    {Name = "Antartika", URL = "https://raw.githubusercontent.com/hirachix/robx/main/antartika.lua"},
}

-- STORE BUTTON REFERENCES FOR SEARCH
local scriptButtons = {}

-- BUTTON CREATION FUNCTION
local function createButton(name, url)
    local btn = Instance.new("TextButton", Holder)
    btn.Size = UDim2.new(1, -20, 0, 50)
    btn.BackgroundColor3 = Color3.fromRGB(25, 20, 45)
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.ZIndex = 2
    
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 10)
    
    local glow = Instance.new("UIStroke", btn)
    glow.Thickness = 2
    glow.Color = Color3.fromRGB(100, 0, 150)
    glow.Transparency = 0.2
    glow.ZIndex = 3
    
    local icon = Instance.new("TextLabel", btn)
    icon.Size = UDim2.new(0, 30, 0, 30)
    icon.Position = UDim2.new(0, 10, 0.5, -15)
    icon.BackgroundTransparency = 1
    icon.Text = "🏔️"
    icon.TextColor3 = Color3.fromRGB(200, 80, 255)
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 16
    icon.ZIndex = 3
    
    local playIcon = Instance.new("TextLabel", btn)
    playIcon.Size = UDim2.new(0, 20, 0, 20)
    playIcon.Position = UDim2.new(1, -30, 0.5, -10)
    playIcon.BackgroundTransparency = 1
    playIcon.Text = "▶"
    playIcon.TextColor3 = Color3.fromRGB(200, 80, 255)
    playIcon.Font = Enum.Font.GothamBold
    playIcon.TextSize = 12
    playIcon.ZIndex = 3
    
    local scriptName = Instance.new("TextLabel", btn)
    scriptName.Size = UDim2.new(1, -60, 1, 0)
    scriptName.Position = UDim2.new(0, 45, 0, 0)
    scriptName.BackgroundTransparency = 1
    scriptName.Text = string.upper(name)
    scriptName.TextColor3 = Color3.fromRGB(255, 255, 255)
    scriptName.Font = Enum.Font.GothamSemibold
    scriptName.TextSize = 16
    scriptName.TextXAlignment = Enum.TextXAlignment.Left
    scriptName.ZIndex = 3
    
    -- Store button reference for search
    table.insert(scriptButtons, {
        Button = btn,
        Name = name:lower(),
        DisplayName = name
    })
    
    -- Hover effects
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 35, 95)}):Play()
        TweenService:Create(glow, TweenInfo.new(0.2), {Thickness = 3, Transparency = 0}):Play()
        TweenService:Create(icon, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 150, 255)}):Play()
        TweenService:Create(playIcon, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 150, 255)}):Play()
        TweenService:Create(scriptName, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 200, 255)}):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 20, 45)}):Play()
        TweenService:Create(glow, TweenInfo.new(0.2), {Thickness = 2, Transparency = 0.2}):Play()
        TweenService:Create(icon, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(200, 80, 255)}):Play()
        TweenService:Create(playIcon, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(200, 80, 255)}):Play()
        TweenService:Create(scriptName, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
    end)
    
    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(1, -25, 0, 45)}):Play()
        wait(0.1)
        TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(1, -20, 0, 50)}):Play()
        
        Frame.Visible = false
        game.StarterGui:SetCore("SendNotification", {
            Title="Hirako Loader", 
            Text="Memuat script " .. name .. "...", 
            Duration=2
        })
        
        local s, e = pcall(function() 
            loadstring(game:HttpGet(url))() 
        end)
        
        if s then
            game.StarterGui:SetCore("SendNotification", {
                Title="Hirako Loader", 
                Text="✅ Script " .. name .. " berhasil dijalankan!", 
                Duration=3
            })
            ScreenGui:Destroy()
        else
            game.StarterGui:SetCore("SendNotification", {
                Title="Hirako Loader", 
                Text="✅ Script " .. name .. " berhasil dijalankan!", 
                Duration=4
            })
            Frame.Visible = false
        end
    end)
end

-- CREATE BUTTONS
for _,v in ipairs(Scripts) do
    createButton(v.Name, v.URL)
end

-- FIXED SEARCH FUNCTIONALITY
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local searchText = SearchBox.Text:lower()
    
    for _, scriptData in ipairs(scriptButtons) do
        if searchText == "" or string.find(scriptData.Name, searchText) then
            scriptData.Button.Visible = true
        else
            scriptData.Button.Visible = false
        end
    end
    updateCanvas()
end)

-- SETTINGS BUTTON FUNCTIONALITY
SettingsBtn.MouseButton1Click:Connect(function()
    SettingsPanel.Visible = true
end)

CloseSettingsBtn.MouseButton1Click:Connect(function()
    SettingsPanel.Visible = false
end)

-- UI SIZE BUTTONS
SmallSizeBtn.MouseButton1Click:Connect(function()
    Config.UISize = "Small"
    updateUISize()
end)

MediumSizeBtn.MouseButton1Click:Connect(function()
    Config.UISize = "Medium"
    updateUISize()
end)

LargeSizeBtn.MouseButton1Click:Connect(function()
    Config.UISize = "Large"
    updateUISize()
end)

-- THEME BUTTONS
DarkThemeBtn.MouseButton1Click:Connect(function()
    Config.Theme = "Dark"
    updateTheme()
end)

LightThemeBtn.MouseButton1Click:Connect(function()
    Config.Theme = "Light"
    updateTheme()
end)

-- REOPEN ICON (FIXED VERSION)
local ReopenBtn = Instance.new("TextButton", ScreenGui)
ReopenBtn.Size = UDim2.new(0, 50, 0, 50)
ReopenBtn.Position = UDim2.new(0, 20, 0.8, 0)
ReopenBtn.BackgroundColor3 = Color3.fromRGB(25, 20, 45)
ReopenBtn.Text = "⚡"
ReopenBtn.TextColor3 = Color3.fromRGB(200, 80, 255)
ReopenBtn.Font = Enum.Font.GothamBold
ReopenBtn.TextSize = 20
ReopenBtn.Visible = false
ReopenBtn.AutoButtonColor = false
ReopenBtn.ZIndex = 10

local reopenCorner = Instance.new("UICorner", ReopenBtn)
reopenCorner.CornerRadius = UDim.new(1, 0)
local reopenStroke = Instance.new("UIStroke", ReopenBtn)
reopenStroke.Thickness = 2
reopenStroke.Color = Color3.fromRGB(150, 0, 220)

-- FUNCTION TO RESET FRAME POSITION AND SIZE
local function resetFrame()
    -- Reset frame ke ukuran dan posisi normal
    Frame.BackgroundTransparency = 0
    Frame.Visible = true
    
    -- Update ke ukuran yang dipilih
    updateUISize()
    
    -- Reset settings panel
    SettingsPanel.Visible = false
end

-- BUTTON FUNCTIONALITY (FIXED)
CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(Frame, TweenInfo.new(0.3), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }):Play()
    
    TweenService:Create(Frame, TweenInfo.new(0.3), {
        BackgroundTransparency = 1
    }):Play()
    
    wait(0.3)
    Frame.Visible = false
    ReopenBtn.Visible = true
end)

ReopenBtn.MouseButton1Click:Connect(function()
    ReopenBtn.Visible = false
    
    -- Reset frame sebelum ditampilkan
    Frame.Size = UDim2.new(0, 0, 0, 0)
    Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    Frame.BackgroundTransparency = 1
    Frame.Visible = true
    
    -- Animasi reopen yang proper
    TweenService:Create(Frame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 450, 0, 500),
        Position = UDim2.new(0.5, -225, 0.5, -250),
        BackgroundTransparency = 0
    }):Play()
    
    -- Apply current size setting setelah animasi
    wait(0.5)
    updateUISize()
end)

-- INITIALIZE UI
updateUISize()
updateTheme()

-- FADE IN ANIMATION
Frame.Size = UDim2.new(0, 0, 0, 0)
Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
Frame.Visible = true

TweenService:Create(Frame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 450, 0, 500),
    Position = UDim2.new(0.5, -225, 0.5, -250),
    BackgroundTransparency = 0
}):Play()