local controls = NewSpawnMenu.controls

function controls.Help(panel, text)
    local ctrl, label = controls.textPanel(panel, language.GetPhrase(text), controls.controlFont(16), Mantle.color.gray, 'center')

    ctrl.Paint = function(_, w, h)
        RNDX.Rect(0, 0, w, h)
            :Rad(14)
            :Color(Mantle.color.panel_alpha[2])
            :Shape(RNDX.SHAPE_IOS)
        :Draw()
    end

    ctrl.SetText = function(_, t)
        label:SetText(t)
        label:InvalidateTextLayout()
        ctrl.Fit()
    end

    return panel:AddPanel(ctrl)
end
