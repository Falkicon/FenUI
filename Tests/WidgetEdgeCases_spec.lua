-- luacheck: globals describe it before_each after_each setup teardown assert spy stub mock pending FenUI CreateFrame UIParent
describe("FenUI Widget Edge Cases", function()
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
        require("Widgets.Containers")
        require("Widgets.ScrollBar")
        require("Widgets.MultiLineEditBox")
        require("Widgets.ImageButton")
        require("Widgets.Image")
    end)

    describe("BlizzardBridge", function()
        it("should apply layouts with overrides", function()
            local frame = CreateFrame("Frame")
            FenUI:ApplyLayoutDirect(frame, "SimplePanelTemplate", {
                title = "Overridden"
            })
            -- Just check it doesn't crash
        end)

        it("should handle missing layouts gracefully", function()
            local frame = CreateFrame("Frame")
            FenUI:ApplyLayoutDirect(frame, "NonExistentLayout")
            -- Should not crash
        end)
    end)

    describe("MultiLineEditBox Focus", function()
        it("should handle focus gains and losses", function()
            local ml = FenUI:CreateMultiLineEditBox(UIParent)
            local eb = ml.editBox
            
            eb:SetFocus()
            assert.is_true(eb:HasFocus())
            
            eb:ClearFocus()
            assert.is_false(eb:HasFocus())
        end)

        it("should handle key down in ReadOnly mode", function()
            local ml = FenUI:CreateMultiLineEditBox(UIParent, { readOnly = true })
            local eb = ml.editBox
            local script = eb:GetScript("OnKeyDown")
            if script then 
                -- Test that it doesn't crash with various keys
                script(eb, "ESCAPE")
                script(eb, "C", true) -- Ctrl+C (copy)
            end
        end)
    end)

    describe("ImageButton States", function()
        it("should handle disabled state", function()
            local btn = FenUI:CreateImageButton(UIParent, { texture = "test" })
            btn:SetEnabled(false)
            assert.is_false(btn:IsEnabled())
            
            local script = btn:GetScript("OnEnter")
            if script then script(btn) end
            -- Visuals should update
            
            btn:SetEnabled(true)
            assert.is_true(btn:IsEnabled())
        end)

        it("should handle hover and press visuals", function()
            local btn = FenUI:CreateImageButton(UIParent, { texture = "test" })
            
            local enter = btn:GetScript("OnEnter")
            if enter then enter(btn) end
            
            local down = btn:GetScript("OnMouseDown")
            if down then down(btn, "LeftButton") end
            assert.is_true(btn.isPressed)
            
            local up = btn:GetScript("OnMouseUp")
            if up then up(btn, "LeftButton") end
            assert.is_false(btn.isPressed)
            
            local leave = btn:GetScript("OnLeave")
            if leave then leave(btn) end
        end)
    end)
end)
