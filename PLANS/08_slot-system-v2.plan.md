# Slot System 2.0

> **Status**: Proposed
> **Priority**: Medium
> **Complexity**: Medium

## Summary

An enhanced slot system that formalizes named content regions within FenUI components. Building on the existing slot concept, this adds typed slots, slot validation, default content, fallback behavior, and multi-slot patterns. Enables true component composition where parents define structure and children fill content.

## Motivation

Current FenUI components have implicit slots:

- Panel has header, body, footer regions
- Dialog has title, content, actions areas
- Card has media, content, actions slots

But these aren't formally defined, making it unclear:

- What slots are available?
- What content types are expected?
- What happens if a slot is empty?
- Can slots have default content?

A formal slot system provides:

- Clear API contracts
- Validation and error messages
- Default/fallback content
- Multi-element slots
- Slot metadata for tooling

## Proposed API

### Slot Definition

```lua
-- Define slots when creating a component template
local CardTemplate = FenUI:DefineComponent("Card", {
    slots = {
        media = {
            type = "single",       -- "single" | "multiple"
            accepts = { "Texture", "Frame" },
            required = false,
            default = nil,
        },
        content = {
            type = "single",
            accepts = "any",
            required = true,
            default = function(parent)
                return FenUI:CreateLabel(parent, { text = "No content" })
            end,
        },
        actions = {
            type = "multiple",
            accepts = { "Button" },
            required = false,
            maxItems = 3,
        },
    },
})
```

### Filling Slots

```lua
-- Factory API with slots
local card = FenUI:CreateCard(parent, {
    slots = {
        media = function(container)
            local tex = container:CreateTexture()
            tex:SetTexture("Interface/Icons/Ability_Rogue_Sprint")
            return tex
        end,
        content = function(container)
            return FenUI:CreateLabel(container, { text = "Card content here" })
        end,
        actions = {
            FenUI:CreateButton(nil, { text = "Action 1" }),
            FenUI:CreateButton(nil, { text = "Action 2" }),
        },
    },
})
```

### Builder API

```lua
local card = FenUI.Card(parent)
    :slot("media", function(c)
        local img = c:CreateTexture()
        img:SetTexture(iconPath)
        return img
    end)
    :slot("content", FenUI:CreateLabel(nil, { text = "Hello" }))
    :slotMultiple("actions", {
        FenUI:CreateButton(nil, { text = "OK" }),
        FenUI:CreateButton(nil, { text = "Cancel" }),
    })
    :build()
```

### Slot Queries

```lua
-- Get slot content
local content = card:GetSlot("content")
local actions = card:GetSlot("actions")  -- Returns array for multiple slots

-- Check if slot is filled
if card:HasSlot("media") then ... end

-- Clear slot
card:ClearSlot("actions")

-- Replace slot content
card:SetSlot("content", newContent)
```

### Slot Metadata

```lua
-- Introspect available slots
local slotDefs = FenUI:GetSlotDefinitions("Card")
-- Returns: { media = {...}, content = {...}, actions = {...} }

-- Validate slot content
local isValid, error = FenUI:ValidateSlotContent("Card", "actions", button)
```

## Implementation Notes

### Slot Storage

```lua
frame._fenui_slots = {
    media = {
        definition = { type = "single", ... },
        content = textureFrame,
        container = mediaContainer,
    },
    actions = {
        definition = { type = "multiple", ... },
        content = { button1, button2 },
        container = actionsContainer,
    },
}
```

### Slot Containers

Each slot has an internal container frame for positioning:

```lua
function Component:CreateSlotContainer(slotName, config)
    local container = CreateFrame("Frame", nil, self)
    container:SetAllPoints()  -- Default, can be overridden
    
    self._fenui_slots[slotName] = {
        container = container,
        content = nil,
        definition = config,
    }
    
    return container
end
```

### Content Resolution

Slot content can be:

1. **Frame** - Use directly
2. **Function** - Call with container, use return value
3. **Array** - For multiple slots, process each element
4. **nil** - Use default or leave empty

```lua
function Component:ResolveSlotContent(slotName, value)
    if type(value) == "function" then
        local container = self._fenui_slots[slotName].container
        return value(container)
    elseif type(value) == "table" and value.GetObjectType then
        return value  -- It's a frame
    elseif type(value) == "table" then
        return value  -- Array of items
    end
    return nil
end
```

### Validation

```lua
function Component:ValidateSlot(slotName, content)
    local def = self._fenui_slots[slotName].definition
    
    -- Check required
    if def.required and not content then
        return false, "Slot '" .. slotName .. "' is required"
    end
    
    -- Check accepts
    if def.accepts ~= "any" then
        local contentType = content:GetObjectType()
        if not tContains(def.accepts, contentType) then
            return false, "Slot '" .. slotName .. "' does not accept " .. contentType
        end
    end
    
    -- Check maxItems for multiple slots
    if def.type == "multiple" and def.maxItems then
        if #content > def.maxItems then
            return false, "Slot '" .. slotName .. "' exceeds max items"
        end
    end
    
    return true
end
```

### Default Content

```lua
function Component:ApplySlotDefaults()
    for slotName, slot in pairs(self._fenui_slots) do
        if not slot.content and slot.definition.default then
            local default = slot.definition.default
            if type(default) == "function" then
                slot.content = default(slot.container)
            else
                slot.content = default
            end
        end
    end
end
```

## Dependencies

- Existing component architecture
- Frame hierarchy management

## Open Questions

1. **Should slots support lazy loading?**
   - Only create content when slot becomes visible
   - Recommendation: Nice to have, Phase 2

2. **Slot lifecycle hooks?**
   - onFill, onClear, onChange
   - Recommendation: Yes, useful for cleanup

3. **Slot styling/layout?**
   - How does slot container handle positioning?
   - Recommendation: Each component defines slot layout internally

4. **TypeScript-style slot type hints?**
   - For IDE support
   - Recommendation: Document thoroughly, types are runtime-validated

## Tasks

- [ ] Design slot definition schema
- [ ] Create `FenUI:DefineComponent()` API
- [ ] Implement slot container creation
- [ ] Implement content resolution (frames, functions, arrays)
- [ ] Add slot validation
- [ ] Implement default content
- [ ] Create `GetSlot()`, `SetSlot()`, `ClearSlot()` methods
- [ ] Add `HasSlot()` check
- [ ] Implement slot metadata introspection
- [ ] Add slot lifecycle hooks
- [ ] Update Card component with formal slots
- [ ] Update Dialog component with formal slots
- [ ] Update Panel component with formal slots
- [ ] Add slot support to builder API
- [ ] Write validation tests
- [ ] Document slot system
- [ ] Create component composition examples

