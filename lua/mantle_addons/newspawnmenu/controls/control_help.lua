local controls = NewSpawnMenu.controls

function controls.ControlHelp(panel, text)
    local ctrl = vgui.Create('NewSpawnMenu.HelpLabel')
    ctrl:SetFont(controls.controlFont(15))
    ctrl:SetText(language.GetPhrase(text))

    return panel:AddPanel(ctrl)
end
