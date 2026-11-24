local controls = NewSpawnMenu.controls

local function addCheckbox(panel, values)
    local ctrl = controls.CheckBox(panel, values.label or 'Untitled', values.command)

    if values.help then
        controls.ControlHelp(panel, (values.label or 'Untitled') .. '.help')
    end

    return ctrl
end

local function addSlider(panel, values)
    local decimals = 0
    if values.type and string.lower(values.type) == 'float' then decimals = 2 end

    local ctrl = controls.NumSlider(
        panel,
        values.label or 'Untitled',
        values.command,
        values.min or 0,
        values.max or 100,
        decimals
    )

    if values.help then
        controls.ControlHelp(panel, (values.label or 'Untitled') .. '.help')
    end

    return ctrl
end

local function addListBox(panel, values)
    if values.menubutton == 1 or values.menubutton == '1' then return end

    return controls.ListBox(panel, values)
end

local handlers = {
    header = function(panel, values)
        if values.description then
            return controls.Help(panel, values.description)
        end
    end,
    textbox = function(panel, values)
        return controls.TextEntry(panel, values.label or 'Untitled', values.command)
    end,
    label = function(panel, values)
        return controls.ControlHelp(panel, values.text)
    end,
    checkbox = addCheckbox,
    toggle = addCheckbox,
    slider = addSlider,
    propselect = function(panel, values)
        return controls.PropSelect(panel, values.label, values.convar, values.options or {}, values.height)
    end,
    matselect = function(panel, values)
        return controls.MatSelect(panel, values.convar, values.options, values.autostretch, values.width, values.height)
    end,
    ropematerial = function(panel, values)
        return controls.RopeSelect(panel, values.convar)
    end,
    button = function(panel, values)
        return controls.Button(panel, values.label or values.text or 'No Label', values.command)
    end,
    numpad = function(panel, values)
        return controls.KeyBinder(panel, values.label, values.command, values.label2, values.command2)
    end,
    color = function(panel, values)
        return controls.ColorPicker(panel, values.label, values.red, values.green, values.blue, values.alpha)
    end,
    listbox = controls.ListBox,
    combobox = addListBox,
    materialgallery = controls.MaterialGallery
}

function controls.AddControl(panel, control, data)
    local values = table.LowerKeyNames(data or {})
    local original = control
    local key = string.lower(control)

    local handler = handlers[key]
    if handler then
        return handler(panel, values)
    end

    local ctrl = vgui.Create(original, panel)
    if !ctrl then
        ctrl = vgui.Create(key, panel)
    end

    if ctrl then
        if ctrl.ControlValues then
            ctrl:ControlValues(values)
        end

        return panel:AddPanel(ctrl)
    end

    return nil
end
