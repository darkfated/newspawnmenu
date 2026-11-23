local controls = NewSpawnMenu.controls

function controls.ComboBoxMulti(panel, label, tabl)
    local combobox = vgui.Create('MantleComboBox')
    combobox:SetPlaceholder(label and language.GetPhrase(label) or '')
    combobox.AddOption = function(cb, text, data)
        cb:AddChoice(text, data)
    end

    for name, data in pairs(tabl or {}) do
        combobox:AddChoice(name, data)
    end

    combobox.OnSelect = function(_, _, data)
        if !istable(data) then return end

        for convar, value in pairs(data) do
            LocalPlayer():ConCommand(convar .. ' ' .. value)
        end
    end

    for _, choice in ipairs(combobox.choices) do
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

    local wrapper = controls.labeledControl(label, combobox, 32)
    panel:AddPanel(wrapper)

    return combobox, wrapper
end
