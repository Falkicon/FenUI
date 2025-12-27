# Conditional Rendering & Visibility Binding

> **Status**: Proposed
> **Priority**: Medium
> **Complexity**: Low

## Summary

A system for declaratively binding component visibility to state values, conditions, or expressions. Instead of manually calling `Show()`/`Hide()` in response to data changes, developers declare visibility rules that FenUI evaluates automatically.

## Motivation

UI often toggles visibility based on state:

```lua
-- Current approach (imperative)
if player.isInCombat then
    combatPanel:Show()
else
    combatPanel:Hide()
end
```

This spreads visibility logic across event handlers and becomes hard to track. A declarative approach:

```lua
-- Proposed approach (declarative)
local combatPanel = FenUI:CreatePanel(parent, {
    visible = function() return player.isInCombat end,
})
```

Benefits:

- Visibility rules are co-located with component definition
- Automatic re-evaluation when dependencies change
- Cleaner separation of data and presentation
- Easier to understand component behavior at a glance

## Proposed API

### Function-Based Visibility

```lua
-- Visibility determined by function return value
local panel = FenUI:CreatePanel(parent, {
    visible = function()
        return UnitAffectingCombat("player")
    end,
    visibleEvents = { "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED" },
})
```

### Observable Binding

```lua
-- Bind to a FenUI observable value
local showDetails = FenUI.Observable(false)

local detailsPanel = FenUI:CreatePanel(parent, {
    visible = showDetails,  -- Auto-shows/hides when value changes
})

-- Later
showDetails:Set(true)  -- Panel automatically shows
```

### Conditional Expression

```lua
-- String expression (parsed)
local panel = FenUI:CreatePanel(parent, {
    visible = "playerLevel >= 60",
    visibleContext = { playerLevel = 45 },  -- Variables for expression
})

-- Update context
panel:SetVisibleContext({ playerLevel = 60 })  -- Re-evaluates, shows panel
```

### Builder API

```lua
local panel = FenUI.Panel(parent)
    :visibleWhen(function() return someCondition end)
    :visibleEvents({ "EVENT_A", "EVENT_B" })
    :build()

-- Or with observable
local panel = FenUI.Panel(parent)
    :bindVisible(showDetailsObservable)
    :build()
```

### Visibility Groups

```lua
-- Show one of multiple panels based on state
FenUI.VisibilityGroup("tabs", {
    { panel = generalPanel, when = function() return tab == "general" end },
    { panel = advancedPanel, when = function() return tab == "advanced" end },
    { panel = aboutPanel, when = function() return tab == "about" end },
})

-- Mutual exclusivity is automatic
tab = "advanced"  -- Only advancedPanel shows
```

### Animated Visibility

```lua
-- Combine with animation system
local tooltip = FenUI:CreatePanel(parent, {
    visible = showTooltip,
    showAnimation = "fadeIn",
    hideAnimation = "fadeOut",
    animateVisibility = true,  -- Use animations for show/hide
})
```

## Implementation Notes

### Visibility Binding Storage

```lua
frame._fenui_visibility = {
    condition = functionOrObservable,
    events = { "EVENT_A", "EVENT_B" },
    context = {},
    lastValue = true,
}
```

### Function Evaluation

```lua
function FenUI:EvaluateVisibility(frame)
    local config = frame._fenui_visibility
    if not config then return end
    
    local visible = false
    
    if type(config.condition) == "function" then
        visible = config.condition()
    elseif type(config.condition) == "table" and config.condition.Get then
        -- Observable
        visible = config.condition:Get()
    elseif type(config.condition) == "string" then
        -- Expression
        visible = self:EvaluateExpression(config.condition, config.context)
    end
    
    if visible ~= config.lastValue then
        config.lastValue = visible
        if visible then
            frame:Show()
        else
            frame:Hide()
        end
    end
end
```

### Event-Based Re-evaluation

```lua
function FenUI:SetupVisibilityEvents(frame, events)
    for _, event in ipairs(events) do
        frame:RegisterEvent(event)
    end
    
    frame:SetScript("OnEvent", function(self, event)
        FenUI:EvaluateVisibility(self)
    end)
end
```

### Observable System

Simple reactive primitive:

```lua
FenUI.Observable = {}

function FenUI.Observable:New(initialValue)
    return {
        _value = initialValue,
        _subscribers = {},
        
        Get = function(self)
            return self._value
        end,
        
        Set = function(self, value)
            if self._value ~= value then
                self._value = value
                for _, callback in ipairs(self._subscribers) do
                    callback(value)
                end
            end
        end,
        
        Subscribe = function(self, callback)
            table.insert(self._subscribers, callback)
        end,
    }
end
```

### Integration with Animation

When `animateVisibility = true`:

```lua
function Frame:Show()
    if self._fenui_visibility.animateVisibility then
        self:PlayShowAnimation()
    else
        -- Original Show
    end
end
```

## Dependencies

- Animation System (Plan 03) for animated visibility
- Event registration (WoW native)

## Open Questions

1. **Should Observables be a separate, more robust system?**
   - Could evolve into full reactive state management
   - Recommendation: Start simple, expand as needed

2. **Expression language complexity?**
   - Simple comparisons only, or full expressions?
   - Recommendation: Start with simple (`==`, `~=`, `>`, `<`, `>=`, `<=`)

3. **Visibility vs Enabled state?**
   - Should there be a similar system for enabled/disabled?
   - Recommendation: Yes, same pattern, Phase 2

4. **Performance with many bindings?**
   - Batch evaluations on event?
   - Recommendation: Debounce rapid events

## Tasks

- [ ] Create `FenUI.Observable` class
- [ ] Implement Observable subscription system
- [ ] Add `visible` config option to components
- [ ] Implement function-based visibility evaluation
- [ ] Implement Observable binding
- [ ] Add event-based re-evaluation
- [ ] Create simple expression parser
- [ ] Implement expression evaluation with context
- [ ] Add `:SetVisibleContext()` for expression updates
- [ ] Create `FenUI.VisibilityGroup` for mutual exclusivity
- [ ] Integrate with Animation system for animated visibility
- [ ] Add builder API methods
- [ ] Write unit tests for Observable
- [ ] Write unit tests for visibility bindings
- [ ] Document conditional rendering
- [ ] Create examples

