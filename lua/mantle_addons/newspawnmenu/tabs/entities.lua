local PANEL = {}

function PANEL:Init()
    self.ContentType = 'entity'

    self:AddFunc(function(tabl, itemIndex)
        RunConsoleCommand('gm_spawnsent', tabl.ClassName)
    end)

    NewSpawnMenu.content.populate.build(self, {
        hook = 'PopulateEntities',
        list = 'SpawnableEntities',
        contentType = 'entity',
        icon = 'icon16/bricks.png',
        nameKeys = { 'PrintName', 'Name', 'ClassName' },
        onClick = function(class)
            RunConsoleCommand('gm_spawnsent', class)
        end
    })
end

vgui.Register('NewSpawnMenu.Tabs.Entities', PANEL, 'NewSpawnMenu.Content')

NewSpawnMenu.CreateTab(3, '#spawnmenu.category.entities', 'icon16/bricks.png', 'NewSpawnMenu.Tabs.Entities')
