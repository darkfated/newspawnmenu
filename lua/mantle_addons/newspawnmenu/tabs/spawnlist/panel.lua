local spawnlist = NewSpawnMenu.spawnlist
local items = spawnlist.items
local catalog = spawnlist.catalog

local PANEL = {}
local nextId = 0
local convar_mode = GetConVar('newspawnmenu_mode')

function PANEL:Init()
    self.BaseClass.Init(self)

    nextId = nextId + 1
    self._hookName = 'NewSpawnMenu.Spawnlist.Refresh.' .. nextId
    self.ContentType = 'prop'
    self._roots = {}
    self._rootByTab = {}
    self._activeByRoot = {}
    self._activeEntry = nil

    self:AddFunc(function(tabl)
        items.spawn(tabl)
    end)

    self:AddFuncMiddle(function(tabl)
        items.spawnMiddle(tabl)
    end)

    hook.Add('GameContentChanged', self._hookName, function()
        if !IsValid(self) then return end

        catalog.invalidate()
        self:Rebuild()
    end)

    self:Rebuild()
end

function PANEL:OnRemove()
    hook.Remove('GameContentChanged', self._hookName)

    if self.BaseClass.OnRemove then self.BaseClass.OnRemove(self) end
end

function PANEL:ConfigureGrid(grid)
    local isWide = convar_mode and convar_mode:GetInt() == 1

    grid:Configure(isWide and 13 or 10, 7, 8, 58)
end

function PANEL:PaintOverlay()
end

function PANEL:Rebuild()
    local activeRoot = IsValid(self.left) and self.left:GetActiveTab() or 1

    self.items = {}
    self._roots = {}
    self._rootByTab = {}
    self._activeEntry = nil

    self:ClearCardQueue()

    self.left = self:EnsureLeft(true)
    self.left:SetTabStyle('modern')

    for _, root in ipairs(catalog.availableRoots()) do
        local categoryData = self:AddCategory(root.title, root.icon)
        local entry = {
            root = root,
            categoryData = categoryData,
            buckets = {},
            initialized = false
        }

        self._rootByTab[categoryData.tabId] = entry
        self._roots[root.key] = entry
    end

    if activeRoot > 1 and activeRoot <= self.left:GetTabCount() then
        self.left:SetActiveTab(activeRoot, true)
    end
end

function PANEL:LoadRoot(entry)
    entry.initialized = true

    local tabs = catalog.tabs(entry.root.key)
    local categoryTabs = entry.categoryData.tabs
    local saved = self._activeByRoot[entry.root.key]

    for _, tab in ipairs(tabs) do
        local bucket = self:AddTabBucket(entry.categoryData, tab.title, tab.icon)
        if bucket then
            bucket.key = tab.key
            bucket.desc = tab
            entry.buckets[#entry.buckets + 1] = bucket
        end
    end

    if saved and IsValid(categoryTabs) then
        for _, bucket in ipairs(entry.buckets) do
            if bucket.key == saved then
                categoryTabs:SetActiveTab(bucket.id, true)
                break
            end
        end
    end
end

function PANEL:BuildItemBucket(bucket)
    for _, section in ipairs(bucket.desc.sections) do
        local grid = self:AddSectionGrid(bucket, section.title)

        for _, desc in ipairs(section.items) do
            self:QueueCard(items.job(desc, grid))
        end
    end
end

function PANEL:BuildFolderSections(bucket)
    for _, folder in ipairs(catalog.folders(bucket.desc)) do
        local current = folder

        self:AddLazySection(bucket, current.title, function(_, grid)
            for _, section in ipairs(catalog.models(current)) do
                for _, desc in ipairs(section.items) do
                    self:QueueCard(items.job(desc, grid))
                end
            end
        end)
    end
end

function PANEL:LoadBucket(bucket)
    bucket.initialized = true

    if bucket.desc.kind == 'items' then
        self:BuildItemBucket(bucket)
    elseif bucket.desc.kind == 'folders' then
        self:BuildFolderSections(bucket)
    end
end

function PANEL:StoreActiveBucket(entry)
    if !entry then return end

    local tabs = entry.categoryData.tabs
    if !IsValid(tabs) then return end

    local active = tabs:GetActiveTab()
    for _, bucket in ipairs(entry.buckets) do
        if bucket.id == active then
            self._activeByRoot[entry.root.key] = bucket.key

            return bucket
        end
    end
end

function PANEL:SyncTabs()
    if !IsValid(self.left) then return end

    local entry = self._rootByTab[self.left:GetActiveTab()]
    if self._activeEntry and self._activeEntry != entry then
        self:StoreActiveBucket(self._activeEntry)
    end

    self._activeEntry = entry
    if !entry then return end

    if !entry.initialized then self:LoadRoot(entry) end

    local bucket = self:StoreActiveBucket(entry)
    if bucket and !bucket.initialized then self:LoadBucket(bucket) end
end

function PANEL:Think()
    self.BaseClass.Think(self)
    self:SyncTabs()
end

vgui.Register('NewSpawnMenu.Tabs.Spawnlist', PANEL, 'NewSpawnMenu.Content')

NewSpawnMenu.CreateTab('#spawnmenu.content_tab', language.GetPhrase('#spawnmenu.content_tab'), 'icon16/application_view_tile.png', 'NewSpawnMenu.Tabs.Spawnlist')
