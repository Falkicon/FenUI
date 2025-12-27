-- luacheck: globals describe it before_each after_each setup teardown assert spy stub mock pending FenUI CreateFrame UIParent
describe("FenUI ThemePicker", function()
    setup(function()
        require("Core.FenUI")
        require("Core.Tokens")
        require("Core.ThemeManager")
        require("Settings.ThemePicker")
        _G.FenUIDB = { globalTheme = "Default" }
    end)

    describe("AceConfig Integration", function()
        it("should create a theme selection option", function()
            local option = FenUI:CreateThemeOption()
            assert.is_table(option)
            assert.is_equal(option.type, "select")
            assert.is_function(option.values)
            
            local values = option.values()
            assert.is_not_nil(values.Default)
        end)

        it("should create a settings group", function()
            local group = FenUI:CreateSettingsGroup()
            assert.is_table(group)
            assert.is_table(group.args)
            assert.is_table(group.args.theme)
            assert.is_table(group.args.debugMode)
        end)
    end)

    describe("ThemePicker Widget", function()
        it("should create a standalone theme picker", function()
            local picker = FenUI:CreateThemePicker(UIParent)
            assert.is_not_nil(picker)
            assert.is_not_nil(picker.buttons)
            assert.is_not_nil(picker.buttons.Default)
        end)

        it("should handle theme selection", function()
            local changed = false
            local savedVars = { theme = "Default" }
            local picker = FenUI:CreateThemePicker(UIParent, savedVars, "theme", function(name) changed = name end)
            
            -- Register a mock theme to select
            FenUI.ThemeManager:Register("Dark", { name = "Dark Theme" })
            
            picker:SelectTheme("Dark")
            assert.is_equal(savedVars.theme, "Dark")
            assert.is_equal(changed, "Dark")
            assert.is_equal(FenUI:GetGlobalTheme(), "Dark")
        end)

        it("should update button visual states on select", function()
            local picker = FenUI:CreateThemePicker(UIParent)
            local btn = picker.buttons.Default
            
            picker:SelectTheme("Default")
            assert.is_true(btn.isSelected)
        end)
    end)
end)

