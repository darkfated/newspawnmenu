local controls = NewSpawnMenu.controls

function controls.KeyBinder(panel, label1, convar1, label2, convar2)
    local binder = vgui.Create('NSM.CtrlNumPad')
    binder:SetLabel1(label1)
    binder:SetConVar1(convar1)

    if label2 != nil and convar2 != nil then
        binder:SetLabel2(label2)
        binder:SetConVar2(convar2)
    end

    return panel:AddPanel(binder)
end
