function NewSpawnMenu.content.openNPCWeaponMenu(npcKey, npcData)
    local menu = Mantle.ui.derma_menu()
    local customIcons = list.Get('ContentCategoryIcons')

    local function addOption(text, weaponClass, icon)
        menu:AddOption(text, function()
            RunConsoleCommand('gmod_spawnnpc', npcKey, weaponClass)
        end, icon)
    end

    for _, class in ipairs(npcData.Weapons) do
        if class != '' then
            addOption(language.GetPhrase(class), class, 'icon16/gun.png')
        end
    end

    menu:AddSpacer()
    addOption(language.GetPhrase('#menubar.npcs.noweapon'), 'none', 'icon16/cross.png')

    local groupedWeps = {}
    for _, v in pairs(list.Get('NPCUsableWeapons')) do
        if table.HasValue(npcData.Weapons, v.class) then continue end

        local cat = (v.category or ''):lower()
        groupedWeps[cat] = groupedWeps[cat] or {}
        groupedWeps[cat][language.GetPhrase(v.title)] = { class = v.class, icon = customIcons[v.category or ''] or 'icon16/gun.png' }
    end

    for group, items in SortedPairs(groupedWeps) do
        menu:AddSpacer()
        for title, info in SortedPairs(items) do
            menu:AddOption(title, function()
                RunConsoleCommand('gmod_spawnnpc', npcKey, info.class)
            end, info.icon)
        end
    end
end
