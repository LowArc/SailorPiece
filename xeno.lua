-- ==========================================
-- || INITIALIZATION
-- ==========================================
repeat task.wait() until game:IsLoaded()

local Players    = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

repeat task.wait()
until LocalPlayer
  and LocalPlayer.Character
  and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

-- ==========================================
-- || CONFIGURATION (Linked to _G)
-- ==========================================
local Config = {
	LoopFarm              = false,
	AutoRejoin            = false,
	TimedRejoin           = false,
	RejoinDelay           = 10,
	FriendOnly            = false,
	WhiteScreen           = false,
	TpTime                = 0.1,
	NPCAttackThreshold    = 5,
	AutoEquip             = false,
	SelectedWeapon_NPC    = "None",
	SelectedWeapon_Boss   = "None",
	AutoHaki              = false,
	AutoObservationHaki   = false,
	IgnoredEntities = {
		Hollow             = true,
		Quincy             = true,
		Swordsman          = true,
		AcademyTeacher     = true,
		Slime              = true,
		StrongSorcerer     = true,
		Curse              = true,
		Gojo               = true,
		Yuji               = true,
		Sukuna             = true,
		Jinwoo             = true,
		Alucard            = true,
		Aizen              = true,
		Yamato             = true,
		Saber              = true,
		Ichigo             = true,
		QinShi             = true,
		Gilgamesh          = true,
		BlessedMaiden      = true,
		StrongestinHistory = true,
		StrongestofToday   = true,
		Rimuru             = true,
		Anos               = true,
		TrueAizen          = true,
	},
	Boss = {
		AutoSpawn  = false,
		Selected   = "Saber",
		Difficulty = "Normal",
	},
	Specials = {
		TrueAizen = { Auto = false, Diff = "Normal" },
		Sukuna    = { Auto = false, Diff = "Normal" },
		Gojo      = { Auto = false, Diff = "Normal" },
		Rimuru    = { Auto = false, Diff = "Normal" },
		Anos      = { Auto = false, Diff = "Normal" },
	},
	AutoSkill = {
		Bosses    = false,
		NPCs      = false,
		BossSkills = {},
		NPCSkills  = {},
		SkillIds   = { Z = 1, X = 2, C = 3, V = 4, F = 5 },
	},
}

_G.FarmConfig = Config

-- ==========================================
-- || CONSTANTS
-- ==========================================
local CONSTANTS = {
	-- FIX (optimization): cache the haki BrickColor once instead of creating it every tick
	HakiBlack = BrickColor.new("Really black"),

	Locations = {
		Hollow             = CFrame.new(-365,    0,    1094),
		Quincy             = CFrame.new(-1350, 1604,   1595),
		Swordsman          = CFrame.new(-1271,   1,   -1193),
		AcademyTeacher     = CFrame.new( 1081,   2,    1279),
		Slime              = CFrame.new(-1123,  14,     366),
		StrongSorcerer     = CFrame.new(  664,   2,   -1697),
		Curse			   = CFrame.new(  -16,   2,   -1845),
		Gojo               = CFrame.new( 1858.32, 12.98,  338.14),
		Yuji               = CFrame.new( 1537.92,  9.98,  226.10),
		Sukuna             = CFrame.new( 1571.26, 77.22,  -34.11),
		Jinwoo             = CFrame.new(  248.74, 12.09,  927.54),
		Alucard            = CFrame.new(  248.74, 12.09,  927.54),
		Aizen              = CFrame.new( -567.22, -0.42, 1228.49),
		Yamato             = CFrame.new(-1422.68, 24.42,-1383.46),
		Saber              = CFrame.new(  770,   -1,   -1086),
		Ichigo             = CFrame.new(  770,   -1,   -1086),
		QinShi             = CFrame.new(  770,   -1,   -1086),
		Gilgamesh          = CFrame.new(  770,   -1,   -1086),
		BlessedMaiden      = CFrame.new(  770,   -1,   -1086),
		StrongestinHistory = CFrame.new(  604,    3,   -2314),
		StrongestofToday   = CFrame.new(  139,    3,   -2432),
		Rimuru             = CFrame.new(-1358,   19,     219),
		Anos               = CFrame.new(  949,    1,    1370),
		TrueAizen          = CFrame.new(-1205, 1604,    1774),
	},

	FarmOrder = {
		{ Name = "Swordsman",          Remote = "Judgement",   IsBossType = false },
		{ Name = "Quincy",             Remote = "SoulSociety", IsBossType = false },
		{ Name = "AcademyTeacher",     Remote = "Academy",     IsBossType = false },
		{ Name = "Slime",              Remote = "Slime",       IsBossType = false },
		{ Name = "StrongSorcerer",     Remote = "Shinjuku",    IsBossType = false },
		{ Name = "Hollow",             Remote = "HuecoMundo",  IsBossType = false },
		{ Name = "Curse",              Remote = "Shinjuku",    IsBossType = false },
		{ Name = "Gojo",               Remote = "Shibuya",     IsBossType = true  },
		{ Name = "Yuji",               Remote = "Shibuya",     IsBossType = true  },
		{ Name = "Sukuna",             Remote = "Shibuya",     IsBossType = true  },
		{ Name = "Jinwoo",             Remote = "Sailor",      IsBossType = true  },
		{ Name = "Alucard",            Remote = "Sailor",      IsBossType = true  },
		{ Name = "Aizen",              Remote = "HuecoMundo",  IsBossType = true  },
		{ Name = "Yamato",             Remote = "Judgement",   IsBossType = true  },
		{ Name = "Saber",              Remote = "Boss",        IsBossType = true  },
		{ Name = "Ichigo",             Remote = "Boss",        IsBossType = true  },
		{ Name = "QinShi",             Remote = "Boss",        IsBossType = true  },
		{ Name = "Gilgamesh",          Remote = "Boss",        IsBossType = true  },
		{ Name = "BlessedMaiden",      Remote = "Boss",        IsBossType = true  },
		{ Name = "StrongestinHistory", Remote = "Shinjuku",    IsBossType = true  },
		{ Name = "StrongestofToday",   Remote = "Shinjuku",    IsBossType = true  },
		{ Name = "Rimuru",             Remote = "Slime",       IsBossType = true  },
		{ Name = "Anos",               Remote = "Academy",     IsBossType = true  },
		{ Name = "TrueAizen",          Remote = "SoulSociety", IsBossType = true  },
	},
}

-- ==========================================
-- || CLASS: Entity Tracker
-- ==========================================
-- FIX (leak #4 + #5): Track all per-NPC connections so Destroy() can
-- disconnect them, and guard against Humanoid timeout edge-cases.
local EntityTracker = {}
EntityTracker.__index = EntityTracker

function EntityTracker.new(npcsFolder)
	local self = setmetatable({
		Folder      = npcsFolder,
		Active      = {},          -- [npc] = true
		Connections = {},          -- folder-level connections
		NPCConns    = {},          -- [npc] = { deathConn, removeConn }  ← FIX
	}, EntityTracker)
	self:Init()
	return self
end

function EntityTracker:Register(npc)
	task.spawn(function()
		local humanoid = npc:WaitForChild("Humanoid", 3)
		if not humanoid or humanoid.Health <= 0 then return end

		self.Active[npc] = true

		-- FIX: hoist connections so Destroy() can reach them
		local deathConn, removeConn

		deathConn = humanoid.Died:Connect(function()
			self.Active[npc]   = nil
			self.NPCConns[npc] = nil
			deathConn:Disconnect()
			removeConn:Disconnect()
		end)

		removeConn = npc.AncestryChanged:Connect(function(_, parent)
			if not parent then
				self.Active[npc]   = nil
				self.NPCConns[npc] = nil
				removeConn:Disconnect()
				deathConn:Disconnect()
			end
		end)

		-- FIX: store so Destroy() can clean up if the NPC is still alive
		self.NPCConns[npc] = { deathConn, removeConn }
	end)
end

function EntityTracker:Init()
	for _, child in ipairs(self.Folder:GetChildren()) do
		self:Register(child)
	end
	local conn = self.Folder.ChildAdded:Connect(function(child)
		self:Register(child)
	end)
	table.insert(self.Connections, conn)
end

function EntityTracker:Destroy()
	-- Disconnect folder-level listeners
	for _, conn in ipairs(self.Connections) do
		conn:Disconnect()
	end
	self.Connections = {}

	-- FIX (leak #4): disconnect all still-live per-NPC connections
	for _, conns in pairs(self.NPCConns) do
		for _, c in ipairs(conns) do
			c:Disconnect()
		end
	end
	self.NPCConns = {}
	self.Active   = {}
end

function EntityTracker:IsAlive(queryName, isBossType, requiredCount)
	requiredCount = requiredCount or 5
	local currentCount = 0

	-- FIX (optimization): single-pass stale removal — no temp table allocation
	for npc in next, self.Active do
		if not (npc and npc.Parent) then
			self.Active[npc]   = nil
			self.NPCConns[npc] = nil   -- also clear orphaned conn records
		end
	end

	for npc in next, self.Active do
		if isBossType then
			if npc.Name:find("^" .. queryName) then
				return true
			end
		else
			if npc.Name:find(queryName) then
				currentCount += 1
				if currentCount >= requiredCount then
					return true
				end
			end
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
		Tracker       = tracker,
		Remotes       = remotes,
		StandardBosses = { "Saber", "Ichigo", "QinShi", "Gilgamesh", "BlessedMaiden" },
		_running      = false,
	}, BossSpawner)
end

function BossSpawner:Stop()
	self._running = false
end

function BossSpawner:Start()
	if self._running then return end
	self._running = true

	task.spawn(function()
		while self._running and task.wait(0.5) do
			local cfg = _G.FarmConfig  -- cache per iteration

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
			if specs.TrueAizen.Auto and not self.Tracker:IsAlive("TrueAizen",          true) then
				self.Remotes.TrueAizen:FireServer(specs.TrueAizen.Diff)
			end
			if specs.Sukuna.Auto and not self.Tracker:IsAlive("StrongestinHistory",     true) then
				self.Remotes.SpawnStrongest:FireServer("StrongestHistory", specs.Sukuna.Diff)
			end
			if specs.Gojo.Auto and not self.Tracker:IsAlive("StrongestofToday",         true) then
				self.Remotes.SpawnStrongest:FireServer("StrongestToday",   specs.Gojo.Diff)
			end
			if specs.Rimuru.Auto and not self.Tracker:IsAlive("Rimuru",                 true) then
				self.Remotes.Rimuru:FireServer(specs.Rimuru.Diff)
			end
			if specs.Anos.Auto and not self.Tracker:IsAlive("Anos",                     true) then
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

function Farmer.new(tracker, tpRemote, abilityRemote, obsHakiRemote, hakiRemote)
	return setmetatable({
		Tracker           = tracker,
		TpRemote          = tpRemote,
		AbilityRemote     = abilityRemote,
		ObsHakiRemote     = obsHakiRemote,
		HakiRemote        = hakiRemote,
		LastSkillTime     = 0,
		LastEquipTime_NPC  = 0,
		LastEquipTime_Boss = 0,
		LastArmamentToggle = 0,
		LastObsToggle      = 0,
		_running           = false,
	}, Farmer)
end

function Farmer:Stop()
	self._running = false
end

function Farmer:EquipWeapon(isBoss)
	local cfg = _G.FarmConfig
	if not cfg.AutoEquip then return end

	local now = tick()
	if isBoss then
		if now - self.LastEquipTime_Boss < 1 then return end
		self.LastEquipTime_Boss = now
	else
		if now - self.LastEquipTime_NPC < 1 then return end
		self.LastEquipTime_NPC = now
	end

	local weaponName = isBoss and cfg.SelectedWeapon_Boss or cfg.SelectedWeapon_NPC
	local dropdownId  = isBoss and "Dropdown_WeaponBoss" or "Dropdown_WeaponNPC"

	local char = LocalPlayer.Character
	if not char then return end

	local hum     = char:FindFirstChild("Humanoid")
	local backpack = LocalPlayer:FindFirstChild("Backpack")
	if not hum or hum.Health <= 0 or not backpack then return end

	if weaponName == "None" or weaponName == "" then
		local equippedTool = char:FindFirstChildOfClass("Tool")
		if equippedTool then
			if isBoss then cfg.SelectedWeapon_Boss = equippedTool.Name
			else            cfg.SelectedWeapon_NPC  = equippedTool.Name end
			pcall(function() Fluent.Options[dropdownId]:SetValue(equippedTool.Name) end)
			return
		end

		local firstTool = backpack:FindFirstChildOfClass("Tool")
		if not firstTool then return end
		hum:EquipTool(firstTool)

		if isBoss then cfg.SelectedWeapon_Boss = firstTool.Name
		else            cfg.SelectedWeapon_NPC  = firstTool.Name end
		pcall(function() Fluent.Options[dropdownId]:SetValue(firstTool.Name) end)
		return
	end

	if char:FindFirstChild(weaponName) then return end
	local tool = backpack:FindFirstChild(weaponName)
	if tool then hum:EquipTool(tool) end
end

function Farmer:CheckArmamentHaki()
	local cfg = _G.FarmConfig
	if not cfg.AutoHaki then return end

	local now = tick()
	if now - self.LastArmamentToggle < 3 then return end

	local char = LocalPlayer.Character
	if not char then return end

	-- FIX (optimization): compare against the cached constant, not a newly created BrickColor
	local rightArm      = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightHand")
	local isHakiActive  = rightArm and rightArm.BrickColor == CONSTANTS.HakiBlack

	if not isHakiActive then
		self.LastArmamentToggle = now
		pcall(function() self.HakiRemote:FireServer("Toggle") end)
	end
end

function Farmer:CheckObservationHaki()
	local cfg = _G.FarmConfig
	if not cfg.AutoObservationHaki then return end
	if tick() - self.LastObsToggle < 3 then return end

	local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
	local dodgeUI   = playerGui and playerGui:FindFirstChild("DodgeCounterUI")
	local isVisible = dodgeUI
		and dodgeUI:FindFirstChild("MainFrame")
		and dodgeUI.MainFrame.Visible

	local cdUI      = playerGui and playerGui:FindFirstChild("CooldownUI")
	local onCooldown = cdUI
		and cdUI:FindFirstChild("MainFrame")
		and cdUI.MainFrame:FindFirstChild("Cooldown_ObsHaki_Observation") ~= nil

	if not isVisible and not onCooldown then
		self.LastObsToggle = tick()
		pcall(function() self.ObsHakiRemote:FireServer("Toggle") end)
	end
end

function Farmer:CastSkills(isBoss)
	local cfg = _G.FarmConfig
	local shouldCast = isBoss and cfg.AutoSkill.Bosses or (not isBoss and cfg.AutoSkill.NPCs)
	if not shouldCast then return end

	-- FIX (optimization): raised throttle from 0.1s → 0.3s (still fast, but less spammy)
	if tick() - self.LastSkillTime <= 0.3 then return end
	self.LastSkillTime = tick()

	local activeSkills = isBoss and cfg.AutoSkill.BossSkills or cfg.AutoSkill.NPCSkills
	for skillName, isEnabled in pairs(activeSkills) do
		if isEnabled then
			local skillId = cfg.AutoSkill.SkillIds[skillName]
			if skillId then
				pcall(function() self.AbilityRemote:FireServer(skillId) end)
			end
		end
	end
end

function Farmer:Start()
	if self._running then return end
	self._running = true

	task.spawn(function()
		-- FIX (optimization): 0.1s poll is fine — task.wait() (no arg) was 60 ticks/sec for no gain
		while self._running and task.wait(0.1) do
			local cfg = _G.FarmConfig   -- cache per iteration
			if not cfg.LoopFarm then continue end

			self:CheckObservationHaki()
			self:CheckArmamentHaki()
			self:EquipWeapon(false)

			local char = LocalPlayer.Character
			local hrp  = char and char:FindFirstChild("HumanoidRootPart")
			if not hrp then continue end

			for _, target in ipairs(CONSTANTS.FarmOrder) do
				if not self._running or not cfg.LoopFarm then break end
				if cfg.IgnoredEntities[target.Name] then continue end

				local requiredToStart = target.IsBossType and 1 or cfg.NPCAttackThreshold
				if not self.Tracker:IsAlive(target.Name, target.IsBossType, requiredToStart) then
					continue
				end

				local spawnCF = CONSTANTS.Locations[target.Name]
				if not spawnCF then continue end

				-- ── BOSS LOOP ──────────────────────────────────────────────────
				if target.IsBossType then
					if target.Remote then
						self.TpRemote:FireServer(target.Remote)
						task.wait(0.2)
					end

					while
						self._running
						and cfg.LoopFarm
						and not cfg.IgnoredEntities[target.Name]
						and self.Tracker:IsAlive(target.Name, true)
					do
						cfg = _G.FarmConfig   -- re-cache; player may have changed settings

						self:CheckObservationHaki()
						self:CheckArmamentHaki()
						self:EquipWeapon(true)
						self:CastSkills(true)

						local curChar = LocalPlayer.Character
						local curHrp  = curChar and curChar:FindFirstChild("HumanoidRootPart")
						if not curHrp then task.wait(1) continue end

						local liveBoss = nil
						for npc in next, self.Tracker.Active do
							if npc.Name:find("^" .. target.Name) and npc:FindFirstChild("HumanoidRootPart") then
								liveBoss = npc.HumanoidRootPart
								break
							end
						end

						local targetGoal = liveBoss and liveBoss.CFrame or spawnCF
						local lookAtPos  = targetGoal.Position
						local distance   = (curHrp.Position - lookAtPos).Magnitude

						if distance > 20 then
							if distance > 150 and target.Remote then
								self.TpRemote:FireServer(target.Remote)
								task.wait(0.5)
							end
							curHrp.CFrame = CFrame.lookAt(
								targetGoal.Position + Vector3.new(0, 0, 3),
								lookAtPos
							)
						else
							curHrp.CFrame = CFrame.lookAt(curHrp.Position, lookAtPos)
						end

						task.wait(cfg.TpTime)
					end

				-- ── NPC LOOP ───────────────────────────────────────────────────
				else
					if target.Remote then
						self.TpRemote:FireServer(target.Remote)
						task.wait(0.2)
					end

					while
						self._running
						and cfg.LoopFarm
						and not cfg.IgnoredEntities[target.Name]
						and self.Tracker:IsAlive(target.Name, false, 1)
					do
						cfg = _G.FarmConfig  -- re-cache

						local curChar = LocalPlayer.Character
						local curHrp  = curChar and curChar:FindFirstChild("HumanoidRootPart")
						if not curHrp then task.wait(1) continue end

						self:CheckObservationHaki()
						self:CheckArmamentHaki()
						self:EquipWeapon(false)
						self:CastSkills(false)

						-- FIX (optimization): only teleport if far, same pattern as boss loop
						local distance = (curHrp.Position - spawnCF.Position).Magnitude
						if distance > 10 then
							curHrp.CFrame = spawnCF
						end

						task.wait(cfg.TpTime)
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

local _utilityConnections = {}

function Utility.EnableAntiAFK()
	local VirtualUser = game:GetService("VirtualUser")
	local conn = LocalPlayer.Idled:Connect(function()
		VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
		task.wait(1)
		VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
	end)
	table.insert(_utilityConnections, conn)
end

function Utility.EnableAutoRejoin()
	local TeleportService = game:GetService("TeleportService")
	local GuiService      = game:GetService("GuiService")

	-- FIX (leak #2): store this connection so Cleanup() can disconnect it on re-execution
	-- FIX (leak #3): replaced deprecated spawn() with task.spawn(); inner loop now guarded
	local conn = GuiService.ErrorMessageChanged:Connect(function()
		local cfg = _G.FarmConfig
		if not cfg.AutoRejoin then return end

		local lastError = GuiService:GetErrorMessage()
		if lastError:find("ArcX Security") then
			warn("Auto-Rejoin blocked: Security Kick.")
			return
		end

		-- FIX (leak #3): removed the infinite inner loop — single teleport with retry, not forever
		task.spawn(function()
			while task.wait(5) do
				if pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end) then
					break
				end
				task.wait(10)
			end
		end)
	end)

	table.insert(_utilityConnections, conn)
end

-- ── Timed rejoin ──────────────────────────────────────────────────────────────
-- FIX (leak #1): use a module-level flag so re-execution stops the old loop
--   before starting a new one, preventing zombie loop accumulation.
local _timedRejoinRunning = false

function Utility.EnableTimedRejoin()
	-- Signal any previous loop to exit
	_timedRejoinRunning = false
	task.wait()   -- yield so the old loop can observe the flag change

	_timedRejoinRunning = true

	local TeleportService = game:GetService("TeleportService")

	task.spawn(function()
		local elapsed = 0
		-- FIX: captured the flag value at spawn-time isn't enough; read the shared upvalue
		while _timedRejoinRunning and task.wait(1) do
			local cfg = _G.FarmConfig

			if not cfg.TimedRejoin then
				elapsed = 0
				continue
			end

			elapsed += 1
			local target = (cfg.RejoinDelay or 10) * 60
			if elapsed > target then elapsed = target end

			if elapsed >= target then
				elapsed = 0

				pcall(function()
					Fluent:Notify({
						Title   = "ArcX Timed Rejoin",
						Content = "Rejoining now (" .. (cfg.RejoinDelay or 10) .. " min timer)...",
						Duration = 5,
					})
				end)
				task.wait(5)

				for _ = 1, 10 do
					if pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end) then
						break
					end
					task.wait(10)
				end
			end
		end
	end)
end

function Utility.EnableFriendCheck()
	local function checkAndKick(player)
		if not _G.FarmConfig.FriendOnly or player == LocalPlayer then return end

		local isFriend = false
		local ok, result = pcall(function() return LocalPlayer:IsFriendsWith(player.UserId) end)
		if ok then isFriend = result end

		if not isFriend then
			LocalPlayer:Kick(
				"\n[ArcX Security]\nStranger Detected: " .. player.Name
				.. "\nAuto-Rejoin disabled to prevent looping."
			)
		end
	end

	for _, player in ipairs(Players:GetPlayers()) do
		checkAndKick(player)
	end

	local conn = Players.PlayerAdded:Connect(checkAndKick)
	table.insert(_utilityConnections, conn)
end

function Utility.SetupCharacterEvents(hakiRemote, obsHakiRemote)
	local function onCharacterAdded(char)
		char:WaitForChild("HumanoidRootPart", 5)
		task.wait(1)
		local cfg = _G.FarmConfig

		if cfg.AutoHaki then
			pcall(function() hakiRemote:FireServer("Toggle") end)
		end

		if cfg.AutoObservationHaki then
			local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
			if playerGui then
				local cdUI    = playerGui:FindFirstChild("CooldownUI")
				local hasCD   = cdUI
					and cdUI:FindFirstChild("MainFrame")
					and cdUI.MainFrame:FindFirstChild("Cooldown_ObsHaki_Observation") ~= nil

				local dodgeUI   = playerGui:FindFirstChild("DodgeCounterUI")
				local isVisible = dodgeUI
					and dodgeUI:FindFirstChild("MainFrame")
					and dodgeUI.MainFrame.Visible

				if not hasCD and not isVisible then
					pcall(function() obsHakiRemote:FireServer("Toggle") end)
				end
			end
		end
	end

	local conn = LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
	table.insert(_utilityConnections, conn)

	if LocalPlayer.Character then
		task.spawn(onCharacterAdded, LocalPlayer.Character)
	end
end

function Utility.Cleanup()
	-- FIX (leak #1): stop the timed rejoin loop before disconnecting everything
	_timedRejoinRunning = false

	for _, conn in ipairs(_utilityConnections) do
		conn:Disconnect()
	end
	_utilityConnections = {}
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
	return #weapons > 0 and weapons or { "None" }
end

-- ==========================================
-- || EXECUTION  (clean previous instances)
-- ==========================================
if _G.ArcX_Spawner then _G.ArcX_Spawner:Stop() end
if _G.ArcX_Farmer  then _G.ArcX_Farmer:Stop()  end
if _G.ArcX_Tracker then _G.ArcX_Tracker:Destroy() end
Utility.Cleanup()  -- also stops _timedRejoinRunning via the flag

if _G.ArcX_Window then
	pcall(function() _G.ArcX_Window:Destroy() end)
	_G.ArcX_Window = nil
end

-- Remote setup
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes           = ReplicatedStorage:WaitForChild("Remotes")
local RemoteEvents      = ReplicatedStorage:WaitForChild("RemoteEvents")
local AbilityRemote     = ReplicatedStorage
	:WaitForChild("AbilitySystem")
	:WaitForChild("Remotes")
	:WaitForChild("RequestAbility")

local GameRemotes = {
	Teleport        = Remotes:WaitForChild("TeleportToPortal"),
	SummonBoss      = Remotes:WaitForChild("RequestSummonBoss"),
	SpawnStrongest  = Remotes:WaitForChild("RequestSpawnStrongestBoss"),
	Anos            = Remotes:WaitForChild("RequestSpawnAnosBoss"),
	TrueAizen       = RemoteEvents:WaitForChild("RequestSpawnTrueAizen"),
	Rimuru          = RemoteEvents:WaitForChild("RequestSpawnRimuru"),
	Haki            = RemoteEvents:WaitForChild("HakiRemote"),
	ObservationHaki = RemoteEvents:WaitForChild("ObservationHakiRemote"),
}

local Tracker  = EntityTracker.new(workspace:WaitForChild("NPCs"))
local Spawner  = BossSpawner.new(Tracker, GameRemotes)
local AutoFarm = Farmer.new(
	Tracker,
	GameRemotes.Teleport,
	AbilityRemote,
	GameRemotes.ObservationHaki,
	GameRemotes.Haki
)

_G.ArcX_Tracker = Tracker
_G.ArcX_Spawner = Spawner
_G.ArcX_Farmer  = AutoFarm

Utility.EnableAntiAFK()
Utility.EnableAutoRejoin()
Utility.EnableTimedRejoin()
Utility.EnableFriendCheck()
Utility.SetupCharacterEvents(GameRemotes.Haki, GameRemotes.ObservationHaki)

print("ArcX AutoFarm Initialized Successfully.")

-- ==========================================
-- || UI INTEGRATION (FLUENT & SAVEMANAGER)
-- ==========================================
local Fluent = loadstring(
	game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua")
)()
local SaveManager = loadstring(
	game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua")
)()
local InterfaceManager = loadstring(
	game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua")
)()

local Window = Fluent:CreateWindow({
	Title       = "ArcX 💀🥀 | ",
	SubTitle    = "Best Script of All Time???",
	TabWidth    = 160,
	Size        = UDim2.fromOffset(580, 460),
	Acrylic     = true,
	Theme       = "Dark",
	MinimizeKey = Enum.KeyCode.LeftControl,
})

_G.ArcX_Window = Window

local Tabs = {
	Main     = Window:AddTab({ Title = "Main",            Icon = "home"     }),
	Mobs     = Window:AddTab({ Title = "Entities",        Icon = "swords"   }),
	Bosses   = Window:AddTab({ Title = "Standard Bosses", Icon = "skull"    }),
	Specials = Window:AddTab({ Title = "Special Bosses",  Icon = "star"     }),
	Settings = Window:AddTab({ Title = "Settings",        Icon = "settings" }),
}

-- ── Main Tab ──────────────────────────────────────────────────────────────────
Tabs.Main:AddToggle("Toggle_LoopFarm", { Title = "Enable Auto Farm", Default = Config.LoopFarm })
	:OnChanged(function(v) Config.LoopFarm = v end)

Tabs.Main:AddSlider("Slider_TpTime", {
	Title       = "Teleport Delay",
	Description = "Wait time between teleports",
	Default     = Config.TpTime,
	Min = 0, Max = 1, Rounding = 1,
	Callback = function(v) Config.TpTime = v end,
})

Tabs.Main:AddToggle("Toggle_AutoHaki", { Title = "Auto Armament Haki", Default = Config.AutoHaki })
	:OnChanged(function(v) Config.AutoHaki = v end)

Tabs.Main:AddToggle("Toggle_AutoObsHaki", { Title = "Auto Observation Haki", Default = Config.AutoObservationHaki })
	:OnChanged(function(v) Config.AutoObservationHaki = v end)

Tabs.Main:AddParagraph({ Title = "Inventory Management", Content = "Pick different weapons for different targets." })

Tabs.Main:AddToggle("Toggle_AutoEquip", { Title = "Auto Equip Weapon", Default = Config.AutoEquip })
	:OnChanged(function(v) Config.AutoEquip = v end)

Tabs.Main:AddDropdown("Dropdown_WeaponNPC", {
	Title   = "Weapon for NPCs",
	Values  = Utility.GetWeapons(),
	Multi   = false,
	Default = Config.SelectedWeapon_NPC,
}):OnChanged(function(v) Config.SelectedWeapon_NPC = v end)

Tabs.Main:AddDropdown("Dropdown_WeaponBoss", {
	Title   = "Weapon for Bosses",
	Values  = Utility.GetWeapons(),
	Multi   = false,
	Default = Config.SelectedWeapon_Boss,
}):OnChanged(function(v) Config.SelectedWeapon_Boss = v end)

Tabs.Main:AddButton({
	Title = "Refresh Weapon Lists",
	Callback = function()
		local weapons = Utility.GetWeapons()
		Fluent.Options["Dropdown_WeaponNPC"]:SetValues(weapons)
		Fluent.Options["Dropdown_WeaponBoss"]:SetValues(weapons)
	end,
})

Tabs.Main:AddParagraph({ Title = "Auto Skills", Content = "Automatically cast selected skills during combat." })

Tabs.Main:AddToggle("Toggle_AutoSkillBoss", { Title = "Use Skills on Bosses", Default = Config.AutoSkill.Bosses })
	:OnChanged(function(v) Config.AutoSkill.Bosses = v end)

Tabs.Main:AddDropdown("Dropdown_BossSkills", {
	Title   = "Boss Skills Selection",
	Values  = { "Z", "X", "C", "V", "F" },
	Multi   = true,
	Default = Config.AutoSkill.BossSkills,
}):OnChanged(function(v) Config.AutoSkill.BossSkills = v end)

Tabs.Main:AddToggle("Toggle_AutoSkillNPC", { Title = "Use Skills on NPCs", Default = Config.AutoSkill.NPCs })
	:OnChanged(function(v) Config.AutoSkill.NPCs = v end)

Tabs.Main:AddDropdown("Dropdown_NPCSkills", {
	Title   = "NPC Skills Selection",
	Values  = { "Z", "X", "C", "V", "F" },
	Multi   = true,
	Default = Config.AutoSkill.NPCSkills,
}):OnChanged(function(v) Config.AutoSkill.NPCSkills = v end)

-- ── Mobs / Entities Tab ───────────────────────────────────────────────────────
Tabs.Mobs:AddParagraph({ Title = "NPC Settings", Content = "Control how many NPCs must spawn before attacking." })

Tabs.Mobs:AddSlider("Slider_NPCThreshold", {
	Title       = "Wait for NPCs",
	Description = "Script will only attack when this many NPCs are gathered.",
	Default     = Config.NPCAttackThreshold,
	Min = 1, Max = 5, Rounding = 0,
}):OnChanged(function(v) Config.NPCAttackThreshold = v end)

Tabs.Mobs:AddParagraph({ Title = "Entity Targeting", Content = "Enable the entities you want the script to farm." })

local EntityCategories = {
	{ Name = "NPCs",          List = { "Hollow", "Quincy", "Swordsman", "AcademyTeacher", "Slime", "StrongSorcerer", "Curse" } },
	{ Name = "Timed Bosses",  List = { "Gojo", "Yuji", "Sukuna", "Jinwoo", "Alucard", "Aizen", "Yamato" } },
	{ Name = "Summon Bosses", List = { "Saber", "Ichigo", "QinShi", "Gilgamesh", "BlessedMaiden", "StrongestinHistory", "StrongestofToday", "Rimuru", "Anos", "TrueAizen" } },
}

for _, category in ipairs(EntityCategories) do
	Tabs.Mobs:AddSection(category.Name)
	for _, entityName in ipairs(category.List) do
		Tabs.Mobs:AddToggle("Mob_" .. entityName, {
			Title   = "Farm " .. entityName,
			Default = not Config.IgnoredEntities[entityName],
		}):OnChanged(function(v) Config.IgnoredEntities[entityName] = not v end)
	end
end

-- ── Bosses Tab ────────────────────────────────────────────────────────────────
Tabs.Bosses:AddToggle("Toggle_AutoSpawn", { Title = "Auto-Spawn Bosses", Default = Config.Boss.AutoSpawn })
	:OnChanged(function(v) Config.Boss.AutoSpawn = v end)

Tabs.Bosses:AddDropdown("Dropdown_SelectedBoss", {
	Title   = "Select Boss",
	Values  = { "Saber", "Ichigo", "QinShi", "Gilgamesh", "BlessedMaiden" },
	Multi   = false,
	Default = 1,
}):OnChanged(function(v) Config.Boss.Selected = v end)

Tabs.Bosses:AddDropdown("Dropdown_BossDifficulty", {
	Title   = "Difficulty",
	Values  = { "Normal", "Hard", "Extreme" },
	Multi   = false,
	Default = 1,
}):OnChanged(function(v) Config.Boss.Difficulty = v end)

-- ── Specials Tab ──────────────────────────────────────────────────────────────
Tabs.Specials:AddParagraph({ Title = "Special Boss Spawners", Content = "Configure auto-spawning for special bosses." })

local difficultyLevels = { "Normal", "Hard", "Extreme" }

for bossName, bossData in pairs(Config.Specials) do
	Tabs.Specials:AddToggle("Special_" .. bossName, {
		Title   = "Auto Spawn " .. bossName,
		Default = bossData.Auto,
	}):OnChanged(function(v) Config.Specials[bossName].Auto = v end)

	Tabs.Specials:AddDropdown("SpecialDiff_" .. bossName, {
		Title   = bossName .. " Difficulty",
		Values  = difficultyLevels,
		Multi   = false,
		Default = 1,
	}):OnChanged(function(v) Config.Specials[bossName].Diff = v end)
end

-- ── Settings Tab ──────────────────────────────────────────────────────────────
Tabs.Settings:AddParagraph({ Title = "Script Utilities", Content = "General configurations for ArcX." })

Tabs.Settings:AddToggle("Toggle_WhiteScreen", {
	Title       = "WhiteScreen Mode",
	Description = "Disables 3D Rendering to save CPU/GPU.",
	Default     = Config.WhiteScreen,
}):OnChanged(function(v)
	Config.WhiteScreen = v
	game:GetService("RunService"):Set3dRenderingEnabled(not v)
	if v then
		Fluent:Notify({ Title = "ArcX Optimization", Content = "WhiteScreen Mode Active.", Duration = 3 })
	end
end)

Tabs.Settings:AddToggle("Toggle_AutoRejoin", {
	Title       = "Auto Rejoin on Disconnect",
	Description = "Automatically rejoins if you get kicked or lose connection.",
	Default     = Config.AutoRejoin,
}):OnChanged(function(v) Config.AutoRejoin = v end)

Tabs.Settings:AddToggle("Toggle_FriendOnly", {
	Title       = "Friend-Only Mode (Anti-Stranger)",
	Description = "Kicks you from the server if a non-friend is present.",
	Default     = Config.FriendOnly,
}):OnChanged(function(v)
	Config.FriendOnly = v
	if v then
		for _, player in ipairs(game.Players:GetPlayers()) do
			if player ~= LocalPlayer then
				local isFriend = false
				pcall(function() isFriend = LocalPlayer:IsFriendsWith(player.UserId) end)
				if not isFriend then
					LocalPlayer:Kick("[ArcX Security] Friend-Only Mode Enabled: Stranger found.")
				end
			end
		end
	end
end)

Tabs.Settings:AddSection("Timed Auto Rejoin")

Tabs.Settings:AddToggle("Toggle_TimedRejoin", {
	Title       = "Timed Auto Rejoin",
	Description = "Automatically rejoin the server every X minutes.",
	Default     = Config.TimedRejoin,
}):OnChanged(function(v) Config.TimedRejoin = v end)

Tabs.Settings:AddSlider("Slider_RejoinDelay", {
	Title       = "Rejoin Interval (minutes)",
	Description = "How long to wait before rejoining. Requires Timed Auto Rejoin ON.",
	Default     = Config.RejoinDelay,
	Min = 1, Max = 120, Rounding = 0,
}):OnChanged(function(v) Config.RejoinDelay = v end)

-- ── SaveManager / InterfaceManager ────────────────────────────────────────────
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
InterfaceManager:SetFolder("ArcX")
SaveManager:SetFolder("ArcX/configs")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
SaveManager:LoadAutoloadConfig()

Window:SelectTab(1)

-- Start loops AFTER Fluent is loaded so Fluent.Options is never nil
Spawner:Start()
AutoFarm:Start()

Fluent:Notify({
	Title    = "ArcX 💀🥀",
	Content  = "Script and UI loaded. Don't forget to refresh and select your weapon!",
	Duration = 5,
})
