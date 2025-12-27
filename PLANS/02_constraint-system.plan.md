# Constraint System

> **Status**: Proposed
> **Priority**: High
> **Complexity**: Medium

## Summary

A constraint system that adds `minWidth`, `maxWidth`, `minHeight`, `maxHeight`, and `aspectRatio` support to FenUI components. This ensures components maintain size boundaries regardless of content or responsive sizing, and enables aspect-ratio-locked elements like thumbnails and icons.

## Motivation

The current responsive sizing system (`%`, `vh`, `vw`, `auto`) is powerful but lacks boundaries:

- A dialog sized at `"80%"` might become too wide on ultrawide monitors
- An `"auto"` button could grow unbounded with long text
- Image containers need to maintain aspect ratios when resized
- Minimum sizes prevent UI elements from becoming unusable

Constraints provide guardrails that keep layouts usable across all screen sizes and content states.

## Proposed API

### Basic Constraints

```lua
-- Factory API with constraints
local panel = FenUI:CreatePanel(parent, {
    width = "80%",
    minWidth = 300,
    maxWidth = 800,
    height = "auto",
    minHeight = 200,
})

-- Builder API
local card = FenUI.Panel(parent)
    :width("100%")
    :minWidth(250)
    :maxWidth(400)
    :height("auto")
    :minHeight(150)
    :build()
```

### Aspect Ratio

```lua
-- Lock to 16:9
local thumbnail = FenUI:CreateLayout(parent, {
    width = "100%",
    aspectRatio = 16/9,  -- height = width * (9/16)
})

-- Square
local avatar = FenUI:CreateLayout(parent, {
    width = 64,
    aspectRatio = 1,
})

-- Aspect ratio with constraints
local image = FenUI:CreateLayout(parent, {
    width = "50%",
    aspectRatio = 4/3,
    maxWidth = 400,
    maxHeight = 300,
})
```

### Constraint Direction

```lua
-- aspectRatio can be width-based or height-based
local container = FenUI:CreateLayout(parent, {
    height = 200,
    aspectRatio = 16/9,
    aspectBase = "height",  -- width = height * (16/9)
})
```

## Implementation Notes

### Integration with ApplySize

Extend `FenUI.Utils:ApplySize()` to:

1. Resolve the base size (px, %, vh, vw, auto)
2. Apply min constraint: `size = math.max(size, minSize)`
3. Apply max constraint: `size = math.min(size, maxSize)`
4. If aspectRatio is set, calculate the dependent dimension
5. Re-apply constraints to the dependent dimension

### Constraint Resolution Order

```
1. Parse base value → baseSize
2. Apply minWidth/minHeight → constrainedSize
3. Apply maxWidth/maxHeight → constrainedSize
4. If aspectRatio, calculate other dimension
5. Apply constraints to other dimension
6. If conflict (aspect vs constraint), constraint wins
```

### Reactive Updates

- When parent resizes, re-evaluate constraints
- When content changes (for `auto`), re-evaluate constraints
- Aspect ratio updates trigger in the `OnSizeChanged` handler

### Constraint Storage

```lua
frame._fenui_constraints = {
    minWidth = 200,
    maxWidth = 800,
    minHeight = nil,
    maxHeight = nil,
    aspectRatio = nil,
    aspectBase = "width",
}
```

### Edge Cases

- **Conflicting constraints**: `minWidth > maxWidth` - use maxWidth
- **Aspect ratio impossible**: Container too small - prioritize constraints over ratio
- **Infinite loop prevention**: Track recursion depth in reactive updates

## Dependencies

- `FenUI.Utils:ParseSize()` - Already implemented
- `FenUI.Utils:ApplySize()` - Needs extension

## Open Questions

1. **Should aspect ratio break or constrain?**
   - When maxHeight would require width beyond maxWidth, what wins?
   - Recommendation: Constraints win, aspect ratio degrades gracefully

2. **How to express aspect ratio in config?**
   - Number (16/9 = 1.777)
   - String ("16:9") - more readable but needs parsing
   - Recommendation: Support both

3. **Should there be a global constraint registry?**
   - Named constraint sets like `"dialog"` that map to { minWidth=400, maxWidth=800 }
   - Could be useful for consistency

## Tasks

- [ ] Extend `ApplySize()` to check min/max constraints
- [ ] Add constraint storage to frame metadata
- [ ] Implement aspect ratio calculation
- [ ] Add `aspectBase` support (width vs height based)
- [ ] Handle constraint conflicts gracefully
- [ ] Add string parsing for aspect ratios ("16:9")
- [ ] Update Layout widget to pass constraints
- [ ] Update Panel widget to pass constraints
- [ ] Update Group widget to pass constraints
- [ ] Update Button widget to support constraints
- [ ] Add constraint support to builder APIs
- [ ] Write unit tests for edge cases
- [ ] Document constraint system in FenUI docs

