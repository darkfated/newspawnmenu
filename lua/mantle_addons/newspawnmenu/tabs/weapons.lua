local PANEL = {}

function PANEL:Init()
    self:AddFunc(function(tabl)
        RunConsoleCommand('gm_giveswep', tabl.ClassName)
    end)

    self:AddFuncPaint(function(name, itemIndex, tabl, w, h)
        local mat = Material(tabl.IconOverride or 'entities/' .. tabl.ClassName .. '.png')
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
        draw.SimpleText(tabl.PrintName, 'Fated.12', w * 0.5, h - 10, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
    end)

    local weps = list.Get('Weapon')

    for k, wep in pairs(weps) do
        if !wep.Spawnable then
            continue
        end

        self:AddItem(wep.PrintName, wep.Category, wep)
    end
end

vgui.Register('NewSpawnMenu.Tabs.Weapons', PANEL, 'NewSpawnMenu.Content')

NewSpawnMenu.CreateTab('weapons', '#spawnmenu.category.weapons', 'icon16/gun.png', 'NewSpawnMenu.Tabs.Weapons')
