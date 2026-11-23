local api = {}
NewSpawnMenu.api.creation = api

local function normalizeTabName(name)
    if isstring(name) and name:StartsWith('#') then
        return language.GetPhrase(name)
    end

    return name
end

function api.install(panel, tabBar)
    panel.creationTabs = {}

    function panel:RegisterCreationTab(name, title, tabId, contentPanel)
        local tabData = tabBar.tabs[tabId]

        local entry = {
            Name = title,
            id = tabId,
            ContentPanel = contentPanel,
            Tab = tabData and tabData._btn or nil
        }

        self.creationTabs[name] = entry
        self.creationTabs[normalizeTabName(name)] = entry
        if title != name then self.creationTabs[title] = entry end
    end

    function panel:GetCreationTab(id)
        return self.creationTabs[id] or self.creationTabs[normalizeTabName(id)]
    end

    function panel:GetCreationTabs()
        return self.creationTabs
    end

    function panel:SwitchToName(name)
        local entry = self:GetCreationTab(name)
        if !entry or !IsValid(tabBar) then return false end

        return tabBar:SetActiveTab(entry.id) == true
    end

    function panel:SetSearchPanel(searchPanel)
        self.searchPanel = searchPanel

        local menu = self:GetParent()
        if IsValid(menu) then menu.SearchPropPanel = searchPanel end
    end
end
