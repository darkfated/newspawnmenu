local content = NewSpawnMenu.content

function content.addNPCWeaponOptions(menu, npcKey, npcData)
    local key = tostring(npcKey or '')
    local weapons = (istable(npcData) and istable(npcData.Weapons) and npcData.Weapons) or {}
    local customIcons = list.Get('ContentCategoryIcons')

    local function addOption(text, class, icon)
        menu:AddOption(text, function()
            RunConsoleCommand('gmod_spawnnpc', key, class)
        end, icon)
    end

    for _, class in ipairs(weapons) do
        if class and class != '' then
            addOption(language.GetPhrase(class), class, 'icon16/gun.png')
        end
    end

    menu:AddSpacer()
    addOption(language.GetPhrase('#menubar.npcs.noweapon'), 'none', 'icon16/cross.png')

    local groupedWeapons = {}
    for _, weapon in pairs(list.Get('NPCUsableWeapons')) do
        if weapon.class and !table.HasValue(weapons, weapon.class) then
            local category = (weapon.category or ''):lower()
            groupedWeapons[category] = groupedWeapons[category] or {}
            groupedWeapons[category][language.GetPhrase(weapon.title or weapon.class)] = {
                class = weapon.class,
                icon = customIcons[weapon.category or ''] or 'icon16/gun.png'
            }
        end
    end

    for _, items in SortedPairs(groupedWeapons) do
        menu:AddSpacer()
        for title, info in SortedPairs(items) do
            addOption(title, info.class, info.icon)
        end
    end
end

