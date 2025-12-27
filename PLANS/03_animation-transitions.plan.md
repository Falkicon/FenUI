# Animation & Transition System

> **Status**: Completed (v2.8.0)
> **Priority**: High
> **Complexity**: High

## Summary

A declarative animation and transition system that brings fluid motion to FenUI components. Supports property transitions (opacity, scale, position), keyframe animations, and lifecycle animations (show/hide). Integrates with WoW's native AnimationGroup system while providing a friendlier API.

## Motivation

Modern UI expects smooth transitions and meaningful animation:

- Dialogs should fade in/out rather than pop
- Buttons should have hover transitions
- Lists should animate item additions/removals
- State changes should feel connected, not jarring

WoW provides `AnimationGroup` but the API is verbose and imperative. FenUI can provide a declarative layer that's easier to use and maintain.

## Proposed API

### Transitions (Property Changes)

```lua
-- Transition on property change
local panel = FenUI:CreatePanel(parent, {
    transitions = {
        alpha = { duration = 0.2, easing = "ease-out" },
        scale = { duration = 0.15 },
    },
})

-- Later, property changes animate automatically
panel:SetAlpha(0.5)  -- Fades to 0.5 over 0.2s
```

### Declarative Animations

```lua
-- Define animation
local fadeIn = FenUI.Animation:Define({
    from = { alpha = 0 },
    to = { alpha = 1 },
    duration = 0.3,
    easing = "ease-out",
})

-- Apply to frame
fadeIn:Play(panel)
fadeIn:Play(panel, { onComplete = function() print("Done!") end })
```

### Keyframe Animations

```lua
local bounce = FenUI.Animation:Keyframes({
    [0] = { scale = 1 },
    [0.5] = { scale = 1.2 },
    [1] = { scale = 1 },
    duration = 0.4,
    easing = "ease-in-out",
})
```

### Lifecycle Animations

```lua
-- Show/Hide with animation
local dialog = FenUI:CreateDialog(parent, {
    showAnimation = "fadeIn",
    hideAnimation = "fadeOut",
})

-- Or inline
local tooltip = FenUI:CreatePanel(parent, {
    showAnimation = { 
        alpha = { from = 0, to = 1 }, 
        duration = 0.15 
    },
})
```

### Builder API

```lua
local panel = FenUI.Panel(parent)
    :transition("alpha", { duration = 0.2 })
    :transition("scale", { duration = 0.15, easing = "ease-out" })
    :showAnimation("fadeSlideUp")
    :hideAnimation("fadeSlideDown")
    :build()
```

### Animation Library

```lua
-- Built-in named animations
FenUI.Animations = {
    fadeIn = { alpha = { from = 0, to = 1 }, duration = 0.2 },
    fadeOut = { alpha = { from = 1, to = 0 }, duration = 0.2 },
    slideUp = { offset = { from = {0, -20}, to = {0, 0} }, duration = 0.25 },
    scaleIn = { scale = { from = 0.9, to = 1 }, duration = 0.15 },
    bounce = { ... },
}
```

## Implementation Notes

### WoW AnimationGroup Integration

FenUI wraps WoW's native system:

```lua
-- Under the hood
local ag = frame:CreateAnimationGroup()
local anim = ag:CreateAnimation("Alpha")
anim:SetFromAlpha(0)
anim:SetToAlpha(1)
anim:SetDuration(0.2)
anim:SetSmoothing("OUT")
ag:Play()
```

### Supported Properties

| Property | WoW Animation Type | Notes |
|----------|-------------------|-------|
| `alpha` | Alpha | 0-1 |
| `scale` | Scale | Uniform or {x, y} |
| `offset` | Translation | {x, y} from current position |
| `rotation` | Rotation | Degrees |
| `width/height` | Custom (OnUpdate) | Not native, requires scripting |

### Easing Functions

Map to WoW's smoothing:
- `"linear"` → `"NONE"`
- `"ease-in"` → `"IN"`
- `"ease-out"` → `"OUT"`
- `"ease-in-out"` → `"IN_OUT"`

Custom easing requires OnUpdate-based animation.

### Transition System

1. Intercept property setters (e.g., `SetAlpha`)
2. Check if transition is defined for property
3. Create/update AnimationGroup with current → target values
4. Play animation

### Combat Lockdown Considerations

- Animations can play during combat
- Position-based animations on protected frames may taint
- Provide fallback for instant transitions when necessary

### Performance

- Reuse AnimationGroups rather than recreating
- Limit concurrent animations
- Prefer native animation types over OnUpdate

## Dependencies

- WoW's AnimationGroup API
- FenUI frame registry for tracking

## Open Questions

1. **How to handle interrupted animations?**
   - Cancel and jump to end?
   - Blend into new animation?
   - Recommendation: Cancel + start new from current state

2. **Should transitions auto-apply to all instances of a widget type?**
   - Theme-level transitions vs instance-level
   - Recommendation: Instance-level by default, theme override possible

3. **Animation sequencing/chaining?**
   - `anim1:Then(anim2):Then(anim3)`
   - Important for complex choreography

4. **Width/height animation implementation?**
   - OnUpdate with lerp is expensive
   - Maybe limit to special cases

## Tasks

- [ ] Create `FenUI.Animation` module
- [ ] Implement `Animation:Define()` for simple animations
- [ ] Implement `Animation:Keyframes()` for multi-step animations
- [ ] Create transition property interceptor system
- [ ] Map easing names to WoW smoothing types
- [ ] Build animation library with common presets
- [ ] Add `showAnimation`/`hideAnimation` to Layout
- [ ] Add `showAnimation`/`hideAnimation` to Panel
- [ ] Implement animation chaining (`:Then()`)
- [ ] Add animation callbacks (onStart, onComplete, onCancel)
- [ ] Handle combat lockdown edge cases
- [ ] Create builder API methods
- [ ] Write performance benchmarks
- [ ] Document animation system
- [ ] Create showcase examples

