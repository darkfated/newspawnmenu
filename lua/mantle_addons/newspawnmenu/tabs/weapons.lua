local PANEL = {}
local math_floor = math.floor

function PANEL:Init()
    self:AddFunc(function(tabl)
        RunConsoleCommand('gm_giveswep', tabl.ClassName)
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

        if btn.mat then
            render.PushFilterMag(TEXFILTER.ANISOTROPIC)
            render.PushFilterMin(TEXFILTER.ANISOTROPIC)
                RNDX().Rect(x, y, scaledW, scaledH)
                    :Rad(24)
                    :Material(btn.mat)
                    :Shape(RNDX.SHAPE_IOS)
                :Draw()
            render.PopFilterMin()
            render.PopFilterMag()
        end

        RNDX().Rect(0, h - fontI * 2, w, fontI * 2)
            :Radii(0, 0, 24, 24)
            :Color(Mantle.color.panel_alpha[2])
            :Shape(RNDX.SHAPE_IOS)
        :Draw()
        draw.SimpleText(tabl.PrintName, textFont, w * 0.5, h - fontI * 0.5 - 1, Mantle.color.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
    end)

    local weps = list.Get('Weapon')
    local customIcons = list.Get('ContentCategoryIcons')

    for k, wep in pairs(weps) do
        if !wep.Spawnable then
            continue
        end

        local btn = self:AddItem(wep.PrintName, wep.Category, wep, nil, customIcons[wep.Category] or 'icon16/gun.png')

        local matName = wep.IconOverride or 'entities/' .. wep.ClassName .. '.png'
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

vgui.Register('NewSpawnMenu.Tabs.Weapons', PANEL, 'NewSpawnMenu.Content')

NewSpawnMenu.CreateTab(2, '#spawnmenu.category.weapons', 'icon16/gun.png', 'NewSpawnMenu.Tabs.Weapons')
