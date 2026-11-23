local controls = NewSpawnMenu.controls

local PANEL = {}

AccessorFunc(PANEL, 'm_bInitialized', 'Initialized')
AccessorFunc(PANEL, 'm_Name', 'Name')

function PANEL:Init()
    self:SetInitialized(false)

    self.sp = vgui.Create('MantleScrollPanel', self)
    self.sp:Dock(FILL)
    self.sp:DockPadding(0, 0, 0, 8)
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

function PANEL:ToolPresets(group, cvarlist)
    return controls.ToolPresets(self, group, cvarlist)
end

function PANEL:KeyBinder(label1, convar1, label2, convar2)
    return controls.KeyBinder(self, label1, convar1, label2, convar2)
end

function PANEL:ComboBoxMulti(label, tabl)
    return controls.ComboBoxMulti(self, label, tabl)
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
    return controls.AddControl(self, control, data)
end

vgui.Register('NewSpawnMenu.ControlPanel', PANEL, 'EditablePanel')
