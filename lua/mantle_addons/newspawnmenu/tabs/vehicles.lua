local PANEL = {}

function PANEL:Init()
    self:AddFunc(function(tabl, itemIndex)
        RunConsoleCommand('gm_spawnvehicle', itemIndex)
    end)

    self.ToolMode = 1

    local vehicles = list.Get('Vehicles')
    local customIcons = list.Get('ContentCategoryIcons')

    for k, veh in pairs(vehicles) do
        local btn = self:AddItem(language.GetPhrase(veh.PrintName or veh.Name or k), veh.Category, veh, k, customIcons[veh.Category] or 'icon16/bricks.png')

        local matName = veh.IconOverride or 'entities/' .. k .. '.png'
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

vgui.Register('NewSpawnMenu.Tabs.Vehicles', PANEL, 'NewSpawnMenu.Content')

NewSpawnMenu.CreateTab(5, '#spawnmenu.category.vehicles', 'icon16/car.png', 'NewSpawnMenu.Tabs.Vehicles')
