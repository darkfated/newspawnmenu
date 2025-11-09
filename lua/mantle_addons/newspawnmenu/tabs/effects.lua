local PANEL = {}
local math_floor = math.floor

function PANEL:Init()
    self.on = true

    self:AddFunc(function(tabl, itemIndex)
        if tabl.onclick then
            tabl.onclick()
            return
        end

        if tabl.convars then
            local isOn = true
            for k, v in pairs(tabl.convars) do
                if GetConVarString(k) != v.on then
                    isOn = false
                end
            end

            for k, v in pairs(tabl.convars) do
                if isOn then
                    RunConsoleCommand(k, v.off or '')
                else
                    RunConsoleCommand(k, v.on)
                end
            end

            return
        end

        if !tabl.convar then return end

        local convarValue = GetConVar(tabl.convar):GetInt() == 1 and 0 or 1
        LocalPlayer():ConCommand(tabl.convar .. ' ' .. convarValue)
    end)

    local fontI = math_floor(14 * GetConVar('newspawnmenu_scale'):GetFloat())
    local textFont = 'Fated.' .. fontI
    local isNameLeft = GetConVar('newspawnmenu_itemname_left'):GetBool()

    self:AddFuncPaint(function(name, itemIndex, tabl, w, h, btn)
        local scale = btn.anim_scale
        local offset = (1 - scale) * 0.5
        local scaledW = w * scale
        local scaledH = h * scale
        local x = offset * w
        local y = offset * h

        if btn.icon then
            if !NewSpawnMenu.convar.opt then
                RNDX().Rect(0, 0, w, h)
                    :Rad(32)
                    :Material(btn.icon)
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
                    :Material(btn.icon)
                    :Shape(RNDX.SHAPE_IOS)
                :Draw()
            render.PopFilterMin()
            render.PopFilterMag()
        end

        local isOn = true
        if tabl.convars then
            for k, v in pairs(tabl.convars) do
                if GetConVarString(k) != v.on then
                    isOn = false
                end
            end
        elseif tabl.convar then
            isOn = GetConVar(tabl.convar):GetInt() == 1
        else
            isOn = false
        end

        if !tabl.onclick then
            RNDX().Rect(x + 8, x + 8, 16, 16)
                :Rad(6)
                :Color(isOn and Mantle.color.theme or Mantle.color.text)
            :Draw()
        end

        RNDX().Rect(0, h - fontI * 2, w, fontI * 2)
            :Radii(0, 0, 24, 24)
            :Color(Mantle.color.panel_alpha[2])
            :Shape(RNDX.SHAPE_IOS)
        :Draw()
        if isNameLeft then
            draw.SimpleText(name, textFont, 8, h - fontI * 0.5 - 1, Mantle.color.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
        else
            draw.SimpleText(name, textFont, w * 0.5, h - fontI * 0.5 - 1, Mantle.color.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
        end
    end)

    local effs = list.Get('PostProcess')

    local function CreateEffect(name, effect)
        local btn = self:AddItem(name, effect.category, effect, nil, 'icon16/picture.png')
        if effect.icon then
            if effect.icon:StartWith('models/') then return end
            btn.icon = Material(effect.icon)
        end
    end

    local otherEffects = {}

    for name, effect in pairs(effs) do
        if effect.func then
            local pan = vgui.Create('Panel')
            effect.func(pan)

            for k, v in pairs(pan:GetChildren()) do
                local infoTable = {}
                v:ToTable(infoTable)
                infoTable = infoTable[1]
                infoTable.category = name
                CreateEffect(infoTable.name, infoTable)
            end

            pan:Remove()
            continue
        end

        CreateEffect(name, effect)
    end
end

vgui.Register('NewSpawnMenu.Tabs.Effects', PANEL, 'NewSpawnMenu.Content')

NewSpawnMenu.CreateTab(6, '#spawnmenu.category.postprocess', 'icon16/picture.png', 'NewSpawnMenu.Tabs.Effects')
