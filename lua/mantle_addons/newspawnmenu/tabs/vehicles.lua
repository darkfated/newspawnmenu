local PANEL = {}

function PANEL:Init()
    self:AddFunc(function(tabl, itemIndex)
        RunConsoleCommand('gm_spawnvehicle', itemIndex)
    end)

    self:AddFuncPaint(function(name, itemIndex, tabl, w, h)
        local mat = Material(tabl.IconOverride or 'entities/' .. itemIndex .. '.png')
        RNDX().Rect(0, 0, w, h)
            :Rad(32)
            :Material(mat)
            :Shape(RNDX.SHAPE_IOS)
        :Draw()

        RNDX().Rect(0, h - 30, w, 30)
            :Radii(0, 0, 32, 32)
            :Color(Mantle.color.panel_alpha[2])
            :Shape(RNDX.SHAPE_IOS)
        :Draw()
        draw.SimpleText(tabl.Name, 'Fated.12', w * 0.5, h - 10, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
    end)

    local vehicles = list.Get('Vehicles')

    for k, veh in pairs(vehicles) do
        self:AddItem(veh.PrintName, veh.Category, veh, k)
    end
end

vgui.Register('NewSpawnMenu.Tabs.Vehicles', PANEL, 'NewSpawnMenu.Content')

NewSpawnMenu.CreateTab('vehicles', 'Транспорт', 'icon16/car.png', 'NewSpawnMenu.Tabs.Vehicles')
