local PANEL = {}

function PANEL:Init()
    self.ContentType = 'vehicle'

    self:AddFunc(function(tabl, itemIndex)
        RunConsoleCommand('gm_spawnvehicle', itemIndex)
    end)

    self.ToolMode = 1

    NewSpawnMenu.content.populate.build(self, {
        hook = 'PopulateVehicles',
        list = 'Vehicles',
        contentType = 'vehicle',
        icon = 'icon16/car.png',
        nameKeys = { 'PrintName', 'Name' },
        onClick = function(class)
            RunConsoleCommand('gm_spawnvehicle', class)
        end
    })
end

vgui.Register('NewSpawnMenu.Tabs.Vehicles', PANEL, 'NewSpawnMenu.Content')

NewSpawnMenu.CreateTab(5, '#spawnmenu.category.vehicles', 'icon16/car.png', 'NewSpawnMenu.Tabs.Vehicles')
