-- luacheck: globals describe it before_each after_each setup teardown assert spy stub mock pending FenUI CreateFrame UIParent
describe("FenUI Container Widgets", function()
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
        require("Widgets.Containers")
        require("Widgets.Tabs")
        require("Widgets.Toolbar")
        require("Widgets.ScrollBar")
        require("Widgets.Image")
        require("Widgets.ImageButton")
        require("Widgets.Buttons")
    end)

    describe("Panel", function()
        it("should create a themed panel with title", function()
            local panel = FenUI:CreatePanel(UIParent, {
                title = "Test Panel",
                width = 400,
                height = 300,
                movable = true,
                closable = true
            })
            assert.is_not_nil(panel)
            assert.is_equal(panel.titleText:GetText(), "Test Panel")
            assert.is_not_nil(panel.closeButton)
        end)

        it("should handle footer slot", function()
            local panel = FenUI:CreatePanel(UIParent, {})
            local footer = CreateFrame("Frame")
            panel:SetSlot("footer", footer)
            assert.is_equal(panel:GetSlot("footer"), footer)
            
            panel:ClearSlot("footer")
            assert.is_nil(panel:GetSlot("footer"))
        end)

        it("should handle resizing and constraints", function()
            local panel = FenUI:CreatePanel(UIParent, {
                width = 300, height = 200,
                resizable = true,
                minWidth = 200, minHeight = 150,
                maxWidth = 500, maxHeight = 400
            })
            assert.is_true(panel.config.resizable)
            assert.is_not_nil(panel.resizeHandle)
            
            panel:SetSize(600, 500)
            panel:ApplyConstraints()
            assert.is_equal(500, panel:GetWidth())
            assert.is_equal(400, panel:GetHeight())
        end)

        it("should handle movable and dragging", function()
            local panel = FenUI:CreatePanel(UIParent, { movable = true })
            assert.is_true(panel:IsMovable())
            
            local script = panel:GetScript("OnDragStart")
            if script then script(panel) end
            
            script = panel:GetScript("OnDragStop")
            if script then script(panel) end
        end)

        it("should support the builder pattern (fluent API)", function()
            local panel = FenUI.Panel(UIParent)
                :title("Fluent Panel")
                :size(500, 400)
                :movable(true)
                :build()
            
            assert.is_equal(panel:GetTitle(), "Fluent Panel")
            assert.is_equal(panel:GetWidth(), 500)
            assert.is_true(panel.config.movable)
        end)

        it("should manage safe zone and content frame", function()
            local panel = FenUI:CreatePanel(UIParent, {
                title = "Title",
                padding = 10
            })
            local safeZone = panel:GetSafeZone()
            local content = panel:GetContentFrame()
            
            assert.is_not_nil(safeZone)
            assert.is_not_nil(content)
            assert.is_equal(content:GetParent(), panel)
            
            panel:SetPadding(20)
            assert.is_equal(panel.padding.left, 20)
        end)

        it("should handle theme integration", function()
            local called = false
            local panel = FenUI:CreatePanel(UIParent, { 
                onThemeChange = function() called = true end 
            })
            panel:SetTheme("dark")
            panel:OnFenUIThemeChanged("dark", {})
            assert.is_true(called)
            
            panel:UnregisterFromThemeChanges()
        end)

        it("should handle lifecycle hooks", function()
            local panel = FenUI:CreatePanel(UIParent)
            local showCalled, hideCalled = false, false
            panel:SetOnShow(function() showCalled = true end)
            panel:SetOnHide(function() hideCalled = true end)
            
            panel:Show()
            local script = panel:GetScript("OnShow")
            if script then script(panel) end
            assert.is_true(showCalled)
            
            panel:Hide()
            script = panel:GetScript("OnHide")
            if script then script(panel) end
            assert.is_true(hideCalled)
        end)
    end)

    describe("Tabs", function()
        it("should create a tab group and handle selection", function()
            local tabGroup = FenUI:CreateTabGroup(UIParent, {
                tabs = {
                    { key = "general", text = "General" },
                    { key = "advanced", text = "Advanced" }
                }
            })
            assert.is_equal(tabGroup.selectedKey, "general")
            
            tabGroup:Select("advanced")
            assert.is_equal(tabGroup.selectedKey, "advanced")
        end)

        it("should support badges on tabs", function()
            local tabGroup = FenUI:CreateTabGroup(UIParent, {
                tabs = { { key = "mail", text = "Mail" } }
            })
            tabGroup:SetTabBadge("mail", "5", "red")
            local tab = tabGroup:GetTab("mail")
            assert.is_not_nil(tab.badge)
            assert.is_equal(tab.badge:GetText(), "5")
            
            -- Test texture badge
            tabGroup:SetTabBadge("mail", "interface\\icons\\inv_misc_questionmark")
            assert.is_not_nil(tab.badge)
        end)

        it("should support disabling tabs", function()
            local tabGroup = FenUI:CreateTabGroup(UIParent, {
                tabs = { { key = "lock", text = "Locked" } }
            })
            tabGroup:SetTabDisabled("lock", true)
            local tab = tabGroup:GetTab("lock")
            assert.is_false(tab:IsEnabled())
            
            tabGroup:Select("lock")
            assert.is_nil(tabGroup.selectedKey) -- Should not select disabled tab if it was the only one
        end)

        it("should handle visibility and focus", function()
            local tabGroup = FenUI:CreateTabGroup(UIParent, {
                tabs = { { key = "t1", text = "T1" } }
            })
            tabGroup:SetTabVisible("t1", false)
            assert.is_false(tabGroup:GetTab("t1"):IsShown())
            
            tabGroup:SetFocus("t1")
            assert.is_true(tabGroup:GetTab("t1").isFocused)
        end)

        it("should support the builder API", function()
            local tabGroup = FenUI.TabGroup(UIParent)
                :tab("a", "A")
                :tab("b", "B")
                :height(40)
                :build()
            assert.is_equal(tabGroup:GetHeight(), 40)
            assert.is_not_nil(tabGroup:GetTab("a"))
        end)
    end)

    describe("Toolbar", function()
        it("should create a toolbar and add items", function()
            local toolbar = FenUI:CreateToolbar(UIParent, {
                height = 32
            })
            local item = toolbar:AddIconButton({
                icon = "Interface\\Icons\\INV_Misc_QuestionMark",
                tooltip = "Help"
            })
            assert.is_not_nil(item)
            assert.is_equal(#toolbar.items, 1)
        end)
    end)

    describe("ScrollPanel", function()
        it("should create a scroll panel", function()
            local sp = FenUI:CreateScrollPanel(UIParent, { padding = 10, showScrollBar = true })
            assert.is_not_nil(sp.scrollFrame)
            assert.is_not_nil(sp.scrollBar)
            assert.is_not_nil(sp.scrollChild)
        end)

        it("should handle scroll child and updates", function()
            local sp = FenUI:CreateScrollPanel(UIParent)
            local child = sp:GetScrollChild()
            assert.is_not_nil(child)
            
            sp:SetContentHeight(500)
            assert.is_equal(child:GetHeight(), 500)
            
            sp:ScrollToTop()
            assert.is_equal(sp.scrollFrame:GetVerticalScroll(), 0)
            
            sp:ScrollToBottom()
            -- Mock VerticalScrollRange is 0 by default, but let's test it doesn't crash
        end)

        it("should handle mouse wheel interaction", function()
            local sp = FenUI:CreateScrollPanel(UIParent)
            local scrollBar = sp.scrollBar
            scrollBar:SetValue(50)
            
            local script = sp.scrollFrame:GetScript("OnMouseWheel")
            if script then script(sp.scrollFrame, 1) end -- Scroll up
            assert.is_equal(scrollBar:GetValue(), 30) -- 50 - 20
        end)
    end)

    describe("ScrollInset", function()
        it("should create a scroll inset", function()
            local inset, child = FenUI:CreateScrollInset(UIParent, { scrollPadding = 5 })
            assert.is_not_nil(inset.scrollPanel)
            assert.is_equal(child, inset.scrollChild)
            
            assert.is_equal(inset:GetScrollChild(), child)
            inset:SetContentHeight(1000)
            inset:ScrollToTop()
        end)
    end)
end)

