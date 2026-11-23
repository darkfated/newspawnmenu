local controls = NewSpawnMenu.controls

local function addHeader(panel, data)
    if data.description then
        return controls.Help(panel, data.description)
    end
end

local function addTextbox(panel, data)
    return controls.TextEntry(panel, data.label or 'Untitled', data.command)
end

local function addLabel(panel, data)
    return controls.ControlHelp(panel, data.text)
end

local function addCheckbox(panel, data)
    local ctrl = controls.CheckBox(panel, data.label or 'Untitled', data.command)

    if data.help then
        controls.ControlHelp(panel, data.label .. '.help')
    end

    return ctrl
end

local function addSlider(panel, data)
    local decimals = 0

    if data.type and string.lower(data.type) == 'float' then
        decimals = 2
    end

    local ctrl = controls.NumSlider(
        panel,
        data.label or 'Untitled',
        data.command,
        data.min or 0,
        data.max or 100,
        decimals
    )

    if data.help then
        controls.ControlHelp(panel, data.label .. '.help')
    end

    return ctrl
end

local function addPropSelect(panel, data)
    return controls.PropSelect(panel, data.label, data.convar, data.options or {}, data.height)
end

local function addMatSelect(panel, data)
    return controls.MatSelect(panel, data.convar, data.options, data.autostretch, data.width, data.height)
end

local function addRopeMaterial(panel, data)
    return controls.RopeSelect(panel, data.convar)
end

local function addButton(panel, data)
    return controls.Button(panel, data.label or data.text or 'No Label', data.command)
end

local function addNumpad(panel, data)
    return controls.KeyBinder(panel, data.label, data.command, data.label2, data.command2)
end

local function addColor(panel, data)
    return controls.ColorPicker(panel, data.label, data.red, data.green, data.blue, data.alpha)
end

local handlers = {
    header = addHeader,
    textbox = addTextbox,
    label = addLabel,
    checkbox = addCheckbox,
    toggle = addCheckbox,
    slider = addSlider,
    propselect = addPropSelect,
    matselect = addMatSelect,
    ropematerial = addRopeMaterial,
    button = addButton,
    numpad = addNumpad,
    color = addColor,
    listbox = controls.ListBox,
    combobox = controls.ListBox,
    materialgallery = controls.MaterialGallery
}

function controls.AddControl(panel, control, data)
    local data = table.LowerKeyNames(data or {})
    local original = control
    local key = string.lower(control)

    local handler = handlers[key]
    if handler then
        return handler(panel, data)
    end

    local ctrl = vgui.Create(original, panel)
    if !ctrl then
        ctrl = vgui.Create(key, panel)
    end

    if ctrl then
        if ctrl.ControlValues then
            ctrl:ControlValues(data)
        end

        return panel:AddPanel(ctrl)
    end

    MsgN('UNHANDLED CONTROL: ', key)

    return nil
end
