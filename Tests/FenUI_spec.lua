-- luacheck: globals describe it before_each after_each setup teardown assert spy stub mock pending FenUI
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

        it("should deep copy tables", function()
            require("Utils.Tables")
            local orig = { a = 1 }
            local copy = FenUI.Utils:DeepCopy(orig)
            assert.is_not_nil(copy)
            assert.is_equal(orig.a, copy.a)
        end)

        it("should wipe tables", function()
            require("Utils.Tables")
            local t = { a = 1 }
            FenUI.Utils:Wipe(t)
            assert.is_nil(t.a)
        end)
    end)
end)

