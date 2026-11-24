local content = NewSpawnMenu.content

local creatorModes = {
    entity = 0,
    vehicle = 1,
    npc = 2,
    weapon = 3
}

local function addCopy(menu, class)
    if class == '' then return end

    menu:AddOption(language.GetPhrase('#spawnmenu.menu.copy'), function()
        SetClipboardText(class)
    end, 'icon16/page_copy.png')
end

local function addCreator(menu, class, toolMode)
    if class == '' or toolMode == nil then return end

    menu:AddOption(language.GetPhrase('#spawnmenu.menu.spawn_with_toolgun'), function()
        RunConsoleCommand('gmod_tool', 'creator')
        RunConsoleCommand('creator_type', tostring(toolMode))
        RunConsoleCommand('creator_name', class)

        if toolMode == 2 then
            RunConsoleCommand('creator_override', '')
        end
    end, 'icon16/brick_add.png')
end

local function addUseAsNPCWeapon(menu, class)
    if class == '' or !content.isNPCWeapon(class) then return end

    local active = GetConVarString('gmod_npcweapon') == class
    local icon = active and 'icon16/monkey_tick.png' or 'icon16/monkey.png'

    menu:AddOption(language.GetPhrase('#spawnmenu.menu.use_as_npc_gun'), function()
        RunConsoleCommand('gmod_npcweapon', class)
    end, icon, { selected = active })
end

local function addNPCWeaponMenu(menu, class, tabl)
    local weapons = istable(tabl) and tabl.Weapons or nil
    if !istable(weapons) or table.IsEmpty(weapons) then return end

    local spawnOption = menu:AddOption(language.GetPhrase('#spawnmenu.menu.spawn_with_weapon'), nil, 'icon16/gun.png')
    local spawnMenu = spawnOption:AddSubMenu()
    if IsValid(spawnMenu) then
        content.addNPCWeaponOptions(spawnMenu, class, tabl)
    end
end

local function addInspect(menu, panel, model)
    if !model then return end

    menu:AddSpacer()
    menu:AddOption(Mantle.lang.get('newspawnmenu', 'inspect'), function()
        if !IsValid(panel) or !IsValid(panel.left) then return end

        panel.left:SetVisible(false)

        local inspector = vgui.Create('NewSpawnMenu.Inspector', panel)
        inspector:Dock(FILL)
        inspector:SetModel(model)
        inspector:SetPan(panel)
    end, 'icon16/camera.png')
end

function content.openItemMenu(panel, name, itemIndex, tabl, contentType)
    local class = content.itemClass(itemIndex, tabl)
    local menu = Mantle.ui.derma_menu()

    addCopy(menu, class)
    addCreator(menu, class, creatorModes[contentType])

    if contentType == 'weapon' then
        addUseAsNPCWeapon(menu, class)
    elseif contentType == 'npc' then
        addNPCWeaponMenu(menu, class, tabl)
    end

    addInspect(menu, panel, content.itemModel(itemIndex, tabl, contentType))
end
