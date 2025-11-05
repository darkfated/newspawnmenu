NewSpawnMenu = {
    tabs = {},
    convar = {}
}

Mantle.run_cl('utils.lua')
Mantle.run_sv('utils.lua')
Mantle.run_cl('menu.lua')
Mantle.run_cl('main.lua')

Mantle.run_cl('controlpanel.lua')
Mantle.run_cl('tools.lua')

Mantle.run_cl('inspector.lua')

Mantle.run_cl('content.lua')
Mantle.run_cl('tabs/props.lua')
Mantle.run_cl('tabs/weapons.lua')
Mantle.run_cl('tabs/entities.lua')
Mantle.run_cl('tabs/vehicles.lua')
Mantle.run_cl('tabs/npcs.lua')
Mantle.run_cl('tabs/effects.lua')
