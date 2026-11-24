local controls = NewSpawnMenu.controls

function controls.TextEntry(panel, strLabel, strConVar)
    local entry = vgui.Create('MantleEntry')

    if strLabel and strLabel != '' then
        entry:SetTitle(language.GetPhrase(strLabel))
    end

    if strConVar and strConVar != '' then
        local convar = GetConVar(strConVar)
        if convar then
            entry:SetValue(convar:GetString())
        end

        entry.action = function(text)
            RunConsoleCommand(strConVar, tostring(text or ''))
        end
    end

    panel:AddPanel(entry)

    return entry.textEntry, entry
end
