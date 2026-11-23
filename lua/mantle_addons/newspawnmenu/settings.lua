local L = function(key)
    return Mantle.lang.get('newspawnmenu', key)
end

local function buildMenuSettings(pan)
    pan:Help(L('help_apply_settings'))
    pan:CheckBox(L('checkbox_enable_menu'), 'newspawnmenu_on')
    pan:CheckBox(L('checkbox_close_on_spawn'), 'newspawnmenu_close_on_spawn')
    pan:NumSlider(L('scale'), 'newspawnmenu_scale', 0.8, 1.2, 2)
    pan:CheckBox(L('checkbox_itemname_left'), 'newspawnmenu_itemname_left')

    pan:ComboBoxMulti(L('checkbox_mode'), {
        [L('checkbox_mode_0')] = {
            newspawnmenu_mode = 0
        },
        [L('checkbox_mode_1')] = {
            newspawnmenu_mode = 1
        },
        [L('checkbox_mode_2')] = {
            newspawnmenu_mode = 2
        }
    })

    pan:Button(L('button_recreate_menu'), 'newspawnmenu_remove')

    pan:CheckBox(L('checkbox_blur'), 'newspawnmenu_blur')
    pan:CheckBox(L('checkbox_opt'), 'newspawnmenu_opt')
end

local function buildToolsSettings(pan)
    pan:Help(L('help_apply_settings'))
    pan:CheckBox(L('checkbox_enable_search'), 'newspawnmenu_search_panel')
    pan:CheckBox(L('checkbox_compact_tools'), 'newspawnmenu_compact_tools')
    pan:CheckBox(L('checkbox_toolname_left'), 'newspawnmenu_toolname_left')

    pan:Button(L('button_recreate_menu'), 'newspawnmenu_remove')

    pan:CheckBox(L('checkbox_contrast_tools'), 'newspawnmenu_contrast_tools')
end

local function getThemeColors()
    local rows = {}

    for name, value in SortedPairs(Mantle.color) do
        if IsColor(value) then
            table.insert(rows, { name = name, key = name })
        elseif istable(value) then
            for i, col in ipairs(value) do
                if IsColor(col) then
                    table.insert(rows, { name = name .. '[' .. i .. ']', key = name, index = i })
                end
            end
        end
    end

    return rows
end

local function getRowColor(entry)
    if entry.index then
        local group = Mantle.color[entry.key]
        return group and group[entry.index]
    end

    return Mantle.color[entry.key]
end

local function buildThemeSettings(pan)
    local comboboxTheme = vgui.Create('MantleComboBox')
    comboboxTheme:SetPlaceholder(L('select_interface_theme'))

    local themes = Mantle.ui.getAvailableThemes()
    local activeTheme = Mantle.ui.getActiveThemeName()

    for _, theme in ipairs(themes) do
        comboboxTheme:AddChoice(theme.title, theme.id)

        if theme.id == activeTheme then
            comboboxTheme:SetValue(theme.title)
        end
    end

    comboboxTheme.OnSelect = function(_, _, id)
        Mantle.ui.setTheme(id)
    end
    pan:AddPanel(comboboxTheme)

    local colorRows = getThemeColors()

    local rowHeight, pad, swatchSize = 48, 12, 36

    local listThemeColors = vgui.Create('DPanel')
    listThemeColors.hoveredRow = 0
    pan:AddPanel(listThemeColors)
    listThemeColors:Dock(TOP)
    listThemeColors:DockMargin(8, 0, 8, 8)
    listThemeColors:SetTall(#colorRows * rowHeight + pad * 2)
    listThemeColors:SetMouseInputEnabled(true)

    listThemeColors.Paint = function(self, w, h)
        local baseCol = Mantle.color.panel and Mantle.color.panel[1] or Mantle.color.panel_alpha[1]

        RNDX.Rect(0, 0, w, h)
            :Rad(14)
            :Color(Mantle.color.panel_alpha[1])
            :Shape(RNDX.SHAPE_IOS)
        :Draw()

        for i, entry in ipairs(colorRows) do
            local col = getRowColor(entry)
            if !IsColor(col) then continue end

            local y = pad + (i - 1) * rowHeight
            local centerY = y + rowHeight * 0.5
            local swatchY = y + (rowHeight - swatchSize) * 0.5

            if self.hoveredRow == i then
                RNDX.Rect(4, y + 2, w - 8, rowHeight - 4)
                    :Rad(10)
                    :Color(Mantle.color.hover_overlay)
                :Draw()
            end

            RNDX.Rect(pad, swatchY, swatchSize, swatchSize)
                :Rad(10)
                :Color(baseCol)
                :Shape(RNDX.SHAPE_IOS)
            :Draw()

            RNDX.Rect(pad, swatchY, swatchSize, swatchSize)
                :Rad(10)
                :Color(col)
                :Shape(RNDX.SHAPE_IOS)
            :Draw()

            draw.SimpleText(entry.name, 'Fated.18', pad + swatchSize + 14, centerY, Mantle.color.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

            if i < #colorRows then
                local textX = pad + swatchSize + 14
                RNDX.Rect(textX, y + rowHeight - 3, w - pad - textX, 1)
                    :Color(Mantle.color.hover_overlay)
                :Draw()
            end
        end
    end

    listThemeColors.OnMouseMove = function(self, mx, my)
        local index = math.floor((my - pad) / rowHeight) + 1
        if index < 1 or index > #colorRows then index = 0 end
        self.hoveredRow = index
    end

    listThemeColors.OnMouseLeave = function(self)
        self.hoveredRow = 0
    end
end

hook.Add('AddToolMenuTabs', 'NewSpawnMenu', function()
    spawnmenu.AddToolTab('newspawnmenu', 'Custom', 'icon16/application_osx_terminal.png')
    spawnmenu.AddToolCategory('newspawnmenu', 'newspawnmenu_v', 'Visual')
end)

hook.Add('PopulateToolMenu', 'NewSpawnMenu', function()
    spawnmenu.AddToolMenuOption('newspawnmenu', 'newspawnmenu_v', 'newspawnmenu_v_menu', 'Menu', '', '', buildMenuSettings)
    spawnmenu.AddToolMenuOption('newspawnmenu', 'newspawnmenu_v', 'newspawnmenu_v_tools', 'Tools', '', '', buildToolsSettings)
    spawnmenu.AddToolMenuOption('newspawnmenu', 'newspawnmenu_v', 'newspawnmenu_v_themes', 'Themes', '', '', buildThemeSettings)
end)
