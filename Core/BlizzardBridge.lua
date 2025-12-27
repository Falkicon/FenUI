--------------------------------------------------------------------------------
-- FenUI v2 - Blizzard Bridge
--
-- Wrapper around Blizzard's NineSliceUtil and NineSliceLayouts.
-- Provides easy access to native UI frame styles.
--------------------------------------------------------------------------------

local FenUI = FenUI

--------------------------------------------------------------------------------
-- Curated Layout Registry
-- These are the recommended Blizzard layouts for common use cases
--------------------------------------------------------------------------------

FenUI.Layouts = {
	-- Standard frames (Legacy)
	Panel = "ButtonFrameTemplateNoPortrait",
	PanelMinimizable = "ButtonFrameTemplateNoPortraitMinimizable",
	Simple = "SimplePanelTemplate",
	Portrait = "PortraitFrameTemplate",
	PortraitMinimizable = "PortraitFrameTemplateMinimizable",

	-- Modern frames (11.0+ Dark Mode style)
	Modern = "GenericMetal", -- Clean, modern dark border
	Metal = "GenericMetal", -- Alias for backward compatibility

	-- Content sections
	Inset = "InsetFrameTemplate",

	-- Dialogs and modals
	Dialog = "Dialog",

	-- Tooltips (modern dark style)
	Tooltip = "TooltipGluesLayout", -- Using TooltipGluesLayout as a general tooltip style
	TooltipDefault = "TooltipDefaultLayout",
	TooltipGlues = "TooltipGluesLayout",

	-- Expansion-themed
	Dragonflight = "DragonflightMissionFrame",
	Shadowlands = "CovenantMissionFrame",
	BFA_Horde = "BFAMissionHorde",
	BFA_Alliance = "BFAMissionAlliance",
}

-- Reverse lookup: Blizzard name -> FenUI name
FenUI.LayoutAliases = {}
for fenUIName, blizzardName in pairs(FenUI.Layouts) do
	FenUI.LayoutAliases[blizzardName] = fenUIName
end

--------------------------------------------------------------------------------
-- Layout Validation
--------------------------------------------------------------------------------

--- Check if a layout exists in Blizzard's NineSliceLayouts
---@param layoutName string The layout name (FenUI alias or Blizzard name)
---@return boolean exists
function FenUI:LayoutExists(layoutName)
	if not NineSliceLayouts then
		return false
	end

	-- Check if it's a FenUI alias
	local blizzardName = self.Layouts[layoutName] or layoutName

	return NineSliceLayouts[blizzardName] ~= nil
end

--- Get the Blizzard layout name from a FenUI alias
---@param layoutName string FenUI alias or Blizzard name
---@return string blizzardLayoutName
function FenUI:ResolveLayoutName(layoutName)
	return self.Layouts[layoutName] or layoutName
end

--- Get all available layouts (both FenUI aliases and Blizzard names)
---@param includeBlizzard boolean Include raw Blizzard layout names
---@return table<number, string> layoutNames
function FenUI:GetAvailableLayouts(includeBlizzard)
	local layouts = {}

	-- Add FenUI aliases
	for name in pairs(self.Layouts) do
		table.insert(layouts, name)
	end

	-- Optionally add all Blizzard layouts
	if includeBlizzard and NineSliceLayouts then
		for name in pairs(NineSliceLayouts) do
			if not self.LayoutAliases[name] then
				table.insert(layouts, name)
			end
		end
	end

	table.sort(layouts)
	return layouts
end

--------------------------------------------------------------------------------
-- Custom Border Engine (Intentional Custom)
--
-- Replaces Blizzard's black-box NineSliceUtil with an explicit 8-texture
-- implementation that provides total control over layering and sub-levels.
--------------------------------------------------------------------------------

local BORDER_PIECES = {
	"TopLeftCorner",
	"TopRightCorner",
	"BottomLeftCorner",
	"BottomRightCorner",
	"TopEdge",
	"BottomEdge",
	"LeftEdge",
	"RightEdge",
}

--- Resolve a border key to its pack definition
---@param borderKey string The border pack name (e.g., "ModernDark")
---@return table|nil pack
function FenUI:GetBorderPack(borderKey)
	return self.Tokens.borders and self.Tokens.borders[borderKey]
end

--- Apply a custom 8-texture border to a frame
---@param frame Frame The target frame
---@param borderKey string The border pack key from Tokens.lua
---@param colorToken string|nil Optional color token to tint the border
---@param margin table|nil Optional margin {top, bottom, left, right}
function FenUI:ApplyBorder(frame, borderKey, colorToken, margin)
	local pack = self:GetBorderPack(borderKey)
	if not pack then
		FenUI:Debug("Border pack not found:", borderKey)
		return false
	end

	local m = margin or { top = 0, bottom = 0, left = 0, right = 0 }

	-- 1. Create or clear existing border textures
	frame.customBorder = frame.customBorder or {}
	local pieces = frame.customBorder

	-- Ensure we have all 8 pieces
	for _, name in ipairs(BORDER_PIECES) do
		if not pieces[name] then
			pieces[name] = frame:CreateTexture(nil, "BORDER", nil, 5)
		end
		local tex = pieces[name]
		tex:SetTexture(pack.file)
		tex:Show()
	end

	-- 2. Setup TexCoords (Slicing)
	-- The texture is assumed to be a grid where corners are 'slice' pixels square
	-- and edges are 1px thick between corners.
	-- We use standard 0-1 normalized coordinates.
	-- Note: This implementation assumes a square texture atlas for simplicity.
	local s = pack.slice / 64 -- Standardizing on 64px source textures for now

	pieces.TopLeftCorner:SetTexCoord(0, s, 0, s)
	pieces.TopRightCorner:SetTexCoord(1 - s, 1, 0, s)
	pieces.BottomLeftCorner:SetTexCoord(0, s, 1 - s, 1)
	pieces.BottomRightCorner:SetTexCoord(1 - s, 1, 1 - s, 1)

	pieces.TopEdge:SetTexCoord(s, 1 - s, 0, s)
	pieces.BottomEdge:SetTexCoord(s, 1 - s, 1 - s, 1)
	pieces.LeftEdge:SetTexCoord(0, s, s, 1 - s)
	pieces.RightEdge:SetTexCoord(1 - s, 1, s, 1 - s)

	-- 3. Positioning
	local size = pack.slice
	pieces.TopLeftCorner:SetSize(size, size)
	pieces.TopLeftCorner:SetPoint("TOPLEFT", m.left, -m.top)

	pieces.TopRightCorner:SetSize(size, size)
	pieces.TopRightCorner:SetPoint("TOPRIGHT", -m.right, -m.top)

	pieces.BottomLeftCorner:SetSize(size, size)
	pieces.BottomLeftCorner:SetPoint("BOTTOMLEFT", m.left, m.bottom)

	pieces.BottomRightCorner:SetSize(size, size)
	pieces.BottomRightCorner:SetPoint("BOTTOMRIGHT", -m.right, m.bottom)

	pieces.TopEdge:SetPoint("TOPLEFT", pieces.TopLeftCorner, "TOPRIGHT")
	pieces.TopEdge:SetPoint("TOPRIGHT", pieces.TopRightCorner, "TOPLEFT")
	pieces.TopEdge:SetHeight(size)

	pieces.BottomEdge:SetPoint("BOTTOMLEFT", pieces.BottomLeftCorner, "BOTTOMRIGHT")
	pieces.BottomEdge:SetPoint("BOTTOMRIGHT", pieces.BottomRightCorner, "BOTTOMLEFT")
	pieces.BottomEdge:SetHeight(size)

	pieces.LeftEdge:SetPoint("TOPLEFT", pieces.TopLeftCorner, "BOTTOMLEFT")
	pieces.LeftEdge:SetPoint("BOTTOMLEFT", pieces.BottomLeftCorner, "TOPLEFT")
	pieces.LeftEdge:SetWidth(size)

	pieces.RightEdge:SetPoint("TOPRIGHT", pieces.TopRightCorner, "BOTTOMRIGHT")
	pieces.RightEdge:SetPoint("BOTTOMRIGHT", pieces.BottomRightCorner, "TOPRIGHT")
	pieces.RightEdge:SetWidth(size)

	-- 4. Theming (Coloring)
	local r, g, b, a = self:GetColor(colorToken or "borderDefault")
	for _, tex in pairs(pieces) do
		tex:SetVertexColor(r, g, b, a)
	end

	-- Store state
	frame.borderApplied = true
	frame.fenUIBorderKey = borderKey

	return true
end

--- Hide the custom border
---@param frame Frame
function FenUI:HideCustomBorder(frame)
	if frame.customBorder then
		for _, tex in pairs(frame.customBorder) do
			tex:Hide()
		end
	end
	frame.borderApplied = false
end

--------------------------------------------------------------------------------
-- NineSlice Application
--------------------------------------------------------------------------------

--- Apply a NineSlice layout to a frame
---@param frame Frame The frame to apply the layout to
---@param layoutName string The layout name (FenUI alias or Blizzard name)
---@param textureKit string|nil Optional texture kit for themed layouts
---@param margin table|nil Optional margin {top, bottom, left, right}
---@return boolean success
function FenUI:ApplyLayout(frame, layoutName, textureKit, margin)
	if not NineSliceUtil or not NineSliceLayouts then
		FenUI:Debug("NineSliceUtil not available")
		return false
	end

	local blizzardLayoutName = self:ResolveLayoutName(layoutName)
	local layout = NineSliceLayouts[blizzardLayoutName]

	if not layout then
		FenUI:Debug("Layout not found:", blizzardLayoutName)
		return false
	end

	-- Apply the layout
	NineSliceUtil.ApplyLayout(frame, layout, textureKit)

	-- Apply margins if provided
	if margin then
		local m = margin
		if frame.TopLeftCorner then
			frame.TopLeftCorner:ClearAllPoints()
			frame.TopLeftCorner:SetPoint("TOPLEFT", m.left, -m.top)
		end
		if frame.TopRightCorner then
			frame.TopRightCorner:ClearAllPoints()
			frame.TopRightCorner:SetPoint("TOPRIGHT", -m.right, -m.top)
		end
		if frame.BottomLeftCorner then
			frame.BottomLeftCorner:ClearAllPoints()
			frame.BottomLeftCorner:SetPoint("BOTTOMLEFT", m.left, m.bottom)
		end
		if frame.BottomRightCorner then
			frame.BottomRightCorner:ClearAllPoints()
			frame.BottomRightCorner:SetPoint("BOTTOMRIGHT", -m.right, m.bottom)
		end
		-- Note: Edges are usually anchored to corners by NineSliceUtil,
		-- so they should follow automatically.
	end

	-- Store layout info on the frame
	frame.fenUILayout = blizzardLayoutName
	frame.fenUITextureKit = textureKit

	FenUI:Debug("Applied layout:", blizzardLayoutName, textureKit and ("with kit: " .. textureKit) or "")
	return true
end

--- Apply a layout by Blizzard name directly (bypasses alias lookup)
---@param frame Frame The frame to apply the layout to
---@param blizzardLayoutName string The exact Blizzard layout name
---@param textureKit string|nil Optional texture kit
---@return boolean success
function FenUI:ApplyLayoutDirect(frame, blizzardLayoutName, textureKit)
	if not NineSliceUtil or not NineSliceLayouts then
		return false
	end

	local layout = NineSliceLayouts[blizzardLayoutName]
	if not layout then
		return false
	end

	NineSliceUtil.ApplyLayout(frame, layout, textureKit)
	frame.fenUILayout = blizzardLayoutName
	frame.fenUITextureKit = textureKit

	return true
end

--------------------------------------------------------------------------------
-- Layout Utilities
--------------------------------------------------------------------------------

--- Get the NineSlice pieces from a frame (if it has them)
---@param frame Frame The frame with a NineSlice layout
---@return table|nil pieces Table of piece names -> textures
function FenUI:GetLayoutPieces(frame)
	local pieceNames = {
		"TopLeftCorner",
		"TopRightCorner",
		"BottomLeftCorner",
		"BottomRightCorner",
		"TopEdge",
		"BottomEdge",
		"LeftEdge",
		"RightEdge",
		"Center",
	}

	local pieces = {}
	local found = false

	for _, name in ipairs(pieceNames) do
		if frame[name] then
			pieces[name] = frame[name]
			found = true
		end
	end

	return found and pieces or nil
end

--- Set the vertex color on all NineSlice pieces of a frame
---@param frame Frame The frame with a NineSlice layout
---@param r number Red (0-1)
---@param g number Green (0-1)
---@param b number Blue (0-1)
---@param a number|nil Alpha (0-1, defaults to 1)
function FenUI:SetLayoutColor(frame, r, g, b, a)
	a = a or 1

	local pieces = self:GetLayoutPieces(frame)
	if pieces then
		for _, texture in pairs(pieces) do
			texture:SetVertexColor(r, g, b, a)
		end
	end
end

--- Set the center color only (for backgrounds)
---@param frame Frame The frame with a NineSlice layout
---@param r number Red (0-1)
---@param g number Green (0-1)
---@param b number Blue (0-1)
---@param a number|nil Alpha (0-1, defaults to 1)
function FenUI:SetLayoutCenterColor(frame, r, g, b, a)
	if frame.Center then
		frame.Center:SetVertexColor(r, g, b, a or 1)
	end
end

--- Set the border color only (excludes center)
---@param frame Frame The frame with a NineSlice layout
---@param r number Red (0-1)
---@param g number Green (0-1)
---@param b number Blue (0-1)
---@param a number|nil Alpha (0-1, defaults to 1)
function FenUI:SetLayoutBorderColor(frame, r, g, b, a)
	a = a or 1

	local borderPieces = {
		"TopLeftCorner",
		"TopRightCorner",
		"BottomLeftCorner",
		"BottomRightCorner",
		"TopEdge",
		"BottomEdge",
		"LeftEdge",
		"RightEdge",
	}

	for _, name in ipairs(borderPieces) do
		if frame[name] then
			frame[name]:SetVertexColor(r, g, b, a)
		end
	end
end

--- Hide the NineSlice layout on a frame
---@param frame Frame The frame with a NineSlice layout
function FenUI:HideLayout(frame)
	if NineSliceUtil and NineSliceUtil.HideLayout then
		NineSliceUtil.HideLayout(frame)
	else
		local pieces = self:GetLayoutPieces(frame)
		if pieces then
			for _, texture in pairs(pieces) do
				texture:Hide()
			end
		end
	end
end

--- Show the NineSlice layout on a frame
---@param frame Frame The frame with a NineSlice layout
function FenUI:ShowLayout(frame)
	if NineSliceUtil and NineSliceUtil.ShowLayout then
		NineSliceUtil.ShowLayout(frame)
	else
		local pieces = self:GetLayoutPieces(frame)
		if pieces then
			for _, texture in pairs(pieces) do
				texture:Show()
			end
		end
	end
end

--------------------------------------------------------------------------------
-- Frame Creation Helpers
--------------------------------------------------------------------------------

--- Create a frame with a NineSlice layout already applied
---@param frameType string The frame type (e.g., "Frame", "Button")
---@param name string|nil The frame name
---@param parent Frame The parent frame
---@param layoutName string The layout name (FenUI alias or Blizzard name)
---@param textureKit string|nil Optional texture kit
---@return Frame frame The created frame
function FenUI:CreateFrameWithLayout(frameType, name, parent, layoutName, textureKit)
	local frame = CreateFrame(frameType, name, parent)
	self:ApplyLayout(frame, layoutName, textureKit)
	return frame
end

--- Create a simple panel frame with Inset layout
---@param name string|nil The frame name
---@param parent Frame The parent frame
---@return Frame frame The created frame
function FenUI:CreateInsetFrame(name, parent)
	return self:CreateFrameWithLayout("Frame", name, parent, "Inset")
end

--------------------------------------------------------------------------------
-- TextureKit Utilities
--------------------------------------------------------------------------------

-- Known texture kits that work with expansion-themed layouts
FenUI.TextureKits = {
	-- Modern (11.0+)
	warwithin = true,
	midnight = true,

	-- Previous expansions
	dragonflight = true,
	oribos = true,

	-- Faction
	horde = true,
	alliance = true,
	neutral = true,
}

--- Check if a texture kit is known to work
---@param textureKit string The texture kit name
---@return boolean isKnown
function FenUI:IsKnownTextureKit(textureKit)
	return self.TextureKits[textureKit] == true
end

--- Get list of known texture kits
---@return table<number, string> textureKits
function FenUI:GetKnownTextureKits()
	local kits = {}
	for kit in pairs(self.TextureKits) do
		table.insert(kits, kit)
	end
	table.sort(kits)
	return kits
end
