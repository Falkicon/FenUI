# Portal System

> **Status**: Proposed
> **Priority**: Medium
> **Complexity**: Medium

## Summary

A portal system that allows rendering FenUI components to a different location in the frame hierarchy than their logical parent. This is essential for tooltips, dropdowns, modals, and popups that need to escape clipping regions and render above other content.

## Motivation

WoW's frame hierarchy determines rendering:

- Children clip to parent bounds
- Children render within parent's strata/level
- Nested elements may be visually obscured

Common problems this solves:

- **Dropdown menus**: Need to render outside their trigger button's container
- **Tooltips**: Must appear above all other content regardless of where the trigger is
- **Modals**: Should overlay entire UI, not just their logical parent
- **Context menus**: Appear at cursor position, not anchored to parent

## Proposed API

### Basic Portal

```lua
-- Render to a different parent
local dropdown = FenUI:CreatePanel(trigger, {
    portal = "UIParent",  -- Render to UIParent instead of trigger
    -- or
    portal = true,        -- Auto-select appropriate portal target
})
```

### Named Portal Targets

```lua
-- Register portal targets
FenUI.Portal:RegisterTarget("tooltips", tooltipLayer)
FenUI.Portal:RegisterTarget("modals", modalLayer)
FenUI.Portal:RegisterTarget("dropdowns", dropdownLayer)

-- Use named target
local tooltip = FenUI:CreateTooltip(button, {
    portal = "tooltips",
})
```

### Portal Component

```lua
-- Explicit Portal wrapper
FenUI.Portal(button)
    :target("dropdowns")
    :content(function(container)
        FenUI.Panel(container)
            :width(200)
            :padding("md")
            :build()
    end)
    :build()
```

### Automatic Positioning

```lua
-- Portal content positioned relative to source
local dropdown = FenUI:CreateDropdown(button, {
    portal = true,
    anchor = "BOTTOMLEFT",    -- Where on source to anchor
    attachTo = "TOPLEFT",     -- Where on portal content to attach
    offset = { x = 0, y = -4 },
})
```

### Builder API

```lua
local menu = FenUI.Panel(trigger)
    :portal("dropdowns")
    :anchorTo(trigger, "BOTTOMLEFT", "TOPLEFT", 0, -4)
    :width(200)
    :build()
```

## Implementation Notes

### Portal Frame Registry

```lua
FenUI.Portal = {
    _targets = {},      -- Named portal targets
    _portals = {},      -- Active portal instances
    _defaultTarget = UIParent,
}
```

### Default Portal Targets

Create standard layers on initialization:

```lua
FenUI.Portal:Init()
    -- Create default layers
    self._targets.tooltips = CreateFrame("Frame", "FenUI_TooltipPortal", UIParent)
    self._targets.tooltips:SetFrameStrata("TOOLTIP")
    
    self._targets.modals = CreateFrame("Frame", "FenUI_ModalPortal", UIParent)
    self._targets.modals:SetFrameStrata("DIALOG")
    
    self._targets.dropdowns = CreateFrame("Frame", "FenUI_DropdownPortal", UIParent)
    self._targets.dropdowns:SetFrameStrata("FULLSCREEN_DIALOG")
end
```

### Reparenting Logic

```lua
function Portal:Render(content, target, sourceFrame)
    -- Store original parent for cleanup
    content._fenui_originalParent = content:GetParent()
    content._fenui_sourceFrame = sourceFrame
    
    -- Reparent to portal target
    content:SetParent(target)
    
    -- Setup positioning relative to source
    self:UpdatePosition(content)
    
    -- Track for cleanup
    self._portals[content] = true
end
```

### Position Updates

Portal content may need to track source frame movement:

```lua
function Portal:UpdatePosition(content)
    local source = content._fenui_sourceFrame
    if not source or not source:IsShown() then return end
    
    local config = content._fenui_portalConfig
    content:ClearAllPoints()
    content:SetPoint(
        config.attachTo,
        source,
        config.anchor,
        config.offset.x,
        config.offset.y
    )
end

-- Optional: Update on source movement
source:HookScript("OnUpdate", function()
    Portal:UpdatePosition(portalContent)
end)
```

### Cleanup

```lua
function Portal:Close(content)
    -- Restore original parent
    local originalParent = content._fenui_originalParent
    if originalParent then
        content:SetParent(originalParent)
    end
    
    -- Remove tracking
    self._portals[content] = nil
end
```

### Integration with Show/Hide

Hook into component lifecycle:

```lua
-- When source hides, portal content should hide
source:HookScript("OnHide", function()
    portalContent:Hide()
end)
```

## Dependencies

- Frame strata system (WoW native)
- Show/hide lifecycle hooks

## Open Questions

1. **Should portals auto-close when clicking outside?**
   - Common for dropdowns and menus
   - Recommendation: Optional configuration

2. **How to handle multiple portals at same level?**
   - Last opened on top?
   - Recommendation: Yes, increment frame level

3. **Should portals track source frame movement?**
   - Performance cost for OnUpdate
   - Recommendation: Opt-in with `trackPosition = true`

4. **Escape key to close portals?**
   - Stack-based closing (most recent first)
   - Recommendation: Yes, integrate with focus system

## Tasks

- [ ] Create `FenUI.Portal` module
- [ ] Create default portal target frames
- [ ] Implement `RegisterTarget()`
- [ ] Implement reparenting logic
- [ ] Create anchor-based positioning
- [ ] Track portal instances
- [ ] Implement cleanup on close
- [ ] Hook source frame show/hide
- [ ] Optional position tracking (OnUpdate)
- [ ] Click-outside-to-close functionality
- [ ] Escape key stack-based closing
- [ ] Integrate with focus trapping
- [ ] Add portal support to CreatePanel
- [ ] Add portal support to CreateDropdown
- [ ] Write unit tests
- [ ] Document portal system
- [ ] Create dropdown example
- [ ] Create tooltip example

