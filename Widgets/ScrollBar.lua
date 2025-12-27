--------------------------------------------------------------------------------
-- FenUI v2 - ScrollBar Widget
--
-- A custom scrollbar with FenUI styling (tokens).
-- Initially background colors only, supporting 9-slice later.
--------------------------------------------------------------------------------

local FenUI = FenUI

local ScrollBarMixin = {}

function ScrollBarMixin:Init(config)
	self.config = config or {}

	-- Setup Slider properties
	self:SetOrientation("VERTICAL")
	self:SetSize(config.width or FenUI:GetLayout("scrollBarWidth"), 0) -- Height set by anchors

	-- 1. Track (Background)
	self.track = self:CreateTexture(nil, "BACKGROUND")
	self.track:SetAllPoints()
	local r, g, b, a = FenUI:GetColor(config.trackToken or "surfaceScrollTrack")
	self.track:SetColorTexture(r, g, b, a)

	-- 2. Thumb
	local thumb = self:CreateTexture(nil, "ARTWORK")
	local tr, tg, tb, ta = FenUI:GetColor(config.thumbToken or "interactiveScrollThumb")
	thumb:SetColorTexture(tr, tg, tb, ta)
	thumb:SetSize(config.width or FenUI:GetLayout("scrollBarWidth"), 32) -- Initial height
	self:SetThumbTexture(thumb)
	self.thumb = thumb

	-- 3. Scripts
	self:SetScript("OnEnter", function()
		local hr, hg, hb, ha = FenUI:GetColor(config.thumbHoverToken or "interactiveScrollThumbHover")
		self.thumb:SetColorTexture(hr, hg, hb, ha)
	end)

	self:SetScript("OnLeave", function()
		local nr, ng, nb, na = FenUI:GetColor(config.thumbToken or "interactiveScrollThumb")
		self.thumb:SetColorTexture(nr, ng, nb, na)
	end)
end

function ScrollBarMixin:UpdateThumbSize(visibleHeight, totalHeight)
	-- Handle initial/empty state
	if totalHeight <= 0 or visibleHeight <= 0 or visibleHeight >= totalHeight then
		if self.thumb then
			self.thumb:SetHeight(0.1)
		end -- Use minimal height instead of 0
		self:Hide()
		return
	end

	self:Show()
	local trackHeight = self:GetHeight()

	-- If track hasn't layout yet, skip update (will trigger again on resize)
	if trackHeight <= 0 then
		return
	end

	local ratio = visibleHeight / totalHeight
	local thumbHeight = math.max(16, trackHeight * ratio)

	self.thumb:SetHeight(thumbHeight)
	self.thumb:Show() -- Ensure thumb is visible

	-- Update slider range
	self:SetMinMaxValues(0, totalHeight - visibleHeight)

	-- Force a redraw of the thumb position
	local current = self:GetValue()
	self:SetValue(current)
end

--------------------------------------------------------------------------------
-- Factory
--------------------------------------------------------------------------------

function FenUI:CreateScrollBar(parent, config)
	local scrollBar = CreateFrame("Slider", nil, parent)
	FenUI.Mixin(scrollBar, ScrollBarMixin)
	scrollBar:Init(config)
	return scrollBar
end

FenUI.ScrollBarMixin = ScrollBarMixin
