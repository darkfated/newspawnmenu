local PANEL = {}

function PANEL:Init()
    self.ContentType = 'vehicle'

    self:AddFunc(function(tabl, itemIndex)
        RunConsoleCommand('gm_spawnvehicle', itemIndex)
    end)

    self.ToolMode = 1

    local vehicles = list.Get('Vehicles')
    local customIcons = list.Get('ContentCategoryIcons')

    for k, veh in pairs(vehicles) do
        local name = language.GetPhrase(veh.PrintName or veh.Name or k)
        local btn = self:AddItem(name, veh.Category, veh, k, customIcons[veh.Category] or 'icon16/bricks.png')

        NewSpawnMenu.content.applyItemVisual(btn, k, veh, 'vehicle')
    end
end

vgui.Register('NewSpawnMenu.Tabs.Vehicles', PANEL, 'NewSpawnMenu.Content')

NewSpawnMenu.CreateTab(5, '#spawnmenu.category.vehicles', 'icon16/car.png', 'NewSpawnMenu.Tabs.Vehicles')
