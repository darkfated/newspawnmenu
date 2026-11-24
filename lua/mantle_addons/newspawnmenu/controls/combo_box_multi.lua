local controls = NewSpawnMenu.controls

function controls.ComboBoxMulti(panel, label, tabl)
    local combobox = vgui.Create('NewSpawnMenu.ComboBox')
    combobox:SetPlaceholder('')

    for name, data in pairs(tabl or {}) do
        combobox:AddChoice(name, data)
    end

    combobox.OnSelect = function(index, value, data)
        controls.applyConvarTable(data)
    end

    for index, choice in ipairs(combobox.choices or {}) do
        if controls.allConvarsMatch(choice.data) then
            combobox:SetValue(choice.text)
            break
        end
    end

    return controls.addLabeledControl(panel, combobox, label, controls.metrics.rowHeight)
end
