local controls = NewSpawnMenu.controls

function controls.TextEntry(panel, label, convar)
    local entry = vgui.Create('MantleEntry')

    if label and label != '' then
        entry:SetTitle(language.GetPhrase(label))
    end

    if convar and convar != '' then
        local cvar = GetConVar(convar)
        if cvar then
            entry:SetValue(cvar:GetString())
        end

        entry.action = function(text)
            RunConsoleCommand(convar, tostring(text or ''))
        end
    end

    panel:AddPanel(entry)

    return entry.textEntry, entry
end
