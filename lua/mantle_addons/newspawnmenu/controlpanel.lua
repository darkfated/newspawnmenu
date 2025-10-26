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
    if !IsValid(pnl) then
        return
    end

    pnl:SetParent(self.sp)
    pnl:Dock(TOP)
    pnl:DockMargin(0, 0, 0, 6)

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
    entry:SetValue('Тестовое поле')

    function entry:SetUpdateOnType()
    end

    return self:AddPanel(entry)
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
    colorBtn:SetTxt('Выберете цвет')
    colorBtn.DoClick = function()
        Mantle.ui.color_picker(function(col)
            local lp = LocalPlayer()
            lp:ConCommand(r .. ' ' .. col.r)
            lp:ConCommand(g .. ' ' .. col.g)
            lp:ConCommand(b .. ' ' .. col.b)
            if a then
                lp:ConCommand(a .. ' ' .. col.a)
            end

            color_default = col
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

function PANEL:ComboBoxMulti(label, list)

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
    label:SetFont('Fated.15')

    return self:AddPanel(panelLabel)
end

PANEL.filter = function() end

function PANEL:AddControl(control, data)

end

vgui.Register('NewSpawnMenu.ControlPanel', PANEL, 'EditablePanel')
