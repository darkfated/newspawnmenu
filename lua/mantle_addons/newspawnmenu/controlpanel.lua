local PANEL = {}

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
    pnl:SetParent(self.sp)
    pnl:Dock(TOP)

    return pnl
end

function PANEL:AddItem(left, right)

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

    local label = vgui.Create('MantleText', panelLabel)
    label:Dock(FILL)
    label:SetText(language.GetPhrase(text))
    label:SetAlign(TEXT_ALIGN_CENTER)
    label:SetVAlign('center')

    return self:AddPanel(panelLabel)
end

function PANEL:ToolPresets(group, cvarlist)

end

function PANEL:NumSlider(label, convar, min, max, decimals)

end

function PANEL:KeyBinder(label1, convar1, label2, convar2)

end

function PANEL:Button(label, command)

end

function PANEL:CheckBox(label, convar)

end

function PANEL:TextEntry(strLabel, strConVar)

end

function PANEL:ColorPicker(label, r,g,b,a)

end

function PANEL:RopeSelect(convar)

end

function PANEL:MatSelect(convar, options, autoStretch, iWidth, iHeight)

end

function PANEL:PropSelect(label, convar, mdlList, height)

end

function PANEL:ComboBoxMulti(label, list)

end

function PANEL:ControlHelp(text)

end

PANEL.matselect = PANEL.MatSelect
PANEL.filter = function() end

function PANEL:AddControl(control, data)
end

vgui.Register('NewSpawnMenu.ControlPanel', PANEL, 'EditablePanel')
