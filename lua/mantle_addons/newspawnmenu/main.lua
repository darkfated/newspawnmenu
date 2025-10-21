local PANEL = {}

function PANEL:Init()
    self.tabs = vgui.Create('MantleTabs', self)
    self.tabs:Dock(FILL)
    self.tabs:DockMargin(8, 8, 8, 8)

    local tabsList = spawnmenu.GetCreationTabs()

    for name, tab in SortedPairsByMemberValue(tabsList, 'Order') do
        local contentPanel = tab.Function()
        contentPanel:SetParent(self.tabs)
        self.tabs:AddTab(name, contentPanel, Material(tab.Icon))
    end
end

function PANEL:Paint(w, h)
    NewSpawnMenu.PanelPaint(w, h)
end

vgui.Register('NewSpawnMenu.Main', PANEL, 'EditablePanel')
