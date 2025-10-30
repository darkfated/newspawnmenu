
if SERVER then
    -- sukk prediction: https://wiki.facepunch.com/gmod/GM:PlayerButtonDown
    util.AddNetworkString('NewSpawnMenu-F1')

    hook.Add('PlayerButtonDown', 'NewSpawnMenu', function(pl, btn)
        if btn != KEY_F1 then return end

        local t = CurTime()
        if t - (pl.lastTimeF1 and pl.lastTimeF1 or 0) < 0.2 then return end
        pl.lastTimeF1 = t

        net.Start('NewSpawnMenu-F1')
        net.Send(pl)
    end)

    return
end

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

local hideElements = {
    CHudHealth = true,
    CHudAmmo = true,
    CHudBattery = true
}

hook.Add('HUDShouldDraw', 'NewSpawnMenu', function(elem)
    if IsValid(NewSpawnMenu.menu) and NewSpawnMenu.menu:IsVisible() and hideElements[elem] then
        return false
    end
end)
