local controls = NewSpawnMenu.controls

function controls.ControlHelp(panel, text)
    return panel:AddPanel(controls.textPanel(panel, language.GetPhrase(text), controls.controlFont(15), Mantle.color.gray, 'center'))
end
