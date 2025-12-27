-- luacheck: globals describe it before_each after_each setup teardown assert spy stub mock pending FenUI
describe("FenUI Validation & Fonts", function()
    setup(function()
        require("Core.FenUI")
        require("Core.Tokens")
        require("Core.Fonts")
        require("Validation.DependencyChecker")
    end)

    describe("Fonts", function()
        it("should initialize fonts", function()
            -- Fonts are initialized when the file is required
            assert.is_not_nil(FenUI.Tokens.fonts.mono)
        end)
    end)

    describe("DependencyChecker", function()
        it("should run validation", function()
            local results = FenUI.Validation:Run(false)
            assert.is_not_nil(results)
            assert.is_not_nil(results.apis)
        end)

        it("should run verbose validation", function()
            local results = FenUI.Validation:Run(true)
            assert.is_not_nil(results)
        end)

        it("should print report", function()
            local results = FenUI.Validation:Run(false)
            FenUI.Validation:PrintReport(results)
            -- Should not crash
        end)

        it("should handle failed validation in report", function()
            local results = {
                valid = false,
                timestamp = "2025-12-27 12:00:00",
                gameVersion = "12.0.0",
                apis = { passed = 0, failed = 1, missing = { { name = "MissingAPI", reason = "Not found" } } },
                layouts = { passed = 0, failed = 1, missing = { { name = "MissingLayout", reason = "Not found" } } },
                atlases = { passed = 0, failed = 1, missing = { { name = "MissingAtlas", reason = "Not found" } } },
            }
            FenUI.Validation:PrintReport(results)
            -- Should not crash
        end)

        it("should handle OnLoad", function()
            FenUI.Validation:OnLoad(true)
            FenUI.Validation:OnLoad(false)
        end)
    end)
end)

