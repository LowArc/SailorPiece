-- ============================================================
-- MacUI.lua  —  macOS-style Roblox UI Library
-- Compatible API surface: CreateWindow / AddTab / AddSection /
--   AddParagraph / AddToggle / AddSlider / AddDropdown /
--   AddButton / AddInput / Notify
-- ============================================================

local TweenService  = game:GetService("TweenService")
local UserInput     = game:GetService("UserInputService")
local RunService    = game:GetService("RunService")
local Players       = game:GetService("Players")
local LocalPlayer   = Players.LocalPlayer

-- ── Palette ──────────────────────────────────────────────────
local C = {
	WinBG     = Color3.fromHex("16161A"),
	Sidebar   = Color3.fromHex("111114"),
	Content   = Color3.fromHex("1C1C22"),
	Element   = Color3.fromHex("242428"),
	ElementHv = Color3.fromHex("2C2C32"),
	Accent    = Color3.fromHex("4F8EF7"),
	AccentDim = Color3.fromHex("2A4F9E"),
	Border    = Color3.fromRGB(255, 255, 255),
	TextPri   = Color3.fromHex("F0F0F5"),
	TextSec   = Color3.fromHex("7A7A8A"),
	ToggleOff = Color3.fromHex("3A3A42"),
	Success   = Color3.fromHex("30D158"),
	Warning   = Color3.fromHex("FFD60A"),
	Danger    = Color3.fromHex("FF453A"),
	TitleBar  = Color3.fromHex("0E0E12"),
	NavActive = Color3.fromHex("1E1E28"),
	TrafficR  = Color3.fromHex("FF5F57"),
	TrafficY  = Color3.fromHex("FEBC2E"),
	TrafficG  = Color3.fromHex("28C840"),
}

local FONT_SEMI  = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold)
local FONT_MED   = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium)
local FONT_REG   = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular)

local TI_FAST    = TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TI_MED     = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TI_SLOW    = TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

-- ── Helpers ───────────────────────────────────────────────────
local function New(class, props, children)
	local inst = Instance.new(class)
	for k, v in pairs(props or {}) do inst[k] = v end
	for _, c in ipairs(children or {}) do c.Parent = inst end
	return inst
end

local function Tween(inst, info, goals)
	TweenService:Create(inst, info, goals):Play()
end

local function MakeCorner(r)
	return New("UICorner", { CornerRadius = UDim.new(0, r or 8) })
end

local function MakePadding(t, b, l, r)
	return New("UIPadding", {
		PaddingTop    = UDim.new(0, t or 0),
		PaddingBottom = UDim.new(0, b or 0),
		PaddingLeft   = UDim.new(0, l or 0),
		PaddingRight  = UDim.new(0, r or 0),
	})
end

local function MakeStroke(color, thickness, trans)
	return New("UIStroke", {
		Color       = color or C.Border,
		Thickness   = thickness or 1,
		Transparency = trans or 0.92,
	})
end

local function MakeListLayout(padding, dir, align)
	return New("UIListLayout", {
		Padding           = UDim.new(0, padding or 6),
		FillDirection     = dir   or Enum.FillDirection.Vertical,
		HorizontalAlignment = align or Enum.HorizontalAlignment.Left,
		SortOrder         = Enum.SortOrder.LayoutOrder,
	})
end

-- ── MacUI Table ───────────────────────────────────────────────
local MacUI = {}
MacUI.__index = MacUI

-- ════════════════════════════════════════════════════════════
-- Window
-- ════════════════════════════════════════════════════════════
function MacUI:CreateWindow(opts)
	opts = opts or {}
	local title    = opts.Title       or "MacUI"
	local subtitle = opts.SubTitle    or ""
	local winSize  = opts.Size        or UDim2.fromOffset(620, 480)
	local minKey   = opts.MinimizeKey or Enum.KeyCode.LeftControl

	-- Root ScreenGui
	local gui = New("ScreenGui", {
		Name             = "MacUI_" .. title,
		ResetOnSpawn     = false,
		ZIndexBehavior   = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset   = true,
	})
	local ok = pcall(function() gui.Parent = game:GetService("CoreGui") end)
	if not ok then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

	-- Main window frame
	local vp = game:GetService("Workspace").CurrentCamera.ViewportSize
	local winFrame = New("Frame", {
		Name            = "Window",
		Size            = winSize,
		Position        = UDim2.fromOffset(
			math.floor(vp.X / 2 - winSize.X.Offset / 2),
			math.floor(vp.Y / 2 - winSize.Y.Offset / 2)
		),
		BackgroundColor3 = C.WinBG,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent          = gui,
	}, { MakeCorner(12), MakeStroke(C.Border, 1, 0.88) })

	-- ── Title bar ──────────────────────────────────────────────
	local titleBar = New("Frame", {
		Name             = "TitleBar",
		Size             = UDim2.new(1, 0, 0, 36),
		BackgroundColor3 = C.TitleBar,
		BorderSizePixel  = 0,
		Parent           = winFrame,
	})
	-- Traffic lights
	local lights = { { C.TrafficR }, { C.TrafficY }, { C.TrafficG } }
	for i, lc in ipairs(lights) do
		New("Frame", {
			Size             = UDim2.fromOffset(12, 12),
			Position         = UDim2.fromOffset(12 + (i - 1) * 20, 12),
			BackgroundColor3 = lc[1],
			BorderSizePixel  = 0,
			Parent           = titleBar,
		}, { MakeCorner(6) })
	end
	-- Title
	New("TextLabel", {
		Text            = title .. "  " .. subtitle,
		FontFace        = FONT_MED,
		TextSize        = 13,
		TextColor3      = C.TextSec,
		BackgroundTransparency = 1,
		Size            = UDim2.new(1, -160, 1, 0),
		Position        = UDim2.fromOffset(75, 0),
		TextXAlignment  = Enum.TextXAlignment.Left,
		Parent          = titleBar,
	})
	-- Separator under title bar
	New("Frame", {
		Size             = UDim2.new(1, 0, 0, 1),
		Position         = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = C.Border,
		BackgroundTransparency = 0.88,
		BorderSizePixel  = 0,
		Parent           = titleBar,
	})

	-- ── Sidebar ────────────────────────────────────────────────
	local sidebar = New("Frame", {
		Name             = "Sidebar",
		Size             = UDim2.new(0, 160, 1, -36),
		Position         = UDim2.new(0, 0, 0, 36),
		BackgroundColor3 = C.Sidebar,
		BorderSizePixel  = 0,
		Parent           = winFrame,
	})
	New("Frame", {  -- right border
		Size             = UDim2.new(0, 1, 1, 0),
		Position         = UDim2.new(1, 0, 0, 0),
		BackgroundColor3 = C.Border,
		BackgroundTransparency = 0.88,
		BorderSizePixel  = 0,
		Parent           = sidebar,
	})
	local navList = New("ScrollingFrame", {
		Size             = UDim2.new(1, 0, 1, -12),
		Position         = UDim2.fromOffset(0, 12),
		BackgroundTransparency = 1,
		BorderSizePixel  = 0,
		ScrollBarThickness = 0,
		CanvasSize       = UDim2.fromScale(0, 0),
		Parent           = sidebar,
	}, { MakeListLayout(2) })

	-- ── Content pane ───────────────────────────────────────────
	local contentHolder = New("Frame", {
		Name             = "ContentHolder",
		Size             = UDim2.new(1, -161, 1, -36),
		Position         = UDim2.fromOffset(161, 36),
		BackgroundColor3 = C.Content,
		BorderSizePixel  = 0,
		ClipsDescendants = true,
		Parent           = winFrame,
	})

	-- ── Drag ───────────────────────────────────────────────────
	local dragging, dragStart, startPos = false, nil, nil
	titleBar.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging  = true
			dragStart = inp.Position
			startPos  = winFrame.Position
		end
	end)
	UserInput.InputChanged:Connect(function(inp)
		if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = inp.Position - dragStart
			winFrame.Position = UDim2.fromOffset(
				startPos.X.Offset + delta.X,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
	UserInput.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	-- ── Minimize ───────────────────────────────────────────────
	local minimized = false
	UserInput.InputBegan:Connect(function(inp)
		if inp.KeyCode == minKey and not UserInput:GetFocusedTextBox() then
			minimized = not minimized
			winFrame.Visible = not minimized
		end
	end)

	-- ── Notify ─────────────────────────────────────────────────
	local notifHolder = New("Frame", {
		Size             = UDim2.fromOffset(280, 0),
		Position         = UDim2.new(1, -292, 0, 8),
		BackgroundTransparency = 1,
		BorderSizePixel  = 0,
		Parent           = gui,
	}, { MakeListLayout(8) })

	-- ── Window object ──────────────────────────────────────────
	local Window = {
		GUI          = gui,
		Frame        = winFrame,
		NavList      = navList,
		ContentHolder = contentHolder,
		Options      = {},   -- id → element object
		_tabs        = {},
		_activeTab   = nil,
		_notifHolder = notifHolder,
	}

	function Window:Notify(opts2)
		local ntitle   = opts2.Title    or ""
		local ncontent = opts2.Content  or ""
		local duration = opts2.Duration or 3

		local card = New("Frame", {
			Size             = UDim2.new(1, 0, 0, 60),
			BackgroundColor3 = C.Element,
			BackgroundTransparency = 0.08,
			BorderSizePixel  = 0,
			AutomaticSize    = Enum.AutomaticSize.Y,
			Parent           = notifHolder,
		}, {
			MakeCorner(10),
			MakeStroke(C.Border, 1, 0.86),
			MakePadding(10, 10, 12, 12),
			New("UIListLayout", {
				Padding       = UDim.new(0, 3),
				SortOrder     = Enum.SortOrder.LayoutOrder,
			}),
		})
		New("TextLabel", {
			Text            = ntitle,
			FontFace        = FONT_SEMI,
			TextSize        = 12,
			TextColor3      = C.TextPri,
			BackgroundTransparency = 1,
			Size            = UDim2.new(1, 0, 0, 16),
			TextXAlignment  = Enum.TextXAlignment.Left,
			LayoutOrder     = 1,
			Parent          = card,
		})
		New("TextLabel", {
			Text            = ncontent,
			FontFace        = FONT_REG,
			TextSize        = 11,
			TextColor3      = C.TextSec,
			BackgroundTransparency = 1,
			Size            = UDim2.new(1, 0, 0, 0),
			AutomaticSize   = Enum.AutomaticSize.Y,
			TextXAlignment  = Enum.TextXAlignment.Left,
			TextWrapped     = true,
			LayoutOrder     = 2,
			Parent          = card,
		})

		-- Slide in
		card.Position = UDim2.fromOffset(280, 0)
		Tween(card, TI_MED, { Position = UDim2.fromOffset(0, 0) })

		task.delay(duration, function()
			Tween(card, TI_MED, { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0) })
			task.wait(0.3)
			card:Destroy()
		end)
	end

	function Window:SelectTab(idx)
		local t = self._tabs[idx]
		if t then t:_activate() end
	end

	function Window:Destroy()
		gui:Destroy()
	end

	-- ── AddTab ─────────────────────────────────────────────────
	function Window:AddTab(opts2)
		local tabTitle = opts2.Title or "Tab"
		local tabIdx   = #self._tabs + 1

		-- Nav button
		local navBtn = New("TextButton", {
			Size             = UDim2.new(1, -16, 0, 30),
			Position         = UDim2.fromOffset(8, 0),
			BackgroundColor3 = C.NavActive,
			BackgroundTransparency = 1,
			BorderSizePixel  = 0,
			Text             = tabTitle,
			FontFace         = FONT_MED,
			TextSize         = 12,
			TextColor3       = C.TextSec,
			TextXAlignment   = Enum.TextXAlignment.Left,
			LayoutOrder      = tabIdx,
			Parent           = navList,
		}, { MakeCorner(7), MakePadding(0, 0, 10, 0) })
		-- Active bar accent
		local navAccent = New("Frame", {
			Size             = UDim2.fromOffset(3, 14),
			Position         = UDim2.new(0, -7, 0.5, -7),
			BackgroundColor3 = C.Accent,
			BackgroundTransparency = 1,
			BorderSizePixel  = 0,
			Parent           = navBtn,
		}, { MakeCorner(2) })

		-- Content scroll frame
		local scroll = New("ScrollingFrame", {
			Size             = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel  = 0,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = C.Accent,
			ScrollBarImageTransparency = 0.5,
			CanvasSize       = UDim2.fromScale(0, 0),
			Visible          = false,
			Parent           = contentHolder,
		}, {
			MakeListLayout(0),
			MakePadding(14, 14, 16, 16),
		})

		-- Auto-size canvas
		local ll = scroll:FindFirstChildOfClass("UIListLayout")
		ll:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			scroll.CanvasSize = UDim2.fromOffset(0, ll.AbsoluteContentSize.Y + 28)
		end)

		-- Tab object
		local Tab = {
			_nav    = navBtn,
			_accent = navAccent,
			_scroll = scroll,
			_window = self,
		}

		function Tab:_activate()
			local win = self._window
			-- Hide all tabs
			for _, t in ipairs(win._tabs) do
				t._scroll.Visible = false
				Tween(t._nav, TI_FAST, { TextColor3 = C.TextSec, BackgroundTransparency = 1 })
				Tween(t._accent, TI_FAST, { BackgroundTransparency = 1 })
			end
			-- Show this tab
			self._scroll.Visible = true
			Tween(self._nav, TI_FAST, { TextColor3 = C.TextPri, BackgroundTransparency = 0.88 })
			Tween(self._accent, TI_FAST, { BackgroundTransparency = 0 })
			win._activeTab = self
		end

		navBtn.MouseButton1Click:Connect(function() Tab:_activate() end)

		-- ── AddSection ───────────────────────────────────────────
		function Tab:AddSection(title)
			local row = New("Frame", {
				Size            = UDim2.new(1, 0, 0, 28),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Parent          = scroll,
			})
			New("TextLabel", {
				Text           = title,
				FontFace       = FONT_SEMI,
				TextSize       = 11,
				TextColor3     = C.TextSec,
				BackgroundTransparency = 1,
				Size           = UDim2.new(1, 0, 1, 0),
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent         = row,
			})
			-- Divider line
			New("Frame", {
				Size            = UDim2.new(1, 0, 0, 1),
				Position        = UDim2.new(0, 0, 1, -1),
				BackgroundColor3 = C.Border,
				BackgroundTransparency = 0.88,
				BorderSizePixel = 0,
				Parent          = row,
			})
		end

		-- ── AddParagraph ─────────────────────────────────────────
		function Tab:AddParagraph(opts3)
			local card = New("Frame", {
				Size            = UDim2.new(1, 0, 0, 0),
				AutomaticSize   = Enum.AutomaticSize.Y,
				BackgroundColor3 = C.Element,
				BorderSizePixel = 0,
				Parent          = scroll,
			}, {
				MakeCorner(8),
				MakeStroke(C.Border, 1, 0.9),
				MakePadding(10, 10, 12, 12),
				New("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }),
			})
			New("TextLabel", {
				Text            = opts3.Title or "",
				FontFace        = FONT_SEMI,
				TextSize        = 12,
				TextColor3      = C.TextPri,
				BackgroundTransparency = 1,
				Size            = UDim2.new(1, 0, 0, 16),
				TextXAlignment  = Enum.TextXAlignment.Left,
				LayoutOrder     = 1,
				Parent          = card,
			})
			local descLabel = New("TextLabel", {
				Text            = opts3.Content or "",
				FontFace        = FONT_REG,
				TextSize        = 11,
				TextColor3      = C.TextSec,
				BackgroundTransparency = 1,
				Size            = UDim2.new(1, 0, 0, 0),
				AutomaticSize   = Enum.AutomaticSize.Y,
				TextXAlignment  = Enum.TextXAlignment.Left,
				TextWrapped     = true,
				LayoutOrder     = 2,
				Parent          = card,
			})
			local obj = {}
			function obj:SetDesc(text) descLabel.Text = text end
			function obj:SetTitle(text)
				local t = card:FindFirstChildOfClass("TextLabel")
				if t then t.Text = text end
			end
			return obj
		end

		-- ── Element builder ───────────────────────────────────────
		local function MakeElement(labelText, descText)
			local row = New("Frame", {
				Size            = UDim2.new(1, 0, 0, 38),
				BackgroundColor3 = C.Element,
				BorderSizePixel = 0,
				Parent          = scroll,
			}, {
				MakeCorner(8),
				MakeStroke(C.Border, 1, 0.9),
				MakePadding(0, 0, 12, 10),
			})
			local label = New("TextLabel", {
				Text            = labelText or "",
				FontFace        = FONT_MED,
				TextSize        = 12,
				TextColor3      = C.TextPri,
				BackgroundTransparency = 1,
				Size            = UDim2.new(0.6, 0, 1, 0),
				TextXAlignment  = Enum.TextXAlignment.Left,
				Parent          = row,
			})
			if descText and descText ~= "" then
				label.Size = UDim2.new(0.6, 0, 0, 18)
				label.Position = UDim2.fromOffset(0, 4)
				New("TextLabel", {
					Text            = descText,
					FontFace        = FONT_REG,
					TextSize        = 10,
					TextColor3      = C.TextSec,
					BackgroundTransparency = 1,
					Size            = UDim2.new(0.6, 0, 0, 14),
					Position        = UDim2.fromOffset(0, 22),
					TextXAlignment  = Enum.TextXAlignment.Left,
					Parent          = row,
				})
				row.Size = UDim2.new(1, 0, 0, 44)
			end
			return row, label
		end

		-- ── AddToggle ─────────────────────────────────────────────
		function Tab:AddToggle(id, opts3)
			local value  = opts3.Default or false
			local cb     = opts3.Callback or function() end
			local row, _ = MakeElement(opts3.Title or "", opts3.Description)

			-- Pill track
			local track = New("Frame", {
				Size            = UDim2.fromOffset(36, 20),
				Position        = UDim2.new(1, -36, 0.5, -10),
				BackgroundColor3 = value and C.Accent or C.ToggleOff,
				BorderSizePixel = 0,
				Parent          = row,
			}, { MakeCorner(10) })
			-- Knob
			local knob = New("Frame", {
				Size            = UDim2.fromOffset(14, 14),
				Position        = value
					and UDim2.fromOffset(19, 3)
					or  UDim2.fromOffset(3, 3),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BorderSizePixel = 0,
				Parent          = track,
			}, { MakeCorner(7) })

			local togObj = { Value = value }

			local function apply(v, silent)
				togObj.Value = v
				Tween(track, TI_FAST, { BackgroundColor3 = v and C.Accent or C.ToggleOff })
				Tween(knob,  TI_FAST, { Position = v
					and UDim2.fromOffset(19, 3)
					or  UDim2.fromOffset(3, 3) })
				if not silent then cb(v) end
			end

			local btn = New("TextButton", {
				Size            = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Text            = "",
				ZIndex          = 2,
				Parent          = row,
			})
			btn.MouseButton1Click:Connect(function()
				apply(not togObj.Value)
			end)

			-- Hover tint
			btn.MouseEnter:Connect(function()  Tween(row, TI_FAST, { BackgroundColor3 = C.ElementHv }) end)
			btn.MouseLeave:Connect(function()  Tween(row, TI_FAST, { BackgroundColor3 = C.Element   }) end)

			function togObj:SetValue(v) apply(v, true) end
			function togObj:OnChanged(fn) cb = fn fn(self.Value) end

			local mt = { OnChanged = togObj.OnChanged }
			mt.__index = mt
			setmetatable(togObj, mt)

			self._window.Options[id] = togObj
			return togObj
		end

		-- ── AddSlider ─────────────────────────────────────────────
		function Tab:AddSlider(id, opts3)
			local minV    = opts3.Min      or 0
			local maxV    = opts3.Max      or 1
			local round   = opts3.Rounding or 1
			local defV    = math.clamp(opts3.Default or minV, minV, maxV)
			local cb      = opts3.Callback or function() end

			local row = New("Frame", {
				Size            = UDim2.new(1, 0, 0, 52),
				BackgroundColor3 = C.Element,
				BorderSizePixel = 0,
				Parent          = scroll,
			}, {
				MakeCorner(8),
				MakeStroke(C.Border, 1, 0.9),
				MakePadding(8, 0, 12, 10),
			})
			local header = New("Frame", {
				Size            = UDim2.new(1, 0, 0, 18),
				BackgroundTransparency = 1,
				Parent          = row,
			})
			New("TextLabel", {
				Text            = opts3.Title or "",
				FontFace        = FONT_MED,
				TextSize        = 12,
				TextColor3      = C.TextPri,
				BackgroundTransparency = 1,
				Size            = UDim2.fromScale(0.7, 1),
				TextXAlignment  = Enum.TextXAlignment.Left,
				Parent          = header,
			})
			local valLabel = New("TextLabel", {
				Text            = tostring(defV),
				FontFace        = FONT_MED,
				TextSize        = 12,
				TextColor3      = C.Accent,
				BackgroundTransparency = 1,
				Size            = UDim2.fromScale(0.3, 1),
				TextXAlignment  = Enum.TextXAlignment.Right,
				Parent          = header,
			})
			-- Rail
			local rail = New("Frame", {
				Size            = UDim2.new(1, 0, 0, 4),
				Position        = UDim2.fromOffset(0, 28),
				BackgroundColor3 = C.ToggleOff,
				BorderSizePixel = 0,
				Parent          = row,
			}, { MakeCorner(2) })
			local fill = New("Frame", {
				Size            = UDim2.new(0, 0, 1, 0),
				BackgroundColor3 = C.Accent,
				BorderSizePixel = 0,
				Parent          = rail,
			}, { MakeCorner(2) })
			local thumb = New("Frame", {
				Size            = UDim2.fromOffset(14, 14),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BorderSizePixel = 0,
				AnchorPoint     = Vector2.new(0.5, 0.5),
				Position        = UDim2.new(0, 0, 0.5, 0),
				Parent          = rail,
			}, { MakeCorner(7) })

			local slObj = { Value = defV, Min = minV, Max = maxV }
			local Changed

			local function applyValue(v, silent)
				v = math.clamp(math.floor(v / (10 ^ -round) + 0.5) / (10 ^ -round), minV, maxV)
				slObj.Value  = v
				local pct    = (v - minV) / (maxV - minV)
				fill.Size    = UDim2.new(pct, 0, 1, 0)
				thumb.Position = UDim2.new(pct, 0, 0.5, 0)
				valLabel.Text = tostring(v)
				if not silent then
					cb(v)
					if Changed then Changed(v) end
				end
			end
			applyValue(defV, true)

			local draggingSlider = false
			local function onInput(inp)
				if not draggingSlider then return end
				local railPos = rail.AbsolutePosition.X
				local railW   = rail.AbsoluteSize.X
				local pct     = math.clamp((inp.Position.X - railPos) / railW, 0, 1)
				applyValue(minV + (maxV - minV) * pct)
			end

			local ibtn = New("TextButton", {
				Size            = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Text            = "",
				ZIndex          = 3,
				Parent          = rail,
			})
			ibtn.InputBegan:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.MouseButton1 then
					draggingSlider = true
				end
			end)
			UserInput.InputChanged:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.MouseMovement then
					onInput(inp)
				end
			end)
			UserInput.InputEnded:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.MouseButton1 then
					draggingSlider = false
				end
			end)

			function slObj:SetValue(v) applyValue(v, true) end
			function slObj:OnChanged(fn) Changed = fn fn(self.Value) end

			local mt2 = { OnChanged = slObj.OnChanged }
			mt2.__index = mt2
			setmetatable(slObj, mt2)

			self._window.Options[id] = slObj
			return slObj
		end

		-- ── AddDropdown ───────────────────────────────────────────
		function Tab:AddDropdown(id, opts3)
			local values  = opts3.Values  or {}
			local multi   = opts3.Multi   or false
			local defVal  = opts3.Default
			local cb      = opts3.Callback or function() end

			local row = New("Frame", {
				Size            = UDim2.new(1, 0, 0, 38),
				BackgroundColor3 = C.Element,
				BorderSizePixel = 0,
				Parent          = scroll,
			}, {
				MakeCorner(8),
				MakeStroke(C.Border, 1, 0.9),
				MakePadding(0, 0, 12, 10),
			})
			New("TextLabel", {
				Text            = opts3.Title or "",
				FontFace        = FONT_MED,
				TextSize        = 12,
				TextColor3      = C.TextPri,
				BackgroundTransparency = 1,
				Size            = UDim2.new(0.45, 0, 1, 0),
				TextXAlignment  = Enum.TextXAlignment.Left,
				Parent          = row,
			})
			-- Value label
			local valLbl = New("TextLabel", {
				Text            = "",
				FontFace        = FONT_REG,
				TextSize        = 11,
				TextColor3      = C.TextSec,
				BackgroundTransparency = 1,
				Size            = UDim2.new(0.45, -20, 1, 0),
				Position        = UDim2.new(0.45, 0, 0, 0),
				TextXAlignment  = Enum.TextXAlignment.Right,
				TextTruncate    = Enum.TextTruncate.AtEnd,
				Parent          = row,
			})
			-- Chevron
			New("TextLabel", {
				Text            = "v",
				FontFace        = FONT_REG,
				TextSize        = 10,
				TextColor3      = C.TextSec,
				BackgroundTransparency = 1,
				Size            = UDim2.fromOffset(20, 20),
				Position        = UDim2.new(1, -20, 0.5, -10),
				TextXAlignment  = Enum.TextXAlignment.Center,
				Parent          = row,
			})

			local ddObj = { Value = multi and {} or nil, Values = values }
			local Changed

			local function refresh()
				if multi then
					local parts = {}
					for k, v in pairs(ddObj.Value) do
						if v then table.insert(parts, k) end
					end
					valLbl.Text = #parts > 0 and table.concat(parts, ", ") or "--"
				else
					valLbl.Text = ddObj.Value or "--"
				end
			end

			-- Set default
			if multi then
				if type(defVal) == "table" then
					for _, vk in ipairs(defVal) do ddObj.Value[vk] = true end
				end
			else
				if type(defVal) == "string" then
					ddObj.Value = defVal
				elseif type(defVal) == "number" and values[defVal] then
					ddObj.Value = values[defVal]
				end
			end
			refresh()

			-- Dropdown popup
			local popupOpen = false
			local popup

			local function closePopup()
				if popup then
					Tween(popup, TI_FAST, { Size = UDim2.fromOffset(popup.AbsoluteSize.X, 0) })
					task.delay(0.2, function() if popup then popup:Destroy() popup = nil end end)
					popupOpen = false
				end
			end

			local openBtn = New("TextButton", {
				Size            = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Text            = "",
				ZIndex          = 5,
				Parent          = row,
			})

			openBtn.MouseButton1Click:Connect(function()
				if popupOpen then closePopup() return end
				popupOpen = true

				local rowAbsPos  = row.AbsolutePosition
				local rowAbsSize = row.AbsoluteSize
				local popW       = rowAbsSize.X
				local popH       = math.min(#values * 30 + 8, 180)

				popup = New("ScrollingFrame", {
					Size            = UDim2.fromOffset(popW, 0),
					Position        = UDim2.fromOffset(
						rowAbsPos.X - contentHolder.AbsolutePosition.X,
						rowAbsPos.Y - contentHolder.AbsolutePosition.Y + rowAbsSize.Y + 4
					),
					BackgroundColor3 = C.Element,
					BorderSizePixel = 0,
					ClipsDescendants = true,
					ScrollBarThickness = 3,
					ScrollBarImageColor3 = C.Accent,
					CanvasSize      = UDim2.fromScale(0, 0),
					ZIndex          = 10,
					Parent          = contentHolder,
				}, {
					MakeCorner(8),
					MakeStroke(C.Border, 1, 0.85),
					MakePadding(4, 4, 0, 0),
					MakeListLayout(2),
				})

				Tween(popup, TI_FAST, { Size = UDim2.fromOffset(popW, popH) })

				for _, vname in ipairs(values) do
					local isActive = multi and (ddObj.Value[vname] == true) or (ddObj.Value == vname)
					local item = New("TextButton", {
						Size            = UDim2.new(1, -8, 0, 26),
						BackgroundColor3 = isActive and C.Accent or C.Element,
						BackgroundTransparency = isActive and 0.7 or 0,
						BorderSizePixel = 0,
						Text            = vname,
						FontFace        = FONT_MED,
						TextSize        = 12,
						TextColor3      = isActive and C.TextPri or C.TextSec,
						TextXAlignment  = Enum.TextXAlignment.Left,
						ZIndex          = 11,
						Parent          = popup,
					}, { MakeCorner(6), MakePadding(0, 0, 8, 0) })

					item.MouseButton1Click:Connect(function()
						if multi then
							ddObj.Value[vname] = not ddObj.Value[vname]
						else
							ddObj.Value = vname
							closePopup()
						end
						refresh()
						cb(ddObj.Value)
						if Changed then Changed(ddObj.Value) end
					end)
				end

				local ll2 = popup:FindFirstChildOfClass("UIListLayout")
				if ll2 then
					ll2:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
						popup.CanvasSize = UDim2.fromOffset(0, ll2.AbsoluteContentSize.Y + 8)
					end)
				end
			end)

			-- Close on outside click
			UserInput.InputBegan:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.MouseButton1 and popupOpen then
					task.wait()
					closePopup()
				end
			end)

			function ddObj:SetValue(v)
				if multi then
					if type(v) == "table" then
						self.Value = v
					end
				else
					self.Value = v
				end
				refresh()
			end
			function ddObj:SetValues(newVals)
				values = newVals
				ddObj.Values = newVals
			end
			function ddObj:OnChanged(fn) Changed = fn fn(self.Value) end

			local mt3 = { OnChanged = ddObj.OnChanged }
			mt3.__index = mt3
			setmetatable(ddObj, mt3)

			self._window.Options[id] = ddObj
			return ddObj
		end

		-- ── AddButton ─────────────────────────────────────────────
		function Tab:AddButton(opts3)
			local cb = opts3.Callback or function() end
			local btn = New("TextButton", {
				Size            = UDim2.new(1, 0, 0, 34),
				BackgroundColor3 = C.Accent,
				BackgroundTransparency = 0.15,
				BorderSizePixel = 0,
				Text            = opts3.Title or "Button",
				FontFace        = FONT_SEMI,
				TextSize        = 12,
				TextColor3      = C.TextPri,
				Parent          = scroll,
			}, { MakeCorner(8) })
			btn.MouseEnter:Connect(function()  Tween(btn, TI_FAST, { BackgroundTransparency = 0 }) end)
			btn.MouseLeave:Connect(function()  Tween(btn, TI_FAST, { BackgroundTransparency = 0.15 }) end)
			btn.MouseButton1Down:Connect(function() Tween(btn, TI_FAST, { BackgroundTransparency = 0.35 }) end)
			btn.MouseButton1Up:Connect(function()   Tween(btn, TI_FAST, { BackgroundTransparency = 0 }) end)
			btn.MouseButton1Click:Connect(function() cb() end)
		end

		-- ── AddInput ──────────────────────────────────────────────
		function Tab:AddInput(id, opts3)
			local cb     = opts3.Callback or function() end
			local finCB  = opts3.Finished
			local numeric = opts3.Numeric or false
			local row, _ = MakeElement(opts3.Title or "", opts3.Description)

			local box = New("TextBox", {
				Size            = UDim2.fromOffset(140, 24),
				Position        = UDim2.new(1, -148, 0.5, -12),
				BackgroundColor3 = C.Content,
				BorderSizePixel = 0,
				Text            = tostring(opts3.Default or ""),
				PlaceholderText = opts3.Placeholder or "",
				PlaceholderColor3 = C.TextSec,
				FontFace        = FONT_REG,
				TextSize        = 12,
				TextColor3      = C.TextPri,
				ClearTextOnFocus = false,
				Parent          = row,
			}, { MakeCorner(6), MakeStroke(C.Border, 1, 0.85), MakePadding(0, 0, 8, 8) })

			local inObj = { Value = tostring(opts3.Default or "") }
			local Changed

			box:GetPropertyChangedSignal("Text"):Connect(function()
				local t = box.Text
				if numeric and not tonumber(t) and #t > 0 then box.Text = inObj.Value return end
				inObj.Value = t
				if not finCB then
					cb(t)
					if Changed then Changed(t) end
				end
			end)
			box.FocusLost:Connect(function(enter)
				if finCB and enter then
					cb(box.Text)
					if Changed then Changed(box.Text) end
				end
			end)

			function inObj:SetValue(v) box.Text = tostring(v) end
			function inObj:OnChanged(fn) Changed = fn fn(self.Value) end

			self._window.Options[id] = inObj
			return inObj
		end

		table.insert(self._tabs, Tab)

		-- Auto-activate first tab
		if #self._tabs == 1 then
			Tab:_activate()
		end

		-- Update navList canvas
		local navLL = navList:FindFirstChildOfClass("UIListLayout")
		if navLL then
			navList.CanvasSize = UDim2.fromOffset(0, navLL.AbsoluteContentSize.Y)
			navLL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				navList.CanvasSize = UDim2.fromOffset(0, navLL.AbsoluteContentSize.Y + 8)
			end)
		end

		return Tab
	end -- AddTab

	return Window
end -- CreateWindow

-- ── SaveManager shim (no-op) ─────────────────────────────────
MacUI.SaveManager = {
	SetLibrary         = function() end,
	SetFolder          = function() end,
	BuildConfigSection = function() end,
	LoadAutoloadConfig = function() end,
}

-- ── InterfaceManager shim (no-op) ────────────────────────────
MacUI.InterfaceManager = {
	SetLibrary       = function() end,
	SetFolder        = function() end,
	BuildInterfaceSection = function() end,
}

return MacUI
