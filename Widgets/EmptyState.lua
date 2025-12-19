--------------------------------------------------------------------------------
-- FenUI v2 - EmptyState Widget
-- 
-- Centered overlay for empty content areas.
-- Features:
-- - Background (color, gradient, or image)
-- - Centered content group (icon + title + subtitle)
-- - Semantic token styling
--------------------------------------------------------------------------------

local FenUI = FenUI

--------------------------------------------------------------------------------
-- EmptyState Mixin
--------------------------------------------------------------------------------

local EmptyStateMixin = {}

function EmptyStateMixin:Init(config)
    self.config = config or {}
    
    -- 1. Background
    self.bg = self:CreateTexture(nil, "BACKGROUND")
    self.bg:SetAllPoints()
    
    if config.backgroundGradient then
        local g = config.backgroundGradient
        local fromR, fromG, fromB, fromA = FenUI:GetColor(g.from or "black")
        local toR, toG, toB, toA = FenUI:GetColor(g.to or "transparent")
        self.bg:SetGradient(g.direction or "VERTICAL", CreateColor(fromR, fromG, fromB, fromA), CreateColor(toR, toG, toB, toA))
    elseif config.backgroundImage then
        self.bg:SetTexture(config.backgroundImage)
    elseif config.background then
        local r, g, b, a = FenUI:GetColor(config.background)
        self.bg:SetColorTexture(r, g, b, a)
    else
        self.bg:Hide()
    end
    
    -- 2. Content Group (centered)
    self.content = CreateFrame("Frame", nil, self)
    self.content:SetPoint("CENTER")
    local contentWidth = config.width or (self:GetParent() and self:GetParent():GetWidth()) or 300
    self.content:SetSize(contentWidth, 100) -- Auto-height based on content
    
    local yOffset = 0
    
    -- Icon
    if config.icon then
        self.icon = self.content:CreateTexture(nil, "ARTWORK")
        self.icon:SetTexture(config.icon)
        local iconSize = config.iconSize or 64
        self.icon:SetSize(iconSize, iconSize)
        self.icon:SetPoint("TOP", 0, yOffset)
        yOffset = yOffset - iconSize - 12
    end
    
    -- Title
    if config.title then
        self.title = self.content:CreateFontString(nil, "OVERLAY")
        self.title:SetFontObject(FenUI:GetFont("fontHeading"))
        self.title:SetPoint("TOP", 0, yOffset)
        self.title:SetText(config.title)
        
        local r, g, b = FenUI:GetColorRGB(config.titleToken or "textEmptyTitle")
        self.title:SetTextColor(r, g, b)
        
        yOffset = yOffset - self.title:GetStringHeight() - 4
    end
    
    -- Subtitle
    if config.subtitle then
        self.subtitle = self.content:CreateFontString(nil, "OVERLAY")
        self.subtitle:SetFontObject(FenUI:GetFont("fontSmall"))
        self.subtitle:SetPoint("TOP", 0, yOffset)
        self.subtitle:SetText(config.subtitle)
        
        local r, g, b = FenUI:GetColorRGB(config.subtitleToken or "textEmptySubtitle")
        self.subtitle:SetTextColor(r, g, b)
        
        yOffset = yOffset - self.subtitle:GetStringHeight()
    end
    
    -- Adjust content height to fit items
    self.content:SetHeight(math.abs(yOffset))
end

function EmptyStateMixin:SetVisible(visible)
    self:SetShown(visible)
end

--------------------------------------------------------------------------------
-- Factory
--------------------------------------------------------------------------------

--- Create an empty state component
---@param parent Frame Parent frame
---@param config table Configuration { background, icon, title, subtitle, etc }
---@return Frame emptyState
function FenUI:CreateEmptyState(parent, config)
    local empty = CreateFrame("Frame", nil, parent)
    empty:SetAllPoints()
    FenUI.Mixin(empty, EmptyStateMixin)
    empty:Init(config)
    return empty
end
