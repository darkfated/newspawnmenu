local convar_newspawnmenu_default_tabs = CreateClientConVar('newspawnmenu_default_tabs', 1, true, false)
local PANEL = {}

function PANEL:Init()
    self.tabs = vgui.Create('MantleTabs', self)
    self.tabs:Dock(FILL)
    self.tabs:DockMargin(8, 8, 8, 8)

    if convar_newspawnmenu_default_tabs:GetBool() then
        local tabsList = spawnmenu.GetCreationTabs()

        for name, tab in SortedPairsByMemberValue(tabsList, 'Order') do
            print(name)
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
