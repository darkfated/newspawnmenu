local PANEL = {}

function PANEL:Init()
    self.ContentType = 'weapon'

    self:AddFunc(function(tabl)
        RunConsoleCommand('gm_giveswep', tabl.ClassName)
    end)

    self:AddFuncMiddle(function(tabl)
        RunConsoleCommand('gm_spawnswep', tabl.ClassName)
    end)

    self.ToolMode = 3

    NewSpawnMenu.content.populate.build(self, {
        hook = 'PopulateWeapons',
        list = 'Weapon',
        contentType = 'weapon',
        icon = 'icon16/gun.png',
        nameKeys = { 'PrintName', 'Name', 'ClassName' },
        filter = function(_, data)
            return data.Spawnable == true
        end,
        onClick = function(class)
            RunConsoleCommand('gm_giveswep', class)
        end
    })
end

vgui.Register('NewSpawnMenu.Tabs.Weapons', PANEL, 'NewSpawnMenu.Content')

NewSpawnMenu.CreateTab(2, '#spawnmenu.category.weapons', 'icon16/gun.png', 'NewSpawnMenu.Tabs.Weapons')
