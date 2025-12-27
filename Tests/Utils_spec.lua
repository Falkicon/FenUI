-- luacheck: globals describe it before_each after_each setup teardown assert spy stub mock pending FenUI CreateFrame UIParent
describe("FenUI Utils", function()
    setup(function()
        require("Core.FenUI")
        require("Utils.Utils")
        require("Utils.Environment")
        require("Utils.Formatting")
        require("Utils.Colors")
        require("Utils.Tables")
        require("Utils.UI")
        require("Utils.SafeAPI")
        require("Utils.SecretValues")
    end)

    describe("Environment", function()
        it("should detect client type", function()
            local clientType = FenUI.Utils:GetClientType()
            assert.is_string(clientType)
        end)

        it("should return version strings", function()
            assert.is_string(FenUI.Utils:GetVersionString())
            assert.is_string(FenUI.Utils:GetInterfaceString())
        end)

        it("should map timer fonts", function()
            assert.is_equal("GameFontHighlightSmallOutline", FenUI.Utils:GetTimerFont("small"))
            assert.is_equal("GameFontHighlightHugeOutline", FenUI.Utils:GetTimerFont(20))
        end)

        it("should detect capabilities", function()
            FenUI.Utils:DetectCapabilities()
            assert.is_not_nil(FenUI.Utils.Cap)
        end)
    end)

    describe("Formatting", function()
        it("should format memory", function()
            assert.is_equal("1.4 MB", FenUI.Utils:FormatMemory(1464.8))
            assert.is_equal("500 KB", FenUI.Utils:FormatMemory(500))
        end)

        it("should format duration", function()
            assert.is_string(FenUI.Utils:FormatDuration(65))
            assert.is_string(FenUI.Utils:FormatDuration(3665))
        end)

        it("should sanitize text", function()
            assert.is_equal("Hello", FenUI.Utils:SanitizeText("Hello"))
            assert.is_equal("Fallback", FenUI.Utils:SanitizeText(nil, "Fallback"))
        end)

        it("should strip color codes", function()
            assert.is_equal("Plain Text", FenUI.Utils:StripColorCodes("|cffff0000Plain Text|r"))
        end)

        it("should truncate text", function()
            assert.is_equal("Hello...", FenUI.Utils:TruncateText("Hello World", 5))
            assert.is_equal("Short", FenUI.Utils:TruncateText("Short", 10))
        end)

        it("should format complex values", function()
            assert.is_equal("123", FenUI.Utils:FormatValue(123))
            assert.is_equal("true", FenUI.Utils:FormatValue(true))
            assert.is_equal("{...}", FenUI.Utils:FormatValue({}))
            
            local t = { a = 1, b = { c = 2 } }
            local fmt = FenUI.Utils:FormatValue(t, { plain = true })
            assert.is_true(string.find(fmt, "a = 1") ~= nil)
            assert.is_true(string.find(fmt, "c = 2") ~= nil)
            
            -- Test depth limit
            local fmtDepth = FenUI.Utils:FormatValue(t, { maxDepth = 1, plain = true })
            assert.is_true(string.find(fmtDepth, "{...}") ~= nil)
        end)
    end)

    describe("Tables", function()
        it("should deep copy tables", function()
            local t1 = { a = 1, b = { c = 2 } }
            local t2 = FenUI.Utils:DeepCopy(t1)
            assert.is_not_equal(t1, t2)
            assert.is_not_equal(t1.b, t2.b)
            assert.is_equal(t1.b.c, t2.b.c)
        end)

        it("should deep copy with metatables", function()
            local mt = { __index = { foo = "bar" } }
            local t1 = setmetatable({ a = 1 }, mt)
            local t2 = FenUI.Utils:DeepCopy(t1)
            assert.is_equal(getmetatable(t2).__index.foo, "bar")
        end)

        it("should safe compare values", function()
            assert.is_true(FenUI.Utils:SafeCompare(1, 1))
            assert.is_true(FenUI.Utils:SafeCompare({ a = 1 }, { a = 1 }))
            assert.is_false(FenUI.Utils:SafeCompare(1, 2))
            assert.is_false(FenUI.Utils:SafeCompare({ a = 1 }, { a = 2 }))
            assert.is_true(FenUI.Utils:SafeCompare(nil, nil))
            assert.is_false(FenUI.Utils:SafeCompare(1, nil))
        end)

        it("should handle secrets in safe compare", function()
            local s1 = WoWAPI_MakeSecret("pass")
            local s2 = WoWAPI_MakeSecret("fail")
            
            -- Equality with same object
            assert.is_true(FenUI.Utils:SafeCompare(s1, s1))
            -- Inequality with different object (even if same underlying value in some mocks)
            assert.is_false(FenUI.Utils:SafeCompare(s1, s2))
            
            -- Test inequality operators
            assert.is_false(FenUI.Utils:SafeCompare(s1, s1, "~="))
            assert.is_true(FenUI.Utils:SafeCompare(s1, s2, "~="))
            
            -- Test unsupported operators for secrets
            assert.is_nil(FenUI.Utils:SafeCompare(s1, s2, ">"))
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
        end)

        it("should wipe tables", function()
            local t = { a = 1, b = 2 }
            FenUI.Utils:Wipe(t)
            assert.is_nil(t.a)
            assert.is_nil(next(t))
        end)
    end)

    before_each(function()
        WoWAPI_ClearSecrets()
        WoWAPI_SetTime(30)
    end)

    describe("SafeAPI", function()
        it("should call functions safely", function()
            local called = false
            local success, results = FenUI.Utils:SafeCall(function() called = true; return "ok" end)
            assert.is_true(success)
            assert.is_true(called)
            assert.is_equal("ok", results[1])
        end)

        it("should handle errors in safe call", function()
            local success, results = FenUI.Utils:SafeCall(function() error("test") end)
            assert.is_false(success)
        end)

        it("should get spell cooldown safely", function()
            local info = FenUI.Utils:GetSpellCooldownSafe(123)
            assert.is_not_nil(info)
            assert.is_true(info.isEnabled)
            
            -- Test cache
            local info2 = FenUI.Utils:GetSpellCooldownSafe(123)
            assert.is_equal(info, info2)
            
            -- Test invalid input
            assert.is_nil(FenUI.Utils:GetSpellCooldownSafe(nil))
        end)

        it("should get unit health safely", function()
            local percent, isRoyal = FenUI.Utils:GetUnitHealthSafe("player")
            assert.is_number(percent)
            
            -- Test invalid unit
            _G.UnitHealth = function() return 0 end
            _G.UnitHealthMax = function() return 0 end
            local p, ir = FenUI.Utils:GetUnitHealthSafe("none")
            assert.is_nil(p)
        end)

        it("should handle unit health percent (Midnight)", function()
            -- Mock UnitHealthPercent
            _G.UnitHealthPercent = function(u) return 75 end
            _G.CurveConstants = { ScaleTo100 = 1 }
            local percent, isRoyal = FenUI.Utils:GetUnitHealthSafe("player")
            assert.is_equal(75, percent)
            assert.is_true(isRoyal)
            _G.UnitHealthPercent = nil
        end)

        it("should get action texture safely", function()
            local old_tex = _G.C_ActionBar.GetActionTexture
            local texture = FenUI.Utils:GetActionTextureSafe(1)
            assert.is_string(texture)
            
            -- Test table return
            _G.C_ActionBar.GetActionTexture = function() return { icon = "test_icon" } end
            local old_midnight = FenUI.Utils.IS_MIDNIGHT
            FenUI.Utils.IS_MIDNIGHT = true
            assert.is_equal("test_icon", FenUI.Utils:GetActionTextureSafe(1))
            FenUI.Utils.IS_MIDNIGHT = old_midnight
            _G.C_ActionBar.GetActionTexture = old_tex
        end)

        it("should get action cooldown safely", function()
            local start, duration, enabled = FenUI.Utils:GetActionCooldownSafe(1)
            assert.is_number(start)
            assert.is_boolean(enabled)
        end)

        it("should check if action is usable safely", function()
            local usable, noMana = FenUI.Utils:IsUsableActionSafe(1)
            assert.is_true(usable)
            assert.is_false(noMana)

            usable, noMana = FenUI.Utils:IsUsableActionSafe(999)
            assert.is_true(usable)
            assert.is_false(noMana)
        end)

        it("should get action display count safely", function()
            local count = FenUI.Utils:GetActionDisplayCountSafe(1)
            assert.is_equal(5, count)
            
            assert.is_equal(10, FenUI.Utils:GetActionDisplayCountSafe(999))
        end)

        it("should handle action texture safely (with ID)", function()
            local old_tex = _G.C_ActionBar.GetActionTexture
            assert.is_equal("Interface\\Icons\\Spell_Nature_HealingTouch", FenUI.Utils:GetActionTextureSafe(1))
            
            _G.C_ActionBar.GetActionTexture = function(id) if id == 999 then return "Interface\\Icons\\Inv_Misc_QuestionMark" end end
            assert.is_equal("Interface\\Icons\\Inv_Misc_QuestionMark", FenUI.Utils:GetActionTextureSafe(999))
            
            _G.C_ActionBar.GetActionTexture = old_tex
        end)

        it("should handle IsActionInRange safely", function()
            assert.is_true(FenUI.Utils:IsActionInRangeSafe(1))
            assert.is_true(FenUI.Utils:IsActionInRangeSafe(999))
        end)

        it("should get specialization safely", function()
            _G.C_SpecializationInfo = { GetSpecialization = function() return 1 end }
            local spec = FenUI.Utils:GetSpecializationSafe()
            assert.is_equal(1, spec)
        end)

        it("should get item spell safely", function()
            local name, spellID = FenUI.Utils:GetItemSpellSafe(123)
            assert.is_equal("Test Spell", name)
            
            name, spellID = FenUI.Utils:GetItemSpellSafe("table")
            assert.is_equal("Table Spell", name)
            assert.is_equal(999, spellID)
        end)

        it("should get inventory item cooldown safely", function()
            local start, duration, enabled = FenUI.Utils:GetInventoryItemCooldownSafe("player", 1)
            assert.is_true(enabled)
            assert.is_equal(30, duration)

            start, duration, enabled = FenUI.Utils:GetInventoryItemCooldownSafe("player", 99)
            assert.is_true(enabled)
            assert.is_equal(60, duration)
        end)

        it("should check if spell is overlayed safely", function()
            _G.C_SpellActivationOverlay = { IsSpellOverlayed = function() return true end }
            assert.is_true(FenUI.Utils:IsSpellOverlayedSafe(123))
            
            -- Test cache
            assert.is_true(FenUI.Utils:IsSpellOverlayedSafe(123))
        end)

        it("should get aura duration safely", function()
            local duration = FenUI.Utils:GetDurationSafe("player", 123)
            assert.is_equal(10, duration)
            
            -- Test legacy aura
            FenUI.Utils.Cap.IsAuraLegacy = true
            _G.C_UnitAuras.GetAuraDurationRemaining = function() return 5 end
            assert.is_equal(5, FenUI.Utils:GetDurationSafe("player", 123))
            FenUI.Utils.Cap.IsAuraLegacy = false
        end)

        it("should handle SetCooldown safely", function()
            local cd = CreateFrame("Frame")
            cd.SetCooldown = function(self, s, d) self.s = s; self.d = d end
            
            -- Normal
            FenUI.Utils:SetCooldownSafe(cd, 123, 456)
            assert.is_equal(123, cd.s)
            assert.is_equal(456, cd.d)

            -- Duration only (implementation sets start to 0)
            FenUI.Utils:SetCooldownSafe(cd, 789)
            assert.is_equal(0, cd.s)
            assert.is_equal(789, cd.d)
            
            -- Royal
            FenUI.Utils.Cap.IsRoyal = true
            cd.SetCooldownFromDurationObject = function(self, obj) self.obj = obj end
            local durObj = { GetDuration = function() return 10 end }
            FenUI.Utils:SetCooldownSafe(cd, durObj)
            assert.is_equal(durObj, cd.obj)
            FenUI.Utils.Cap.IsRoyal = false
        end)

        it("should handle GetActionBarPage safely", function()
            local page = FenUI.Utils:GetActionBarPageSafe()
            assert.is_number(page)
        end)

        it("should handle IsActionInRange safely", function()
            local inRange = FenUI.Utils:IsActionInRangeSafe(1)
            assert.is_not_nil(inRange)
        end)

        it("should handle GetSpellCharges safely", function()
            local charges = FenUI.Utils:GetSpellChargesSafe(123)
            -- Mock in wow_api_c_spell.lua returns a table
            assert.is_table(charges)
            assert.is_equal(3, charges.maxCharges)
        end)

        it("should handle texture cache invalidation", function()
            FenUI.Utils:InvalidateTextureCache()
            -- Just check it doesn't crash
        end)

        it("should get spell texture safely", function()
            local texture = FenUI.Utils:GetSpellTextureSafe(123)
            assert.is_equal("Interface\\Icons\\Spell_Nature_HealingTouch", texture)
            
            -- Test cache
            assert.is_equal("Interface\\Icons\\Spell_Nature_HealingTouch", FenUI.Utils:GetSpellTextureSafe(123))
        end)

        it("should handle Midnight C_ActionBar paths", function()
            FenUI.Utils.IS_MIDNIGHT = true
            
            -- Action Cooldown
            local start, duration = FenUI.Utils:GetActionCooldownSafe(999)
            assert.is_number(start)
            assert.is_equal(30, duration)
            
            -- Action Count
            local count = FenUI.Utils:GetActionDisplayCountSafe(999)
            assert.is_equal(10, count)
            
            -- Action Texture
            local tex = FenUI.Utils:GetActionTextureSafe(999)
            assert.is_equal("Interface\\Icons\\Action_999", tex)
            
            -- Action Range
            local inRange = FenUI.Utils:IsActionInRangeSafe(999)
            assert.is_true(inRange)
            
            FenUI.Utils.IS_MIDNIGHT = false
        end)

        it("should handle SetTimerSafe", function()
            local bar = { SetTimerDuration = function() return true end }
            local ok = FenUI.Utils:SetTimerSafe(bar, {}, 1, 1)
            assert.is_true(ok)
            
            assert.is_false(FenUI.Utils:SetTimerSafe(nil, {}))
            assert.is_false(FenUI.Utils:SetTimerSafe({}, nil))
        end)
    end)

    describe("UI", function()
        it("should parse sizes", function()
            assert.is_equal(100, FenUI.Utils:ParseSize(100))
            assert.is_equal(100, FenUI.Utils:ParseSize("50%", 200))
            assert.is_equal(100, FenUI.Utils:ParseSize("100px"))
            assert.is_equal(108, FenUI.Utils:ParseSize("10vh", nil, true)) -- UIParent height is 1080
            assert.is_equal(192, FenUI.Utils:ParseSize("10vw", nil, false)) -- UIParent width is 1920
            assert.is_equal(-1, FenUI.Utils:ParseSize("auto"))
        end)

        it("should parse aspect ratios", function()
            assert.is_equal(1.5, FenUI.Utils:ParseAspectRatio(1.5))
            assert.is_equal(16/9, FenUI.Utils:ParseAspectRatio("16:9"))
            assert.is_equal(4/3, FenUI.Utils:ParseAspectRatio("4/3"))
            assert.is_nil(FenUI.Utils:ParseAspectRatio("invalid"))
        end)

        it("should handle HideSafe", function()
            local frame = CreateFrame("Frame")
            FenUI.Utils:HideSafe(frame)
            assert.is_equal(0, frame:GetAlpha())
        end)

        it("should apply icon crop", function()
            local tex = CreateFrame("Frame"):CreateTexture()
            tex.SetTexCoord = function(self, ...) self.coords = {...} end
            
            FenUI.Utils:ApplyIconCrop(tex, 100, 50) -- Wide
            assert.is_not_nil(tex.coords)
            
            FenUI.Utils:ApplyIconCrop(tex, 50, 100) -- Tall
            assert.is_not_nil(tex.coords)
            
            FenUI.Utils:ApplyIconCrop(tex, 100, 100) -- Square
            assert.is_not_nil(tex.coords)
        end)

        it("should handle HideTexture", function()
            local tex = CreateFrame("Frame"):CreateTexture()
            FenUI.Utils:HideTexture(tex)
            assert.is_equal(0, tex:GetAlpha())
            assert.is_nil(tex:GetTexture())
        end)

        it("should handle GetMouseFocus", function()
            local focus = FenUI.Utils:GetMouseFocus()
            assert.is_not_nil(focus)
            
            -- Test legacy global
            local old_C_UI = _G.C_UI
            _G.C_UI = nil
            local old_GetMouseFocus = _G.GetMouseFocus
            _G.GetMouseFocus = function() return { name = "GlobalFocus" } end
            focus = FenUI.Utils:GetMouseFocus()
            assert.is_equal("GlobalFocus", focus.name)
            
            _G.C_UI = old_C_UI
            _G.GetMouseFocus = old_GetMouseFocus
        end)

        it("should handle StripBlizzardDecorations", function()
            local frame = CreateFrame("Frame")
            local tex = frame:CreateTexture(nil, "ARTWORK")
            tex.GetDebugName = function() return "MyBorder" end
            tex:Show()
            
            FenUI.Utils:StripBlizzardDecorations(frame)
            -- Mock GetRegions returns nothing by default
        end)

        it("should handle ShowMenu with EasyMenu", function()
            local menu = { { text = "Test", func = function() end } }
            local old_MenuUtil = _G.MenuUtil
            _G.MenuUtil = nil
            local called = false
            _G.EasyMenu = function() called = true end
            
            FenUI.Utils:ShowMenu(menu)
            assert.is_true(called)
            
            _G.MenuUtil = old_MenuUtil
            _G.EasyMenu = nil
        end)

        it("should handle dynamic sizing and constraints", function()
            local frame = CreateFrame("Frame")
            frame:SetParent(UIParent)
            FenUI.Utils:ApplySize(frame, "50%", "50%", { minWidth = 100, maxWidth = 200 })
            
            -- UIParent is 1920x1080. 50% is 960x540.
            -- Width 960 is constrained by maxWidth 200 -> 200.
            assert.is_equal(200, frame:GetWidth())
            assert.is_equal(540, frame:GetHeight())
        end)

        it("should handle parent resize hooks", function()
            local parent = CreateFrame("Frame")
            parent:SetSize(100, 100)
            local child = CreateFrame("Frame")
            child:SetParent(parent)
            local called = false
            child.UpdateDynamicSize = function() called = true end
            
            FenUI.Utils:HookParentResize(child, parent)
            -- Fire script manually
            local script = parent:GetScript("OnSizeChanged")
            if script then script(parent, 200, 200) end
            assert.is_true(called)
        end)

        it("should handle intrinsic size observation", function()
            local parent = CreateFrame("Frame")
            local child = CreateFrame("Frame")
            local called = false
            parent.UpdateDynamicSize = function() called = true end
            
            FenUI.Utils:ObserveIntrinsicSize(parent, child)
            -- Fire script manually
            local script = child:GetScript("OnSizeChanged")
            if script then script(child, 50, 50) end
            assert.is_true(called)
        end)

        it("should handle aspect ratio in dynamic sizing", function()
            local frame = CreateFrame("Frame")
            frame:SetParent(UIParent)
            FenUI.Utils:ApplySize(frame, 100, "auto", { aspectRatio = 2 })
            -- Width 100, Aspect 2 -> Height 50
            assert.is_equal(50, frame:GetHeight())
        end)

        it("should handle GetOrCreateWidget", function()
            local parent = {}
            local widget = FenUI.Utils:GetOrCreateWidget(parent, "myWidget", function() return { name = "new" } end)
            assert.is_equal("new", widget.name)
            local existing = FenUI.Utils:GetOrCreateWidget(parent, "myWidget", function() return { name = "other" } end)
            assert.is_equal("new", existing.name)
        end)
    end)
end)
