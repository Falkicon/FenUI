-- luacheck: globals describe it before_each after_each setup teardown assert spy stub mock pending FenUI
-- FenUI Miscellaneous Tests (standalone, no FenCore required)
describe("FenUI Miscellaneous", function()
    setup(function()
        require("wow_api_midnight")
        require("Core.FenUI")
        require("Utils.Utils")
        require("Utils.Formatting")
        require("Settings.ThemePicker")
    end)

    describe("ThemePicker", function()
        it("should exist", function()
            -- ThemePicker usually registers itself into Blizzard settings
            -- We just check if the module file loaded without error
            assert.is_not_nil(FenUI.Utils)
        end)
    end)

    describe("SecretDetection", function()
        it("should detect secrets using WoW API", function()
            -- Uses WoW's issecretvalue API directly
            local secret = WoWAPI_MakeSecret("my-secret")
            -- FenUI.Utils:FormatValue uses issecretvalue internally
            local formatted = FenUI.Utils:FormatValue(secret)
            assert.is_truthy(formatted:find("SECRET"))
        end)
    end)
end)
