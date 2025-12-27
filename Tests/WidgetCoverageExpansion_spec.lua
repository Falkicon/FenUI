-- luacheck: globals describe it before_each after_each setup teardown assert spy stub mock pending FenUI CreateFrame UIParent
describe("FenUI Widget Coverage Expansion", function()
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
        require("Widgets.Panel")
        require("Widgets.Tabs")
        require("Widgets.Grid")
        require("Widgets.Buttons")
        require("Widgets.Image")
        require("Widgets.ImageButton")
    end)

    describe("Panel Expansion", function()
        it("should handle title and subtitle updates", function()
            local panel = FenUI:CreatePanel(UIParent, { title = "Old" })
            panel:SetTitle("New Title")
            assert.is_equal(panel:GetTitle(), "New Title")
            
            panel:SetSubtitle("Sub")
            assert.is_equal(panel:GetSubtitle(), "Sub")
        end)

        it("should handle padding and slot clearing", function()
            local panel = FenUI:CreatePanel(UIParent)
            panel:SetPadding(20)
            panel:ClearSlot("footer")
            -- Should not crash
        end)
    end)

    describe("Tabs Expansion", function()
        it("should handle tab visibility and disabling", function()
            local tabs = FenUI:CreateTabGroup(UIParent, {
                tabs = { { text = "T1", id = 1 }, { text = "T2", id = 2 } }
            })
            tabs:SetTabVisible(1, false)
            tabs:SetTabDisabled(2, true)
            assert.is_false(tabs:GetTab(2):IsEnabled())
        end)

        it("should handle programmatic selection", function()
            local tabs = FenUI:CreateTabGroup(UIParent, {
                tabs = { { text = "A", id = "a" }, { text = "B", id = "b" } }
            })
            tabs:Select("b")
            assert.is_equal(tabs:GetSelected(), "b")
        end)
    end)

    describe("Grid Expansion", function()
        it("should handle sorting and filtering", function()
            local grid = FenUI:CreateGrid(UIParent, {
                columns = { "1fr" }
            })
            grid:SetData({ { val = 2 }, { val = 1 } })
            grid:Sort(function(a, b) return a.val < b.val end)
            assert.is_equal(grid.data[1].val, 1)
            
            grid:Filter(function(item) return item.val > 1 end)
            assert.is_equal(#grid.rows, 1)
        end)
    end)
end)

