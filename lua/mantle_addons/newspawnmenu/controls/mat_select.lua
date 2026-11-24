local controls = NewSpawnMenu.controls

function controls.MatSelect(panel, convar, options, autoStretch, iWidth, iHeight)
    local ctrl = vgui.Create('MatSelect')
    ctrl:SetConVar(convar)
    controls.stylePicker(ctrl)

    if autoStretch != nil then
        ctrl:SetAutoHeight(autoStretch)
    end

    if iWidth != nil then
        ctrl:SetItemWidth(iWidth)
    end

    if iHeight != nil then
        ctrl:SetItemHeight(iHeight)
    end

    if options != nil then
        for k, v in pairs(options) do
            local nam = isnumber(k) and v or k
            ctrl:AddMaterial(nam, v)
        end
    end

    return panel:AddPanel(ctrl)
end
