local convar_newspawnmenu_on = CreateClientConVar('newspawnmenu_on', 1, true, false)
local convar_newspawnmenu_mode = CreateClientConVar('newspawnmenu_mode', 0, true, false)
local convar_newspawnmenu_scale = CreateClientConVar('newspawnmenu_scale', 1, true, false)
CreateClientConVar('newspawnmenu_itemname_left', 1, true, false)

local function defaultMenuSize(w, h)
    local border = GetConVar('spawnmenu_border')
    local marginX, marginY = 0, 0

    if w >= 1024 and h >= 768 then
        local value = border and border:GetFloat() or 0.1

        marginX = math.Clamp((w - 1024) * value, 25, 256)
        marginY = math.Clamp((h - 768) * value, 25, 256)
    end

    return w - marginX * 2, h - marginY * 2
end

function NewSpawnMenu.CreateMenu()
    local w, h = Mantle.func.sw, Mantle.func.sh
    local menuW, menuH = defaultMenuSize(w, h)

    local menuMode = convar_newspawnmenu_mode:GetInt()
    if menuMode == 2 then
        menuW = w * 0.5
    elseif menuMode == 1 then
        menuW = w * 0.7
    end

    local scaleMenu = convar_newspawnmenu_scale:GetFloat()
    menuW = menuW * scaleMenu
    menuH = menuH * scaleMenu
    if menuW > w then menuW = w end
    if menuH > h then menuH = h end

    local menu = vgui.Create('EditablePanel')
    NewSpawnMenu.menu = menu

    NewSpawnMenu.compatibility.bridge.bind()

    menu:SetSize(menuW, menuH)
    menu:Center()
    menu:MakePopup()
    menu:SetVisible(false)
    menu:SetKeyboardInputEnabled(false)
    menu.Paint = nil
    menu.HangOpen = nil

    NewSpawnMenu.api.menu.install(menu)

    if menuMode != 2 then
        local main = vgui.Create('NewSpawnMenu.Main', menu)
        menu.CreateMenu = main
        main:Dock(FILL)

        if menuMode == 1 then
            local btnReturnTools = vgui.Create('MantleBtn', main)
            btnReturnTools:SetPos(menuW - 54, 10)
            btnReturnTools:SetSize(44, 32)
            btnReturnTools:SetTxt('Tools')
            btnReturnTools.DoClick = function()
                RunConsoleCommand('newspawnmenu_mode', 0)
                RunConsoleCommand('newspawnmenu_remove')
            end
        end
    end

    if menuMode != 1 then
        local tools = vgui.Create('NewSpawnMenu.Tools', menu)
        menu.ToolMenu = tools
        tools:Dock(menuMode == 2 and FILL or RIGHT)
        tools:DockMargin(6, 0, 0, 0)
        tools:SetWide(menuW * 0.35)
    end

end

function NewSpawnMenu.OpenMenu()
    if !IsValid(NewSpawnMenu.menu) then
        if !hook.Run('SpawnMenuEnabled') then return end
        NewSpawnMenu.CreateMenu()
    end

    if IsValid(NewSpawnMenu.menu) then
        NewSpawnMenu.menu:Open()
        NewSpawnMenu.OpenThemeWizard()
    end
end

hook.Add('OnSpawnMenuOpen', 'NewSpawnMenu', function()
    if !convar_newspawnmenu_on:GetBool() then return end
    NewSpawnMenu.OpenMenu()
end)

cvars.AddChangeCallback('gmod_language', function()
    RunConsoleCommand('newspawnmenu_remove')
end, 'newspawnmenu_reload')

hook.Add('OnTextEntryGetFocus', 'NewSpawnMenu', function(panel)
    if !convar_newspawnmenu_on:GetBool() then return end

    if IsValid(NewSpawnMenu.menu) and IsValid(panel) and panel:HasParent(NewSpawnMenu.menu) then
        NewSpawnMenu.menu:StartFocus(panel)
    end
end)

hook.Add('OnTextEntryLoseFocus', 'NewSpawnMenu', function(panel)
    if !convar_newspawnmenu_on:GetBool() then return end

    if IsValid(NewSpawnMenu.menu) and IsValid(panel) and panel:HasParent(NewSpawnMenu.menu) then
        NewSpawnMenu.menu:EndFocus(panel)
    end
end)

net.Receive('NewSpawnMenu-F1', function()
    if !convar_newspawnmenu_on:GetBool() then return end

    if IsValid(NewSpawnMenu.menu) and NewSpawnMenu.menu:IsVisible() then
        NewSpawnMenu.menu:Close()
    else
        NewSpawnMenu.OpenMenu()
    end
end)
