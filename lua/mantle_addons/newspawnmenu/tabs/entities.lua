local PANEL = {}

function PANEL:Init()
    self:AddFunc(function(tabl, itemIndex)
        RunConsoleCommand('gm_spawnsent', tabl.ClassName)
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
        draw.SimpleText(name, 'Fated.12', w * 0.5, h - 10, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
    end)

    local entities = list.Get('SpawnableEntities')

    for k, ent in pairs(entities) do
        self:AddItem(ent.PrintName, ent.Category, ent)
    end
end

vgui.Register('NewSpawnMenu.Tabs.Entities', PANEL, 'NewSpawnMenu.Content')

NewSpawnMenu.CreateTab('entities', 'Энтити', 'icon16/bricks.png', 'NewSpawnMenu.Tabs.Entities')
