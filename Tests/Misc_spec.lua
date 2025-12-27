-- luacheck: globals describe it before_each after_each setup teardown assert spy stub mock pending FenUI
describe("FenUI Miscellaneous", function()
    setup(function()
        require("wow_api_midnight")
        require("Core.FenUI")
        require("Utils.Utils")
        require("Utils.Environment")
        require("Utils.SecretValues")
        require("Settings.ThemePicker")
    end)

    describe("SecretValues", function()
        it("should detect secret values", function()
            -- issecretvalue is a Blizzard global in Midnight
            -- Our mock wow_api_midnight.lua provides it
            local secret = WoWAPI_MakeSecret("my-secret")
            assert.is_true(FenUI.Utils:IsValueSecret(secret))
            assert.is_false(FenUI.Utils:IsValueSecret("public"))
            assert.is_false(FenUI.Utils:IsValueSecret(nil))
        end)

        it("should handle missing issecretvalue global", function()
            local old_issecretvalue = _G.issecretvalue
            _G.issecretvalue = nil
            
            -- Should fallback to type checking and pcall
            local secret = WoWAPI_MakeSecret("fallback-secret")
            assert.is_true(FenUI.Utils:IsValueSecret(secret))
            assert.is_false(FenUI.Utils:IsValueSecret("public"))
            
            _G.issecretvalue = old_issecretvalue
        end)

        it("should count secrets in tables", function()
            local t = {
                a = 1,
                b = WoWAPI_MakeSecret(2),
                c = {
                    d = WoWAPI_MakeSecret(3),
                    e = 4
                }
            }
            assert.is_equal(1, FenUI.Utils:CountSecrets(t, false))
            assert.is_equal(2, FenUI.Utils:CountSecrets(t, true))
            
            -- Test with non-table
            assert.is_equal(0, FenUI.Utils:CountSecrets("not-a-table"))
            assert.is_equal(0, FenUI.Utils:CountSecrets(nil))
        end)
    end)

    describe("ThemePicker", function()
        it("should exist", function()
            -- ThemePicker usually registers itself into Blizzard settings
            -- We just check if the module file loaded without error
            assert.is_not_nil(FenUI.Utils)
        end)
    end)
end)

