local controls = NewSpawnMenu.controls

function controls.RopeSelect(panel, convar)
    local ctrl = vgui.Create('NSM.RopeMaterial')
    ctrl:SetConVar(convar)

    return panel:AddPanel(ctrl)
end
