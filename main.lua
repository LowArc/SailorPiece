-- ==========================================
-- || INITIALIZATION
-- ==========================================
repeat
    task.wait()
until game:IsLoaded()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
repeat
    task.wait()
until LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

-- ==========================================
-- || CONFIGURATION (Linked to getgenv)
-- ==========================================
local Config = {
    LoopFarm = false,
    TpTime = 0.1,
    AutoEquip = false,
    SelectedWeapon = "", -- Stores the chosen weapon name
    AutoHaki = false,
    AutoObservationHaki = false,
    IgnoredEntities = {
        Hollow = true, Quincy = true, Swordsman = true, AcademyTeacher = true,
        Slime = true, StrongSorcerer = true, Curse = true, Gojo = true,
        Yuji = true, Sukuna = true, Jinwoo = true, Alucard = true,
        Aizen = true, Yamato = true, Saber = true, Ichigo = true,
        QinShi = true, Gilgamesh = true, BlessedMaiden = true,
        StrongestinHistory = true, StrongestofToday = true,
        Rimuru = true, Anos = true, TrueAizen = true,
    },
    Boss = {
        AutoSpawn = false, Selected = "Saber", Difficulty = "Normal",
    },
    Specials = {
        TrueAizen = { Auto = false, Diff = "Normal" },
        Sukuna = { Auto = false, Diff = "Normal" },
        Gojo = { Auto = false, Diff = "Normal" },
        Rimuru = { Auto = false, Diff = "Normal" },
        Anos = { Auto = false, Diff = "Normal" },
    },
    AutoSkill = {
        Enabled = true,
        Skills = {
            Z = { Id = 1, Enabled = false },
            X = { Id = 2, Enabled = false },
            C = { Id = 3, Enabled = false },
            V = { Id = 4, Enabled = false },
            F = { Id = 5, Enabled = false },
        }
    }
}

getgenv().FarmConfig = Config

-- ==========================================
-- || CONSTANTS
-- ==========================================
local CONSTANTS = {
    Locations = {
        Hollow = CFrame.new(-365, 0, 1094), Quincy = CFrame.new(-1350, 1604, 1595),
        Swordsman = CFrame.new(-1271, 1, -1193), AcademyTeacher = CFrame.new(1081, 2, 1279),
        Slime = CFrame.new(-1123, 14, 366), StrongSorcerer = CFrame.new(664, 2, -1697),
        Gojo = CFrame.new(1858.32, 12.98, 338.14), Yuji = CFrame.new(1537.92, 9.98, 226.10),
        Sukuna = CFrame.new(1571.26, 77.22, -34.11), Jinwoo = CFrame.new(248.74, 12.09, 927.54),
        Alucard = CFrame.new(248.74, 12.09, 927.54), Aizen = CFrame.new(-567.22, -0.42, 1228.49),
        Yamato = CFrame.new(-1422.68, 24.42, -1383.46), Saber = CFrame.new(770, -1, -1086),
        Ichigo = CFrame.new(770, -1, -1086), QinShi = CFrame.new(770, -1, -1086),
        Gilgamesh = CFrame.new(770, -1, -1086), BlessedMaiden = CFrame.new(770, -1, -1086),
        StrongestinHistory = CFrame.new(604, 3, -2314), StrongestofToday = CFrame.new(139, 3, -2432),
        Rimuru = CFrame.new(-1358, 19, 219), Anos = CFrame.new(949, 1, 1370),
        TrueAizen = CFrame.new(-1205, 1604, 1774),
    },
    FarmOrder = {
        { Name = "Swordsman", Remote = "Judgement", IsBossType = false },
        { Name = "Quincy", Remote = "SoulSociety", IsBossType = false },
        { Name = "AcademyTeacher", Remote = "Academy", IsBossType = false },
        { Name = "Slime", Remote = "Slime", IsBossType = false },
        { Name = "StrongSorcerer", Remote = "Shinjuku", IsBossType = false },
        { Name = "Hollow", Remote = "HuecoMundo", IsBossType = false },
        { Name = "Gojo", Remote = "Shibuya", IsBossType = true },
        { Name = "Yuji", Remote = "Shibuya", IsBossType = true },
        { Name = "Sukuna", Remote = "Shibuya", IsBossType = true },
        { Name = "Jinwoo", Remote = "Sailor", IsBossType = true },
        { Name = "Alucard", Remote = "Sailor", IsBossType = true },
        { Name = "Aizen", Remote = "HuecoMundo", IsBossType = true },
        { Name = "Yamato", Remote = "Judgement", IsBossType = true },
        { Name = "Saber", Remote = "Boss", IsBossType = true },
        { Name = "Ichigo", Remote = "Boss", IsBossType = true },
        { Name = "QinShi", Remote = "Boss", IsBossType = true },
        { Name = "Gilgamesh", Remote = "Boss", IsBossType = true },
        { Name = "BlessedMaiden", Remote = "Boss", IsBossType = true },
        { Name = "StrongestinHistory", Remote = "Shinjuku", IsBossType = true },
        { Name = "StrongestofToday", Remote = "Shinjuku", IsBossType = true },
        { Name = "Rimuru", Remote = "Slime", IsBossType = true },
        { Name = "Anos", Remote = "Academy", IsBossType = true },
        { Name = "TrueAizen", Remote = "SoulSociety", IsBossType = true },
    },
}

-- ==========================================
-- || CLASS: Entity Tracker
-- ==========================================
local EntityTracker = {}
EntityTracker.__index = EntityTracker

function EntityTracker.new(npcsFolder)
    local self = setmetatable({
        Folder = npcsFolder,
        Active = {},
        Connections = {},
    }, EntityTracker)
    self:Init()
    return self
end

function EntityTracker:Register(npc)
    task.spawn(function()
        local humanoid = npc:WaitForChild("Humanoid", 3)
        if humanoid and humanoid.Health > 0 then
            self.Active[npc] = true
            local deathConn, removeConn
            deathConn = humanoid.Died:Connect(function()
                self.Active[npc] = nil
                deathConn:Disconnect()
            end)
            removeConn = npc.AncestryChanged:Connect(function(_, parent)
                if not parent then
                    self.Active[npc] = nil
                    removeConn:Disconnect()
                    if deathConn then deathConn:Disconnect() end
                end
            end)
        end
    end)
end

function EntityTracker:Init()
    for _, child in ipairs(self.Folder:GetChildren()) do
        self:Register(child)
    end
    self.Folder.ChildAdded:Connect(function(child)
        self:Register(child)
    end)
end

function EntityTracker:IsAlive(queryName, isBossType, requiredCount)
    requiredCount = requiredCount or 5
    local currentCount = 0

    for npc, _ in pairs(self.Active) do
        if npc and npc.Parent then
            if isBossType then
                if string.find(npc.Name, "^" .. queryName) then return true end
            else
                if string.find(npc.Name, queryName) then
                    currentCount += 1
                    if currentCount >= requiredCount then return true end
                end
            end
        else
            self.Active[npc] = nil
        end
    end
    return false
end

-- ==========================================
-- || CLASS: Boss Spawner
-- ==========================================
local BossSpawner = {}
BossSpawner.__index = BossSpawner

function BossSpawner.new(tracker, remotes)
    return setmetatable({
        Tracker = tracker,
        Remotes = remotes,
        StandardBosses = { "Saber", "Ichigo", "QinShi", "Gilgamesh", "BlessedMaiden" },
    }, BossSpawner)
end

function BossSpawner:Start()
    task.spawn(function()
        while task.wait(0.5) do
            local cfg = getgenv().FarmConfig

            if cfg.Boss.AutoSpawn then
                local anyAlive = false
                for _, bName in ipairs(self.StandardBosses) do
                    if self.Tracker:IsAlive(bName, true) then
                        anyAlive = true
                        break
                    end
                end
                if not anyAlive then
                    self.Remotes.SummonBoss:FireServer(cfg.Boss.Selected .. "Boss", cfg.Boss.Difficulty)
                end
            end

            local specs = cfg.Specials
            if specs.TrueAizen.Auto and not self.Tracker:IsAlive("TrueAizen", true) then
                self.Remotes.TrueAizen:FireServer(specs.TrueAizen.Diff)
            end
            if specs.Sukuna.Auto and not self.Tracker:IsAlive("StrongestinHistory", true) then
                self.Remotes.SpawnStrongest:FireServer("StrongestHistory", specs.Sukuna.Diff)
            end
            if specs.Gojo.Auto and not self.Tracker:IsAlive("StrongestofToday", true) then
                self.Remotes.SpawnStrongest:FireServer("StrongestToday", specs.Gojo.Diff)
            end
            if specs.Rimuru.Auto and not self.Tracker:IsAlive("Rimuru", true) then
                self.Remotes.Rimuru:FireServer(specs.Rimuru.Diff)
            end
            if specs.Anos.Auto and not self.Tracker:IsAlive("Anos", true) then
                self.Remotes.Anos:FireServer("Anos", specs.Anos.Diff)
            end
        end
    end)
end

-- ==========================================
-- || CLASS: Farmer
-- ==========================================
local Farmer = {}
Farmer.__index = Farmer

function Farmer.new(tracker, tpRemote, abilityRemote, obsHakiRemote)
    return setmetatable({
        Tracker = tracker,
        TpRemote = tpRemote,
        AbilityRemote = abilityRemote,
        ObsHakiRemote = obsHakiRemote,
        LastSkillTime = 0
    }, Farmer)
end

function Farmer:EquipWeapon()
    local cfg = getgenv().FarmConfig
    if not cfg.AutoEquip or cfg.SelectedWeapon == "" or cfg.SelectedWeapon == "None" then return end

    local char = LocalPlayer.Character
    if not char then return end

    local hum = char:FindFirstChild("Humanoid")
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    
    if not hum or hum.Health <= 0 or not backpack then return end
    
    local tool = char:FindFirstChild(cfg.SelectedWeapon)
    if not tool then
        tool = backpack:FindFirstChild(cfg.SelectedWeapon)
        if tool then
            hum:EquipTool(tool)
        end
    else
        -- If equipped, auto attack!
        pcall(function()
            tool:Activate()
        end)
    end
end

function Farmer:CheckObservationHaki()
    local cfg = getgenv().FarmConfig
    if not cfg.AutoObservationHaki then return end

    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return end

    -- 1. Check if it's on Cooldown
    local cdUI = playerGui:FindFirstChild("CooldownUI")
    if cdUI then
        local cdMain = cdUI:FindFirstChild("MainFrame")
        if cdMain and cdMain:FindFirstChild("Cooldown_ObsHaki_Observation") then
            -- Cooldown exists, do not fire remote
            return
        end
    end

    -- 2. Check if the Dodge UI is already visible
    local dodgeUI = playerGui:FindFirstChild("DodgeCounterUI")
    local isVisible = false
    if dodgeUI then
        local mainFrame = dodgeUI:FindFirstChild("MainFrame")
        if mainFrame and mainFrame.Visible then
            isVisible = true
        end
    end

    -- 3. If no cooldown and not visible, toggle it on
    if not isVisible then
        pcall(function()
            self.ObsHakiRemote:FireServer("Toggle")
        end)
    end
end

function Farmer:Start()
    task.spawn(function()
        while task.wait() do
            local cfg = getgenv().FarmConfig
            if not cfg.LoopFarm then
                continue
            end
            
            self:CheckObservationHaki()
            self:EquipWeapon()

            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then
                continue
            end

            for _, target in ipairs(CONSTANTS.FarmOrder) do
                if not cfg.LoopFarm then break end
                if cfg.IgnoredEntities[target.Name] then continue end

                if not self.Tracker:IsAlive(target.Name, target.IsBossType, 5) then
                    continue
                end

                local spawnCF = CONSTANTS.Locations[target.Name]
                if spawnCF then
                    if target.IsBossType then
                        if target.Remote then
                            self.TpRemote:FireServer(target.Remote)
                            task.wait(0.2)
                        end

                        while
                            cfg.LoopFarm
                            and not cfg.IgnoredEntities[target.Name]
                            and self.Tracker:IsAlive(target.Name, true)
                        do
                            self:CheckObservationHaki()
                            self:EquipWeapon()
                            
                            local currentChar = LocalPlayer.Character
                            local currentHrp = currentChar and currentChar:FindFirstChild("HumanoidRootPart")

                            if currentHrp then
                                local liveBoss = nil
                                for npc, _ in pairs(self.Tracker.Active) do
                                    if npc.Name:find("^" .. target.Name) and npc:FindFirstChild("HumanoidRootPart") then
                                        liveBoss = npc.HumanoidRootPart
                                        break
                                    end
                                end

                                local targetGoal = liveBoss and liveBoss.CFrame or spawnCF
                                local distance = (currentHrp.Position - targetGoal.Position).Magnitude

                                if distance > 20 then
                                    if distance > 150 and target.Remote then
                                        self.TpRemote:FireServer(target.Remote)
                                        task.wait(0.5)
                                    end

                                    currentHrp.CFrame = targetGoal * CFrame.new(0, 0, 3)
                                    task.wait(cfg.TpTime + 0.5)
                                end

                                if cfg.AutoSkill.Enabled and (tick() - self.LastSkillTime > 1) then
                                    self.LastSkillTime = tick()
                                    for key, skillData in pairs(cfg.AutoSkill.Skills) do
                                        if skillData.Enabled then
                                            task.spawn(function()
                                                pcall(function() self.AbilityRemote:FireServer(skillData.Id) end)
                                            end)
                                        end
                                    end
                                end
                            end
                            task.wait(0.1)
                        end
                    else
                        if target.Remote then
                            self.TpRemote:FireServer(target.Remote)
                        end

                        local currentHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if currentHrp then
                            currentHrp.CFrame = spawnCF
                            task.wait(cfg.TpTime)
                        end
                    end
                end
            end
        end
    end)
end

-- ==========================================
-- || CLASS: Utility / Character Manager
-- ==========================================
local Utility = {}
function Utility.EnableAntiAFK()
    if getgenv().AntiAFK_Enabled then return end
    getgenv().AntiAFK_Enabled = true

    local VirtualUser = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end)
end

function Utility.SetupCharacterEvents(hakiRemote, obsHakiRemote)
    local function onCharacterAdded(char)
        char:WaitForChild("HumanoidRootPart", 5)
        task.wait(1)
        local cfg = getgenv().FarmConfig
        
        -- Auto Armament Haki
        if cfg.AutoHaki then
            pcall(function() hakiRemote:FireServer("Toggle") end)
        end
        
        -- Auto Observation Haki (With UI Checks)
        if cfg.AutoObservationHaki then
            local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
            if playerGui then
                -- Check if on cooldown
                local cdUI = playerGui:FindFirstChild("CooldownUI")
                local hasCD = false
                if cdUI then
                    local cdMain = cdUI:FindFirstChild("MainFrame")
                    if cdMain and cdMain:FindFirstChild("Cooldown_ObsHaki_Observation") then
                        hasCD = true
                    end
                end

                -- Check if Dodge Counter UI is already visible
                local dodgeUI = playerGui:FindFirstChild("DodgeCounterUI")
                local isVisible = false
                if dodgeUI then
                    local mainFrame = dodgeUI:FindFirstChild("MainFrame")
                    if mainFrame and mainFrame.Visible then
                        isVisible = true
                    end
                end

                -- Fire if safe
                if not hasCD and not isVisible then
                    pcall(function() obsHakiRemote:FireServer("Toggle") end)
                end
            end
        end
    end

    LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
    if LocalPlayer.Character then
        task.spawn(onCharacterAdded, LocalPlayer.Character)
    end
end

function Utility.GetWeapons()
    local weapons = {}
    local char = LocalPlayer.Character
    if char then
        for _, v in ipairs(char:GetChildren()) do
            if v:IsA("Tool") then table.insert(weapons, v.Name) end
        end
    end
    for _, v in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if v:IsA("Tool") then table.insert(weapons, v.Name) end
    end
    if #weapons == 0 then return {"None"} end
    return weapons
end

-- ==========================================
-- || EXECUTION
-- ==========================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local AbilityRemote = ReplicatedStorage:WaitForChild("AbilitySystem"):WaitForChild("Remotes"):WaitForChild("RequestAbility")

local GameRemotes = {
    Teleport = Remotes:WaitForChild("TeleportToPortal"),
    SummonBoss = Remotes:WaitForChild("RequestSummonBoss"),
    SpawnStrongest = Remotes:WaitForChild("RequestSpawnStrongestBoss"),
    Anos = Remotes:WaitForChild("RequestSpawnAnosBoss"),
    TrueAizen = RemoteEvents:WaitForChild("RequestSpawnTrueAizen"),
    Rimuru = RemoteEvents:WaitForChild("RequestSpawnRimuru"),
    Haki = RemoteEvents:WaitForChild("HakiRemote"),
    ObservationHaki = RemoteEvents:WaitForChild("ObservationHakiRemote")
}

local Tracker = EntityTracker.new(workspace:WaitForChild("NPCs"))
local Spawner = BossSpawner.new(Tracker, GameRemotes)
local AutoFarm = Farmer.new(Tracker, GameRemotes.Teleport, AbilityRemote, GameRemotes.ObservationHaki)

Utility.EnableAntiAFK()
Utility.SetupCharacterEvents(GameRemotes.Haki, GameRemotes.ObservationHaki)
Spawner:Start()
AutoFarm:Start()

print("ArcX AutoFarm Initialized Successfully.")

-- ==========================================
-- || UI INTEGRATION (FLUENT & SAVEMANAGER)
-- ==========================================
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "ArcX 💀🥀",
    SubTitle = "Best Script Of All Time???",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Mobs = Window:AddTab({ Title = "Entities", Icon = "swords" }),
    Bosses = Window:AddTab({ Title = "Standard Bosses", Icon = "skull" }),
    Specials = Window:AddTab({ Title = "Special Bosses", Icon = "star" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- [[ Main Tab ]]
local Toggle_LoopFarm = Tabs.Main:AddToggle("Toggle_LoopFarm", {Title = "Enable Auto Farm", Default = Config.LoopFarm })
Toggle_LoopFarm:OnChanged(function(Value)
    Config.LoopFarm = Value
end)

local Toggle_AutoHaki = Tabs.Main:AddToggle("Toggle_AutoHaki", {Title = "Auto Armament Haki (On Spawn)", Default = Config.AutoHaki })
Toggle_AutoHaki:OnChanged(function(Value)
    Config.AutoHaki = Value
end)

local Toggle_AutoObsHaki = Tabs.Main:AddToggle("Toggle_AutoObsHaki", {Title = "Auto Observation Haki (Always)", Default = Config.AutoObservationHaki })
Toggle_AutoObsHaki:OnChanged(function(Value)
    Config.AutoObservationHaki = Value
end)

-- Auto Equip & Weapon Selection
Tabs.Main:AddParagraph({ Title = "Inventory Management", Content = "Configure auto-equipping of specific weapons." })

local Toggle_AutoEquip = Tabs.Main:AddToggle("Toggle_AutoEquip", {Title = "Auto Equip Weapon", Default = Config.AutoEquip })
Toggle_AutoEquip:OnChanged(function(Value)
    Config.AutoEquip = Value
end)

local Dropdown_Weapon = Tabs.Main:AddDropdown("Dropdown_Weapon", {
    Title = "Select Weapon",
    Values = Utility.GetWeapons(),
    Multi = false,
    Default = 1,
})
Dropdown_Weapon:OnChanged(function(Value)
    Config.SelectedWeapon = Value
end)

Tabs.Main:AddButton({
    Title = "Refresh Weapon List",
    Description = "Click this to update the dropdown if you get a new tool.",
    Callback = function()
        Dropdown_Weapon:SetValues(Utility.GetWeapons())
        -- Restore the saved selection if it still exists
        if table.find(Utility.GetWeapons(), Config.SelectedWeapon) then
            Dropdown_Weapon:SetValue(Config.SelectedWeapon)
        end
    end
})

local Slider_TpTime = Tabs.Main:AddSlider("Slider_TpTime", {
    Title = "Teleport Delay",
    Description = "Wait time between teleports",
    Default = Config.TpTime,
    Min = 0,
    Max = 2,
    Rounding = 1,
    Callback = function(Value) Config.TpTime = Value end
})

-- [[ Main Tab: Auto Skills ]]
Tabs.Main:AddParagraph({ Title = "Auto Skills", Content = "Automatically use abilities ONLY when fighting Bosses." })

local Toggle_AutoSkill = Tabs.Main:AddToggle("Toggle_AutoSkill", { Title = "Use Skills on Bosses", Default = Config.AutoSkill.Enabled })
Toggle_AutoSkill:OnChanged(function(Value) Config.AutoSkill.Enabled = Value end)

for key, data in pairs(Config.AutoSkill.Skills) do
    local Toggle_Skill = Tabs.Main:AddToggle("Skill_" .. key, {
        Title = "Use Skill " .. key,
        Default = data.Enabled
    })
    Toggle_Skill:OnChanged(function(Value)
        Config.AutoSkill.Skills[key].Enabled = Value
    end)
end

-- [[ Mobs / Entities Tab ]]
Tabs.Mobs:AddParagraph({ Title = "Entity Targeting", Content = "Enable the entities you want the script to farm." })

local sortedEntities = {}
for k, _ in pairs(Config.IgnoredEntities) do table.insert(sortedEntities, k) end
table.sort(sortedEntities)

for _, entityName in ipairs(sortedEntities) do
    local Toggle_Entity = Tabs.Mobs:AddToggle("Mob_" .. entityName, {
        Title = "Farm " .. entityName,
        Default = not Config.IgnoredEntities[entityName] 
    })
    Toggle_Entity:OnChanged(function(Value)
        Config.IgnoredEntities[entityName] = not Value
    end)
end

-- [[ Bosses Tab ]]
local Toggle_AutoSpawn = Tabs.Bosses:AddToggle("Toggle_AutoSpawn", {Title = "Auto-Spawn Bosses", Default = Config.Boss.AutoSpawn })
Toggle_AutoSpawn:OnChanged(function(Value) Config.Boss.AutoSpawn = Value end)

local Dropdown_SelectedBoss = Tabs.Bosses:AddDropdown("Dropdown_SelectedBoss", {
    Title = "Select Boss",
    Values = {"Saber", "Ichigo", "QinShi", "Gilgamesh", "BlessedMaiden"},
    Multi = false,
    Default = 1,
})
Dropdown_SelectedBoss:OnChanged(function(Value) Config.Boss.Selected = Value end)

local Dropdown_BossDifficulty = Tabs.Bosses:AddDropdown("Dropdown_BossDifficulty", {
    Title = "Difficulty",
    Values = {"Normal", "Hard", "Extreme"}, 
    Multi = false,
    Default = 1,
})
Dropdown_BossDifficulty:OnChanged(function(Value) Config.Boss.Difficulty = Value end)

-- [[ Specials Tab ]]
Tabs.Specials:AddParagraph({ Title = "Special Boss Spawners", Content = "Configure auto-spawning for special bosses." })
local difficultyLevels = {"Normal", "Hard", "Nightmare"}

for bossName, bossData in pairs(Config.Specials) do
    local Toggle_Special = Tabs.Specials:AddToggle("Special_" .. bossName, {
        Title = "Auto Spawn " .. bossName,
        Default = bossData.Auto
    })
    Toggle_Special:OnChanged(function(Value) Config.Specials[bossName].Auto = Value end)

    local Dropdown_SpecialDiff = Tabs.Specials:AddDropdown("SpecialDiff_" .. bossName, {
        Title = bossName .. " Difficulty",
        Values = difficultyLevels,
        Multi = false,
        Default = 1,
    })
    Dropdown_SpecialDiff:OnChanged(function(Value) Config.Specials[bossName].Diff = Value end)
end

-- [[ Settings & SaveManager Integration ]]
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({"Dropdown_Weapon"}) -- Don't auto-save weapon list state as it changes
InterfaceManager:SetFolder("ArcX")
SaveManager:SetFolder("ArcX/configs")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

SaveManager:LoadAutoloadConfig()
Window:SelectTab(1)

Fluent:Notify({
    Title = "ArcX 💀🥀",
    Content = "Script and UI loaded. Don't forget to refresh and select your weapon!",
    Duration = 5
})
