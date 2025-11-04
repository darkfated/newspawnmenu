local PANEL = {}
local math_floor = math.floor

function PANEL:Init()
    self:DockPadding(8, 8, 8, 8)

    self.sp = vgui.Create('MantleScrollPanel', self)
    self.sp:Dock(FILL)
end

function PANEL:Paint(w, h)
    -- RNDX().Rect(0, 0, w, h)
    --     :Rad(32)
    --     :Color(Mantle.color.panel_alpha[2])
    --     :Shape(RNDX.SHAPE_IOS)
    -- :Draw()
end

function PANEL:AddPanel(pnl)
    if !IsValid(pnl) then
        return
    end

    pnl:SetParent(self.sp)
    pnl:Dock(TOP)
    pnl:DockMargin(0, 0, 0, 6)

    return pnl
end

function PANEL:AddItem(pnl)
    self:AddPanel(pnl)
end

function PANEL:Clear()
    -- Clear :)
end

function PANEL:Help(text)
    local panelLabel = vgui.Create('Panel')
    panelLabel:SetTall(110)
    panelLabel.Paint = function(_, w, h)
        RNDX().Rect(0, 0, w, h)
            :Rad(32)
            :Color(Mantle.color.panel_alpha[2])
            :Shape(RNDX.SHAPE_IOS)
        :Draw()
    end

    local textFont = 'Fated.' .. math_floor(16 * GetConVar('newspawnmenu_scale'):GetFloat())

    local label = vgui.Create('MantleText', panelLabel)
    label:Dock(FILL)
    label:SetText(language.GetPhrase(text))
    label:SetAlign(TEXT_ALIGN_CENTER)
    label:SetVAlign('center')
    label:SetFont(textFont)

    return self:AddPanel(panelLabel)
end

function PANEL:ToolPresets(group, cvarlist)

end

function PANEL:NumSlider(label, convar, min, max, decimals)
    local slider = vgui.Create('MantleSlideBox')
    slider:SetConvar(convar)
    slider:SetText(label)
    slider:SetRange(min, max, decimals)

    return self:AddPanel(slider)
end

function PANEL:KeyBinder(label1, convar1, label2, convar2)

end

function PANEL:Button(label, command)
    local btn = vgui.Create('MantleBtn')
    btn:SetTall(32)
    btn:SetTxt(label)
    btn.DoClick = function()
        RunConsoleCommand(command)
    end

    return self:AddPanel(btn)
end

function PANEL:CheckBox(label, convar)
    local checkbox = vgui.Create('MantleCheckBox')
    checkbox:SetTxt(label)
    checkbox:SetConvar(convar)

    return self:AddPanel(checkbox)
end

function PANEL:TextEntry(strLabel, strConVar)
    local entry = vgui.Create('MantleEntry')
    entry:SetTitle(strLabel)

    return self:AddPanel(checkbox)
end

function PANEL:ColorPicker(label, r, g, b, a)
    local convar_r = GetConVar(r):GetInt()
    local convar_g = GetConVar(g):GetInt()
    local convar_b = GetConVar(b):GetInt()
    local color_default
    if a then
        local convar_a = GetConVar(a):GetInt()
        color_default = Color(convar_r, convar_g, convar_b, convar_a)
    else
        color_default = Color(convar_r, convar_g, convar_b)
    end

    local colorBtn = vgui.Create('MantleBtn')
    colorBtn:SetTall(30)
    colorBtn:SetTxt(Mantle.lang.get('newspawnmenu', 'select_color'))
    colorBtn.DoClick = function()
        Mantle.ui.color_picker(function(col)
            local lp = LocalPlayer()
            lp:ConCommand(r .. ' ' .. col.r)
            lp:ConCommand(g .. ' ' .. col.g)
            lp:ConCommand(b .. ' ' .. col.b)
            if a then
                lp:ConCommand(a .. ' ' .. col.a)
            end
        end, color_default)
    end

    return self:AddPanel(colorBtn)
end

function PANEL:RopeSelect(convar)

end

function PANEL:MatSelect(convar, options, autoStretch, iWidth, iHeight)

end

function PANEL:PropSelect(label, convar, mdlList, height)

end

function PANEL:ComboBoxMulti(label, tabl)
    local combobox = vgui.Create('MantleComboBox')
    combobox:SetPlaceholder(label)

    for name, tabl in pairs(tabl) do
        combobox:AddChoice(name, tabl)
    end

    combobox.OnSelect = function(idx, text, data)
        for convar, value in pairs(data) do
            LocalPlayer():ConCommand(convar .. ' ' .. value)
        end
    end

    return self:AddPanel(combobox)
end

function PANEL:ControlHelp(text)
    local panelLabel = vgui.Create('Panel')
    panelLabel:SetTall(50)

    local label = vgui.Create('MantleText', panelLabel)
    label:Dock(FILL)
    label:DockMargin(0, 6, 0, 0)
    label:SetText(language.GetPhrase(text))
    label:SetAlign(TEXT_ALIGN_CENTER)
    label:SetVAlign('center')
    local textFont = 'Fated.' .. math_floor(15 * GetConVar('newspawnmenu_scale'):GetFloat())
    label:SetFont(textFont)

    return self:AddPanel(panelLabel)
end

PANEL.filter = function() end

function PANEL:ClearControls()
    -- Clear
end

function PANEL:AddControl(control, data)
    local data = table.LowerKeyNames(data or {})
    local original = control
    control = string.lower(control)

    if control == 'header' then
        if data.description then
            return self:Help(data.description)
        end

        return
    end

    if control == 'textbox' then
        local ctrl = self:TextEntry(data.label or 'Untitled', data.command)

        return ctrl
    end

    if control == 'label' then
        local ctrl = self:ControlHelp(data.text)

        return ctrl
    end

    if control == 'checkbox' or control == 'toggle' then
        local ctrl = self:CheckBox(data.label or 'Untitled', data.command)

        if data.help then
            self:ControlHelp(data.label .. '.help')
        end

        return ctrl
    end

    if control == 'slider' then
        local decimals = 0

        if data.type and string.lower(data.type) == 'float' then
            decimals = 2
        end

        local ctrl = self:NumSlider(
            data.label or 'Untitled',
            data.command,
            data.min or 0,
            data.max or 100,
            decimals
        )

        if data.help then
            self:ControlHelp(data.label .. '.help')
        end

        return ctrl
    end

    if control == 'button' then
        local ctrl = self:Button(data.label or data.text or 'No Label', data.command)

        return ctrl
    end

    if control == 'color' then
        local ctrl = self:ColorPicker(
            data.label,
            data.red,
            data.green,
            data.blue,
            data.alpha
        )

        return ctrl
    end

    if control == 'combobox' then
        local ctrl = self:ComboBoxMulti(data.label, data.options)

        return ctrl
    end

    if control == 'listbox' then
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

            self:AddPanel(ctrl)

            return ctrl
        else
            local ctrl = self:ComboBoxMulti(data.label, data.options)

            return ctrl
        end
    end

    if control == 'materialgallery' then
        local ctrl = vgui.Create('MatSelect', self)
        ctrl:SetItemWidth(data.width or 32)
        ctrl:SetItemHeight(data.height or 32)
        ctrl:SetConVar(data.convar or nil)

        if data.options then
            for name, tab in pairs(data.options) do
                ctrl:AddMaterial(name, tab.material or tab)
            end
        end

        self:AddPanel(ctrl)

        return ctrl
    end

    if control == 'ropematerial' then
        local ctrl = self:RopeSelect(data.convar)
        return ctrl
    end

    if control == 'propselect' then
        local ctrl = self:PropSelect(
            data.label,
            data.convar,
            data.options or {},
            data.height
        )

        return ctrl
    end

    if control == 'matselect' then
        local ctrl = self:MatSelect(
            data.convar,
            data.options,
            data.autostretch,
            data.width,
            data.height
        )

        return ctrl
    end

    if control == 'numpad' then
        local ctrl = self:KeyBinder(
            data.label,
            data.command,
            data.label2,
            data.command2
        )

        return ctrl
    end

    local ctrl = vgui.Create(original, self)
    if !ctrl then
        ctrl = vgui.Create(control, self)
    end

    if ctrl then
        if ctrl.ControlValues then
            ctrl:ControlValues(data)
        end

        self:AddPanel(ctrl)

        return ctrl
    end

    return nil
end

vgui.Register('NewSpawnMenu.ControlPanel', PANEL, 'EditablePanel')
