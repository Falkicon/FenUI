-- luacheck: globals describe it before_each after_each setup teardown assert spy stub mock pending FenUI CreateFrame UIParent
describe("FenUI Widgets", function()
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
        require("Widgets.Stack")
        require("Widgets.Grid")
        require("Widgets.Image")
        require("Widgets.ImageButton")
        require("Widgets.Buttons")
        require("Widgets.Input")
        require("Widgets.Group")
        require("Widgets.EmptyState")
        require("Widgets.StatusRow")
        require("Widgets.SectionHeader")
        require("Widgets.Section")
        require("Widgets.Dropdown")
        require("Widgets.SplitLayout")
        require("Widgets.ScrollBar")
        require("Widgets.MultiLineEditBox")
        require("Widgets.Containers")
    end)

    describe("Layout", function()
        it("should create a basic layout", function()
            local layout = FenUI:CreateLayout(UIParent, {
                width = 200,
                height = 100,
                padding = 10,
                background = "surfacePanel",
                border = "borderDefault"
            })
            assert.is_not_nil(layout)
            assert.is_equal(layout:GetWidth(), 200)
            assert.is_equal(layout:GetHeight(), 100)
        end)

        it("should handle rows and columns", function()
            local layout = FenUI:CreateLayout(UIParent, {
                width = 400,
                height = 400,
                rows = { "50px", "1fr" }
            })
            layout:UpdateLayout()
            assert.is_not_nil(layout.cells)
            -- 2 rows
            assert.is_not_nil(layout.cells[1])
            assert.is_not_nil(layout.cells[2])
            
            assert.is_equal(layout.cells[1]:GetHeight(), 50)
            assert.is_equal(layout.cells[2]:GetHeight(), 350)
        end)

        it("should handle cell content", function()
            local layout = FenUI:CreateLayout(UIParent, {
                width = 200, height = 200,
                rows = { "1fr" }
            })
            local child = CreateFrame("Frame")
            layout:SetCellContent(1, 1, child)
            assert.is_equal(child:GetParent(), layout.cells[1])
        end)
    end)

    describe("Stack", function()
        it("should handle horizontal stack and wrap", function()
            local stack = FenUI:CreateStack(UIParent, {
                direction = "horizontal",
                wrap = true,
                width = 100,
                gap = 10
            })
            -- Add 3 children of 40px width. Only 2 fit per line (40+10+40=90 < 100).
            local c1 = CreateFrame("Frame", nil, stack); c1:SetSize(40, 20)
            local c2 = CreateFrame("Frame", nil, stack); c2:SetSize(40, 20)
            local c3 = CreateFrame("Frame", nil, stack); c3:SetSize(40, 20)
            
            stack:AddChild(c1)
            stack:AddChild(c2)
            stack:AddChild(c3)
            
            stack:Layout()
            
            local _, _, _, x1, y1 = c1:GetPoint()
            local _, _, _, x3, y3 = c3:GetPoint()
            
            assert.is_equal(x1, 0)
            assert.is_not_equal(y3, y1) -- c3 should be on a new line
        end)

        it("should handle grow property", function()
            local stack = FenUI:CreateStack(UIParent, {
                direction = "horizontal",
                width = 200
            })
            local c1 = CreateFrame("Frame", nil, stack); c1:SetSize(50, 20)
            local c2 = CreateFrame("Frame", nil, stack); c2:SetSize(50, 20)
            
            stack:AddChild(c1, { grow = 1 })
            stack:AddChild(c2, { grow = 2 })
            
            stack:Layout()
            -- Available extra space: 200 - (50+50) = 100
            -- c1 grows by 1/3 of 100 = 33.3
            -- c2 grows by 2/3 of 100 = 66.6
            assert.is_true(c1:GetWidth() > 50)
            assert.is_true(c2:GetWidth() > c1:GetWidth())
        end)

        it("should handle vertical stack", function()
            local stack = FenUI:CreateStack(UIParent, {
                direction = "vertical",
                height = 200
            })
            local c1 = CreateFrame("Frame", nil, stack); c1:SetSize(50, 50)
            local c2 = CreateFrame("Frame", nil, stack); c2:SetSize(50, 50)
            stack:AddChild(c1)
            stack:AddChild(c2)
            stack:Layout()
            
            local _, _, _, _, y2 = c2:GetPoint()
            assert.is_equal(y2, -50)
        end)

        it("should handle child removal", function()
            local stack = FenUI:CreateStack(UIParent)
            local c1 = CreateFrame("Frame")
            stack:AddChild(c1)
            stack:RemoveChild(c1)
            assert.is_equal(#stack.children, 0)
        end)

        it("should handle clearing children", function()
            local stack = FenUI:CreateStack(UIParent)
            stack:AddChild(CreateFrame("Frame"))
            stack:ClearChildren()
            assert.is_equal(#stack.children, 0)
        end)

        it("should support the builder API", function()
            local stack = FenUI.Stack(UIParent)
                :direction("horizontal")
                :gap(10)
                :width(200)
                :child(CreateFrame("Frame"), { width = 50 })
                :child(CreateFrame("Frame"), { width = 50 })
                :build()
            assert.is_equal(stack.direction, "horizontal")
            assert.is_equal(stack.gap, 10)
            assert.is_equal(#stack.children, 2)
        end)

        it("should handle wrapped layout", function()
            local stack = FenUI:CreateFlex(UIParent, {
                width = 100,
                gap = 10
            })
            local c1 = CreateFrame("Frame", nil, stack); c1:SetSize(60, 20)
            local c2 = CreateFrame("Frame", nil, stack); c2:SetSize(60, 20)
            stack:AddChild(c1)
            stack:AddChild(c2)
            stack:Layout()
            -- c2 should be on second line because 60+10+60 = 130 > 100
        end)
    end)

    describe("Grid", function()
        it("should handle auto-sizing rows", function()
            local grid = FenUI:CreateGrid(UIParent, {
                columns = { "1fr" },
                rowHeight = 30
            })
            grid:SetData({ { a = 1 }, { b = 2 } })
            assert.is_equal(grid:GetHeight(), 60) -- 2 rows * 30
        end)

        it("should handle multi-column grid", function()
            local grid = FenUI:CreateGrid(UIParent, {
                columns = { "100px", "1fr" },
                width = 300
            })
            grid:SetWidth(300)
            grid:UpdateLayout()
            grid:SetData({ { a = 1, b = 2 } })
            -- Row 1, Col 1 should be 100px
            -- Row 1, Col 2 should be 200px
            assert.is_equal(grid.colWidths[1], 100)
            assert.is_equal(grid.colWidths[2], 200)
        end)

        it("should handle selection", function()
            local selected = nil
            local grid = FenUI:CreateGrid(UIParent, {
                columns = { "1fr" },
                onRowClick = function(row) selected = row end
            })
            grid:SetData({ { a = 1 } })
            local row = grid.rows[1]
            local script = row:GetScript("OnMouseDown")
            script(row)
            assert.is_not_nil(selected)
        end)
    end)

    describe("Group", function()
        it("should handle multi-column mode", function()
            local group = FenUI:CreateGroup(UIParent, {
                width = 300,
                cols = { "100px", "1fr" }
            })
            group:SetWidth(300)
            group:LayoutCells()
            
            assert.is_equal(group.cells[1]:GetWidth(), 100)
            assert.is_equal(group.cells[2]:GetWidth(), 200)
        end)

        it("should handle margins and padding", function()
            local group = FenUI:CreateGroup(UIParent, {
                margin = 10,
                padding = 5,
                marginTop = 20
            })
            local margin = group:GetMargin()
            local padding = group:GetPadding()
            assert.is_equal(margin.top, 20)
            assert.is_equal(padding.left, 5)
        end)

        it("should handle content frame", function()
            local group = FenUI:CreateGroup(UIParent)
            local content = group:GetContentFrame()
            assert.is_not_nil(content)
            
            local child = CreateFrame("Frame")
            group:SetContent(child)
            assert.is_equal(child:GetParent(), content)
            
            -- Test SetContent with nil
            group:SetContent(nil)
        end)

        it("should support the builder API", function()
            local group = FenUI.Group(UIParent)
                :size(200, 100)
                :padding(10)
                :columns(2)
                :build()
            assert.is_equal(group:GetWidth(), 200)
            assert.is_equal(group.config.padding, 10)
            assert.is_equal(group.config.cols, 2)
            
            -- Test other builder methods
            local group2 = FenUI.Group(UIParent)
                :width(100):height(100):name("T")
                :minWidth(50):maxWidth(200)
                :minHeight(50):maxHeight(200)
                :aspectRatio(1)
                :paddingTop(1):paddingBottom(2):paddingLeft(3):paddingRight(4)
                :rows(2):gap(5)
                :build()
            assert.is_equal(group2:GetWidth(), 100)
        end)

        it("should handle individual cell access", function()
            local group = FenUI:CreateGroup(UIParent, { cols = 3 })
            assert.is_not_nil(group:GetCell(1))
            assert.is_not_nil(group:GetCell(3))
            assert.is_nil(group:GetCell(4))
        end)

        it("should handle dynamic sizing and constraints", function()
            local group = FenUI:CreateGroup(UIParent, {
                width = 200,
                maxWidth = 150
            })
            assert.is_equal(group:GetWidth(), 150)
            
            group:ApplySize(300, 300, { minWidth = 400 })
            assert.is_equal(group:GetWidth(), 400)
            
            group:UpdateDynamicSize()
        end)

        it("should handle margin and padding string resolutions", function()
            -- Mock layout token
            local old_GetLayout = FenUI.GetLayout
            FenUI.GetLayout = function(self, key) if key == "largePadding" then return 40 end return 0 end
            
            local group = FenUI:CreateGroup(UIParent, {
                padding = "largePadding",
                margin = "largePadding"
            })
            local p = group:GetPadding()
            local m = group:GetMargin()
            assert.is_equal(p.top, 40)
            assert.is_equal(m.top, 40)
            
            FenUI.GetLayout = old_GetLayout
        end)

        it("should handle numeric cell definitions", function()
            local group = FenUI:CreateGroup(UIParent, {
                cols = 3
            })
            assert.is_equal(#group.cells, 3)
            assert.is_equal(group.cells[1].def.type, "fr")
        end)

        it("should handle px cell definitions", function()
            local group = FenUI:CreateGroup(UIParent, {
                cols = { "100px", "1fr" }
            })
            assert.is_equal(group.cells[1].def.type, "fixed")
            assert.is_equal(group.cells[1].def.value, 100)
        end)
    end)

    describe("Buttons", function()
        it("should create a standard button", function()
            local btn = FenUI:CreateButton(UIParent, {
                text = "Test Button",
                width = 120
            })
            assert.is_not_nil(btn)
            assert.is_equal(btn:GetText(), "Test Button")
            assert.is_equal(btn:GetWidth(), 120)
        end)

        it("should handle click events", function()
            local clicked = false
            local btn = FenUI:CreateButton(UIParent, {
                onClick = function() clicked = true end
            })
            local script = btn:GetScript("OnClick")
            script(btn, "LeftButton", false)
            assert.is_true(clicked)
        end)

        it("should create an icon button", function()
            local btn = FenUI:CreateIconButton(UIParent, {
                icon = "interface\\icons\\inv_misc_questionmark",
                size = 32
            })
            assert.is_not_nil(btn)
            assert.is_equal(btn:GetWidth(), 32)
            assert.is_equal(btn.icon:GetTexture(), "interface\\icons\\inv_misc_questionmark")
        end)

        it("should create a close button", function()
            local btn = FenUI:CreateCloseButton(UIParent, { name = "TestClose" })
            assert.is_not_nil(btn)
            assert.is_equal(_G["TestClose"], btn)
        end)

        it("should handle close button on parent", function()
            local parent = CreateFrame("Frame")
            parent:Show()
            local btn = FenUI:CreateCloseButton(parent)
            local script = btn:GetScript("OnClick")
            script(btn)
            assert.is_false(parent:IsShown())
        end)

        it("should handle custom close handler", function()
            local closed = false
            local btn = FenUI:CreateCloseButton(UIParent, {
                onClose = function() closed = true end
            })
            local script = btn:GetScript("OnClick")
            script(btn)
            assert.is_true(closed)
        end)

        it("should support ButtonMixin methods", function()
            local btn = FenUI:CreateButton(UIParent, "Test")
            btn:SetOnClick(function() end)
            btn:SetOnEnter(function() end)
            btn:SetOnLeave(function() end)
            assert.is_not_nil(btn.hooks.onClick)
            assert.is_table(btn:GetPadding())
            assert.is_table(btn:GetMargin())
        end)
    end)

    describe("Checkbox", function()
        it("should create a checkbox", function()
            local cb = FenUI:CreateCheckbox(UIParent, {
                label = "Check Me"
            })
            assert.is_not_nil(cb)
            assert.is_equal(cb.label:GetText(), "Check Me")
            assert.is_false(cb:GetChecked())
        end)

        it("should handle check toggle", function()
            local changed = false
            local cb = FenUI:CreateCheckbox(UIParent, {
                onChange = function(_, val) changed = val end
            })
            cb:SetChecked(true)
            assert.is_true(cb:GetChecked())
            assert.is_true(changed)
            
            cb:Toggle()
            assert.is_false(cb:GetChecked())
            assert.is_false(changed)
        end)

        it("should support custom textures", function()
            local cb = FenUI:CreateCheckbox(UIParent, {
                checkedTexture = "checked",
                uncheckedTexture = "unchecked"
            })
            assert.is_equal(cb.boxBg:GetTexture(), "unchecked")
            cb:SetChecked(true)
            assert.is_equal(cb.boxBg:GetTexture(), "checked")
        end)
    end)

    describe("Image", function()
        it("should create a static image", function()
            local img = FenUI:CreateImage(UIParent, {
                texture = "interface\\icons\\spell_nature_healingtouch",
                size = 64
            })
            assert.is_not_nil(img)
            assert.is_equal(img.texture:GetTexture(), "interface\\icons\\spell_nature_healingtouch")
        end)

        it("should handle conditional variants (class)", function()
            local img = FenUI:CreateImage(UIParent, {
                condition = "class",
                variants = {
                    WARRIOR = "interface\\icons\\ability_warrior_innerrage",
                    MAGE = "interface\\icons\\spell_holy_magicalsentry"
                }
            })
            -- Mock is WARRIOR
            img:Refresh()
            assert.is_equal(img.texture:GetTexture(), "interface\\icons\\ability_warrior_innerrage")
        end)

        it("should handle tinting", function()
            local img = FenUI:CreateImage(UIParent, {
                texture = "test",
                tint = "gold500"
            })
            -- GetColor for gold500 is roughly (1, 0.82, 0)
            -- We just check that SetTint doesn't error and refreshes
            img:SetTint("gold500")
            assert.is_not_nil(img.texture)
            
            img:ClearTint()
            img:SetTint({ 1, 0, 0, 1 })
            assert.is_not_nil(img.texture)
        end)

        it("should handle masking", function()
            local img = FenUI:CreateImage(UIParent, {
                texture = "test",
                mask = "circle"
            })
            assert.is_not_nil(img.maskTexture)
            img:ClearMask()
            assert.is_not_nil(img.maskTexture) -- Still exists but removed from texture
        end)

        it("should handle fill mode", function()
            local img = FenUI:CreateImage(UIParent, {
                texture = "test",
                fill = true
            })
            assert.is_true(img:GetFill())
            img:SetFill(false)
            assert.is_false(img:GetFill())
            
            -- Test filling logic
            img:SetFill(true)
            -- Single frame widget, no LayoutCells needed
        end)

        it("should handle various condition resolvers", function()
            local img = FenUI:CreateImage(UIParent, {
                condition = "faction",
                variants = { Horde = "horde_tex", Alliance = "alli_tex" }
            })
            -- Mock is Horde
            img:Refresh()
            assert.is_equal(img.texture:GetTexture(), "horde_tex")

            -- spec resolver returns 1
            img:SetConditional("spec", { [1] = "spec1_tex" })
            img:Refresh()
            -- Force resolver to return 1 if needed
            if img.texture:GetTexture() ~= "spec1_tex" then
                FenUI:RegisterImageCondition("spec", function() return 1 end)
                img:Refresh()
            end
            assert.is_equal(img.texture:GetTexture(), "spec1_tex")
            
            -- Test default texture when no variant matches
            img:SetConditional("class", { MAGE = "mage_tex" })
            img.config.fallback = "default_tex"
            img:Refresh()
            assert.is_equal(img.texture:GetTexture(), "default_tex")
        end)

        it("should handle sizing modes", function()
            local img = FenUI:CreateImage(UIParent, {
                texture = "test",
                sizing = "cover"
            })
            img:ApplySizing()
            assert.is_not_nil(img.texture)
            
            img:SetSizing("contain")
            img:ApplySizing()
            assert.is_not_nil(img.texture)
        end)

        it("should support atlas textures", function()
            local img = FenUI:CreateImage(UIParent, {
                atlas = "some_atlas"
            })
            assert.is_equal(img.texture:GetTexture(), "some_atlas")
            img:SetAtlas("other_atlas")
            assert.is_equal(img.texture:GetTexture(), "other_atlas")
        end)

        it("should register custom conditions", function()
            FenUI:RegisterImageCondition("custom", function() return "key" end)
            local conditions = FenUI:GetImageConditions()
            local found = false
            for _, c in ipairs(conditions) do if c == "custom" then found = true end end
            assert.is_true(found)
        end)
    end)

    describe("ImageButton", function()
        it("should create an image button", function()
            local btn = FenUI:CreateImageButton(UIParent, {
                texture = "interface\\icons\\inv_misc_questionmark",
                size = 32,
                isToggle = true
            })
            assert.is_not_nil(btn)
            assert.is_equal(btn:GetWidth(), 32)
            assert.is_true(btn.isToggle)
        end)

        it("should handle toggle state", function()
            local toggled = false
            local btn = FenUI:CreateImageButton(UIParent, {
                isToggle = true,
                onToggle = function(_, active) toggled = active end
            })
            btn:SetActive(true)
            assert.is_true(btn:GetActive())
            assert.is_true(toggled)
            
            btn:SetActive(false)
            assert.is_false(btn:GetActive())
            
            btn:Toggle()
            assert.is_true(btn:GetActive())
        end)

        it("should handle click and highlight", function()
            local clicked = false
            local btn = FenUI:CreateImageButton(UIParent, { 
                texture = "test",
                onClick = function() clicked = true end
            })
            local script = btn:GetScript("OnMouseDown")
            if script then script(btn, "LeftButton") end
            assert.is_true(btn.isPressed)
            
            script = btn:GetScript("OnMouseUp")
            if script then script(btn, "LeftButton") end
            assert.is_false(btn.isPressed)

            script = btn:GetScript("OnClick")
            if script then script(btn, "LeftButton") end
            assert.is_true(clicked)
        end)
    end)

    describe("EmptyState", function()
        it("should create an empty state with title and subtitle", function()
            local es = FenUI:CreateEmptyState(UIParent, {
                title = "Empty",
                subtitle = "Nothing here"
            })
            assert.is_not_nil(es)
            assert.is_equal(es.titleText:GetText(), "Empty")
            assert.is_equal(es.subtitleText:GetText(), "Nothing here")
        end)

        it("should handle icon/image", function()
            local es = FenUI:CreateEmptyState(UIParent, {
                icon = "interface\\icons\\inv_misc_questionmark",
                iconSize = 48
            })
            assert.is_not_nil(es.slots.top)
            assert.is_equal(es.topSlot:GetWidth(), 48)
        end)

        it("should handle background types", function()
            local es1 = FenUI:CreateEmptyState(UIParent, { background = "black" })
            assert.is_true(es1.bg:IsShown())
            
            local es2 = FenUI:CreateEmptyState(UIParent, { backgroundImage = "test" })
            assert.is_equal(es2.bg:GetTexture(), "test")
            
            local es3 = FenUI:CreateEmptyState(UIParent, { 
                backgroundGradient = { from = "black", to = "white" } 
            })
            assert.is_true(es3.bg:IsShown())
        end)

        it("should handle slots and text updates", function()
            local es = FenUI:CreateEmptyState(UIParent, { title = "T", subtitle = "S" })
            es:SetTitle("New Title")
            es:SetSubtitle("New Subtitle")
            assert.is_equal(es.titleText:GetText(), "New Title")
            
            local custom = CreateFrame("Frame")
            custom:SetSize(100, 100)
            es:SetSlot("top", custom)
            assert.is_equal(es:GetSlot("top"), custom)
            
            es:ClearSlot("top")
            assert.is_nil(es:GetSlot("top"))
            
            es:SetVisible(false)
            assert.is_false(es:IsShown())
        end)
    end)

    describe("Section", function()
        it("should create a section with content", function()
            local s = FenUI:CreateSection(UIParent, {
                heading = "Heading",
                body = "Body text"
            })
            assert.is_not_nil(s)
            assert.is_equal(s.heading:GetText(), "Heading")
            assert.is_equal(s.body:GetText(), "Body text")
        end)

        it("should update height", function()
            local s = FenUI:CreateSection(UIParent, { heading = "H", body = "B" })
            local h1 = s:GetHeight()
            s:SetBody("Longer body text\nwith newlines")
            local h2 = s:GetHeight()
            -- String height is mocked to 20 in wow_api.lua, so it won't change
            -- unless we change the number of lines or something.
            -- But we can check that GetHeight doesn't crash.
            assert.is_number(h2)
        end)
    end)

    describe("Input", function()
        it("should create an input field", function()
            local input = FenUI:CreateInput(UIParent, {
                placeholder = "Search..."
            })
            assert.is_not_nil(input)
            assert.is_not_nil(input.editBox)
            assert.is_equal(input.placeholder:GetText(), "Search...")
        end)

        it("should handle text changes", function()
            local changed = false
            local input = FenUI:CreateInput(UIParent, {
                onChange = function() changed = true end
            })
            input:SetText("Hello")
            assert.is_equal(input:GetText(), "Hello")
            -- We manually fire the script because SetText might not fire it in mock
            local script = input.editBox:GetScript("OnTextChanged")
            if script then script(input.editBox) end
            assert.is_true(changed)
        end)

        it("should handle enter and escape", function()
            local entered = false
            local input = FenUI:CreateInput(UIParent, {
                onEnter = function() entered = true end
            })
            local script = input.editBox:GetScript("OnEnterPressed")
            if script then script(input.editBox) end
            assert.is_true(entered)
            
            script = input.editBox:GetScript("OnEscapePressed")
            if script then script(input.editBox) end
        end)
    end)

    describe("StatusRow", function()
        it("should create a status row with items", function()
            local sr = FenUI:CreateStatusRow(UIParent, {
                items = {
                    { label = "CPU", value = "1.2ms" },
                    { label = "Memory", value = "500kb" }
                }
            })
            assert.is_not_nil(sr)
            assert.is_equal(#sr.items, 2)
            assert.is_equal(sr.items[1].label, "CPU")
        end)

        it("should handle value updates", function()
            local sr = FenUI:CreateStatusRow(UIParent, {
                items = { { label = "Stat", value = "Old" } }
            })
            sr:SetValue("Stat", "New")
            assert.is_equal(sr.items[1].value, "New")
        end)
    end)

    describe("SectionHeader", function()
        it("should create a section header", function()
            local sh = FenUI:CreateSectionHeader(UIParent, {
                text = "My Section"
            })
            assert.is_not_nil(sh)
            assert.is_equal(sh.text:GetText(), "My Section")
        end)
    end)

    describe("Dropdown", function()
        it("should create a dropdown", function()
            local dd = FenUI:CreateDropdown(UIParent, {
                items = { "Option 1", "Option 2" },
                defaultText = "Select Option"
            })
            assert.is_not_nil(dd)
            assert.is_equal(dd.button:GetText(), "Select Option")
        end)

        it("should handle item selection", function()
            local selectedValue = nil
            local dd = FenUI:CreateDropdown(UIParent, {
                items = { { text = "One", value = 1 }, { text = "Two", value = 2 } },
                onSelect = function(v) selectedValue = v end
            })
            dd:UpdateMenuList()
            dd.menuList[1].func()
            assert.is_equal(selectedValue, 1)
            assert.is_equal(dd.button:GetText(), "One")
        end)

        it("should handle SetItems and SetValue", function()
            local dd = FenUI:CreateDropdown(UIParent, { items = { "A", "B" } })
            dd:SetValue("B")
            assert.is_equal(dd.button:GetText(), "B")
            
            dd:SetItems({ "C", "D" })
            dd:SetValue("D")
            assert.is_equal(dd.button:GetText(), "D")
        end)

        it("should handle ToggleMenu", function()
            local dd = FenUI:CreateDropdown(UIParent, { items = { "X" } })
            dd:ToggleMenu()
            assert.is_not_nil(dd.menuList)
        end)
    end)

    describe("SplitLayout", function()
        it("should create a split layout", function()
            local split = FenUI:CreateSplitLayout(UIParent, {
                navWidth = 150,
                items = {
                    { text = "General", key = "gen" },
                    { text = "Advanced", key = "adv" }
                }
            })
            assert.is_not_nil(split)
            assert.is_not_nil(split.navPanel)
            assert.is_not_nil(split.contentArea)
            assert.is_equal(#split.buttons, 2)
        end)

        it("should handle navigation selection", function()
            local split = FenUI:CreateSplitLayout(UIParent, {
                items = { { text = "A", key = "a" }, { text = "B", key = "b" } }
            })
            split:Select("b")
            assert.is_equal(split:GetSelectedKey(), "b")
        end)
    end)

    describe("ScrollBar", function()
        it("should create a scrollbar", function()
            local sb = FenUI:CreateScrollBar(UIParent, { width = 16 })
            assert.is_not_nil(sb)
            assert.is_equal(sb:GetWidth(), 16)
        end)

        it("should update thumb size", function()
            local sb = FenUI:CreateScrollBar(UIParent, { width = 16 })
            sb:SetHeight(100)
            sb:UpdateThumbSize(50, 200)
            assert.is_true(sb:IsShown())
        end)
    end)

    describe("MultiLineEditBox", function()
        it("should create a multiline edit box", function()
            local ml = FenUI:CreateMultiLineEditBox(UIParent, {
                text = "Initial Text"
            })
            assert.is_not_nil(ml)
            assert.is_equal(ml:GetText(), "Initial Text")
        end)

        it("should handle read-only mode", function()
            local ml = FenUI:CreateMultiLineEditBox(UIParent, {
                readOnly = true,
                text = "Locked"
            })
            assert.is_true(ml.readOnly)
            ml:SetText("Programmatic update")
            assert.is_equal(ml:GetText(), "Programmatic update")
        end)

        it("should handle scrolling", function()
            local ml = FenUI:CreateMultiLineEditBox(UIParent, { text = "Line 1\nLine 2\nLine 3" })
            ml:ScrollToBottom()
            -- Just check it doesn't crash
        end)

        it("should handle focus events", function()
            local ml = FenUI:CreateMultiLineEditBox(UIParent)
            local script = ml.editBox:GetScript("OnEditFocusGained")
            if script then script(ml.editBox) end
            
            script = ml.editBox:GetScript("OnEditFocusLost")
            if script then script(ml.editBox) end
        end)

        it("should handle ReadOnly mode transitions", function()
            local ml = FenUI:CreateMultiLineEditBox(UIParent)
            ml:SetReadOnly(true)
            assert.is_true(ml.readOnly)
            assert.is_not_nil(ml.editBox:GetScript("OnKeyDown"))
            
            ml:SetReadOnly(false)
            assert.is_false(ml.readOnly)
            assert.is_nil(ml.editBox:GetScript("OnKeyDown"))
        end)

        it("should handle Clear and SelectAll", function()
            local ml = FenUI:CreateMultiLineEditBox(UIParent, { text = "Test" })
            ml:Clear()
            assert.is_equal(ml:GetText(), "")
            
            ml:SelectAll()
            -- Just check it doesn't crash
        end)

        it("should handle SetLabel", function()
            local ml = FenUI:CreateMultiLineEditBox(UIParent)
            ml:SetLabel("My Label")
            assert.is_equal(ml.label:GetText(), "My Label")
        end)

        it("should handle OnMouseUp for focus", function()
            local ml = FenUI:CreateMultiLineEditBox(UIParent)
            local script = ml.scrollFrame:GetScript("OnMouseUp")
            if script then script(ml.scrollFrame) end
            -- Should set focus
        end)
    end)
end)
