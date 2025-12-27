-- luacheck: globals describe it before_each after_each setup teardown assert spy stub mock pending FenUI UIParent WoWAPI_MakeSecret
describe("FenUI Full Audit", function()
    setup(function()
        -- Load everything in TOC order
        require("wow_api_midnight")
        require("Core.FenUI")
        require("Utils.Utils")
        require("Core.Tokens")
        require("Core.BlizzardBridge")
        require("Core.ThemeManager")
        require("Core.Fonts")
        require("Validation.DependencyChecker")
        require("Utils.Environment")
        require("Utils.Formatting")
        require("Utils.Colors")
        require("Utils.Tables")
        require("Utils.SafeAPI")
        require("Utils.SecretValues")
        require("Utils.UI")
        require("Widgets.Image")
        require("Widgets.ImageButton")
        require("Widgets.ScrollBar")
        require("Widgets.Layout")
        require("Widgets.Stack")
        require("Widgets.Panel")
        require("Widgets.Containers")
        require("Widgets.Tabs")
        require("Widgets.Buttons")
        require("Widgets.Grid")
        require("Widgets.Toolbar")
        require("Widgets.EmptyState")
        require("Widgets.Group")
        require("Widgets.InfoPanel")
        require("Widgets.Input")
        require("Widgets.Section")
        require("Widgets.SectionHeader")
        require("Widgets.StatusRow")
        require("Widgets.Tree")
        require("Settings.ThemePicker")
    end)

    describe("Core", function()
        it("should have basic properties", function()
            assert.is_not_nil(FenUI.VERSION)
            assert.is_not_nil(FenUI.Tokens)
        end)

        it("should manage themes", function()
            assert.is_true(FenUI.ThemeManager:Exists("Default"))
            local list = FenUI:GetThemeList()
            assert.is_true(#list >= 1)
        end)
    end)

    describe("Utils", function()
        it("should resolve colors", function()
            local r, g, b = FenUI:GetColorRGB("surfacePanel")
            assert.is_not_nil(r)
        end)

        it("should format values", function()
            assert.is_equal("1.0 MB", FenUI.Utils:FormatMemory(1024))
            assert.is_equal("30.0s", FenUI.Utils:FormatDuration(30))
        end)

        it("should handle secrets", function()
            local secret = WoWAPI_MakeSecret("shhh")
            assert.is_true(FenUI.Utils:IsValueSecret(secret))
        end)
    end)

    describe("Widgets", function()
        it("should create common widgets", function()
            local layout = FenUI:CreateLayout(UIParent, { 
                width = 100, height = 100,
                rows = { "auto", "1fr" },
                cells = { [1] = { background = "gray800" } }
            })
            assert.is_not_nil(layout)
            assert.is_not_nil(layout.cells[1])

            local panel = FenUI:CreatePanel(UIParent, { title = "Audit", resizable = true, closable = true })
            assert.is_not_nil(panel)
            panel:SetTitle("New Title")
            panel:SetPadding(10)
            
            local btn = FenUI:CreateButton(panel, { text = "Click Me" })
            assert.is_not_nil(btn)
            btn:Disable()
            btn:Enable()

            local input = FenUI:CreateInput(panel, { placeholder = "Type..." })
            assert.is_not_nil(input)
            input:SetText("Hello")
            assert.is_equal("Hello", input:GetText())

            local tabs = FenUI:CreateTabGroup(panel, { 
                tabs = { 
                    { key = "1", text = "T1" },
                    { key = "2", text = "T2" }
                } 
            })
            assert.is_not_nil(tabs)
            tabs:Select("2")
            assert.is_equal("2", tabs.selectedKey)
        end)

        it("should create advanced widgets", function()
            local group = FenUI:CreateGroup(UIParent, { title = "Group" })
            assert.is_not_nil(group)

            local info = FenUI:CreateInfoPanel(UIParent, { 
                title = "Info",
                sections = {
                    { heading = "H1", body = "B1" }
                }
            })
            assert.is_not_nil(info)

            local tree = FenUI:CreateTree(UIParent, { 
                items = { 
                    { key = "k1", text = "v1", children = { { key = "k1.1", text = "v1.1" } } } 
                } 
            })
            assert.is_not_nil(tree)
            tree:SetData({ { text = "Node 1", value = 1 } })

            local stack = FenUI:CreateStack(UIParent, { direction = "vertical", gap = 10 })
            for i=1,5 do stack:AddChild(CreateFrame("Frame")) end
            assert.is_equal(5, #stack.children)

            local grid = FenUI:CreateGrid(UIParent, { columns = { "1fr", "1fr" } })
            grid:SetData({ { a = 1 }, { a = 2 } })
            assert.is_equal(2, #grid.rows)
        end)
    end)

    describe("Validation", function()
        it("should run validation", function()
            local res = FenUI.Validation:Run(false)
            assert.is_not_nil(res)
        end)
    end)
end)
