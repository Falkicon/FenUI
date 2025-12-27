# calc() Size Expressions

> **Status**: Proposed
> **Priority**: Medium
> **Complexity**: Medium

## Summary

Support for mathematical expressions in size values, similar to CSS `calc()`. This enables dynamic sizing like `"100% - 40px"` or `"50vh + 20"` that combines relative and absolute units in a single declaration.

## Motivation

Current sizing supports individual units but not combinations:

```lua
-- Can do:
width = "80%"
width = 400
width = "50vh"

-- Cannot do (yet):
width = "100% - 40px"    -- Full width minus sidebar
width = "50% + 20"       -- Half plus fixed padding
width = "100vh - 200px"  -- Viewport minus header/footer
```

Many real-world layouts need these combinations:

- Content area that's "100% minus sidebar width"
- Dialogs that are "80% of viewport, minimum 400px"
- Responsive grids with fixed gutters

## Proposed API

### Basic Expressions

```lua
local content = FenUI:CreatePanel(parent, {
    width = "100% - 250px",  -- Full width minus sidebar
    height = "100%",
})

local dialog = FenUI:CreateDialog(parent, {
    width = "80vw - 40px",   -- 80% viewport width minus margins
    height = "calc(100vh - 200)",  -- Optional calc() wrapper
})
```

### Supported Operations

```lua
width = "50% + 100px"    -- Addition
width = "100% - 40"      -- Subtraction
width = "50% * 2"        -- Multiplication (less common)
width = "200px / 2"      -- Division
width = "(100% - 40px) / 2"  -- Parentheses for order of operations
```

### Mixed Units

```lua
-- All units can mix
width = "50% + 10vh"     -- Percentage + viewport
width = "100vw - 300px"  -- Viewport - pixels
```

### Nested calc()

```lua
-- For complex expressions
width = "calc(100% - calc(50px + 10%))"
```

### Builder API

```lua
local panel = FenUI.Panel(parent)
    :width("100% - 300px")
    :height("calc(100vh - 150)")
    :minWidth(400)
    :build()
```

## Implementation Notes

### Expression Parser

```lua
-- Tokenize expression
"100% - 40px" → { {100, "%"}, "-", {40, "px"} }

-- Parse into AST
{
    type = "subtract",
    left = { type = "percentage", value = 100 },
    right = { type = "pixels", value = 40 },
}
```

### Evaluation Function

```lua
function FenUI.Utils:EvaluateCalc(expression, parentSize)
    local ast = self:ParseCalcExpression(expression)
    return self:EvaluateAST(ast, parentSize)
end
```

### Integration with ParseSize

Extend `FenUI.Utils:ParseSize()`:

```lua
function Utils:ParseSize(value, parentSize)
    if type(value) == "string" then
        -- Check for operators
        if value:match("[%+%-%*/]") then
            return self:EvaluateCalc(value, parentSize)
        end
        -- Existing unit parsing...
    end
end
```

### Reactive Updates

calc() expressions are re-evaluated when:
- Parent resizes (for `%` units)
- Viewport resizes (for `vh`/`vw` units)

This reuses the existing responsive sizing hooks.

### Grammar

```
expression := term (('+' | '-') term)*
term := factor (('*' | '/') factor)*
factor := number unit? | '(' expression ')'
unit := '%' | 'px' | 'vh' | 'vw'
number := [0-9]+('.'[0-9]+)?
```

### Performance

- Parse expressions once on first use
- Cache the AST in frame metadata
- Only re-evaluate numeric result on resize

## Dependencies

- `FenUI.Utils:ParseSize()` - Already implemented, needs extension
- Responsive sizing system - Already implemented

## Open Questions

1. **Should `calc()` wrapper be required or optional?**
   - CSS requires it, but we could auto-detect
   - Recommendation: Optional, auto-detect expressions

2. **Error handling for invalid expressions?**
   - Silent fallback to 0?
   - Warning in debug mode?
   - Recommendation: Fallback + debug warning

3. **Support for variables/tokens in expressions?**
   - `"100% - $spacing.xl"` 
   - Would be powerful but complex
   - Recommendation: Phase 2 feature

4. **How to handle division by zero?**
   - Return 0 with warning
   - Recommendation: Yes, graceful degradation

## Tasks

- [ ] Design expression tokenizer
- [ ] Implement recursive descent parser
- [ ] Create AST data structure
- [ ] Implement AST evaluator
- [ ] Integrate with `ParseSize()`
- [ ] Add parentheses support
- [ ] Handle all unit types (%, px, vh, vw)
- [ ] Cache parsed expressions
- [ ] Connect to reactive resize system
- [ ] Error handling and validation
- [ ] Performance optimization
- [ ] Write unit tests for parser
- [ ] Write unit tests for edge cases
- [ ] Document calc() syntax
- [ ] Create examples

