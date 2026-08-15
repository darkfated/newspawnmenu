local PANEL = {}

function PANEL:Init()
    self:AddFunc(function(tabl, itemIndex)
        RunConsoleCommand('gm_spawnsent', tabl.ClassName)
    end)

    self.ToolMode = 0

    local entities = list.Get('SpawnableEntities')
    local customIcons = list.Get('ContentCategoryIcons')

    for k, ent in pairs(entities) do
        local btn = self:AddItem(language.GetPhrase(ent.PrintName or ent.Name or ent.ClassName or k), ent.Category, ent, nil, customIcons[ent.Category] or 'icon16/bricks.png')

        local matName = ent.IconOverride or 'entities/' .. ent.ClassName .. '.png'
        local mat = Material(matName)

        if mat:IsError() then
            matName = matName:Replace('entities/', 'vgui/entities/'):Replace('.png', '')
            mat = Material(matName)
        end

        if !mat:IsError() then
            btn.mat = mat
        end
    end
end

vgui.Register('NewSpawnMenu.Tabs.Entities', PANEL, 'NewSpawnMenu.Content')

NewSpawnMenu.CreateTab(3, '#spawnmenu.category.entities', 'icon16/bricks.png', 'NewSpawnMenu.Tabs.Entities')
