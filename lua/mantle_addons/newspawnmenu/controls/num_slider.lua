local controls = NewSpawnMenu.controls

function controls.NumSlider(panel, label, convar, min, max, decimals)
    local slider = vgui.Create('MantleSlideBox')
    slider:SetRange(min, max, decimals)
    slider:SetConvar(convar)
    slider:SetText(language.GetPhrase(label))

    return panel:AddPanel(slider)
end
