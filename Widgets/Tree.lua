--------------------------------------------------------------------------------
-- FenUI - Tree Widget
--
-- A simple tree view for hierarchical data.
--------------------------------------------------------------------------------

local FenUI = FenUI
local WidgetMixin = {}

function WidgetMixin:Init(config)
	self.config = config or {}
	self.nodes = {}
	self.scrollFrame = FenUI:CreateScrollInset(self, {
		background = "surfaceInset",
	})
	self.scrollFrame:SetAllPoints()

	self.content = self.scrollFrame:GetScrollChild()
	self.content:SetWidth(self.scrollFrame:GetWidth())

	self.rows = {}
	self.rowPool = {}
end

function WidgetMixin:SetData(data)
	self.data = data
	self:Refresh()
end

function WidgetMixin:Refresh()
	-- Clear current rows
	for _, row in ipairs(self.rows) do
		row:Hide()
		table.insert(self.rowPool, row)
	end
	wipe(self.rows)

	local yOffset = 0
	local function addNode(node, depth)
		local row = self:GetRow()
		row:SetPoint("TOPLEFT", depth * 16, -yOffset)
		row:SetPoint("TOPRIGHT", 0, -yOffset)
		row:SetText(node.text)
		row.value = node.value
		row:Show()

		table.insert(self.rows, row)
		yOffset = yOffset + 20

		local expanded = node.expanded
		if expanded == nil then
			expanded = true
		end -- Default to expanded

		if node.children and expanded then
			for _, child in ipairs(node.children) do
				addNode(child, depth + 1)
			end
		end
	end

	if self.data then
		for _, node in ipairs(self.data) do
			addNode(node, 0)
		end
	end

	self.content:SetHeight(yOffset)
end

function WidgetMixin:GetRow()
	local row = table.remove(self.rowPool)
	if not row then
		row = CreateFrame("Button", nil, self.content)
		row:SetHeight(20)

		row.text = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		row.text:SetPoint("LEFT", 4, 0)

		row:SetScript("OnClick", function(r)
			if self.config.onSelect then
				self.config.onSelect(r.value)
			end
		end)

		function row:SetText(t)
			self.text:SetText(t)
		end
	end
	return row
end

-- Factory function
function FenUI:CreateTree(parent, config)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetSize(config.width or 200, config.height or 300)

	FenUI.Mixin(frame, WidgetMixin)
	frame:Init(config)

	return frame
end
