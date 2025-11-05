local PANEL = {}
local math_floor = math.floor

function PANEL:Init()
    self:AddFunc(function(tabl, itemIndex)
        RunConsoleCommand('gm_spawnsent', tabl.ClassName)
    end)

    local fontI = math_floor(14 * GetConVar('newspawnmenu_scale'):GetFloat())
    local textFont = 'Fated.' .. fontI

    self:AddFuncPaint(function(name, itemIndex, tabl, w, h, btn)
        local scale = btn.anim_scale
        local offset = (1 - scale) * 0.5
        local scaledW = w * scale
        local scaledH = h * scale
        local x = offset * w
        local y = offset * h

        if !NewSpawnMenu.convar.opt then
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
        end

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
        draw.SimpleText(name, textFont, w * 0.5, h - fontI * 0.5 - 1, Mantle.color.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
    end)

    local entities = list.Get('SpawnableEntities')
    local customIcons = list.Get('ContentCategoryIcons')

    for k, ent in pairs(entities) do
        local btn = self:AddItem(ent.PrintName, ent.Category, ent, nil, customIcons[ent.Category] or 'icon16/bricks.png')
        btn.mat = Material(ent.IconOverride or 'entities/' .. ent.ClassName .. '.png')
    end
end

vgui.Register('NewSpawnMenu.Tabs.Entities', PANEL, 'NewSpawnMenu.Content')

NewSpawnMenu.CreateTab(3, '#spawnmenu.category.entities', 'icon16/bricks.png', 'NewSpawnMenu.Tabs.Entities')
