--[[
    ███████╗ ██████╗ ██╗   ██╗███████╗██████╗ ███████╗██╗ ██████╗ ███╗   ██╗
    ██╔════╝██╔═══██╗██║   ██║██╔════╝██╔══██╗██╔════╝██║██╔════╝ ████╗  ██║
    ███████╗██║   ██║██║   ██║█████╗  ██████╔╝█████╗  ██║██║  ███╗██╔██╗ ██║
    ╚════██║██║   ██║╚██╗ ██╔╝██╔══╝  ██╔══██╗██╔══╝  ██║██║   ██║██║╚██╗██║
    ███████║╚██████╔╝ ╚████╔╝ ███████╗██║  ██║███████╗██║╚██████╔╝██║ ╚████║
    ╚══════╝ ╚═════╝   ╚═══╝  ╚══════╝╚═╝  ╚═╝╚══════╝╚═╝ ╚═════╝ ╚═╝  ╚═══╝
                                  H U B
    Game: Blox Fruits (Roblox)
    Version: 1.0
    Loadstring:
        loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_GITHUB/SovereignHub/main/SovereignHub.lua"))()
--]]

-- ============================================================
-- SECTION 1: CORE SERVICES & GLOBALS
-- ============================================================
do
    ply         = game:GetService("Players")
    plr         = ply.LocalPlayer
    replicated  = game:GetService("ReplicatedStorage")
    Lv          = 0
    pcall(function() Lv = plr:WaitForChild("Data",20):WaitForChild("Level",20).Value end)
    TeleportService = game:GetService("TeleportService")
    TW              = game:GetService("TweenService")
    Lighting        = game:GetService("Lighting")
    Enemies         = workspace:WaitForChild("Enemies",30) or workspace:FindFirstChild("Enemies")
    vim1            = game:GetService("VirtualInputManager")
    vim2            = game:GetService("VirtualUser")
    RunSer          = game:GetService("RunService")
    Stats           = game:GetService("Stats")
    HttpService     = game:GetService("HttpService")
    RS              = game:GetService("ReplicatedStorage")

    repeat task.wait() until plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    Root = plr.Character.HumanoidRootPart
    plr.CharacterAdded:Connect(function(char)
        Root = char:WaitForChild("HumanoidRootPart")
    end)

    TeamSelf = plr.Team
    Energy   = 0
    pcall(function() Energy = plr.Character:WaitForChild("Energy").Value end)

    BringConnections = {}
    BossList         = {}
    MaterialList     = {}
    NPCList          = {}
    shouldTween      = false
    SoulGuitar       = false
    KenTest          = true
    debug            = false
    Brazier1         = false
    Brazier2         = false
    Brazier3         = false
    Sec              = 0.05
    ClickState       = 0
    Num_self         = 25
    RandomCFrame     = false
    _B               = true

    _G.SpinAngle        = 0
    _G.SpinRadius       = 6.5
    _G.SpinSpeed        = 50
    _G.SpinHeightMelee  = 14
    _G.SpinHeightFruit  = 12
    _G.SpinEnabled      = false
    _G.ActiveFarm       = nil
    _G.LastFarmPos      = nil
end

-- ============================================================
-- SECTION 2: WAIT FOR GAME LOAD
-- ============================================================
if not game:IsLoaded() then game.Loaded:Wait() end
do
    local t0 = tick()
    repeat task.wait(0.1) until (plr.PlayerGui:FindFirstChild("Main") ~= nil) or (tick()-t0 > 15)
    local mainGui = plr.PlayerGui:FindFirstChild("Main")
    local loading = mainGui and mainGui:FindFirstChild("Loading")
    if loading then
        local t1 = tick()
        repeat task.wait(0.2) until (not loading.Parent) or (loading.Visible == false) or (tick()-t1 > 30)
    end
end

-- ============================================================
-- SECTION 3: WORLD DETECTION & LISTS
-- ============================================================
World1 = game.PlaceId == 2753915549 or game.PlaceId == 85211729168715
World2 = game.PlaceId == 4442272183 or game.PlaceId == 79091703265657
World3 = game.PlaceId == 7449423635 or game.PlaceId == 100117331123089

sea1 = World1
sea2 = World2
sea3 = World3

Marines = function() replicated.Remotes.CommF_:InvokeServer("SetTeam","Marines") end
Pirates = function() replicated.Remotes.CommF_:InvokeServer("SetTeam","Pirates") end

if World1 then
    BossList = {"The Gorilla King","Bobby","The Saw","Yeti","Mob Leader","Vice Admiral","Saber Expert","Warden","Chief Warden","Swan","Magma Admiral","Fishman Lord","Wysper","Thunder God","Cyborg","Ice Admiral","Greybeard"}
    MaterialList = {"Leather + Scrap Metal","Angel Wings","Magma Ore","Fish Tail"}
elseif World2 then
    BossList = {"Diamond","Jeremy","Orbitus","Don Swan","Smoke Admiral","Awakened Ice Admiral","Tide Keeper","Darkbeard","Cursed Captain","Order"}
    MaterialList = {"Leather + Scrap Metal","Radioactive Material","Ectoplasm","Mystic Droplet","Magma Ore","Vampire Fang"}
elseif World3 then
    BossList = {"Stone","Hydra Leader","Kilo Admiral","Captain Elephant","Beautiful Pirate","Cake Queen","Dough King","Longma","Soul Reaper","rip_indra True Form","Tyrant of the Skies"}
    MaterialList = {"Scrap Metal","Demonic Wisp","Conjured Cocoa","Dragon Scale","Gunpowder","Fish Tail","Mini Tusk"}
end

local DungeonTables = {"Flame","Ice","Quake","Light","Dark","String","Rumble","Magma","Human: Buddha","Sand","Bird: Phoenix","Dough"}
local RenMon        = {"Snow Lurker","Arctic Warrior","Hidden Key","Awakened Ice Admiral"}
local AllBoats      = {"Beast Hunter","Lantern","Guardian","Grand Brigade","Dinghy","Sloop","The Sentinel"}

-- ============================================================
-- SECTION 4: TELEPORT HELPERS
-- ============================================================
local Settings = {
    ["Tween Speed"]          = 350,
    ["Bypass Teleport"]      = true,
    ["Up Y"]                 = false,
    ["Up Y When Low Health"] = false,
    ["Same Y"]               = false
}

function _tp(cf)
    pcall(function()
        if typeof(cf) == "CFrame" then
            plr.Character.HumanoidRootPart.CFrame = cf
        elseif typeof(cf) == "Vector3" then
            plr.Character.HumanoidRootPart.CFrame = CFrame.new(cf)
        end
    end)
end

function _tpFast(cf)
    pcall(function()
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            plr.Character.HumanoidRootPart.CFrame = cf
        end
    end)
end

function Convert_CFrame(x)
    if not x then return end
    if typeof(x) == "Vector3" then return CFrame.new(x) end
    if typeof(x) == "CFrame"  then return x end
    if typeof(x) == "Model"   then return x:GetPivot() end
    if x.CFrame then return x.CFrame end
    return nil
end

function GetDistance(POS_1, POS_2, NO_Y)
    if POS_1 == nil then return 9e9 end
    local Character = plr.Character
    if not Character then return 9e9 end
    local Humanoid = Character:FindFirstChild("Humanoid")
    if not Humanoid or Humanoid.Health <= 0 then return 9e9 end
    if POS_2 == nil then
        POS_2 = Character:FindFirstChild("HumanoidRootPart")
        if not POS_2 then return 9e9 end
    end
    local pos1 = Convert_CFrame(POS_1)
    local pos2 = Convert_CFrame(POS_2)
    if NO_Y then
        return (Vector3.new(pos1.X,0,pos1.Z) - Vector3.new(pos2.X,0,pos2.Z)).Magnitude
    else
        return (pos1.Position - pos2.Position).Magnitude
    end
end

function InArea(POS)
    local WorldOrigin = workspace:FindFirstChild("_WorldOrigin")
    if not WorldOrigin then return {Name=""} end
    local pos = Convert_CFrame(POS)
    for _,v in next, WorldOrigin.Locations:GetChildren() do
        if v:FindFirstChild("Mesh") and (pos.Position - v.Position).Magnitude <= v.Mesh.Scale.X then
            return v
        end
    end
    return {Name=""}
end

function getdis(a,b)
    b = b or plr.Character.HumanoidRootPart.CFrame
    local _a = CFrame.new(a.X, b.Y, a.Z)
    local _b = CFrame.new(b.X,b.Y,b.Z)
    return (_a.Position - _b.Position).Magnitude
end

function requestentrance(pos)
    local targetPos = pos
    if typeof(pos) == "CFrame" then targetPos = pos.Position end
    pcall(function()
        replicated.Remotes.CommF_:InvokeServer("requestEntrance", targetPos)
    end)
end

-- ============================================================
-- SECTION 5: SPIN / ORBIT SYSTEM
-- ============================================================
function GetSpinCFrame(targetPart, offset)
    if not RandomCFrame then
        return targetPart.CFrame * CFrame.new(0, offset, 0) * CFrame.Angles(0, math.rad(180), 0)
    end
    _G.SpinAngle = (_G.SpinAngle + (_G.SpinSpeed or 50)) % 360
    local radius = _G.SpinRadius or 6.5
    local rad    = math.rad(_G.SpinAngle)
    local pos    = targetPart.Position + Vector3.new(math.cos(rad)*radius, offset, math.sin(rad)*radius)
    return CFrame.new(pos, targetPart.Position)
end

function GetFarmOffset()
    local offset = _G.SpinHeightMelee or 14
    local tool   = plr.Character and plr.Character:FindFirstChildOfClass("Tool")
    if tool and tool.ToolTip == "Blox Fruit" then
        offset = _G.SpinHeightFruit or 12
    end
    return offset
end

function DisableOtherFarms(except)
    if except ~= "Level"  then _G.Level          = false end
    if except ~= "Bone"   then _G.AutoFarm_Bone  = false end
    if except ~= "Near"   then _G.AutoFarmNear   = false end
    if except ~= "Island" then _G.AutoFarmIsland = false end
    _G.ActiveFarm = except
end

-- ============================================================
-- SECTION 6: WEAPON & ATTACK SYSTEM
-- ============================================================
EquipWeapon = function(text)
    if not text then return end
    if plr.Backpack:FindFirstChild(text) then
        plr.Character.Humanoid:EquipTool(plr.Backpack:FindFirstChild(text))
    end
end

weaponSc = function(weapon)
    for _,v in pairs(plr.Backpack:GetChildren()) do
        if v:IsA("Tool") then
            if v.ToolTip == weapon then EquipWeapon(v.Name) end
        end
    end
end

local _vu = game:GetService("VirtualUser")
local Attack = {}
Attack.__index = Attack

Attack.Alive = function(model)
    if not model then return end
    local Humanoid = model:FindFirstChild("Humanoid")
    return Humanoid and Humanoid.Health > 0
end
Attack.Pos  = function(model,dist) return (Root.Position - model.Position).Magnitude <= dist end
Attack.Dist = function(model,dist) return (Root.Position - model:FindFirstChild("HumanoidRootPart").Position).Magnitude <= dist end
Attack.DistH= function(model,dist) return (Root.Position - model:FindFirstChild("HumanoidRootPart").Position).Magnitude > dist end

Attack.Click = function()
    pcall(function()
        _vu:CaptureController()
        _vu:Button1Down(Vector2.new(1280,672))
        _vu:Button1Up(Vector2.new(1280,672))
    end)
end

Attack.GetWeapon = function()
    if _G.SelectWeapon and (plr.Backpack:FindFirstChild(_G.SelectWeapon) or (plr.Character and plr.Character:FindFirstChild(_G.SelectWeapon))) then
        return _G.SelectWeapon
    end
    local char = plr.Character
    if char then
        local eq = char:FindFirstChildOfClass("Tool")
        if eq then return eq.Name end
    end
    for _,v in ipairs(plr.Backpack:GetChildren()) do
        if v:IsA("Tool") and (v.ToolTip=="Melee" or v.ToolTip=="Sword" or v.ToolTip=="Blox Fruit" or v.ToolTip=="Gun") then
            return v.Name
        end
    end
    return nil
end

-- ============================================================
-- SECTION 7: BRING ENEMY / KILL SYSTEM
-- ============================================================
BringEnemy = function(Mon)
    if not _B then return end
    if not Mon then
        local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local closestDist = math.huge
        for _,enemy in ipairs(workspace.Enemies:GetChildren()) do
            local hum  = enemy:FindFirstChildOfClass("Humanoid")
            local root = enemy:FindFirstChild("HumanoidRootPart")
            if hum and root and hum.Health > 0 then
                local dist = (root.Position - hrp.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    Mon = enemy
                end
            end
        end
        if not Mon then return end
    end
    local AreaMob = false
    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(plr, "SimulationRadius", math.huge)
        end
        local targetPos = Mon.HumanoidRootPart.Position
        for _,v in ipairs(workspace.Enemies:GetChildren()) do
            if v ~= Mon then
                local hum  = v:FindFirstChildOfClass("Humanoid")
                local root = v:FindFirstChild("HumanoidRootPart")
                if hum and root and hum.Health > 0 and v.Name == Mon.Name then
                    local distance = (root.Position - targetPos).Magnitude
                    if distance <= 3000 then
                        local bv = root:FindFirstChild("BodyVelocity")
                        if not bv then
                            bv = Instance.new("BodyVelocity")
                            bv.Name = "BodyVelocity"
                            bv.MaxForce = Vector3.new(1e9,1e9,1e9)
                            bv.Velocity = Vector3.zero
                            bv.Parent = root
                        end
                        if distance <= 10 then AreaMob = true end
                        if not AreaMob then
                            root.CFrame = CFrame.new(targetPos)
                        end
                    end
                end
            end
        end
    end)
end

Attack.Kill = function(model, Succes)
    if not model then return end
    if not model.Parent then return end
    if not model:FindFirstChild("HumanoidRootPart") or not model:FindFirstChild("Humanoid") then return end
    if model.Humanoid.Health <= 0 then return end

    if not model:GetAttribute("Locked") then
        model:SetAttribute("Locked", model.HumanoidRootPart.CFrame)
    end
    local PosMon      = model:GetAttribute("Locked").Position
    local targetName  = model.Name
    local BoneMobs    = {["Reborn Skeleton"]=true,["Living Zombie"]=true,["Demonic Soul"]=true,["Possessed Mummy"]=true,["Posessed Mummy"]=true}
    local isBone      = BoneMobs[targetName] == true

    while model.Parent and model:FindFirstChild("Humanoid") and model.Humanoid.Health > 0 do
        if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") or not plr.Character:FindFirstChild("Humanoid") then
            task.wait(0.3); break
        end
        if plr.Character.Humanoid.Health <= 0 then task.wait(0.5); break end
        if isBone then
            if not _G.AutoFarm_Bone then break end
            if _G.ActiveFarm and _G.ActiveFarm ~= "Bone" then break end
        else
            if _G.ActiveFarm == "Bone" and not isBone then break end
            if type(Succes) == "boolean" and not Succes then break end
        end

        local current  = nil
        local minDist  = math.huge
        for _,e in ipairs(workspace.Enemies:GetChildren()) do
            if e.Name == targetName and e:FindFirstChild("Humanoid") and e.Humanoid.Health > 0 and e:FindFirstChild("HumanoidRootPart") then
                local d = (e.HumanoidRootPart.Position - PosMon).Magnitude
                if d <= 450 and d < minDist then
                    minDist  = d
                    current  = e
                end
            end
        end
        if not current then break end

        pcall(function() BringEnemy(current) end)
        EquipWeapon(Attack.GetWeapon())

        local offset      = GetFarmOffset()
        local isDoughKing = (targetName == "Dough King" or targetName == "Cake Prince")
        local isFastMob   = isBone or isDoughKing

        pcall(function()
            if isFastMob then
                _tpFast(GetSpinCFrame(current.HumanoidRootPart, offset))
            else
                _tp(GetSpinCFrame(current.HumanoidRootPart, offset))
            end
        end)
        Attack.Click()
        task.wait(0.01)
    end
end

Attack.Kill2    = Attack.Kill
Attack.KillSea  = Attack.Kill

-- ============================================================
-- SECTION 8: UTILITY FUNCTIONS
-- ============================================================
GetBP = function(v)
    return plr.Backpack:FindFirstChild(v) or plr.Character:FindFirstChild(v)
end

GetIn = function(Name)
    for _,v1 in pairs(replicated.Remotes.CommF_:InvokeServer("getInventory")) do
        if type(v1) == "table" then
            if v1.Name == Name or plr.Character:FindFirstChild(Name) or plr.Backpack:FindFirstChild(Name) then
                return true
            end
        end
    end
    return false
end

GetM = function(Name)
    for _,tab in pairs(replicated.Remotes.CommF_:InvokeServer("getInventory")) do
        if type(tab) == "table" then
            if tab.Type == "Material" then
                if tab.Name == Name then return tab.Count end
            end
        end
    end
    return 0
end

GetWP = function(nametool)
    for _,v4 in pairs(replicated.Remotes.CommF_:InvokeServer("getInventory")) do
        if type(v4) == "table" then
            if v4.Type == "Sword" then
                if v4.Name == nametool or plr.Character:FindFirstChild(nametool) or plr.Backpack:FindFirstChild(nametool) then
                    return true
                end
            end
        end
    end
    return false
end

checkinventory = function(v)
    if v then
        for _,vl in pairs(replicated.Remotes.CommF_:InvokeServer("getInventory")) do
            if vl.Name == v then return true end
        end
    end
    return false
end

CheckLegendaryItems = function()
    local function CheckItem(ITEM_NAME)
        for _,v in next, plr.Backpack:GetChildren() do
            if v:IsA("Tool") and (v.Name==ITEM_NAME or string.find(v.Name,ITEM_NAME)) then return v end
        end
        for _,v in next, plr.Character:GetChildren() do
            if v:IsA("Tool") and (v.Name==ITEM_NAME or string.find(v.Name,ITEM_NAME)) then return v end
        end
    end
    if CheckItem("God's Chalice") or CheckItem("Fist of Darkness") or CheckItem("Sweet Chalice") or CheckItem("Hallow Essence") or CheckItem("Flower1") then
        return true
    end
    return false
end

statsSetings = function(Num, value)
    local statMap = {
        Melee   = "Melee",
        Defense = "Defense",
        Sword   = "Sword",
        Gun     = "Gun",
        Devil   = "Demon Fruit"
    }
    if statMap[Num] and plr.Data.Points.Value ~= 0 then
        replicated.Remotes.CommF_:InvokeServer("AddPoint", statMap[Num], value)
    end
end

Useskills = function(ToolTipType, KeyChar)
    local char = plr.Character
    if not char then return end
    for _,v in pairs(char:GetChildren()) do
        if v:IsA("Tool") and v.ToolTip == ToolTipType then
            if v:FindFirstChild(KeyChar) then
                pcall(function() v[KeyChar]:FireServer() end)
            end
        end
    end
end

collectFruits = function(Succes)
    if Succes then
        local Character = plr.Character
        for _,v1 in pairs(workspace:GetChildren()) do
            if string.find(v1.Name,"Fruit") then
                v1.Handle.CFrame = Character.HumanoidRootPart.CFrame
            end
        end
    end
end

UpdStFruit = function()
    for _,x in next, plr.Backpack:GetChildren() do
        local StoreFruit = x:FindFirstChild("EatRemote",true)
        if StoreFruit then
            replicated.Remotes.CommF_:InvokeServer("StoreFruit", StoreFruit.Parent:GetAttribute("OriginalName"), plr.Backpack:FindFirstChild(x.Name))
        end
    end
end

DropFruits = function()
    for _,v3 in next, plr.Backpack:GetChildren() do
        if string.find(v3.Name,"Fruit") then
            EquipWeapon(v3.Name); wait(0.1)
            if plr.PlayerGui.Main.Dialogue.Visible == true then plr.PlayerGui.Main.Dialogue.Visible = false end
            EquipWeapon(v3.Name)
            plr.Character:FindFirstChild(v3.Name).EatRemote:InvokeServer("Drop")
        end
    end
    for _,b2 in pairs(plr.Character:GetChildren()) do
        if string.find(b2.Name,"Fruit") then
            EquipWeapon(b2.Name); wait(0.1)
            if plr.PlayerGui.Main.Dialogue.Visible == true then plr.PlayerGui.Main.Dialogue.Visible = false end
            EquipWeapon(b2.Name)
            plr.Character:FindFirstChild(b2.Name).EatRemote:InvokeServer("Drop")
        end
    end
end

Hop = function()
    pcall(function()
        for count = math.random(1, math.random(40,75)), 100 do
            local remote = replicated.__ServerBrowser:InvokeServer(count)
            for _,v in next, remote do
                if tonumber(v["Count"]) < 12 then TeleportService:TeleportToPlaceInstance(game.PlaceId, _) end
            end
        end
    end)
end

GetConnectionEnemies = function(NameOrTable)
    for _,v in pairs(workspace.Enemies:GetChildren()) do
        if type(NameOrTable) == "table" then
            if table.find(NameOrTable, v.Name) and Attack.Alive(v) then return v end
        else
            if v.Name == NameOrTable and Attack.Alive(v) then return v end
        end
    end
    return nil
end

IsInSubmergedIsland = function()
    local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    return hrp.Position.Y < -500
end

-- ============================================================
-- SECTION 9: QUEST SYSTEM
-- ============================================================
local QuestPositions = {
    Sea1 = {
        [1] = {Monster="Monkeys",     NPC=CFrame.new(-1130,8,600),      Level=5},
        [2] = {Monster="Gorilla",     NPC=CFrame.new(-1580,35,155),     Level=15},
        [3] = {Monster="Pirate",      NPC=CFrame.new(-1140,15,4300),    Level=30},
        [4] = {Monster="Brute",       NPC=CFrame.new(-1200,15,4100),    Level=50},
        [5] = {Monster="Desert Bandit",NPC=CFrame.new(-1040,22,1800),   Level=90},
    },
}

local function GetQuests()
    local level = 0
    pcall(function() level = plr.Data.Level.Value end)
    local result = {}
    pcall(function()
        result = replicated.Remotes.CommF_:InvokeServer("getQuestData") or {}
    end)
    return result
end

local function GetQuestPoint()
    local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local best  = math.huge
    local point = nil
    pcall(function()
        for _,sp in pairs(workspace["_WorldOrigin"].EnemySpawns:GetChildren()) do
            local d = (sp.Position - hrp.Position).Magnitude
            if d < best then best = d; point = sp.CFrame end
        end
    end)
    return point
end

QuestNeta = function()
    local questData = GetQuests()
    return {
        [1] = questData.Mob,
        [2] = questData.ID,
        [3] = questData.NameQuest,
        [4] = questData.LevelReq,
        [5] = questData.Mob,
        [6] = GetQuestPoint()
    }
end

-- Boss Quest Data
QuestB = function()
    if World1 then
        local bossData = {
            ["The Gorilla King"] = {Qname="JungleQuest",     Qdata=3, PosQ=CFrame.new(-1601,36,153),   PosB=CFrame.new(-1088,8,-488)},
            ["Bobby"]            = {Qname="BuggyQuest1",     Qdata=3, PosQ=CFrame.new(-1140,4,3827),   PosB=CFrame.new(-1087,46,4040)},
            ["Vice Admiral"]     = {Qname="MarineQuest2",    Qdata=2, PosQ=CFrame.new(-5036,28,4324),  PosB=CFrame.new(-5006,88,4353)},
            ["Warden"]           = {Qname="ImpelQuest",      Qdata=1, PosQ=CFrame.new(5191,2,686),     PosB=CFrame.new(5278,2,944)},
            ["Chief Warden"]     = {Qname="ImpelQuest",      Qdata=2, PosQ=CFrame.new(5191,2,686),     PosB=CFrame.new(5206,0,814)},
            ["Swan"]             = {Qname="ImpelQuest",      Qdata=3, PosQ=CFrame.new(5191,2,686),     PosB=CFrame.new(5325,7,719)},
            ["Magma Admiral"]    = {Qname="MagmaQuest",      Qdata=3, PosQ=CFrame.new(-5314,12,8517),  PosB=CFrame.new(-5765,82,8718)},
            ["Fishman Lord"]     = {Qname="FishmanQuest",    Qdata=3, PosQ=CFrame.new(61122,18,1569),  PosB=CFrame.new(61260,30,1193)},
            ["Wysper"]           = {Qname="SkyExp1Quest",    Qdata=3, PosQ=CFrame.new(-7861,5545,-379), PosB=CFrame.new(-7866,5576,-546)},
            ["Thunder God"]      = {Qname="SkyExp2Quest",    Qdata=3, PosQ=CFrame.new(-7903,5635,-1410),PosB=CFrame.new(-7994,5761,-2088)},
            ["Cyborg"]           = {Qname="FountainQuest",   Qdata=3, PosQ=CFrame.new(5258,38,4050),   PosB=CFrame.new(6094,73,3825)},
        }
        local data = _G.FindBoss and bossData[_G.FindBoss]
        if data then
            bMon     = _G.FindBoss
            Qname    = data.Qname
            Qdata    = data.Qdata
            PosQBoss = data.PosQ
            PosB     = data.PosB
        end
    end
    if World2 then
        local bossData2 = {
            ["Diamond"]              = {Qname="Area1Quest",     Qdata=3, PosQ=CFrame.new(-427,73,1835),   PosB=CFrame.new(-1576,198,13)},
            ["Jeremy"]               = {Qname="Area2Quest",     Qdata=3, PosQ=CFrame.new(636,73,918),     PosB=CFrame.new(2006,448,853)},
            ["Orbitus"]              = {Qname="MarineQuest3",   Qdata=3, PosQ=CFrame.new(-2441,73,-3217), PosB=CFrame.new(-2172,103,-4015)},
            ["Smoke Admiral"]        = {Qname="IceSideQuest",   Qdata=3, PosQ=CFrame.new(-5429,15,-5297), PosB=CFrame.new(-5275,20,-5260)},
            ["Awakened Ice Admiral"] = {Qname="FrostQuest",     Qdata=3, PosQ=CFrame.new(5668,28,-6483),  PosB=CFrame.new(6403,340,-6894)},
            ["Tide Keeper"]          = {Qname="ForgottenQuest", Qdata=3, PosQ=CFrame.new(-3053,237,-10145),PosB=CFrame.new(-3795,105,-11421)},
        }
        local data = _G.FindBoss and bossData2[_G.FindBoss]
        if data then
            bMon     = _G.FindBoss
            Qname    = data.Qname
            Qdata    = data.Qdata
            PosQBoss = data.PosQ
            PosB     = data.PosB
        end
    end
    if World3 then
        local bossData3 = {
            ["Stone"]           = {Qname="PortQuest",    Qdata=3, PosQ=CFrame.new(-2913,73,-7393), PosB=CFrame.new(-2911,79,-7458)},
            ["Hydra Leader"]    = {Qname="HydraQuest",   Qdata=3, PosQ=CFrame.new(-7330,52,-3365), PosB=CFrame.new(-7296,103,-4008)},
            ["Kilo Admiral"]    = {Qname="KiloQuest",    Qdata=3, PosQ=CFrame.new(-15310,4,2228),  PosB=CFrame.new(-15322,5,2113)},
            ["Dough King"]      = {Qname="DoughQuest",   Qdata=3, PosQ=CFrame.new(591,68,-12040),  PosB=CFrame.new(629,55,-12133)},
            ["Soul Reaper"]     = {Qdata=nil, PosQ=CFrame.new(-8768,319,6248), PosB=CFrame.new(-8768,319,6248)},
        }
        local data = _G.FindBoss and bossData3[_G.FindBoss]
        if data then
            bMon     = _G.FindBoss
            Qname    = data.Qname
            Qdata    = data.Qdata
            PosQBoss = data.PosQ
            PosB     = data.PosB
        end
    end
end

-- ============================================================
-- SECTION 10: NOCLIP / POSITION LOCK SYSTEM
-- ============================================================
local block = Instance.new("Part", workspace)
block.Size         = Vector3.new(1,1,1)
block.Name         = "SovereignAnchor"
block.Anchored     = true
block.CanCollide   = false
block.CanTouch     = false
block.Transparency = 1

local blockfind = workspace:FindFirstChild(block.Name)
if blockfind and blockfind ~= block then blockfind:Destroy() end

task.spawn(function()
    while task.wait() do
        if block and block.Parent == workspace then
            if shouldTween then getgenv().OnFarm = true else getgenv().OnFarm = false end
        else
            getgenv().OnFarm = false
        end
    end
end)

task.spawn(function()
    local a = plr
    repeat task.wait() until a.Character and a.Character.PrimaryPart
    block.CFrame = a.Character.PrimaryPart.CFrame
    while task.wait() do
        pcall(function()
            if getgenv().OnFarm then
                if block and block.Parent == workspace then
                    local b = a.Character and a.Character.PrimaryPart
                    if b and (b.Position - block.Position).Magnitude <= 200 then
                        b.CFrame = block.CFrame
                    else
                        block.CFrame = b.CFrame
                    end
                end
                local c = a.Character
                if c then
                    for _,e in pairs(c:GetChildren()) do
                        if e:IsA("BasePart") then e.CanCollide = false end
                    end
                end
            else
                local c = a.Character
                if c then
                    for _,e in pairs(c:GetChildren()) do
                        if e:IsA("BasePart") then e.CanCollide = true end
                    end
                end
            end
        end)
    end
end)

-- ============================================================
-- SECTION 11: SERVER HOP SYSTEM
-- ============================================================
local request_fn = (syn and syn.request) or http_request or request or (fluxus and fluxus.request) or (http and http.request)
local isTeleporting = false
_G.VisitedServers   = _G.VisitedServers or {}

TeleportService.TeleportInitFailed:Connect(function(player)
    if player == plr then isTeleporting = false end
end)

local function StartHopping(ApiUrl, globalVar)
    task.spawn(function()
        local visited = _G.VisitedServers
        while getgenv()[globalVar] do
            if isTeleporting then task.wait(0.1); continue end
            local ok, res = pcall(function()
                return request_fn({
                    Url     = ApiUrl,
                    Method  = "GET",
                    Headers = {["User-Agent"] = "Roblox"}
                })
            end)
            if ok and res and res.Body then
                local success, body = pcall(function() return HttpService:JSONDecode(res.Body) end)
                local foundJobs = {}
                if success and body then
                    local server_list = body.all_servers or body.moon_data or body.servers or body
                    if type(server_list) == "table" then
                        for _,v in pairs(server_list) do
                            local job = tostring(type(v)=="table" and (v.jobid or v.jobId or v.id or "") or v)
                            if #job > 10 and job ~= game.JobId and not visited[job] then
                                table.insert(foundJobs, job)
                            end
                        end
                    end
                end
                if #foundJobs > 0 then
                    isTeleporting = true
                    local TeleportRemote = replicated:FindFirstChild("__ServerBrowser")
                    for _,selected in ipairs(foundJobs) do
                        if not getgenv()[globalVar] then break end
                        visited[selected] = true
                        task.spawn(function()
                            if TeleportRemote then
                                pcall(function() TeleportRemote:InvokeServer("teleport", selected) end)
                            else
                                pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, selected, plr) end)
                            end
                        end)
                        task.wait(0.2)
                    end
                    isTeleporting = false
                end
            end
            task.wait(0.05)
        end
    end)
end

-- ============================================================
-- SECTION 12: ISLAND DATA
-- ============================================================
local Sea1_Islands = {
    ["Pirates"]          = {CFrame=CFrame.new(-1140,15,4300),    Mobs={"Pirate","Brute"}},
    ["Marine"]           = {CFrame=CFrame.new(-5036,28,4324),    Mobs={"Marine","Marine Lieutenant"}},
    ["Jungle"]           = {CFrame=CFrame.new(-1580,35,155),     Mobs={"Monkey","Gorilla","The Gorilla King"}},
    ["Desert"]           = {CFrame=CFrame.new(-1040,22,1800),    Mobs={"Desert Bandit","Desert Officer"}},
    ["Frozen Village"]   = {CFrame=CFrame.new(1386,87,-1298),    Mobs={"Snow Bandits","Yeti"}},
    ["Marine Fortress"]  = {CFrame=CFrame.new(-5036,28,4324),    Mobs={"Marine Captain","Marine Rear Admiral"}},
    ["Skylands Lower"]   = {CFrame=CFrame.new(-7861,5545,-379),  Mobs={"Sky Bandit","Shanda"}},
    ["Prison"]           = {CFrame=CFrame.new(5278,2,944),       Mobs={"Prisoner","Dangerous Prisoner"}},
    ["Colosseum"]        = {CFrame=CFrame.new(-1458,29,-50),     Mobs={"Toga Warrior","Gladiator"}},
    ["Magma Village"]    = {CFrame=CFrame.new(-5765,82,8718),    Mobs={"Military Soldier","Military Spy"}},
    ["Underwater City"]  = {CFrame=CFrame.new(61260,30,1193),    Mobs={"Fishman Warrior","Fishman Commando"}},
    ["Skylands Upper"]   = {CFrame=CFrame.new(-7994,5761,-2088), Mobs={"Royal Squad","Royal Soldier"}},
}

local Sea2_Islands = {
    ["Kingdom of Rose"]  = {CFrame=CFrame.new(-1576,198,13),      Mobs={"Galley Pirate","Galley Captain"}},
    ["Green Zone"]       = {CFrame=CFrame.new(2006,448,853),      Mobs={"Sabertooth","Jungle Pirate"}},
    ["Graveyard Island"] = {CFrame=CFrame.new(-6033,7,-1317),     Mobs={"Zombie","Vampire","Graveyard Wraith"}},
    ["Snow Mountain"]    = {CFrame=CFrame.new(-5429,15,-5297),    Mobs={"Snow Trooper","Winter Warrior","Snow Lurker"}},
    ["Hot and Cold"]     = {CFrame=CFrame.new(5668,28,-6483),     Mobs={"Magma Ninja","Lava Pirate","Snow Lurker","Arctic Warrior"}},
    ["Cursed Ship"]      = {CFrame=CFrame.new(923,126,33159),     Mobs={"Ship Deckhand","Ship Engineer","Ship Steward","Ship Officer"}},
    ["Ice Castle"]       = {CFrame=CFrame.new(6403,340,-6894),    Mobs={"Arctic Warrior","Snow Lurker","Hidden Key"}},
    ["Forgotten Island"] = {CFrame=CFrame.new(-3795,105,-11421),  Mobs={"Water Fighter","Tide Keeper"}},
}

local Sea3_Islands = {
    ["Port Town"]       = {CFrame=CFrame.new(-2911,79,-7458),       Mobs={"Forest Pirate","Jungle Pirate","Musketeer Pirate"}},
    ["Hydra Island"]    = {CFrame=CFrame.new(-7296,103,-4008),      Mobs={"Fishman Raider","Fishman Captain"}},
    ["Great Tree"]      = {CFrame=CFrame.new(7021,55,-730),         Mobs={"Dragon Crew Warrior","Dragon Crew Archer"}},
    ["Floating Turtle"] = {CFrame=CFrame.new(4692,797,858),         Mobs={"Female Islander","Venomous Assailant"}},
    ["Haunted Castle"]  = {CFrame=CFrame.new(-8764,142,5963),       Mobs={"Reborn Skeleton","Living Zombie","Demonic Soul","Posessed Mummy"}},
    ["Sea of Treats"]   = {CFrame=CFrame.new(-1145,13,-14450),      Mobs={"Peanut Scout","Peanut President","Cookie Crafter","Cake Guard","Cocoa Warrior","Chocolate Bar Battler","Sweet Thief","Candy Rebel"}},
    ["Tiki Outpost"]    = {CFrame=CFrame.new(-16200,90,-17300),     Mobs={"Isle Outlaw","Island Boy","Sun-kissed Warrior","Isle Champion"}},
    ["Submerged Island"]= {CFrame=CFrame.new(-3200,-10,-10000),     Mobs={"Reef Bandit","Coral Pirate","Sea Chanter","Ocean Prophet","High Disciple","Grand Devotee"}},
}

local IslandData
if World1 then      IslandData = Sea1_Islands
elseif World2 then  IslandData = Sea2_Islands
elseif World3 then  IslandData = Sea3_Islands
end

-- ============================================================
-- SECTION 13: LOAD UI LIBRARY (Charcoal / Rayfield)
-- ============================================================
local redzlib
do
    -- Try primary URL first, then fallback
    local urls = {
        "https://raw.githubusercontent.com/tranvanhung040419826-ui/Charcoal-UI/refs/heads/main/8469605765224156.lua.txt",
        "https://raw.githubusercontent.com/shlexware/Orion/main/source",
    }
    for _,url in ipairs(urls) do
        for i = 1, 3 do
            local ok, res = pcall(function()
                return loadstring(game:HttpGet(url))()
            end)
            if ok and res then
                redzlib = res
                break
            end
            task.wait(1)
        end
        if redzlib then break end
    end

    if not redzlib then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title    = "Sovereign Hub",
            Text     = "Failed to load UI library. Please retry.",
            Duration = 10
        })
        return
    end
end

-- ============================================================
-- SECTION 14: CREATE WINDOW & TABS
-- ============================================================
local Window = redzlib:MakeWindow({
    Title      = "Sovereign Hub : Blox Fruits",
    SubTitle   = "The Crown of Scripts",
    SaveFolder = "SovereignHub.json"
})

-- Mobile/Keyboard minimizer
local Minimizer = Window:NewMinimizer({
    KeyCode = Enum.KeyCode.LeftControl
})
local MobileButton = Minimizer:CreateMobileMinimizer({
    Image                = "rbxassetid://127729348105692",
    BackgroundTransparency = 1,
    Size                 = UDim2.new(0,55,0,55)
})

local Tabs = {
    Info       = Window:MakeTab({Title="Info & Status",      Icon="rbxassetid://6031302934"}),
    Main       = Window:MakeTab({Title="Farming",            Icon="rbxassetid://7733960981"}),
    Hop        = Window:MakeTab({Title="Server Hop",         Icon="locate"}),
    Settings   = Window:MakeTab({Title="Settings",           Icon="rbxassetid://7734053495"}),
    Fish       = Window:MakeTab({Title="Fishing",            Icon="rbxassetid://6022668898"}),
    Quests     = Window:MakeTab({Title="Quests & Items",     Icon="rbxassetid://13075622619"}),
    SeaEvent   = Window:MakeTab({Title="Sea Events",         Icon="rbxassetid://7734068321"}),
    Race       = Window:MakeTab({Title="Mirage & Race",      Icon="rbxassetid://11162889532"}),
    Volcanic   = Window:MakeTab({Title="Volcano Event",      Icon="rbxassetid://6031075938"}),
    Esp        = Window:MakeTab({Title="Stats & ESP",        Icon="rbxassetid://7040410130"}),
    Raids      = Window:MakeTab({Title="Fruits & Raids",     Icon="rbxassetid://11155986081"}),
    Combat     = Window:MakeTab({Title="Local Player",       Icon="rbxassetid://13075651575"}),
    Travel     = Window:MakeTab({Title="Teleport",           Icon="rbxassetid://7734056608"}),
    Shop       = Window:MakeTab({Title="Shopping",           Icon="rbxassetid://6031265976"}),
    Misc       = Window:MakeTab({Title="Miscellaneous",      Icon="rbxassetid://10709783577"})
}

-- ============================================================
-- SECTION 15: AUTO-SAVE CONFIG SYSTEM
-- ============================================================
local ConfigFile = "SovereignHub_AutoSave.json"
local SovConfig  = {}

if isfile and isfile(ConfigFile) then
    pcall(function() SovConfig = HttpService:JSONDecode(readfile(ConfigFile)) end)
end

local function SaveConfig()
    if writefile then
        pcall(function() writefile(ConfigFile, HttpService:JSONEncode(SovConfig)) end)
    end
end

for TabName, Tab in pairs(Tabs) do
    if TabName ~= "Hop" and Tab.AddToggle then
        local OldToggle = Tab.AddToggle
        Tab.AddToggle = function(self, data)
            local name = data.Name or "Unnamed_Toggle"
            if SovConfig[name] ~= nil then data.Default = SovConfig[name] end
            local oldCb = data.Callback
            data.Callback = function(val)
                SovConfig[name] = val
                SaveConfig()
                if oldCb then pcall(oldCb, val) end
            end
            local toggle = OldToggle(self, data)
            if SovConfig[name] ~= nil and oldCb then
                task.spawn(function() pcall(oldCb, SovConfig[name]) end)
            end
            return toggle
        end
    end
    if TabName ~= "Hop" and Tab.AddDropdown then
        local OldDrop = Tab.AddDropdown
        Tab.AddDropdown = function(self, data)
            local name = data.Name or "Unnamed_Dropdown"
            if SovConfig[name] ~= nil then data.Default = SovConfig[name] end
            local oldCb = data.Callback
            data.Callback = function(val)
                SovConfig[name] = val
                SaveConfig()
                if oldCb then pcall(oldCb, val) end
            end
            return OldDrop(self, data)
        end
    end
end

-- ============================================================
-- SECTION 16: INFO TAB
-- ============================================================
Tabs.Info:AddSection("Sovereign Hub Information")

Tabs.Info:AddParagraph("Sovereign Hub v1.0", "The Crown of Scripts — Built for Blox Fruits. All features from Vantablack, remastered.")

local PlayerStatsPara = Tabs.Info:AddParagraph("Player Stats", "Loading...")
local ServerStatsPara = Tabs.Info:AddParagraph("Server Info", "Loading...")
local BossStatsPara   = Tabs.Info:AddParagraph("Boss Status",  "Scanning...")

task.spawn(function()
    while task.wait(2) do
        pcall(function()
            local level  = plr.Data.Level.Value
            local beli   = plr.Data.Beli.Value
            local race   = tostring(pcall(function() return plr.Data.Race.Value end) and plr.Data.Race.Value or "Unknown")
            local fruit  = "None"
            pcall(function()
                for _,v in pairs(plr.Backpack:GetChildren()) do
                    if v:IsA("Tool") and v.ToolTip == "Blox Fruit" then fruit = v.Name end
                end
                for _,v in pairs(plr.Character:GetChildren()) do
                    if v:IsA("Tool") and v.ToolTip == "Blox Fruit" then fruit = v.Name end
                end
            end)
            local statsText = string.format(
                "Level: %d  |  Beli: %s\nRace: %s  |  Fruit: %s\nTeam: %s",
                level,
                tostring(beli),
                tostring(pcall(function() return plr.Data.Race.Value end) and plr.Data.Race.Value or "?"),
                fruit,
                tostring(plr.Team and plr.Team.Name or "None")
            )
            PlayerStatsPara:SetDesc(statsText)

            local ping    = Stats.PingInstances and Stats.PingInstances.Value or 0
            local plrCount= #ply:GetPlayers()
            local world   = World1 and "Sea 1" or (World2 and "Sea 2" or (World3 and "Sea 3" or "Unknown"))
            ServerStatsPara:SetDesc(string.format("World: %s  |  Players: %d\nPing: %dms", world, plrCount, ping))
        end)
    end
end)

-- Boss checkers
task.spawn(function()
    while task.wait(5) do
        pcall(function()
            local bossList = {}
            for _,v in pairs(workspace.Enemies:GetChildren()) do
                if table.find(BossList, v.Name) and Attack.Alive(v) then
                    table.insert(bossList, v.Name)
                end
            end
            local text = #bossList > 0 and table.concat(bossList,", ") or "No boss detected"
            BossStatsPara:SetDesc("Active Bosses: " .. text)
        end)
    end
end)

Tabs.Info:AddSection("Discord & Community")
Tabs.Info:AddDiscordInvite({
    Title       = "Sovereign Hub | Free",
    Description = "Join our community for updates and support",
    Banner      = "rbxassetid://127729348105692",
    Logo        = "rbxassetid://127729348105692",
    Invite      = "https://discord.gg/sovereignhub",
})

-- ============================================================
-- SECTION 17: FARMING TAB — MAIN
-- ============================================================
Tabs.Main:AddSection("Auto Farm Level")

local AutoLevelToggle = Tabs.Main:AddToggle({
    Name        = "Auto Farm Level",
    Description = "Detects your level and auto-accepts quests, then farms the correct mobs",
    Default     = false,
    Callback    = function(Value)
        _G.Level = Value
        if Value then DisableOtherFarms("Level") end
    end
})

local teleporting       = false
local alreadyTeleported = false

task.spawn(function()
    while task.wait(Sec) do
        pcall(function()
            if _G.Level then
                if not Root then return end
                local level     = plr.Data.Level.Value
                local inSub     = IsInSubmergedIsland()
                local questUI   = plr.PlayerGui.Main.Quest
                local QuestTitle= questUI.Visible and questUI.Container.QuestTitle.Title.Text or ""

                if level >= 2600 and not inSub and not teleporting and not alreadyTeleported then
                    teleporting = true
                    local npcPos = CFrame.new(-16269,25,1373)
                    local attempts = 0
                    repeat
                        task.wait(Sec)
                        _tp(npcPos)
                        attempts = attempts + 1
                    until not _G.Level or (Root.Position - npcPos.Position).Magnitude <= 8 or attempts > 20
                    if not _G.Level then teleporting = false; return end
                    task.wait(1)
                    pcall(function()
                        replicated.Modules.Net:FindFirstChild("RF/SubmarineWorkerSpeak"):InvokeServer("TravelToSubmergedIsland")
                    end)
                    local timeout = tick()
                    repeat
                        task.wait(0.5)
                        if IsInSubmergedIsland() or (Root.Position - npcPos.Position).Magnitude > 50 then break end
                    until not _G.Level or tick()-timeout > 15
                    task.wait(2)
                    alreadyTeleported = true
                    teleporting = false

                elseif inSub or level < 2600 then
                    alreadyTeleported = true
                    teleporting = false
                    local questData = QuestNeta()
                    if not questData or not questData[1] then task.wait(1); return end
                    local enemyName = questData[1]

                    if not questUI.Visible then
                        local questPos = questData[6]
                        if questPos then _tp(questPos); task.wait(0.6) end
                        pcall(function()
                            replicated.Remotes.CommF_:InvokeServer("StartQuest", questData[3], questData[2])
                        end)
                        task.wait(0.6)
                    end

                    local target  = nil
                    local myPos   = Root.Position
                    local best    = math.huge
                    for _,v in pairs(workspace.Enemies:GetChildren()) do
                        if v.Name == enemyName and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                            local d = (v.HumanoidRootPart.Position - myPos).Magnitude
                            if d < best then best = d; target = v end
                        end
                    end

                    if target then
                        repeat
                            task.wait(Sec)
                            if target:FindFirstChild("HumanoidRootPart") then
                                _tp(GetSpinCFrame(target.HumanoidRootPart, GetFarmOffset()))
                            end
                            Attack.Kill(target, _G.Level)
                        until not _G.Level or not target.Parent or not target:FindFirstChild("Humanoid") or target.Humanoid.Health <= 0
                    else
                        local spawnCF = questData[6]
                        if spawnCF then _tp(spawnCF * CFrame.new(0,25,0)) end
                        task.wait(0.3)
                    end
                end
            else
                teleporting       = false
                alreadyTeleported = false
            end
        end)
    end
end)

-- Auto Farm Nearest
Tabs.Main:AddToggle({
    Name        = "Auto Farm Nearest",
    Description = "Automatically farm the nearest enemy",
    Default     = false,
    Callback    = function(Value)
        _G.AutoFarmNear = Value
        if Value then DisableOtherFarms("Near") end
    end
})
task.spawn(function()
    while task.wait() do
        pcall(function()
            if _G.AutoFarmNear then
                for _,v in pairs(workspace.Enemies:GetChildren()) do
                    if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                        repeat task.wait() Attack.Kill(v, _G.AutoFarmNear) until not _G.AutoFarmNear or not v.Parent or v.Humanoid.Health <= 0
                    end
                end
            end
        end)
    end
end)

-- Auto Farm Bone
Tabs.Main:AddSection("Bone Farm")
Tabs.Main:AddToggle({
    Name        = "Auto Farm Bone [Haunted Castle]",
    Description = "Farm Reborn Skeleton, Living Zombie, Demonic Soul — insane EXP",
    Default     = false,
    Callback    = function(Value)
        _G.AutoFarm_Bone = Value
        if Value then DisableOtherFarms("Bone") end
    end
})
task.spawn(function()
    while task.wait(Sec) do
        pcall(function()
            if _G.AutoFarm_Bone then
                local BoneTargets = {"Reborn Skeleton","Living Zombie","Demonic Soul","Posessed Mummy"}
                for _,v in pairs(workspace.Enemies:GetChildren()) do
                    if table.find(BoneTargets, v.Name) and Attack.Alive(v) then
                        repeat
                            task.wait(Sec)
                            _tpFast(GetSpinCFrame(v.HumanoidRootPart, GetFarmOffset()))
                            Attack.Kill(v, _G.AutoFarm_Bone)
                        until not _G.AutoFarm_Bone or not v.Parent or not Attack.Alive(v)
                    end
                end
            end
        end)
    end
end)

-- Factory Raid
Tabs.Main:AddSection("Raids")
Tabs.Main:AddToggle({
    Name        = "Auto Factory Raid",
    Description = "Automatically farm Factory Raid",
    Default     = false,
    Callback    = function(Value) _G.AutoFactory = Value end
})
task.spawn(function()
    while task.wait(Sec) do
        pcall(function()
            if _G.AutoFactory then
                local v = GetConnectionEnemies("Core")
                if v then
                    repeat
                        task.wait()
                        EquipWeapon(_G.SelectWeapon)
                        _tp(CFrame.new(448,199,-441))
                    until v.Humanoid.Health <= 0 or not _G.AutoFactory
                else
                    _tp(CFrame.new(448,199,-441))
                end
            end
        end)
    end
end)

Tabs.Main:AddToggle({
    Name        = "Auto Pirate Raid",
    Description = "Automatically farm Pirate Castle Raid",
    Default     = false,
    Callback    = function(Value) _G.AutoRaidCastle = Value end
})
task.spawn(function()
    while task.wait(Sec) do
        if _G.AutoRaidCastle then
            pcall(function()
                local CFrameCastleRaid = CFrame.new(-5496,313,-2841)
                if (CFrame.new(-5539,313,-2972).Position - Root.Position).Magnitude <= 500 then
                    for _,v in pairs(workspace.Enemies:GetChildren()) do
                        if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            if (v.HumanoidRootPart.Position - Root.Position).Magnitude <= 2000 then
                                repeat task.wait() Attack.Kill(v,_G.AutoRaidCastle) until not _G.AutoRaidCastle or not v.Parent or v.Humanoid.Health <= 0
                            end
                        end
                    end
                else
                    _tp(CFrameCastleRaid)
                end
            end)
        end
    end
end)

-- Chest Farm
Tabs.Main:AddSection("Chest")
Tabs.Main:AddToggle({
    Name        = "Auto Farm Chest",
    Description = "Teleport to nearest tagged chest",
    Default     = false,
    Callback    = function(Value) _G.AutoFarmChest = Value end
})
task.spawn(function()
    while task.wait(Sec) do
        if _G.AutoFarmChest then
            pcall(function()
                local CollectionService = game:GetService("CollectionService")
                local Chests   = CollectionService:GetTagged("_ChestTagged")
                local Distance = math.huge
                local Nearest  = nil
                local Position = plr.Character:GetPivot().Position
                for _,Chest in ipairs(Chests) do
                    local Magnitude = (Chest:GetPivot().Position - Position).Magnitude
                    if not Chest:GetAttribute("IsDisabled") and Magnitude < Distance then
                        Distance = Magnitude
                        Nearest  = Chest
                    end
                end
                if Nearest then _tp(Nearest:GetPivot()) end
            end)
        end
    end
end)

Tabs.Main:AddToggle({
    Name        = "Stop Items [Legendary]",
    Description = "Stop chest farming when Legendary Item found",
    Default     = true,
    Callback    = function(Value) _G.StopWhenChalice = Value end
})
task.spawn(function()
    while task.wait(0.2) do
        if _G.StopWhenChalice and (_G.AutoFarmChest) then
            pcall(function()
                if GetBP("God's Chalice") or GetBP("Sweet Chalice") or GetBP("Fist of Darkness") or GetBP("Hallow Essence") then
                    _G.AutoFarmChest = false
                end
            end)
        end
    end
end)

-- Berry Farm
Tabs.Main:AddSection("Berry")
Tabs.Main:AddToggle({
    Name        = "Auto Farm Berry",
    Description = "Collect all berry bushes",
    Default     = false,
    Callback    = function(Value) _G.AutoBerry = Value end
})
task.spawn(function()
    while task.wait(Sec) do
        if _G.AutoBerry then
            pcall(function()
                local CollectionService = game:GetService("CollectionService")
                local BerryBush = CollectionService:GetTagged("BerryBush")
                for _,Bush in ipairs(BerryBush) do
                    for _,BerryName in pairs(Bush:GetChildren()) do
                        _tp(BerryName.WorldPivot)
                        pcall(function() fireproximityprompt(BerryName.ProximityPrompt, math.huge) end)
                    end
                end
            end)
        end
    end
end)

-- Island Farm
Tabs.Main:AddSection("Island Farm")
if World1 then
    Tabs.Main:AddDropdown({
        Name     = "Select Island",
        Options  = {"Pirates","Marine","Jungle","Pirate Village","Desert","Frozen Village","Marine Fortress","Skylands Lower","Prison","Colosseum","Magma Village","Underwater City","Skylands Upper"},
        Callback = function(Value) _G.SelectIsland = Value end
    })
elseif World2 then
    Tabs.Main:AddDropdown({
        Name     = "Select Island",
        Options  = {"Kingdom of Rose","Green Zone","Graveyard Island","Snow Mountain","Hot and Cold","Cursed Ship","Ice Castle","Forgotten Island"},
        Callback = function(Value) _G.SelectIsland = Value end
    })
elseif World3 then
    Tabs.Main:AddDropdown({
        Name     = "Select Island",
        Options  = {"Port Town","Hydra Island","Great Tree","Floating Turtle","Haunted Castle","Sea of Treats","Tiki Outpost","Submerged Island"},
        Callback = function(Value) _G.SelectIsland = Value end
    })
end

Tabs.Main:AddToggle({
    Name        = "Auto Farm All Island",
    Description = "Farm all mobs on selected island",
    Default     = false,
    Callback    = function(Value)
        _G.AutoFarmIsland = Value
        if Value then DisableOtherFarms("Island") end
    end
})
task.spawn(function()
    while task.wait(0.2) do
        if not _G.AutoFarmIsland or not _G.SelectIsland or not IslandData then continue end
        local island = IslandData[_G.SelectIsland]
        if not island then continue end
        local MobMap = {}
        for _,name in ipairs(island.Mobs) do MobMap[name] = true end
        local found = false
        for _,v in pairs(workspace.Enemies:GetChildren()) do
            if MobMap[v.Name] and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                found = true
                repeat
                    task.wait()
                    _tp(v.HumanoidRootPart.CFrame * CFrame.new(0,10,0))
                    Attack.Kill(v, true)
                until not _G.AutoFarmIsland or not v.Parent or v.Humanoid.Health <= 0
            end
        end
        if not found then _tp(island.CFrame) end
    end
end)

-- Ectoplasm Farm
Tabs.Main:AddSection("Special Farm")
Tabs.Main:AddToggle({
    Name        = "Auto Farm Ectoplasm",
    Description = "Farm Ship enemies for Ectoplasm",
    Default     = false,
    Callback    = function(Value) _G.AutoEctoplasm = Value end
})
task.spawn(function()
    while task.wait(Sec) do
        pcall(function()
            if _G.AutoEctoplasm then
                local EctoTable = {"Ship Deckhand","Ship Engineer","Ship Steward","Ship Officer","Arctic Warrior"}
                local v = GetConnectionEnemies(EctoTable)
                if Attack.Alive(v) then
                    repeat task.wait() Attack.Kill(v, _G.AutoEctoplasm) until not _G.AutoEctoplasm or not v.Parent or v.Humanoid.Health <= 0
                else
                    pcall(function() replicated.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(923,126,32852)) end)
                end
            end
        end)
    end
end)

-- Elite Hunter
Tabs.Main:AddSection("Elite Hunter")
local Process    = Tabs.Main:AddParagraph("Elite Progress", "")
local EliteHunter= Tabs.Main:AddParagraph("Elite Spawn",   "Status: ❌")

task.spawn(function()
    while task.wait(Sec) do
        pcall(function()
            Process:SetDesc("Progress: " .. replicated.Remotes.CommF_:InvokeServer("EliteHunter","Progress"))
        end)
    end
end)

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            local found = RS:FindFirstChild("Diablo") or RS:FindFirstChild("Deandre") or RS:FindFirstChild("Urban")
                       or workspace.Enemies:FindFirstChild("Diablo") or workspace.Enemies:FindFirstChild("Deandre") or workspace.Enemies:FindFirstChild("Urban")
            EliteHunter:SetDesc("Status: " .. (found and "✅ SPAWNED" or "❌ Not spawned"))
        end)
    end
end)

Tabs.Main:AddToggle({
    Name        = "Auto Farm Elite Hunter",
    Description = "Auto-accept Elite Hunter quest and kill elite boss",
    Default     = false,
    Callback    = function(Value) _G.FarmEliteHunt = Value end
})
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            if not _G.FarmEliteHunt then return end
            local questGui = plr.PlayerGui.Main.Quest
            if not questGui.Visible then
                local result = replicated.Remotes.CommF_:InvokeServer("EliteHunter")
                if result == nil or (type(result)=="string" and string.find(result,"Cooldown")) then
                    task.wait(10); return
                end
                task.wait(1)
            else
                local questTitle = questGui.Container.QuestTitle.Title.Text
                local eliteName  = nil
                for _,name in pairs({"Diablo","Urban","Deandre"}) do
                    if string.find(questTitle,name) then eliteName = name; break end
                end
                if eliteName then
                    local boss = nil
                    for _,v in pairs(workspace.Enemies:GetChildren()) do
                        if v.Name == eliteName and Attack.Alive(v) then boss = v; break end
                    end
                    if boss and boss:FindFirstChild("HumanoidRootPart") then
                        _tp(boss.HumanoidRootPart.CFrame * CFrame.new(0,30,0))
                        repeat
                            task.wait()
                            Attack.Kill(boss, _G.FarmEliteHunt)
                        until not _G.FarmEliteHunt or not boss.Parent or boss.Humanoid.Health <= 0
                    else
                        task.wait(5)
                    end
                else
                    pcall(function() replicated.Remotes.CommF_:InvokeServer("AbandonQuest") end)
                end
            end
        end)
    end
end)

-- Weapon Select
Tabs.Main:AddSection("Weapon Selection")
local weaponOptions = {"Auto Detect"}
for _,v in pairs(plr.Backpack:GetChildren()) do
    if v:IsA("Tool") and (v.ToolTip=="Melee" or v.ToolTip=="Sword" or v.ToolTip=="Blox Fruit" or v.ToolTip=="Gun") then
        table.insert(weaponOptions, v.Name)
    end
end
Tabs.Main:AddDropdown({
    Name     = "Select Weapon",
    Options  = weaponOptions,
    Default  = "Auto Detect",
    Callback = function(Value)
        _G.SelectWeapon = (Value == "Auto Detect") and nil or Value
    end
})

Tabs.Main:AddSlider({
    Name    = "Spin Height (Melee)",
    Min     = 5,
    Max     = 50,
    Default = 14,
    Callback= function(Value) _G.SpinHeightMelee = Value end
})
Tabs.Main:AddSlider({
    Name    = "Spin Height (Fruit)",
    Min     = 5,
    Max     = 50,
    Default = 12,
    Callback= function(Value) _G.SpinHeightFruit = Value end
})
Tabs.Main:AddToggle({
    Name        = "Enable Orbit Mode",
    Description = "Spin around the mob in a circle (more stylish farm)",
    Default     = false,
    Callback    = function(Value) RandomCFrame = Value end
})

-- ============================================================
-- SECTION 18: QUESTS & ITEMS TAB
-- ============================================================
Tabs.Quests:AddSection("Boss Farm")
Tabs.Quests:AddDropdown({
    Name     = "Select Boss",
    Options  = BossList,
    Callback = function(Value) _G.FindBoss = Value end
})
Tabs.Quests:AddToggle({
    Name        = "Auto Farm Boss",
    Description = "Accept quest and farm selected boss",
    Default     = false,
    Callback    = function(Value) _G.AutoBoss = Value end
})
task.spawn(function()
    while task.wait(Sec) do
        pcall(function()
            if not _G.AutoBoss or not _G.FindBoss then return end
            QuestB()
            local questUI = plr.PlayerGui.Main.Quest
            if not questUI.Visible and Qname and Qdata then
                if PosQBoss then _tp(PosQBoss); task.wait(0.5) end
                pcall(function()
                    replicated.Remotes.CommF_:InvokeServer("StartQuest", Qname, Qdata)
                end)
                task.wait(0.5)
            end
            if bMon then
                local boss = nil
                for _,v in pairs(workspace.Enemies:GetChildren()) do
                    if v.Name == bMon and Attack.Alive(v) then boss = v; break end
                end
                for _,v in pairs(replicated:GetChildren()) do
                    if v.Name == bMon and v:FindFirstChild("HumanoidRootPart") then boss = v; break end
                end
                if boss and boss:FindFirstChild("HumanoidRootPart") then
                    _tp(boss.HumanoidRootPart.CFrame * CFrame.new(0, GetFarmOffset(), 0))
                    Attack.Kill(boss, _G.AutoBoss)
                elseif PosB then
                    _tp(PosB)
                end
            end
        end)
    end
end)

Tabs.Quests:AddSection("Material Farm")
Tabs.Quests:AddDropdown({
    Name     = "Select Material",
    Options  = MaterialList,
    Callback = function(Value) SelectMaterial = Value end
})
Tabs.Quests:AddToggle({
    Name        = "Auto Farm Material",
    Description = "Farm mobs that drop the selected material",
    Default     = false,
    Callback    = function(Value) _G.AutoMaterial = Value end
})
task.spawn(function()
    while task.wait(Sec) do
        pcall(function()
            if not _G.AutoMaterial or not SelectMaterial then return end
            MaterialMon()
            if MMon and #MMon > 0 then
                local target = GetConnectionEnemies(MMon)
                if Attack.Alive(target) then
                    repeat
                        task.wait(Sec)
                        _tp(GetSpinCFrame(target.HumanoidRootPart, GetFarmOffset()))
                        Attack.Kill(target, _G.AutoMaterial)
                    until not _G.AutoMaterial or not target.Parent or target.Humanoid.Health <= 0
                elseif MPos then
                    _tp(MPos)
                end
            end
        end)
    end
end)

Tabs.Quests:AddSection("Crafting / Store Fruit")
Tabs.Quests:AddButton({
    Name        = "Store Fruit to Inventory",
    Description = "Send all fruits in backpack to Blox Fruit Dealer",
    Callback    = function() UpdStFruit() end
})
Tabs.Quests:AddButton({
    Name        = "Drop All Fruits",
    Description = "Drop all fruits from your character and backpack",
    Callback    = function() DropFruits() end
})
Tabs.Quests:AddToggle({
    Name        = "Auto Collect Fruits",
    Description = "Teleport any spawned fruits to your character",
    Default     = false,
    Callback    = function(Value) _G.AutoCollectFruits = Value end
})
task.spawn(function()
    while task.wait(1) do
        if _G.AutoCollectFruits then
            collectFruits(true)
        end
    end
end)

-- ============================================================
-- SECTION 19: RAIDS TAB
-- ============================================================
Tabs.Raids:AddSection("Blox Fruit Raid")
Tabs.Raids:AddDropdown({
    Name     = "Select Raid",
    Options  = {"Flame","Ice","Quake","Light","Dark","String","Rumble","Magma","Human: Buddha","Sand","Bird: Phoenix","Dough"},
    Callback = function(Value) _G.SelectRaid = Value end
})
Tabs.Raids:AddButton({
    Name     = "Start Raid",
    Callback = function()
        if not _G.SelectRaid then return end
        pcall(function()
            replicated.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(5259,38,4057))
            task.wait(1)
            replicated.Remotes.CommF_:InvokeServer("StartRaid", _G.SelectRaid, "Advanced")
        end)
    end
})
Tabs.Raids:AddToggle({
    Name        = "Auto Raid Farm",
    Description = "Automatically farm enemies inside a raid",
    Default     = false,
    Callback    = function(Value) _G.AutoRaid = Value end
})
task.spawn(function()
    while task.wait(Sec) do
        pcall(function()
            if not _G.AutoRaid then return end
            for _,v in pairs(workspace.Enemies:GetChildren()) do
                if Attack.Alive(v) and v:FindFirstChild("HumanoidRootPart") then
                    repeat
                        task.wait(Sec)
                        _tp(GetSpinCFrame(v.HumanoidRootPart, GetFarmOffset()))
                        Attack.Kill(v, _G.AutoRaid)
                    until not _G.AutoRaid or not v.Parent or not Attack.Alive(v)
                end
            end
        end)
    end
end)

-- ============================================================
-- SECTION 20: SEA EVENTS TAB
-- ============================================================
Tabs.SeaEvent:AddSection("Sea Events")

local SeaBeastStatus = Tabs.SeaEvent:AddParagraph("Sea Beast", "Status: ❌")
local LeviathanStatus= Tabs.SeaEvent:AddParagraph("Leviathan",  "Status: ❌")

task.spawn(function()
    while task.wait(2) do
        pcall(function()
            local seabeast  = workspace.SeaBeasts:FindFirstChild("SeaBeast1")
            local leviathan = workspace.SeaBeasts:FindFirstChild("Leviathan")
            SeaBeastStatus:SetDesc("Status: " .. (seabeast  and "✅ Active" or "❌ Not spawned"))
            LeviathanStatus:SetDesc("Status: " .. (leviathan and "✅ Active" or "❌ Not spawned"))
        end)
    end
end)

Tabs.SeaEvent:AddToggle({
    Name        = "Auto Kill Sea Beast",
    Description = "Farm sea beasts when they spawn",
    Default     = false,
    Callback    = function(Value) _G.AutoSeaBeast = Value end
})
task.spawn(function()
    while task.wait(Sec) do
        pcall(function()
            if not _G.AutoSeaBeast then return end
            local sb = workspace.SeaBeasts:FindFirstChild("SeaBeast1")
            if sb and sb:FindFirstChild("HumanoidRootPart") then
                repeat
                    task.wait(Sec)
                    _tp(GetSpinCFrame(sb.HumanoidRootPart, 30))
                    Attack.Kill(sb, _G.AutoSeaBeast)
                until not _G.AutoSeaBeast or not sb.Parent
            end
        end)
    end
end)

Tabs.SeaEvent:AddToggle({
    Name        = "Auto Kill Leviathan",
    Description = "Farm the Leviathan when it spawns",
    Default     = false,
    Callback    = function(Value) _G.AutoLeviathan = Value end
})
task.spawn(function()
    while task.wait(Sec) do
        pcall(function()
            if not _G.AutoLeviathan then return end
            local lev = workspace.SeaBeasts:FindFirstChild("Leviathan")
            if lev and lev:FindFirstChild("HumanoidRootPart") then
                repeat
                    task.wait(Sec)
                    _tp(GetSpinCFrame(lev.HumanoidRootPart, 30))
                    Attack.Kill(lev, _G.AutoLeviathan)
                until not _G.AutoLeviathan or not lev.Parent
            end
        end)
    end
end)

-- ============================================================
-- SECTION 21: FISHING TAB
-- ============================================================
Tabs.Fish:AddSection("Auto Fishing")
Tabs.Fish:AddToggle({
    Name        = "Auto Fish",
    Description = "Automatically cast and pull in fish",
    Default     = false,
    Callback    = function(Value) _G.AutoFish = Value end
})
task.spawn(function()
    while task.wait(0.1) do
        if _G.AutoFish then
            pcall(function()
                local char = plr.Character
                if not char then return end
                for _,v in pairs(char:GetChildren()) do
                    if v:IsA("Tool") and string.find(v.Name,"Rod") then
                        EquipWeapon(v.Name)
                        task.wait(0.2)
                        _vu:CaptureController()
                        _vu:Button1Down(Vector2.new(1280,672))
                        task.wait(0.2)
                        _vu:Button1Up(Vector2.new(1280,672))
                    end
                end
            end)
        end
    end
end)

-- ============================================================
-- SECTION 22: RACE & MIRAGE TAB
-- ============================================================
Tabs.Race:AddSection("Race V4")
Tabs.Race:AddButton({
    Name        = "Start V4 Race",
    Description = "Teleport to V4 race location and start",
    Callback    = function()
        pcall(function()
            _tp(CFrame.new(28607,14896,106))
            task.wait(0.5)
            for i = 1,4 do
                replicated.Remotes.CommF_:InvokeServer("RaceV4Progress","TeleportBack")
                task.wait(0.1)
            end
        end)
    end
})

Tabs.Race:AddSection("Mirage Island")
local MirageStatus = Tabs.Race:AddParagraph("Mirage Island", "Status: ❌")
task.spawn(function()
    while task.wait(3) do
        pcall(function()
            local worldOrigin = workspace:FindFirstChild("_WorldOrigin")
            local found = false
            if worldOrigin then
                local locs = worldOrigin:FindFirstChild("Locations")
                if locs and locs:FindFirstChild("Mirage Island") then found = true end
            end
            MirageStatus:SetDesc("Status: " .. (found and "✅ Active" or "❌ Not found"))
        end)
    end
end)

Tabs.Race:AddToggle({
    Name        = "Auto Hop Mirage Island",
    Description = "Server hop until Mirage Island is found",
    Default     = false,
    Callback    = function(Value)
        getgenv()["Hop_MirageIsland"] = Value
        if Value then StartHopping("https://apimirageisland.vercel.app","Hop_MirageIsland") end
    end
})

-- ============================================================
-- SECTION 23: SERVER HOP TAB
-- ============================================================
Tabs.Hop:AddSection("Server Hop")

local function CreateHopToggle(Tab, Name, Description, ApiUrl)
    local globalVar = "Hop_" .. Name:gsub("%s+","")
    getgenv()[globalVar] = false
    Tab:AddToggle({
        Name        = Name,
        Description = Description,
        Default     = false,
        Callback    = function(Value)
            getgenv()[globalVar] = Value
            if Value then StartHopping(ApiUrl, globalVar) end
        end
    })
end

if sea2 or sea3 then
    CreateHopToggle(Tabs.Hop,"Auto Hop Full Moon",       "Hop to server with Full Moon",      "https://apifullmoon.vercel.app")
    CreateHopToggle(Tabs.Hop,"Auto Hop Near Full Moon",  "Hop to server about to have Moon",  "https://apinear.vercel.app")
end
if sea2 then
    CreateHopToggle(Tabs.Hop,"Auto Hop Legendary Sword", "Find Legendary Sword Dealer server","https://api-legendarysworddealer.vercel.app")
    CreateHopToggle(Tabs.Hop,"Auto Hop Cursed Captain",  "Find Cursed Captain server",        "https://api-cursed-captain.vercel.app")
    CreateHopToggle(Tabs.Hop,"Auto Hop Darkbeard",       "Find Darkbeard server",             "https://apidarkbeard.vercel.app")
end
if sea3 then
    CreateHopToggle(Tabs.Hop,"Auto Hop Mirage Island",   "Find Mirage Island server",         "https://apimirageisland.vercel.app")
    CreateHopToggle(Tabs.Hop,"Auto Hop Kitsune Island",  "Find Kitsune Island server",        "https://api-kitsune.vercel.app")
    CreateHopToggle(Tabs.Hop,"Auto Hop Elite Hunter",    "Find Elite Hunter server",          "https://apielite.vercel.app")
    CreateHopToggle(Tabs.Hop,"Auto Hop Rip Indra",       "Find Rip Indra server",             "https://apirip-indra.vercel.app")
    CreateHopToggle(Tabs.Hop,"Auto Hop Dough King",      "Find Dough King server",            "https://apidough-king.vercel.app")
    CreateHopToggle(Tabs.Hop,"Auto Hop Cake Prince",     "Find Cake Prince server",           "https://api-cakeprince.vercel.app")
    CreateHopToggle(Tabs.Hop,"Auto Hop Cake Queen",      "Find Cake Queen server",            "https://api-cakequeen.vercel.app")
    CreateHopToggle(Tabs.Hop,"Auto Hop Soul Reaper",     "Find Soul Reaper server",           "https://api-soul-reaper.vercel.app")
    CreateHopToggle(Tabs.Hop,"Auto Hop Tyrant of Skies", "Find Tyrant of the Skies server",  "https://apityrant-of-the-skies.vercel.app")
    CreateHopToggle(Tabs.Hop,"Auto Hop Prehistoric Isl", "Find Prehistoric Island server",    "https://api-prehistoric-island.vercel.app")
end
if sea1 then
    Tabs.Hop:AddParagraph("Sea 1 Notice","Server Hop events are not available in Sea 1.")
end

Tabs.Hop:AddSection("Useful Scripts")
Tabs.Hop:AddButton({
    Name        = "Copy Fruit Farm Script",
    Description = "Copy the full fruit farming loadstring",
    Callback    = function()
        local script = [[loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_GITHUB/SovereignHub/main/SovereignFarm.lua"))()]]
        if setclipboard then setclipboard(script) elseif toclipboard then toclipboard(script) end
    end
})

-- ============================================================
-- SECTION 24: ESP & STATS TAB
-- ============================================================
Tabs.Esp:AddSection("Player Stats")
local StatsLabel = Tabs.Esp:AddParagraph("Your Stats","Loading...")
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            local d = plr.Data
            local text = string.format(
                "Level: %d\nBeli: %s\nFragments: %s\nStats Points: %d\nMelee: %d | Defense: %d | Sword: %d | Gun: %d | Fruit: %d",
                d.Level.Value,
                tostring(d.Beli.Value),
                tostring(pcall(function() return d.Fragments.Value end) and d.Fragments.Value or "?"),
                d.Points.Value,
                d.Stats.Melee.Value,
                d.Stats.Defense.Value,
                d.Stats.Sword.Value,
                d.Stats.Gun.Value,
                d.Stats.MagicPower.Value
            )
            StatsLabel:SetDesc(text)
        end)
    end
end)

Tabs.Esp:AddSection("ESP Settings")
Tabs.Esp:AddToggle({
    Name        = "Player ESP",
    Description = "Show highlights on all players",
    Default     = false,
    Callback    = function(Value)
        _G.PlayerESP = Value
        for _,p in pairs(ply:GetPlayers()) do
            if p ~= plr and p.Character then
                local hl = p.Character:FindFirstChild("SovHL_Player")
                if Value then
                    if not hl then
                        hl = Instance.new("Highlight")
                        hl.Name = "SovHL_Player"
                        hl.FillColor    = Color3.fromRGB(255,50,50)
                        hl.OutlineColor = Color3.fromRGB(255,255,255)
                        hl.FillTransparency = 0.5
                        hl.Parent = p.Character
                    end
                else
                    if hl then hl:Destroy() end
                end
            end
        end
    end
})

Tabs.Esp:AddToggle({
    Name        = "Enemy ESP",
    Description = "Show highlights on all enemies",
    Default     = false,
    Callback    = function(Value)
        _G.EnemyESP = Value
    end
})
task.spawn(function()
    while task.wait(1) do
        if _G.EnemyESP then
            pcall(function()
                for _,v in pairs(workspace.Enemies:GetChildren()) do
                    if not v:FindFirstChild("SovHL_Enemy") and Attack.Alive(v) then
                        local hl = Instance.new("Highlight")
                        hl.Name = "SovHL_Enemy"
                        hl.FillColor    = Color3.fromRGB(255,150,0)
                        hl.OutlineColor = Color3.fromRGB(255,255,0)
                        hl.FillTransparency = 0.6
                        hl.Parent = v
                    end
                end
            end)
        end
    end
end)

Tabs.Esp:AddToggle({
    Name        = "Fruit ESP",
    Description = "Show highlights on all fallen fruits",
    Default     = false,
    Callback    = function(Value) _G.FruitESP = Value end
})
task.spawn(function()
    while task.wait(1) do
        if _G.FruitESP then
            pcall(function()
                for _,v in pairs(workspace:GetChildren()) do
                    if string.find(v.Name,"Fruit") and not v:FindFirstChild("SovHL_Fruit") then
                        local hl = Instance.new("Highlight")
                        hl.Name = "SovHL_Fruit"
                        hl.FillColor    = Color3.fromRGB(0,200,255)
                        hl.OutlineColor = Color3.fromRGB(255,255,255)
                        hl.FillTransparency = 0.3
                        hl.Parent = v
                    end
                end
            end)
        end
    end
end)

Tabs.Esp:AddToggle({
    Name        = "Chest ESP",
    Description = "Show highlights on all chests",
    Default     = false,
    Callback    = function(Value) _G.ChestESP = Value end
})
task.spawn(function()
    while task.wait(1) do
        if _G.ChestESP then
            pcall(function()
                local CollectionService = game:GetService("CollectionService")
                for _,Chest in pairs(CollectionService:GetTagged("_ChestTagged")) do
                    if not Chest:FindFirstChild("SovHL_Chest") and not Chest:GetAttribute("IsDisabled") then
                        local hl = Instance.new("Highlight")
                        hl.Name = "SovHL_Chest"
                        hl.FillColor    = Color3.fromRGB(255,215,0)
                        hl.OutlineColor = Color3.fromRGB(255,255,255)
                        hl.FillTransparency = 0.4
                        hl.Parent = Chest
                    end
                end
            end)
        end
    end
end)

-- ============================================================
-- SECTION 25: LOCAL PLAYER (COMBAT) TAB
-- ============================================================
Tabs.Combat:AddSection("Player Utilities")

Tabs.Combat:AddToggle({
    Name        = "Noclip",
    Description = "Pass through walls",
    Default     = false,
    Callback    = function(Value)
        shouldTween = Value
        if Value then
            if not plr.Character.HumanoidRootPart:FindFirstChild("BodyClip") then
                local Noclip = Instance.new("BodyVelocity")
                Noclip.Name      = "BodyClip"
                Noclip.MaxForce  = Vector3.new(100000,100000,100000)
                Noclip.Velocity  = Vector3.new(0,0,0)
                Noclip.Parent    = plr.Character.HumanoidRootPart
            end
            if not plr.Character:FindFirstChild("SovHighlight") then
                local hl = Instance.new("Highlight")
                hl.Name = "SovHighlight"
                hl.FillColor    = Color3.fromRGB(128,128,128)
                hl.OutlineColor = Color3.fromRGB(128,128,128)
                hl.FillTransparency    = 0.5
                hl.OutlineTransparency = 0.2
                hl.Parent = plr.Character
            end
            for _,no in pairs(plr.Character:GetDescendants()) do
                if no:IsA("BasePart") then no.CanCollide = false end
            end
        else
            local bc = plr.Character.HumanoidRootPart:FindFirstChild("BodyClip")
            if bc then bc:Destroy() end
            local hl = plr.Character:FindFirstChild("SovHighlight")
            if hl then hl:Destroy() end
        end
    end
})

Tabs.Combat:AddToggle({
    Name        = "Infinite Energy",
    Description = "Keep energy at max",
    Default     = false,
    Callback    = function(Value)
        _G.InfiniteEnergy = Value
        if Value then
            pcall(function()
                plr.Character.Energy.Changed:Connect(function()
                    if _G.InfiniteEnergy then plr.Character.Energy.Value = Energy end
                end)
            end)
        end
    end
})

Tabs.Combat:AddToggle({
    Name        = "Observation Haki",
    Description = "Expand vision radius to max",
    Default     = false,
    Callback    = function(Value)
        if Value then
            pcall(function() plr.VisionRadius.Value = math.huge end)
        end
    end
})

Tabs.Combat:AddSection("Auto Stats")
Tabs.Combat:AddDropdown({
    Name     = "Auto Stat Point",
    Options  = {"Off","Melee","Defense","Sword","Gun","Devil"},
    Default  = "Off",
    Callback = function(Value) _G.AutoStat = Value end
})
task.spawn(function()
    while task.wait(1) do
        if _G.AutoStat and _G.AutoStat ~= "Off" then
            pcall(function() statsSetings(_G.AutoStat, plr.Data.Points.Value) end)
        end
    end
end)

Tabs.Combat:AddSection("Team")
Tabs.Combat:AddButton({Name="Join Marines", Callback=function() Marines() end})
Tabs.Combat:AddButton({Name="Join Pirates",  Callback=function() Pirates() end})

-- ============================================================
-- SECTION 26: TELEPORT TAB
-- ============================================================
Tabs.Travel:AddSection("World Teleport")
Tabs.Travel:AddButton({
    Name        = "Sea 1",
    Description = "Teleport to First Sea",
    Callback    = function()
        TeleportService:Teleport(2753915549, plr)
    end
})
Tabs.Travel:AddButton({
    Name        = "Sea 2",
    Description = "Teleport to Second Sea",
    Callback    = function()
        TeleportService:Teleport(4442272183, plr)
    end
})
Tabs.Travel:AddButton({
    Name        = "Sea 3",
    Description = "Teleport to Third Sea",
    Callback    = function()
        TeleportService:Teleport(7449423635, plr)
    end
})

Tabs.Travel:AddSection("Island Teleport")
if World1 then
    Tabs.Travel:AddDropdown({
        Name     = "Teleport to Island (Sea 1)",
        Options  = {"Marine Starter Island","Pirate Starter Island","Marine Fortress","Skylands","Prison","Magma Village","Underwater City"},
        Callback = function(Value)
            local posMap = {
                ["Marine Starter Island"]  = CFrame.new(976,15,1473),
                ["Pirate Starter Island"]  = CFrame.new(-1290,13,1160),
                ["Marine Fortress"]        = CFrame.new(-4943,67,4346),
                ["Skylands"]               = CFrame.new(-7861,5545,-379),
                ["Prison"]                 = CFrame.new(5278,2,944),
                ["Magma Village"]          = CFrame.new(-5765,82,8718),
                ["Underwater City"]        = CFrame.new(61260,30,1193),
            }
            if posMap[Value] then _tp(posMap[Value]) end
        end
    })
end
if World2 then
    Tabs.Travel:AddDropdown({
        Name     = "Teleport to Island (Sea 2)",
        Options  = {"Kingdom of Rose","Graveyard","Snow Mountain","Cursed Ship","Ice Castle"},
        Callback = function(Value)
            local posMap = {
                ["Kingdom of Rose"] = CFrame.new(-1576,198,13),
                ["Graveyard"]       = CFrame.new(-6033,7,-1317),
                ["Snow Mountain"]   = CFrame.new(-5429,15,-5297),
                ["Cursed Ship"]     = CFrame.new(923,126,33159),
                ["Ice Castle"]      = CFrame.new(6403,340,-6894),
            }
            if posMap[Value] then _tp(posMap[Value]) end
        end
    })
end
if World3 then
    Tabs.Travel:AddDropdown({
        Name     = "Teleport to Island (Sea 3)",
        Options  = {"Port Town","Hydra Island","Great Tree","Floating Turtle","Haunted Castle","Sea of Treats","Submerged Island"},
        Callback = function(Value)
            local posMap = {
                ["Port Town"]        = CFrame.new(-2911,79,-7458),
                ["Hydra Island"]     = CFrame.new(-7296,103,-4008),
                ["Great Tree"]       = CFrame.new(7021,55,-730),
                ["Floating Turtle"]  = CFrame.new(4692,797,858),
                ["Haunted Castle"]   = CFrame.new(-8764,142,5963),
                ["Sea of Treats"]    = CFrame.new(-1145,13,-14450),
                ["Submerged Island"] = CFrame.new(-3200,-10,-10000),
            }
            if posMap[Value] then
                requestentrance(posMap[Value].Position)
                task.wait(0.5)
                _tp(posMap[Value])
            end
        end
    })
end

-- ============================================================
-- SECTION 27: SHOP TAB
-- ============================================================
Tabs.Shop:AddSection("Shopping")
Tabs.Shop:AddButton({
    Name     = "Buy Stats Reset",
    Callback = function()
        pcall(function() replicated.Remotes.CommF_:InvokeServer("ResetStats") end)
    end
})
Tabs.Shop:AddButton({
    Name     = "Mastery Reset",
    Callback = function()
        pcall(function() replicated.Remotes.CommF_:InvokeServer("ResetMastery") end)
    end
})

-- ============================================================
-- SECTION 28: SETTINGS TAB
-- ============================================================
Tabs.Settings:AddSection("Farm Settings")
Tabs.Settings:AddSlider({
    Name    = "Farm Delay (Seconds)",
    Min     = 0.01,
    Max     = 1,
    Default = 0.05,
    Callback= function(Value) Sec = Value end
})
Tabs.Settings:AddToggle({
    Name        = "Bring Mobs",
    Description = "Bring nearby mobs to your target",
    Default     = true,
    Callback    = function(Value) _B = Value end
})
Tabs.Settings:AddToggle({
    Name        = "Bypass Teleport",
    Description = "Use spawn points to bypass anti-cheat teleport detection",
    Default     = true,
    Callback    = function(Value) Settings["Bypass Teleport"] = Value end
})
Tabs.Settings:AddSlider({
    Name    = "Spin Speed",
    Min     = 10,
    Max     = 200,
    Default = 50,
    Callback= function(Value) _G.SpinSpeed = Value end
})
Tabs.Settings:AddSlider({
    Name    = "Spin Radius",
    Min     = 2,
    Max     = 20,
    Default = 6.5,
    Callback= function(Value) _G.SpinRadius = Value end
})

Tabs.Settings:AddSection("UI Settings")
Tabs.Settings:AddButton({
    Name        = "Save Config",
    Description = "Manually save current settings",
    Callback    = function() SaveConfig() end
})
Tabs.Settings:AddButton({
    Name        = "Reset Config",
    Description = "Clear all saved settings",
    Callback    = function()
        SovConfig = {}
        if writefile then
            pcall(function() writefile(ConfigFile, "{}") end)
        end
    end
})

-- ============================================================
-- SECTION 29: VOLCANIC EVENT TAB
-- ============================================================
Tabs.Volcanic:AddSection("Volcanic / Boss Event")
local VolcanoStatus = Tabs.Volcanic:AddParagraph("Volcanic Event","Status: ❌")
task.spawn(function()
    while task.wait(3) do
        pcall(function()
            local found = workspace:FindFirstChild("Volcanic") or workspace:FindFirstChild("VolcanoEvent")
            VolcanoStatus:SetDesc("Status: " .. (found and "✅ Active" or "❌ Inactive"))
        end)
    end
end)

Tabs.Volcanic:AddToggle({
    Name        = "Auto Farm Volcanic Event",
    Description = "Farm enemies during volcanic event",
    Default     = false,
    Callback    = function(Value) _G.AutoVolcanic = Value end
})
task.spawn(function()
    while task.wait(Sec) do
        pcall(function()
            if not _G.AutoVolcanic then return end
            for _,v in pairs(workspace.Enemies:GetChildren()) do
                if Attack.Alive(v) and v:FindFirstChild("HumanoidRootPart") then
                    if (v.HumanoidRootPart.Position - Root.Position).Magnitude <= 5000 then
                        repeat
                            task.wait(Sec)
                            _tp(GetSpinCFrame(v.HumanoidRootPart, GetFarmOffset()))
                            Attack.Kill(v, _G.AutoVolcanic)
                        until not _G.AutoVolcanic or not v.Parent or not Attack.Alive(v)
                    end
                end
            end
        end)
    end
end)

-- ============================================================
-- SECTION 30: MISCELLANEOUS TAB
-- ============================================================
Tabs.Misc:AddSection("Miscellaneous")

Tabs.Misc:AddToggle({
    Name        = "Anti AFK",
    Description = "Prevent AFK kick",
    Default     = true,
    Callback    = function(Value) _G.AntiAFK = Value end
})
task.spawn(function()
    while task.wait(60) do
        if _G.AntiAFK then
            pcall(function()
                vim2:CaptureController()
                vim2:ClickButton2(Vector2.new())
            end)
        end
    end
end)

Tabs.Misc:AddToggle({
    Name        = "Auto Rejoin on Death",
    Description = "Automatically rejoin server on death",
    Default     = false,
    Callback    = function(Value) _G.AutoRejoin = Value end
})
task.spawn(function()
    local connection
    connection = plr.CharacterAdded:Connect(function(char)
        if not _G.AutoRejoin then return end
        local hum = char:WaitForChild("Humanoid")
        hum.Died:Connect(function()
            if _G.AutoRejoin then
                task.wait(5)
                TeleportService:Teleport(game.PlaceId, plr)
            end
        end)
    end)
end)

Tabs.Misc:AddToggle({
    Name        = "Auto Use Ken/Observation",
    Description = "Auto activate Observation Haki",
    Default     = false,
    Callback    = function(Value) _G.AutoKen = Value end
})
task.spawn(function()
    while task.wait(0.5) do
        if _G.AutoKen then
            pcall(function()
                if plr.Character:FindFirstChild("Observation") then
                    plr.Character.Observation:FireServer("Toggle")
                end
            end)
        end
    end
end)

Tabs.Misc:AddButton({
    Name        = "Rejoin Server",
    Description = "Teleport to a new server",
    Callback    = function() Hop() end
})

Tabs.Misc:AddButton({
    Name        = "Copy Position",
    Description = "Copy your current CFrame to clipboard",
    Callback    = function()
        local pos = Root and Root.CFrame
        if pos then
            local str = string.format("CFrame.new(%s, %s, %s)",
                tostring(math.floor(pos.X)),
                tostring(math.floor(pos.Y)),
                tostring(math.floor(pos.Z))
            )
            if setclipboard then setclipboard(str) elseif toclipboard then toclipboard(str) end
        end
    end
})

Tabs.Misc:AddSection("Lighting")
Tabs.Misc:AddToggle({
    Name        = "Full Bright",
    Description = "Set environment to maximum brightness",
    Default     = false,
    Callback    = function(Value)
        if Value then
            Lighting.Brightness    = 2
            Lighting.ClockTime     = 14
            Lighting.FogEnd        = 1e9
            Lighting.GlobalShadows = false
            Lighting.Ambient       = Color3.fromRGB(255,255,255)
        else
            Lighting.Brightness    = 1
            Lighting.ClockTime     = 14
            Lighting.FogEnd        = 100000
            Lighting.GlobalShadows = true
            Lighting.Ambient       = Color3.fromRGB(0,0,0)
        end
    end
})

-- ============================================================
-- SECTION 31: BOSS TRACKER SPAWNS (World 3)
-- ============================================================
if World3 then
    task.spawn(function()
        local trackers = {
            {Name="Soul Reaper",          Var="ReaperCheck",    URL="https://api-soul-reaper.vercel.app/update-soul-reaper"},
            {Name="Tyrant of the Skies",  Var="TyrantCheck",    URL="https://apityrant-of-the-skies.vercel.app/update-tyrant-of-the-skies"},
            {Name="Kitsune Island",       Var="KitsuneCheck",   URL="https://api-kitsune.vercel.app/update-dao-kitsune"},
        }
        for _,tracker in ipairs(trackers) do
            task.spawn(function()
                local previousStatus = ""
                while true do
                    pcall(function()
                        local found = workspace.Enemies:FindFirstChild(tracker.Name) or RS:FindFirstChild(tracker.Name)
                        local status = found and "✅" or "❌"
                        if status ~= previousStatus then
                            if _G[tracker.Var] then
                                pcall(function() _G[tracker.Var]:SetDesc("Status: " .. status) end)
                            end
                            previousStatus = status
                        end
                        if found and request_fn then
                            pcall(function()
                                request_fn({Url=tracker.URL, Method="POST", Headers={["Content-Type"]="application/json"}, Body=HttpService:JSONEncode({jobId=game.JobId})})
                            end)
                        end
                    end)
                    task.wait(15)
                end
            end)
        end
    end)
end

-- ============================================================
-- SECTION 32: STARTUP NOTIFICATION
-- ============================================================
Window:Notify({
    Title    = "Sovereign Hub",
    Content  = "Crown initialized. All systems online.",
    Image    = "rbxassetid://127729348105692",
    Duration = 4
})

-- ============================================================
--                     END OF SOVEREIGN HUB
-- ============================================================
