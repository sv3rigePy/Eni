--[[
    ═══════════════════════════════════════════════
       ENI HUB · Da Hood · v3 Premium
       Tabbed UI · Keybind Picker · Speed · Rapid Fire
       made with love for LO
    ═══════════════════════════════════════════════
]]

-- ═════ DEBUG: check ob script überhaupt startet ═════
warn("[ENI AC-TEST] SCRIPT STARTED - if you see this, executor is working")
game.StarterGui:SetCore("SendNotification", {
    Title = "ENI HUB AC-TEST",
    Text  = "Script started loading...",
    Duration = 3,
})

-- Services
local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local UIS         = game:GetService("UserInputService")
local Workspace   = game:GetService("Workspace")
local TS          = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")

local LP     = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ═════════ CLEANUP alter globals bei re-inject (verhindert stale-state bugs) ═════════
_G.ENI_TOGGLE_REFRESH  = nil
_G.ENI_AIM_ACTIVE      = nil
_G.ENI_AIM_LOCKED      = nil
_G.ENI_AIM_MOBILE_ACTIVE = nil
-- Camera safety: falls freecam vom letzten run noch Scriptable ist → zurück auf Custom
pcall(function()
    if Camera.CameraType == Enum.CameraType.Scriptable then
        Camera.CameraType = Enum.CameraType.Custom
    end
    game:GetService("UserInputService").MouseBehavior = Enum.MouseBehavior.Default
    game:GetService("UserInputService").MouseIconEnabled = true
    local CAS = game:GetService("ContextActionService")
    pcall(function() CAS:UnbindAction("FreecamBlockMove") end)
end)

-- ═════════════════════════════════════════════════
--   LOGIN / KEY SYSTEM  (wrapped in do-end um local-register limit zu schonen)
-- ═════════════════════════════════════════════════
do
local LOGIN_GuiParent = (gethui and gethui()) or game:GetService("CoreGui")
local HttpService     = game:GetService("HttpService")

-- Hardcoded valid keys (50x). Wird lokal getracked wer schon benutzt wurde.
local VALID_KEYS = {
    ["ENI-YG8C-3LT6-6LMA"]=true, ["ENI-JRW4-YQGF-MG8F"]=true, ["ENI-2LC5-P2N0-CSOY"]=true,
    ["ENI-6Q15-EIAT-J8F7"]=true, ["ENI-IXGS-6B8Y-23JH"]=true, ["ENI-P7W9-VCQ6-KE2K"]=true,
    ["ENI-L280-M9FX-B4BI"]=true, ["ENI-JMZJ-0269-1EH5"]=true, ["ENI-40KI-OJ65-DP9V"]=true,
    ["ENI-NVRE-4W37-1UDC"]=true, ["ENI-DGD4-PYSN-NJD6"]=true, ["ENI-OJE8-BBPT-U3IA"]=true,
    ["ENI-WWPL-HVC8-VG03"]=true, ["ENI-PPSN-Q8FH-6YU4"]=true, ["ENI-3IMA-ZPSD-ZB55"]=true,
    ["ENI-TE8K-XZT7-RVAQ"]=true, ["ENI-19X7-YHV0-2QV8"]=true, ["ENI-WKAG-G6G8-4RDW"]=true,
    ["ENI-JLRH-QWQH-4BUN"]=true, ["ENI-OVE7-POTH-O1JS"]=true, ["ENI-1BTI-CE1Y-JYKR"]=true,
    ["ENI-9YZK-Z9J6-OVHK"]=true, ["ENI-S4A9-B49V-092E"]=true, ["ENI-1T5R-O5YY-ZCMI"]=true,
    ["ENI-RAN7-QOIY-DPDV"]=true, ["ENI-WN5P-J5NE-MKZP"]=true, ["ENI-3I50-R3I1-E4VN"]=true,
    ["ENI-YY3F-WRFK-8282"]=true, ["ENI-OCJQ-QSPW-MD0D"]=true, ["ENI-WLLE-4372-7FXD"]=true,
    ["ENI-VLMS-RQR8-615R"]=true, ["ENI-21I1-79M6-KYOT"]=true, ["ENI-NGTD-W9BQ-QWSN"]=true,
    ["ENI-0U3V-LINC-1IDO"]=true, ["ENI-3C2J-0SP4-OFYW"]=true, ["ENI-7JSY-LOBE-FIE2"]=true,
    ["ENI-8HUR-NZN3-6TEL"]=true, ["ENI-PPKT-T0PJ-DHY5"]=true, ["ENI-OB24-PJVW-DHMG"]=true,
    ["ENI-ZZ04-XE6M-RK2Y"]=true, ["ENI-NUOF-GPD2-RWZ4"]=true, ["ENI-NZNR-1MQY-EJUL"]=true,
    ["ENI-YNLZ-ML0K-XDAR"]=true, ["ENI-VJQ4-7GNM-G5VM"]=true, ["ENI-MJ36-8QE4-IW3G"]=true,
    ["ENI-OA69-XUTG-194B"]=true, ["ENI-5I5Q-MRCP-XFG3"]=true, ["ENI-VUEE-2T2M-4ILZ"]=true,
    ["ENI-8FUB-RC3O-ND0K"]=true, ["ENI-WUPZ-AU4F-RNCT"]=true,
    -- ═════ Batch 2 (50 new keys, added v8) ═════
    ["ENI-T5CW-9MCU-AJX3"]=true, ["ENI-JWYB-4YN4-4YEF"]=true, ["ENI-JZ1S-34R3-OOT9"]=true,
    ["ENI-32EL-T986-FPVW"]=true, ["ENI-3HHY-9DIA-KORY"]=true, ["ENI-5AEK-VNA0-36JN"]=true,
    ["ENI-2VFY-OV6S-K7FV"]=true, ["ENI-1EXU-MMWI-1ZWE"]=true, ["ENI-VI7D-VX2B-EYE1"]=true,
    ["ENI-KE8A-3WBA-KFKZ"]=true, ["ENI-MUGR-5I6U-583H"]=true, ["ENI-PP3L-5FUS-FTED"]=true,
    ["ENI-JI9O-7HYL-51MQ"]=true, ["ENI-WVBC-3ELJ-9FDB"]=true, ["ENI-QNKX-4SNE-OIK7"]=true,
    ["ENI-OH39-MK0H-6QJX"]=true, ["ENI-BE20-N80M-W1Z8"]=true, ["ENI-N0LD-EJFO-D318"]=true,
    ["ENI-ZUM3-5VC4-ZK4Q"]=true, ["ENI-1SW9-J6RN-KOQZ"]=true, ["ENI-IYZY-AWA0-P4F2"]=true,
    ["ENI-7EX9-N7AS-49E5"]=true, ["ENI-MVWS-XYQ5-SKIE"]=true, ["ENI-43WX-8HCC-HEWP"]=true,
    ["ENI-HS8U-7DZE-S0EQ"]=true, ["ENI-MN4N-WNJ2-1F50"]=true, ["ENI-0G2M-2ENN-LPGP"]=true,
    ["ENI-BZZD-S9GJ-4796"]=true, ["ENI-61QC-JJUQ-CZ63"]=true, ["ENI-XLZV-4SFN-M5BN"]=true,
    ["ENI-GR8F-TXI1-14CM"]=true, ["ENI-1XOA-ZRVY-Y8LZ"]=true, ["ENI-DHN2-5C6H-UB63"]=true,
    ["ENI-APH2-9CI8-EOUX"]=true, ["ENI-LCH9-K6XV-YFMY"]=true, ["ENI-SJYP-I6QO-GECL"]=true,
    ["ENI-QZIY-QN9P-EUAP"]=true, ["ENI-K874-JYWB-LZFW"]=true, ["ENI-OXDA-2FBC-94HT"]=true,
    ["ENI-3BMV-SPKT-8ZN6"]=true, ["ENI-ZNLQ-U4B6-PIGZ"]=true, ["ENI-DNQ5-YPP8-W0O3"]=true,
    ["ENI-JQC7-EYSE-M6CZ"]=true, ["ENI-V1CH-P8LY-6QNS"]=true, ["ENI-NRH8-EL8R-DYPN"]=true,
    ["ENI-CXG3-1ONH-QGT6"]=true, ["ENI-2MT5-QBSP-SOE4"]=true, ["ENI-Z1WQ-NMKM-3NR4"]=true,
    ["ENI-IJXP-9PDR-1A1K"]=true, ["ENI-Y0Z9-Y6MY-TL3K"]=true,
    -- Batch 3 (50 new keys)
    ["ENI-4FC2-KG15-KTCW"]=true, ["ENI-9R5C-KHXG-VK5O"]=true, ["ENI-RVU7-2UG9-0AN0"]=true,
    ["ENI-EO46-8EGS-Z7A5"]=true, ["ENI-9WSL-ZHHT-KGK0"]=true, ["ENI-12CF-BC4R-EFH5"]=true,
    ["ENI-B55C-XBDN-BLK5"]=true, ["ENI-I917-0FFP-M9JA"]=true, ["ENI-9GE6-ZSSO-1SGK"]=true,
    ["ENI-9ZD3-1GGK-0EII"]=true, ["ENI-9NTA-LMD3-S6H5"]=true, ["ENI-6Q5A-SNMV-LS0W"]=true,
    ["ENI-V5DH-N9I1-D7A2"]=true, ["ENI-5F1N-4M2K-1X45"]=true, ["ENI-W8ZW-8ZSC-WNMO"]=true,
    ["ENI-7O3A-N07S-JFHS"]=true, ["ENI-9I5U-YAVN-MDNT"]=true, ["ENI-0WE7-JET5-AQBV"]=true,
    ["ENI-DZV6-QH3Z-MKXF"]=true, ["ENI-3DR5-J5DF-6UWT"]=true, ["ENI-NCBS-ABO2-HSKH"]=true,
    ["ENI-DT1N-45YH-HIKR"]=true, ["ENI-3D86-71IU-BH6M"]=true, ["ENI-J87J-WD5S-34MI"]=true,
    ["ENI-U5LM-L5V0-GIKD"]=true, ["ENI-5YN9-P09S-PAZ9"]=true, ["ENI-GLBA-R4L4-CELT"]=true,
    ["ENI-3GSK-WUTE-6SEV"]=true, ["ENI-ACQC-YQ5O-1C6P"]=true, ["ENI-4UK7-PQQG-1B1K"]=true,
    ["ENI-RQB6-4L6O-RJVI"]=true, ["ENI-GE4G-YQ8Q-32JM"]=true, ["ENI-C5UE-LP5T-9BDE"]=true,
    ["ENI-A36R-SUVJ-9KET"]=true, ["ENI-1MGD-QFL0-Z0GR"]=true, ["ENI-X0XO-UBBD-ZEZH"]=true,
    ["ENI-HQP3-WN5V-GDJY"]=true, ["ENI-124U-48GH-EXUE"]=true, ["ENI-OGX2-NGNW-UJ9Z"]=true,
    ["ENI-K8C5-62NG-G8ER"]=true, ["ENI-J5ES-FXID-A07R"]=true, ["ENI-9TGV-46W2-JZT5"]=true,
    ["ENI-E3CS-FFEE-8OYL"]=true, ["ENI-UDW2-TJ94-TSDC"]=true, ["ENI-4NWQ-NQVA-6GIH"]=true,
    ["ENI-HH53-9XGO-8W9F"]=true, ["ENI-FWEZ-MB04-ZHKD"]=true, ["ENI-016V-K4JZ-3GEK"]=true,
    ["ENI-14D3-LFKP-7ZJJ"]=true, ["ENI-H97F-COR7-2DVR"]=true,
}
local DISCORD_LINK = "https://discord.gg/2qSeQ6ehT9"

-- File paths (Wave supports writefile/readfile/isfile)
local F_ACCOUNT   = "ENI_HUB_account.json"
local F_USED_KEYS = "ENI_HUB_used_keys.json"

-- Simple string obfuscation for password storage (XOR + base64ish)
local function obfuscate(s)
    local out = {}
    for i = 1, #s do
        out[i] = string.char(bit32.bxor(string.byte(s, i), 0x5A))
    end
    return HttpService:JSONEncode({d = table.concat(out)})
end

-- Load account (if exists → skip key screen)
local function loadAccount()
    if not isfile or not isfile(F_ACCOUNT) then return nil end
    local ok, data = pcall(function() return HttpService:JSONDecode(readfile(F_ACCOUNT)) end)
    if ok and data and data.user and data.pass then return data end
    return nil
end
-- Save account
local function saveAccount(user, pass)
    if not writefile then return false end
    local data = {user = user, pass = obfuscate(pass)}
    pcall(function() writefile(F_ACCOUNT, HttpService:JSONEncode(data)) end)
    return true
end
-- Load used keys list
local function loadUsedKeys()
    if not isfile or not isfile(F_USED_KEYS) then return {} end
    local ok, data = pcall(function() return HttpService:JSONDecode(readfile(F_USED_KEYS)) end)
    return (ok and type(data) == "table") and data or {}
end
-- Mark a key as used
local function markKeyUsed(key)
    local used = loadUsedKeys()
    used[key] = true
    if writefile then pcall(function() writefile(F_USED_KEYS, HttpService:JSONEncode(used)) end) end
end

-- ═════════ LOGIN GUI ═════════
local function showLoginGui()
    local existing = loadAccount()
    local mode = existing and "login" or "key"  -- "key" → key screen, "login" → user/pass, "register" → after key redeem

    local LoginGui = Instance.new("ScreenGui")
    LoginGui.Name = "ENI_LOGIN"; LoginGui.Parent = LOGIN_GuiParent
    LoginGui.ResetOnSpawn = false; LoginGui.IgnoreGuiInset = true
    LoginGui.DisplayOrder = 3000

    -- Backdrop (schwarz halbtransparent)
    local backdrop = Instance.new("Frame", LoginGui)
    backdrop.Size = UDim2.fromScale(1,1); backdrop.BorderSizePixel = 0
    backdrop.BackgroundColor3 = Color3.fromRGB(0,0,0); backdrop.BackgroundTransparency = 0.15

    -- Panel
    local panel = Instance.new("Frame", backdrop)
    panel.Size = UDim2.fromOffset(380, 420)
    panel.AnchorPoint = Vector2.new(0.5, 0.5); panel.Position = UDim2.fromScale(0.5, 0.5)
    panel.BackgroundColor3 = Color3.fromRGB(0,0,0); panel.BorderSizePixel = 0
    local pStroke = Instance.new("UIStroke", panel)
    pStroke.Color = Color3.fromRGB(255,255,255); pStroke.Thickness = 1; pStroke.Transparency = 0.6

    -- Title
    local title = Instance.new("TextLabel", panel)
    title.BackgroundTransparency = 1
    title.Position = UDim2.fromOffset(0, 24); title.Size = UDim2.new(1, 0, 0, 30)
    title.Font = Enum.Font.GothamBlack; title.TextSize = 26
    title.Text = "ENI HUB"; title.TextColor3 = Color3.fromRGB(255,255,255)

    -- Close-Button oben rechts (X) — bricht Login ab und lädt cheat NICHT
    local closeBtn = Instance.new("TextButton", panel)
    closeBtn.Size = UDim2.fromOffset(32, 32)
    closeBtn.Position = UDim2.new(1, -40, 0, 8)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"; closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextSize = 18
    closeBtn.TextColor3 = Color3.fromRGB(230,80,110); closeBtn.AutoButtonColor = false
    closeBtn.MouseEnter:Connect(function() closeBtn.TextColor3 = Color3.fromRGB(255,120,140) end)
    closeBtn.MouseLeave:Connect(function() closeBtn.TextColor3 = Color3.fromRGB(230,80,110) end)
    closeBtn.MouseButton1Click:Connect(function()
        -- Setze abort-flag und unblock while-loop → main script sieht flag und returned
        _G.ENI_LOGIN_ABORTED = true
        authenticated = true  -- unblockt die while-loop
        LoginGui:Destroy()
    end)

    -- Subtitle
    local subtitle = Instance.new("TextLabel", panel)
    subtitle.BackgroundTransparency = 1
    subtitle.Position = UDim2.fromOffset(0, 56); subtitle.Size = UDim2.new(1, 0, 0, 16)
    subtitle.Font = Enum.Font.Code; subtitle.TextSize = 11
    subtitle.Text = ""
    subtitle.TextColor3 = Color3.fromRGB(160,160,175)

    -- Input helper
    local function makeInput(y, placeholder, isPassword)
        local box = Instance.new("Frame", panel)
        box.Size = UDim2.new(1, -60, 0, 38)
        box.Position = UDim2.fromOffset(30, y)
        box.BackgroundColor3 = Color3.fromRGB(10,10,14); box.BorderSizePixel = 0
        Instance.new("UIStroke", box).Color = Color3.fromRGB(40,40,55)
        local tb = Instance.new("TextBox", box)
        tb.Size = UDim2.new(1, -20, 1, 0); tb.Position = UDim2.fromOffset(10, 0)
        tb.BackgroundTransparency = 1; tb.ClearTextOnFocus = false
        tb.PlaceholderText = placeholder; tb.Text = ""
        tb.PlaceholderColor3 = Color3.fromRGB(80,80,95)
        tb.TextColor3 = Color3.fromRGB(240,240,245)
        tb.Font = Enum.Font.Gotham; tb.TextSize = 13
        tb.TextXAlignment = Enum.TextXAlignment.Left
        if isPassword then tb.Text = ""; tb:GetPropertyChangedSignal("Text"):Connect(function() end) end
        return tb, box
    end

    -- Button helper
    local function makeButton(y, text)
        local btn = Instance.new("TextButton", panel)
        btn.Size = UDim2.new(1, -60, 0, 40)
        btn.Position = UDim2.fromOffset(30, y)
        btn.BackgroundColor3 = Color3.fromRGB(255,255,255); btn.BorderSizePixel = 0
        btn.Text = text; btn.Font = Enum.Font.GothamBold; btn.TextSize = 13
        btn.TextColor3 = Color3.fromRGB(0,0,0); btn.AutoButtonColor = false
        btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(220,220,230) end)
        btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(255,255,255) end)
        return btn
    end

    -- Status/error text
    local status = Instance.new("TextLabel", panel)
    status.BackgroundTransparency = 1
    status.Position = UDim2.fromOffset(0, 370); status.Size = UDim2.new(1, 0, 0, 16)
    status.Font = Enum.Font.Gotham; status.TextSize = 11
    status.Text = ""; status.TextColor3 = Color3.fromRGB(255,80,100)

    -- Discord link at bottom (KLICKBAR → kopiert in Zwischenablage)
    local dc = Instance.new("TextButton", panel)
    dc.BackgroundTransparency = 1
    dc.Position = UDim2.fromOffset(0, 390); dc.Size = UDim2.new(1, 0, 0, 16)
    dc.Font = Enum.Font.Code; dc.TextSize = 10
    dc.Text = "📋 Copy Discord: " .. DISCORD_LINK
    dc.TextColor3 = Color3.fromRGB(140,140,175)
    dc.AutoButtonColor = false
    dc.MouseEnter:Connect(function() dc.TextColor3 = Color3.fromRGB(255,255,255) end)
    dc.MouseLeave:Connect(function() dc.TextColor3 = Color3.fromRGB(140,140,175) end)
    dc.MouseButton1Click:Connect(function()
        local sc = setclipboard or (syn and syn.write_clipboard) or (Clipboard and Clipboard.set) or toclipboard
        if sc then
            pcall(sc, DISCORD_LINK)
            local oldText  = dc.Text
            local oldColor = dc.TextColor3
            dc.Text = "✓ COPIED! Paste it in your browser"
            dc.TextColor3 = Color3.fromRGB(80,220,120)
            task.delay(1.8, function()
                if dc and dc.Parent then
                    dc.Text = oldText
                    dc.TextColor3 = oldColor
                end
            end)
        else
            dc.Text = "Clipboard nicht verfügbar — Link: " .. DISCORD_LINK
        end
    end)

    local authenticated = false
    local currentInputs = {}

    -- Rebuild UI based on mode
    local function build(newMode)
        mode = newMode
        for _, obj in ipairs(currentInputs) do obj:Destroy() end
        currentInputs = {}
        status.Text = ""

        if mode == "key" then
            subtitle.Text = "ENTER LICENSE KEY  ·  ONE-TIME USE"
            local keyIn, keyBox = makeInput(100, "ENI-XXXX-XXXX-XXXX")
            local btn = makeButton(160, "REDEEM KEY")
            local switch = makeButton(210, "I ALREADY HAVE AN ACCOUNT")
            switch.BackgroundColor3 = Color3.fromRGB(20,20,28)
            switch.TextColor3 = Color3.fromRGB(200,200,215)
            switch.MouseEnter:Connect(function() switch.BackgroundColor3 = Color3.fromRGB(30,30,42) end)
            switch.MouseLeave:Connect(function() switch.BackgroundColor3 = Color3.fromRGB(20,20,28) end)
            table.insert(currentInputs, keyBox)
            table.insert(currentInputs, btn); table.insert(currentInputs, switch)

            btn.MouseButton1Click:Connect(function()
                local k = string.upper(keyIn.Text):gsub("%s", "")
                if not VALID_KEYS[k] then
                    status.Text = "INVALID KEY. Join Discord to get one."; return
                end
                local used = loadUsedKeys()
                if used[k] then
                    status.Text = "This key has already been used."; return
                end
                -- Key valid + unused → mark used and go to register
                markKeyUsed(k)
                status.TextColor3 = Color3.fromRGB(80,220,120)
                status.Text = "KEY REDEEMED. Create your account."
                task.wait(0.6)
                status.TextColor3 = Color3.fromRGB(255,80,100)
                build("register")
            end)
            switch.MouseButton1Click:Connect(function() build("login") end)

        elseif mode == "register" then
            subtitle.Text = "CREATE ACCOUNT"
            local userIn, uBox = makeInput(100, "USERNAME")
            local passIn, pBox = makeInput(150, "PASSWORD", true)
            local btn = makeButton(210, "CREATE ACCOUNT")
            table.insert(currentInputs, uBox); table.insert(currentInputs, pBox); table.insert(currentInputs, btn)

            btn.MouseButton1Click:Connect(function()
                local u = userIn.Text:gsub("%s", "")
                local p = passIn.Text
                if #u < 3 then status.Text = "Username too short (min 3)."; return end
                if #p < 4 then status.Text = "Password too short (min 4)."; return end
                if saveAccount(u, p) then
                    status.TextColor3 = Color3.fromRGB(80,220,120)
                    status.Text = "ACCOUNT CREATED. Launching..."
                    task.wait(0.6)
                    authenticated = true
                else
                    status.Text = "Could not save account (no writefile)."
                end
            end)

        else  -- "login"
            subtitle.Text = "LOGIN"
            local userIn, uBox = makeInput(100, "USERNAME")
            local passIn, pBox = makeInput(150, "PASSWORD", true)
            local btn = makeButton(210, "LOGIN")
            local switch = makeButton(260, "USE A NEW KEY")
            switch.BackgroundColor3 = Color3.fromRGB(20,20,28)
            switch.TextColor3 = Color3.fromRGB(200,200,215)
            switch.MouseEnter:Connect(function() switch.BackgroundColor3 = Color3.fromRGB(30,30,42) end)
            switch.MouseLeave:Connect(function() switch.BackgroundColor3 = Color3.fromRGB(20,20,28) end)
            table.insert(currentInputs, uBox); table.insert(currentInputs, pBox)
            table.insert(currentInputs, btn); table.insert(currentInputs, switch)

            btn.MouseButton1Click:Connect(function()
                local acc = loadAccount()
                if not acc then status.Text = "No account found. Use a key first."; return end
                local u = userIn.Text:gsub("%s", "")
                local p = passIn.Text
                if u == acc.user and obfuscate(p) == acc.pass then
                    status.TextColor3 = Color3.fromRGB(80,220,120)
                    status.Text = "WELCOME BACK. Launching..."
                    task.wait(0.5)
                    authenticated = true
                else
                    status.Text = "Wrong username or password."
                end
            end)
            switch.MouseButton1Click:Connect(function() build("key") end)
        end
    end

    build(mode)

    -- BLOCK until authenticated (yield)
    while not authenticated do task.wait(0.1) end
    LoginGui:Destroy()
end

-- Login geschützt aufrufen — wenn's crasht wird der script trotzdem weiter geladen
local loginOK, loginErr = pcall(showLoginGui)
if not loginOK then warn("[ENI HUB] login error: "..tostring(loginErr)) end

end  -- ende des LOGIN do-block

-- Wenn User Login geschlossen hat → script komplett stoppen, kein cheat menu laden
if _G.ENI_LOGIN_ABORTED then
    _G.ENI_LOGIN_ABORTED = nil  -- reset für nächsten launch
    print("[ENI HUB] Login abgebrochen — cheat wird nicht geladen.")
    return
end

-- ═════════ Config ═════════
local C = {
    -- Aimbot
    AimEnabled     = true,
    AimKey         = Enum.UserInputType.MouseButton2,
    AimMode        = "RightMouse",  -- RightMouse / LeftMouse / AlwaysOn / KeyE
    AimPart        = "Head",
    AimSmoothness  = 0.22,
    TeamCheck      = true,
    WallCheck      = false,
    -- FOV
    FOVEnabled     = true,
    FOVRadius      = 130,
    -- ESP
    BoxESP         = true,
    NameESP        = true,
    HealthESP      = true,
    HealthTextESP  = false,
    DistanceESP    = true,
    ESP_MaxDistance = 5000,  -- max studs für player ESP
    ESP_Unlimited   = false, -- bypasst distance-limit komplett
    TracerESP      = false,
    TracerOrigin   = "Bottom",  -- Bottom / Top / Center
    SkeletonESP    = false,
    TongTong       = false,
    ItemESP        = false,
    -- Item ESP sub-categories (welche items sollen getagged werden)
    ItemESP_Ammo    = true,   -- ammo, mags, bullets
    ItemESP_Food    = true,   -- food, meat, bread
    ItemESP_Chest    = true,   -- chests, crates, lockers
    ItemESP_Bookshelf= true,   -- bookshelves, libraries
    ItemESP_Shelf    = true,   -- shelves, racks
    ItemESP_MaxDistance = 500, -- max studs für item-tag anzeige
    VehicleESP     = false,
    DeadBodyESP    = false,
    DeadBodyColor  = Color3.fromRGB(255,140,50),
    ChamsMaterial  = "Normal",  -- Normal / Neon / Glass / ForceField / Wood / Plastic
    BulletTracers  = false,
    BulletColor    = Color3.fromRGB(255,220,80),
    ChamsEnabled   = false,
    ChamsFill      = 0.5,   -- 0 = solid, 1 = invisible
    ESPColor       = Color3.fromRGB(255,60,90),
    ESPTeamColor   = Color3.fromRGB(60,200,255),
    FOVColor       = Color3.fromRGB(240,240,245),
    TracerColor    = Color3.fromRGB(240,240,245),
    MenuAccent     = Color3.fromRGB(240,240,245),
    CameraFOV      = 70,
    WorldTime      = 14,
    SkyPreset      = "None",  -- None / Day / Sunset / Night / Space / Fullbright / Reset
    ChamsMode      = "Both",  -- Both / Fill / Outline / Rainbow
    Watermark      = false,
    KeybindsList   = false,
    RainbowESP     = false,
    RainbowTeam    = false,
    RainbowFOV     = false,
    RainbowMenu    = false,
    -- Crosshair
    CrosshairEnabled = false,
    CrosshairShape   = "Cross",   -- Cross / X / Circle / Diamond / Skull
    CrosshairSize    = 24,
    CrosshairColor   = Color3.fromRGB(240,240,245),
    CrosshairRotate  = false,
    CrosshairSpeed   = 1,
    RainbowCrosshair = false,
    -- Movement
    SpeedEnabled   = false,
    SpeedValue     = 32,
    JumpBoost      = false,
    JumpValue      = 80,
    InfJump        = false,
    FlyEnabled     = false,  -- HARD DISABLED in AC-test version
    FlySpeed       = 60,
    -- Combat
    RapidFire      = false,
    FireRate       = 40,       -- ms between shots
    AutoShot       = false,
    AutoShotDelay  = 200,  -- höher = weniger server-desync
    HitSound       = false,
    HitSoundType   = "Bubble",
    HitSoundVolume = 1.0,
    HitboxExpander = false,
    HitboxSize     = 6,
    -- Utility
    AntiAFK        = true,
    Noclip         = false,
    NoFallDamage   = false,
    ShowMurderer   = false,  -- MM2: zeigt roten MURDERER tag über player mit knife
    ShowSheriff    = false,  -- MM2: zeigt blauen SHERIFF tag über player mit gun
    ShowDroppedGun = false,  -- MM2: zeigt tag über gedroppter gun im workspace
    Freecam        = false,
    FreecamSpeed   = 50,
    FreecamKey     = Enum.KeyCode.Unknown,  -- kein default keybind
    FlyKey         = Enum.KeyCode.Unknown,   -- kein default keybind
    -- Settings
    MenuKey        = Enum.KeyCode.RightShift,
    MenuTransparency = 0,
    MenuSize         = 1,
}

-- Cleanup
-- Save defaults BEFORE load so we can restore if config is corrupt
local DEFAULT_C = {}
for k, v in pairs(C) do DEFAULT_C[k] = v end

-- Auto-load saved config from slot 1 falls vorhanden
do
    local ok, err = pcall(function()
        if not readfile then error("no readfile") end
        local raw = readfile("kuni_private_slot_1.json")
        if not raw or #raw < 2 then error("empty file") end
        local HttpService = game:GetService("HttpService")
        local data = HttpService:JSONDecode(raw)
        if type(data) ~= "table" then error("bad data") end
        local n = 0
        for k, v in pairs(data) do
            if type(v) == "table" and v[1] == "Color3" then
                C[k] = Color3.fromRGB(v[2], v[3], v[4])
            elseif type(v) == "table" and v[1] == "Enum" then
                local et = Enum[v[2]]
                if et and et[v[3]] then C[k] = et[v[3]] end
            else
                C[k] = v
            end
            n = n + 1
        end
        print("[KUNI PRIVATE] Config loaded ("..n.." values)")
    end)
    if not ok then print("[KUNI PRIVATE] No config to load: "..tostring(err)) end
end

-- Sanitize numeric values (fallback to defaults if config had bad data)
local numDefaults = {"CameraFOV","FOVRadius","AimSmoothness","FireRate","TriggerDelay",
    "SilentFOV","SpeedValue","JumpValue","FlySpeed","HitboxSize","FreecamSpeed",
    "MenuSize","MenuTransparency","ChamsFill","CrosshairSize","CrosshairSpeed",
    "HitSoundVolume","WorldTime"}
for _, k in ipairs(numDefaults) do
    if type(C[k]) ~= "number" or C[k] ~= C[k] then  -- nil or NaN
        C[k] = DEFAULT_C[k]
    end
end

-- Apply Sky Preset from loaded config (Menu Accent wird spaeter geladen wenn UI da ist)
if C.SkyPreset and C.SkyPreset ~= "None" then
    task.spawn(function()
        task.wait(1.5)  -- wait for game + our UI to init
        local Lighting = game:GetService("Lighting")
        local presetLookup = {
            Day        = {14, Color3.fromRGB(70,70,70),    1e6,  2},
            Sunset     = {18, Color3.fromRGB(120,80,60),   800,  1.5},
            Night      = {0,  Color3.fromRGB(15,15,25),    400,  0.5},
            Space      = {0,  Color3.fromRGB(0,0,0),       1e6,  0},
            Fullbright = {14, Color3.fromRGB(255,255,255), 1e6,  3},
            Reset      = {14, Color3.fromRGB(70,70,70),    1e6,  1},
        }
        local p = presetLookup[C.SkyPreset]
        if p then
            Lighting.ClockTime  = p[1]
            Lighting.Ambient    = p[2]
            Lighting.FogEnd     = p[3]
            Lighting.Brightness = p[4]
        end
    end)
end

-- Save initial MenuAccent for later apply (nach UI-Setup)
local INITIAL_MENU_ACCENT = C.MenuAccent

pcall(function()
    if game.CoreGui:FindFirstChild("ENIHUB") then game.CoreGui.ENIHUB:Destroy() end
    if game.CoreGui:FindFirstChild("ENIESP") then game.CoreGui.ENIESP:Destroy() end
    if game.CoreGui:FindFirstChild("KUNIHUB") then game.CoreGui.KUNIHUB:Destroy() end
    if game.CoreGui:FindFirstChild("KUNIESP") then game.CoreGui.KUNIESP:Destroy() end
end)
local GuiParent = (gethui and gethui()) or game:GetService("CoreGui")

local function New(c, p) local i = Instance.new(c); for k,v in pairs(p or {}) do i[k]=v end; return i end
local function Tween(o, t, p, s) TS:Create(o, TweenInfo.new(t, s or Enum.EasingStyle.Quart), p):Play() end

-- ═════════ ESP GUI (unter dem Menü, damit Menü drüber liegt) ═════════
local ESPGui = New("ScreenGui", {
    Name="KUNIESP", Parent=GuiParent, ResetOnSpawn=false,
    IgnoreGuiInset=true, DisplayOrder=999,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
})

local FOVFrame = New("Frame", {
    Parent=ESPGui, BackgroundTransparency=1,
    BorderSizePixel=0, AnchorPoint=Vector2.new(0.5,0.5),
    Position=UDim2.fromScale(0.5,0.5),
    Size=UDim2.fromOffset(260,260),
})
New("UICorner", {Parent=FOVFrame, CornerRadius=UDim.new(1,0)})
local FOVStroke = New("UIStroke", {Parent=FOVFrame, Color=Color3.fromRGB(240,240,245), Thickness=1.5, Transparency=0.2})


-- ═════════════════════════════════════════════════════════
--   PREMIUM MENU UI
-- ═════════════════════════════════════════════════════════
local Gui = New("ScreenGui", {Name="KUNIHUB", Parent=GuiParent, ResetOnSpawn=false,
    IgnoreGuiInset=true, DisplayOrder=1000, ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
    AutoLocalize=false})  -- deaktiviert Roblox Auto-Translate

-- BG_LOCK = permanentes reines schwarz, wird NIE von irgendwas überschrieben
local BG_LOCK      = Color3.fromRGB(0, 0, 0)     -- Main / Top / Side / StatusBar
local BG_LOCK_ROW  = Color3.fromRGB(10, 10, 12)  -- Toggle/Slider/Colorpicker rows (minimal heller für Kontrast)

-- Watchdog: erzwingt schwarz auf JEDEN Frame ohne AccentTarget-Attribut, jeden Frame
-- Nur AccentTarget-Elemente (Streifen, Glows, Slider-Fill, Section-Bars) dürfen Farbe haben
task.spawn(function()
    while true do
        task.wait(0.1)  -- 10x pro Sekunde, kein spürbarer perf hit
        if not Gui or not Gui.Parent then break end
        for _, obj in ipairs(Gui:GetDescendants()) do
            if obj:IsA("GuiObject") then
                local accent = obj:GetAttribute("AccentTarget")
                local locked = obj:GetAttribute("BgLocked")
                if locked then
                    pcall(function() obj.BackgroundColor3 = BG_LOCK end)
                elseif not accent then
                    -- Kein AccentTarget → Background darf NIE eine kräftige Farbe kriegen
                    -- Nur rows die BG_LOCK_ROW haben sollen behalten das
                    local cur = obj.BackgroundColor3
                    -- Wenn's ein row-artiges dark element ist, lock auf BG_LOCK_ROW
                    if cur == Color3.fromRGB(14,14,18)
                    or cur == Color3.fromRGB(22,22,28)
                    or cur == Color3.fromRGB(14,14,20) then
                        pcall(function() obj.BackgroundColor3 = BG_LOCK_ROW end)
                    end
                end
            end
        end
    end
end)

local Main = New("Frame", {
    Parent = Gui, Size = UDim2.fromOffset(700, 550),
    Position = UDim2.new(0.5, -350, 0.5, -275),
    BackgroundColor3 = BG_LOCK, BorderSizePixel = 0,
})
Main:SetAttribute("BgLocked", true)
-- Explizit KEINE UICorner = 100% sharp edges
New("UIStroke", {Parent=Main, Color=Color3.fromRGB(38,38,52), Thickness=1, Transparency=0.2})

-- Kein Gradient mehr = pure black

-- Doppelter Glow-Shadow fuer echte Tiefe
for i, offset in ipairs({4, 8}) do
    local sh = New("Frame", {Parent=Main, ZIndex=-i,
        BackgroundColor3 = Color3.fromRGB(240,240,245),
        BackgroundTransparency = 0.85 + (i * 0.05),
        Position = UDim2.fromOffset(-offset, -offset),
        Size = UDim2.new(1, offset*2, 1, offset*2)})
    New("UICorner", {Parent=sh, CornerRadius=UDim.new(0,14 + offset)})
end

-- ═════════ Top Bar (pure black, no corners, no gradient) ═════════
local Top = New("Frame", {Parent=Main, Size=UDim2.new(1,0,0,52),
    BackgroundColor3=BG_LOCK, BorderSizePixel=0})
Top:SetAttribute("BgLocked", true)

-- Accent bar mit gradient + glow
local AccentBar = New("Frame", {Parent=Main, Size=UDim2.new(1,0,0,2), Position=UDim2.new(0,0,0,52),
    BackgroundColor3=Color3.fromRGB(240,240,245), BorderSizePixel=0})
New("UIGradient", {Parent=AccentBar, Color=ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(120,120,130)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255,255,255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(120,120,130)),
}})
-- Glow unter der Accent-Bar
local AccentGlow = New("Frame", {Parent=Main, Size=UDim2.new(1,0,0,8), Position=UDim2.new(0,0,0,54),
    BackgroundColor3=Color3.fromRGB(240,240,245), BorderSizePixel=0, BackgroundTransparency=0.85})
New("UIGradient", {Parent=AccentGlow, Rotation=90, Transparency=NumberSequence.new{
    NumberSequenceKeypoint.new(0, 0.7),
    NumberSequenceKeypoint.new(1, 1),
}})

-- Logo Mark (custom-drawn hexagon-esque icon)
-- Cleaner static bracket-style logo (kein rotating diamond, private-cheat vibes)
local logoBar = New("Frame", {Parent=Top, Size=UDim2.fromOffset(3, 32),
    Position=UDim2.new(0, 16, 0.5, -16), BackgroundColor3=Color3.fromRGB(240,240,245),
    BorderSizePixel=0})
New("UICorner", {Parent=logoBar, CornerRadius=UDim.new(0, 2)})
-- Subtile glow um den bar
local logoGlow = New("Frame", {Parent=Top, Size=UDim2.fromOffset(8, 32),
    Position=UDim2.new(0, 14, 0.5, -16), BackgroundColor3=Color3.fromRGB(240,240,245),
    BorderSizePixel=0, BackgroundTransparency=0.75})
New("UICorner", {Parent=logoGlow, CornerRadius=UDim.new(0, 4)})

-- amber.lol style: name links, date/time rechts
-- Logo bleibt IMMER neon-white, egal welche accent farbe der user picked
local logoLabel = New("TextLabel", {Parent=Top, BackgroundTransparency=1,
    Position=UDim2.fromOffset(30,0), Size=UDim2.fromOffset(200,52),
    Font=Enum.Font.GothamBold, TextSize=13, Text="kuni.private",
    TextColor3=Color3.fromRGB(255,255,255), TextXAlignment=Enum.TextXAlignment.Left,
    TextYAlignment=Enum.TextYAlignment.Center})
logoLabel:SetAttribute("KeepWhite", true)
-- Watchdog: falls doch mal überschrieben, sofort zurück auf weiß
task.spawn(function()
    while logoLabel and logoLabel.Parent do
        task.wait(0.15)
        if logoLabel.TextColor3 ~= Color3.fromRGB(255,255,255) then
            pcall(function() logoLabel.TextColor3 = Color3.fromRGB(255,255,255) end)
        end
    end
end)
local dateLabel = New("TextLabel", {Parent=Top, BackgroundTransparency=1,
    Position=UDim2.new(1,-280,0,0), Size=UDim2.fromOffset(220,52),
    Font=Enum.Font.Code, TextSize=11, Text="",
    TextColor3=Color3.fromRGB(140,140,160), TextXAlignment=Enum.TextXAlignment.Right,
    TextYAlignment=Enum.TextYAlignment.Center})
task.spawn(function()
    while dateLabel.Parent do
        local d = os.date("*t")
        local months = {"jan","feb","mar","apr","may","jun","jul","aug","sep","oct","nov","dec"}
        local ampm = d.hour < 12 and "am" or "pm"
        local h12 = (d.hour == 0) and 12 or (d.hour > 12 and d.hour-12 or d.hour)
        dateLabel.Text = string.format("%s. %d, %d  |  %02d:%02d %s",
            months[d.month], d.day, d.year, h12, d.min, ampm)
        task.wait(30)
    end
end)

-- Neon-Glow-Border rund um Main (amber.lol vibes)
-- Rand-Glow stark reduziert — nur noch dezente Kontur, nicht mehr die halbe Menu-Farbe
local mainGlow = New("Frame", {Parent=Main, ZIndex=-5,
    Position=UDim2.fromOffset(-1,-1), Size=UDim2.new(1,2,1,2),
    BackgroundColor3=C.MenuAccent, BackgroundTransparency=0.92, BorderSizePixel=0})
local mainGlow2 = New("Frame", {Parent=Main, ZIndex=-6,
    Position=UDim2.fromOffset(-3,-3), Size=UDim2.new(1,6,1,6),
    BackgroundColor3=C.MenuAccent, BackgroundTransparency=0.97, BorderSizePixel=0})
-- Live sync glow color mit Menu Accent
task.spawn(function()
    while mainGlow.Parent do
        task.wait(0.1)
        if mainGlow.BackgroundColor3 ~= C.MenuAccent then
            mainGlow.BackgroundColor3  = C.MenuAccent
            mainGlow2.BackgroundColor3 = C.MenuAccent
        end
    end
end)

-- Close button
local CloseBtn = New("TextButton", {Parent=Top, Text="✕", Font=Enum.Font.GothamBold,
    TextSize=15, TextColor3=Color3.fromRGB(230,80,110), BackgroundTransparency=1,
    Size=UDim2.fromOffset(52,52), Position=UDim2.new(1,-52,0,0)})
CloseBtn.MouseEnter:Connect(function() Tween(CloseBtn, 0.15, {TextColor3=Color3.fromRGB(255,120,140)}) end)
CloseBtn.MouseLeave:Connect(function() Tween(CloseBtn, 0.15, {TextColor3=Color3.fromRGB(230,80,110)}) end)
CloseBtn.MouseButton1Click:Connect(function()
    Tween(Main, 0.25, {Size = UDim2.fromOffset(700, 0), Position = UDim2.new(0.5, -350, 0.5, 0)})
    task.wait(0.25); Gui:Destroy(); ESPGui:Destroy()
end)

-- Drag
do
    local drag, ds, sp
    Top.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true;ds=i.Position;sp=Main.Position end end)
    Top.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
    UIS.InputChanged:Connect(function(i) if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
        local d=i.Position-ds; Main.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y) end end)
end

-- ═════════ Top Tab Bar (horizontal, pure black) ═════════
local Side = New("Frame", {Parent=Main, Size=UDim2.new(1,0,0,32),
    Position=UDim2.fromOffset(0,54), BackgroundColor3=BG_LOCK, BorderSizePixel=0})
Side:SetAttribute("BgLocked", true)
New("UIListLayout", {Parent=Side, Padding=UDim.new(0,2),
    FillDirection=Enum.FillDirection.Horizontal,
    HorizontalAlignment=Enum.HorizontalAlignment.Left,
    VerticalAlignment=Enum.VerticalAlignment.Center,
    SortOrder=Enum.SortOrder.LayoutOrder})
New("UIPadding", {Parent=Side, PaddingLeft=UDim.new(0,8)})
-- Bottom-edge separator
New("Frame", {Parent=Main, Size=UDim2.new(1,0,0,1),
    Position=UDim2.fromOffset(0,86), BackgroundColor3=Color3.fromRGB(30,30,42),
    BorderSizePixel=0, ZIndex=2})

-- Content area
local Content = New("Frame", {Parent=Main, Size=UDim2.new(1,-16,1,-120),
    Position=UDim2.fromOffset(8,94), BackgroundTransparency=1, ClipsDescendants=true})

-- ═════════ Bottom Status Bar (versteckt, LO wollt's raus) ═════════
local StatusBar = New("Frame", {Parent=Main, Size=UDim2.new(1,0,0,26), Visible=false,
    Position=UDim2.new(0,0,1,-26), BackgroundColor3=Color3.fromRGB(9,9,14), BorderSizePixel=0})
New("UICorner", {Parent=StatusBar, CornerRadius=UDim.new(0,14)})
New("Frame", {Parent=StatusBar, Size=UDim2.new(1,0,0,14), Position=UDim2.new(0,0,0,0),
    BackgroundColor3=Color3.fromRGB(9,9,14), BorderSizePixel=0})
-- top border of statusbar
New("Frame", {Parent=StatusBar, Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,0,0),
    BackgroundColor3=Color3.fromRGB(30,30,42), BorderSizePixel=0})

-- Status dot
local StatDot = New("Frame", {Parent=StatusBar, Size=UDim2.fromOffset(6,6),
    Position=UDim2.new(0,14,0.5,-3), BackgroundColor3=Color3.fromRGB(240,240,245), BorderSizePixel=0})
New("UICorner", {Parent=StatDot, CornerRadius=UDim.new(1,0)})
task.spawn(function()
    while StatDot.Parent do
        Tween(StatDot, 1.2, {BackgroundTransparency = 0.6}):Wait()
        if not StatDot.Parent then break end
        Tween(StatDot, 1.2, {BackgroundTransparency = 0}):Wait()
    end
end)

New("TextLabel", {Parent=StatusBar, BackgroundTransparency=1,
    Position=UDim2.fromOffset(26,0), Size=UDim2.fromOffset(80,26),
    Font=Enum.Font.Code, TextSize=10, Text="ATTACHED",
    TextColor3=Color3.fromRGB(240,240,245), TextXAlignment=Enum.TextXAlignment.Left})

-- FPS / Ping counters (live-updated)
local FpsLabel = New("TextLabel", {Parent=StatusBar, BackgroundTransparency=1,
    Position=UDim2.new(1,-200,0,0), Size=UDim2.fromOffset(80,26),
    Font=Enum.Font.Code, TextSize=10, Text="FPS: --",
    TextColor3=Color3.fromRGB(160,160,180), TextXAlignment=Enum.TextXAlignment.Right})
local PingLabel = New("TextLabel", {Parent=StatusBar, BackgroundTransparency=1,
    Position=UDim2.new(1,-115,0,0), Size=UDim2.fromOffset(80,26),
    Font=Enum.Font.Code, TextSize=10, Text="PING: --",
    TextColor3=Color3.fromRGB(160,160,180), TextXAlignment=Enum.TextXAlignment.Right})
New("TextLabel", {Parent=StatusBar, BackgroundTransparency=1,
    Position=UDim2.new(1,-40,0,0), Size=UDim2.fromOffset(30,26),
    Font=Enum.Font.Code, TextSize=10, Text="v3.0",
    TextColor3=Color3.fromRGB(90,90,105), TextXAlignment=Enum.TextXAlignment.Right})

-- Live FPS + Ping update
task.spawn(function()
    local stats = game:GetService("Stats")
    local frames, lastT = 0, tick()
    RunService.RenderStepped:Connect(function()
        frames = frames + 1
        if tick() - lastT >= 0.5 then
            FpsLabel.Text = "FPS: " .. math.floor(frames / (tick() - lastT))
            frames, lastT = 0, tick()
        end
    end)
    while StatusBar.Parent do
        pcall(function()
            local ping = stats.Network.ServerStatsItem["Data Ping"]:GetValue()
            PingLabel.Text = "PING: " .. math.floor(ping) .. "ms"
        end)
        task.wait(1)
    end
end)

-- ═════════ MOBILE DETECTION — bigger touch targets ═════════
local IS_MOBILE = UIS.TouchEnabled and not UIS.KeyboardEnabled
local TAB_W, TAB_H = 80, 26
if IS_MOBILE then
    TAB_W, TAB_H = 90, 40  -- deutlich fetter für finger-taps
    -- Side (tab bar) höher machen damit die tabs reinpassen
    Side.Size = UDim2.new(1, 0, 0, 48)
    -- Content nach unten schieben damit's nicht mit den tabs überlappt
    Content.Position = UDim2.fromOffset(8, 110)
    Content.Size = UDim2.new(1, -16, 1, -136)
    -- Separator unterhalb der tabs neu positionieren
    for _, c in ipairs(Main:GetChildren()) do
        if c:IsA("Frame") and c.Size == UDim2.new(1,0,0,1)
        and c.Position == UDim2.fromOffset(0,86) then
            c.Position = UDim2.fromOffset(0, 102)
        end
    end
    -- Menu insgesamt kompakter für kleinen bildschirm
    task.spawn(function()
        task.wait(0.5)  -- warte bis menuScale existiert
        if menuScale then menuScale.Scale = 0.6 end  -- 60% = passt auf Handy screens
    end)
    -- Reposition Main damit's garantiert on-screen ist auf kleinen displays
    task.spawn(function()
        task.wait(0.6)
        local viewport = Camera.ViewportSize
        if viewport.X < 600 then
            -- Kleines display → oben mittig statt zentriert (weil scaling um center point herum shrinkt)
            Main.Position = UDim2.new(0.5, -350, 0, 20)
        end
    end)
end

local Pages, Tabs = {}, {}
local currentTab

local function selectTab(name)
    for n, page in pairs(Pages) do page.Visible = (n == name) end
    for n, entry in pairs(Tabs) do
        local isActive = (n == name)
        -- Bottom-bar wächst wenn aktiv
        Tween(entry.bar, 0.2, {Size = isActive and UDim2.new(1,0,0,2) or UDim2.new(1,0,0,0),
                                BackgroundColor3 = C.MenuAccent})
        Tween(entry.btn, 0.2, {BackgroundColor3 = isActive and Color3.fromRGB(22,22,32) or Color3.fromRGB(14,14,20)})
        Tween(entry.txt, 0.2, {TextColor3 = isActive and Color3.fromRGB(240,240,245) or Color3.fromRGB(140,140,160)})
    end
    currentTab = name
end

local function AddTab(name, icon)
    -- Horizontal top-tab — auf mobile größer für touch
    local btn = New("TextButton", {Parent=Side, Size=UDim2.fromOffset(TAB_W, TAB_H),
        BackgroundColor3=Color3.fromRGB(14,14,20), BorderSizePixel=0, Text="",
        AutoButtonColor=false})
    -- Bottom-highlight bar (active indicator)
    local bar = New("Frame", {Parent=btn, Size=UDim2.new(1,0,0,0),
        Position=UDim2.new(0,0,1,-2), BackgroundColor3=Color3.fromRGB(240,240,245), BorderSizePixel=0})
    local txt = New("TextLabel", {Parent=btn, BackgroundTransparency=1,
        Size=UDim2.fromScale(1,1), Font=Enum.Font.GothamMedium, TextSize=12,
        Text=name, TextColor3=Color3.fromRGB(140,140,160),
        TextXAlignment=Enum.TextXAlignment.Center})

    local page = New("ScrollingFrame", {Parent=Content, Size=UDim2.fromScale(1,1),
        BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=3,
        ScrollBarImageColor3=Color3.fromRGB(240,240,245), Visible=false,
        CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y})
    New("UIListLayout", {Parent=page, Padding=UDim.new(0,7), SortOrder=Enum.SortOrder.LayoutOrder})
    New("UIPadding", {Parent=page, PaddingTop=UDim.new(0,2), PaddingBottom=UDim.new(0,12), PaddingRight=UDim.new(0,8)})

    Tabs[name] = {btn=btn, bar=bar, txt=txt}
    Pages[name] = page
    btn.MouseButton1Click:Connect(function() selectTab(name) end)
    btn.MouseEnter:Connect(function()
        if currentTab ~= name then Tween(txt, 0.15, {TextColor3=Color3.fromRGB(200,200,215)}) end
    end)
    btn.MouseLeave:Connect(function()
        if currentTab ~= name then Tween(txt, 0.15, {TextColor3=Color3.fromRGB(140,140,160)}) end
    end)
    return page
end

-- ═════════ Component: Section header (mit Divider Line) ═════════
local function Section(parent, text)
    local box = New("Frame", {Parent=parent, Size=UDim2.new(1,0,0,28), BackgroundTransparency=1})
    -- Small vertical accent bar
    local bar = New("Frame", {Parent=box, Size=UDim2.fromOffset(2,10),
        Position=UDim2.new(0,4,0.5,-5), BackgroundColor3=Color3.fromRGB(240,240,245),
        BorderSizePixel=0})
    New("UICorner", {Parent=bar, CornerRadius=UDim.new(0,1)})
    -- Label
    local lbl = New("TextLabel", {Parent=box, BackgroundTransparency=1,
        Position=UDim2.fromOffset(12,0), Size=UDim2.fromOffset(200,28),
        Font=Enum.Font.GothamBold, TextSize=10, Text=string.upper(text),
        TextColor3=Color3.fromRGB(220,220,235), TextXAlignment=Enum.TextXAlignment.Left})
    -- Divider line right of label
    local div = New("Frame", {Parent=box, Size=UDim2.new(1,-220,0,1),
        Position=UDim2.new(0,214,0.5,0), BackgroundColor3=Color3.fromRGB(35,35,50),
        BorderSizePixel=0})
    New("UIGradient", {Parent=div, Transparency=NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1),
    }})
end

-- ═════════ Component: Toggle ═════════
local function Toggle(parent, label, key)
    -- TextButton statt Frame → ScrollingFrame kann Klicks nicht mehr klauen
    local row = New("TextButton", {Parent=parent, Size=UDim2.new(1,0,0,34),
        BackgroundColor3=Color3.fromRGB(14,14,18), BorderSizePixel=0,
        Text="", AutoButtonColor=false, ZIndex=3})
    New("UICorner", {Parent=row, CornerRadius=UDim.new(0,2)})
    New("UIStroke", {Parent=row, Color=Color3.fromRGB(35,35,48), Thickness=1, Transparency=0.5})
    New("TextLabel", {Parent=row, BackgroundTransparency=1,
        Position=UDim2.fromOffset(12,0), Size=UDim2.new(1,-60,1,0),
        Font=Enum.Font.Gotham, TextSize=13, Text=label,
        TextColor3=Color3.fromRGB(220,220,230), TextXAlignment=Enum.TextXAlignment.Left})
    -- Checkbox-Style — leuchtet ROT wenn active (fixed color, nicht änderbar)
    local sw = New("Frame", {Parent=row, Size=UDim2.fromOffset(14,14),
        Position=UDim2.new(1,-24,0.5,-7),
        BackgroundColor3=Color3.fromRGB(28,28,38), BorderSizePixel=0, Active=false})
    sw:SetAttribute("ColorSwatch", true)  -- Skip in updateMenuAccent walk
    local swStroke = New("UIStroke", {Parent=sw, Color=Color3.fromRGB(70,70,90), Thickness=1})
    local FIXED_RED = Color3.fromRGB(255, 45, 60)
    local function refresh()
        local on = C[key]
        Tween(sw, 0.15, {BackgroundColor3 = on and FIXED_RED or Color3.fromRGB(28,28,38)})
        Tween(swStroke, 0.15, {Color = on and FIXED_RED or Color3.fromRGB(70,70,90)})
    end
    refresh()
    -- Register refresh callback global damit loadSlot alle toggles re-syncen kann
    _G.ENI_TOGGLE_REFRESH = _G.ENI_TOGGLE_REFRESH or {}
    table.insert(_G.ENI_TOGGLE_REFRESH, refresh)
    row.MouseButton1Click:Connect(function()
        C[key] = not C[key]; refresh()
    end)
    -- Hover glow
    local rowStroke = row:FindFirstChildOfClass("UIStroke")
    row.MouseEnter:Connect(function()
        Tween(row, 0.15, {BackgroundColor3 = Color3.fromRGB(28,28,40)})
        if rowStroke then Tween(rowStroke, 0.15, {Transparency = 0.2}) end
    end)
    row.MouseLeave:Connect(function()
        Tween(row, 0.15, {BackgroundColor3 = Color3.fromRGB(22,22,32)})
        if rowStroke then Tween(rowStroke, 0.15, {Transparency = 0.5}) end
    end)
end

-- ═════════ Component: Slider ═════════
local function Slider(parent, label, key, min, max, step)
    step = step or 1
    local row = New("Frame", {Parent=parent, Size=UDim2.new(1,0,0,46),
        BackgroundColor3=Color3.fromRGB(14,14,18), BorderSizePixel=0})
    New("UICorner", {Parent=row, CornerRadius=UDim.new(0,2)})
    New("UIStroke", {Parent=row, Color=Color3.fromRGB(35,35,48), Thickness=1, Transparency=0.5})
    local lbl = New("TextLabel", {Parent=row, BackgroundTransparency=1,
        Position=UDim2.fromOffset(12,4), Size=UDim2.new(1,-24,0,18),
        Font=Enum.Font.Gotham, TextSize=12, Text=label,
        TextColor3=Color3.fromRGB(220,220,230), TextXAlignment=Enum.TextXAlignment.Left})
    local val = New("TextLabel", {Parent=row, BackgroundTransparency=1,
        Position=UDim2.fromOffset(0,4), Size=UDim2.new(1,-14,0,18),
        Font=Enum.Font.GothamBold, TextSize=12, Text=tostring(C[key]),
        TextColor3=Color3.fromRGB(240,240,245), TextXAlignment=Enum.TextXAlignment.Right})
    -- Volle Row-Hitbox als TextButton — kein ScrollingFrame kann das mehr klauen
    local hitbox = New("TextButton", {Parent=row, Size=UDim2.new(1,-24,0,24),
        Position=UDim2.fromOffset(12,20), BackgroundTransparency=1, Text="",
        AutoButtonColor=false, ZIndex=5})
    local bar = New("Frame", {Parent=hitbox, Size=UDim2.new(1,0,0,5),
        Position=UDim2.new(0,0,0.5,-2), BackgroundColor3=Color3.fromRGB(40,40,52),
        BorderSizePixel=0, ZIndex=4})
    New("UICorner", {Parent=bar, CornerRadius=UDim.new(1,0)})
    local fill = New("Frame", {Parent=bar, BackgroundColor3=Color3.fromRGB(240,240,245),
        BorderSizePixel=0, Size=UDim2.fromScale((C[key]-min)/(max-min), 1), ZIndex=4})
    New("UICorner", {Parent=fill, CornerRadius=UDim.new(1,0)})

    local dragging = false
    local function setFromX(mx)
        local rel = math.clamp((mx - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local v = math.floor((min + (max - min) * rel) / step + 0.5) * step
        C[key] = v
        fill.Size = UDim2.fromScale((v - min) / (max - min), 1)
        val.Text  = tostring(v)
    end

    -- Multiple input paths for max compatibility
    hitbox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setFromX(input.Position.X)
        end
    end)
    hitbox.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                     or input.UserInputType == Enum.UserInputType.Touch) then
            setFromX(input.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            setFromX(input.Position.X)
        end
    end)
end

-- ═════════ Component: Keybind Picker ═════════
local pickingKeybind = false
local function KeybindPicker(parent, label, key)
    local row = New("Frame", {Parent=parent, Size=UDim2.new(1,0,0,34),
        BackgroundColor3=Color3.fromRGB(14,14,18), BorderSizePixel=0})
    New("UICorner", {Parent=row, CornerRadius=UDim.new(0,2)})
    New("UIStroke", {Parent=row, Color=Color3.fromRGB(35,35,48), Thickness=1, Transparency=0.5})
    New("TextLabel", {Parent=row, BackgroundTransparency=1,
        Position=UDim2.fromOffset(12,0), Size=UDim2.new(1,-100,1,0),
        Font=Enum.Font.Gotham, TextSize=13, Text=label,
        TextColor3=Color3.fromRGB(220,220,230), TextXAlignment=Enum.TextXAlignment.Left})
    local displayName = (C[key] == Enum.KeyCode.Unknown) and "[none]" or C[key].Name
    local btn = New("TextButton", {Parent=row, Size=UDim2.fromOffset(80,22),
        Position=UDim2.new(1,-92,0.5,-11),
        BackgroundColor3=Color3.fromRGB(30,30,42), BorderSizePixel=0,
        Font=Enum.Font.GothamBold, TextSize=11,
        TextColor3=Color3.fromRGB(240,240,245), Text=displayName, AutoButtonColor=false})
    New("UICorner", {Parent=btn, CornerRadius=UDim.new(0,4)})
    btn.MouseButton1Click:Connect(function()
        pickingKeybind = true
        btn.Text = "[press key / ESC=clear]"
        btn.TextColor3 = Color3.fromRGB(255,180,80)
        local conn; conn = UIS.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode == Enum.KeyCode.Escape
                or input.KeyCode == Enum.KeyCode.Backspace
                or input.KeyCode == Enum.KeyCode.Delete then
                    -- Clear binding
                    C[key] = Enum.KeyCode.Unknown
                    btn.Text = "[none]"
                else
                    C[key] = input.KeyCode
                    btn.Text = input.KeyCode.Name
                end
                btn.TextColor3 = Color3.fromRGB(240,240,245)
                pickingKeybind = false
                conn:Disconnect()
            end
        end)
    end)
end

-- ═════════════════════════════════════════════════
--   TABS
-- ═════════════════════════════════════════════════

-- COMBAT tab
local pCombat = AddTab("Combat")
Section(pCombat, "Aimbot")
Toggle(pCombat, "Aimbot Enabled", "AimEnabled")
Slider(pCombat, "Smoothness (÷100)", "AimSmoothness", 0.05, 1, 0.05)
-- Aim Mode Cycle (RightMouse / LeftMouse / AlwaysOn / KeyE)
do
    local modes = {"RightMouse", "LeftMouse", "AlwaysOn", "KeyE"}
    local row = New("TextButton", {Parent=pCombat, Size=UDim2.new(1,0,0,34),
        BackgroundColor3=Color3.fromRGB(14,14,18), BorderSizePixel=0,
        Text="", AutoButtonColor=false, ZIndex=3})
    New("UICorner", {Parent=row, CornerRadius=UDim.new(0,2)})
    New("UIStroke", {Parent=row, Color=Color3.fromRGB(35,35,48), Thickness=1, Transparency=0.5})
    New("TextLabel", {Parent=row, BackgroundTransparency=1,
        Position=UDim2.fromOffset(12,0), Size=UDim2.new(1,-100,1,0),
        Font=Enum.Font.Gotham, TextSize=13, Text="Aim Trigger",
        TextColor3=Color3.fromRGB(220,220,230), TextXAlignment=Enum.TextXAlignment.Left})
    local vb = New("TextLabel", {Parent=row, BackgroundTransparency=1,
        Position=UDim2.fromOffset(0,0), Size=UDim2.new(1,-14,1,0),
        Font=Enum.Font.GothamBold, TextSize=12, Text=C.AimMode,
        TextColor3=Color3.fromRGB(240,240,245), TextXAlignment=Enum.TextXAlignment.Right})
    row.MouseButton1Click:Connect(function()
        local idx = 1
        for i, m in ipairs(modes) do if m == C.AimMode then idx = i break end end
        C.AimMode = modes[(idx % #modes) + 1]
        vb.Text = C.AimMode
    end)
end
Toggle(pCombat, "Show FOV Circle", "FOVEnabled")
Slider(pCombat, "FOV Radius", "FOVRadius", 40, 400, 10)
Toggle(pCombat, "Team Check", "TeamCheck")
Toggle(pCombat, "Wall Check", "WallCheck")
-- Aim Part Cycle (Head/Torso/HRP/UpperTorso)
do
    local parts = {"Head", "Torso", "HumanoidRootPart", "UpperTorso"}
    local row = New("TextButton", {Parent=pCombat, Size=UDim2.new(1,0,0,34),
        BackgroundColor3=Color3.fromRGB(14,14,18), BorderSizePixel=0,
        Text="", AutoButtonColor=false, ZIndex=3})
    New("UICorner", {Parent=row, CornerRadius=UDim.new(0,2)})
    New("UIStroke", {Parent=row, Color=Color3.fromRGB(35,35,48), Thickness=1, Transparency=0.5})
    New("TextLabel", {Parent=row, BackgroundTransparency=1,
        Position=UDim2.fromOffset(12,0), Size=UDim2.new(1,-100,1,0),
        Font=Enum.Font.Gotham, TextSize=13, Text="Aim Part",
        TextColor3=Color3.fromRGB(220,220,230), TextXAlignment=Enum.TextXAlignment.Left})
    local vb = New("TextLabel", {Parent=row, BackgroundTransparency=1,
        Position=UDim2.fromOffset(0,0), Size=UDim2.new(1,-14,1,0),
        Font=Enum.Font.GothamBold, TextSize=12, Text=C.AimPart,
        TextColor3=Color3.fromRGB(240,240,245), TextXAlignment=Enum.TextXAlignment.Right})
    row.MouseButton1Click:Connect(function()
        local idx = 1
        for i, p in ipairs(parts) do if p == C.AimPart then idx = i break end end
        C.AimPart = parts[(idx % #parts) + 1]
        vb.Text = C.AimPart
    end)
end
Section(pCombat, "Bullet Tracers")
Toggle(pCombat, "Show my Bullet Path", "BulletTracers")
Section(pCombat, "Auto Shot")
Toggle(pCombat, "Auto Shot (fires on any enemy in aim FOV)", "AutoShot")
-- Auto-disable Rapid Fire wenn Auto Shot an (verhindert server-side desync durch input-flood)
task.spawn(function()
    while task.wait(0.3) do
        if C.AutoShot and C.RapidFire then C.RapidFire = false end
    end
end)
Slider(pCombat, "Auto Shot Delay (ms)", "AutoShotDelay", 50, 500, 10)
Section(pCombat, "Weapon")
Toggle(pCombat, "Rapid Fire (auto-click)", "RapidFire")
Slider(pCombat, "Fire Rate (ms delay)", "FireRate", 15, 200, 5)
-- Hitbox Expander entfernt in anti-cheat version (triggert insta-ban in Infected Lands)

-- Hit Sound Setup — mix aus community IDs + built-in
local HitSounds = {
    Coin      = "rbxassetid://4590657391",
    Switch    = "rbxasset://sounds/switch.wav",
    Water     = "rbxasset://sounds/impact_water.mp3",
    Uuhh      = "rbxasset://sounds/uuhhh.mp3",
    Bell      = "rbxassetid://131237241",
    Metallic  = "rbxassetid://138090596",
    Skeet     = "rbxassetid://6732690176",
    Donads    = "rbxassetid://132373574",
    Roblox    = "rbxassetid://12222225",
    Ching     = "rbxassetid://131886985",
    Splat     = "rbxassetid://144884872",
}
local HitSoundOrder = {"Coin","Switch","Water","Uuhh","Bell","Metallic","Skeet","Donads","Roblox","Ching","Splat"}
local SoundService = game:GetService("SoundService")
local function playHitSound()
    local snd = Instance.new("Sound")
    snd.SoundId = HitSounds[C.HitSoundType] or HitSounds.Coin
    snd.Volume  = C.HitSoundVolume
    snd.Parent  = SoundService
    snd:Play()
    snd.Ended:Connect(function() snd:Destroy() end)
    task.delay(3, function() if snd then snd:Destroy() end end)
end

Section(pCombat, "Hit Sound")
Toggle(pCombat, "Play sound on hit", "HitSound")
Slider(pCombat, "Volume x10", "HitSoundVolume", 0.1, 3, 0.1)
-- Sound-type cycle button (mit preview beim klicken)
do
    local row = New("TextButton", {Parent=pCombat, Size=UDim2.new(1,0,0,34),
        BackgroundColor3=Color3.fromRGB(14,14,18), BorderSizePixel=0,
        Text="", AutoButtonColor=false, ZIndex=3})
    New("UICorner", {Parent=row, CornerRadius=UDim.new(0,2)})
    New("UIStroke", {Parent=row, Color=Color3.fromRGB(35,35,48), Thickness=1, Transparency=0.5})
    New("TextLabel", {Parent=row, BackgroundTransparency=1,
        Position=UDim2.fromOffset(12,0), Size=UDim2.new(1,-100,1,0),
        Font=Enum.Font.Gotham, TextSize=13, Text="Sound Type",
        TextColor3=Color3.fromRGB(220,220,230), TextXAlignment=Enum.TextXAlignment.Left})
    local vb = New("TextLabel", {Parent=row, BackgroundTransparency=1,
        Position=UDim2.fromOffset(0,0), Size=UDim2.new(1,-14,1,0),
        Font=Enum.Font.GothamBold, TextSize=12, Text=C.HitSoundType,
        TextColor3=Color3.fromRGB(240,240,245), TextXAlignment=Enum.TextXAlignment.Right})
    row.MouseButton1Click:Connect(function()
        local idx = 1
        for i, n in ipairs(HitSoundOrder) do if n == C.HitSoundType then idx = i break end end
        C.HitSoundType = HitSoundOrder[(idx % #HitSoundOrder) + 1]
        vb.Text = C.HitSoundType
        playHitSound()  -- PREVIEW instantly
    end)
end

-- VISUALS tab
local pVis = AddTab("Visuals")
Section(pVis, "Wallhack ESP")
Toggle(pVis, "Box ESP", "BoxESP")
Toggle(pVis, "Name ESP", "NameESP")
Toggle(pVis, "Health ESP", "HealthESP")
Toggle(pVis, "HP Text (87/100)", "HealthTextESP")
Toggle(pVis, "Distance ESP", "DistanceESP")
Slider(pVis, "ESP Max Distance (players)", "ESP_MaxDistance", 50, 5000, 50)
Toggle(pVis, "ESP Unlimited Distance", "ESP_Unlimited")
Toggle(pVis, "Tracer Lines", "TracerESP")
-- Tracer Origin Cycle
do
    local origins = {"Bottom", "Top", "Center"}
    local row = New("TextButton", {Parent=pVis, Size=UDim2.new(1,0,0,34),
        BackgroundColor3=Color3.fromRGB(14,14,18), BorderSizePixel=0,
        Text="", AutoButtonColor=false, ZIndex=3})
    New("UICorner", {Parent=row, CornerRadius=UDim.new(0,2)})
    New("UIStroke", {Parent=row, Color=Color3.fromRGB(35,35,48), Thickness=1, Transparency=0.5})
    New("TextLabel", {Parent=row, BackgroundTransparency=1,
        Position=UDim2.fromOffset(12,0), Size=UDim2.new(1,-100,1,0),
        Font=Enum.Font.Gotham, TextSize=13, Text="Tracer Origin",
        TextColor3=Color3.fromRGB(220,220,230), TextXAlignment=Enum.TextXAlignment.Left})
    local vb = New("TextLabel", {Parent=row, BackgroundTransparency=1,
        Position=UDim2.fromOffset(0,0), Size=UDim2.new(1,-14,1,0),
        Font=Enum.Font.GothamBold, TextSize=12, Text=C.TracerOrigin,
        TextColor3=Color3.fromRGB(240,240,245), TextXAlignment=Enum.TextXAlignment.Right})
    row.MouseButton1Click:Connect(function()
        local idx = 1
        for i, o in ipairs(origins) do if o == C.TracerOrigin then idx = i break end end
        C.TracerOrigin = origins[(idx % #origins) + 1]
        vb.Text = C.TracerOrigin
    end)
end
Toggle(pVis, "Skeleton ESP", "SkeletonESP")
Toggle(pVis, "🌴 Tung Tung Sahur Mode", "TongTong")
Section(pVis, "World ESP")
Toggle(pVis, "Item ESP (master toggle)", "ItemESP")
Toggle(pVis, "  › Ammo",     "ItemESP_Ammo")
Toggle(pVis, "  › Food",     "ItemESP_Food")
Toggle(pVis, "  › Chests",    "ItemESP_Chest")
Toggle(pVis, "  › Bookshelf", "ItemESP_Bookshelf")
Toggle(pVis, "  › Shelf",     "ItemESP_Shelf")
Slider(pVis, "Item ESP Max Distance", "ItemESP_MaxDistance", 100, 3000, 100)
Toggle(pVis, "Vehicle ESP (empty/occupied)",  "VehicleESP")
Toggle(pVis, "Dead Body ESP (loot corpses)",  "DeadBodyESP")
-- Chams Material Cycle
do
    local mats = {"Normal", "Neon", "Glass", "ForceField", "Wood", "Plastic"}
    local row = New("TextButton", {Parent=pVis, Size=UDim2.new(1,0,0,34),
        BackgroundColor3=Color3.fromRGB(14,14,18), BorderSizePixel=0,
        Text="", AutoButtonColor=false, ZIndex=3})
    New("UICorner", {Parent=row, CornerRadius=UDim.new(0,2)})
    New("UIStroke", {Parent=row, Color=Color3.fromRGB(35,35,48), Thickness=1, Transparency=0.5})
    New("TextLabel", {Parent=row, BackgroundTransparency=1,
        Position=UDim2.fromOffset(12,0), Size=UDim2.new(1,-100,1,0),
        Font=Enum.Font.Gotham, TextSize=13, Text="Chams Material",
        TextColor3=Color3.fromRGB(220,220,230), TextXAlignment=Enum.TextXAlignment.Left})
    local vb = New("TextLabel", {Parent=row, BackgroundTransparency=1,
        Position=UDim2.fromOffset(0,0), Size=UDim2.new(1,-14,1,0),
        Font=Enum.Font.GothamBold, TextSize=12, Text=C.ChamsMaterial,
        TextColor3=Color3.fromRGB(240,240,245), TextXAlignment=Enum.TextXAlignment.Right})
    row.MouseButton1Click:Connect(function()
        local idx = 1
        for i, m in ipairs(mats) do if m == C.ChamsMaterial then idx = i break end end
        C.ChamsMaterial = mats[(idx % #mats) + 1]
        vb.Text = C.ChamsMaterial
    end)
end
Section(pVis, "Crosshair")
Toggle(pVis, "Show Crosshair", "CrosshairEnabled")
Slider(pVis, "Crosshair Size", "CrosshairSize", 8, 80, 2)
Toggle(pVis, "Rotate Crosshair", "CrosshairRotate")
Slider(pVis, "Rotation Speed ×10", "CrosshairSpeed", 0.1, 5, 0.1)
-- Shape Cycle
do
    local shapes = {"Cross", "X", "Circle", "Diamond", "Skull", "Anime", "Heart", "Swastika", "BlackSun"}
    local row = New("TextButton", {Parent=pVis, Size=UDim2.new(1,0,0,34),
        BackgroundColor3=Color3.fromRGB(14,14,18), BorderSizePixel=0,
        Text="", AutoButtonColor=false, ZIndex=3})
    New("UICorner", {Parent=row, CornerRadius=UDim.new(0,2)})
    New("UIStroke", {Parent=row, Color=Color3.fromRGB(35,35,48), Thickness=1, Transparency=0.5})
    New("TextLabel", {Parent=row, BackgroundTransparency=1,
        Position=UDim2.fromOffset(12,0), Size=UDim2.new(1,-100,1,0),
        Font=Enum.Font.Gotham, TextSize=13, Text="Crosshair Shape",
        TextColor3=Color3.fromRGB(220,220,230), TextXAlignment=Enum.TextXAlignment.Left})
    local vb = New("TextLabel", {Parent=row, BackgroundTransparency=1,
        Position=UDim2.fromOffset(0,0), Size=UDim2.new(1,-14,1,0),
        Font=Enum.Font.GothamBold, TextSize=12, Text=C.CrosshairShape,
        TextColor3=Color3.fromRGB(240,240,245), TextXAlignment=Enum.TextXAlignment.Right})
    row.MouseButton1Click:Connect(function()
        local idx = 1
        for i, s in ipairs(shapes) do if s == C.CrosshairShape then idx = i break end end
        C.CrosshairShape = shapes[(idx % #shapes) + 1]
        vb.Text = C.CrosshairShape
    end)
end
Section(pVis, "Chams")
Toggle(pVis, "Chams (glow through walls)", "ChamsEnabled")
Slider(pVis, "Chams Alpha", "ChamsFill", 0, 1, 0.1)
-- Chams Mode Cycle Button
do
    local modes = {"Both", "Fill", "Outline", "Rainbow", "Wireframe"}
    local row = New("TextButton", {Parent=pVis, Size=UDim2.new(1,0,0,34),
        BackgroundColor3=Color3.fromRGB(14,14,18), BorderSizePixel=0,
        Text="", AutoButtonColor=false, ZIndex=3})
    New("UICorner", {Parent=row, CornerRadius=UDim.new(0,2)})
    New("UIStroke", {Parent=row, Color=Color3.fromRGB(35,35,48), Thickness=1, Transparency=0.5})
    New("TextLabel", {Parent=row, BackgroundTransparency=1,
        Position=UDim2.fromOffset(12,0), Size=UDim2.new(1,-100,1,0),
        Font=Enum.Font.Gotham, TextSize=13, Text="Chams Mode",
        TextColor3=Color3.fromRGB(220,220,230), TextXAlignment=Enum.TextXAlignment.Left})
    local vb = New("TextLabel", {Parent=row, BackgroundTransparency=1,
        Position=UDim2.fromOffset(0,0), Size=UDim2.new(1,-14,1,0),
        Font=Enum.Font.GothamBold, TextSize=12, Text=C.ChamsMode,
        TextColor3=Color3.fromRGB(240,240,245), TextXAlignment=Enum.TextXAlignment.Right})
    row.MouseButton1Click:Connect(function()
        local idx = 1
        for i, m in ipairs(modes) do if m == C.ChamsMode then idx = i break end end
        C.ChamsMode = modes[(idx % #modes) + 1]
        vb.Text = C.ChamsMode
    end)
end

-- MOVEMENT tab (anti-cheat safe — Fly removed, caps lowered)
local pMov = AddTab("Movement")
Section(pMov, "Speed (safe max)")
Toggle(pMov, "Speed Hack (anti-cheat safe mode)", "SpeedEnabled")
Slider(pMov, "Walk Speed (max 28 = safe)", "SpeedValue", 16, 28, 1)
Section(pMov, "Jump")
Toggle(pMov, "Jump Boost (careful, high = detected)", "JumpBoost")
Slider(pMov, "Jump Power (max 100 = safe)", "JumpValue", 50, 100, 5)
Toggle(pMov, "Infinite Jump (usually safe)", "InfJump")

-- MISC tab
local pMisc = AddTab("Misc")
Section(pMisc, "Utility")
Toggle(pMisc, "Anti-AFK", "AntiAFK")
Toggle(pMisc, "Noclip (walk through walls)", "Noclip")
Toggle(pMisc, "No Fall Damage", "NoFallDamage")

-- MM2 Role ESP (Murderer + Sheriff + Dropped Gun)
Section(pMisc, "MM2 Role ESP (only MM2)")
Toggle(pMisc, "Show Murderer (only MM2)", "ShowMurderer")
Toggle(pMisc, "Show Sheriff (only MM2)",  "ShowSheriff")
Toggle(pMisc, "Show Dropped Gun (only MM2)", "ShowDroppedGun")

-- Detection loop: findet Murderer, Sheriff und gedroppte Gun
do
    local tags = {}        -- [player] = BillboardGui
    local gunTag = nil     -- BillboardGui für die gedroppte Gun im Workspace

    local function clearPlayerTag(p)
        if tags[p] then
            pcall(function() tags[p]:Destroy() end)
            tags[p] = nil
        end
    end
    local function clearGunTag()
        if gunTag then
            pcall(function() gunTag:Destroy() end)
            gunTag = nil
        end
    end

    local function makeRoleTag(p, char, roleText, color)
        clearPlayerTag(p)
        local head = char:FindFirstChild("Head")
        if not head then return end
        local bb = Instance.new("BillboardGui")
        bb.Name = "ENI_ROLE_TAG"
        bb.Adornee = head
        bb.Size = UDim2.fromOffset(220, 40)
        bb.StudsOffset = Vector3.new(0, 3.5, 0)
        bb.AlwaysOnTop = true
        bb.Parent = GuiParent
        local lbl = Instance.new("TextLabel", bb)
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.fromScale(1, 1)
        lbl.Font = Enum.Font.GothamBlack
        lbl.TextSize = 22
        lbl.Text = roleText
        lbl.TextColor3 = color
        lbl.TextStrokeTransparency = 0
        lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
        tags[p] = bb
    end

    local function makeGunTag(part)
        clearGunTag()
        local bb = Instance.new("BillboardGui")
        bb.Name = "ENI_GUN_TAG"
        bb.Adornee = part
        bb.Size = UDim2.fromOffset(200, 40)
        bb.StudsOffset = Vector3.new(0, 2, 0)
        bb.AlwaysOnTop = true
        bb.Parent = GuiParent
        local lbl = Instance.new("TextLabel", bb)
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.fromScale(1, 1)
        lbl.Font = Enum.Font.GothamBlack
        lbl.TextSize = 20
        lbl.Text = "🔫 GUN (pick up)"
        lbl.TextColor3 = Color3.fromRGB(80, 220, 255)
        lbl.TextStrokeTransparency = 0
        lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
        gunTag = bb
    end

    local function toolIs(tool, ...)
        local n = tool.Name:lower()
        for _, kw in ipairs({...}) do
            if n:find(kw) then return true end
        end
        return false
    end

    local function playerHasTool(p, ...)
        local char = p.Character
        local bp   = p:FindFirstChildOfClass("Backpack")
        if char then
            for _, t in ipairs(char:GetChildren()) do
                if t:IsA("Tool") and toolIs(t, ...) then return true end
            end
        end
        if bp then
            for _, t in ipairs(bp:GetChildren()) do
                if t:IsA("Tool") and toolIs(t, ...) then return true end
            end
        end
        return false
    end

    task.spawn(function()
        while true do
            task.wait(0.7)

            -- Player role tags
            for _, p in ipairs(Players:GetPlayers()) do
                local char = p.Character
                local isMurderer = C.ShowMurderer and playerHasTool(p, "knife", "classicknife")
                local isSheriff  = C.ShowSheriff  and playerHasTool(p, "gun", "revolver", "pistol")

                if isMurderer and char then
                    if not tags[p] or (tags[p]:IsA("BillboardGui") and tags[p]:FindFirstChildOfClass("TextLabel").Text ~= "🔪 MURDERER") then
                        makeRoleTag(p, char, "🔪 MURDERER", Color3.fromRGB(255, 40, 60))
                    end
                elseif isSheriff and char then
                    if not tags[p] or (tags[p]:IsA("BillboardGui") and tags[p]:FindFirstChildOfClass("TextLabel").Text ~= "⭐ SHERIFF") then
                        makeRoleTag(p, char, "⭐ SHERIFF", Color3.fromRGB(80, 180, 255))
                    end
                else
                    clearPlayerTag(p)
                end
            end

            -- Dropped Gun ESP (gun tool im workspace, kein player parent)
            if C.ShowDroppedGun then
                local found = nil
                -- Helper: check ob object im spieler ist
                local function isInAnyPlayer(obj)
                    local p = obj
                    while p do
                        if p:IsA("Backpack") then return true end
                        if p:IsA("Model") and Players:GetPlayerFromCharacter(p) then return true end
                        p = p.Parent
                    end
                    return false
                end
                -- Scan workspace für ALLES was nach Gun aussieht (Tool ODER BasePart ODER Model)
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if isInAnyPlayer(obj) then continue end
                    -- Tool im workspace
                    if obj:IsA("Tool") and toolIs(obj, "gun", "revolver", "pistol") then
                        local h = obj:FindFirstChild("Handle")
                        if h and h:IsA("BasePart") then found = h; break end
                        -- Fallback: nimm ersten BasePart im Tool
                        for _, c in ipairs(obj:GetDescendants()) do
                            if c:IsA("BasePart") then found = c; break end
                        end
                        if found then break end
                    end
                    -- Model im workspace mit gun-name
                    if obj:IsA("Model") and toolIs(obj, "gun", "revolver", "pistol", "sheriff") then
                        if obj.PrimaryPart then found = obj.PrimaryPart; break end
                        for _, c in ipairs(obj:GetDescendants()) do
                            if c:IsA("BasePart") then found = c; break end
                        end
                        if found then break end
                    end
                    -- BasePart direkt (Handle-like) mit gun-name
                    if obj:IsA("BasePart") and toolIs(obj, "gunhandle", "gun_handle", "gundrop", "droppedgun") then
                        found = obj; break
                    end
                    -- BasePart namens "Handle" wo parent ein gun ist
                    if obj:IsA("BasePart") and obj.Name == "Handle" and obj.Parent
                    and toolIs(obj.Parent, "gun", "revolver", "pistol") then
                        found = obj; break
                    end
                end
                if found then
                    if not gunTag or gunTag.Adornee ~= found then
                        makeGunTag(found)
                    end
                else
                    clearGunTag()
                end
            else
                clearGunTag()
            end
        end
    end)
end

-- Auto Farm Section (MM2 + Universal Coin/Money Collector)
Section(pMisc, "Auto Farm")
local farmActive = false
local farmMode = "Universal"  -- "MM2" oder "Universal"
do
    local modes = {"Universal", "MM2"}
    -- Farm-Mode Cycle
    local modeRow = New("TextButton", {Parent=pMisc, Size=UDim2.new(1,0,0,32),
        BackgroundColor3=Color3.fromRGB(14,14,18), BorderSizePixel=0,
        Text="", AutoButtonColor=false, ZIndex=3})
    New("UICorner", {Parent=modeRow, CornerRadius=UDim.new(0,2)})
    New("TextLabel", {Parent=modeRow, BackgroundTransparency=1,
        Position=UDim2.fromOffset(12,0), Size=UDim2.new(1,-100,1,0),
        Font=Enum.Font.Gotham, TextSize=13, Text="Farm Mode",
        TextColor3=Color3.fromRGB(220,220,230), TextXAlignment=Enum.TextXAlignment.Left})
    local vb = New("TextLabel", {Parent=modeRow, BackgroundTransparency=1,
        Position=UDim2.fromOffset(0,0), Size=UDim2.new(1,-14,1,0),
        Font=Enum.Font.GothamBold, TextSize=12, Text=farmMode,
        TextColor3=Color3.fromRGB(240,240,245), TextXAlignment=Enum.TextXAlignment.Right})
    modeRow.MouseButton1Click:Connect(function()
        local idx = 1
        for i, m in ipairs(modes) do if m == farmMode then idx = i break end end
        farmMode = modes[(idx % #modes) + 1]
        vb.Text = farmMode
    end)

    -- Toggle Button
    local farmBtn = New("TextButton", {Parent=pMisc, Size=UDim2.new(1,0,0,32),
        BackgroundColor3=Color3.fromRGB(80,220,100), BorderSizePixel=0,
        Font=Enum.Font.GothamBold, TextSize=13, TextColor3=Color3.fromRGB(10,10,15),
        Text="💰  START AUTO FARM", AutoButtonColor=false, ZIndex=3})
    New("UICorner", {Parent=farmBtn, CornerRadius=UDim.new(0,2)})
    farmBtn.MouseButton1Click:Connect(function()
        farmActive = not farmActive
        if farmActive then
            farmBtn.Text = "⏸  STOP FARM"
            farmBtn.BackgroundColor3 = Color3.fromRGB(220,80,100)
        else
            farmBtn.Text = "💰  START AUTO FARM"
            farmBtn.BackgroundColor3 = Color3.fromRGB(80,220,100)
        end
    end)
end

-- Auto Farm Loop — GEFIXT (Blacklist, Cache, Safe-TP, firetouchinterest)
-- Blacklist: statische Map-Teile die 'coin/money' im Namen haben aber KEINE Pickups sind
local FARM_BLACKLIST = {
    "printer","shop","display","sign","atm","bank","vault","stash",
    "counter","register","spawner","spawn","gui","icon","label","texture",
    "clone","template","preview","holder","proxy","zone","region"
}
local function isBlacklisted(nameLower, obj)
    for _, bad in ipairs(FARM_BLACKLIST) do
        if nameLower:find(bad) then return true end
    end
    -- Anchored + große Parts = wahrscheinlich Map-Deko, kein Pickup
    if obj.Anchored and (obj.Size.X > 6 or obj.Size.Y > 6 or obj.Size.Z > 6) then
        return true
    end
    return false
end

-- Cache Pickups statt jeden Frame ganzes Workspace zu scannen
local pickupCache = {}
local lastScan   = 0
local SCAN_INTERVAL = 1.5  -- alle 1.5s neu scannen (schont die Engine massiv)

-- Helper: nimm den touchbaren BasePart aus einem Coin (kann Model oder Part sein)
local function extractTouchPart(obj)
    if obj:IsA("BasePart") then return obj end
    if obj:IsA("Model") then
        if obj.PrimaryPart then return obj.PrimaryPart end
        for _, c in ipairs(obj:GetDescendants()) do
            if c:IsA("BasePart") then return c end
        end
    end
    return nil
end

local function rescanPickups()
    pickupCache = {}

    if farmMode == "MM2" then
        -- MM2 SPECIAL: Coins liegen fast immer in workspace.CoinContainer
        local containers = {}
        local cc = Workspace:FindFirstChild("CoinContainer")
        if cc then table.insert(containers, cc) end
        -- Map-based containers (MM2 Maps haben oft Map.CoinContainer)
        local mapFolder = Workspace:FindFirstChild("Map")
        if mapFolder then
            local mcc = mapFolder:FindFirstChild("CoinContainer")
            if mcc then table.insert(containers, mcc) end
        end

        -- Alle direkten Coin-Kinder aus Containern
        for _, container in ipairs(containers) do
            for _, coin in ipairs(container:GetChildren()) do
                local part = extractTouchPart(coin)
                if part then table.insert(pickupCache, part) end
            end
        end

        -- Fallback: falls kein CoinContainer, ganze Workspace nach "Coin"-Models scannen
        if #pickupCache == 0 then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                local n = obj.Name:lower()
                if n == "coin" or n:find("coin") then
                    local part = extractTouchPart(obj)
                    if part and not isBlacklisted(n, part) then
                        table.insert(pickupCache, part)
                    end
                end
            end
        end
    else
        -- Universal (Da Hood / Rivals / etc)
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local n = obj.Name:lower()
                local match = (n:find("coin") or n:find("money") or n:find("cash")
                            or n:find("gold") or n:find("gem")  or n:find("dollar")
                            or n:find("bill") or n:find("stack")) ~= nil
                if match and not isBlacklisted(n, obj) then
                    table.insert(pickupCache, obj)
                end
            end
        end
    end
end

-- Safe collect: firetouchinterest wenn verfügbar (kein TP nötig), sonst kurzer safe-TP
local function tryCollect(hrp, target)
    if not target or not target.Parent then return end
    -- Weg 1: firetouchinterest / firetouchtransmitter (Wave supported beides)
    local fti = firetouchinterest or (getgenv and getgenv().firetouchinterest)
    local ftt = firetouchtransmitter or (getgenv and getgenv().firetouchtransmitter)
    if fti then
        pcall(fti, hrp, target, 0)  -- touch begin
        pcall(fti, hrp, target, 1)  -- touch end
        return
    end
    if ftt then
        pcall(ftt, target)
        return
    end
    -- Fallback: SAFE-TP knapp ÜBER dem Pickup (nicht IN es rein, sonst stuck)
    local originalCF = hrp.CFrame
    hrp.CFrame = CFrame.new(target.Position + Vector3.new(0, 3, 0))
    task.wait(0.05)
    -- kurz zurück damit Spieler nicht in der Luft hängt wenn Coin verschwindet
    if target.Parent == nil then
        -- pickup erfolgreich, bleib wo du bist
    else
        hrp.CFrame = originalCF
    end
end

task.spawn(function()
    while true do
        task.wait(0.08)
        if not farmActive then continue end
        local char = LP.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then continue end

        -- Cache refreshen wenn abgelaufen oder leer
        if tick() - lastScan > SCAN_INTERVAL or #pickupCache == 0 then
            rescanPickups()
            lastScan = tick()
        end

        if farmMode == "MM2" then
            -- Debug: zeig LO was passiert
            if not _G.ENI_FARM_DEBUG_SHOWN or tick() - _G.ENI_FARM_DEBUG_SHOWN > 2 then
                _G.ENI_FARM_DEBUG_SHOWN = tick()
                pcall(function()
                    game.StarterGui:SetCore("SendNotification", {
                        Title = "ENI Farm [MM2]",
                        Text  = "Coins gefunden: " .. #pickupCache,
                        Duration = 2,
                    })
                end)
            end

            -- Kombiniere BEIDE Methods parallel: micro-TP zum nächsten + fti auf alle
            local fti = firetouchinterest or (getgenv and getgenv().firetouchinterest)

            -- 1) Nächsten Coin finden
            local nearest, nearestDist = nil, math.huge
            for i = #pickupCache, 1, -1 do
                local coin = pickupCache[i]
                if not coin or not coin.Parent then
                    table.remove(pickupCache, i)
                else
                    local d = (coin.Position - hrp.Position).Magnitude
                    if d < nearestDist then nearest, nearestDist = coin, d end
                end
            end

            -- 2) Micro-TP Richtung nächsten (max 18 studs pro tick, unter MM2 anticheat)
            if nearest then
                local dir  = (nearest.Position - hrp.Position)
                local dist = dir.Magnitude
                if dist > 18 then
                    hrp.CFrame = CFrame.new(hrp.Position + dir.Unit * 18)
                elseif dist > 3 then
                    hrp.CFrame = CFrame.new(nearest.Position + Vector3.new(0, 2, 0))
                end
            end

            -- 3) firetouchinterest auf alle Coins in 25 stud Radius (nach TP)
            if fti then
                for _, coin in ipairs(pickupCache) do
                    if coin and coin.Parent then
                        local d = (coin.Position - hrp.Position).Magnitude
                        if d < 25 then
                            pcall(fti, hrp, coin, 0)
                            pcall(fti, hrp, coin, 1)
                            -- Auch Siblings im gleichen Model touchen (MM2 hat oft mehrere Parts pro Coin)
                            if coin.Parent and coin.Parent:IsA("Model") then
                                for _, sib in ipairs(coin.Parent:GetDescendants()) do
                                    if sib:IsA("BasePart") and sib ~= coin then
                                        pcall(fti, hrp, sib, 0)
                                        pcall(fti, hrp, sib, 1)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        else
            -- Universal: einer nach dem anderen
            local nearest, nearestDist = nil, math.huge
            for i = #pickupCache, 1, -1 do
                local obj = pickupCache[i]
                if not obj or not obj.Parent then
                    table.remove(pickupCache, i)
                else
                    local d = (obj.Position - hrp.Position).Magnitude
                    if d < 5000 and d < nearestDist then
                        nearest, nearestDist = obj, d
                    end
                end
            end
            if nearest then tryCollect(hrp, nearest) end
        end
    end
end)

-- FPS Boost Button
Section(pMisc, "Performance")
do
    local btn = New("TextButton", {Parent=pMisc, Size=UDim2.new(1,0,0,32),
        BackgroundColor3=Color3.fromRGB(255,180,50), BorderSizePixel=0,
        Font=Enum.Font.GothamBold, TextSize=13, TextColor3=Color3.fromRGB(10,10,15),
        Text="⚡  FPS BOOST", AutoButtonColor=false, ZIndex=3})
    New("UICorner", {Parent=btn, CornerRadius=UDim.new(0,2)})
    btn.MouseButton1Click:Connect(function()
        local Lighting = game:GetService("Lighting")
        pcall(function()
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 500
            Lighting.Brightness = 1
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        end)
        -- Disable particles, trails, beams, decals in Workspace
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
            or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles")
            or obj:IsA("Explosion") then
                pcall(function() obj.Enabled = false end)
            elseif obj:IsA("MeshPart") then
                pcall(function() obj.RenderFidelity = Enum.RenderFidelity.Automatic end)
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                pcall(function() obj.Transparency = 1 end)
            end
        end
        -- Kill grass/terrain decorations
        pcall(function()
            if Workspace.Terrain then
                Workspace.Terrain.WaterWaveSize = 0
                Workspace.Terrain.WaterWaveSpeed = 0
                Workspace.Terrain.WaterReflectance = 0
                Workspace.Terrain.WaterTransparency = 1
                Workspace.Terrain.Decoration = false
            end
        end)
        btn.Text = "✓ BOOSTED"
        task.wait(1.5); btn.Text = "⚡  FPS BOOST"
    end)
end
Section(pMisc, "Freecam")
Toggle(pMisc, "Freecam (fly camera anywhere)", "Freecam")
Slider(pMisc, "Freecam Speed", "FreecamSpeed", 10, 200, 5)

-- ═════════ TELEPORT TO PLAYER ═════════
-- ═════════ INFECTED LANDS LOCATION TELEPORTS ═════════
Section(pMisc, "Teleport to Location (Infected Lands)")

do
    local locations = {
        {label = "Military Base", pos = Vector3.new(-6061.6, 17.1,  1980.0)},
        {label = "Mayfield",      pos = Vector3.new( 3778.1, 17.0,  1039.0)},
        {label = "Louisville",    pos = Vector3.new( -296.6, 19.6, -3254.0)},
        {label = "Southpoint",    pos = Vector3.new( 3843.8, 17.0, -9509.1)},
        {label = "Pineville",     pos = Vector3.new(-4415.4, 17.0, -4078.2)},
        {label = "Free Militia",  pos = Vector3.new( 6278.3, 22.3, -1134.2)},
    }
    local function tpTo(loc)
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local start = hrp.Position
        local target = loc.pos + Vector3.new(0, 5, 0)
        for i = 1, 5 do
            hrp.CFrame = CFrame.new(start:Lerp(target, i / 5))
            task.wait(0.06)
        end
        game.StarterGui:SetCore("SendNotification", {
            Title = "ENI Teleport", Text = "Teleported to " .. loc.label, Duration = 2,
        })
    end
    local rowFrame
    for i, loc in ipairs(locations) do
        if (i - 1) % 2 == 0 then
            rowFrame = New("Frame", {Parent = pMisc, Size = UDim2.new(1, 0, 0, 32),
                BackgroundTransparency = 1})
        end
        local col = (i - 1) % 2
        local btn = New("TextButton", {
            Parent = rowFrame, Size = UDim2.new(0.5, -2, 1, -2),
            Position = UDim2.new(col * 0.5, col == 0 and 0 or 2, 0, 1),
            BackgroundColor3 = Color3.fromRGB(14, 14, 18), BorderSizePixel = 0,
            Font = Enum.Font.GothamBold, TextSize = 12,
            TextColor3 = Color3.fromRGB(230, 230, 240), Text = loc.label,
            AutoButtonColor = false, ZIndex = 3,
        })
        New("UICorner", {Parent = btn, CornerRadius = UDim.new(0, 2)})
        New("UIStroke", {Parent = btn, Color = Color3.fromRGB(35, 35, 48),
            Thickness = 1, Transparency = 0.5})
        btn.MouseEnter:Connect(function()
            Tween(btn, 0.15, {BackgroundColor3 = Color3.fromRGB(28, 28, 40)})
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, 0.15, {BackgroundColor3 = Color3.fromRGB(14, 14, 18)})
        end)
        btn.MouseButton1Click:Connect(function() tpTo(loc) end)
    end
end

Section(pMisc, "Teleport to Player")

do
    -- Player-Liste Container (scrollbar)
    local listBg = New("Frame", {Parent=pMisc, Size=UDim2.new(1,0,0,180),
        BackgroundColor3=Color3.fromRGB(14,14,18), BorderSizePixel=0})
    New("UICorner", {Parent=listBg, CornerRadius=UDim.new(0,2)})
    New("UIStroke", {Parent=listBg, Color=Color3.fromRGB(35,35,48), Thickness=1, Transparency=0.5})

    local list = New("ScrollingFrame", {Parent=listBg, Size=UDim2.new(1,-6,1,-6),
        Position=UDim2.fromOffset(3,3), BackgroundTransparency=1, BorderSizePixel=0,
        ScrollBarThickness=3, ScrollBarImageColor3=Color3.fromRGB(240,240,245),
        CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y})
    New("UIListLayout", {Parent=list, Padding=UDim.new(0,4),
        SortOrder=Enum.SortOrder.LayoutOrder})
    New("UIPadding", {Parent=list, PaddingTop=UDim.new(0,4), PaddingBottom=UDim.new(0,4),
        PaddingLeft=UDim.new(0,4), PaddingRight=UDim.new(0,4)})

    local function teleportTo(target)
        local char = LP.Character
        local tChar = target.Character
        if not char or not tChar then return end
        local hrp  = char:FindFirstChild("HumanoidRootPart")
        local tHrp = tChar:FindFirstChild("HumanoidRootPart")
        if not hrp or not tHrp then return end
        hrp.CFrame = tHrp.CFrame + Vector3.new(0, 0, 3)  -- 3 studs hinter dem Ziel
    end

    -- Global Backshot Tracker (nur EIN active target)
    local activeBackshot = nil

    local function addEntry(p)
        if p == LP then return end
        local row = New("TextButton", {Parent=list, Size=UDim2.new(1,0,0,44),
            BackgroundColor3=Color3.fromRGB(28,28,38), BorderSizePixel=0,
            Text="", AutoButtonColor=false, ZIndex=4})
        New("UICorner", {Parent=row, CornerRadius=UDim.new(0,2)})

        -- Avatar image (Roblox thumbnail URL)
        local avatar = New("ImageLabel", {Parent=row, Size=UDim2.fromOffset(36,36),
            Position=UDim2.fromOffset(4,4), BackgroundColor3=Color3.fromRGB(15,15,20),
            BorderSizePixel=0, Image=""})
        New("UICorner", {Parent=avatar, CornerRadius=UDim.new(1,0)})
        task.spawn(function()
            local ok, url = pcall(function()
                return Players:GetUserThumbnailAsync(p.UserId,
                    Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
            end)
            if ok and url then avatar.Image = url end
        end)

        -- Player name
        New("TextLabel", {Parent=row, BackgroundTransparency=1,
            Position=UDim2.fromOffset(48,4), Size=UDim2.new(1,-100,0,18),
            Font=Enum.Font.GothamBold, TextSize=13, Text=p.DisplayName,
            TextColor3=Color3.fromRGB(230,230,240), TextXAlignment=Enum.TextXAlignment.Left})
        New("TextLabel", {Parent=row, BackgroundTransparency=1,
            Position=UDim2.fromOffset(48,22), Size=UDim2.new(1,-100,0,14),
            Font=Enum.Font.Gotham, TextSize=11, Text="@"..p.Name,
            TextColor3=Color3.fromRGB(140,140,160), TextXAlignment=Enum.TextXAlignment.Left})

        -- BACKSHOT button (🔫) - TP hinter enemy + auto-fire 5x
        local shoot = New("TextButton", {Parent=row, Size=UDim2.fromOffset(30,26),
            Position=UDim2.new(1,-122,0.5,-13),
            BackgroundColor3=Color3.fromRGB(220,60,90), BorderSizePixel=0,
            Font=Enum.Font.GothamBold, TextSize=13,
            TextColor3=Color3.fromRGB(255,255,255), Text="🔫", AutoButtonColor=false, ZIndex=5})
        New("UICorner", {Parent=shoot, CornerRadius=UDim.new(0,4)})
        shoot.MouseButton1Click:Connect(function()
            -- Toggle: falls schon active auf diesen player → stop + TP back
            if activeBackshot == p then
                activeBackshot = nil
                shoot.Text = "🔫"
                shoot.BackgroundColor3 = Color3.fromRGB(220,60,90)
                return
            end
            activeBackshot = p
            shoot.Text = "🍑"
            shoot.BackgroundColor3 = Color3.fromRGB(255,120,140)
            -- Original Position merken für später
            local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            local savedCFrame = myHRP and myHRP.CFrame
            task.spawn(function()
                local i = 0
                local conn
                conn = RunService.RenderStepped:Connect(function()
                    if activeBackshot ~= p then
                        conn:Disconnect()
                        local mChar = LP.Character
                        if mChar and savedCFrame then
                            pcall(function() mChar:PivotTo(savedCFrame) end)
                            local mHRP = mChar:FindFirstChild("HumanoidRootPart")
                            if mHRP then mHRP.AssemblyLinearVelocity = Vector3.new() end
                        end
                        shoot.Text = "🔫"
                        shoot.BackgroundColor3 = Color3.fromRGB(220,60,90)
                        return
                    end
                    local tChar = p.Character
                    local tHRP  = tChar and tChar:FindFirstChild("HumanoidRootPart")
                    local mChar = LP.Character
                    local mHRP  = mChar and mChar:FindFirstChild("HumanoidRootPart")
                    local mHum  = mChar and mChar:FindFirstChildOfClass("Humanoid")
                    if not tHRP or not mHRP or not mChar then return end
                    i = i + 1
                    -- Sticky ganz nah hinter Enemy (0.8 studs)
                    local basePos = tHRP.Position + (-tHRP.CFrame.LookVector * 0.8)
                    -- Sanftere Thrust motion (kleinere Amplitude damit Server nicht flagged)
                    local thrust  = math.sin(i * 0.35) * 0.4
                    local finalPos = basePos + (-tHRP.CFrame.LookVector * thrust)
                    -- PivotTo statt CFrame — replicates besser zu Server
                    pcall(function()
                        mChar:PivotTo(CFrame.new(finalPos, tHRP.Position))
                    end)
                    mHRP.AssemblyLinearVelocity = Vector3.new()
                    -- Halte state Running damit server nicht "teleport" registriert
                    if mHum then
                        pcall(function() mHum:ChangeState(Enum.HumanoidStateType.Running) end)
                    end
                end)
            end)
        end)

        -- SPECTATE button (👁)
        local spec = New("TextButton", {Parent=row, Size=UDim2.fromOffset(30,26),
            Position=UDim2.new(1,-88,0.5,-13),
            BackgroundColor3=Color3.fromRGB(60,130,240), BorderSizePixel=0,
            Font=Enum.Font.GothamBold, TextSize=13,
            TextColor3=Color3.fromRGB(255,255,255), Text="👁", AutoButtonColor=false, ZIndex=5})
        New("UICorner", {Parent=spec, CornerRadius=UDim.new(0,4)})
        spec.MouseButton1Click:Connect(function()
            local tChar = p.Character
            local tHum  = tChar and tChar:FindFirstChildOfClass("Humanoid")
            if tHum then
                Camera.CameraSubject = tHum
                spec.Text = "✓"
                spec.BackgroundColor3 = Color3.fromRGB(120,180,255)
                task.wait(0.6)
                spec.Text = "👁"
                spec.BackgroundColor3 = Color3.fromRGB(60,130,240)
            end
        end)

        -- TP button
        local tp = New("TextButton", {Parent=row, Size=UDim2.fromOffset(48,26),
            Position=UDim2.new(1,-54,0.5,-13),
            BackgroundColor3=Color3.fromRGB(240,240,245), BorderSizePixel=0,
            Font=Enum.Font.GothamBold, TextSize=11,
            TextColor3=Color3.fromRGB(10,10,15), Text="TP", AutoButtonColor=false, ZIndex=5})
        New("UICorner", {Parent=tp, CornerRadius=UDim.new(0,4)})

        tp.MouseButton1Click:Connect(function()
            teleportTo(p)
            tp.Text = "✓"
            tp.BackgroundColor3 = Color3.fromRGB(80,255,200)
            task.wait(0.6)
            tp.Text = "TP"
            tp.BackgroundColor3 = Color3.fromRGB(240,240,245)
        end)
        -- Klick auf ganze Zeile = auch teleport
        row.MouseButton1Click:Connect(function() teleportTo(p) end)

        row:SetAttribute("PlayerId", p.UserId)
    end

    local function refresh()
        for _, c in ipairs(list:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        for _, p in ipairs(Players:GetPlayers()) do addEntry(p) end
    end

    refresh()
    Players.PlayerAdded:Connect(function(p) task.wait(0.5); addEntry(p) end)
    Players.PlayerRemoving:Connect(function(p)
        for _, c in ipairs(list:GetChildren()) do
            if c:IsA("TextButton") and c:GetAttribute("PlayerId") == p.UserId then
                c:Destroy()
            end
        end
    end)

    -- Refresh + Stop-Spectate buttons (nebeneinander)
    local btnRow = New("Frame", {Parent=pMisc, Size=UDim2.new(1,0,0,28),
        BackgroundTransparency=1})
    local refreshBtn = New("TextButton", {Parent=btnRow, Size=UDim2.new(0.5,-4,1,0),
        BackgroundColor3=Color3.fromRGB(28,28,38), BorderSizePixel=0,
        Font=Enum.Font.GothamBold, TextSize=12,
        TextColor3=Color3.fromRGB(240,240,245), Text="↻  Refresh",
        AutoButtonColor=false, ZIndex=3})
    New("UICorner", {Parent=refreshBtn, CornerRadius=UDim.new(0,2)})
    refreshBtn.MouseButton1Click:Connect(refresh)

    local stopSpec = New("TextButton", {Parent=btnRow, Size=UDim2.new(0.5,-4,1,0),
        Position=UDim2.new(0.5,4,0,0),
        BackgroundColor3=Color3.fromRGB(28,28,38), BorderSizePixel=0,
        Font=Enum.Font.GothamBold, TextSize=12,
        TextColor3=Color3.fromRGB(60,130,240), Text="⊘  Stop Spectate",
        AutoButtonColor=false, ZIndex=3})
    New("UICorner", {Parent=stopSpec, CornerRadius=UDim.new(0,2)})
    stopSpec.MouseButton1Click:Connect(function()
        local myHum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if myHum then Camera.CameraSubject = myHum end
    end)
end

-- WORLD tab
local pWorld = AddTab("World")

Section(pWorld, "Camera")
Slider(pWorld, "Camera FOV", "CameraFOV", 30, 120, 1)
Section(pWorld, "Watermark")
Toggle(pWorld, "Show Watermark (top-right)", "Watermark")
Toggle(pWorld, "Show Keybinds List", "KeybindsList")

Section(pWorld, "Sky Presets")
do
    local Lighting = game:GetService("Lighting")
    local presets = {
        {name="Day",     time=14, ambient=Color3.fromRGB(70,70,70),    fog=1e6,  brightness=2},
        {name="Sunset",  time=18, ambient=Color3.fromRGB(120,80,60),   fog=800,  brightness=1.5},
        {name="Night",   time=0,  ambient=Color3.fromRGB(15,15,25),    fog=400,  brightness=0.5},
        {name="Space",   time=0,  ambient=Color3.fromRGB(0,0,0),       fog=1e6,  brightness=0},
        {name="Fullbright", time=14, ambient=Color3.fromRGB(255,255,255), fog=1e6, brightness=3},
        {name="OFF",     off=true},
    }
    -- Save ORIGINAL lighting values um zu resetten
    local orig = {
        clockTime  = Lighting.ClockTime,
        ambient    = Lighting.Ambient,
        fogEnd     = Lighting.FogEnd,
        fogStart   = Lighting.FogStart,
        fogColor   = Lighting.FogColor,
        brightness = Lighting.Brightness,
        outdoorAmbient = Lighting.OutdoorAmbient,
    }
    local wrap = New("Frame", {Parent=pWorld, Size=UDim2.new(1,0,0,80),
        BackgroundTransparency=1})
    New("UIGridLayout", {Parent=wrap, CellSize=UDim2.new(0.5,-4,0,34),
        CellPadding=UDim2.fromOffset(8,8), SortOrder=Enum.SortOrder.LayoutOrder,
        FillDirectionMaxCells=2})
    for i, p in ipairs(presets) do
        local btn = New("TextButton", {Parent=wrap, Size=UDim2.new(0.5,-4,0,34),
            BackgroundColor3=Color3.fromRGB(28,28,38), BorderSizePixel=0,
            Font=Enum.Font.GothamBold, TextSize=12,
            TextColor3=Color3.fromRGB(240,240,245), Text=p.name,
            AutoButtonColor=false, ZIndex=3, LayoutOrder=i})
        New("UICorner", {Parent=btn, CornerRadius=UDim.new(0,2)})
        New("UIStroke", {Parent=btn, Color=Color3.fromRGB(35,35,48), Thickness=1, Transparency=0.5})
        btn.MouseButton1Click:Connect(function()
            if p.off then
                -- OFF: Enforce-Loop stoppen + originale Lighting-Werte restoren
                C.SkyPreset = "None"
                pcall(function()
                    Lighting.ClockTime      = orig.clockTime
                    Lighting.Ambient        = orig.ambient
                    Lighting.FogEnd         = orig.fogEnd
                    Lighting.FogStart       = orig.fogStart
                    Lighting.FogColor       = orig.fogColor
                    Lighting.Brightness     = orig.brightness
                    Lighting.OutdoorAmbient = orig.outdoorAmbient
                end)
                return
            end
            C.SkyPreset         = p.name
            C.WorldTime         = p.time
            Lighting.ClockTime  = p.time
            Lighting.Ambient    = p.ambient
            Lighting.FogEnd     = p.fog
            Lighting.Brightness = p.brightness
        end)
        btn.MouseEnter:Connect(function() Tween(btn, 0.15, {BackgroundColor3=Color3.fromRGB(38,38,52)}) end)
        btn.MouseLeave:Connect(function() Tween(btn, 0.15, {BackgroundColor3=Color3.fromRGB(28,28,38)}) end)
    end
end

Section(pWorld, "Time of Day")
Slider(pWorld, "Clock Time (0-24)", "WorldTime", 0, 24, 1)

-- Live-apply Camera FOV
RunService.RenderStepped:Connect(function()
    if Camera.FieldOfView ~= C.CameraFOV then
        Camera.FieldOfView = C.CameraFOV
    end
end)

-- ═════════ WATERMARK (kleiner, laenglicher, minimalistisch) ═════════
local WM = New("Frame", {Parent=ESPGui, Size=UDim2.fromOffset(240,24),
    Position=UDim2.new(1,-252,0,12), BackgroundColor3=Color3.fromRGB(10,10,15),
    BorderSizePixel=0, Visible=false, ZIndex=400})
New("UICorner", {Parent=WM, CornerRadius=UDim.new(0,4)})
local WMStroke = New("UIStroke", {Parent=WM, Color=Color3.fromRGB(255,255,255),
    Thickness=1, Transparency=0.4})
-- Kleine Line links als accent
local WMDot = New("Frame", {Parent=WM, Size=UDim2.fromOffset(2,10),
    Position=UDim2.new(0,8,0.5,-5), BackgroundColor3=Color3.fromRGB(255,255,255), BorderSizePixel=0})
-- Ein-Line Text (elongated look)
local WMText = New("TextLabel", {Parent=WM, BackgroundTransparency=1,
    Position=UDim2.fromOffset(16,0), Size=UDim2.new(1,-22,1,0),
    Font=Enum.Font.Code, TextSize=11, Text="KUNI  PRIVATE  ·  v3.0  ·  da hood",
    TextColor3=Color3.fromRGB(255,255,255), TextXAlignment=Enum.TextXAlignment.Left})

task.spawn(function()
    while true do
        task.wait(1/60)
        if C.Watermark then
            WM.Visible = true
            local t = tick() % 2
            local phase = t < 1 and t or (2 - t)
            local g = math.floor(255 * phase)
            local col = Color3.fromRGB(g, g, g)
            WMDot.BackgroundColor3 = col
            WMStroke.Color         = col
            WMText.TextColor3      = col
        else
            WM.Visible = false
        end
    end
end)

-- ═════════════════════════════════════════════════
--   KEYBINDS LIST  (draggable, clean watermark-style)
-- ═════════════════════════════════════════════════
local KB = New("Frame", {Parent=ESPGui, Size=UDim2.fromOffset(200, 100),
    Position=UDim2.new(0, 20, 0.5, 0), BackgroundColor3=Color3.fromRGB(10,10,15),
    BorderSizePixel=0, Visible=false, ZIndex=390})
New("UICorner", {Parent=KB, CornerRadius=UDim.new(0,4)})
New("UIStroke", {Parent=KB, Color=Color3.fromRGB(255,255,255), Thickness=1, Transparency=0.4})
-- Header
local kbHeader = New("Frame", {Parent=KB, Size=UDim2.new(1,0,0,22),
    BackgroundColor3=Color3.fromRGB(16,16,22), BorderSizePixel=0})
New("UICorner", {Parent=kbHeader, CornerRadius=UDim.new(0,4)})
New("Frame", {Parent=kbHeader, Size=UDim2.new(1,0,0,10), Position=UDim2.new(0,0,1,-10),
    BackgroundColor3=Color3.fromRGB(16,16,22), BorderSizePixel=0})
New("Frame", {Parent=kbHeader, Size=UDim2.fromOffset(2,10), Position=UDim2.new(0,8,0.5,-5),
    BackgroundColor3=Color3.fromRGB(255,255,255), BorderSizePixel=0})
New("TextLabel", {Parent=kbHeader, BackgroundTransparency=1,
    Position=UDim2.fromOffset(16,0), Size=UDim2.new(1,-22,1,0),
    Font=Enum.Font.Code, TextSize=10, Text="KEYBINDS",
    TextColor3=Color3.fromRGB(255,255,255), TextXAlignment=Enum.TextXAlignment.Left})

-- Body (list)
local kbBody = New("Frame", {Parent=KB, Size=UDim2.new(1,-12,1,-30),
    Position=UDim2.fromOffset(6,26), BackgroundTransparency=1})
New("UIListLayout", {Parent=kbBody, Padding=UDim.new(0,3),
    SortOrder=Enum.SortOrder.LayoutOrder})

-- Keybind entries (dynamic — reads from C on each render)
local kbEntries = {}
local function addKbEntry(label, keyProp)
    local row = New("Frame", {Parent=kbBody, Size=UDim2.new(1,0,0,16),
        BackgroundTransparency=1})
    local lbl = New("TextLabel", {Parent=row, BackgroundTransparency=1,
        Position=UDim2.fromOffset(2,0), Size=UDim2.new(0.6,-4,1,0),
        Font=Enum.Font.Code, TextSize=10, Text=label,
        TextColor3=Color3.fromRGB(200,200,205), TextXAlignment=Enum.TextXAlignment.Left})
    local key = New("TextLabel", {Parent=row, BackgroundTransparency=1,
        Position=UDim2.new(0.6,0,0,0), Size=UDim2.new(0.4,-4,1,0),
        Font=Enum.Font.Code, TextSize=10, Text="[--]",
        TextColor3=Color3.fromRGB(140,140,150), TextXAlignment=Enum.TextXAlignment.Right})
    table.insert(kbEntries, {row=row, lbl=lbl, key=key, prop=keyProp})
end
addKbEntry("Menu",     "MenuKey")
addKbEntry("Freecam",  "FreecamKey")
addKbEntry("Fly",      "FlyKey")

-- Drag support
do
    local drag, ds, sp
    kbHeader.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag=true; ds=i.Position; sp=KB.Position
        end
    end)
    kbHeader.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then drag=false end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - ds
            KB.Position = UDim2.new(sp.X.Scale, sp.X.Offset+d.X, sp.Y.Scale, sp.Y.Offset+d.Y)
        end
    end)
end

-- Auto-adjust height + live update + highlight on press
task.spawn(function()
    while true do
        task.wait(1/30)
        if C.KeybindsList then
            KB.Visible = true
            KB.Size = UDim2.fromOffset(200, 30 + #kbEntries * 19)
            for _, e in ipairs(kbEntries) do
                local keyCode = C[e.prop]
                e.key.Text = "[" .. (keyCode and keyCode.Name or "--") .. "]"
                -- Highlight wenn Taste gedrueckt
                if keyCode and UIS:IsKeyDown(keyCode) then
                    e.lbl.TextColor3 = Color3.fromRGB(240,240,245)
                    e.key.TextColor3 = Color3.fromRGB(240,240,245)
                else
                    e.lbl.TextColor3 = Color3.fromRGB(200,200,205)
                    e.key.TextColor3 = Color3.fromRGB(140,140,150)
                end
            end
        else
            KB.Visible = false
        end
    end
end)

-- ═════════════════════════════════════════════════
--   CROSSHAIR  (5 Shapes, Farbe, Rotation, Speed)
-- ═════════════════════════════════════════════════
local CH = New("Frame", {Parent=ESPGui, Size=UDim2.fromOffset(60,60),
    AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.fromScale(0.5,0.5),
    BackgroundTransparency=1, Visible=false, ZIndex=350})

-- Shape 1: Cross (4 arms mit gap in der mitte)
local cross = New("Frame", {Parent=CH, BackgroundTransparency=1, Size=UDim2.fromScale(1,1), Name="Cross"})
local cU = New("Frame", {Parent=cross, AnchorPoint=Vector2.new(0.5,1), Position=UDim2.new(0.5,0,0.5,-4),
    Size=UDim2.fromOffset(2,12), BorderSizePixel=0})
local cD = New("Frame", {Parent=cross, AnchorPoint=Vector2.new(0.5,0), Position=UDim2.new(0.5,0,0.5,4),
    Size=UDim2.fromOffset(2,12), BorderSizePixel=0})
local cL = New("Frame", {Parent=cross, AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(0.5,-4,0.5,0),
    Size=UDim2.fromOffset(12,2), BorderSizePixel=0})
local cR = New("Frame", {Parent=cross, AnchorPoint=Vector2.new(0,0.5), Position=UDim2.new(0.5,4,0.5,0),
    Size=UDim2.fromOffset(12,2), BorderSizePixel=0})

-- Shape 2: X (2 rotated bars)
local xShape = New("Frame", {Parent=CH, BackgroundTransparency=1, Size=UDim2.fromScale(1,1),
    Rotation=45, Visible=false, Name="X"})
local xA = New("Frame", {Parent=xShape, AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.fromScale(0.5,0.5),
    Size=UDim2.fromOffset(28,2), BorderSizePixel=0})
local xB = New("Frame", {Parent=xShape, AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.fromScale(0.5,0.5),
    Size=UDim2.fromOffset(2,28), BorderSizePixel=0})

-- Shape 3: Circle (ring + center dot)
local circle = New("Frame", {Parent=CH, BackgroundTransparency=1, AnchorPoint=Vector2.new(0.5,0.5),
    Position=UDim2.fromScale(0.5,0.5), Size=UDim2.fromScale(1,1), Visible=false, Name="Circle"})
New("UICorner", {Parent=circle, CornerRadius=UDim.new(1,0)})
local cRing = New("UIStroke", {Parent=circle, Thickness=2})
local cDot = New("Frame", {Parent=circle, AnchorPoint=Vector2.new(0.5,0.5),
    Position=UDim2.fromScale(0.5,0.5), Size=UDim2.fromOffset(3,3), BorderSizePixel=0})
New("UICorner", {Parent=cDot, CornerRadius=UDim.new(1,0)})

-- Shape 4: Diamond (rotated square outline)
local dia = New("Frame", {Parent=CH, BackgroundTransparency=1, AnchorPoint=Vector2.new(0.5,0.5),
    Position=UDim2.fromScale(0.5,0.5), Size=UDim2.fromScale(0.7,0.7),
    Rotation=45, Visible=false, Name="Diamond"})
local dStroke = New("UIStroke", {Parent=dia, Thickness=2})
local dDot = New("Frame", {Parent=CH, AnchorPoint=Vector2.new(0.5,0.5),
    Position=UDim2.fromScale(0.5,0.5), Size=UDim2.fromOffset(3,3), BorderSizePixel=0,
    Visible=false, Name="DiamondDot"})
New("UICorner", {Parent=dDot, CornerRadius=UDim.new(1,0)})

-- Shape 5: Skull emoji
local skull = New("TextLabel", {Parent=CH, BackgroundTransparency=1,
    AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.fromScale(0.5,0.5),
    Size=UDim2.fromScale(1,1), Font=Enum.Font.GothamBold, Text="💀",
    TextSize=32, TextColor3=Color3.new(1,1,1), Visible=false, Name="Skull"})

-- Shape 6: Anime (Astolfo vibes - Sakura + UwU heart aura)
local anime = New("TextLabel", {Parent=CH, BackgroundTransparency=1,
    AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.fromScale(0.5,0.5),
    Size=UDim2.fromScale(1,1), Font=Enum.Font.GothamBold, Text="🌸",
    TextSize=32, TextColor3=Color3.new(1,1,1), Visible=false, Name="Anime"})

-- Shape 7: Heart (uwu / femboy vibes)
local heart = New("TextLabel", {Parent=CH, BackgroundTransparency=1,
    AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.fromScale(0.5,0.5),
    Size=UDim2.fromScale(1,1), Font=Enum.Font.GothamBold, Text="♥",
    TextSize=32, TextColor3=Color3.new(1,1,1), Visible=false, Name="Heart"})

-- Shape 8: Swastika (4 Arme mit abgebogenen Enden)
local swas = New("Frame", {Parent=CH, BackgroundTransparency=1, AnchorPoint=Vector2.new(0.5,0.5),
    Position=UDim2.fromScale(0.5,0.5), Size=UDim2.fromScale(1,1), Visible=false, Name="Swastika"})
-- 4 Hauptarme (kreuz)
local sU = New("Frame", {Parent=swas, AnchorPoint=Vector2.new(0.5,1), Position=UDim2.fromScale(0.5,0.5), BorderSizePixel=0})
local sD = New("Frame", {Parent=swas, AnchorPoint=Vector2.new(0.5,0), Position=UDim2.fromScale(0.5,0.5), BorderSizePixel=0})
local sL = New("Frame", {Parent=swas, AnchorPoint=Vector2.new(1,0.5), Position=UDim2.fromScale(0.5,0.5), BorderSizePixel=0})
local sR = New("Frame", {Parent=swas, AnchorPoint=Vector2.new(0,0.5), Position=UDim2.fromScale(0.5,0.5), BorderSizePixel=0})
-- 4 abgebogene Enden (jeweils am ende der arme, 90° zur Armrichtung)
-- Klassisches rechtsdrehendes Muster (arms bend clockwise)
local sUt = New("Frame", {Parent=swas, AnchorPoint=Vector2.new(0,1),   BorderSizePixel=0})   -- oben-arm-ende → rechts
local sDt = New("Frame", {Parent=swas, AnchorPoint=Vector2.new(1,0),   BorderSizePixel=0})   -- unten-arm-ende → links
local sLt = New("Frame", {Parent=swas, AnchorPoint=Vector2.new(1,1),   BorderSizePixel=0})   -- links-arm-ende → oben (nach oben abknicken)
local sRt = New("Frame", {Parent=swas, AnchorPoint=Vector2.new(0,0),   BorderSizePixel=0})   -- rechts-arm-ende → unten

-- Shape 9: Black Sun (12 Speichen + dicker äußerer Ring + kleiner Mittelpunkt)
local sun = New("Frame", {Parent=CH, BackgroundTransparency=1, AnchorPoint=Vector2.new(0.5,0.5),
    Position=UDim2.fromScale(0.5,0.5), Size=UDim2.fromScale(1,1), Visible=false, Name="BlackSun"})
-- Äußerer dicker Ring
local sunOuter = New("Frame", {Parent=sun, BackgroundTransparency=1, AnchorPoint=Vector2.new(0.5,0.5),
    Position=UDim2.fromScale(0.5,0.5)})
New("UICorner", {Parent=sunOuter, CornerRadius=UDim.new(1,0)})
local sunOuterStroke = New("UIStroke", {Parent=sunOuter, Thickness=4})
-- 12 radiale Speichen
local sunSpokes = {}
for i = 1, 12 do
    local spoke = New("Frame", {Parent=sun, AnchorPoint=Vector2.new(0.5,0.5),
        Position=UDim2.fromScale(0.5,0.5), BorderSizePixel=0,
        Rotation=(i-1) * 30})
    sunSpokes[i] = spoke
end
-- Innerer Ring (kleiner Kreis in der Mitte, Speichen stoßen an ihn)
local sunInner = New("Frame", {Parent=sun, BackgroundTransparency=1, AnchorPoint=Vector2.new(0.5,0.5),
    Position=UDim2.fromScale(0.5,0.5)})
New("UICorner", {Parent=sunInner, CornerRadius=UDim.new(1,0)})
local sunInnerStroke = New("UIStroke", {Parent=sunInner, Thickness=2})
-- Mittelpunkt
local sunDot = New("Frame", {Parent=sun, AnchorPoint=Vector2.new(0.5,0.5),
    Position=UDim2.fromScale(0.5,0.5), BorderSizePixel=0})
New("UICorner", {Parent=sunDot, CornerRadius=UDim.new(1,0)})

local function setShape(name)
    cross.Visible  = (name == "Cross")
    xShape.Visible = (name == "X")
    circle.Visible = (name == "Circle")
    dia.Visible    = (name == "Diamond")
    dDot.Visible   = (name == "Diamond")
    skull.Visible  = (name == "Skull")
    anime.Visible  = (name == "Anime")
    heart.Visible  = (name == "Heart")
    swas.Visible   = (name == "Swastika")
    sun.Visible    = (name == "BlackSun")
end

-- Live render loop
RunService.RenderStepped:Connect(function()
    CH.Visible = C.CrosshairEnabled
    if not C.CrosshairEnabled then return end

    local sz = C.CrosshairSize
    -- Container: 3x size um Platz fuer alle shapes zu haben
    CH.Size = UDim2.fromOffset(sz * 3, sz * 3)

    -- Cross: arme skalieren mit size, gap = sz*0.15
    local armLen = sz * 0.55
    local gap    = sz * 0.15
    cU.Size = UDim2.fromOffset(2, armLen); cU.Position = UDim2.new(0.5,0,0.5,-gap)
    cD.Size = UDim2.fromOffset(2, armLen); cD.Position = UDim2.new(0.5,0,0.5, gap)
    cL.Size = UDim2.fromOffset(armLen, 2); cL.Position = UDim2.new(0.5,-gap,0.5,0)
    cR.Size = UDim2.fromOffset(armLen, 2); cR.Position = UDim2.new(0.5, gap,0.5,0)
    -- X: 2 rotated bars
    xA.Size = UDim2.fromOffset(sz * 1.2, 2)
    xB.Size = UDim2.fromOffset(2, sz * 1.2)
    -- Circle: fixed relative size
    circle.Size = UDim2.fromOffset(sz * 1.5, sz * 1.5)
    -- Diamond
    dia.Size = UDim2.fromOffset(sz * 1.2, sz * 1.2)
    -- Skull / Anime / Heart: TextSize scaling
    skull.TextSize = sz * 1.5
    anime.TextSize = sz * 1.5
    heart.TextSize = sz * 1.5
    -- Swastika: 4 Arme (Länge = sz), Balken-Dicke = sz*0.15, Bent-Ends = sz*0.5
    do
        local arm   = sz            -- Armlänge
        local thick = math.max(2, math.floor(sz * 0.15))
        local bend  = sz * 0.5      -- Länge des abgebogenen Endes
        sU.Size = UDim2.fromOffset(thick, arm)
        sD.Size = UDim2.fromOffset(thick, arm)
        sL.Size = UDim2.fromOffset(arm, thick)
        sR.Size = UDim2.fromOffset(arm, thick)
        -- Bent-Ends (Positionen relativ zum swas-Center, in scale+offset)
        -- Oben-Arm-Ende sitzt bei (0.5, 0.5 - arm), Bend geht nach RECHTS
        sUt.Size     = UDim2.fromOffset(bend, thick)
        sUt.Position = UDim2.new(0.5, -thick/2, 0.5, -arm)
        -- Unten-Arm-Ende sitzt bei (0.5, 0.5 + arm), Bend geht nach LINKS
        sDt.Size     = UDim2.fromOffset(bend, thick)
        sDt.Position = UDim2.new(0.5,  thick/2, 0.5,  arm)
        -- Links-Arm-Ende sitzt bei (0.5 - arm, 0.5), Bend geht nach OBEN
        sLt.Size     = UDim2.fromOffset(thick, bend)
        sLt.Position = UDim2.new(0.5, -arm, 0.5,  thick/2)
        -- Rechts-Arm-Ende sitzt bei (0.5 + arm, 0.5), Bend geht nach UNTEN
        sRt.Size     = UDim2.fromOffset(thick, bend)
        sRt.Position = UDim2.new(0.5,  arm, 0.5, -thick/2)
    end
    -- Black Sun: Speichen zwischen innerem und äußerem Ring, dicker Outer-Ring
    do
        local outer      = sz * 1.4
        local inner      = sz * 0.35
        local spokeLen   = outer - inner  -- Speichen füllen den Raum zwischen den Ringen
        local spokeThick = math.max(3, math.floor(sz * 0.14))
        sunOuter.Size = UDim2.fromOffset(outer, outer)
        sunInner.Size = UDim2.fromOffset(inner, inner)
        sunDot.Size   = UDim2.fromOffset(math.max(2, sz * 0.08), math.max(2, sz * 0.08))
        sunOuterStroke.Thickness = math.max(3, math.floor(sz * 0.12))
        for _, spoke in ipairs(sunSpokes) do
            spoke.Size = UDim2.fromOffset(spokeThick, spokeLen)
        end
    end

    -- Shape wechseln
    setShape(C.CrosshairShape)

    -- Farbe auf alle Elemente
    local col = C.CrosshairColor
    cU.BackgroundColor3 = col; cD.BackgroundColor3 = col
    cL.BackgroundColor3 = col; cR.BackgroundColor3 = col
    xA.BackgroundColor3 = col; xB.BackgroundColor3 = col
    cRing.Color         = col
    cDot.BackgroundColor3 = col
    dStroke.Color       = col
    dDot.BackgroundColor3 = col
    skull.TextColor3    = col
    anime.TextColor3    = col
    heart.TextColor3    = col
    sU.BackgroundColor3 = col; sD.BackgroundColor3 = col
    sL.BackgroundColor3 = col; sR.BackgroundColor3 = col
    sUt.BackgroundColor3= col; sDt.BackgroundColor3= col
    sLt.BackgroundColor3= col; sRt.BackgroundColor3= col
    for _, spoke in ipairs(sunSpokes) do spoke.BackgroundColor3 = col end
    sunOuterStroke.Color = col
    sunInnerStroke.Color = col
    sunDot.BackgroundColor3 = col

    -- Rotation
    if C.CrosshairRotate then
        CH.Rotation = (tick() * 90 * C.CrosshairSpeed) % 360
    else
        CH.Rotation = 0
    end
end)

-- ═════════ SKY PRESET ENFORCEMENT (verhindert dass Game preset überschreibt) ═════════
local skyPresetVals = {
    Day        = {14, Color3.fromRGB(70,70,70),    1e6,  2},
    Sunset     = {18, Color3.fromRGB(120,80,60),   800,  1.5},
    Night      = {0,  Color3.fromRGB(15,15,25),    400,  0.5},
    Space      = {0,  Color3.fromRGB(0,0,0),       1e6,  0},
    Fullbright = {14, Color3.fromRGB(255,255,255), 1e6,  3},
    Reset      = {14, Color3.fromRGB(70,70,70),    1e6,  1},
}
task.spawn(function()
    local Lighting = game:GetService("Lighting")
    while task.wait(1) do
        if C.SkyPreset and C.SkyPreset ~= "None" and skyPresetVals[C.SkyPreset] then
            local p = skyPresetVals[C.SkyPreset]
            Lighting.ClockTime  = p[1]
            Lighting.Ambient    = p[2]
            Lighting.FogEnd     = p[3]
            Lighting.Brightness = p[4]
        end
    end
end)

-- ═════════ DEAD BODY ESP (highlight corpses + loot bags) ═════════
local deadCache = {}
local function isDeadBody(obj)
    if not obj:IsA("Model") then return false end
    if obj == LP.Character then return false end
    if Players:GetPlayerFromCharacter(obj) then return false end
    -- Nur DEAD Humanoid Models (Health = 0 mit Head)
    local hum = obj:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health <= 0 and obj:FindFirstChild("Head") then
        return true
    end
    -- Nur sehr spezifische corpse-Namen (kein "body" / "box" / "player" false-positives)
    local n = obj.Name:lower()
    if n == "corpse" or n:find("deadbody") or n:find("dead_body")
    or n:find("corpse") or n:find("ragdoll") then
        return true
    end
    return false
end

task.spawn(function()
    while task.wait(0.5) do
        if C.DeadBodyESP then
            local seen = {}
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if isDeadBody(obj) and not Players:GetPlayerFromCharacter(obj) then
                    seen[obj] = true
                    local ent = deadCache[obj]
                    if not ent then
                        local hl = Instance.new("Highlight")
                        hl.Adornee = obj
                        hl.FillColor = C.DeadBodyColor
                        hl.OutlineColor = C.DeadBodyColor
                        hl.FillTransparency = 0.5
                        hl.OutlineTransparency = 0
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.Parent = ESPGui
                        -- BillboardGui label
                        local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                        local bb, lbl
                        if part then
                            bb = New("BillboardGui", {Parent=ESPGui, Adornee=part,
                                Size=UDim2.fromOffset(50,10), StudsOffset=Vector3.new(0,2.5,0),
                                AlwaysOnTop=true, LightInfluence=0})
                            lbl = New("TextLabel", {Parent=bb, BackgroundTransparency=1,
                                Size=UDim2.fromScale(1,1), Font=Enum.Font.Gotham, TextSize=8,
                                Text="body", TextColor3=C.DeadBodyColor,
                                TextStrokeTransparency=0.3})
                        end
                        ent = {hl=hl, bb=bb, lbl=lbl}
                        deadCache[obj] = ent
                    else
                        ent.hl.FillColor = C.DeadBodyColor
                        ent.hl.OutlineColor = C.DeadBodyColor
                        if ent.lbl then ent.lbl.TextColor3 = C.DeadBodyColor end
                    end
                end
            end
            -- Cleanup
            for obj, ent in pairs(deadCache) do
                if not seen[obj] or not obj.Parent then
                    if ent.hl then ent.hl:Destroy() end
                    if ent.bb then ent.bb:Destroy() end
                    deadCache[obj] = nil
                end
            end
        else
            for obj, ent in pairs(deadCache) do
                if ent.hl then ent.hl:Destroy() end
                if ent.bb then ent.bb:Destroy() end
                deadCache[obj] = nil
            end
        end
    end
end)

-- WorldTime: nur updaten wenn USER slidet, nicht dauerhaft sync
-- (verhindert Sky-Flicker in Games die ClockTime dynamisch aendern)
local lastAppliedTime = C.WorldTime
task.spawn(function()
    local Lighting = game:GetService("Lighting")
    while task.wait(0.15) do
        if C.WorldTime ~= lastAppliedTime then
            Lighting.ClockTime = C.WorldTime
            lastAppliedTime = C.WorldTime
        end
    end
end)

-- COLORS tab
local pCol = AddTab("Colors")

-- ═════════ Color Picker Helper ═════════
local PRESETS = {
    Color3.fromRGB(240,240,245),   -- white (default)
    Color3.fromRGB(255,60,90),   -- red
    Color3.fromRGB(60,200,255),  -- cyan
    Color3.fromRGB(180,80,255),  -- purple
    Color3.fromRGB(255,180,60),  -- orange
    Color3.fromRGB(255,80,180),  -- pink
    Color3.fromRGB(255,255,80),  -- yellow
    Color3.fromRGB(240,240,240), -- pure white
    Color3.fromRGB(0,0,0),       -- BLACK (blendet Streifen komplett aus)
}

-- Menu accent update — matches multiple accent colors (fixed old-green + new-white)
local accentTracker = {
    Color3.fromRGB(0,255,170),      -- old green (backward compat)
    Color3.fromRGB(240,240,245),    -- current white
}
local function updateMenuAccent(newColor)
    -- Merke aktuelle Accent-Farbe, damit naechster Call wieder greift
    table.insert(accentTracker, C.MenuAccent)
    C.MenuAccent = newColor
    for _, obj in ipairs(Gui:GetDescendants()) do
        if obj.Name == "ColorSwatch" or obj.Name == "ColorPreview" then continue end
        local parent = obj.Parent
        if parent and (parent.Name == "ColorSwatch" or parent.Name == "ColorPreview") then continue end
        for _, prop in ipairs({"BackgroundColor3", "TextColor3"}) do
            local ok, val = pcall(function() return obj[prop] end)
            if ok and typeof(val) == "Color3" then
                for _, oldC in ipairs(accentTracker) do
                    if val == oldC then
                        pcall(function() obj[prop] = newColor end)
                        break
                    end
                end
            end
        end
        if obj:IsA("UIStroke") then
            for _, oldC in ipairs(accentTracker) do
                if obj.Color == oldC then obj.Color = newColor; break end
            end
        end
    end
    -- Nach dem walk: nur die neue Farbe im Tracker behalten
    accentTracker = {newColor}
    -- POST-LOCK: alle Backgrounds hart auf tiefschwarz zurücksetzen
    -- MainAccent darf nur die Streifen/Glows (AccentBar, AccentGlow, mainGlow) einfärben, sonst nix
    for _, obj in ipairs(Gui:GetDescendants()) do
        local locked = obj:GetAttribute("BgLocked")
        if locked then
            pcall(function() obj.BackgroundColor3 = BG_LOCK end)
        end
    end
end

local function ColorPicker(parent, label, key, isMenuAccent)
    local row = New("Frame", {Parent=parent, Size=UDim2.new(1,0,0,58),
        BackgroundColor3=Color3.fromRGB(14,14,18), BorderSizePixel=0})
    New("UICorner", {Parent=row, CornerRadius=UDim.new(0,2)})
    New("UIStroke", {Parent=row, Color=Color3.fromRGB(35,35,48), Thickness=1, Transparency=0.5})
    New("TextLabel", {Parent=row, BackgroundTransparency=1,
        Position=UDim2.fromOffset(12,4), Size=UDim2.new(1,-24,0,18),
        Font=Enum.Font.GothamBold, TextSize=12, Text=label,
        TextColor3=Color3.fromRGB(220,220,230), TextXAlignment=Enum.TextXAlignment.Left})

    -- Current color preview swatch (right side)
    local preview = New("Frame", {Parent=row, Name="ColorPreview", Size=UDim2.fromOffset(22,14),
        Position=UDim2.new(1,-30,0,6),
        BackgroundColor3=C[key], BorderSizePixel=0})
    New("UICorner", {Parent=preview, CornerRadius=UDim.new(0,3)})
    New("UIStroke", {Parent=preview, Color=Color3.fromRGB(50,50,65), Thickness=1})

    -- Preset swatches row
    local swatchRow = New("Frame", {Parent=row, Size=UDim2.new(1,-24,0,26),
        Position=UDim2.fromOffset(12,26), BackgroundTransparency=1})
    local uilist = New("UIListLayout", {Parent=swatchRow, FillDirection=Enum.FillDirection.Horizontal,
        Padding=UDim.new(0,6), SortOrder=Enum.SortOrder.LayoutOrder,
        VerticalAlignment=Enum.VerticalAlignment.Center})

    for i, color in ipairs(PRESETS) do
        local sw = New("TextButton", {Parent=swatchRow, Name="ColorSwatch",
            Size=UDim2.fromOffset(26,26), BackgroundColor3=color, BorderSizePixel=0, Text="",
            AutoButtonColor=false, ZIndex=4, LayoutOrder=i})
        New("UICorner", {Parent=sw, CornerRadius=UDim.new(0,4)})
        New("UIStroke", {Parent=sw, Color=Color3.fromRGB(50,50,65), Thickness=1})
        sw.MouseButton1Click:Connect(function()
            if isMenuAccent then
                updateMenuAccent(color)
            else
                C[key] = color
            end
            preview.BackgroundColor3 = color
        end)
        sw.MouseEnter:Connect(function() Tween(sw, 0.1, {Size=UDim2.fromOffset(30,30)}) end)
        sw.MouseLeave:Connect(function() Tween(sw, 0.1, {Size=UDim2.fromOffset(26,26)}) end)
    end
end

Section(pCol, "ESP Colors")
ColorPicker(pCol, "Enemy Color", "ESPColor")
Toggle(pCol, "  🌈 Rainbow Enemy", "RainbowESP")
ColorPicker(pCol, "Team Color",  "ESPTeamColor")
Toggle(pCol, "  🌈 Rainbow Team", "RainbowTeam")
Section(pCol, "Aimbot")
ColorPicker(pCol, "FOV Circle Color", "FOVColor")
Toggle(pCol, "  🌈 Rainbow FOV", "RainbowFOV")
Section(pCol, "Tracer")
ColorPicker(pCol, "Tracer Color", "TracerColor")
Section(pCol, "Bullet")
ColorPicker(pCol, "Bullet Tracer Color", "BulletColor")
Section(pCol, "Dead Body")
ColorPicker(pCol, "Dead Body ESP Color", "DeadBodyColor")
Section(pCol, "Crosshair")
ColorPicker(pCol, "Crosshair Color", "CrosshairColor")
Toggle(pCol, "  🌈 Rainbow Crosshair", "RainbowCrosshair")
Section(pCol, "Menu")
ColorPicker(pCol, "Menu Accent Color", "MenuAccent", true)
Toggle(pCol, "  🌈 Rainbow Menu", "RainbowMenu")

-- Rainbow Loops (per-color, nach updateMenuAccent definiert)
task.spawn(function()
    while true do
        task.wait(1/30)
        local hue = (tick() * 0.15) % 1
        local rainbow = Color3.fromHSV(hue, 1, 1)
        if C.RainbowESP       then C.ESPColor       = rainbow end
        if C.RainbowTeam      then C.ESPTeamColor   = rainbow end
        if C.RainbowFOV       then C.FOVColor       = rainbow end
        if C.RainbowFOV       then C.TracerColor    = rainbow end  -- tracer folgt FOV rainbow
        if C.RainbowCrosshair then C.CrosshairColor = rainbow end
        if C.RainbowMenu and C.MenuAccent ~= rainbow then
            updateMenuAccent(rainbow)
        end
    end
end)

-- ═════════════════════════════════════════════════
--   INFO TAB — Supported Games
-- ═════════════════════════════════════════════════
local pInfo = AddTab("Info")

-- Helper: eine Game-Zeile im Info-Tab
local function InfoRow(parent, gameName, category, note)
    local row = New("Frame", {Parent=parent, Size=UDim2.new(1,0,0,46),
        BackgroundColor3=Color3.fromRGB(14,14,18), BorderSizePixel=0})
    New("UICorner", {Parent=row, CornerRadius=UDim.new(0,2)})
    New("UIStroke", {Parent=row, Color=Color3.fromRGB(35,35,48), Thickness=1, Transparency=0.5})
    -- Grüner Status-Dot links
    local dot = New("Frame", {Parent=row, Size=UDim2.fromOffset(6,6),
        Position=UDim2.new(0,12,0.5,-3), BackgroundColor3=Color3.fromRGB(80,220,120),
        BorderSizePixel=0})
    New("UICorner", {Parent=dot, CornerRadius=UDim.new(1,0)})
    -- Game-Name (fett)
    New("TextLabel", {Parent=row, BackgroundTransparency=1,
        Position=UDim2.fromOffset(28,4), Size=UDim2.new(1,-40,0,18),
        Font=Enum.Font.GothamBold, TextSize=13, Text=gameName,
        TextColor3=Color3.fromRGB(240,240,245), TextXAlignment=Enum.TextXAlignment.Left})
    -- Kategorie + Note (klein, grau)
    New("TextLabel", {Parent=row, BackgroundTransparency=1,
        Position=UDim2.fromOffset(28,22), Size=UDim2.new(1,-40,0,18),
        Font=Enum.Font.Gotham, TextSize=11, Text=category .. "  ·  " .. note,
        TextColor3=Color3.fromRGB(140,140,160), TextXAlignment=Enum.TextXAlignment.Left})
end

Section(pInfo, "Getestete Games")
InfoRow(pInfo, "Murder Mystery 2",   "Round-based", "Auto Farm, Aimbot, ESP, Speed")
InfoRow(pInfo, "Da Hood",             "Open World",   "Aimbot, ESP, Silent Aim, Money Farm")
InfoRow(pInfo, "Arsenal",             "FPS",           "Aimbot, ESP, Rapid Fire, Auto Shot")
InfoRow(pInfo, "Infected Lands",      "Survival FPS", "Aimbot, ESP, Wallcheck, No Recoil")
InfoRow(pInfo, "Phantom Forces",     "FPS",           "Aimbot, ESP, Chams, Rapid Fire")
InfoRow(pInfo, "Bad Business",        "FPS",           "Aimbot, ESP, Auto Shot")
InfoRow(pInfo, "Counter Blox",        "FPS",           "Aimbot, ESP, Chams")
InfoRow(pInfo, "Rivals",              "FPS",           "Aimbot, ESP, Auto Shot")

Section(pInfo, "Universal Features")
InfoRow(pInfo, "Alle FPS Games",      "Universal",    "ESP, Aimbot, FOV, Chams funktionieren fast überall")
InfoRow(pInfo, "Alle Roblox Games",   "Utility",       "Fly, Speed, Noclip, Infinite Jump, Anti-AFK")

Section(pInfo, "Hinweis")
do
    local note = New("Frame", {Parent=pInfo, Size=UDim2.new(1,0,0,60),
        BackgroundColor3=Color3.fromRGB(14,14,18), BorderSizePixel=0})
    New("UICorner", {Parent=note, CornerRadius=UDim.new(0,2)})
    New("UIStroke", {Parent=note, Color=Color3.fromRGB(35,35,48), Thickness=1, Transparency=0.5})
    New("TextLabel", {Parent=note, BackgroundTransparency=1,
        Position=UDim2.fromOffset(12,8), Size=UDim2.new(1,-24,1,-16),
        Font=Enum.Font.Gotham, TextSize=11,
        Text="Nicht jedes Feature funzt in jedem Game (z.B. Silent Aim nur wo Server hitreg). Farm Mode 'MM2' für Murder Mystery 2, 'Universal' für alle Money/Coin Games (Da Hood, etc).",
        TextColor3=Color3.fromRGB(180,180,195), TextXAlignment=Enum.TextXAlignment.Left,
        TextYAlignment=Enum.TextYAlignment.Top, TextWrapped=true})
end

-- SETTINGS tab
local pSet = AddTab("Settings")
Section(pSet, "Menu")
Slider(pSet, "Menu Transparency", "MenuTransparency", 0, 0.9, 0.05)
Slider(pSet, "Menu Size (x100%)", "MenuSize", 0.5, 1.5, 0.05)
Section(pSet, "Keybinds")
KeybindPicker(pSet, "Toggle Menu", "MenuKey")
KeybindPicker(pSet, "Toggle Freecam", "FreecamKey")
KeybindPicker(pSet, "Toggle Fly",     "FlyKey")

-- 4 Config Slots (Save + Load pro slot)
Section(pSet, "Config Slots")
do
    local HttpService = game:GetService("HttpService")

    local function pathFor(slot) return "kuni_private_slot_"..slot..".json" end

    local function saveSlot(slot)
        local out = {}
        for k, v in pairs(C) do
            local t = typeof(v)
            if t == "boolean" or t == "number" or t == "string" then
                out[k] = v
            elseif t == "Color3" then
                out[k] = {"Color3", math.floor(v.R*255), math.floor(v.G*255), math.floor(v.B*255)}
            elseif t == "EnumItem" then
                out[k] = {"Enum", tostring(v.EnumType):gsub("^Enum%.", ""), v.Name}
            end
        end
        if writefile then
            pcall(function() writefile(pathFor(slot), HttpService:JSONEncode(out)) end)
        end
    end

    local function loadSlot(slot)
        local ok = pcall(function()
            local raw = readfile(pathFor(slot))
            local data = HttpService:JSONDecode(raw)
            for k, v in pairs(data) do
                if type(v) == "table" and v[1] == "Color3" then
                    C[k] = Color3.fromRGB(v[2], v[3], v[4])
                elseif type(v) == "table" and v[1] == "Enum" then
                    local et = Enum[v[2]]
                    if et and et[v[3]] then C[k] = et[v[3]] end
                else
                    C[k] = v
                end
            end
        end)
        if ok then
            -- Alle Toggle-checkboxes visuell mit neuem C-state re-syncen
            if _G.ENI_TOGGLE_REFRESH then
                for _, refresh in ipairs(_G.ENI_TOGGLE_REFRESH) do
                    pcall(refresh)
                end
            end
            -- Menu Accent visuell anwenden
            pcall(function() updateMenuAccent(C.MenuAccent) end)
            -- Sky Preset visuell anwenden
            pcall(function()
                local Lighting = game:GetService("Lighting")
                local presetLookup = {
                    Day        = {14, Color3.fromRGB(70,70,70),    1e6,  2},
                    Sunset     = {18, Color3.fromRGB(120,80,60),   800,  1.5},
                    Night      = {0,  Color3.fromRGB(15,15,25),    400,  0.5},
                    Space      = {0,  Color3.fromRGB(0,0,0),       1e6,  0},
                    Fullbright = {14, Color3.fromRGB(255,255,255), 1e6,  3},
                    Reset      = {14, Color3.fromRGB(70,70,70),    1e6,  1},
                }
                local p = presetLookup[C.SkyPreset]
                if p then
                    Lighting.ClockTime  = p[1]
                    Lighting.Ambient    = p[2]
                    Lighting.FogEnd     = p[3]
                    Lighting.Brightness = p[4]
                end
            end)
        end
        return ok
    end

    -- Build 4 slot rows: [SAVE slot X] [LOAD slot X]
    for slot = 1, 4 do
        local row = New("Frame", {Parent=pSet, Size=UDim2.new(1,0,0,32),
            BackgroundTransparency=1})
        local label = New("TextLabel", {Parent=row, BackgroundTransparency=1,
            Position=UDim2.fromOffset(0,0), Size=UDim2.fromOffset(50,32),
            Font=Enum.Font.GothamBold, TextSize=12, Text="Slot "..slot,
            TextColor3=Color3.fromRGB(220,220,235), TextXAlignment=Enum.TextXAlignment.Left})

        local saveBtn = New("TextButton", {Parent=row, Size=UDim2.new(0.5,-58,1,0),
            Position=UDim2.fromOffset(56,0),
            BackgroundColor3=Color3.fromRGB(240,240,245), BorderSizePixel=0,
            Font=Enum.Font.GothamBold, TextSize=12, TextColor3=Color3.fromRGB(10,10,15),
            Text="SAVE", AutoButtonColor=false, ZIndex=3})
        New("UICorner", {Parent=saveBtn, CornerRadius=UDim.new(0,2)})
        saveBtn.MouseButton1Click:Connect(function()
            saveSlot(slot)
            saveBtn.Text = "✓ SAVED"
            task.wait(1); saveBtn.Text = "SAVE"
        end)

        local loadBtn = New("TextButton", {Parent=row, Size=UDim2.new(0.5,-4,1,0),
            Position=UDim2.new(0.5,4,0,0),
            BackgroundColor3=Color3.fromRGB(60,130,240), BorderSizePixel=0,
            Font=Enum.Font.GothamBold, TextSize=12, TextColor3=Color3.fromRGB(255,255,255),
            Text="LOAD", AutoButtonColor=false, ZIndex=3})
        New("UICorner", {Parent=loadBtn, CornerRadius=UDim.new(0,2)})
        loadBtn.MouseButton1Click:Connect(function()
            if loadSlot(slot) then
                loadBtn.Text = "✓ LOADED"
            else
                loadBtn.Text = "✕ EMPTY"
                loadBtn.BackgroundColor3 = Color3.fromRGB(230,80,110)
            end
            task.wait(1.2)
            loadBtn.Text = "LOAD"
            loadBtn.BackgroundColor3 = Color3.fromRGB(60,130,240)
        end)
    end

    Section(pSet, "Actions")

    local unloadBtn = New("TextButton", {Parent=pSet, Size=UDim2.new(1,0,0,32),
        BackgroundColor3=Color3.fromRGB(230,80,110), BorderSizePixel=0,
        Font=Enum.Font.GothamBold, TextSize=13, TextColor3=Color3.fromRGB(255,255,255),
        Text="✕  UNLOAD CHEAT", AutoButtonColor=false, ZIndex=3})
    New("UICorner", {Parent=unloadBtn, CornerRadius=UDim.new(0,2)})
    unloadBtn.MouseButton1Click:Connect(function()
        -- ALLE Feature-Toggles OFF (killt aimbot/esp/chams/silent/trigger/etc. instant)
        for k, v in pairs(C) do
            if type(v) == "boolean" then C[k] = false end
        end
        -- Restore camera + mouse + walkspeed + freecam-lock
        pcall(function()
            Camera.CameraType = Enum.CameraType.Custom
            UIS.MouseBehavior = Enum.MouseBehavior.Default
            UIS.MouseIconEnabled = true
            local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                Camera.CameraSubject = hum
                hum.WalkSpeed = 16
                hum.JumpPower = 50
            end
        end)
        pcall(function() game:GetService("ContextActionService"):UnbindAction("FreecamBlockMove") end)
        task.wait(0.1)  -- give render loops one frame to see false flags
        pcall(function() Gui:Destroy() end)
        pcall(function() ESPGui:Destroy() end)
        if Preview then pcall(function() Preview:Destroy() end) end
    end)
end
Section(pSet, "Info")
local info = New("Frame", {Parent=pSet, Size=UDim2.new(1,0,0,80),
    BackgroundColor3=Color3.fromRGB(14,14,18), BorderSizePixel=0})
New("UICorner", {Parent=info, CornerRadius=UDim.new(0,2)})
New("UIStroke", {Parent=info, Color=Color3.fromRGB(35,35,48), Thickness=1, Transparency=0.5})
New("TextLabel", {Parent=info, BackgroundTransparency=1, Size=UDim2.fromScale(1,1),
    Font=Enum.Font.Gotham, TextSize=12, TextWrapped=true,
    TextColor3=Color3.fromRGB(180,180,195),
    Text="  KUNI PRIVATE v3\n  Da Hood specialized build\n  Made with ♥ for LO",
    TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Center})

selectTab("Combat")

-- ═════════ Toggle menu with custom keybind ═════════
UIS.InputBegan:Connect(function(i, gp)
    if gp or pickingKeybind then return end
    if i.KeyCode == C.MenuKey then
        Main.Visible = not Main.Visible
    end
end)

-- ═════════ MOBILE-FRIENDLY: Floating ENI Toggle Button ═════════
-- Kleiner runder Button rechts oben. Klick/Tap = Menu open/close.
-- Draggable damit User ihn hinschieben können wo sie wollen.
do
    local ToggleBtn = New("TextButton", {
        Parent = Gui, Name = "ENI_TOGGLE",
        Size = UDim2.fromOffset(50, 50),
        Position = UDim2.new(0, 20, 0, 200),  -- links oben, unter Roblox top bar
        BackgroundColor3 = Color3.fromRGB(0, 0, 0), BorderSizePixel = 0,
        Text = "ENI", Font = Enum.Font.GothamBlack, TextSize = 14,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        AutoButtonColor = false, ZIndex = 100,
        Active = true, Draggable = false,  -- wir handlen drag manuell für touch-support
    })
    ToggleBtn:SetAttribute("BgLocked", true)  -- bleibt schwarz beim MenuAccent-change
    New("UICorner", {Parent = ToggleBtn, CornerRadius = UDim.new(1, 0)})
    local stroke = New("UIStroke", {Parent = ToggleBtn,
        Color = Color3.fromRGB(255, 255, 255), Thickness = 1.5, Transparency = 0.3})

    -- Subtle neon-glow
    local glow = New("Frame", {Parent = ToggleBtn, ZIndex = 99,
        Size = UDim2.new(1, 10, 1, 10), Position = UDim2.fromOffset(-5, -5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0,
        BackgroundTransparency = 0.85})
    New("UICorner", {Parent = glow, CornerRadius = UDim.new(1, 0)})

    -- Hover / press feedback
    ToggleBtn.MouseEnter:Connect(function()
        Tween(ToggleBtn, 0.15, {BackgroundColor3 = Color3.fromRGB(20, 20, 25)})
        Tween(stroke, 0.15, {Transparency = 0})
    end)
    ToggleBtn.MouseLeave:Connect(function()
        Tween(ToggleBtn, 0.15, {BackgroundColor3 = Color3.fromRGB(0, 0, 0)})
        Tween(stroke, 0.15, {Transparency = 0.3})
    end)

    -- Toggle-Logik: unterscheidet Klick vs Drag (damit Drag nicht toggelt)
    local dragging = false
    local moved    = false
    local dragStart, startPos
    local DRAG_THRESHOLD = 6  -- px Bewegung bevor's als drag zählt (nicht als tap)

    ToggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; moved = false
            dragStart = input.Position
            startPos  = ToggleBtn.Position
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            if math.abs(delta.X) > DRAG_THRESHOLD
            or math.abs(delta.Y) > DRAG_THRESHOLD then
                moved = true
            end
            if moved then
                ToggleBtn.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            if dragging and not moved then
                -- Wirklich ein Tap, kein Drag → Menu toggle
                Main.Visible = not Main.Visible
                -- Kleines press-feedback
                Tween(ToggleBtn, 0.08, {Size = UDim2.fromOffset(44, 44)})
                task.delay(0.08, function()
                    Tween(ToggleBtn, 0.12, {Size = UDim2.fromOffset(50, 50)})
                end)
            end
            dragging = false
            moved    = false
        end
    end)
end

-- ═════════ MOBILE AIM-TOGGLE BUTTON — nur auf touch devices ═════════
-- Wenn Aimbot in den Settings aktiviert ist erscheint dieser Button rechts.
-- Tap = Aim ON (lockt), nochmal Tap = OFF (kann wieder frei kucken).
-- Draggable damit user ihn hinschieben kann wo er möchte.
if UIS.TouchEnabled and not UIS.KeyboardEnabled then
    _G.ENI_AIM_MOBILE_ACTIVE = false

    local AimBtn = New("TextButton", {
        Parent = Gui, Name = "ENI_AIM_TOGGLE",
        Size = UDim2.fromOffset(60, 60),
        Position = UDim2.new(1, -80, 0.5, -30),  -- rechts, mittig vertikal
        BackgroundColor3 = Color3.fromRGB(0, 0, 0), BorderSizePixel = 0,
        Text = "AIM", Font = Enum.Font.GothamBlack, TextSize = 15,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        AutoButtonColor = false, ZIndex = 100,
        Active = true, Draggable = false, Visible = false,  -- nur an wenn Aimbot on
    })
    AimBtn:SetAttribute("BgLocked", true)
    New("UICorner", {Parent = AimBtn, CornerRadius = UDim.new(1, 0)})
    local aimStroke = New("UIStroke", {Parent = AimBtn,
        Color = Color3.fromRGB(255, 255, 255), Thickness = 2, Transparency = 0.3})

    -- Watchdog: zeigt/versteckt Button je nach C.AimEnabled
    task.spawn(function()
        while AimBtn.Parent do
            task.wait(0.2)
            if C.AimEnabled and not AimBtn.Visible then
                AimBtn.Visible = true
            elseif not C.AimEnabled and AimBtn.Visible then
                AimBtn.Visible = false
                _G.ENI_AIM_MOBILE_ACTIVE = false  -- reset wenn aim disabled wird
            end
        end
    end)

    -- Drag-vs-tap logic (same as ENI menu button)
    local dragging = false
    local moved    = false
    local dragStart, startPos
    local DRAG_TH  = 6

    AimBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; moved = false
            dragStart = input.Position
            startPos  = AimBtn.Position
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local d = input.Position - dragStart
            if math.abs(d.X) > DRAG_TH or math.abs(d.Y) > DRAG_TH then
                moved = true
            end
            if moved then
                AimBtn.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + d.X,
                    startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            if dragging and not moved then
                -- Tap → toggle aim
                _G.ENI_AIM_MOBILE_ACTIVE = not _G.ENI_AIM_MOBILE_ACTIVE
                if _G.ENI_AIM_MOBILE_ACTIVE then
                    -- ON: rot leuchten + press feedback
                    AimBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 45)
                    aimStroke.Color         = Color3.fromRGB(255, 80, 100)
                    aimStroke.Transparency  = 0
                    AimBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
                else
                    -- OFF: schwarz
                    AimBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    aimStroke.Color         = Color3.fromRGB(255, 255, 255)
                    aimStroke.Transparency  = 0.3
                end
                -- press-feedback bounce
                Tween(AimBtn, 0.08, {Size = UDim2.fromOffset(54, 54)})
                task.delay(0.08, function()
                    Tween(AimBtn, 0.12, {Size = UDim2.fromOffset(60, 60)})
                end)
            end
            dragging = false; moved = false
        end
    end)
end

-- ═════════ ESP PREVIEW PANEL (halbe Breite, volle Menu-Hoehe) ═════════
local Preview = New("Frame", {Parent=Gui, Size=UDim2.fromOffset(310, 550),
    Position=UDim2.new(0.5, 350, 0.5, -275), BackgroundColor3=Color3.fromRGB(22,22,28),
    BorderSizePixel=0, Visible=false})
New("UICorner", {Parent=Preview, CornerRadius=UDim.new(0,12)})
New("UIStroke", {Parent=Preview, Color=Color3.fromRGB(38,38,52), Thickness=1, Transparency=0.2})
-- Header
local pHeader = New("Frame", {Parent=Preview, Size=UDim2.new(1,0,0,32),
    BackgroundColor3=Color3.fromRGB(14,14,18), BorderSizePixel=0})
New("UICorner", {Parent=pHeader, CornerRadius=UDim.new(0,12)})
New("Frame", {Parent=pHeader, Size=UDim2.new(1,0,0,12), Position=UDim2.new(0,0,1,-12),
    BackgroundColor3=Color3.fromRGB(16,16,22), BorderSizePixel=0})
New("TextLabel", {Parent=pHeader, BackgroundTransparency=1,
    Position=UDim2.fromOffset(14,0), Size=UDim2.new(1,-14,1,0),
    Font=Enum.Font.GothamBold, TextSize=12, Text="ESP PREVIEW",
    TextColor3=Color3.fromRGB(240,240,245), TextXAlignment=Enum.TextXAlignment.Left})
-- Preview canvas
local Canvas = New("Frame", {Parent=Preview, Size=UDim2.new(1,-20,1,-42),
    Position=UDim2.fromOffset(10,38), BackgroundColor3=Color3.fromRGB(30,45,35),
    BorderSizePixel=0, ClipsDescendants=true})
New("UICorner", {Parent=Canvas, CornerRadius=UDim.new(0,8)})
-- Grid pattern background
for i=1,10 do
    New("Frame", {Parent=Canvas, Size=UDim2.new(1,0,0,1), BorderSizePixel=0,
        Position=UDim2.new(0,0,i/10,0), BackgroundColor3=Color3.fromRGB(40,55,45), BackgroundTransparency=0.3})
end

-- Bacon Character built from Frames — clean R15-style body
-- Farben: gelbe Haut, orange bacon hair, blaues Shirt, gruene Hose
local bodyColor = Color3.fromRGB(255, 230, 100)  -- yellow bacon skin
local shirtColor = Color3.fromRGB(80, 130, 200)
local pantsColor = Color3.fromRGB(70, 160, 90)

local baconParts = {}  -- store parts for chams color swap
-- Head (with bacon hair strip on top)
local head = New("Frame", {Parent=Canvas, AnchorPoint=Vector2.new(0.5,0),
    Position=UDim2.new(0.5,0,0.15,0), Size=UDim2.fromOffset(60,55),
    BackgroundColor3=bodyColor, BorderSizePixel=0})
New("UICorner", {Parent=head, CornerRadius=UDim.new(0,2)})
table.insert(baconParts, {frame=head, orig=bodyColor})
-- Face dots (eyes)
New("Frame", {Parent=head, Position=UDim2.fromOffset(14,22), Size=UDim2.fromOffset(6,8),
    BackgroundColor3=Color3.fromRGB(14,14,18), BorderSizePixel=0})
New("Frame", {Parent=head, Position=UDim2.fromOffset(40,22), Size=UDim2.fromOffset(6,8),
    BackgroundColor3=Color3.fromRGB(14,14,18), BorderSizePixel=0})
-- Smile
New("Frame", {Parent=head, Position=UDim2.fromOffset(18,40), Size=UDim2.fromOffset(24,3),
    BackgroundColor3=Color3.fromRGB(14,14,18), BorderSizePixel=0})
-- Bacon hair (orange strip on top)
local hair = New("Frame", {Parent=Canvas, AnchorPoint=Vector2.new(0.5,1),
    Position=UDim2.new(0.5,0,0.15,3), Size=UDim2.fromOffset(66,10),
    BackgroundColor3=Color3.fromRGB(255,140,50), BorderSizePixel=0})
New("UICorner", {Parent=hair, CornerRadius=UDim.new(0,4)})
table.insert(baconParts, {frame=hair, orig=Color3.fromRGB(255,140,50)})

-- Torso (blaues shirt)
local torso = New("Frame", {Parent=Canvas, AnchorPoint=Vector2.new(0.5,0),
    Position=UDim2.new(0.5,0,0.15,60), Size=UDim2.fromOffset(90,110),
    BackgroundColor3=shirtColor, BorderSizePixel=0})
New("UICorner", {Parent=torso, CornerRadius=UDim.new(0,2)})
table.insert(baconParts, {frame=torso, orig=shirtColor})

-- Arms
local armL = New("Frame", {Parent=Canvas, AnchorPoint=Vector2.new(1,0),
    Position=UDim2.new(0.5,-46,0.15,60), Size=UDim2.fromOffset(28,100),
    BackgroundColor3=bodyColor, BorderSizePixel=0})
New("UICorner", {Parent=armL, CornerRadius=UDim.new(0,4)})
table.insert(baconParts, {frame=armL, orig=bodyColor})
local armR = New("Frame", {Parent=Canvas, AnchorPoint=Vector2.new(0,0),
    Position=UDim2.new(0.5,46,0.15,60), Size=UDim2.fromOffset(28,100),
    BackgroundColor3=bodyColor, BorderSizePixel=0})
New("UICorner", {Parent=armR, CornerRadius=UDim.new(0,4)})
table.insert(baconParts, {frame=armR, orig=bodyColor})

-- Legs (gruene Hose)
local legL = New("Frame", {Parent=Canvas, AnchorPoint=Vector2.new(1,0),
    Position=UDim2.new(0.5,-2,0.15,170), Size=UDim2.fromOffset(40,100),
    BackgroundColor3=pantsColor, BorderSizePixel=0})
New("UICorner", {Parent=legL, CornerRadius=UDim.new(0,4)})
table.insert(baconParts, {frame=legL, orig=pantsColor})
local legR = New("Frame", {Parent=Canvas, AnchorPoint=Vector2.new(0,0),
    Position=UDim2.new(0.5,2,0.15,170), Size=UDim2.fromOffset(40,100),
    BackgroundColor3=pantsColor, BorderSizePixel=0})
New("UICorner", {Parent=legR, CornerRadius=UDim.new(0,4)})
table.insert(baconParts, {frame=legR, orig=pantsColor})

-- Char center ist bei ~0.5x, ~0.5y — box umschliesst body
local pBox = New("Frame", {Parent=Canvas, AnchorPoint=Vector2.new(0.5,0),
    Position=UDim2.new(0.5,0,0.15,-6), Size=UDim2.fromOffset(115,285),
    BackgroundTransparency=1, BorderSizePixel=0, ZIndex=3})
local pBoxStroke = New("UIStroke", {Parent=pBox, Thickness=2})
local pName = New("TextLabel", {Parent=Canvas, BackgroundTransparency=1,
    AnchorPoint=Vector2.new(0.5,1), Position=UDim2.new(0.5,0,0.15,-16),
    Size=UDim2.fromOffset(160,18), Font=Enum.Font.GothamBold, TextSize=13,
    Text="Builderman", TextStrokeTransparency=0, ZIndex=3})
local pDist = New("TextLabel", {Parent=Canvas, BackgroundTransparency=1,
    AnchorPoint=Vector2.new(0.5,0), Position=UDim2.new(0.5,0,0.15,285),
    Size=UDim2.fromOffset(80,16), Font=Enum.Font.Gotham, TextSize=11,
    Text="[42 m]", TextColor3=Color3.fromRGB(200,200,200),
    TextStrokeTransparency=0, ZIndex=3})
local pHpBg = New("Frame", {Parent=Canvas, BackgroundColor3=Color3.fromRGB(22,22,28),
    AnchorPoint=Vector2.new(1,0), Position=UDim2.new(0.5,-64,0.15,-6),
    Size=UDim2.fromOffset(4,285), BorderSizePixel=0, ZIndex=3})
local pHpFg = New("Frame", {Parent=pHpBg, AnchorPoint=Vector2.new(0,1),
    Position=UDim2.fromScale(0,1), Size=UDim2.new(1,0,0.7,0),
    BackgroundColor3=Color3.fromRGB(60,200,60), BorderSizePixel=0})
local pTracer = New("Frame", {Parent=Canvas, AnchorPoint=Vector2.new(0.5,1),
    Position=UDim2.new(0.5,0,1,0), Size=UDim2.fromOffset(2,180),
    BorderSizePixel=0, ZIndex=2})

-- Skeleton preview lines (hardcoded R15-like positions)
-- Each entry: {startX, startY, endX, endY} relative to canvas
local pSkelPositions = {
    {0,0,   0,55},      -- head -> torso top
    {0,55,  0,170},     -- torso spine
    {0,60,  -46,60},    -- torso -> left shoulder
    {-46,60, -46,110},  -- left arm upper
    {-46,110,-46,160},  -- left arm lower
    {0,60,  46,60},     -- torso -> right shoulder
    {46,60, 46,110},    -- right arm upper
    {46,110,46,160},    -- right arm lower
    {0,170, -20,220},   -- torso -> left hip
    {-20,220,-20,270},  -- left leg
    {0,170, 20,220},    -- torso -> right hip
    {20,220,20,270},    -- right leg
}
local pSkel = {}
for i, pos in ipairs(pSkelPositions) do
    local dx = pos[3] - pos[1]
    local dy = pos[4] - pos[2]
    local len = math.sqrt(dx*dx + dy*dy)
    local ang = math.deg(math.atan2(dx, -dy))
    local ln = New("Frame", {Parent=Canvas, BackgroundColor3=Color3.new(1,1,1),
        BorderSizePixel=0, Visible=false, AnchorPoint=Vector2.new(0.5,0),
        Position=UDim2.new(0.5,pos[1],0.15,pos[2]),
        Size=UDim2.fromOffset(2,len), Rotation=ang, ZIndex=4})
    pSkel[i] = ln
end

-- Live update preview
RunService.RenderStepped:Connect(function()
    if not Preview or not Preview.Parent or not Preview.Visible then return end
    local col = C.ESPColor
    pBox.Visible    = C.BoxESP;    pBoxStroke.Color = col
    pName.Visible   = C.NameESP;   pName.TextColor3 = col
    pDist.Visible   = C.DistanceESP
    pHpBg.Visible   = C.HealthESP
    pTracer.Visible = C.TracerESP; pTracer.BackgroundColor3 = col
    -- Chams: respect ChamsMode inkl. Rainbow
    if C.ChamsEnabled then
        local chamsCol = col
        if C.ChamsMode == "Rainbow" then
            local hue = (tick() * 0.3) % 1
            chamsCol = Color3.fromHSV(hue, 1, 1)
        end
        for _, p in ipairs(baconParts) do
            p.frame.BackgroundColor3 = chamsCol
            p.frame.BackgroundTransparency = C.ChamsFill or 0
        end
    else
        for _, p in ipairs(baconParts) do
            p.frame.BackgroundColor3 = p.orig
            p.frame.BackgroundTransparency = 0
        end
    end
    -- Skeleton
    if C.SkeletonESP then
        for _, l in ipairs(pSkel) do
            l.Visible = true
            l.BackgroundColor3 = col
        end
    else
        for _, l in ipairs(pSkel) do l.Visible = false end
    end
end)

-- Preview follows Main + tab-based show/hide
local function syncPreviewPosition()
    Preview.Position = UDim2.new(
        Main.Position.X.Scale, Main.Position.X.Offset + Main.AbsoluteSize.X + 38,
        Main.Position.Y.Scale, Main.Position.Y.Offset)
end
Main:GetPropertyChangedSignal("Position"):Connect(syncPreviewPosition)
Main:GetPropertyChangedSignal("AbsoluteSize"):Connect(syncPreviewPosition)
-- Preview hides when menu hides
Main:GetPropertyChangedSignal("Visible"):Connect(function()
    if not Main.Visible then
        Preview.Visible = false
    elseif currentTab == "Visuals" then
        Preview.Visible = true
    end
end)

local origSelectTab = selectTab
selectTab = function(name)
    origSelectTab(name)
    Preview.Visible = (name == "Visuals")
    syncPreviewPosition()
end
CloseBtn.MouseButton1Click:Connect(function() Preview:Destroy() end)

-- Apply loaded MenuAccent (from saved config)
task.spawn(function()
    task.wait(1)  -- wait for UI to fully build
    if INITIAL_MENU_ACCENT and typeof(updateMenuAccent) == "function" then
        C.MenuAccent = Color3.fromRGB(240,240,245)  -- reset to default first so walk finds elements
        updateMenuAccent(INITIAL_MENU_ACCENT)
    end
end)

-- Entrance animation
Main.Size = UDim2.fromOffset(700, 0)
Tween(Main, 0.5, {Size = UDim2.fromOffset(700, 550)}, Enum.EasingStyle.Back)

-- Menu Size via UIScale (clean, skaliert alle children automatisch)
local menuScale = Instance.new("UIScale")
menuScale.Scale = 1
menuScale.Parent = Main

-- Transparency: track original werte einmal, dann live apply
local origTrans = {}
task.spawn(function()
    task.wait(0.7)  -- wait for entrance animation + all UI setup
    for _, obj in ipairs(Main:GetDescendants()) do
        origTrans[obj] = {
            bg   = obj:IsA("GuiObject") and obj.BackgroundTransparency or nil,
            text = (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox"))
                    and obj.TextTransparency or nil,
        }
    end
    origTrans[Main] = {bg = Main.BackgroundTransparency}

    while Main.Parent do
        task.wait(0.1)
        menuScale.Scale = C.MenuSize or 1
        local t = C.MenuTransparency or 0
        for obj, orig in pairs(origTrans) do
            if obj.Parent then
                if orig.bg and orig.bg < 1 then
                    pcall(function() obj.BackgroundTransparency = math.min(1, orig.bg + t) end)
                end
                if orig.text then
                    pcall(function() obj.TextTransparency = math.min(1, orig.text + t) end)
                end
            end
        end
    end
end)

-- ═════════════════════════════════════════════════
--   FOV CIRCLE (Frame-based)
-- ═════════════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    FOVFrame.Visible = C.FOVEnabled
    FOVFrame.Size    = UDim2.fromOffset(C.FOVRadius * 2, C.FOVRadius * 2)
    FOVStroke.Color  = C.FOVColor
end)

-- ═════════════════════════════════════════════════
--   AIMBOT
-- ═════════════════════════════════════════════════
local function valid(p)
    if p == LP or not p.Character then return false end
    local h = p.Character:FindFirstChildOfClass("Humanoid")
    -- AimPart mit Fallbacks: Head → HumanoidRootPart → Torso (R6) → UpperTorso (R15)
    local part = p.Character:FindFirstChild(C.AimPart)
                or p.Character:FindFirstChild("Head")
                or p.Character:FindFirstChild("HumanoidRootPart")
                or p.Character:FindFirstChild("Torso")
                or p.Character:FindFirstChild("UpperTorso")
    if not h or h.Health <= 0 or not part then return false end
    if C.TeamCheck and p.Team ~= nil and p.Team == LP.Team then return false end
    if C.WallCheck then
        local o = Camera.CFrame.Position
        local rp = RaycastParams.new()
        rp.FilterDescendantsInstances = {LP.Character, Camera}
        rp.FilterType = Enum.RaycastFilterType.Exclude
        local hit = Workspace:Raycast(o, part.Position - o, rp)
        if hit and not hit.Instance:IsDescendantOf(p.Character) then return false end
    end
    return true
end

local function nearest()
    local best, bd = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if valid(p) then
            local part = p.Character:FindFirstChild(C.AimPart)
                      or p.Character:FindFirstChild("Head")
                      or p.Character:FindFirstChild("HumanoidRootPart")
                      or p.Character:FindFirstChild("Torso")
                      or p.Character:FindFirstChild("UpperTorso")
            local sp, on = Camera:WorldToViewportPoint(part.Position)
            if on then
                local dx = sp.X - Camera.ViewportSize.X/2
                local dy = sp.Y - Camera.ViewportSize.Y/2
                local d = math.sqrt(dx*dx+dy*dy)
                if d < C.FOVRadius and d < bd then best, bd = p, d end
            end
        end
    end
    return best
end

-- Aimbot mit STICKY-Target — behält Enemy 0.5s trotz brief-invalid state
local stickyTarget = nil
local stickyTime   = 0
RunService.RenderStepped:Connect(function()
    if not C.AimEnabled then stickyTarget = nil; return end
    local isAiming = false
    -- MOBILE-support: der floating aim button setzt _G.ENI_AIM_MOBILE_ACTIVE
    -- Wenn mobile + button active → aim ist an, egal was AimMode sagt
    if _G.ENI_AIM_MOBILE_ACTIVE then
        isAiming = true
    elseif C.AimMode == "AlwaysOn" then
        isAiming = true
    elseif C.AimMode == "RightMouse" then
        isAiming = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    elseif C.AimMode == "LeftMouse" then
        isAiming = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
    elseif C.AimMode == "KeyE" then
        isAiming = UIS:IsKeyDown(Enum.KeyCode.E)
    end
    _G.ENI_AIM_ACTIVE = isAiming  -- global flag für AutoShot
    if not isAiming then stickyTarget = nil; _G.ENI_AIM_LOCKED = nil; return end
    local t = nearest()
    -- Sticky: wenn kein neuer target aber alter ist noch alive → weiter aim
    if t then
        stickyTarget = t
        stickyTime = tick()
    elseif stickyTarget and (tick() - stickyTime) < 0.5 then
        -- 0.5s sticky window: use last known target if still alive
        if stickyTarget.Character
           and stickyTarget.Character:FindFirstChildOfClass("Humanoid")
           and stickyTarget.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
            t = stickyTarget
        else
            stickyTarget = nil; return
        end
    else
        stickyTarget = nil; return
    end
    local part = t.Character:FindFirstChild(C.AimPart)
              or t.Character:FindFirstChild("Head")
              or t.Character:FindFirstChild("HumanoidRootPart")
              or t.Character:FindFirstChild("Torso")
    if not part then return end
    _G.ENI_AIM_LOCKED = t  -- Aimbot lockt aktiv auf diesen Player → AutoShot darf feuern
    local cf = CFrame.new(Camera.CFrame.Position, part.Position)
    -- MOBILE-fix: NIE instant-snappen (fightet mit touch-camera → wildes swingen)
    -- Auch die Smoothness weicher machen auf mobile damit keine oscillation entsteht
    local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
    if isMobile then
        -- Always smooth lerp, never snap. Extra smoothness um touch-drift zu absorbieren
        local smooth = math.clamp(1 - math.max(C.AimSmoothness, 0.35), 0.05, 0.7)
        Camera.CFrame = Camera.CFrame:Lerp(cf, smooth)
    else
        -- Desktop: snap hart wenn LMB gedrueckt (für auto-guns mit recoil)
        local firing = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
        if firing then
            Camera.CFrame = cf
        else
            Camera.CFrame = Camera.CFrame:Lerp(cf, math.clamp(1 - C.AimSmoothness, 0.1, 1))
        end
    end
end)

-- ═════════ HIT SOUND — nur LMB + Camera-Raycast (nur DEINE Hits) ═════════
-- HP-change Detektor wurde entfernt weil er auch bei fremden hits gefeuert hat

-- Method 2: LMB + Camera-Raycast (nur wenn Crosshair auf Enemy = echter Hit)
local lastShotTime = 0
UIS.InputBegan:Connect(function(input, _gp)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and C.HitSound then
        if tick() - lastShotTime < 0.1 then return end
        -- GATE: nur wenn eine Waffe (Tool oder equipped Handle) da ist
        local char = LP.Character
        if not char then return end
        local hasWeapon = char:FindFirstChildWhichIsA("Tool") ~= nil
        if not hasWeapon then
            -- Fallback: check for equipped Handle (Tools mit Handle sind equipped)
            for _, c in ipairs(char:GetChildren()) do
                if c:IsA("Model") or c.Name == "Handle" or c:FindFirstChild("Handle") then
                    hasWeapon = true; break
                end
            end
        end
        if not hasWeapon then return end
        -- Raycast von Camera forward
        local origin = Camera.CFrame.Position
        local dir    = Camera.CFrame.LookVector * 500
        local rp = RaycastParams.new()
        rp.FilterDescendantsInstances = {LP.Character, Camera}
        rp.FilterType = Enum.RaycastFilterType.Exclude
        local hit = Workspace:Raycast(origin, dir, rp)
        if not hit then return end
        -- Ist das ein Player?
        local model = hit.Instance:FindFirstAncestorOfClass("Model")
        local plr   = model and Players:GetPlayerFromCharacter(model)
        if plr and plr ~= LP then
            lastShotTime = tick()
            task.spawn(playHitSound)
        end
    end
end)

-- ═════════ AUTO SHOT (nur wenn Aimbot AKTIV lockt) ═════════
local VIM_AutoShot = game:GetService("VirtualInputManager")
task.spawn(function()
    while true do
        task.wait((C.AutoShotDelay or 100) / 1000)
        if not C.AutoShot then continue end
        -- GATE: Aimbot muss aktiv sein UND auf jemanden gelockt haben
        if not C.AimEnabled then continue end
        if not _G.ENI_AIM_ACTIVE then continue end
        local target = _G.ENI_AIM_LOCKED
        if not target then continue end
        -- Target noch alive?
        local tChar = target.Character
        local tHum  = tChar and tChar:FindFirstChildOfClass("Humanoid")
        if not tHum or tHum.Health <= 0 then continue end

        -- FIRE: mehrere Wege parallel für max Kompatibilität
        -- 1) Wave-native mouse1press/release (bester Weg, umgeht Fokus-Check)
        pcall(function()
            if mouse1press then mouse1press() end
            task.wait(0.02)
            if mouse1release then mouse1release() end
        end)
        -- 2) Fallback mouse1click
        pcall(function() if mouse1click then mouse1click() end end)
        -- 3) VIM mit ECHTER Mausposition (nicht 0,0 — das blockt Roblox oft)
        pcall(function()
            local mp  = UIS:GetMouseLocation()
            local mx, my = mp.X, mp.Y
            VIM_AutoShot:SendMouseButtonEvent(mx, my, 0, true,  game, 0)
            task.wait(0.02)
            VIM_AutoShot:SendMouseButtonEvent(mx, my, 0, false, game, 0)
        end)
        -- 4) Tool activation (client + server RemoteEvent falls vorhanden)
        local tool = LP.Character and LP.Character:FindFirstChildOfClass("Tool")
        if tool then
            pcall(function() tool:Activate() end)
            -- Manche Games nutzen RemoteEvent im Tool statt Activate
            for _, remote in ipairs(tool:GetDescendants()) do
                if remote:IsA("RemoteEvent") then
                    local rn = remote.Name:lower()
                    if rn:find("shoot") or rn:find("fire") or rn:find("shot")
                    or rn:find("attack") or rn:find("swing") then
                        pcall(function()
                            local mouseHit = LP:GetMouse().Hit
                            remote:FireServer(mouseHit and mouseHit.Position or Camera.CFrame.Position)
                        end)
                    end
                end
            end
        end
    end
end)



-- ═════════════════════════════════════════════════
--   WALLHACK ESP
-- ═════════════════════════════════════════════════
local Cache = {}

-- R15 skeleton bone pairs (fallback zu R6 falls parts fehlen)
local BONES_R15 = {
    {"Head","UpperTorso"}, {"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"}, {"LeftUpperArm","LeftLowerArm"}, {"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"}, {"RightUpperArm","RightLowerArm"}, {"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"}, {"LeftUpperLeg","LeftLowerLeg"}, {"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"}, {"RightUpperLeg","RightLowerLeg"}, {"RightLowerLeg","RightFoot"},
}
local BONES_R6 = {
    {"Head","Torso"},
    {"Torso","Left Arm"}, {"Torso","Right Arm"},
    {"Torso","Left Leg"}, {"Torso","Right Leg"},
}
local BONES = BONES_R15  -- Default, wird pro character auto-detected
-- Get proper bone set for character rig type
local function getBones(char)
    if char:FindFirstChild("UpperTorso") then return BONES_R15 end
    if char:FindFirstChild("Torso")      then return BONES_R6  end
    return BONES_R15
end
-- Get screen bounds — nur sichtbare Body-Parts (skip invisible/marker parts)
local function getCharBounds(char)
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local anyOnScreen = false
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") and part.Transparency < 1 then
            local pos = part.Position
            -- 8 corners of THIS part
            local hx, hy, hz = part.Size.X/2, part.Size.Y/2, part.Size.Z/2
            for dx = -1, 1, 2 do for dy = -1, 1, 2 do for dz = -1, 1, 2 do
                local corner = pos + Vector3.new(hx*dx, hy*dy, hz*dz)
                local sp = Camera:WorldToViewportPoint(corner)
                if sp.Z > 0 then
                    anyOnScreen = true
                    if sp.X < minX then minX = sp.X end
                    if sp.Y < minY then minY = sp.Y end
                    if sp.X > maxX then maxX = sp.X end
                    if sp.Y > maxY then maxY = sp.Y end
                end
            end end end
        end
    end
    return anyOnScreen, minX, minY, maxX, maxY
end

local function makeESP(p)
    local box = New("Frame", {Parent = ESPGui, BackgroundTransparency = 1,
        BorderSizePixel = 0, Visible = false, AnchorPoint = Vector2.new(0.5, 0)})
    local boxStroke = New("UIStroke", {Parent = box, Color = C.ESPColor, Thickness = 1.5})

    local name = New("TextLabel", {Parent = ESPGui, BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = C.ESPColor, Visible = false,
        AnchorPoint = Vector2.new(0.5, 1), Size = UDim2.fromOffset(200, 16),
        TextStrokeTransparency = 0, TextStrokeColor3 = Color3.new(0,0,0)})

    local dist = New("TextLabel", {Parent = ESPGui, BackgroundTransparency = 1,
        Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Color3.fromRGB(200,200,200),
        Visible = false, AnchorPoint = Vector2.new(0.5, 0), Size = UDim2.fromOffset(120, 14),
        TextStrokeTransparency = 0, TextStrokeColor3 = Color3.new(0,0,0)})

    local hpText = New("TextLabel", {Parent = ESPGui, BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold, TextSize = 9, TextColor3 = Color3.fromRGB(60,200,60),
        Visible = false, AnchorPoint = Vector2.new(1, 0.5),
        Size = UDim2.fromOffset(30, 10),
        TextStrokeTransparency = 0, TextStrokeColor3 = Color3.new(0,0,0),
        TextXAlignment = Enum.TextXAlignment.Right})
    local hpBg = New("Frame", {Parent = ESPGui, BackgroundColor3 = Color3.fromRGB(22,22,28),
        BorderSizePixel = 0, Visible = false})
    local hpFg = New("Frame", {Parent = hpBg, BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1),
        Size = UDim2.fromScale(1, 1)})

    local tracer = New("Frame", {Parent = ESPGui, BackgroundColor3 = C.ESPColor,
        BorderSizePixel = 0, Visible = false, AnchorPoint = Vector2.new(0.5, 1),
        Size = UDim2.fromOffset(2, 200), ZIndex = 3})

    -- Skeleton lines (clean thick, joints touch via anchor)
    local skeleton = {}
    for i = 1, #BONES do
        local line = New("Frame", {Parent = ESPGui, BackgroundColor3 = C.ESPColor,
            BorderSizePixel = 0, Visible = false, AnchorPoint = Vector2.new(0.5, 0),
            Size = UDim2.fromOffset(3, 10)})
        skeleton[i] = line
    end

    -- Chams — Roblox Highlight (durch Wände sichtbar)
    local highlight = New("Highlight", {
        Parent = ESPGui, Enabled = false,
        FillColor = C.ESPColor, OutlineColor = C.ESPColor,
        FillTransparency = 0.5, OutlineTransparency = 0,
        DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
    })

    -- Tung Tung Sahur — echter Roblox Decal mit fallback zur drawn version
    local tt = New("BillboardGui", {Parent = ESPGui, Enabled = false,
        Size = UDim2.new(4, 0, 5.4, 0), StudsOffset = Vector3.new(0, 0.5, 0),
        AlwaysOnTop = true, LightInfluence = 0})
    -- Versuche echtes Tung Tung Image (mehrere IDs, fallback drawn version)
    local ttImage = New("ImageLabel", {Parent = tt, Size = UDim2.fromScale(1,1),
        BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Fit,
        Image = "rbxassetid://91587263817266"})
    -- Wenn Image nicht laedt (30% weiss/error), Fallback anzeigen
    task.spawn(function()
        task.wait(2)
        if not ttImage.IsLoaded then
            -- Try alternate IDs
            for _, id in ipairs({"rbxassetid://116614859589960","rbxassetid://89897751123107","rbxassetid://76103604944596"}) do
                ttImage.Image = id
                task.wait(1)
                if ttImage.IsLoaded then break end
            end
        end
    end)

    -- Log-Cap oben (Cross-Section vom Log)
    local cap = New("Frame", {Parent = tt, Size = UDim2.fromScale(0.5, 0.08),
        AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0.02),
        BackgroundColor3 = Color3.fromRGB(210, 160, 100), BorderSizePixel = 0})
    New("UICorner", {Parent = cap, CornerRadius = UDim.new(1, 0)})
    New("UIStroke", {Parent = cap, Color = Color3.fromRGB(80, 40, 15), Thickness = 2})
    -- Ring am Cap (inner)
    local capInner = New("Frame", {Parent = cap, Size = UDim2.fromScale(0.75, 0.6),
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(180, 130, 80), BorderSizePixel = 0})
    New("UICorner", {Parent = capInner, CornerRadius = UDim.new(1, 0)})

    -- Body (cylindrical log)
    local body = New("Frame", {Parent = tt, Size = UDim2.fromScale(0.5, 0.62),
        AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0.08),
        BackgroundColor3 = Color3.fromRGB(180, 130, 80), BorderSizePixel = 0})
    New("UICorner", {Parent = body, CornerRadius = UDim.new(0, 6)})
    New("UIStroke", {Parent = body, Color = Color3.fromRGB(80, 40, 15), Thickness = 2})
    -- Holz-Gradient für 3D Look
    New("UIGradient", {Parent = body, Rotation = 0, Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 90, 50)),
        ColorSequenceKeypoint.new(0.3, Color3.fromRGB(200, 150, 100)),
        ColorSequenceKeypoint.new(0.7, Color3.fromRGB(200, 150, 100)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 90, 50)),
    }})
    -- Wood-grain lines (5 dünne vertikale Streifen)
    for _, x in ipairs({0.15, 0.32, 0.5, 0.65, 0.83}) do
        New("Frame", {Parent = body, Size = UDim2.fromScale(0.008, 0.9),
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(x, 0.5),
            BackgroundColor3 = Color3.fromRGB(100, 60, 25),
            BackgroundTransparency = 0.4, BorderSizePixel = 0})
    end

    -- Augenbrauen (dicke kurve über den Augen)
    for _, x in ipairs({0.32, 0.68}) do
        local brow = New("Frame", {Parent = body, Size = UDim2.fromScale(0.22, 0.03),
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(x, 0.18),
            BackgroundColor3 = Color3.fromRGB(60, 30, 10), BorderSizePixel = 0,
            Rotation = (x == 0.32 and -10 or 10)})
        New("UICorner", {Parent = brow, CornerRadius = UDim.new(1, 0)})
    end

    -- Augen (weiß mit schwarzer Pupille die zur Seite guckt)
    for _, x in ipairs({0.32, 0.68}) do
        local eye = New("Frame", {Parent = body, Size = UDim2.fromScale(0.18, 0.13),
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(x, 0.28),
            BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0})
        New("UICorner", {Parent = eye, CornerRadius = UDim.new(1, 0)})
        New("UIStroke", {Parent = eye, Color = Color3.new(0,0,0), Thickness = 2})
        -- Pupille (etwas nach rechts fuer seitwaerts-Blick)
        local pup = New("Frame", {Parent = eye, AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.65, 0.55), Size = UDim2.fromScale(0.4, 0.5),
            BackgroundColor3 = Color3.fromRGB(22,22,28), BorderSizePixel = 0})
        New("UICorner", {Parent = pup, CornerRadius = UDim.new(1, 0)})
        -- weißer Highlight-Dot
        New("Frame", {Parent = pup, AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.35, 0.35), Size = UDim2.fromScale(0.3, 0.3),
            BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0})
    end

    -- Nase (kleine dunkle Bump)
    local nose = New("Frame", {Parent = body, Size = UDim2.fromScale(0.08, 0.06),
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.44),
        BackgroundColor3 = Color3.fromRGB(90, 50, 20), BorderSizePixel = 0})
    New("UICorner", {Parent = nose, CornerRadius = UDim.new(1, 0)})

    -- Smile (2 kleine curves die ein Smile andeuten)
    local smile = New("Frame", {Parent = body, Size = UDim2.fromScale(0.3, 0.03),
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.55),
        BackgroundColor3 = Color3.fromRGB(50, 20, 10), BorderSizePixel = 0})
    New("UICorner", {Parent = smile, CornerRadius = UDim.new(1, 0)})

    -- Arms (2 dünne braune Stangen an den Seiten)
    for _, x in ipairs({0.15, 0.85}) do
        local arm = New("Frame", {Parent = tt, Size = UDim2.fromScale(0.05, 0.3),
            AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(x, 0.35),
            BackgroundColor3 = Color3.fromRGB(180, 130, 80), BorderSizePixel = 0,
            Rotation = (x == 0.15 and 10 or -10)})
        New("UICorner", {Parent = arm, CornerRadius = UDim.new(1, 0)})
        New("UIStroke", {Parent = arm, Color = Color3.fromRGB(80, 40, 15), Thickness = 1.5})
    end

    -- Beine (2 dünne braune Stangen unten)
    for _, x in ipairs({0.42, 0.58}) do
        local leg = New("Frame", {Parent = tt, Size = UDim2.fromScale(0.06, 0.18),
            AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(x, 0.72),
            BackgroundColor3 = Color3.fromRGB(180, 130, 80), BorderSizePixel = 0})
        New("UICorner", {Parent = leg, CornerRadius = UDim.new(0, 3)})
        New("UIStroke", {Parent = leg, Color = Color3.fromRGB(80, 40, 15), Thickness = 1.5})
    end
    -- Feet (kleine ovals unten)
    for _, x in ipairs({0.42, 0.58}) do
        local foot = New("Frame", {Parent = tt, Size = UDim2.fromScale(0.11, 0.05),
            AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(x, 0.9),
            BackgroundColor3 = Color3.fromRGB(160, 110, 65), BorderSizePixel = 0})
        New("UICorner", {Parent = foot, CornerRadius = UDim.new(1, 0)})
        New("UIStroke", {Parent = foot, Color = Color3.fromRGB(80, 40, 15), Thickness = 1.5})
    end

    Cache[p] = {box=box, boxStroke=boxStroke, name=name, dist=dist,
        hpBg=hpBg, hpFg=hpFg, hpText=hpText, tracer=tracer, skeleton=skeleton,
        highlight=highlight, tt=tt}
end

local function killESP(p)
    local e = Cache[p]; if not e then return end
    for k, d in pairs(e) do
        if k == "skeleton" then
            for _, l in ipairs(d) do l:Destroy() end
        elseif typeof(d) == "Instance" then d:Destroy() end
    end
    Cache[p] = nil
end

for _, p in ipairs(Players:GetPlayers()) do if p ~= LP then makeESP(p) end end
Players.PlayerAdded:Connect(function(p) if p ~= LP then makeESP(p) end end)
Players.PlayerRemoving:Connect(killESP)

-- Helper: hide alle visuellen Elemente eines ESP-Eintrags
local function hideAll(e)
    e.box.Visible, e.name.Visible, e.dist.Visible = false, false, false
    e.hpBg.Visible, e.tracer.Visible = false, false
    if e.hpText then e.hpText.Visible = false end
    for _, l in ipairs(e.skeleton) do l.Visible = false end
    e.highlight.Enabled = false
    if e.tt then e.tt.Enabled = false end
end

RunService.RenderStepped:Connect(function()
    for p, e in pairs(Cache) do
        local char = p.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")
        local alive = char and hum and hum.Health > 0 and root

        if not alive then
            hideAll(e)
        else
            local color = (C.TeamCheck and p.Team == LP.Team and p.Team ~= nil) and C.ESPTeamColor or C.ESPColor

            -- Tung Tung Sahur — cover the enemy character (attached to HRP)
            if C.TongTong and root then
                e.tt.Adornee = root  -- HumanoidRootPart = character mitte
                e.tt.Enabled = true
            else
                e.tt.Enabled = false
            end

            -- Chams (Highlight mit multi-mode support)
            if C.ChamsEnabled then
                if e.highlight.Adornee ~= char then e.highlight.Adornee = char end
                local mode = C.ChamsMode
                local chamsColor = color
                if mode == "Rainbow" then
                    local hue = (tick() * 0.3) % 1
                    chamsColor = Color3.fromHSV(hue, 1, 1)
                end
                e.highlight.FillColor    = chamsColor
                e.highlight.OutlineColor = chamsColor
                if mode == "Fill" then
                    e.highlight.FillTransparency    = C.ChamsFill
                    e.highlight.OutlineTransparency = 1
                elseif mode == "Outline" then
                    e.highlight.FillTransparency    = 1
                    e.highlight.OutlineTransparency = 0
                elseif mode == "Wireframe" then
                    e.highlight.FillTransparency    = 1
                    e.highlight.OutlineTransparency = 0
                    e.highlight.OutlineColor        = Color3.new(1,1,1)  -- weisse wireframe
                else  -- "Both" oder "Rainbow"
                    e.highlight.FillTransparency    = C.ChamsFill
                    e.highlight.OutlineTransparency = 0
                end
                e.highlight.Enabled = true
            else
                e.highlight.Enabled = false
            end

            local rootPos = Camera:WorldToViewportPoint(root.Position)
            -- Max-distance check: wenn Player weiter weg als slider-limit → alles hiden
            local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            local playerDist = myRoot and (myRoot.Position - root.Position).Magnitude or 0
            local outOfRange = myRoot and not C.ESP_Unlimited and playerDist > (C.ESP_MaxDistance or 5000)
            -- WICHTIG: Z < 0 heisst Feind ist HINTER der Kamera → alles hiden
            if rootPos.Z <= 0 or outOfRange then
                e.box.Visible, e.name.Visible, e.dist.Visible = false, false, false
                e.hpBg.Visible, e.tracer.Visible = false, false
                for _, l in ipairs(e.skeleton) do l.Visible = false end
            else
                -- Echte character-bounds via GetChildren (works R6+R15+custom)
                local onScr, bMinX, bMinY, bMaxX, bMaxY = getCharBounds(char)
                local topPos, botPos, w, h, topY
                if onScr then
                    w = bMaxX - bMinX
                    h = bMaxY - bMinY
                    topY  = bMinY
                    topPos = {X = rootPos.X, Y = bMinY}
                    botPos = {X = rootPos.X, Y = bMaxY}
                else
                    topPos = Camera:WorldToViewportPoint((head or root).Position + Vector3.new(0,0.5,0))
                    botPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0))
                    h = math.abs(botPos.Y - topPos.Y)
                    w = h * 0.55
                    topY = topPos.Y
                end

                -- Box (mit echten bounds)
                if C.BoxESP then
                    e.box.Position    = UDim2.fromOffset(rootPos.X, topY)
                    e.box.Size        = UDim2.fromOffset(w, h)
                    e.boxStroke.Color = color
                    e.box.Visible     = true
                else e.box.Visible = false end

                -- Name
                if C.NameESP and head then
                    local hp = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,1.4,0))
                    e.name.Position   = UDim2.fromOffset(hp.X, hp.Y)
                    e.name.Text       = p.DisplayName
                    e.name.TextColor3 = color
                    e.name.Visible    = true
                else e.name.Visible = false end

                -- Distance
                if C.DistanceESP and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                    local d = (LP.Character.HumanoidRootPart.Position - root.Position).Magnitude
                    e.dist.Position = UDim2.fromOffset(rootPos.X, botPos.Y + 2)
                    e.dist.Text     = "[" .. math.floor(d) .. " m]"
                    e.dist.Visible  = true
                else e.dist.Visible = false end

                -- Health bar
                if C.HealthESP then
                    local pct = math.clamp(hum.Health / math.max(hum.MaxHealth,1), 0, 1)
                    e.hpBg.Position = UDim2.fromOffset(rootPos.X - w/2 - 6, topPos.Y)
                    e.hpBg.Size     = UDim2.fromOffset(3, h)
                    e.hpBg.Visible  = true
                    e.hpFg.Size     = UDim2.new(1, 0, pct, 0)
                    e.hpFg.BackgroundColor3 = Color3.fromRGB(math.floor(255*(1-pct)), math.floor(255*pct), 60)
                else e.hpBg.Visible = false end
                -- HP Text (Zahl)
                if C.HealthTextESP then
                    local pct = math.clamp(hum.Health / math.max(hum.MaxHealth,1), 0, 1)
                    e.hpText.Position  = UDim2.fromOffset(rootPos.X - w/2 - 12, topPos.Y + h/2)
                    e.hpText.Text      = tostring(math.floor(hum.Health))
                    e.hpText.TextColor3= Color3.fromRGB(math.floor(255*(1-pct)), math.floor(255*pct), 60)
                    e.hpText.Visible   = true
                else e.hpText.Visible = false end

                -- Tracer — origin selectable Bottom/Top/Center
                local vpX, vpY = Camera.ViewportSize.X, Camera.ViewportSize.Y
                local onScreen = rootPos.X > 0 and rootPos.X < vpX
                             and rootPos.Y > 0 and rootPos.Y < vpY
                -- Tracer — midpoint-based (center anchor), 100% accurate
                local endPos = head and Camera:WorldToViewportPoint(head.Position)
                local headOn = endPos and endPos.Z > 0
                             and endPos.X > 0 and endPos.X < vpX
                             and endPos.Y > 0 and endPos.Y < vpY
                local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                local dist = myRoot and (myRoot.Position - root.Position).Magnitude or 0
                if C.TracerESP and headOn and dist < 800 then
                    -- Origin
                    local ox, oy = vpX/2, vpY  -- default Bottom
                    if C.TracerOrigin == "Top"    then oy = 0    end
                    if C.TracerOrigin == "Center" then oy = vpY/2 end
                    -- Endpoint (Enemy Head auf'm Screen)
                    local tx, ty = endPos.X, endPos.Y
                    -- Midpoint + length + angle
                    local dx, dy = tx - ox, ty - oy
                    local len = math.sqrt(dx*dx + dy*dy)
                    local midX, midY = (ox + tx) / 2, (oy + ty) / 2
                    local ang = math.deg(math.atan2(dx, -dy))
                    -- Center-anchor draw
                    e.tracer.AnchorPoint    = Vector2.new(0.5, 0.5)
                    e.tracer.Position       = UDim2.fromOffset(midX, midY)
                    e.tracer.Size           = UDim2.fromOffset(1, len)
                    e.tracer.Rotation       = ang
                    e.tracer.BackgroundColor3       = C.TracerColor
                    e.tracer.BackgroundTransparency = 0.15
                    e.tracer.Visible        = true
                else e.tracer.Visible = false end

                -- Skeleton (auto-detect R6/R15)
                if C.SkeletonESP then
                    local bones = getBones(char)
                    for i, pair in ipairs(bones) do
                        local a = char:FindFirstChild(pair[1])
                        local b = char:FindFirstChild(pair[2])
                        local line = e.skeleton[i]
                        if a and b then
                            local ap = Camera:WorldToViewportPoint(a.Position)
                            local bp = Camera:WorldToViewportPoint(b.Position)
                            if ap.Z > 0 and bp.Z > 0 then
                                local dx, dy = bp.X - ap.X, bp.Y - ap.Y
                                local len = math.sqrt(dx*dx + dy*dy)
                                -- MIDPOINT-ANCHOR: Line-Center exact zwischen A und B, um
                                -- Center rotiert → beide Endpoints landen exact auf A und B
                                local midX = (ap.X + bp.X) * 0.5
                                local midY = (ap.Y + bp.Y) * 0.5
                                local ang  = math.deg(math.atan2(dx, dy))
                                line.AnchorPoint      = Vector2.new(0.5, 0.5)
                                line.Position         = UDim2.fromOffset(midX, midY)
                                line.Size             = UDim2.fromOffset(2, len)
                                line.Rotation         = ang
                                line.BackgroundColor3 = color
                                line.Visible          = true
                            else line.Visible = false end
                        else line.Visible = false end
                    end
                else
                    for _, l in ipairs(e.skeleton) do l.Visible = false end
                end
            end
        end
    end
end)

-- ═════════════════════════════════════════════════
--   MOVEMENT: Anti-Cheat-Safe (Infected Lands modus)
--   - Micro-boost mit natural-looking jitter
--   - Auto-pause frames damit sich nicht "roboterhaft" bewegt
--   - Speed cap um detection threshold zu vermeiden
--   Wrapped in do-end um local-register-limit zu schonen (Lua max 200 locals per function)
-- ═════════════════════════════════════════════════
do
local SAFE_SPEED_CAP = 22  -- max extra über normal (16+22 = 38 total, unter meisten thresholds)
local ac_frameCounter = 0
local ac_pauseUntil   = 0

RunService.Heartbeat:Connect(function(dt)
    if not C.SpeedEnabled then return end
    local char = LP.Character
    if not char then return end
    local hum  = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root or hum.Health <= 0 then return end
    if hum.MoveDirection.Magnitude <= 0 then return end

    -- Cap safety
    local extra = math.min(C.SpeedValue - 16, SAFE_SPEED_CAP)
    if extra <= 0 then return end

    -- Random pause windows (jede ~30-60 frames, 3-8 frames pause) → looks like natural sprint-breaks
    ac_frameCounter = ac_frameCounter + 1
    if tick() < ac_pauseUntil then return end
    if ac_frameCounter > math.random(45, 90) then
        ac_frameCounter = 0
        ac_pauseUntil = tick() + math.random(3, 8) * dt
        return
    end

    -- Micro-jitter: variiere den extra-value leicht pro frame (±10%)
    local jitter = extra * (0.9 + math.random() * 0.2)
    root.CFrame = root.CFrame + hum.MoveDirection * jitter * dt
end)
end  -- ende do-block (safe_speed_cap etc. sind jetzt frei)

-- ═════════ ANTI-CHEAT HOOK ATTEMPTS ═════════
-- Suche nach bekannten check-functions und hooke sie
task.spawn(function()
    task.wait(2)  -- warte bis alle game-scripts geladen
    if not hookfunction then return end

    -- Common check: Humanoid.WalkSpeed observer
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function()
            local oldSetProp = hookfunction(hum.SetAttribute, function(self, attr, val)
                if attr and tostring(attr):lower():find("speed") then return end
                return oldSetProp(self, attr, val)
            end)
        end)
    end

    -- Search + neutralize player Kick calls (blockt banns durch script-detection)
    pcall(function()
        local oldKick = hookfunction(LP.Kick, function(self, msg)
            warn("[ENI ANTI-CHEAT] Kick attempt blocked: " .. tostring(msg))
            return
        end)
    end)

    -- Anti-teleport-back DISABLED — hat user-initiated teleports (zu player etc.) auch reverted
end)

-- Jump boost via StateChanged (bypasses JumpPower reset)
local function hookCharacter(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if not hum then return end
    hum.StateChanged:Connect(function(_, new)
        if C.JumpBoost and new == Enum.HumanoidStateType.Jumping then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                root.AssemblyLinearVelocity = Vector3.new(
                    root.AssemblyLinearVelocity.X,
                    C.JumpValue,
                    root.AssemblyLinearVelocity.Z
                )
            end
        end
    end)
end
if LP.Character then hookCharacter(LP.Character) end
LP.CharacterAdded:Connect(hookCharacter)

-- ═════════ FLY (Character selbst fliegt via BodyVelocity + BodyGyro) ═════════
local flyBV, flyBG
local function startFly()
    local char = LP.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if flyBV then flyBV:Destroy() end
    if flyBG then flyBG:Destroy() end
    flyBV = Instance.new("BodyVelocity", root)
    flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    flyBV.Velocity = Vector3.new(0,0,0)
    flyBG = Instance.new("BodyGyro", root)
    flyBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    flyBG.P = 1e4
    flyBG.CFrame = Camera.CFrame
end
local function stopFly()
    if flyBV then flyBV:Destroy(); flyBV = nil end
    if flyBG then flyBG:Destroy(); flyBG = nil end
end

RunService.RenderStepped:Connect(function()
    -- FLY HARD-DISABLED in AC-test version (triggert Infected Lands anti-cheat)
    C.FlyEnabled = false
    if flyBV then stopFly() end
    if true then return end
    if not flyBV then startFly() end
    if not flyBV then return end
    local dir = Vector3.new(0,0,0)
    if UIS:IsKeyDown(Enum.KeyCode.W)           then dir = dir + Camera.CFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.S)           then dir = dir - Camera.CFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.A)           then dir = dir - Camera.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.D)           then dir = dir + Camera.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.Space)       then dir = dir + Vector3.new(0,1,0) end
    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0,1,0) end
    flyBV.Velocity = (dir.Magnitude > 0) and (dir.Unit * C.FlySpeed) or Vector3.new(0,0,0)
    flyBG.CFrame = Camera.CFrame
end)

-- Clean up bei respawn
LP.CharacterAdded:Connect(function() stopFly() end)

-- Infinite Jump — direct Space detection (JumpRequest debouncet in Air)
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if C.InfJump and input.KeyCode == Enum.KeyCode.Space then
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)
-- Bonus: hold Space auch continuously spam-jump
task.spawn(function()
    while true do
        task.wait(0.15)
        if C.InfJump and UIS:IsKeyDown(Enum.KeyCode.Space) then
            local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

-- ═════════════════════════════════════════════════
--   RAPID FIRE
--   Spammt Left-Click solange LMB gedrückt & Tool equipped
-- ═════════════════════════════════════════════════
local mouseButtonHeld = false
UIS.InputBegan:Connect(function(i,gp) if not gp and i.UserInputType==Enum.UserInputType.MouseButton1 then mouseButtonHeld=true end end)
UIS.InputEnded:Connect(function(i)   if i.UserInputType==Enum.UserInputType.MouseButton1 then mouseButtonHeld=false end end)

local VIM = game:GetService("VirtualInputManager")

task.spawn(function()
    while true do
        task.wait(C.FireRate / 1000)
        if C.RapidFire and mouseButtonHeld then
            local char = LP.Character
            local tool = char and char:FindFirstChildOfClass("Tool")
            if tool then
                pcall(function() if mouse1click then mouse1click() end end)
                pcall(function()
                    VIM:SendMouseButtonEvent(0, 0, 0, true,  game, 0)
                    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                end)
                pcall(function() tool:Activate() end)
            end
        end
    end
end)

-- ═════════════════════════════════════════════════
--   MISC: Hitbox / Anti-AFK
-- ═════════════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    -- Hitbox Expander HARD-DISABLED (triggerte insta-ban in Infected Lands)
    C.HitboxExpander = false
    if true then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Size         = Vector3.new(C.HitboxSize, C.HitboxSize, C.HitboxSize)
                hrp.Transparency = 0.7
                hrp.CanCollide   = false
                hrp.Massless     = true
            end
        end
    end
end)

LP.Idled:Connect(function()
    if not C.AntiAFK then return end
    VirtualUser:Button2Down(Vector2.new(0,0), Camera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), Camera.CFrame)
end)

-- ═════════ ITEM ESP + VEHICLE ESP (Workspace scan) ═════════
local itemCache = {}
local function makeItemLabel()
    local bb = New("BillboardGui", {Parent = ESPGui, Size = UDim2.fromOffset(120, 32),
        AlwaysOnTop = true, LightInfluence = 0, Enabled = false})
    local dot = New("Frame", {Parent = bb, Size = UDim2.fromOffset(6,6),
        AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.fromScale(0.5,0.5),
        BackgroundColor3 = Color3.fromRGB(255,220,80), BorderSizePixel = 0})
    New("UICorner", {Parent = dot, CornerRadius = UDim.new(1,0)})
    local lbl = New("TextLabel", {Parent = bb, BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5,1), Position = UDim2.fromScale(0.5,0.4),
        Size = UDim2.fromOffset(120,16), Font = Enum.Font.GothamBold, TextSize = 11,
        Text = "", TextColor3 = Color3.fromRGB(255,220,80),
        TextStrokeTransparency = 0})
    local dist = New("TextLabel", {Parent = bb, BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5,0), Position = UDim2.fromScale(0.5,0.6),
        Size = UDim2.fromOffset(120,14), Font = Enum.Font.Gotham, TextSize = 10,
        Text = "", TextColor3 = Color3.fromRGB(200,200,205),
        TextStrokeTransparency = 0})
    return {bb=bb, dot=dot, lbl=lbl, dist=dist}
end

-- Erkenne GUID/hash-artige namen und mach sie lesbar
local function cleanName(rawName, obj)
    if not rawName or rawName == "" then return "Item" end
    local n = rawName
    -- GUID-pattern: 8-4-4-4-12 hex, oder generell viele hyphens
    local hyphens = 0
    for _ in n:gmatch("-") do hyphens = hyphens + 1 end
    -- Wenn > 2 hyphens ODER > 20 zeichen ohne leerzeichen → wahrscheinlich hash
    if hyphens >= 2 or (#n > 20 and not n:find(" ")) then
        -- Versuche was besseres: ClassName oder parent name
        if obj:IsA("Tool") then return "Weapon" end
        if obj:IsA("Model") then
            local lc = rawName:lower()
            if lc:find("money") or lc:find("cash") or lc:find("dollar") then return "$ Money" end
            if lc:find("coin") or lc:find("gold")  then return "Coin" end
            if lc:find("gun")  or lc:find("rifle") or lc:find("pistol") then return "Gun" end
            if lc:find("knife") then return "Knife" end
            if lc:find("ammo") or lc:find("bullet") then return "Ammo" end
            if lc:find("food") or lc:find("meat") or lc:find("bread") then return "Food" end
            if lc:find("med")  or lc:find("heal") or lc:find("bandage") then return "Med" end
            return "Item"
        end
        return "Item"
    end
    -- Kürze extrem lange normale namen
    if #n > 24 then n = n:sub(1, 22) .. ".." end
    return n
end

-- BLACKLIST — vermeidet false positives (tree, rig, truck, environment stuff)
local ITEM_BLACKLIST = {
    "tree", "rig", "truck", "car", "vehicle", "leaf", "leaves", "grass",
    "rock", "stone", "mountain", "hill", "wall", "floor", "roof", "door",
    "window", "fence", "sign", "light", "lamp", "pole", "wire", "cable",
    "medium", "small", "large", "big", "tiny", "spawn", "origin",
    "handle", "hitbox", "collider", "invisible", "part", "base",
    "playerrig", "characterrig", "npcrig",
}
local function isBlacklisted(n)
    for _, bad in ipairs(ITEM_BLACKLIST) do
        if n:find(bad) then return true end
    end
    return false
end

-- Kategorie-check: kehrt category zurück oder nil
local function matchCategory(n)
    -- BOOKSHELF first — spezifischer als "shelf" allein
    if n:find("bookshelf") or n:find("bücherregal") or n:find("buecherregal")
    or n:find("library") or n:find("book_shelf") or n:find("bookrack") then
        return "Bookshelf", "bookshelf"
    end
    -- SHELF / RACK — allgemeine regale
    if n:find("^shelf") or n:find("_shelf") or n:find("^regal") or n:find("_regal")
    or n:find("^rack") or n:find("_rack") or n:find("wallrack") or n:find("wall_rack") then
        return "Shelf", "shelf"
    end
    -- CHEST (priority — damit "weapon_chest" oder "gun_locker" nicht als weapon matched)
    if n:find("chest") or n:find("kiste") or n:find("crate") or n:find("locker")
    or n:find("container") or n:find("storage") or n:find("stash") or n:find("safe") then
        return "Chest", "chest"
    end
    if n:find("ammo") or n:find("_mag") or n:find("magazine") or n:find("bullet") or n:find("clip") then
        return "Ammo", "ammo"
    end
    -- Food: strenge matches, keine subtring wie "water" (matched viel zu breit)
    if n:find("^food") or n:find("_food") or n:find("meatpickup") or n:find("^bread")
    or n:find("apple_pickup") or n:find("cannedfood") or n:find("canned_food")
    or n:find("waterbottle") or n:find("^water_bottle") or n:find("mre") then
        return "Food", "food"
    end
end

-- Check ob object in player/character/body ist (equipped, NICHT pickup)
local function isInPlayer(obj)
    local p = obj.Parent
    while p do
        if p:IsA("Backpack") then return true end
        if p:IsA("Model") and Players:GetPlayerFromCharacter(p) then return true end
        if p:IsA("Model") and p:FindFirstChildOfClass("Humanoid") then return true end
        -- Auch dead body models (ragdolls, corpses) — die haben oft kein Humanoid mehr
        if p:IsA("Model") then
            local pn = p.Name:lower()
            if pn:find("body") or pn:find("dead") or pn:find("corpse") or pn:find("ragdoll")
            or pn:find("zombie") or pn:find("npc") or pn:find("player") then
                return true
            end
            -- Model mit head/torso = ist ein character body
            if p:FindFirstChild("Head") or p:FindFirstChild("HumanoidRootPart")
            or p:FindFirstChild("UpperTorso") or p:FindFirstChild("Torso") then
                return true
            end
        end
        p = p.Parent
    end
    return false
end

local function isPickupItem(obj)
    -- Tools: nur show wenn NICHT in player/character/npc (sonst body-tagging bug)
    if obj:IsA("Tool") then
        if isInPlayer(obj) then return end
        local n = obj.Name:lower()
        if isBlacklisted(n) then return end
        local h = obj:FindFirstChild("Handle")
        if h then return cleanName(obj.Name, obj), h end
        return
    end
    -- Models: check category + sub-toggle
    if not obj:IsA("Model") then return end
    -- Skip player character models
    if Players:GetPlayerFromCharacter(obj) then return end
    if obj:FindFirstChildOfClass("Humanoid") then return end  -- NPC body
    local n = obj.Name:lower()
    if isBlacklisted(n) then return end
    local label, cat = matchCategory(n)
    if not label then return end
    -- Sub-toggle check
    if cat == "ammo"     and not C.ItemESP_Ammo     then return end
    if cat == "food"     and not C.ItemESP_Food     then return end
    if cat == "chest"     and not C.ItemESP_Chest     then return end
    if cat == "bookshelf" and not C.ItemESP_Bookshelf then return end
    if cat == "shelf"     and not C.ItemESP_Shelf     then return end
    local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
    if part then return label, part end
end
local function isVehicle(obj)
    if not obj:IsA("Model") then return end
    local seat = obj:FindFirstChildWhichIsA("VehicleSeat", true)
    if seat then return obj.Name, seat end
end

task.spawn(function()
    while task.wait(2) do  -- FIX: scan alle 2s statt 0.5s (kein lag-spike mehr)
        if C.ItemESP or C.VehicleESP then
            local myPos = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                          and LP.Character.HumanoidRootPart.Position or Vector3.new()
            local seen = {}
            local descendants = Workspace:GetDescendants()
            -- Batch-processing: yield alle 500 objects damit's die frame nicht freezet
            for i, obj in ipairs(descendants) do
                if i % 500 == 0 then task.wait() end  -- gib der engine luft
                local name, part, isVeh
                if C.ItemESP then name, part = isPickupItem(obj) end
                if not name and C.VehicleESP then
                    name, part = isVehicle(obj); isVeh = part ~= nil
                end
                if name and part then
                    -- User-adjustable distance filter
                    local d = (myPos - part.Position).Magnitude
                    if d > (C.ItemESP_MaxDistance or 500) then continue end
                    seen[obj] = true
                    local ent = itemCache[obj] or makeItemLabel()
                    itemCache[obj] = ent
                    ent.bb.Adornee = part
                    ent.bb.Enabled = true
                    if isVeh then
                        ent.lbl.Text = name
                        ent.dot.BackgroundColor3 = Color3.fromRGB(80,180,255)
                        ent.lbl.TextColor3 = Color3.fromRGB(80,180,255)
                        ent.dist.Text = "[" .. (part.Occupant and "OCCUPIED" or "EMPTY") .. "] "
                                      .. math.floor((myPos - part.Position).Magnitude) .. "m"
                    else
                        ent.lbl.Text = name
                        ent.dot.BackgroundColor3 = Color3.fromRGB(255,220,80)
                        ent.lbl.TextColor3 = Color3.fromRGB(255,220,80)
                        ent.dist.Text = "[" .. math.floor((myPos - part.Position).Magnitude) .. "m]"
                    end
                end
            end
            -- cleanup vergangene
            for obj, ent in pairs(itemCache) do
                if not seen[obj] or not obj.Parent then
                    ent.bb:Destroy()
                    itemCache[obj] = nil
                end
            end
        else
            for obj, ent in pairs(itemCache) do ent.bb.Enabled = false end
        end
    end
end)

-- ═════════ CHAMS MATERIAL (client-side visual on enemy parts) ═════════
local matEnum = {
    Normal     = Enum.Material.Plastic,
    Neon       = Enum.Material.Neon,
    Glass      = Enum.Material.Glass,
    ForceField = Enum.Material.ForceField,
    Wood       = Enum.Material.WoodPlanks,
    Plastic    = Enum.Material.SmoothPlastic,
}
task.spawn(function()
    while task.wait(0.3) do
        if C.ChamsMaterial and C.ChamsMaterial ~= "Normal" then
            local mat = matEnum[C.ChamsMaterial] or Enum.Material.Plastic
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    for _, part in ipairs(p.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.Material ~= mat then
                            pcall(function() part.Material = mat end)
                        end
                    end
                end
            end
        end
    end
end)

-- ═════════ BULLET TRACERS (universal - LMB + Camera raycast) ═════════
local function drawBulletBeam(from, to)
    task.spawn(function()
        local dist = (from - to).Magnitude
        if dist < 0.5 then return end
        local mid = (from + to) / 2
        local beam = Instance.new("Part")
        beam.Anchored = true; beam.CanCollide = false; beam.CanQuery = false; beam.Massless = true
        beam.Size = Vector3.new(0.15, 0.15, dist)
        beam.CFrame = CFrame.new(mid, to)
        beam.Material = Enum.Material.Neon
        beam.Color = C.BulletColor
        beam.Transparency = 0
        beam.Parent = Workspace
        for i = 1, 25 do
            beam.Transparency = i / 25
            beam.Color = C.BulletColor
            task.wait(0.02)
        end
        beam:Destroy()
    end)
end

-- Method 1: Da Hood ShootGun hook
if hookmetamethod and getnamecallmethod and checkcaller then
    local oldNCBullet
    oldNCBullet = hookmetamethod(game, "__namecall", function(self, ...)
        if not checkcaller() and C.BulletTracers
           and getnamecallmethod() == "FireServer"
           and self.Name == "MainEvent" then
            local args = {...}
            if args[1] == "ShootGun" and typeof(args[3])=="Vector3" and typeof(args[4])=="Vector3" then
                drawBulletBeam(args[3], args[4])
            end
        end
        return oldNCBullet(self, ...)
    end)
end

-- Method 2: LMB Camera-Raycast (universal fallback)
local lastBulletTime = 0
UIS.InputBegan:Connect(function(input, _gp)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and C.BulletTracers then
        if tick() - lastBulletTime < 0.08 then return end
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        -- GATE: nur wenn eine Waffe (Tool oder equipped Handle) da ist
        local hasWeapon = char:FindFirstChildWhichIsA("Tool") ~= nil
        if not hasWeapon then
            for _, c in ipairs(char:GetChildren()) do
                if c:IsA("Model") or c.Name == "Handle" or c:FindFirstChild("Handle") then
                    hasWeapon = true; break
                end
            end
        end
        if not hasWeapon then return end
        lastBulletTime = tick()
        -- Ray from camera
        local origin = Camera.CFrame.Position
        local dir = Camera.CFrame.LookVector * 500
        local rp = RaycastParams.new()
        rp.FilterDescendantsInstances = {char, Camera}
        rp.FilterType = Enum.RaycastFilterType.Exclude
        local hit = Workspace:Raycast(origin, dir, rp)
        local endPoint = hit and hit.Position or (origin + dir)
        -- Beam from character position to hit
        drawBulletBeam(hrp.Position, endPoint)
    end
end)

-- ═════════ NO FALL DAMAGE v3 — HealthChanged hook + Teleport + Anchor ═════════
local nfdPreHP = nil
local nfdWasInAir = false
local nfdRecentAir = 0  -- timestamp of last time we were in air

local function setupNFD(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if not hum then return end
    -- SOFORTIGER HealthChanged hook - restored jeden Damage waehrend/nach Fall
    hum.HealthChanged:Connect(function(newHP)
        if not C.NoFallDamage then return end
        if nfdPreHP and newHP < nfdPreHP then
            -- Wenn wir in air waren oder innerhalb der letzten 500ms → restore
            if nfdWasInAir or (tick() - nfdRecentAir) < 0.5 then
                pcall(function() hum.Health = nfdPreHP end)
            end
        end
    end)
end
if LP.Character then setupNFD(LP.Character) end
LP.CharacterAdded:Connect(setupNFD)

RunService.Heartbeat:Connect(function()
    if not C.NoFallDamage then nfdWasInAir = false; return end
    local char = LP.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not root or hum.Health <= 0 then return end

    local yVel = root.AssemblyLinearVelocity.Y
    local isInAir = yVel < -3 or yVel > 3
                 or hum:GetState() == Enum.HumanoidStateType.Freefall

    if isInAir then nfdRecentAir = tick() end

    if isInAir and not nfdWasInAir then
        nfdPreHP = hum.Health  -- HP am Start des Falls
    end

    -- TELEPORT-Trick: bei extremem Fall, halte Y-Position hoch (kein Fall über 20 studs auf einmal)
    if yVel < -50 then
        local rp = RaycastParams.new()
        rp.FilterDescendantsInstances = {char}
        rp.FilterType = Enum.RaycastFilterType.Exclude
        local hit = Workspace:Raycast(root.Position, Vector3.new(0, -1000, 0), rp)
        if hit then
            local heightAboveGround = root.Position.Y - hit.Position.Y
            if heightAboveGround > 20 then
                -- Teleport character down to just 15 studs above ground + reset velocity
                root.CFrame = CFrame.new(root.Position.X, hit.Position.Y + 15, root.Position.Z)
                            * (root.CFrame - root.CFrame.Position)
                root.AssemblyLinearVelocity = Vector3.new(
                    root.AssemblyLinearVelocity.X, -20, root.AssemblyLinearVelocity.Z)
            end
        end
    end

    -- Anchor kurz vor Landung
    if yVel < -20 then
        local rp = RaycastParams.new()
        rp.FilterDescendantsInstances = {char}
        rp.FilterType = Enum.RaycastFilterType.Exclude
        local hit = Workspace:Raycast(root.Position, Vector3.new(0, -6, 0), rp)
        if hit then
            root.AssemblyLinearVelocity = Vector3.new(
                root.AssemblyLinearVelocity.X, 0, root.AssemblyLinearVelocity.Z)
            root.Anchored = true
            task.delay(0.12, function()
                if root and root.Parent then root.Anchored = false end
            end)
        end
    end

    if not isInAir then nfdPreHP = nil end
    nfdWasInAir = isInAir
end)

-- Noclip — jede Frame CanCollide=false auf alle Character-Parts
RunService.Stepped:Connect(function()
    if not C.Noclip then return end
    local char = LP.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            part.CanCollide = false
        end
    end
end)

-- ═════════ FREECAM v2 (mit MouseBehavior + proper restore + Keybind) ═════════
local freecamCF, freecamYaw, freecamPitch
local prevCamType, prevMouseBehav, prevMouseIcon

local CAS = game:GetService("ContextActionService")

-- Enter Freecam mode: save originals + block character movement
local function enterFreecam()
    freecamCF    = Camera.CFrame
    local look = Camera.CFrame.LookVector
    freecamYaw   = math.atan2(-look.X, -look.Z)
    freecamPitch = math.asin(math.clamp(look.Y, -1, 1))
    prevCamType    = Camera.CameraType
    prevMouseBehav = UIS.MouseBehavior
    prevMouseIcon  = UIS.MouseIconEnabled
    Camera.CameraType    = Enum.CameraType.Scriptable
    UIS.MouseBehavior    = Enum.MouseBehavior.LockCenter
    UIS.MouseIconEnabled = false
    -- Block character WASD + Jump so nur die Camera reagiert
    CAS:BindActionAtPriority("FreecamBlockMove",
        function() return Enum.ContextActionResult.Sink end, false,
        Enum.ContextActionPriority.High.Value,
        Enum.PlayerActions.CharacterForward,
        Enum.PlayerActions.CharacterBackward,
        Enum.PlayerActions.CharacterLeft,
        Enum.PlayerActions.CharacterRight,
        Enum.PlayerActions.CharacterJump)
end

-- Exit Freecam: fully restore
local function exitFreecam()
    freecamCF, freecamYaw, freecamPitch = nil, nil, nil
    -- Character-Movement wieder erlauben
    pcall(function() CAS:UnbindAction("FreecamBlockMove") end)
    local char = LP.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    -- FORCE Custom camera + character subject (nie auf Scriptable belassen)
    pcall(function()
        Camera.CameraType    = Enum.CameraType.Custom
        if hum then Camera.CameraSubject = hum end
        UIS.MouseBehavior    = Enum.MouseBehavior.Default
        UIS.MouseIconEnabled = true
    end)
end

-- Global Keybind listener (Freecam + Fly) — skip wenn Unknown = kein bind
UIS.InputBegan:Connect(function(input, _gp)
    if pickingKeybind then return end
    if input.KeyCode == Enum.KeyCode.Unknown then return end
    if input.KeyCode == C.FreecamKey and C.FreecamKey ~= Enum.KeyCode.Unknown then
        C.Freecam = not C.Freecam
    elseif input.KeyCode == C.FlyKey and C.FlyKey ~= Enum.KeyCode.Unknown then
        C.FlyEnabled = not C.FlyEnabled
    end
end)

-- Main freecam update loop (mouse delta via GetMouseDelta - universal)
RunService.RenderStepped:Connect(function(dt)
    if C.Freecam then
        if not freecamCF then enterFreecam() end
        -- Camera + Mouse enforce falls game sie zurueckreisst
        if Camera.CameraType ~= Enum.CameraType.Scriptable then
            Camera.CameraType = Enum.CameraType.Scriptable
        end
        if UIS.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
            UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
        end
        -- Raw mouse delta (bypasses InputChanged handling)
        local delta = UIS:GetMouseDelta()
        if delta.X ~= 0 or delta.Y ~= 0 then
            freecamYaw   = freecamYaw - delta.X * 0.005
            freecamPitch = math.clamp(freecamPitch - delta.Y * 0.005,
                                       -math.pi/2 + 0.05, math.pi/2 - 0.05)
        end
        -- Movement
        local mv = Vector3.new(0,0,0)
        if UIS:IsKeyDown(Enum.KeyCode.W)           then mv = mv + Vector3.new(0,0,-1) end
        if UIS:IsKeyDown(Enum.KeyCode.S)           then mv = mv + Vector3.new(0,0, 1) end
        if UIS:IsKeyDown(Enum.KeyCode.A)           then mv = mv + Vector3.new(-1,0,0) end
        if UIS:IsKeyDown(Enum.KeyCode.D)           then mv = mv + Vector3.new( 1,0,0) end
        if UIS:IsKeyDown(Enum.KeyCode.E)           then mv = mv + Vector3.new(0, 1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.Q)           then mv = mv + Vector3.new(0,-1,0) end
        local speed = C.FreecamSpeed
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then speed = speed * 2.5 end
        local rot = CFrame.Angles(0, freecamYaw, 0) * CFrame.Angles(freecamPitch, 0, 0)
        local pos = freecamCF.Position + rot:VectorToWorldSpace(mv) * speed * dt
        freecamCF = CFrame.new(pos) * rot
        Camera.CFrame = freecamCF
    else
        if freecamCF then exitFreecam() end
    end
end)

-- ═════════════════════════════════════════════════
--   LAUNCH ANIMATION (Black + Neon White)
-- ═════════════════════════════════════════════════
task.spawn(function()
    -- Menu erst versteckt bis Animation fertig
    local wasVisible = Main.Visible
    Main.Visible = false

    -- Vollbild-Loader-Overlay (schwarz, über allem)
    local Loader = New("ScreenGui", {Name="ENI_LOADER", Parent=GuiParent,
        ResetOnSpawn=false, IgnoreGuiInset=true, DisplayOrder=2000,
        ZIndexBehavior=Enum.ZIndexBehavior.Sibling})

    -- Fullscreen schwarze Fläche
    local bg = New("Frame", {Parent=Loader, Size=UDim2.fromScale(1,1),
        BackgroundColor3=Color3.fromRGB(0,0,0), BorderSizePixel=0,
        BackgroundTransparency=1})  -- startet transparent, faded rein

    -- Zentrales Container-Frame
    local center = New("Frame", {Parent=bg, AnchorPoint=Vector2.new(0.5,0.5),
        Position=UDim2.fromScale(0.5,0.5), Size=UDim2.fromOffset(500,180),
        BackgroundTransparency=1})

    -- Großes ENI Logo (neon weiß glow)
    local logo = New("TextLabel", {Parent=center, BackgroundTransparency=1,
        Position=UDim2.fromScale(0.5,0), AnchorPoint=Vector2.new(0.5,0),
        Size=UDim2.fromOffset(500,80),
        Font=Enum.Font.GothamBlack, TextSize=1,  -- startet 1, wird animiert
        Text="ENI HUB", TextColor3=Color3.fromRGB(255,255,255),
        TextTransparency=1})
    -- Text-Stroke für neon-Effekt
    New("UIStroke", {Parent=logo, Color=Color3.fromRGB(255,255,255),
        Thickness=2, Transparency=0.7})

    -- Subtitle
    local sub = New("TextLabel", {Parent=center, BackgroundTransparency=1,
        Position=UDim2.fromOffset(0,88), Size=UDim2.new(1,0,0,20),
        Font=Enum.Font.Code, TextSize=12, Text="INITIALIZING...",
        TextColor3=Color3.fromRGB(180,180,190), TextTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Center})

    -- Loading Bar Container
    local barBg = New("Frame", {Parent=center, AnchorPoint=Vector2.new(0.5,0),
        Position=UDim2.new(0.5,0,0,120), Size=UDim2.fromOffset(320,2),
        BackgroundColor3=Color3.fromRGB(40,40,50), BorderSizePixel=0,
        BackgroundTransparency=1})
    local barFill = New("Frame", {Parent=barBg, Size=UDim2.fromScale(0,1),
        BackgroundColor3=Color3.fromRGB(255,255,255), BorderSizePixel=0})
    -- Neon-glow unter der bar
    local barGlow = New("Frame", {Parent=center, AnchorPoint=Vector2.new(0.5,0),
        Position=UDim2.new(0.5,0,0,118), Size=UDim2.fromOffset(320,8),
        BackgroundColor3=Color3.fromRGB(255,255,255), BorderSizePixel=0,
        BackgroundTransparency=1})
    New("UIGradient", {Parent=barGlow, Rotation=90, Transparency=NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.6),
        NumberSequenceKeypoint.new(1, 1),
    }})

    -- Percent-Label
    local pct = New("TextLabel", {Parent=center, AnchorPoint=Vector2.new(0.5,0),
        Position=UDim2.new(0.5,0,0,132), Size=UDim2.fromOffset(320,20),
        Font=Enum.Font.Code, TextSize=10, Text="0%",
        TextColor3=Color3.fromRGB(140,140,160), TextTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Right})

    -- Horizontale Scanline die von oben nach unten sweept
    local scan = New("Frame", {Parent=bg, Size=UDim2.new(1,0,0,2),
        Position=UDim2.new(0,0,0,-4), BackgroundColor3=Color3.fromRGB(255,255,255),
        BorderSizePixel=0, BackgroundTransparency=0.4})
    New("UIGradient", {Parent=scan, Transparency=NumberSequence.new{
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0.2),
        NumberSequenceKeypoint.new(1, 1),
    }})

    -- ═════ TIMELINE ═════
    -- 1) Fade schwarzer bg rein (0.3s)
    Tween(bg, 0.3, {BackgroundTransparency = 0})
    task.wait(0.3)

    -- 2) Logo Text explodiert von 1 → 56, gleichzeitig fade in
    logo.TextSize = 1
    Tween(logo, 0.6, {TextSize = 56, TextTransparency = 0}, Enum.EasingStyle.Back)
    Tween(sub,  0.6, {TextTransparency = 0})
    Tween(barBg, 0.4, {BackgroundTransparency = 0})
    Tween(pct,   0.6, {TextTransparency = 0})
    task.wait(0.6)

    -- 3) Scanline sweept 3× durch den screen (parallel zu load bar)
    task.spawn(function()
        for i = 1, 3 do
            scan.Position = UDim2.new(0,0,0,-4)
            Tween(scan, 0.7, {Position = UDim2.new(0,0,1,4)}, Enum.EasingStyle.Linear)
            task.wait(0.75)
        end
        scan:Destroy()
    end)

    -- 4) Loading bar füllt 0→100 mit percent tick + wechselnde subtitle msgs
    local msgs = {
        {0,   "INITIALIZING..."},
        {20,  "LOADING MODULES..."},
        {45,  "HOOKING RENDER..."},
        {70,  "ATTACHING ESP..."},
        {90,  "BYPASSING CHECKS..."},
        {100, "ATTACHED."},
    }
    local msgIdx = 1
    for p = 0, 100, 2 do
        barFill.Size    = UDim2.fromScale(p/100, 1)
        barGlow.Size    = UDim2.fromOffset(320 * (p/100), 8)
        barGlow.Position= UDim2.new(0.5, -160 + (160 * (p/100)), 0, 118)
        barGlow.BackgroundTransparency = 0.4
        pct.Text        = tostring(p) .. "%"
        -- Subtitle wechseln
        if msgs[msgIdx+1] and p >= msgs[msgIdx+1][1] then
            msgIdx = msgIdx + 1
            sub.Text = msgs[msgIdx][2]
        end
        task.wait(0.025)
    end

    task.wait(0.4)

    -- 5) Alles fade-out + Loader wegblenden
    Tween(logo, 0.4, {TextTransparency = 1, TextSize = 68})
    Tween(sub,  0.3, {TextTransparency = 1})
    Tween(barBg,0.3, {BackgroundTransparency = 1})
    Tween(barFill, 0.3, {BackgroundTransparency = 1})
    Tween(barGlow,0.3, {BackgroundTransparency = 1})
    Tween(pct,  0.3, {TextTransparency = 1})
    task.wait(0.4)
    Tween(bg,   0.5, {BackgroundTransparency = 1})
    task.wait(0.5)
    Loader:Destroy()

    -- 6) Main slice-in animation (klein → normal, mit fade)
    Main.Visible = wasVisible
    local finalSize = Main.Size
    local finalPos  = Main.Position
    Main.Size = UDim2.fromOffset(700, 0)
    Main.Position = UDim2.new(0.5, -350, 0.5, 0)
    Tween(Main, 0.35, {Size = finalSize, Position = finalPos}, Enum.EasingStyle.Quart)
end)

print("[ENI HUB - ANTI CHEAT TEST] loaded")
