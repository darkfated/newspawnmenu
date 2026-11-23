local controls = NewSpawnMenu.controls

local math_floor = math.floor

function controls.controlFont(size)
    return 'Fated.' .. math_floor(size * GetConVar('newspawnmenu_scale'):GetFloat())
end

function controls.textPanel(owner, text, font, color, valign)
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

function controls.labeledControl(label, control, controlTall)
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
