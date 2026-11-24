Mantle.run_cl('mantle_addons/newspawnmenu/ui/content/npc_weapons.lua')
Mantle.run_cl('mantle_addons/newspawnmenu/ui/content/context_menu.lua')
Mantle.run_cl('mantle_addons/newspawnmenu/ui/content/grid.lua')
Mantle.run_cl('mantle_addons/newspawnmenu/ui/content/panel.lua')

function NewSpawnMenu.CreateTab(id, name, icon, panel)
    NewSpawnMenu.tabs[id] = {
        name = name,
        icon = icon,
        panel = panel
    }
end
