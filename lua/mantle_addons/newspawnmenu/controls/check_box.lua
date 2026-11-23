local controls = NewSpawnMenu.controls

function controls.CheckBox(panel, label, convar)
    local checkbox = vgui.Create('MantleCheckBox')
    checkbox:SetTxt(language.GetPhrase(label))
    checkbox:SetConvar(convar)

    local ctrl = panel:AddPanel(checkbox)
    ctrl:DockMargin(6, 0, 6, 8)

    return ctrl
end
