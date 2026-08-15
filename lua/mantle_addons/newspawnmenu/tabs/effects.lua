local PANEL = {}

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

    self:AddFuncPaint(function(name, itemIndex, tabl, w, h, btn)
        self:PaintItem(name, itemIndex, tabl, w, h, btn)

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
            RNDX.Rect(w - 24, 8, 16, 16)
                :Rad(6)
                :Color(isOn and Mantle.color.theme or Mantle.color.text)
            :Draw()
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
