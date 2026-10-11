--[[
    ╔══════════════════════════════════════════════════════╗
    ║          SOVEREIGN AIMBOT V3  —  BLOX FRUITS        ║
    ║          PVP Hub  |  Wind UI  |  Educational Only   ║
    ╚══════════════════════════════════════════════════════╝

    Compatible with: Blox Fruits (game 2753915549)
    Executor req:    getrawmetatable, setreadonly, Drawing API
]]

-- ══════════════════════════════════════════════════════════════
--  SERVICES
-- ══════════════════════════════════════════════════════════════
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService     = game:GetService("TweenService")
local Workspace        = game:GetService("Workspace")
local HttpService      = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()
local Camera      = Workspace.CurrentCamera

-- ══════════════════════════════════════════════════════════════
--  BLOX FRUITS SPECIFIC REFERENCES
--  (resolve lazily so the script loads before the game populates)
-- ══════════════════════════════════════════════════════════════
local BF = {
    -- Remote paths inside ReplicatedStorage
    SwordRemote      = nil,   -- resolved on use
    FruitRemote      = nil,
    GunRemote        = nil,
    BlockRemote      = nil,
    DashRemote       = nil,

    -- Blox Fruits stores character data here
    CharacterFolder  = Workspace:FindFirstChild("Characters"),
}

local function GetBFRemote(name)
    -- Common Blox Fruits remote locations
    local paths = {
        ReplicatedStorage:FindFirstChild(name),
        ReplicatedStorage:FindFirstChild("Remotes") and
            ReplicatedStorage.Remotes:FindFirstChild(name),
        ReplicatedStorage:FindFirstChild("Events") and
            ReplicatedStorage.Events:FindFirstChild(name),
    }
    for _, r in ipairs(paths) do
        if r then return r end
    end
    return nil
end

-- ══════════════════════════════════════════════════════════════
--  WIND UI LOADER
-- ══════════════════════════════════════════════════════════════
local WindUI
local ok, loadErr = pcall(function()
    WindUI = loadstring(game:HttpGet("https://api.windui.xyz/v1/load"))()
end)
if not ok then
    warn("[Sovereign V3] Wind UI failed: " .. tostring(loadErr))
    return
end

-- ══════════════════════════════════════════════════════════════
--  SETTINGS
-- ══════════════════════════════════════════════════════════════
local S = {
    -- ── Aimbot ──────────────────────────────
    AimbotEnabled      = false,
    AimbotKey          = Enum.KeyCode.Q,
    AimbotSmoothing    = 0.18,
    AimbotPart         = "Head",
    AimbotTeamCheck    = true,
    AimbotWallCheck    = true,
    AimbotMaxDistance  = 600,
    AimbotPrediction   = true,
    AimbotPredictAmt   = 0.12,
    HighlightTarget    = true,

    -- ── Silent Aim ──────────────────────────
    SilentEnabled      = false,
    SilentPart         = "HumanoidRootPart",
    SilentChance       = 100,

    -- ── FOV Circle ──────────────────────────
    FOVEnabled         = true,
    FOVRadius          = 130,
    FOVColor           = Color3.fromRGB(255, 220, 50),
    FOVThickness       = 1.5,
    FOVFilled          = false,

    -- ── Fast Attack / Hit-box ────────────────
    FastAttackEnabled  = false,
    AttackDelay        = 0.0,   -- seconds between auto-attacks
    HitboxEnabled      = false,
    HitboxSize         = 12,    -- studs — expands enemy hitbox client-side

    -- ── Fruit / Skill Spam ──────────────────
    FruitSpamEnabled   = false,
    FruitSpamKey       = Enum.KeyCode.Z,
    FruitMoveSlot      = 1,     -- 1-4 skill slot

    -- ── Auto Dash ───────────────────────────
    AutoDashEnabled    = false,
    AutoDashCooldown   = 0.3,

    -- ── ESP ─────────────────────────────────
    ESPEnabled         = false,
    ESPBoxes           = true,
    ESPNames           = true,
    ESPDistance        = true,
    ESPHealth          = true,
    ESPFruit           = true,   -- shows equipped devil fruit
    ESPMaxDistance     = 700,

    -- ── Combat Misc ─────────────────────────
    AntiKnockback      = false,
    Bhop               = false,
    NoFallDmg          = false,
    InfiniteEnergy     = false,
    AutoBlock          = false,
    AutoCombo          = false,  -- auto-chains M1 → skill → M1
}

-- ══════════════════════════════════════════════════════════════
--  UTILITY
-- ══════════════════════════════════════════════════════════════
local function Char(p)   return p and p.Character end
local function Root(p)   local c = Char(p); return c and c:FindFirstChild("HumanoidRootPart") end
local function Hum(p)    local c = Char(p); return c and c:FindFirstChildOfClass("Humanoid") end
local function Alive(p)  local h = Hum(p); return h and h.Health > 0 end

local function SameTeam(p)
    if not S.AimbotTeamCheck then return false end
    return p.Team ~= nil and p.Team == LocalPlayer.Team
end

local function LoS(part)
    if not S.AimbotWallCheck then return true end
    local rp = RaycastParams.new()
    rp.FilterDescendantsInstances = {LocalPlayer.Character or {}}
    rp.FilterType = Enum.RaycastFilterType.Exclude
    local dir = part.Position - Camera.CFrame.Position
    local res = Workspace:Raycast(Camera.CFrame.Position, dir, rp)
    if res then
        local anc = res.Instance:FindFirstAncestorOfClass("Model")
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl.Character == anc then return true end
        end
        return false
    end
    return true
end

local function GetTarget()
    local best, bestDist = nil, math.huge
    local cx, cy = Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if SameTeam(p) then continue end
        if not Alive(p) then continue end

        local c = Char(p); if not c then continue end
        local part = c:FindFirstChild(S.AimbotPart) or c:FindFirstChild("HumanoidRootPart")
        if not part then continue end

        local wdist = (part.Position - Camera.CFrame.Position).Magnitude
        if wdist > S.AimbotMaxDistance then continue end
        if S.AimbotWallCheck and not LoS(part) then continue end

        local sp, vis = Camera:WorldToViewportPoint(part.Position)
        if not vis then continue end

        local d = Vector2.new(sp.X - cx, sp.Y - cy).Magnitude
        if d < S.FOVRadius and d < bestDist then
            bestDist = d; best = p
        end
    end
    return best
end

-- Blox Fruits devil fruit attribute path
local function GetFruitName(player)
    local c = Char(player)
    if not c then return "?" end
    -- BF stores equipped fruit in character attributes or a StringValue
    local val = c:FindFirstChild("DevilFruit")
           or c:FindFirstChild("Fruit")
           or c:FindFirstChild("FruitName")
    if val then return tostring(val.Value) end
    -- fallback: check LocalPlayer stats folder
    local stats = player:FindFirstChild("Stats") or player:FindFirstChild("leaderstats")
    if stats then
        local f = stats:FindFirstChild("Fruit") or stats:FindFirstChild("DevilFruit")
        if f then return tostring(f.Value) end
    end
    return "None"
end

-- ══════════════════════════════════════════════════════════════
--  FOV CIRCLE
-- ══════════════════════════════════════════════════════════════
local FOVCircle = Drawing.new("Circle")
FOVCircle.NumSides  = 80
FOVCircle.Radius    = S.FOVRadius
FOVCircle.Color     = S.FOVColor
FOVCircle.Thickness = S.FOVThickness
FOVCircle.Filled    = S.FOVFilled
FOVCircle.Visible   = S.FOVEnabled

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Radius   = S.FOVRadius
    FOVCircle.Color    = S.FOVColor
    FOVCircle.Visible  = S.FOVEnabled
end)

-- ══════════════════════════════════════════════════════════════
--  AIMBOT
-- ══════════════════════════════════════════════════════════════
local currentTarget = nil

RunService.RenderStepped:Connect(function()
    -- Clear old highlight when aimbot off
    if not S.AimbotEnabled then
        currentTarget = nil
        return
    end
    if not UserInputService:IsKeyDown(S.AimbotKey) then
        currentTarget = nil
        return
    end

    local target = GetTarget()
    currentTarget = target
    if not target then return end

    local c    = Char(target); if not c then return end
    local part = c:FindFirstChild(S.AimbotPart) or c:FindFirstChild("HumanoidRootPart")
    if not part then return end

    local pos = part.Position

    -- Blox Fruits players move fast — prediction is important
    if S.AimbotPrediction then
        local root = Root(target)
        if root then
            pos = pos + root.AssemblyLinearVelocity * S.AimbotPredictAmt
        end
    end

    local cf   = Camera.CFrame
    local tgt  = CFrame.new(cf.Position, pos)
    Camera.CFrame = cf:Lerp(tgt, S.AimbotSmoothing)

    -- Selection highlight
    if S.HighlightTarget and not c:FindFirstChild("_SovHL") then
        local hl = Instance.new("Highlight")
        hl.Name            = "_SovHL"
        hl.FillColor       = Color3.fromRGB(255, 30, 30)
        hl.OutlineColor    = Color3.fromRGB(255, 200, 0)
        hl.FillTransparency   = 0.5
        hl.OutlineTransparency = 0
        hl.Adornee = c
        hl.Parent  = c
    end
end)

-- Clean highlights when target changes
RunService.Heartbeat:Connect(function()
    for _, p in ipairs(Players:GetPlayers()) do
        local c = Char(p)
        if not c then continue end
        local hl = c:FindFirstChild("_SovHL")
        if hl and (not S.HighlightTarget or p ~= currentTarget) then
            hl:Destroy()
        end
    end
end)

-- ══════════════════════════════════════════════════════════════
--  SILENT AIM  (Mouse.Hit hook)
-- ══════════════════════════════════════════════════════════════
pcall(function()
    local mt  = getrawmetatable(Mouse)
    local ro  = setreadonly or (function() end)
    local old = mt.__index
    ro(mt, false)
    mt.__index = function(self, key)
        if key == "Hit" and S.SilentEnabled then
            local t = GetTarget()
            if t and math.random(100) <= S.SilentChance then
                local c = Char(t)
                if c then
                    local part = c:FindFirstChild(S.SilentPart)
                             or c:FindFirstChild("HumanoidRootPart")
                    if part then return CFrame.new(part.Position) end
                end
            end
        end
        return old(self, key)
    end
    ro(mt, true)
end)

-- ══════════════════════════════════════════════════════════════
--  HITBOX EXPANDER  (Blox Fruits PVP meta staple)
--  Enlarges enemy HumanoidRootPart size client-side so M1s
--  register at a wider range.
-- ══════════════════════════════════════════════════════════════
local originalSizes = {}

local function ApplyHitbox(enabled)
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        local c = Char(p); if not c then continue end
        local root = c:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        if enabled then
            if not originalSizes[p] then
                originalSizes[p] = root.Size
            end
            root.Size = Vector3.new(S.HitboxSize, S.HitboxSize, S.HitboxSize)
        else
            if originalSizes[p] then
                root.Size      = originalSizes[p]
                originalSizes[p] = nil
            end
        end
    end
end

RunService.Heartbeat:Connect(function()
    if S.HitboxEnabled then ApplyHitbox(true)
    else ApplyHitbox(false) end
end)

-- ══════════════════════════════════════════════════════════════
--  FAST ATTACK  (Blox Fruits M1 remote)
--  Fires the sword/gun click remote on heartbeat.
-- ══════════════════════════════════════════════════════════════
local lastFastAtk = 0

RunService.Heartbeat:Connect(function()
    if not S.FastAttackEnabled then return end
    if tick() - lastFastAtk < S.AttackDelay then return end
    lastFastAtk = tick()

    local c = Char(LocalPlayer); if not c then return end
    -- Try equipped tool first
    local tool = c:FindFirstChildOfClass("Tool")
    if tool then
        local remote = tool:FindFirstChildOfClass("RemoteEvent")
        if remote then pcall(function() remote:FireServer() end) end
    end

    -- Also try known BF sword/click remotes
    local clickRemote = GetBFRemote("Punch")
                     or GetBFRemote("SwordClick")
                     or GetBFRemote("M1")
    if clickRemote then
        pcall(function() clickRemote:FireServer() end)
    end
end)

-- ══════════════════════════════════════════════════════════════
--  FRUIT SKILL SPAM
--  Rapid-fires a fruit move slot toward the nearest target.
-- ══════════════════════════════════════════════════════════════
local fruitSpamConn

local function StartFruitSpam()
    if fruitSpamConn then fruitSpamConn:Disconnect() end
    fruitSpamConn = RunService.Heartbeat:Connect(function()
        if not S.FruitSpamEnabled then return end
        if not UserInputService:IsKeyDown(S.FruitSpamKey) then return end

        local target = GetTarget()
        local aimPos = target and Root(target) and Root(target).Position
                    or Mouse.Hit.Position

        -- BF fruit moves fire via a remote named after the slot
        local slotNames = {"Z", "X", "C", "V"}
        local remoteName = "Fruit_" .. slotNames[S.FruitMoveSlot]
        local remote = GetBFRemote(remoteName)
               or GetBFRemote("FruitSkill" .. S.FruitMoveSlot)
               or GetBFRemote("Skill" .. slotNames[S.FruitMoveSlot])

        if remote and remote:IsA("RemoteEvent") then
            pcall(function() remote:FireServer(aimPos) end)
        end
    end)
end
StartFruitSpam()

-- ══════════════════════════════════════════════════════════════
--  AUTO DASH  (Blox Fruits uses double-tap to dash)
-- ══════════════════════════════════════════════════════════════
local lastDash = 0

RunService.Heartbeat:Connect(function()
    if not S.AutoDashEnabled then return end
    if tick() - lastDash < S.AutoDashCooldown then return end

    local dashRemote = GetBFRemote("Dash") or GetBFRemote("Blink")
    if dashRemote and dashRemote:IsA("RemoteEvent") then
        lastDash = tick()
        pcall(function()
            local dir = Camera.CFrame.LookVector
            dashRemote:FireServer(dir)
        end)
    end
end)

-- ══════════════════════════════════════════════════════════════
--  AUTO BLOCK  (Blox Fruits blocking remote)
-- ══════════════════════════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    if not S.AutoBlock then return end
    local blockRemote = GetBFRemote("Block") or GetBFRemote("Blocking")
    if blockRemote and blockRemote:IsA("RemoteEvent") then
        pcall(function() blockRemote:FireServer(true) end)
    end
end)

-- ══════════════════════════════════════════════════════════════
--  INFINITE ENERGY  (spoof energy attribute)
-- ══════════════════════════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    if not S.InfiniteEnergy then return end
    local c = Char(LocalPlayer); if not c then return end
    local stats = LocalPlayer:FindFirstChild("Stats")
    if stats then
        local energy = stats:FindFirstChild("Energy") or stats:FindFirstChild("Mana")
        if energy and energy:IsA("NumberValue") then
            energy.Value = energy.Value < 100 and 9999 or energy.Value
        end
    end
end)

-- ══════════════════════════════════════════════════════════════
--  ANTI-KNOCKBACK
-- ══════════════════════════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    if not S.AntiKnockback then return end
    local c = Char(LocalPlayer); if not c then return end
    local r = c:FindFirstChild("HumanoidRootPart"); if not r then return end
    local v = r.AssemblyLinearVelocity
    local cap = 60
    if math.abs(v.X) > cap or math.abs(v.Z) > cap then
        r.AssemblyLinearVelocity = Vector3.new(
            math.clamp(v.X, -cap, cap), v.Y, math.clamp(v.Z, -cap, cap))
    end
end)

-- ══════════════════════════════════════════════════════════════
--  BUNNY HOP
-- ══════════════════════════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    if not S.Bhop then return end
    local c = Char(LocalPlayer); if not c then return end
    local h = c:FindFirstChildOfClass("Humanoid"); if not h then return end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        if h.FloorMaterial ~= Enum.Material.Air then
            h:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- ══════════════════════════════════════════════════════════════
--  NO FALL DAMAGE
-- ══════════════════════════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    if not S.NoFallDmg then return end
    local c = Char(LocalPlayer); if not c then return end
    local h = c:FindFirstChildOfClass("Humanoid"); if not h then return end
    if h:GetState() == Enum.HumanoidStateType.Freefall then
        h:ChangeState(Enum.HumanoidStateType.Landed)
    end
end)

-- ══════════════════════════════════════════════════════════════
--  AUTO COMBO  (M1 → Skill → M1 loop toward target)
-- ══════════════════════════════════════════════════════════════
local comboStep = 1
local lastCombo = 0

RunService.Heartbeat:Connect(function()
    if not S.AutoCombo then return end
    if tick() - lastCombo < 0.22 then return end
    lastCombo = tick()

    local target = GetTarget(); if not target then return end
    local tRoot  = Root(target); if not tRoot then return end

    local c = Char(LocalPlayer); if not c then return end
    local myRoot = c:FindFirstChild("HumanoidRootPart"); if not myRoot then return end

    local dist = (tRoot.Position - myRoot.Position).Magnitude
    if dist > 20 then return end -- only combo in melee range

    -- Step: M1 → Z skill → M1 → M1 → repeat
    local clickRemote = GetBFRemote("Punch") or GetBFRemote("SwordClick") or GetBFRemote("M1")
    local zRemote     = GetBFRemote("Skill_Z") or GetBFRemote("Fruit_Z")

    if comboStep == 1 or comboStep == 3 or comboStep == 4 then
        if clickRemote then pcall(function() clickRemote:FireServer() end) end
    elseif comboStep == 2 then
        if zRemote then pcall(function() zRemote:FireServer(tRoot.Position) end) end
    end

    comboStep = comboStep % 4 + 1
end)

-- ══════════════════════════════════════════════════════════════
--  ESP
-- ══════════════════════════════════════════════════════════════
local ESPObjects = {}

local function MakeESP(p)
    if ESPObjects[p] then return end
    ESPObjects[p] = {
        Box      = Drawing.new("Square"),
        Name     = Drawing.new("Text"),
        Dist     = Drawing.new("Text"),
        HPBar    = Drawing.new("Square"),
        HPBarBG  = Drawing.new("Square"),
        Fruit    = Drawing.new("Text"),
    }
    local e = ESPObjects[p]
    e.Box.Filled = false; e.Box.Thickness = 1
    e.Name.Size = 13; e.Name.Center = true; e.Name.Outline = true
    e.Dist.Size = 11; e.Dist.Center = true; e.Dist.Outline = true
    e.Fruit.Size = 11; e.Fruit.Center = true; e.Fruit.Outline = true
    e.Fruit.Color = Color3.fromRGB(180, 100, 255)
    e.HPBar.Filled = true
    e.HPBarBG.Filled = true; e.HPBarBG.Color = Color3.fromRGB(40,40,40)
    for _, d in pairs(e) do d.Visible = false end
end

local function KillESP(p)
    local e = ESPObjects[p]; if not e then return end
    for _, d in pairs(e) do d:Remove() end
    ESPObjects[p] = nil
end

local function UpdateESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        MakeESP(p)
        local e = ESPObjects[p]
        local c = Char(p)

        if not S.ESPEnabled or not c or not Alive(p) then
            for _, d in pairs(e) do d.Visible = false end
            continue
        end

        local root = Root(p); if not root then continue end
        local wd = (root.Position - Camera.CFrame.Position).Magnitude
        if wd > S.ESPMaxDistance then
            for _, d in pairs(e) do d.Visible = false end
            continue
        end

        local head  = c:FindFirstChild("Head") or root
        local top,  topVis = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.6,0))
        local bot,  _      = Camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0))
        if not topVis then
            for _, d in pairs(e) do d.Visible = false end
            continue
        end

        local col = Color3.fromRGB(255, 50, 50)
        if SameTeam(p) then col = Color3.fromRGB(50, 220, 100) end

        local bH  = math.abs(top.Y - bot.Y)
        local bW  = bH * 0.55
        local bX  = top.X - bW / 2
        local bY  = top.Y

        -- Box
        if S.ESPBoxes then
            e.Box.Position = Vector2.new(bX, bY)
            e.Box.Size     = Vector2.new(bW, bH)
            e.Box.Color    = col
            e.Box.Visible  = true
        else e.Box.Visible = false end

        -- Name
        if S.ESPNames then
            e.Name.Text     = p.DisplayName
            e.Name.Position = Vector2.new(top.X, bY - 16)
            e.Name.Color    = col
            e.Name.Visible  = true
        else e.Name.Visible = false end

        -- Distance
        if S.ESPDistance then
            e.Dist.Text     = string.format("[%dm]", math.floor(wd))
            e.Dist.Position = Vector2.new(top.X, bot.Y + 3)
            e.Dist.Color    = Color3.fromRGB(210, 210, 210)
            e.Dist.Visible  = true
        else e.Dist.Visible = false end

        -- Fruit label
        if S.ESPFruit then
            e.Fruit.Text     = "🍎 " .. GetFruitName(p)
            e.Fruit.Position = Vector2.new(top.X, bot.Y + 16)
            e.Fruit.Visible  = true
        else e.Fruit.Visible = false end

        -- Health bar
        local hum = Hum(p)
        if S.ESPHealth and hum then
            local ratio = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            local hpCol = Color3.fromRGB(
                math.floor(255 * (1 - ratio)),
                math.floor(255 * ratio), 0)
            e.HPBarBG.Position = Vector2.new(bX - 7, bY)
            e.HPBarBG.Size     = Vector2.new(4, bH)
            e.HPBarBG.Visible  = true
            e.HPBar.Position   = Vector2.new(bX - 7, bY + bH * (1 - ratio))
            e.HPBar.Size       = Vector2.new(4, bH * ratio)
            e.HPBar.Color      = hpCol
            e.HPBar.Visible    = true
        else
            e.HPBar.Visible   = false
            e.HPBarBG.Visible = false
        end
    end
end

Players.PlayerRemoving:Connect(KillESP)
RunService.RenderStepped:Connect(UpdateESP)

-- ══════════════════════════════════════════════════════════════
--  WIND UI — WINDOW
-- ══════════════════════════════════════════════════════════════
local W = WindUI:CreateWindow({
    Title    = "Sovereign",
    SubTitle = "v3  ·  Blox Fruits  ·  Wind UI",
    TabWidth = 160,
    Size     = UDim2.fromOffset(600, 480),
    Acrylic  = true,
    Theme    = "Dark",
    KeySystem = false,
})

-- ── TAB: AIMBOT ────────────────────────────────────────────────
local TabAim = W:Tab({ Title = "Aimbot", Icon = "crosshair" })

TabAim:Toggle({
    Title = "Enable Aimbot",
    Default = S.AimbotEnabled,
    Callback = function(v) S.AimbotEnabled = v end,
})
TabAim:Keybind({
    Title = "Hold Key",
    Default = S.AimbotKey,
    Callback = function(v) S.AimbotKey = v end,
})
TabAim:Dropdown({
    Title = "Target Part",
    Default = S.AimbotPart,
    Options = {"Head", "HumanoidRootPart", "UpperTorso", "Torso"},
    Callback = function(v) S.AimbotPart = v end,
})
TabAim:Slider({
    Title = "Smoothness",
    Min = 0.01, Max = 1, Default = S.AimbotSmoothing, Rounding = 2,
    Callback = function(v) S.AimbotSmoothing = v end,
})
TabAim:Slider({
    Title = "Max Distance (studs)",
    Min = 50, Max = 1500, Default = S.AimbotMaxDistance, Rounding = 0,
    Callback = function(v) S.AimbotMaxDistance = v end,
})
TabAim:Toggle({
    Title = "Team Check",
    Default = S.AimbotTeamCheck,
    Callback = function(v) S.AimbotTeamCheck = v end,
})
TabAim:Toggle({
    Title = "Wall Check",
    Default = S.AimbotWallCheck,
    Callback = function(v) S.AimbotWallCheck = v end,
})
TabAim:Toggle({
    Title = "Velocity Prediction",
    Default = S.AimbotPrediction,
    Callback = function(v) S.AimbotPrediction = v end,
})
TabAim:Slider({
    Title = "Prediction Amount",
    Min = 0, Max = 0.5, Default = S.AimbotPredictAmt, Rounding = 2,
    Callback = function(v) S.AimbotPredictAmt = v end,
})
TabAim:Toggle({
    Title = "Highlight Target",
    Default = S.HighlightTarget,
    Callback = function(v) S.HighlightTarget = v end,
})

-- ── TAB: SILENT AIM ────────────────────────────────────────────
local TabSA = W:Tab({ Title = "Silent Aim", Icon = "zap" })

TabSA:Toggle({
    Title = "Enable Silent Aim",
    Default = S.SilentEnabled,
    Callback = function(v) S.SilentEnabled = v end,
})
TabSA:Dropdown({
    Title = "Target Part",
    Default = S.SilentPart,
    Options = {"Head", "HumanoidRootPart", "UpperTorso"},
    Callback = function(v) S.SilentPart = v end,
})
TabSA:Slider({
    Title = "Hit Chance (%)",
    Min = 1, Max = 100, Default = S.SilentChance, Rounding = 0,
    Callback = function(v) S.SilentChance = v end,
})

-- ── TAB: FOV ───────────────────────────────────────────────────
local TabFOV = W:Tab({ Title = "FOV", Icon = "circle" })

TabFOV:Toggle({
    Title = "Show FOV Circle",
    Default = S.FOVEnabled,
    Callback = function(v) S.FOVEnabled = v end,
})
TabFOV:Slider({
    Title = "Radius",
    Min = 20, Max = 600, Default = S.FOVRadius, Rounding = 0,
    Callback = function(v) S.FOVRadius = v end,
})
TabFOV:Slider({
    Title = "Thickness",
    Min = 0.5, Max = 5, Default = S.FOVThickness, Rounding = 1,
    Callback = function(v) S.FOVThickness = v; FOVCircle.Thickness = v end,
})
TabFOV:Toggle({
    Title = "Filled",
    Default = S.FOVFilled,
    Callback = function(v) S.FOVFilled = v; FOVCircle.Filled = v end,
})
TabFOV:ColorPicker({
    Title = "Color",
    Default = S.FOVColor,
    Callback = function(v) S.FOVColor = v end,
})

-- ── TAB: COMBAT ────────────────────────────────────────────────
local TabCombat = W:Tab({ Title = "Combat", Icon = "swords" })

TabCombat:Toggle({
    Title = "Fast Attack",
    Default = S.FastAttackEnabled,
    Callback = function(v) S.FastAttackEnabled = v end,
})
TabCombat:Slider({
    Title = "Attack Delay (s)",
    Min = 0, Max = 0.5, Default = S.AttackDelay, Rounding = 2,
    Callback = function(v) S.AttackDelay = v end,
})
TabCombat:Divider({ Title = "Hitbox" })
TabCombat:Toggle({
    Title = "Hitbox Expander",
    Default = S.HitboxEnabled,
    Callback = function(v) S.HitboxEnabled = v end,
})
TabCombat:Slider({
    Title = "Hitbox Size (studs)",
    Min = 5, Max = 40, Default = S.HitboxSize, Rounding = 0,
    Callback = function(v) S.HitboxSize = v end,
})
TabCombat:Divider({ Title = "Combo" })
TabCombat:Toggle({
    Title = "Auto Combo (M1 → Z → M1)",
    Default = S.AutoCombo,
    Callback = function(v) S.AutoCombo = v end,
})
TabCombat:Toggle({
    Title = "Auto Block",
    Default = S.AutoBlock,
    Callback = function(v) S.AutoBlock = v end,
})

-- ── TAB: FRUIT ─────────────────────────────────────────────────
local TabFruit = W:Tab({ Title = "Fruit", Icon = "star" })

TabFruit:Toggle({
    Title = "Fruit Skill Spam",
    Default = S.FruitSpamEnabled,
    Callback = function(v) S.FruitSpamEnabled = v end,
})
TabFruit:Keybind({
    Title = "Spam Key (hold)",
    Default = S.FruitSpamKey,
    Callback = function(v) S.FruitSpamKey = v end,
})
TabFruit:Dropdown({
    Title = "Skill Slot",
    Default = "Slot 1 (Z)",
    Options = {"Slot 1 (Z)", "Slot 2 (X)", "Slot 3 (C)", "Slot 4 (V)"},
    Callback = function(v)
        local map = {["Slot 1 (Z)"]=1,["Slot 2 (X)"]=2,["Slot 3 (C)"]=3,["Slot 4 (V)"]=4}
        S.FruitMoveSlot = map[v] or 1
    end,
})
TabFruit:Divider({ Title = "Dash" })
TabFruit:Toggle({
    Title = "Auto Dash",
    Default = S.AutoDashEnabled,
    Callback = function(v) S.AutoDashEnabled = v end,
})
TabFruit:Slider({
    Title = "Dash Cooldown (s)",
    Min = 0.1, Max = 2, Default = S.AutoDashCooldown, Rounding = 1,
    Callback = function(v) S.AutoDashCooldown = v end,
})

-- ── TAB: ESP ───────────────────────────────────────────────────
local TabESP = W:Tab({ Title = "ESP", Icon = "eye" })

TabESP:Toggle({
    Title = "Enable ESP",
    Default = S.ESPEnabled,
    Callback = function(v) S.ESPEnabled = v end,
})
TabESP:Toggle({
    Title = "Boxes",
    Default = S.ESPBoxes,
    Callback = function(v) S.ESPBoxes = v end,
})
TabESP:Toggle({
    Title = "Names",
    Default = S.ESPNames,
    Callback = function(v) S.ESPNames = v end,
})
TabESP:Toggle({
    Title = "Distance",
    Default = S.ESPDistance,
    Callback = function(v) S.ESPDistance = v end,
})
TabESP:Toggle({
    Title = "Health Bar",
    Default = S.ESPHealth,
    Callback = function(v) S.ESPHealth = v end,
})
TabESP:Toggle({
    Title = "Show Devil Fruit",
    Default = S.ESPFruit,
    Callback = function(v) S.ESPFruit = v end,
})
TabESP:Slider({
    Title = "Max Distance",
    Min = 50, Max = 2000, Default = S.ESPMaxDistance, Rounding = 0,
    Callback = function(v) S.ESPMaxDistance = v end,
})

-- ── TAB: MISC ──────────────────────────────────────────────────
local TabMisc = W:Tab({ Title = "Misc", Icon = "settings" })

TabMisc:Toggle({
    Title = "Anti-Knockback",
    Default = S.AntiKnockback,
    Callback = function(v) S.AntiKnockback = v end,
})
TabMisc:Toggle({
    Title = "Bunny Hop",
    Default = S.Bhop,
    Callback = function(v) S.Bhop = v end,
})
TabMisc:Toggle({
    Title = "No Fall Damage",
    Default = S.NoFallDmg,
    Callback = function(v) S.NoFallDmg = v end,
})
TabMisc:Toggle({
    Title = "Infinite Energy / Mana",
    Default = S.InfiniteEnergy,
    Callback = function(v) S.InfiniteEnergy = v end,
})
TabMisc:Divider({ Title = "Script" })
TabMisc:Button({
    Title = "Destroy GUI",
    Callback = function()
        ApplyHitbox(false)
        FOVCircle:Remove()
        for _, p in ipairs(Players:GetPlayers()) do KillESP(p) end
        W:Destroy()
    end,
})
TabMisc:Label({ Title = "Sovereign V3  ·  Blox Fruits  ·  Wind UI" })

-- ══════════════════════════════════════════════════════════════
--  INIT
-- ══════════════════════════════════════════════════════════════
W:SelectTab(1)
print("[Sovereign V3 | BF] Loaded ✓")
