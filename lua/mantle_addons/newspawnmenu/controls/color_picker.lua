local controls = NewSpawnMenu.controls

function controls.ColorPicker(panel, label, r, g, b, a)
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

    return panel:AddPanel(controls.labeledControl(label, swatch, 34))
end
