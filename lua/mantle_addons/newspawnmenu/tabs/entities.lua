local PANEL = {}

function PANEL:Init()
    self.ContentType = 'entity'

    self:AddFunc(function(tabl, itemIndex)
        RunConsoleCommand('gm_spawnsent', tabl.ClassName)
    end)

    self.ToolMode = 0

    local entities = list.Get('SpawnableEntities')
    local customIcons = list.Get('ContentCategoryIcons')

    for k, ent in pairs(entities) do
        local name = language.GetPhrase(ent.PrintName or ent.Name or ent.ClassName or k)
        local btn = self:AddItem(name, ent.Category, ent, nil, customIcons[ent.Category] or 'icon16/bricks.png')

        NewSpawnMenu.content.applyItemVisual(btn, k, ent, 'entity')
    end
end

vgui.Register('NewSpawnMenu.Tabs.Entities', PANEL, 'NewSpawnMenu.Content')

NewSpawnMenu.CreateTab(3, '#spawnmenu.category.entities', 'icon16/bricks.png', 'NewSpawnMenu.Tabs.Entities')
