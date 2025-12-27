-- luacheck: globals describe it before_each after_each setup teardown assert spy stub mock pending FenUI
describe("FenUI Core", function()
    setup(function()
        require("Core.FenUI")
        require("Core.Tokens")
        require("Core.ThemeManager")
        require("Core.BlizzardBridge")
    end)

    describe("ThemeManager", function()
        it("should have a Default theme", function()
            assert.is_not_nil(FenUI.Themes.Default)
            assert.is_equal("Default", FenUI.Themes.Default.name)
        end)

        it("should register a new theme", function()
            local config = {
                name = "Test Theme",
                description = "A test theme",
                tokens = { surfacePanel = "black" }
            }
            FenUI.ThemeManager:Register("Test", config)
            
            local theme = FenUI.ThemeManager:Get("Test")
            assert.is_not_nil(theme)
            assert.is_equal("Test Theme", theme.name)
            assert.is_equal("black", theme.tokens.surfacePanel)
        end)

        it("should unregister a theme", function()
            FenUI.ThemeManager:Unregister("Test")
            assert.is_nil(FenUI.ThemeManager:Get("Test"))
        end)

        it("should not unregister the Default theme", function()
            FenUI.ThemeManager:Unregister("Default")
            assert.is_not_nil(FenUI.ThemeManager:Get("Default"))
        end)

        it("should check if a theme exists", function()
            assert.is_true(FenUI.ThemeManager:Exists("Default"))
            assert.is_false(FenUI.ThemeManager:Exists("NonExistent"))
        end)

        it("should get a list of theme names", function()
            local list = FenUI.ThemeManager:GetList()
            assert.is_true(#list >= 1)
            local found = false
            for _, name in ipairs(list) do
                if name == "Default" then found = true end
            end
            assert.is_true(found)
        end)

        it("should get theme info", function()
            local info = FenUI.ThemeManager:GetThemeInfo()
            assert.is_not_nil(info.Default)
            assert.is_equal("Default", info.Default.name)
        end)
    end)

    describe("Tokens", function()
        it("should resolve semantic tokens", function()
            assert.is_not_nil(FenUI.Tokens)
            local r, g, b, a = FenUI:GetColor("surfacePanel")
            assert.is_not_nil(r)
            assert.is_not_nil(a)
        end)

        it("should apply token overrides", function()
            local original_r, original_g, original_b = FenUI:GetColor("surfacePanel")
            
            FenUI:ApplyTokenOverrides({ surfacePanel = "white" })
            local r, g, b = FenUI:GetColor("surfacePanel")
            assert.is_equal(1, r)
            assert.is_equal(1, g)
            assert.is_equal(1, b)
            
            FenUI:ClearTokenOverrides()
            local reset_r = FenUI:GetColor("surfacePanel")
            assert.is_equal(original_r, reset_r)
        end)

        it("should get color as table", function()
            local color = FenUI:GetColorTable("surfacePanel")
            assert.is_equal("table", type(color))
            assert.is_equal(4, #color)
        end)

        it("should get color as RGB (no alpha)", function()
            local r, g, b, a = FenUI:GetColorRGB("surfacePanel")
            assert.is_not_nil(r)
            assert.is_not_nil(g)
            assert.is_not_nil(b)
            assert.is_nil(a)
        end)

        it("should get color hex", function()
            FenUI:ApplyTokenOverrides({ surfacePanel = "white" })
            local hex = FenUI:GetColorHex("surfacePanel")
            assert.is_equal("ffffff", hex)
            FenUI:ClearTokenOverrides()
        end)

        it("should get spacing", function()
            local spacing = FenUI:GetSpacing("spacingPanel")
            assert.is_true(spacing > 0)
        end)

        it("should get layout constants", function()
            local padding = FenUI:GetLayout("panelPadding")
            assert.is_equal(24, padding)
        end)

        it("should get font object names", function()
            local font = FenUI:GetFont("fontHeading")
            assert.is_equal("GameFontNormalLarge", font)
        end)

        it("should get tokens by prefix", function()
            local tokens = FenUI:GetTokensByPrefix("surface")
            assert.is_not_nil(tokens.surfacePanel)
            assert.is_nil(tokens.textHeading)
        end)
    end)

    describe("BlizzardBridge", function()
        it("should check if layout exists", function()
            _G.NineSliceLayouts = { GenericMetal = {} }
            assert.is_true(FenUI:LayoutExists("Modern"))
            assert.is_false(FenUI:LayoutExists("NonExistent"))
        end)

        it("should resolve layout names", function()
            assert.is_equal(FenUI:ResolveLayoutName("Modern"), "GenericMetal")
            assert.is_equal(FenUI:ResolveLayoutName("DirectName"), "DirectName")
        end)

        it("should get available layouts", function()
            local layouts = FenUI:GetAvailableLayouts(false)
            assert.is_table(layouts)
            assert.is_true(#layouts > 0)
        end)

        it("should apply layout direct", function()
            _G.NineSliceUtil = { ApplyLayout = function() end }
            _G.NineSliceLayouts = { MyLayout = {} }
            local frame = CreateFrame("Frame")
            assert.is_true(FenUI:ApplyLayoutDirect(frame, "MyLayout"))
            assert.is_equal(frame.fenUILayout, "MyLayout")
        end)
    end)

    describe("FenUI Base", function()
        it("should handle theme changed callbacks", function()
            local called = false
            local id = FenUI:OnThemeChanged(function() called = true end)
            FenUI:SetGlobalTheme("Default")
            assert.is_true(called)
            
            -- Test pcall in FireThemeChangeCallbacks
            local id2 = FenUI:OnThemeChanged(function() error("fail") end)
            FenUI:SetGlobalTheme("test-error")
            -- Should not crash
            
            FenUI:RemoveThemeChangedCallback(id)
            FenUI:RemoveThemeChangedCallback(id2)
        end)

        it("should handle placeholder theme functions", function()
            local old_Themes = FenUI.Themes
            FenUI.Themes = nil
            
            local ok, err = pcall(function()
                local list = FenUI:GetThemeList()
                assert.is_table(list)
                assert.is_equal("Default", list[1])
            end)
            
            FenUI.Themes = old_Themes
            if not ok then error(err) end

            -- Test fallback SetGlobalTheme without a full ThemeManager
            -- Since ThemeManager.lua was required, FenUI:SetGlobalTheme was overriden.
            -- We just call it and ensure it handles missing themes gracefully (prints error)
            FenUI:SetGlobalTheme("non-existent-theme")
            assert.is_equal(FenUI:GetGlobalTheme(), "Default")
        end)

        it("should handle slash commands", function()
            -- Register a theme for testing
            FenUI.ThemeManager:Register("dark", { name = "Dark" })
            _G.FenUIDB = { debugMode = false }
            
            -- Test various commands through the global function
            local handler = SlashCmdList["FENUI"]
            assert.is_function(handler)
            
            handler("version")
            handler("themes")
            handler("debug")
            assert.is_true(FenUI.debugMode)
            handler("debug")
            assert.is_false(FenUI.debugMode)
            
            handler("tokens")
            handler("frames")
            
            -- Test validation command
            handler("validate")
            handler("validate verbose")
            
            -- Test theme command variants
            handler("theme")
            handler("theme dark")
            assert.is_equal(FenUI:GetGlobalTheme(), "dark")
            
            handler("invalid")
        end)

        it("should handle frame registration", function()
            local frame = CreateFrame("Frame")
            local frameId = FenUI:RegisterFrame(frame, "panel")
            assert.is_not_nil(frameId)
            assert.is_equal(frame.fenUIFrameId, frameId)
            
            local frames = FenUI:GetRegisteredFrames()
            assert.is_not_nil(frames[frameId])
            assert.is_equal(frames[frameId].frame, frame)
            assert.is_equal(frames[frameId].frameType, "panel")
            
            -- Test frameId lookup
            FenUI:UnregisterFrame(frameId)
            assert.is_nil(frames[frameId])
            
            -- Test frame object lookup
            local frame2 = CreateFrame("Frame")
            local id2 = FenUI:RegisterFrame(frame2)
            assert.is_equal(frames[id2].frameType, "unknown")
            FenUI:UnregisterFrame(frame2)
            assert.is_nil(frames[id2])
        end)

        it("should support Mixin and CreateFromMixins", function()
            local target = {}
            local source = { testMethod = function() return "ok" end }
            FenUI.Mixin(target, source)
            assert.is_equal(target.testMethod(), "ok")
            
            local combined = FenUI.CreateFromMixins(source, { prop = 123 })
            assert.is_equal(combined.testMethod(), "ok")
            assert.is_equal(combined.prop, 123)
        end)

        it("should provide SafeCall", function()
            local success, res = FenUI.SafeCall(function(a) return a end, "test")
            assert.is_true(success)
            assert.is_equal(res, "test")
            
            local success2 = FenUI.SafeCall(function() error("fail") end)
            assert.is_false(success2)
        end)
    end)
end)

