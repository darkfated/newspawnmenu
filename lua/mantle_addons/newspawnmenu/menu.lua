local function CreateMenu()
    local w, h = Mantle.func.sw, Mantle.func.sh
    local menuW, menuH
    if w < 1600 then
        menuW, menuH = w, h
    else
        menuW, menuH = w * 0.9, h * 0.85
    end

    NewSpawnMenu.menu = vgui.Create('EditablePanel')
    NewSpawnMenu.menu:SetSize(menuW, menuH)
    NewSpawnMenu.menu:Center()
    NewSpawnMenu.menu:MakePopup()
    NewSpawnMenu.menu:SetKeyBoardInputEnabled(true)
    NewSpawnMenu.menu.Paint = nil

    local main = vgui.Create('NewSpawnMenu.Main', NewSpawnMenu.menu)
    main:Dock(FILL)

    local tools = vgui.Create('NewSpawnMenu.Tools', NewSpawnMenu.menu)
    tools:Dock(RIGHT)
    tools:DockMargin(6, 0, 0, 0)
    tools:SetWide(menuW * 0.35)
end

hook.Add('OnSpawnMenuOpen', 'NewSpawnMenu', function()
    if IsValid(NewSpawnMenu.menu) then
        NewSpawnMenu.menu:SetVisible(true)
    else
        CreateMenu()
    end

    return false
end)

hook.Add('OnSpawnMenuClose', 'NewSpawnMenu', function()
    if IsValid(NewSpawnMenu.menu) then
        NewSpawnMenu.menu:SetVisible(false)
        -- NewSpawnMenu.menu:Remove()
    end

    return false
end)
