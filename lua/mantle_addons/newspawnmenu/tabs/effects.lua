local PANEL = {}

function PANEL:Init()
    self:AddFunc(function(tabl, itemIndex)
        if tabl.onclick then
            tabl.onclick()
            return
        end

        if !tabl.convar then
            return
        end

        local convarValue = GetConVar(tabl.convar):GetInt() == 1 and 0 or 1
        LocalPlayer():ConCommand(tabl.convar .. ' ' .. convarValue)
    end)

    self:AddFuncPaint(function(name, itemIndex, tabl, w, h, btn)
        local scale = btn.anim_scale
        local offset = (1 - scale) * 0.5
        local scaledW = w * scale
        local scaledH = h * scale
        local x = offset * w
        local y = offset * h

        if btn.icon then
            render.PushFilterMag(TEXFILTER.ANISOTROPIC)
            render.PushFilterMin(TEXFILTER.ANISOTROPIC)
                RNDX().Rect(x, y, scaledW, scaledH)
                    :Rad(32)
                    :Material(btn.icon)
                    :Shape(RNDX.SHAPE_IOS)
                :Draw()
            render.PopFilterMin()
            render.PopFilterMag()
        end

        if tabl.convar != nil then
            RNDX().Rect(x + 8, x + 8, 16, 16)
                :Rad(6)
                :Color(GetConVar(tabl.convar):GetInt() == 1 and Mantle.color.theme or Mantle.color.text)
            :Draw()
        end

        RNDX().Rect(0, h - 30, w, 30)
            :Radii(0, 0, 32, 32)
            :Color(Mantle.color.panel_alpha[2])
            :Shape(RNDX.SHAPE_IOS)
        :Draw()
        draw.SimpleText(name, 'Fated.12', w * 0.5, h - 10, Mantle.color.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
    end)

    local effs = list.Get('PostProcess')

    for name, effect in pairs(effs) do
        local btn = self:AddItem(name, effect.category, effect, nil, 'icon16/picture.png')
        if effect.icon then
            btn.icon = Material(effect.icon)
        end
    end
end

vgui.Register('NewSpawnMenu.Tabs.Effects', PANEL, 'NewSpawnMenu.Content')

NewSpawnMenu.CreateTab(6, '#spawnmenu.category.postprocess', 'icon16/picture.png', 'NewSpawnMenu.Tabs.Effects')
