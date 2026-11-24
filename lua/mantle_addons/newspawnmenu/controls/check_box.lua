local controls = NewSpawnMenu.controls

function controls.CheckBox(panel, label, convar)
    local checkbox = vgui.Create('MantleCheckBox')
    checkbox:SetTxt(language.GetPhrase(label))
    checkbox:SetConvar(convar)

    return controls.wrap(panel, checkbox)
end
