--------------------------------------------------------------------------------
-- FenUI v2 - Container Widgets
-- 
-- Common container patterns:
-- - Inset: Styled content area with optional scroll
-- - ScrollPanel: Scrollable content with proper styling
--------------------------------------------------------------------------------

local FenUI = FenUI

--------------------------------------------------------------------------------
-- Layout Helper (reads from FenUI.Tokens.layout)
--------------------------------------------------------------------------------

local function GetLayout(name)
    return FenUI:GetLayout(name)
end

--------------------------------------------------------------------------------
-- Inset Container
-- A styled content area typically used inside panels
--------------------------------------------------------------------------------

local InsetMixin = {}

function InsetMixin:Init(config)
    self.config = config or {}
    
    -- Apply backdrop
    self:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    
    -- Use token colors
    local bgR, bgG, bgB = FenUI:GetColorRGB("surfaceInset")
    local borderR, borderG, borderB = FenUI:GetColorRGB("borderSubtle")
    self:SetBackdropColor(bgR, bgG, bgB, config.alpha or 0.95)
    self:SetBackdropBorderColor(borderR, borderG, borderB, 1)
end

function InsetMixin:SetInsetAlpha(alpha)
    local bgR, bgG, bgB = FenUI:GetColorRGB("surfaceInset")
    self:SetBackdropColor(bgR, bgG, bgB, alpha)
end

--- Create an inset container (styled content area)
---@param parent Frame Parent frame
---@param config table|nil Configuration { padding, alpha }
---@return Frame inset
function FenUI:CreateInset(parent, config)
    config = config or {}
    
    local inset = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    FenUI.Mixin(inset, InsetMixin)
    
    -- Position using layout constants or config
    local padding = config.padding or GetLayout("panelPadding")
    local topOffset = config.topOffset or 0
    local bottomOffset = config.bottomOffset or 0
    
    inset:SetPoint("TOPLEFT", padding, -topOffset)
    inset:SetPoint("BOTTOMRIGHT", -padding, bottomOffset)
    
    inset:Init(config)
    
    return inset
end

--------------------------------------------------------------------------------
-- Scroll Panel
-- A scrollable content container with proper styling
--------------------------------------------------------------------------------

local ScrollPanelMixin = {}

function ScrollPanelMixin:Init(config)
    self.config = config or {}
end

function ScrollPanelMixin:GetScrollChild()
    return self.scrollChild
end

function ScrollPanelMixin:GetContentWidth()
    return self.scrollChild:GetWidth()
end

function ScrollPanelMixin:SetContentHeight(height)
    self.scrollChild:SetHeight(height)
end

function ScrollPanelMixin:ScrollToTop()
    self.scrollFrame:SetVerticalScroll(0)
end

function ScrollPanelMixin:ScrollToBottom()
    local maxScroll = self.scrollFrame:GetVerticalScrollRange()
    self.scrollFrame:SetVerticalScroll(maxScroll)
end

--- Create a scroll panel (scrollable content area)
---@param parent Frame Parent frame
---@param config table|nil Configuration { padding, showScrollBar }
---@return Frame scrollPanel
function FenUI:CreateScrollPanel(parent, config)
    config = config or {}
    
    local container = CreateFrame("Frame", nil, parent)
    FenUI.Mixin(container, ScrollPanelMixin)
    
    -- Create scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", nil, container, "UIPanelScrollFrameTemplate")
    local padding = config.padding or GetLayout("scrollPadding")
    local scrollBarWidth = config.showScrollBar ~= false and GetLayout("scrollBarWidth") or 0
    
    scrollFrame:SetPoint("TOPLEFT", padding, -padding)
    scrollFrame:SetPoint("BOTTOMRIGHT", -(padding + scrollBarWidth), padding)
    
    -- Create scroll child
    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetWidth(container:GetWidth() - (padding * 2) - scrollBarWidth)
    scrollChild:SetHeight(1) -- Will be set by content
    scrollFrame:SetScrollChild(scrollChild)
    
    -- Store references
    container.scrollFrame = scrollFrame
    container.scrollChild = scrollChild
    
    -- Update scroll child width when container resizes
    container:SetScript("OnSizeChanged", function(self, width, height)
        local innerWidth = width - (padding * 2) - scrollBarWidth
        scrollChild:SetWidth(math.max(1, innerWidth))
    end)
    
    container:Init(config)
    
    return container
end

--------------------------------------------------------------------------------
-- Inset with Scroll (Combined convenience widget)
--------------------------------------------------------------------------------

--- Create an inset container with built-in scroll functionality
---@param parent Frame Parent frame  
---@param config table|nil Configuration { padding, topOffset, bottomOffset, alpha, scrollPadding }
---@return Frame inset, Frame scrollChild
function FenUI:CreateScrollInset(parent, config)
    config = config or {}
    
    -- Create the inset container
    local inset = self:CreateInset(parent, config)
    
    -- Create scroll panel inside it
    local scrollPanel = self:CreateScrollPanel(inset, {
        padding = config.scrollPadding or 5,
        showScrollBar = config.showScrollBar ~= false,
    })
    scrollPanel:SetAllPoints()
    
    -- Attach scroll panel to inset for easy access
    inset.scrollPanel = scrollPanel
    inset.scrollChild = scrollPanel.scrollChild
    
    -- Convenience methods
    function inset:GetScrollChild()
        return self.scrollChild
    end
    
    function inset:SetContentHeight(height)
        self.scrollPanel:SetContentHeight(height)
    end
    
    function inset:ScrollToTop()
        self.scrollPanel:ScrollToTop()
    end
    
    return inset, scrollPanel.scrollChild
end

--------------------------------------------------------------------------------
-- Export
--------------------------------------------------------------------------------

FenUI.InsetMixin = InsetMixin
FenUI.ScrollPanelMixin = ScrollPanelMixin
