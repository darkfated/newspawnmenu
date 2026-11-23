local PANEL = {}

function PANEL:Init()
    NewSpawnMenu.main = self

    self.tabs = vgui.Create('MantleTabs', self)
    self.tabs:Dock(FILL)
    self.tabs:DockMargin(8, 8, 8, 8)

    NewSpawnMenu.api.creation.install(self, self.tabs)

    local tabsList = spawnmenu.GetCreationTabs()

    local cacheTabs = {}
    for id, tab in pairs(NewSpawnMenu.tabs) do
        cacheTabs[tab.name] = tab
    end

    for name, tab in SortedPairsByMemberValue(tabsList, 'Order') do
        local title = name
        local panelTab
        local icon

        if cacheTabs[name] then
            local newTab = cacheTabs[name]
            title = newTab.name
            panelTab = vgui.Create(newTab.panel)
            icon = newTab.icon
        else
            panelTab = tab.Function()
            panelTab:SetParent(self.tabs)
            icon = tab.Icon
        end

        local tabId = self.tabs:AddTab(title, panelTab, Material(icon))
        self:RegisterCreationTab(name, title, tabId, panelTab)
    end

    local searchPanel = vgui.Create('Panel', self)
    searchPanel:Dock(FILL)
    searchPanel:SetVisible(false)
    self:SetSearchPanel(searchPanel)
end

function PANEL:Paint(w, h)
    NewSpawnMenu.PanelPaint(w, h)
end

vgui.Register('NewSpawnMenu.Main', PANEL, 'EditablePanel')

concommand.Add('newspawnmenu_remove', function()
    if IsValid(NewSpawnMenu.menu) then
        NewSpawnMenu.menu:Remove()
    end

    NewSpawnMenu.main = nil
    NewSpawnMenu.tools = nil
end)
