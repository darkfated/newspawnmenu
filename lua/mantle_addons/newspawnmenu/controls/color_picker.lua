local controls = NewSpawnMenu.controls

local function convarInt(name, fallback)
    local convar = name and GetConVar(name)
    return convar and convar:GetInt() or fallback
end

local function setConVar(name, value)
    if name then RunConsoleCommand(name, tostring(value)) end
end

local function getColor(r, g, b, a)
    return Color(
        convarInt(r, 0),
        convarInt(g, 0),
        convarInt(b, 0),
        convarInt(a, 255)
    )
end

function controls.ColorPicker(panel, label, r, g, b, a)
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
            :Color(getColor(r, g, b, a))
        :Draw()
    end

    swatch.OnMousePressed = function()
        local colorSet = getColor(r, g, b, a)

        Mantle.ui.color_picker(function(col)
            setConVar(r, col.r)
            setConVar(g, col.g)
            setConVar(b, col.b)
            if a then setConVar(a, col.a) end
        end, colorSet)

        local frame = Mantle.ui.menu_color_picker
        frame:SetParent(NewSpawnMenu.menu)
        frame:DisableCloseBtn()
        frame:SetDraggable(false)
        frame.header:SetCursor('arrow')
        frame:SetZPos(100)
        frame:Center()
    end

    local _, wrapper = controls.addLabeledControl(panel, swatch, label, 34)

    return wrapper
end
