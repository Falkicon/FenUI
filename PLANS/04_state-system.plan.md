# Declarative State System

> **Status**: Proposed
> **Priority**: Medium
> **Complexity**: Medium

## Summary

A declarative system for defining component states (normal, hover, active, disabled, focused) with automatic visual transitions. Instead of manually scripting `OnEnter`/`OnLeave` handlers, developers define state-based style overrides that FenUI applies automatically.

## Motivation

Interactive components have multiple visual states:

- Buttons: normal, hover, pressed, disabled
- Inputs: normal, focused, error, disabled
- Cards: normal, selected, highlighted
- Menu items: normal, hover, active

Currently, each state requires manual event handlers and style changes. This leads to repetitive code and inconsistent behavior. A declarative state system centralizes this logic.

## Proposed API

### State Definition

```lua
local button = FenUI:CreateButton(parent, {
    text = "Click Me",
    states = {
        normal = {
            background = "surface",
            textColor = "text",
        },
        hover = {
            background = "surfaceHover",
            textColor = "textBright",
            transition = { duration = 0.1 },
        },
        active = {
            background = "surfaceActive",
            scale = 0.98,
        },
        disabled = {
            background = "surfaceDisabled",
            textColor = "textMuted",
            alpha = 0.6,
        },
    },
})

-- State changes automatically on mouse events
-- Or manually:
button:SetState("disabled")
```

### Builder API

```lua
local card = FenUI.Panel(parent)
    :state("normal", { background = "surface" })
    :state("selected", { 
        background = "primary",
        border = "primaryBorder",
    })
    :state("hover", { background = "surfaceHover" })
    :build()

card:SetState("selected")
```

### Compound States

```lua
-- States can combine
local item = FenUI:CreateLayout(parent, {
    states = {
        normal = { ... },
        hover = { ... },
        selected = { ... },
        ["selected+hover"] = { ... },  -- Both selected AND hovered
    },
})
```

### State Events

```lua
-- React to state changes
button:OnStateChange(function(newState, oldState)
    print("Changed from", oldState, "to", newState)
end)
```

### Automatic State Detection

```lua
-- FenUI auto-detects these states based on events:
-- "hover" - OnEnter/OnLeave
-- "active" - OnMouseDown/OnMouseUp
-- "focused" - SetFocus/ClearFocus
-- "disabled" - :SetEnabled(false)

local input = FenUI:CreateInput(parent, {
    states = {
        normal = { border = "border" },
        focused = { border = "primary" },
        hover = { border = "borderHover" },
        disabled = { border = "borderDisabled" },
    },
})
-- No manual event handlers needed!
```

## Implementation Notes

### State Machine

Each stateful component has an internal state machine:

```lua
frame._fenui_state = {
    current = "normal",
    flags = {
        hover = false,
        active = false,
        focused = false,
        disabled = false,
    },
    definitions = { ... },
    callbacks = { ... },
}
```

### State Resolution

1. Check `disabled` flag first (highest priority)
2. Check compound states (e.g., `selected+hover`)
3. Check individual states in priority order
4. Fallback to `normal`

### Property Application

When state changes:

1. Calculate diff between current and new state styles
2. If transitions defined, animate the changes
3. Otherwise, apply immediately

### Supported Properties

| Property | Type | Notes |
|----------|------|-------|
| `background` | Token/Color | Background color |
| `border` | Token | Border style |
| `textColor` | Token/Color | Text color |
| `alpha` | Number | Opacity |
| `scale` | Number | Transform scale |
| `shadow` | Token/Config | Shadow style |

### Event Auto-Registration

For interactive components, FenUI automatically registers:

```lua
frame:SetScript("OnEnter", function() 
    self:_SetStateFlag("hover", true) 
end)
frame:SetScript("OnLeave", function() 
    self:_SetStateFlag("hover", false) 
end)
-- etc.
```

### Integration with Animation System

State transitions use the Animation system (Plan 03):

```lua
hover = {
    background = "surfaceHover",
    transition = { duration = 0.15, easing = "ease-out" },
}
```

## Dependencies

- Animation System (Plan 03) for transitions
- Design Tokens for color/style resolution
- Event system for state detection

## Open Questions

1. **State inheritance?**
   - Should `hover` inherit undefined properties from `normal`?
   - Recommendation: Yes, states are overlays on base styles

2. **Custom state definitions?**
   - Allow addon-specific states like "crafting", "looting"?
   - Recommendation: Yes, states are just string identifiers

3. **State persistence?**
   - Should certain states (like "selected") persist across sessions?
   - Recommendation: No, this is application logic

4. **Priority of compound states?**
   - `selected+hover` vs `hover+selected`?
   - Recommendation: Alphabetical order, or explicit priority

## Tasks

- [ ] Design state machine data structure
- [ ] Implement `SetState()` method
- [ ] Implement state flag system (hover, active, etc.)
- [ ] Create state resolution algorithm
- [ ] Auto-register mouse event handlers
- [ ] Integrate with Animation system for transitions
- [ ] Implement compound state support
- [ ] Add `OnStateChange` callback
- [ ] Apply state system to Button widget
- [ ] Apply state system to Layout widget
- [ ] Apply state system to Panel widget
- [ ] Create theme-level default states
- [ ] Write unit tests
- [ ] Document state system
- [ ] Create interactive examples

