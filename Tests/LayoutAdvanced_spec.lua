-- luacheck: globals describe it before_each after_each setup teardown assert spy stub mock pending FenUI CreateFrame UIParent
describe("FenUI Layout Advanced", function()
    setup(function()
        require("Core.FenUI")
        require("Utils.Utils")
        require("Core.Tokens")
        require("Core.ThemeManager")
        require("Core.BlizzardBridge")
        require("Utils.Environment")
        require("Utils.Formatting")
        require("Utils.Colors")
        require("Utils.Tables")
        require("Utils.UI")
        require("Widgets.Layout")
        require("Widgets.Stack")
        require("Widgets.Group")
    end)

    describe("Layout Constraints", function()
        it("should handle min/max constraints", function()
            -- Test minWidth
            local layout = FenUI:CreateLayout(UIParent, {
                width = 50, height = 50,
                minWidth = 100, minHeight = 100
            })
            assert.is_equal(100, layout:GetWidth())
            
            -- Test maxWidth
            layout = FenUI:CreateLayout(UIParent, {
                width = 500, height = 500,
                maxWidth = 300, maxHeight = 300
            })
            assert.is_equal(300, layout:GetWidth())
        end)
    end)

    describe("Complex Grid Layouts", function()
        it("should handle mixed unit definitions", function()
            local layout = FenUI:CreateLayout(UIParent, {
                width = 500, height = 500,
                cols = { "100px", "2fr", "1fr" }
            })
            layout:UpdateLayout()
            
            -- Total width = 500. Fixed = 100. Available = 400.
            -- fr unit = 400 / 3 = 133.33
            -- Col 1 = 100px
            -- Col 2 = 2 * 133.33 = 266.66
            -- Col 3 = 1 * 133.33 = 133.33
            assert.is_equal(layout.cells[1]:GetWidth(), 100)
            assert.is_true(math.abs(layout.cells[2]:GetWidth() - 266.66) < 1)
            assert.is_true(math.abs(layout.cells[3]:GetWidth() - 133.33) < 1)
        end)

        it("should handle nested layouts", function()
            local outer = FenUI:CreateLayout(UIParent, { width = 400, height = 400, cols = { "1fr" } })
            local inner = FenUI:CreateLayout(outer, { width = "100%", height = "100%" })
            outer:SetCellContent(1, 1, inner)
            outer:UpdateLayout()
            -- When UpdateLayout is called, the cells are sized. 
            -- But inner width="100%" is relative to UIParent by default if not updated.
            -- Actually, UpdateDynamicSize uses parent:GetWidth().
            inner:SetParent(outer.cells[1])
            inner:UpdateDynamicSize()
            assert.is_equal(inner:GetWidth(), 400)
        end)
    end)

    describe("Stack Advanced", function()
        it("should handle justification end", function()
            local stack = FenUI:CreateStack(UIParent, {
                direction = "horizontal",
                width = 200,
                justify = "end"
            })
            local c1 = CreateFrame("Frame", nil, stack); c1:SetSize(50, 50)
            stack:AddChild(c1)
            stack:Layout()
            local _, _, _, x = c1:GetPoint()
            assert.is_equal(x, 150)
        end)

        it("should handle justification center", function()
            local stack = FenUI:CreateStack(UIParent, {
                direction = "horizontal",
                width = 200,
                justify = "center"
            })
            local c1 = CreateFrame("Frame", nil, stack); c1:SetSize(50, 50)
            stack:AddChild(c1)
            stack:Layout()
            local _, _, _, x = c1:GetPoint()
            assert.is_equal(x, 75)
        end)
    end)

    describe("Group Advanced", function()
        it("should support custom rows", function()
            local group = FenUI:CreateGroup(UIParent, {
                width = 300,
                rows = 4
            })
            assert.is_not_nil(group.cells[1])
            assert.is_not_nil(group.cells[4])
        end)
    end)
end)
