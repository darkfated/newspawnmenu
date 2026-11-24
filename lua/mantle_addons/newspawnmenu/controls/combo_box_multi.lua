local controls = NewSpawnMenu.controls

function controls.ComboBoxMulti(panel, label, tabl)
    local combobox = vgui.Create('NewSpawnMenu.ComboBox')
    combobox:SetPlaceholder('')

    for name, data in pairs(tabl or {}) do
        combobox:AddChoice(name, data)
    end

    combobox.OnSelect = function(index, value, data)
        if !istable(data) then return end

        for convar, convarValue in pairs(data) do
            RunConsoleCommand(convar, tostring(convarValue))
        end
    end

    for index, choice in ipairs(combobox.choices or {}) do
        if !istable(choice.data) then continue end

        local match = true
        for convar, value in pairs(choice.data) do
            if GetConVarString(convar) != tostring(value) then
                match = false
                break
            end
        end

        if match then
            combobox:SetValue(choice.text)
            break
        end
    end

    local wrapper = controls.labeledControl(label, combobox, controls.metrics.rowHeight)
    panel:AddPanel(wrapper)

    return combobox, wrapper
end
