local PANEL = {}

function PANEL:Init()
    self:AddFunc(function(tabl, itemIndex)
        RunConsoleCommand('gm_spawnvehicle', itemIndex)
    end)

    self:AddFuncPaint(function(name, itemIndex, tabl, w, h, btn)
        local scale = btn.anim_scale
        local offset = (1 - scale) * 0.5
        local scaledW = w * scale
        local scaledH = h * scale
        local x = offset * w
        local y = offset * h

        RNDX().Rect(0, 0, w, h)
            :Rad(32)
            :Material(btn.mat)
            :Shape(RNDX.SHAPE_IOS)
        :Draw()

        RNDX().Rect(0, 0, w, h)
            :Rad(24)
            :Shape(RNDX.SHAPE_IOS)
            :Blur(2, 8)
        :Draw()

        render.PushFilterMag(TEXFILTER.ANISOTROPIC)
        render.PushFilterMin(TEXFILTER.ANISOTROPIC)
            RNDX().Rect(x, y, scaledW, scaledH)
                :Rad(24)
                :Material(btn.mat)
                :Shape(RNDX.SHAPE_IOS)
            :Draw()
        render.PopFilterMin()
        render.PopFilterMag()

        RNDX().Rect(0, h - 30, w, 30)
            :Radii(0, 0, 24, 24)
            :Color(Mantle.color.panel_alpha[2])
            :Shape(RNDX.SHAPE_IOS)
        :Draw()
        draw.SimpleText(tabl.Name, 'Fated.12', w * 0.5, h - 10, Mantle.color.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
    end)

    local vehicles = list.Get('Vehicles')
    local customIcons = list.Get('ContentCategoryIcons')

    for k, veh in pairs(vehicles) do
        local btn = self:AddItem(veh.PrintName, veh.Category, veh, k, customIcons[veh.Category] or 'icon16/bricks.png')
        btn.mat = Material(veh.IconOverride or 'entities/' .. k .. '.png')
    end
end

vgui.Register('NewSpawnMenu.Tabs.Vehicles', PANEL, 'NewSpawnMenu.Content')

NewSpawnMenu.CreateTab(5, '#spawnmenu.category.vehicles', 'icon16/car.png', 'NewSpawnMenu.Tabs.Vehicles')
