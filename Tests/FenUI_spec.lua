-- luacheck: globals describe it before_each after_each setup teardown assert spy stub mock pending FenUI
-- Basic FenUI tests (standalone, no FenCore required)
describe("FenUI", function()
    setup(function()
        require("Core.FenUI")
        FenUI.Utils = FenUI.Utils or {}
    end)

    it("should define the FenUI namespace", function()
        assert.is_not_nil(FenUI)
    end)

    it("should have a version", function()
        assert.is_not_nil(FenUI.VERSION)
    end)

    it("should load tokens", function()
        require("Core.Tokens")
        assert.is_not_nil(FenUI.Tokens)
    end)

    describe("Utils", function()
        it("should colorize text", function()
            require("Utils.Colors")
            local result = FenUI.Utils:Colorize("test", "ff00ff00")
            assert.is_equal("|cff00ff00test|r", result)
        end)
    end)
end)
