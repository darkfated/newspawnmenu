local PANEL = {}

function PANEL:Init()
    self:SetItemWidth(0.14)
    self:SetItemHeight(0.3)
    self:SetAutoHeight(true)
    self.List.Paint = nil

    local mats = list.Get('RopeMaterials')

    for k, v in pairs(mats) do
        self:AddMaterial(k, v)
    end
end

function PANEL:Paint(w, h)
    RNDX.Rect(0, 0, w, h)
        :Rad(12)
        :Color(Mantle.color.panel_alpha[1])
    :Draw()
end

vgui.Register('NSM.RopeMaterial', PANEL, 'MatSelect')


local PANEL = {}

AccessorFunc(PANEL, 'm_ConVar1', 'ConVar1')
AccessorFunc(PANEL, 'm_ConVar2', 'ConVar2')

local function paintBtn(btn)
    btn:SetFont('Fated.16')
    btn:SetTextColor(Mantle.color.gray)
    btn.Paint = function(_, w, h)
        RNDX.Rect(0, 0, w, h)
            :Rad(12)
            :Color(Mantle.color.panel_alpha[1])
        :Draw()
    end
end

function PANEL:Init()
    self.NumPad1 = vgui.Create('DBinder', self)
    paintBtn(self.NumPad1)
    self.Label1 = vgui.Create('DLabel', self)
    self.Label1:SetFont('Fated.16')
    self.Label1:SetTextColor(Mantle.color.text)
    self.Label1:SetDark(true)

    self.NumPad2 = vgui.Create('DBinder', self)
    paintBtn(self.NumPad2)
    self.Label2 = vgui.Create('DLabel', self)
    self.Label2:SetFont('Fated.16')
    self.Label2:SetTextColor(Mantle.color.text)
    self.Label2:SetDark(true)

    self:SetHeight(200)
end

function PANEL:SetLabel1(txt)
    if !txt then return end
    self.Label1:SetText(txt)
end

function PANEL:SetLabel2(txt)
    if !txt then return end
    self.Label2:SetText(txt)
end

function PANEL:SetConVar1(cvar)
    self.NumPad1:SetConVar(cvar)
    self.m_ConVar1 = cvar
end

function PANEL:SetConVar2(cvar)
    self.NumPad2:SetConVar(cvar)
    self.m_ConVar2 = cvar
end

function PANEL:GetValue1()
    if !self.m_ConVar1 or !IsValid(self.NumPad1) then return KEY_NONE end
    return self.NumPad1:GetValue()
end

function PANEL:GetValue2()
    if !self.m_ConVar2 or !IsValid(self.NumPad2) then return KEY_NONE end
    return self.NumPad2:GetValue()
end

function PANEL:PerformLayout()
    self:SetTall(80)

    self.NumPad1:InvalidateLayout(true)
    self.NumPad1:SetSize(100, 50)

    if self.m_ConVar2 then
        self.NumPad2:InvalidateLayout(true)
        self.NumPad2:SetSize(100, 50)
    end

    if !self.m_ConVar2 then
        self.Label1:SizeToContents()

        self.NumPad2:SetVisible(false)
        self.Label2:SetVisible(false)

        self.NumPad1:CenterHorizontal(0.5)
        self.NumPad1:AlignTop(30)

        self.Label1:CenterHorizontal()
        self.Label1:AlignTop(0)
    else
        self.Label1:SizeToContents()
        self.Label2:SizeToContents()

        self.NumPad2:SetVisible(true)
        self.Label2:SetVisible(true)

        self.NumPad1:CenterHorizontal(0.25)
        self.Label1:CenterHorizontal(0.25)
        self.NumPad1:AlignTop(30)

        self.NumPad2:CenterHorizontal(0.75)
        self.Label2:CenterHorizontal(0.75)
        self.NumPad2:AlignTop(30)
        self.Label2:AlignTop(0)
    end
end

vgui.Register('NSM.CtrlNumPad', PANEL, 'Panel')


local PANEL = {}
local math_floor = math.floor

AccessorFunc(PANEL, 'm_bInitialized', 'Initialized')
AccessorFunc(PANEL, 'm_Name', 'Name')

local function controlFont(size)
    return 'Fated.' .. math_floor(size * GetConVar('newspawnmenu_scale'):GetFloat())
end

local function textPanel(owner, text, font, color, valign)
    local panel = vgui.Create('Panel')

    local label = vgui.Create('MantleText', panel)
    label:Dock(FILL)
    label:SetText(text)
    label:SetFont(font)
    label:SetColor(color)
    label:SetAlign(TEXT_ALIGN_CENTER)
    label:SetVAlign(valign or 'center')

    local function fit(useW)
        local pw = useW or panel:GetWide()
        if pw < 40 then return end

        local ml, mt, mr, mb = label:GetDockMargin()
        local padding = label.padding or 6

        label:SetSize(math.max(1, pw - ml - mr), 10000)
        label:InvalidateTextLayout()
        label:PerformLayout()

        local lines = label._lines and #label._lines or 1
        local lineH = label._lineH or 16
        local tall = math.max(34, lines * lineH + padding * 2 + mt + mb)

        label:SetTall(math.max(1, tall - mt - mb))
        panel:SetTall(tall)
    end

    panel.Fit = fit

    local lastFitW = 0
    panel.OnSizeChanged = function(_, w, h)
        if w < 40 or w == lastFitW then return end
        lastFitW = w
        fit()
    end

    fit(owner:GetWide())

    return panel, label
end

local function labeledControl(label, control, controlTall)
    if !label or label == '' then
        control:SetTall(controlTall)
        return control
    end

    local wrapper = vgui.Create('Panel')
    wrapper:SetTall(controlTall + 24)

    local title = vgui.Create('DPanel', wrapper)
    title:Dock(TOP)
    title:DockMargin(0, 0, 0, 6)
    title:SetTall(18)
    title.Paint = function(_, w, h)
        draw.SimpleText(language.GetPhrase(label), 'Fated.18', 0, 0, Mantle.color.text)
    end

    control:SetParent(wrapper)
    control:Dock(FILL)
    control:DockMargin(6, 0, 6, 0)

    return wrapper
end

function PANEL:Init()
    self:SetInitialized(false)

    self.sp = vgui.Create('MantleScrollPanel', self)
    self.sp:Dock(FILL)
    self.sp:DockPadding(0, 0, 0, 10)
end

function PANEL:ClearControls()
    self.sp:Clear()
end

function PANEL:Clear()
    self.sp:Clear()
end

function PANEL:GetEmbeddedPanel()
    return self
end

function PANEL:AddPanel(pnl)
    if !IsValid(pnl) then return end

    if pnl:GetParent() == self.sp:GetCanvas() then
        return pnl
    end

    pnl:Dock(TOP)
    pnl:DockMargin(0, 0, 0, 8)
    self.sp:AddItem(pnl)

    return pnl
end

function PANEL:AddItem(pnl)
    return self:AddPanel(pnl)
end

function PANEL:Help(text)
    local panel, label = textPanel(self, language.GetPhrase(text), controlFont(16), Mantle.color.gray, 'center')

    panel.Paint = function(_, w, h)
        RNDX.Rect(0, 0, w, h)
            :Rad(14)
            :Color(Mantle.color.panel_alpha[2])
            :Shape(RNDX.SHAPE_IOS)
        :Draw()
    end

    panel.SetText = function(_, t)
        label:SetText(t)
        label:InvalidateTextLayout()
        panel.Fit()
    end

    return self:AddPanel(panel)
end

function PANEL:ControlHelp(text)
    return self:AddPanel(textPanel(self, language.GetPhrase(text), controlFont(15), Mantle.color.gray, 'center'))
end

function PANEL:CheckBox(label, convar)
    local checkbox = vgui.Create('MantleCheckBox')
    checkbox:SetTxt(language.GetPhrase(label))
    checkbox:SetConvar(convar)

    local ctrl = self:AddPanel(checkbox)
    ctrl:DockMargin(6, 0, 6, 8)

    return ctrl
end

function PANEL:NumSlider(label, convar, min, max, decimals)
    local slider = vgui.Create('MantleSlideBox')
    slider:SetRange(min, max, decimals)
    slider:SetConvar(convar)
    slider:SetText(language.GetPhrase(label))

    return self:AddPanel(slider)
end

function PANEL:TextEntry(strLabel, strConVar)
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

    local ctrl = self:AddPanel(entry)
    ctrl:DockMargin(6, 0, 6, 8)

    return entry.textEntry, entry
end

function PANEL:Button(label, command, ...)
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

    return self:AddPanel(btn)
end

function PANEL:ColorPicker(label, r, g, b, a)
    local function getColor()
        local convar_r = GetConVar(r):GetInt()
        local convar_g = GetConVar(g):GetInt()
        local convar_b = GetConVar(b):GetInt()
        local col

        if a then
            local convar_a = GetConVar(a):GetInt()
            col = Color(convar_r, convar_g, convar_b, convar_a)
        else
            col = Color(convar_r, convar_g, convar_b)
        end

        return col
    end

    local swatch = vgui.Create('DPanel')
    swatch:SetCursor('hand')
    swatch:SetMouseInputEnabled(true)

    swatch.Paint = function(_, w, h)
        RNDX.Rect(0, 0, w, h)
            :Rad(12)
            :Color(Mantle.color.window_shadow)
            :Shadow(4, 2)
        :Draw()

        RNDX.Rect(0, 0, w, h)
            :Rad(12)
            :Color(getColor())
        :Draw()
    end

    swatch.OnMousePressed = function()
        local colorSet = getColor()

        Mantle.ui.color_picker(function(col)
            local lp = LocalPlayer()
            lp:ConCommand(r .. ' ' .. col.r)
            lp:ConCommand(g .. ' ' .. col.g)
            lp:ConCommand(b .. ' ' .. col.b)
            if a then
                lp:ConCommand(a .. ' ' .. col.a)
            end
        end, colorSet)
    end

    return self:AddPanel(labeledControl(label, swatch, 34))
end

function PANEL:RopeSelect(convar)
    local ctrl = vgui.Create('NSM.RopeMaterial')
    ctrl:SetConVar(convar)

    return self:AddPanel(ctrl)
end

function PANEL:MatSelect(convar, options, autoStretch, iWidth, iHeight)
    local MatSelect = vgui.Create('MatSelect')
    MatSelect:SetConVar(convar)

    if autoStretch != nil then
        MatSelect:SetAutoHeight(autoStretch)
    end

    MatSelect.List.Paint = nil

    if iWidth != nil then
        MatSelect:SetItemWidth(iWidth)
    end

    if iHeight != nil then
        MatSelect:SetItemHeight(iHeight)
    end

    if options != nil then
        for k, v in pairs(options) do
            local nam = isnumber(k) and v or k
            MatSelect:AddMaterial(nam, v)
        end
    end

    return self:AddPanel(MatSelect)
end

function PANEL:PropSelect(label, convar, mdlList, height)
    local PropSelect = vgui.Create('PropSelect')
    PropSelect:SetConVar(convar or '')
    PropSelect.List.Paint = nil
    PropSelect.Label:SetText(label or '')
    PropSelect.Height = height or 2

    local firstKey, firstVal = next(mdlList)

    if istable(firstVal) and isstring(firstVal.model) then
        local tmp = {}

        for k, v in SortedPairsByMemberValue(mdlList, 'model') do
            tmp[k] = v.model:lower() .. (v.skin or 0)
        end

        for k, v in SortedPairsByValue(tmp) do
            v = mdlList[k]
            PropSelect:AddModelEx(k, v.model, v.skin or 0)
        end
    else
        for k, v in SortedPairs(mdlList) do
            PropSelect:AddModel(k, v)
        end
    end

    return self:AddPanel(PropSelect)
end

function PANEL:ToolPresets(group, cvarlist)
end

function PANEL:KeyBinder(label1, convar1, label2, convar2)
    local binder = vgui.Create('NSM.CtrlNumPad')
    binder:SetLabel1(label1)
    binder:SetConVar1(convar1)

    if label2 != nil and convar2 != nil then
        binder:SetLabel2(label2)
        binder:SetConVar2(convar2)
    end

    return self:AddPanel(binder)
end

function PANEL:ComboBoxMulti(label, tabl)
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

    local wrapper = labeledControl(label, combobox, 32)
    self:AddPanel(wrapper)

    return combobox, wrapper
end

function PANEL:FillViaTable(Table)
    self:SetInitialized(true)
    self:SetName(Table.Text)

    if Table.ControlPanelBuildFunction then
        Table.ControlPanelBuildFunction(self)
    end
end

function PANEL:FillViaFunction(func)
    func(self)
end

function PANEL:ControlValues(data)
    if data.label then
        self:SetName(data.label)
    end
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
        return self:TextEntry(data.label or 'Untitled', data.command)
    end

    if control == 'label' then
        return self:ControlHelp(data.text)
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

    if control == 'propselect' then
        return self:PropSelect(data.label, data.convar, data.options or {}, data.height)
    end

    if control == 'matselect' then
        return self:MatSelect(data.convar, data.options, data.autostretch, data.width, data.height)
    end

    if control == 'ropematerial' then
        return self:RopeSelect(data.convar)
    end

    if control == 'button' then
        return self:Button(data.label or data.text or 'No Label', data.command)
    end

    if control == 'numpad' then
        return self:KeyBinder(data.label, data.command, data.label2, data.command2)
    end

    if control == 'color' then
        return self:ColorPicker(data.label, data.red, data.green, data.blue, data.alpha)
    end

    if control == 'combobox' then
        control = 'listbox'
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

            return self:AddPanel(ctrl)
        end

        return self:ComboBoxMulti(data.label, data.options)
    end

    if control == 'materialgallery' then
        local ctrl = vgui.Create('MatSelect')
        ctrl:SetItemWidth(data.width or 32)
        ctrl:SetItemHeight(data.height or 32)
        ctrl:SetNumRows(data.rows or 4)
        ctrl:SetConVar(data.convar or nil)
        ctrl.List.Paint = nil

        if data.options then
            for name, tab in pairs(data.options) do
                local infoTable = table.Copy(tab)
                local mat = infoTable.material
                local value = infoTable.value

                infoTable.material = nil
                infoTable.value = nil

                ctrl:AddMaterialEx(name, mat, value, infoTable)
            end
        end

        return self:AddPanel(ctrl)
    end

    local ctrl = vgui.Create(original, self)
    if !ctrl then
        ctrl = vgui.Create(control, self)
    end

    if ctrl then
        if ctrl.ControlValues then
            ctrl:ControlValues(data)
        end

        return self:AddPanel(ctrl)
    end

    MsgN('UNHANDLED CONTROL: ', control)

    return nil
end

vgui.Register('NewSpawnMenu.ControlPanel', PANEL, 'EditablePanel')
