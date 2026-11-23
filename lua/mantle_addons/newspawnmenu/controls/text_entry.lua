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

        entry.action = function(_, text)
            LocalPlayer():ConCommand(strConVar .. ' ' .. text)
        end
    end

    local ctrl = panel:AddPanel(entry)
    ctrl:DockMargin(6, 0, 6, 8)

    return entry.textEntry, entry
end
