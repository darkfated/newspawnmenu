local PANEL = {}

local convar_default_spawnlist = CreateClientConVar('newspawnmenu_default_spawnlist', 0, true, false)
local CONTENT_TAB = '#spawnmenu.content_tab'

local function titleText(value)
    if isstring(value) and value:StartsWith('#') then return language.GetPhrase(value) end

    return value
end

local function iconMaterial(icon)
    if !isstring(icon) or icon == '' then return end

    local mat = Material(icon)
    if !mat or mat:IsError() then return end

    return mat
end

function PANEL:Init()
    NewSpawnMenu.main = self

    self.tabs = vgui.Create('MantleTabs', self)
    self.tabs:Dock(FILL)
    self.tabs:DockMargin(8, 8, 8, 8)
    self.tabs:SetTabStyle('modern')

    NewSpawnMenu.api.creation.install(self, self.tabs)

    self._builders = {}

    local cacheTabs = {}
    for id, tab in pairs(NewSpawnMenu.tabs) do
        cacheTabs[id] = tab
        cacheTabs[tab.name] = tab
    end

    for name, tab in SortedPairsByMemberValue(spawnmenu.GetCreationTabs(), 'Order') do
        local override = cacheTabs[name]
        if name == CONTENT_TAB and convar_default_spawnlist:GetBool() then override = nil end

        local title = titleText(override and override.name or name)
        local icon = override and override.icon or tab.Icon
        local placeholder = vgui.Create('Panel')
        local tabId = self.tabs:AddTab(title, placeholder, iconMaterial(icon))

        self:RegisterCreationTab(name, title, tabId, placeholder)

        self._builders[tabId] = function()
            local child

            if override then
                child = vgui.Create(override.panel)
            else
                child = tab.Function()
            end

            if !IsValid(child) then return end

            child:SetParent(placeholder)
            child:Dock(FILL)

            local entry = self:GetCreationTab(name)
            if entry then entry.ContentPanel = child end
        end
    end

    local searchPanel = vgui.Create('Panel', self)
    searchPanel:Dock(FILL)
    searchPanel:SetVisible(false)
    self:SetSearchPanel(searchPanel)
end

function PANEL:Think()
    local id = self.tabs:GetActiveTab()
    local build = self._builders[id]
    if !build then return end

    self._builders[id] = nil
    build()
end

function PANEL:Paint(w, h)
    NewSpawnMenu.PanelPaint(w, h)
end

vgui.Register('NewSpawnMenu.Main', PANEL, 'EditablePanel')

concommand.Add('newspawnmenu_remove', function()
    NewSpawnMenu.compatibility.bridge.release()

    controlpanel.Clear()
end)
