local convar_newspawnmenu_on = CreateClientConVar('newspawnmenu_on', 1, true, false)

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
    NewSpawnMenu.menu.Paint = nil
    NewSpawnMenu.menu.Focus = nil
    NewSpawnMenu.menu.HangOpen = nil

    function NewSpawnMenu.menu:Close()
        if NewSpawnMenu.menu.HangOpen then
            NewSpawnMenu.menu.HangOpen = false
            return
        end

        RememberCursorPosition()

        NewSpawnMenu.menu:SetVisible(false)
        -- NewSpawnMenu.menu:Remove()
    end

    function NewSpawnMenu.menu:OnKeyCodePressed(key)
        if key == KEY_F1 then
            self:Close()
        end
    end

    function NewSpawnMenu.menu:StartFocus(pan)
        self.Focus = pan
        self.HangOpen = true
        self:SetKeyboardInputEnabled(true)
    end

    function NewSpawnMenu.menu:EndFocus(pan)
        if self.Focus != pan then return end
        self:SetKeyboardInputEnabled(false)
    end

    local main = vgui.Create('NewSpawnMenu.Main', NewSpawnMenu.menu)
    main:Dock(FILL)

    local tools = vgui.Create('NewSpawnMenu.Tools', NewSpawnMenu.menu)
    tools:Dock(RIGHT)
    tools:DockMargin(6, 0, 0, 0)
    tools:SetWide(menuW * 0.35)
end

hook.Add('OnSpawnMenuOpen', 'NewSpawnMenu', function()
    if !convar_newspawnmenu_on:GetBool() then
        return
    end

    if IsValid(NewSpawnMenu.menu) then
        NewSpawnMenu.menu:SetVisible(true)
    else
        CreateMenu()
    end

    RestoreCursorPosition()

    return false
end)

hook.Add('OnSpawnMenuClose', 'NewSpawnMenu', function()
    if IsValid(NewSpawnMenu.menu) then
        NewSpawnMenu.menu:Close()
    end
end)

hook.Add('OnTextEntryGetFocus', 'NewSpawnMenu', function(pan)
    if !convar_newspawnmenu_on:GetBool() then
        return
    end

	if IsValid(NewSpawnMenu.menu) and IsValid(pan) and pan:HasParent(NewSpawnMenu.menu) then
		NewSpawnMenu.menu:StartFocus(pan)
	end
end)

hook.Add('OnTextEntryLoseFocus', 'NewSpawnMenu', function(pan)
    if !convar_newspawnmenu_on:GetBool() then
        return
    end

	if IsValid(NewSpawnMenu.menu) and IsValid(pan) and pan:HasParent(NewSpawnMenu.menu) then
		NewSpawnMenu.menu:EndFocus(pan)
	end
end)
