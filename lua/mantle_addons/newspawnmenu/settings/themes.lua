local L = NewSpawnMenu.settings.L

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

function NewSpawnMenu.settings.themeCombo(onSelect)
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
        if onSelect then onSelect(id) end
    end

    return comboboxTheme
end

function NewSpawnMenu.settings.buildThemes(pan)
    pan:AddPanel(NewSpawnMenu.settings.themeCombo())

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
