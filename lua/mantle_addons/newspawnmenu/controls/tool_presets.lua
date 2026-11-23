local controls = NewSpawnMenu.controls

function controls.ToolPresets(panel, group, cvarlist)
    cvarlist = cvarlist or {}

    local preset = vgui.Create('ControlPresets', panel)
    preset:SetPreset(group)
    preset:AddOption('#preset.default', cvarlist)

    for cvar in pairs(cvarlist) do
        preset:AddConVar(cvar)
    end

    return panel:AddPanel(preset)
end
