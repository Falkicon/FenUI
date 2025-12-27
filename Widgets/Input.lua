--------------------------------------------------------------------------------
-- FenUI - Input Widget
--
-- A standard text input field with styling.
--------------------------------------------------------------------------------

local FenUI = FenUI
local WidgetMixin = {}

function WidgetMixin:Init(config)
	self.config = config or {}

	-- Background/Border using Layout
	local layout = FenUI:CreateLayout(self, {
		background = "surfaceInset",
		border = "Inset",
		padding = 4,
	})
	layout:SetAllPoints()
	self.layout = layout

	-- EditBox
	local editBox = CreateFrame("EditBox", nil, self)
	editBox:SetAllPoints(layout)
	editBox:SetFontObject("ChatFontNormal")
	editBox:SetAutoFocus(false)
	editBox:SetTextInsets(8, 8, 0, 0)

	if self.config.placeholder then
		local placeholder = editBox:CreateFontString(nil, "OVERLAY", "ChatFontNormal")
		placeholder:SetPoint("LEFT", 8, 0)

		local U = FenUI.Utils
		local placeholderText = U and U:SanitizeText(self.config.placeholder, "Enter text...")
			or (self.config.placeholder == true and "Enter text..." or self.config.placeholder)

		placeholder:SetText(placeholderText)
		placeholder:SetTextColor(0.5, 0.5, 0.5)
		self.placeholder = placeholder

		editBox:SetScript("OnTextChanged", function(eb)
			placeholder:SetShown(eb:GetText() == "")
			if self.config.onChange then
				self.config.onChange(eb:GetText())
			end
		end)
	else
		editBox:SetScript("OnTextChanged", function(eb)
			if self.config.onChange then
				self.config.onChange(eb:GetText())
			end
		end)
	end

	if self.config.readOnly then
		editBox:SetEnabled(false)
	end

	-- Enter/Escape handlers
	editBox:SetScript("OnEnterPressed", function(eb)
		if self.config.onEnter then
			self.config.onEnter(eb:GetText())
		end
		eb:ClearFocus()
	end)

	editBox:SetScript("OnEscapePressed", function(eb)
		if self.config.onEscape then
			self.config.onEscape(eb:GetText())
		end
		eb:ClearFocus()
	end)

	self.editBox = editBox
end

function WidgetMixin:SetText(text)
	self.editBox:SetText(text or "")
end

function WidgetMixin:GetText()
	return self.editBox:GetText()
end

-- Factory function
function FenUI:CreateInput(parent, config)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetSize(config.width or 200, config.height or 24)

	FenUI.Mixin(frame, WidgetMixin)
	frame:Init(config)

	return frame
end
