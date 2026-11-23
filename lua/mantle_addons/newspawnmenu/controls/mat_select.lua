local controls = NewSpawnMenu.controls

function controls.MatSelect(panel, convar, options, autoStretch, iWidth, iHeight)
    local MatSelect = vgui.Create('MatSelect')
    MatSelect:SetConVar(convar)

    if autoStretch != nil then
        MatSelect:SetAutoHeight(autoStretch)
    end

    MatSelect.List.Paint = nil

    if iWidth != nil then
        MatSelect:SetItemWidth(iWidth)
    end

    if iHeight != nil then
        MatSelect:SetItemHeight(iHeight)
    end

    if options != nil then
        for k, v in pairs(options) do
            local nam = isnumber(k) and v or k
            MatSelect:AddMaterial(nam, v)
        end
    end

    return panel:AddPanel(MatSelect)
end
