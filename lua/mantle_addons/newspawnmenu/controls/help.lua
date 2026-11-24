local controls = NewSpawnMenu.controls

function controls.Help(panel, text)
    local ctrl = vgui.Create('NewSpawnMenu.HelpLabel')
    ctrl:SetText(language.GetPhrase(text))

    return panel:AddPanel(ctrl)
end
