local convar_blur = CreateClientConVar('newspawnmenu_blur', 1, true, false)
local convar_opt = CreateClientConVar('newspawnmenu_opt', 1, true, false)
local color_background = Color(0, 0, 0, 45)

local hideElements = {
    CHudHealth = true,
    CHudAmmo = true,
    CHudBattery = true
}

function NewSpawnMenu.PanelPaint(w, h)
    if convar_blur:GetBool() then
        RNDX.Rect(0, 0, w, h)
            :Rad(24)
            :KBlur(4, 2)
            :Shape(RNDX.SHAPE_IOS)
        :Draw()
    end

    RNDX.Rect(0, 0, w, h)
        :Rad(24)
        :Color(Mantle.color.background_alpha)
        :Shape(RNDX.SHAPE_IOS)
    :Draw()
end

hook.Add('HUDPaint', 'NewSpawnMenu', function()
    if IsValid(NewSpawnMenu.menu) and NewSpawnMenu.menu:IsVisible() then
        RNDX.Rect(0, 0, Mantle.func.sw, Mantle.func.sh)
            :Color(color_background)
        :Draw()

        return false
    end
end)

hook.Add('HUDShouldDraw', 'NewSpawnMenu', function(elem)
    if IsValid(NewSpawnMenu.menu) and NewSpawnMenu.menu:IsVisible() and hideElements[elem] then
        return false
    end
end)

NewSpawnMenu.convar.opt = convar_opt:GetBool()

cvars.AddChangeCallback('newspawnmenu_opt', function(_, _, newValue)
    NewSpawnMenu.convar.opt = newValue == '1' and true or false
end)
