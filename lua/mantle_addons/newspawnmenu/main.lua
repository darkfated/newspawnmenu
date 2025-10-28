local convar_newspawnmenu_default_tabs = CreateClientConVar('newspawnmenu_default_tabs', 1, true, false)
local PANEL = {}

function PANEL:Init()
    self.tabs = vgui.Create('MantleTabs', self)
    self.tabs:Dock(FILL)
    self.tabs:DockMargin(8, 8, 8, 8)

    if convar_newspawnmenu_default_tabs:GetBool() then
        local tabsList = spawnmenu.GetCreationTabs()

        for name, tab in SortedPairsByMemberValue(tabsList, 'Order') do
            local contentPanel = tab.Function()
            contentPanel:SetParent(self.tabs)
            self.tabs:AddTab(name, contentPanel, Material(tab.Icon))
        end
    else
        local tabsList = spawnmenu.GetCreationTabs()

        for id, tab in pairs(NewSpawnMenu.tabs) do
            local panelTab = vgui.Create(tab.panel)

            self.tabs:AddTab(tab.name, panelTab, Material(tab.icon))
        end
    end
end

function PANEL:Paint(w, h)
    NewSpawnMenu.PanelPaint(w, h)
end

vgui.Register('NewSpawnMenu.Main', PANEL, 'EditablePanel')

concommand.Add('newspawnmenu_remove', function()
    if IsValid(NewSpawnMenu.menu) then
        NewSpawnMenu.menu:Remove()
    end
end)

hook.Add('AddToolMenuTabs', 'NewSpawnMenu', function()
	spawnmenu.AddToolTab('newspawnmenu', 'Custom', 'icon16/application_osx_terminal.png')

	spawnmenu.AddToolCategory('newspawnmenu', 'newspawnmenu_v', 'Visual')
end )

hook.Add('PopulateToolMenu', 'NewSpawnMenu', function()
    spawnmenu.AddToolMenuOption('newspawnmenu','newspawnmenu_v', 'newspawnmenu_v_basic', 'Basic', '', '', function(pan)
        pan:Help(Mantle.lang.get('newspawnmenu', 'help_apply_settings'))
        pan:CheckBox(Mantle.lang.get('newspawnmenu', 'checkbox_enable_menu'), 'newspawnmenu_on')
        pan:CheckBox(Mantle.lang.get('newspawnmenu', 'checkbox_enable_default_tabs'), 'newspawnmenu_default_tabs')
        pan:Button(Mantle.lang.get('newspawnmenu', 'button_recreate_menu'), 'newspawnmenu_remove')
    end)

    spawnmenu.AddToolMenuOption('newspawnmenu','newspawnmenu_v', 'newspawnmenu_v_themes', 'Themes', '', '', function(pan)
        local comboboxTheme = vgui.Create('MantleComboBox', pan)
        comboboxTheme:Dock(TOP)
        comboboxTheme:SetPlaceholder(Mantle.lang.get('newspawnmenu', 'select_interface_theme'))
        comboboxTheme:AddChoice(Mantle.lang.get('newspawnmenu', 'theme_dark'), 'dark')
        comboboxTheme:AddChoice(Mantle.lang.get('newspawnmenu', 'theme_dark_mono'), 'dark_mono')
        comboboxTheme:AddChoice(Mantle.lang.get('newspawnmenu', 'theme_light'), 'light')
        comboboxTheme:AddChoice(Mantle.lang.get('newspawnmenu', 'theme_blue'), 'blue')
        comboboxTheme:AddChoice(Mantle.lang.get('newspawnmenu', 'theme_red'), 'red')
        comboboxTheme:AddChoice(Mantle.lang.get('newspawnmenu', 'theme_green'), 'green')
        comboboxTheme:AddChoice(Mantle.lang.get('newspawnmenu', 'theme_orange'), 'orange')
        comboboxTheme:AddChoice(Mantle.lang.get('newspawnmenu', 'theme_purple'), 'purple')
        comboboxTheme:AddChoice(Mantle.lang.get('newspawnmenu', 'theme_coffee'), 'coffee')
        comboboxTheme:AddChoice(Mantle.lang.get('newspawnmenu', 'theme_ice'), 'ice')
        comboboxTheme:AddChoice(Mantle.lang.get('newspawnmenu', 'theme_wine'), 'wine')
        comboboxTheme:AddChoice(Mantle.lang.get('newspawnmenu', 'theme_violet'), 'violet')
        comboboxTheme:AddChoice(Mantle.lang.get('newspawnmenu', 'theme_moss'), 'moss')
        comboboxTheme:AddChoice(Mantle.lang.get('newspawnmenu', 'theme_coral'), 'coral')
        comboboxTheme.OnSelect = function(_, _, data)
            RunConsoleCommand('mantle_theme', data)
        end

        local listThemeColors = vgui.Create('DIconLayout', pan)
        listThemeColors:Dock(TOP)
        listThemeColors:DockMargin(6, 8, 6, 0)
        listThemeColors:SetTall(164)
        listThemeColors:SetSpaceX(8)
        listThemeColors:SetSpaceY(8)

        for colId, _ in pairs(Mantle.color) do
            local panCol = vgui.Create('DPanel', listThemeColors)
            panCol:SetSize(80, 80)
            panCol.Paint = function(_, w, h)
                RNDX().Rect(0, 0, w, h)
                    :Rad(16)
                    :Color(Mantle.color[colId])
                    :Shape(RNDX.SHAPE_IOS)
                :Draw()
                draw.SimpleText(colId, 'Fated.12', w * 0.5, h * 0.5, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
    end)
end)
