local controls = NewSpawnMenu.controls

function controls.ListBox(panel, data)
    if data.height then
        local ctrl = vgui.Create('DListView')
        ctrl:SetMultiSelect(false)
        ctrl:AddColumn(data.label or 'unknown')
        ctrl:SetTall(data.height)

        if data.options then
            for k, v in pairs(data.options) do
                local line = ctrl:AddLine(k)
                line.data = v

                for cvar, val in pairs(line.data) do
                    if GetConVarString(cvar) == tostring(val) then
                        line:SetSelected(true)
                    end
                end
            end
        end

        ctrl:SortByColumn(1, false)

        function ctrl:OnRowSelected(LineID, Line)
            for cvar, val in pairs(Line.data) do
                RunConsoleCommand(cvar, val)
            end
        end

        return panel:AddPanel(ctrl)
    end

    return controls.ComboBoxMulti(panel, data.label, data.options)
end
