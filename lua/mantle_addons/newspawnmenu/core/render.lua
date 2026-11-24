local convar_blur = CreateClientConVar('newspawnmenu_blur', 1, true, false)
local convar_opt = CreateClientConVar('newspawnmenu_opt', 1, true, false)
local color_background = Color(0, 0, 0, 45)
local ACRYLIC_TTL = 0.25

local acrylic
local acrylicTime = 0

local hideElements = {
    CHudHealth = true,
    CHudAmmo = true,
    CHudBattery = true
}

local function buildAcrylic()
    return {
        blur = { iterations = 4, radius = 4 },
        burn = { color = Mantle.color.theme, amount = 0.3 },
        tint = { color = Mantle.color.background_alpha, amount = 0.85 },
        noise = { intensity = 0.015, scale = 8 },
        fresnel = { color = Mantle.color.button, amount = 0.3, width = 1.4 }
    }
end

function NewSpawnMenu.PanelPaint(w, h)
    local alphaBg = convar_blur:GetBool() and Mantle.ui.convar.blur

    if alphaBg then
        local now = RealTime()
        if !acrylic or now - acrylicTime > ACRYLIC_TTL then
            acrylic = buildAcrylic()
            acrylicTime = now
        end

        RNDX.Rect(0, 0, w, h)
            :Rad(24)
            :Acrylic(acrylic)
            :Shape(RNDX.SHAPE_IOS)
        :Draw()

        return
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
end, 'NewSpawnMenu.Opt')
