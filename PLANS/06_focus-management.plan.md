# Focus Management & Keyboard Navigation

> **Status**: Proposed
> **Priority**: Medium
> **Complexity**: High

## Summary

A comprehensive system for managing keyboard focus and navigation within FenUI components. Enables tab-order navigation, arrow-key movement within groups, focus trapping for modals, and visual focus indicators. Essential for accessibility and power-user keyboard workflows.

## Motivation

WoW's native focus system is limited:

- EditBox can receive focus, but other frames cannot
- No built-in tab navigation between elements
- No concept of focus groups or trapping
- Arrow-key navigation requires manual implementation

A robust focus system enables:

- Keyboard-only UI operation
- Accessible interfaces
- Dialog focus trapping
- Consistent navigation patterns

## Proposed API

### Focus Registration

```lua
-- Make a frame focusable
FenUI.Focus:Register(button, {
    tabIndex = 1,         -- Tab order (lower = earlier)
    group = "toolbar",    -- Focus group name
    onFocus = function(frame) end,
    onBlur = function(frame) end,
})

-- Shorthand in widget config
local button = FenUI:CreateButton(parent, {
    text = "Submit",
    focusable = true,
    tabIndex = 2,
})
```

### Focus Groups

```lua
-- Create a focus group with navigation rules
FenUI.Focus:CreateGroup("menu", {
    navigation = "vertical",   -- "horizontal" | "vertical" | "grid"
    wrap = true,              -- Wrap at ends
    trap = false,             -- Keep focus within group
})

-- Add items to group
FenUI.Focus:AddToGroup("menu", menuItem1)
FenUI.Focus:AddToGroup("menu", menuItem2)
FenUI.Focus:AddToGroup("menu", menuItem3)
```

### Focus Trapping (Modals)

```lua
local dialog = FenUI:CreateDialog(parent, {
    focusTrap = true,  -- Tab cannot leave dialog
    initialFocus = "firstInput",  -- Element to focus on show
    returnFocus = true,  -- Return focus to previous element on close
})
```

### Programmatic Focus

```lua
-- Set focus
FenUI.Focus:Set(button)
button:Focus()

-- Clear focus
FenUI.Focus:Clear()

-- Get current focus
local focused = FenUI.Focus:GetCurrent()
```

### Focus Indicators

```lua
-- Visual focus ring
local button = FenUI:CreateButton(parent, {
    focusable = true,
    focusStyle = {
        ring = true,           -- Show focus ring
        ringColor = "primary",
        ringWidth = 2,
        ringOffset = 2,
    },
})

-- Or use states system
local button = FenUI:CreateButton(parent, {
    states = {
        focused = {
            border = "primaryBright",
            shadow = "focus",
        },
    },
})
```

### Navigation Handlers

```lua
-- Custom navigation behavior
FenUI.Focus:SetNavigationHandler("grid", function(current, direction)
    if direction == "up" then
        return grid:GetAbove(current)
    elseif direction == "down" then
        return grid:GetBelow(current)
    end
    -- etc.
end)
```

## Implementation Notes

### Focus Stack

Track focus history for return-focus functionality:

```lua
FenUI.Focus._stack = {}  -- { frame1, frame2, ... }

function Focus:Push(frame)
    table.insert(self._stack, frame)
end

function Focus:Pop()
    return table.remove(self._stack)
end
```

### Global Key Handling

Register global keybindings for focus navigation:

```lua
-- Tab / Shift+Tab for sequential navigation
-- Arrow keys for directional navigation
-- Enter/Space for activation
-- Escape for blur/close

FenUI.Focus:RegisterGlobalKeys()
```

### Tab Order Algorithm

1. Collect all focusable elements in current scope
2. Sort by `tabIndex` (elements without tabIndex come last)
3. Within same tabIndex, sort by frame creation order
4. Navigate to next/previous in sorted list

### Visual Focus Ring

Create a dedicated frame for the focus ring:

```lua
FenUI.Focus._ring = CreateFrame("Frame", nil, UIParent)
-- Position around current focused element
-- Animate on focus change
```

### Integration with State System

Focus integrates with the State System (Plan 04):

```lua
-- Auto-set "focused" state flag
function Focus:Set(frame)
    if self._current then
        self._current:_SetStateFlag("focused", false)
    end
    frame:_SetStateFlag("focused", true)
    self._current = frame
end
```

### Combat Lockdown

- Focus management scripts may taint
- Queue focus changes during combat
- Visual indicators should still work

## Dependencies

- State System (Plan 04) for focus styling
- Animation System (Plan 03) for focus ring animation
- Key binding system (WoW native)

## Open Questions

1. **How to handle overlapping focus groups?**
   - Element in multiple groups?
   - Recommendation: Element belongs to one group at a time

2. **Should focus ring be a single shared frame or per-element?**
   - Single is efficient but may have z-order issues
   - Recommendation: Single shared frame, reparent as needed

3. **Keyboard shortcut conflicts?**
   - Tab is commonly used in WoW
   - Recommendation: Only active when FenUI UI is focused/shown

4. **Gamepad/controller support?**
   - WoW has controller support
   - Recommendation: Design system to support, implement in Phase 2

## Tasks

- [ ] Create `FenUI.Focus` module
- [ ] Implement focus registration
- [ ] Implement tab-order sorting
- [ ] Create focus group system
- [ ] Implement Tab/Shift+Tab navigation
- [ ] Implement arrow-key navigation
- [ ] Create focus trapping for modals
- [ ] Implement focus stack for return-focus
- [ ] Create visual focus ring frame
- [ ] Integrate with State System
- [ ] Add focus indicators to Button
- [ ] Add focus indicators to Panel
- [ ] Handle combat lockdown
- [ ] Register global keybindings
- [ ] Write unit tests
- [ ] Document focus system
- [ ] Create keyboard navigation demo

