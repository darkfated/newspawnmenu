local controls = NewSpawnMenu.controls

local PANEL = {}

AccessorFunc(PANEL, 'm_bInitialized', 'Initialized', FORCE_BOOL)
AccessorFunc(PANEL, 'm_Name', 'Name')

function PANEL:Init()
    self:SetInitialized(false)
    self:SetName('')
    self.sp = controls.createScrollContainer(self)
end

function PANEL:SetLabel(name)
    self:SetName(name)
end

function PANEL:GetLabel()
    return self:GetName()
end

function PANEL:Clear()
    controls.clearContainer(self)
end

PANEL.ClearControls = PANEL.Clear

function PANEL:GetEmbeddedPanel()
    return self
end

function PANEL:AddPanel(pnl)
    return controls.addPanel(self, pnl)
end

function PANEL:AddItem(left, right)
    controls.addItem(self, left, right)
end

function PANEL:Help(text)
    return controls.Help(self, text)
end

function PANEL:ControlHelp(text)
    return controls.ControlHelp(self, text)
end

function PANEL:CheckBox(label, convar)
    return controls.CheckBox(self, label, convar)
end

function PANEL:NumSlider(label, convar, min, max, decimals)
    return controls.NumSlider(self, label, convar, min, max, decimals)
end

function PANEL:TextEntry(strLabel, strConVar)
    return controls.TextEntry(self, strLabel, strConVar)
end

function PANEL:Button(label, command, ...)
    return controls.Button(self, label, command, ...)
end

function PANEL:ColorPicker(label, r, g, b, a)
    return controls.ColorPicker(self, label, r, g, b, a)
end

function PANEL:RopeSelect(convar)
    return controls.RopeSelect(self, convar)
end

function PANEL:MatSelect(convar, options, autoStretch, iWidth, iHeight)
    return controls.MatSelect(self, convar, options, autoStretch, iWidth, iHeight)
end

function PANEL:PropSelect(label, convar, mdlList, height)
    return controls.PropSelect(self, label, convar, mdlList, height)
end

function PANEL:ToolPresets(group, cvarlist, options)
end

function PANEL:KeyBinder(label1, convar1, label2, convar2)
    return controls.KeyBinder(self, label1, convar1, label2, convar2)
end

function PANEL:ComboBox(label, convar)
    return controls.ComboBox(self, label, convar)
end

function PANEL:ComboBoxMulti(label, tabl)
    return controls.ComboBoxMulti(self, label, tabl)
end

function PANEL:ListBox(label)
    return controls.ListBox(self, istable(label) and label or { label = label })
end

function PANEL:NumberWang(label, convar, min, max, decimals)
    return controls.NumberWang(self, label, convar, min, max, decimals)
end

function PANEL:PanelSelect()
    return controls.PanelSelect(self)
end

function PANEL:MaterialGallery(data)
    return controls.MaterialGallery(self, data)
end

function PANEL:AddControl(control, data)
    return controls.AddControl(self, control, data)
end

function PANEL:Rebuild()
end

function PANEL:GenerateExample()
end

function PANEL:FillViaTable(Table)
    Table = Table or {}
    self:SetInitialized(true)
    self:SetName(Table.Text)

    if Table.ControlPanelBuildFunction then
        Table.ControlPanelBuildFunction(self)
    end
end

function PANEL:FillViaFunction(func)
    if func then func(self) end
end

function PANEL:ControlValues(data)
    if data.label then
        self:SetName(data.label)
    end
end

vgui.Register('NewSpawnMenu.ControlPanel', PANEL, 'EditablePanel')
