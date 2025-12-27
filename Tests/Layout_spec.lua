-- luacheck: globals describe it before_each after_each setup teardown assert spy stub mock pending FenUI CreateFrame UIParent
describe("FenUI Layout Foundational", function()
    setup(function()
        require("Core.FenUI")
        require("Utils.Utils")
        require("Core.Tokens")
        require("Core.ThemeManager")
        require("Core.BlizzardBridge")
        require("Utils.Environment")
        require("Utils.UI")
        require("Widgets.Layout")
        require("Widgets.Image")
    end)

    describe("Borders", function()
        it("should apply custom borders", function()
            local layout = FenUI:CreateLayout(UIParent, {
                border = "Modern"
            })
            assert.is_true(layout:HasBorder())
            assert.is_not_nil(layout.bgInset)
        end)

        it("should handle border removal", function()
            local layout = FenUI:CreateLayout(UIParent, { border = "Modern" })
            layout:SetBorder(false)
            assert.is_false(layout:HasBorder())
        end)
    end)

    describe("Backgrounds", function()
        it("should handle color backgrounds", function()
            local layout = FenUI:CreateLayout(UIParent, {
                background = "surfacePanel"
            })
            assert.is_true(layout.bgTexture:IsShown())
            
            layout:SetBackground(false)
            assert.is_false(layout.bgTexture:IsShown())
        end)

        it("should handle image backgrounds", function()
            local layout = FenUI:CreateLayout(UIParent, {
                background = { image = "interface\\icons\\inv_misc_questionmark" }
            })
            assert.is_not_nil(layout.bgImageFrame)
            assert.is_true(layout.bgImageFrame:IsShown())
        end)

        it("should handle gradient backgrounds", function()
            local layout = FenUI:CreateLayout(UIParent, {
                background = { gradient = { from = "black", to = "transparent" } }
            })
            assert.is_true(layout.bgTexture:IsShown())
        end)
    end)

    describe("Shadows", function()
        it("should handle inner shadows", function()
            local layout = FenUI:CreateLayout(UIParent, {
                shadow = "inner"
            })
            assert.is_not_nil(layout.shadowTextures)
            assert.is_true(layout.shadowTextures.topLeft:IsShown())
            
            layout:SetShadow(false)
            assert.is_false(layout.shadowTextures.topLeft:IsShown())
        end)

        it("should handle drop shadows", function()
            local layout = FenUI:CreateLayout(UIParent, {
                shadow = "soft"
            })
            assert.is_not_nil(layout.dropShadowFrame)
            assert.is_true(layout.dropShadowFrame:IsShown())
        end)
    end)

    describe("Cells", function()
        it("should handle cell operations", function()
            local layout = FenUI:CreateLayout(UIParent, {
                cols = 2,
                rows = 2
            })
            local cell = layout:GetCell(1, 1)
            assert.is_not_nil(cell)
            
            local content = CreateFrame("Frame")
            layout:SetCellContent(1, 1, content)
            
            layout:UpdateLayout()
        end)
    end)

    describe("Sizing & Margins", function()
        it("should handle margins", function()
            local layout = FenUI:CreateLayout(UIParent, {
                margin = 10,
                width = 100, height = 100
            })
            local margin = layout:GetMargin()
            assert.is_equal(margin.top, 10)
        end)

        it("should handle individual margin overrides", function()
            local layout = FenUI:CreateLayout(UIParent, {
                marginTop = 20,
                marginLeft = 5
            })
            local margin = layout:GetMargin()
            assert.is_equal(margin.top, 20)
            assert.is_equal(margin.left, 5)
        end)
    end)
end)

