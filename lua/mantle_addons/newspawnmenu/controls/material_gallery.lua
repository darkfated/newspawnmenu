local controls = NewSpawnMenu.controls

function controls.MaterialGallery(panel, data)
    local ctrl = vgui.Create('MatSelect')
    controls.stylePicker(ctrl)
    ctrl:SetItemWidth(data.width or 32)
    ctrl:SetItemHeight(data.height or 32)
    ctrl:SetNumRows(data.rows or 4)
    ctrl:SetConVar(data.convar)

    if data.options then
        for name, tab in pairs(data.options) do
            local infoTable = table.Copy(tab)
            local mat = infoTable.material
            local value = infoTable.value

            infoTable.material = nil
            infoTable.value = nil

            ctrl:AddMaterialEx(name, mat, value, infoTable)
        end
    end

    return panel:AddPanel(ctrl)
end
