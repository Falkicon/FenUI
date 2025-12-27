# Stack/Flex Layout System

> **Status**: Completed
> **Priority**: High
> **Complexity**: High

## Summary

A Flexbox-inspired layout system that provides declarative horizontal and vertical stacking with alignment, justification, gap control, and optional wrapping. This brings familiar CSS Flexbox concepts to WoW UI development while respecting the constraints of the game's frame-based rendering engine.

## Proposed API

### Basic Stack (Vertical)

```lua
-- Factory API
local stack = FenUI:CreateStack(parent, {
    direction = "vertical",  -- "horizontal" | "vertical"
    gap = "sm",              -- spacing token or pixels
    align = "stretch",       -- "start" | "center" | "end" | "stretch"
    justify = "start",       -- "start" | "center" | "end" | "space-between" | "space-around"
})

stack:AddChild(button1)
stack:AddChild(button2)
stack:AddChild(button3)
```

### Builder API

```lua
local stack = FenUI.Stack(parent)
    :direction("horizontal")
    :gap("md")
    :align("center")
    :justify("space-between")
    :padding("lg")
    :build()
```

### Flex Container with Wrapping

```lua
local flex = FenUI:CreateFlex(parent, {
    direction = "horizontal",
    wrap = true,             -- Enable wrapping
    gap = "sm",
    rowGap = "md",           -- Gap between wrapped rows
    align = "start",
    justify = "start",
})
```

### Child-Level Overrides

```lua
-- Override alignment for specific child
stack:AddChild(button, { align = "end" })

-- Flex grow/shrink (for horizontal layouts)
stack:AddChild(spacer, { grow = 1 })
stack:AddChild(button, { shrink = 0 })
```

## Implementation Notes

### Core Algorithm

1. **Measure Phase**: Query each child's size (using `GetSize()` or intrinsic sizing)
2. **Layout Phase**: Calculate positions based on direction, gap, and alignment
3. **Apply Phase**: Set anchors on each child frame

### Reactivity

- Hook into child `OnSizeChanged` events to trigger re-layout
- Debounce rapid size changes using a short timer (~0.01s)
- Provide manual `stack:Layout()` for explicit updates

### Integration with Existing Systems

- Use `FenUI.Utils:ParseSize()` for gap values (supports tokens, px, %)
- Respect child margin values as additional spacing
- Support `auto` sizing on the Stack itself (shrink-wrap to content)

### Performance Considerations

- Cache child measurements during layout pass
- Only re-layout when children are added/removed or sizes change
- Use `SetPoint` batching where possible

### Edge Cases

- Empty container: Collapse to zero size or maintain minimum
- Single child: Alignment still applies, gap is ignored
- Hidden children: Skip in layout calculations (check `:IsShown()`)

## Dependencies

- `FenUI.Utils:ParseSize()` - Already implemented
- `FenUI.Utils:ObserveIntrinsicSize()` - For auto-sizing containers
- Design tokens for gap values

## Open Questions

1. **Should Stack extend Layout or be standalone?**
   - **Resolved**: Extends Layout to inherit border/background support.

2. **How to handle `wrap` with limited vertical space?**
   - **Resolved**: Standard wrapping logic; scrolling is handled by wrapping the Flex container in a ScrollPanel if needed.

3. **Should flex-grow work in vertical layouts?**
   - **Resolved**: Yes, implemented for both horizontal and vertical.

4. **Animation during layout changes?**
   - **Planned**: To be integrated with the Animation system (Plan 03).

## Tasks

- [x] Design core StackMixin with direction and gap support
- [x] Implement measure/layout/apply algorithm
- [x] Add alignment (align-items equivalent)
- [x] Add justification (justify-content equivalent)
- [x] Implement child OnSizeChanged reactivity
- [x] Add wrap support for FlexMixin
- [x] Add rowGap support for wrapped layouts
- [x] Implement flex-grow and flex-shrink
- [x] Add child-level override support (align-self)
- [x] Create builder API
- [x] Write unit tests
- [x] Document API in FenUI docs
- [x] Create example implementations
