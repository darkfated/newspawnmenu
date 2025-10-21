-- clear
function NewSpawnMenu.PanelPaint(w, h)
    RNDX().Rect(0, 0, w, h)
        :Rad(24)
        :Blur(2, 10)
        :Shape(SHAPE_IOS)
    :Draw()

    RNDX().Rect(0, 0, w, h)
        :Rad(24)
        :Color(Mantle.color.background_alpha)
        :Shape(SHAPE_IOS)
    :Draw()
end

hook.Add('HUDPaint', 'NewSpawnMenu', function()
    if IsValid(NewSpawnMenu.menu) and NewSpawnMenu.menu:IsVisible() then
        RNDX().Rect(0, 0, Mantle.func.sw, Mantle.func.sh)
            :Color(Mantle.color.background_alpha)
        :Draw()

        return false
    end
end)

hook.Add('HUDShouldDraw', 'NewSpawnMenu', function(elem)
    if elem != 'CHudHealth' then
        return
    end

    if IsValid(NewSpawnMenu.menu) and NewSpawnMenu.menu:IsVisible() then
        RNDX().Rect(0, 0, Mantle.func.sw, Mantle.func.sh)
            :Color(Mantle.color.background_alpha)
        :Draw()

        return false
    end
end)
