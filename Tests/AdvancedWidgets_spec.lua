-- luacheck: globals describe it before_each after_each setup teardown assert spy stub mock pending FenUI CreateFrame UIParent
describe("FenUI Advanced Widgets", function()
    setup(function()
        require("Core.FenUI")
        require("Utils.Utils")
        require("Core.Tokens")
        require("Core.ThemeManager")
        require("Core.BlizzardBridge")
        require("Utils.UI")
        require("Widgets.Layout")
        require("Widgets.Stack")
        require("Widgets.Grid")
        require("Widgets.Image")
        require("Widgets.ImageButton")
        require("Widgets.Buttons")
        require("Widgets.Input")
        require("Widgets.Group")
        require("Widgets.EmptyState")
        require("Widgets.StatusRow")
        require("Widgets.SectionHeader")
        require("Widgets.Section")
        require("Widgets.Dropdown")
        require("Widgets.SplitLayout")
        require("Widgets.ScrollBar")
        require("Widgets.MultiLineEditBox")
        require("Widgets.Containers")
        require("Widgets.Panel")
        require("Widgets.Tabs")
        require("Widgets.InfoPanel")
        require("Widgets.Toolbar")
        require("Widgets.Tree")
    end)

    describe("InfoPanel", function()
        it("should create an info panel with sections", function()
            local ip = FenUI:CreateInfoPanel(UIParent, {
                title = "About My Addon",
                sections = {
                    { heading = "Overview", body = "This is a test addon." },
                    { heading = "Usage", body = "Click things to do stuff." }
                }
            })
            assert.is_not_nil(ip)
            assert.is_equal(#ip.sectionFrames, 2)
            assert.is_equal(ip.sectionFrames[1].heading:GetText(), "Overview")
        end)

        it("should handle adding sections dynamically", function()
            local ip = FenUI:CreateInfoPanel(UIParent, { title = "Dynamic" })
            ip:AddSection("New", "Content")
            assert.is_equal(#ip.sectionFrames, 1)
            assert.is_equal(ip.sectionFrames[1].heading:GetText(), "New")
            
            ip:ClearSections()
            assert.is_equal(#ip.sectionFrames, 0)
        end)

        it("should handle close button", function()
            local ip = FenUI:CreateInfoPanel(UIParent, { showCloseButton = true })
            assert.is_not_nil(ip.closeBtn)
            ip:Show()
            local script = ip.closeBtn:GetScript("OnClick")
            script(ip.closeBtn)
            assert.is_false(ip:IsShown())
        end)
        
        it("should scroll to top", function()
            local ip = FenUI:CreateInfoPanel(UIParent)
            -- Just check it doesn't crash
            ip:ScrollToTop()
        end)
    end)

    describe("Toolbar", function()
        it("should create a toolbar and add buttons", function()
            local tb = FenUI:CreateToolbar(UIParent, { height = 40 })
            assert.is_not_nil(tb)
            
            local b1 = tb:AddButton({ text = "B1" })
            local b2 = tb:AddIconButton({ icon = "test" })
            local b3 = tb:AddImageButton({ texture = "test" })
            
            assert.is_equal(#tb.items, 3)
            assert.is_equal(b1:GetParent(), tb)
        end)

        it("should handle spacers and dividers", function()
            local tb = FenUI:CreateToolbar(UIParent)
            tb:AddSpacer(10)
            tb:AddSpacer("flex")
            tb:AddDivider()
            
            assert.is_equal(#tb.items, 3)
            tb:UpdateLayout()
        end)

        it("should handle alignment", function()
            local tb = FenUI:CreateToolbar(UIParent, { align = "center", width = 200 })
            tb:AddButton({ text = "Btn", width = 50 })
            tb:UpdateLayout()
            -- xOffset should be around (200-50)/2 = 75
            local _, _, _, x = tb.items[1].frame:GetPoint()
            assert.is_equal(x, 75)
        end)

        it("should handle clearing items", function()
            local tb = FenUI:CreateToolbar(UIParent)
            tb:AddButton({ text = "B" })
            tb:Clear()
            assert.is_equal(#tb.items, 0)
        end)
    end)

    describe("Tree", function()
        it("should create a tree with data", function()
            local tree = FenUI:CreateTree(UIParent, {
                width = 200, height = 300
            })
            assert.is_not_nil(tree)
            
            tree:SetData({
                { text = "Root", value = "r", expanded = true, children = {
                    { text = "Child", value = "c" }
                }}
            })
            
            assert.is_equal(#tree.rows, 2)
            assert.is_equal(tree.rows[1].text:GetText(), "Root")
            assert.is_equal(tree.rows[2].text:GetText(), "Child")
        end)

        it("should handle selection", function()
            local selected = nil
            local tree = FenUI:CreateTree(UIParent, {
                onSelect = function(v) selected = v end
            })
            tree:SetData({ { text = "A", value = 1 } })
            
            local script = tree.rows[1]:GetScript("OnClick")
            script(tree.rows[1])
            assert.is_equal(selected, 1)
        end)
    end)
end)
