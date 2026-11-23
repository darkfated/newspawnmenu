local controls = NewSpawnMenu.controls

function controls.Button(panel, label, command, ...)
    local args = { ... }

    local btn = vgui.Create('MantleBtn')
    btn:SetTall(32)
    btn:SetRadius(10)
    btn:SetTxt(language.GetPhrase(label))
    btn.DoClick = function()
        if command then
            RunConsoleCommand(command, unpack(args))
        end
    end

    return panel:AddPanel(btn)
end
