local PANEL = {}

function PANEL:Init()
    self:AddFunc(function(tabl, itemIndex)
        print(itemIndex)
        RunConsoleCommand('gmod_spawnnpc', itemIndex)
    end)

    self:AddFuncPaint(function(name, itemIndex, tabl, w, h, btn)
        local scale = btn.anim_scale
        local offset = (1 - scale) * 0.5
        local scaledW = w * scale
        local scaledH = h * scale
        local x = offset * w
        local y = offset * h

        local mat = Material(tabl.IconOverride or 'entities/' .. itemIndex .. '.png')

        RNDX().Rect(x, y, scaledW, scaledH)
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

    local npcs = list.Get('NPC')
    local customIcons = list.Get('ContentCategoryIcons')

    for k, npc in pairs(npcs) do
        self:AddItem(npc.Name, npc.Category, npc, k, customIcons[npc.Category] or 'icon16/monkey.png')
    end
end

vgui.Register('NewSpawnMenu.Tabs.NPCS', PANEL, 'NewSpawnMenu.Content')

NewSpawnMenu.CreateTab('npcs', '#spawnmenu.category.npcs', 'icon16/bricks.png', 'NewSpawnMenu.Tabs.NPCS')
