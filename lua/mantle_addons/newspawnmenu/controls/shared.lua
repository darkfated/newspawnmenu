local controls = NewSpawnMenu.controls

local math_floor = math.floor

controls.metrics = {
    rowHeight = 32,
    titleHeight = 18,
    titleGap = 2,
    rowGap = 8,
    radius = 12,
    panelPad = 8
}

function controls.scale(value)
    local convar = GetConVar('newspawnmenu_scale')
    return value * (convar and convar:GetFloat() or 1)
end

function controls.controlFont(size)
    return 'Fated.' .. math_floor(controls.scale(size))
end

function controls.paintRounded(w, h, color)
    RNDX.Rect(0, 0, w, h)
        :Rad(controls.metrics.radius)
        :Color(color)
    :Draw()
end

function controls.paintPanel(w, h)
    controls.paintRounded(w, h, Mantle.color.panel_alpha[1])
end

function controls.paintField(w, h)
    controls.paintRounded(w, h, Mantle.color.focus_panel)
end

function controls.paintContainer(panel)
    panel.Paint = function(_, w, h)
        controls.paintPanel(w, h)
    end
end

function controls.stylePicker(panel)
    controls.paintContainer(panel)
    if IsValid(panel.List) then panel.List.Paint = nil end
end

function controls.allConvarsMatch(values)
    if !istable(values) then return false end

    for convar, value in pairs(values) do
        if GetConVarString(convar) != tostring(value) then return false end
    end

    return true
end

function controls.anyConvarMatches(values)
    if !istable(values) then return false end

    for convar, value in pairs(values) do
        if GetConVarString(convar) == tostring(value) then return true end
    end

    return false
end

function controls.applyConvarTable(values)
    if !istable(values) then return end

    for convar, value in pairs(values) do
        RunConsoleCommand(convar, tostring(value))
    end
end

function controls.title(label, parent)
    local title = vgui.Create('MantleText', parent)
    title:Dock(TOP)
    title:DockMargin(0, 0, 0, controls.metrics.titleGap)
    title:SetTall(controls.metrics.titleHeight)
    title:SetFont(controls.controlFont(14))
    title:SetColor(Mantle.color.text)
    title:SetAlign(TEXT_ALIGN_LEFT)
    title:SetVAlign('center')
    title.padding = 0
    title:SetText(label and language.GetPhrase(label) or '')

    return title
end

function controls.labeledControl(label, control, controlTall)
    controlTall = controlTall or controls.metrics.rowHeight

    if !label or label == '' then
        control:SetTall(controlTall)
        return control
    end

    local wrapper = vgui.Create('Panel')
    wrapper:SetTall(controlTall + controls.metrics.titleHeight + controls.metrics.titleGap)

    controls.title(label, wrapper)

    control:SetParent(wrapper)
    control:Dock(FILL)
    control:DockMargin(0, 0, 0, 0)

    return wrapper
end

function controls.addLabeledControl(panel, control, label, tall)
    local wrapper = controls.labeledControl(label, control, tall)
    panel:AddPanel(wrapper)

    return control, wrapper
end

function controls.helpLabel(panel, text, font)
    local ctrl = vgui.Create('NewSpawnMenu.HelpLabel')
    if font then ctrl:SetFont(font) end
    ctrl:SetText(language.GetPhrase(text or ''))

    return panel:AddPanel(ctrl)
end

function controls.createScrollContainer(panel)
    local sp = vgui.Create('MantleScrollPanel', panel)
    sp:Dock(FILL)
    sp:DockPadding(
        controls.metrics.panelPad,
        controls.metrics.panelPad,
        controls.metrics.panelPad,
        controls.metrics.panelPad
    )

    return sp
end

function controls.clearContainer(panel)
    if IsValid(panel.sp) then panel.sp:Clear() end
end

function controls.addPanel(panel, child)
    if !IsValid(child) or !IsValid(panel.sp) then return child end
    if child:GetParent() == panel.sp:GetCanvas() then return child end

    child:Dock(TOP)
    child:DockMargin(0, 0, 0, controls.metrics.rowGap)
    panel.sp:AddItem(child)

    return child
end

function controls.addItem(panel, left, right)
    if IsValid(left) then controls.addPanel(panel, left) end
    if IsValid(right) then controls.addPanel(panel, right) end
end
