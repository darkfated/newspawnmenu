local controls = NewSpawnMenu.controls

local function convarInt(name, fallback)
    local convar = name and GetConVar(name)
    return convar and convar:GetInt() or fallback
end

local function setConVar(name, value)
    if name then RunConsoleCommand(name, tostring(value)) end
end

function controls.ColorPicker(panel, label, r, g, b, a)
    local function getColor()
        return Color(
            convarInt(r, 0),
            convarInt(g, 0),
            convarInt(b, 0),
            convarInt(a, 255)
        )
    end

    local swatch = vgui.Create('DPanel')
    swatch:SetCursor('hand')
    swatch:SetMouseInputEnabled(true)

    swatch.Paint = function(_, w, h)
        RNDX.Rect(0, 0, w, h)
            :Rad(controls.metrics.radius)
            :Color(Mantle.color.window_shadow)
            :Shadow(4, 2)
        :Draw()

        RNDX.Rect(0, 0, w, h)
            :Rad(controls.metrics.radius)
            :Color(getColor())
        :Draw()
    end

    swatch.OnMousePressed = function()
        local colorSet = getColor()

        Mantle.ui.color_picker(function(col)
            setConVar(r, col.r)
            setConVar(g, col.g)
            setConVar(b, col.b)
            if a then setConVar(a, col.a) end
        end, colorSet)
    end

    return panel:AddPanel(controls.labeledControl(label, swatch, 34))
end
