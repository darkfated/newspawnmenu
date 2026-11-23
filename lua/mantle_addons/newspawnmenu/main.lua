local PANEL = {}

function PANEL:Init()
    self.tabs = vgui.Create('MantleTabs', self)
    self.tabs:Dock(FILL)
    self.tabs:DockMargin(8, 8, 8, 8)

    local tabsList = spawnmenu.GetCreationTabs()

    local cacheTabs = {}
    for id, tab in pairs(NewSpawnMenu.tabs) do
        cacheTabs[tab.name] = tab
    end

    for name, tab in SortedPairsByMemberValue(tabsList, 'Order') do
        if cacheTabs[name] then
            local newTab = cacheTabs[name]
            local panelTab = vgui.Create(newTab.panel)
            self.tabs:AddTab(newTab.name, panelTab, Material(newTab.icon))

            continue
        end

        local contentPanel = tab.Function()
        contentPanel:SetParent(self.tabs)
        self.tabs:AddTab(name, contentPanel, Material(tab.Icon))
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

cvars.AddChangeCallback('spawnmenu_reload', function()
    RunConsoleCommand('newspawnmenu_remove')
end)
