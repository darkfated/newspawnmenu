NewSpawnMenu = {
    tabs = {},
    convar = {},
    controls = {},
    content = {},
    settings = {},
    ui = {}
}

Mantle.run_sv('mantle_addons/newspawnmenu/core/network.lua')
Mantle.run_cl('mantle_addons/newspawnmenu/core/render.lua')

Mantle.run_cl('mantle_addons/newspawnmenu/api/init.lua')

Mantle.run_cl('mantle_addons/newspawnmenu/controls/shared.lua')
Mantle.run_cl('mantle_addons/newspawnmenu/controls/rope_material.lua')
Mantle.run_cl('mantle_addons/newspawnmenu/controls/num_pad.lua')
Mantle.run_cl('mantle_addons/newspawnmenu/controls/help.lua')
Mantle.run_cl('mantle_addons/newspawnmenu/controls/control_help.lua')
Mantle.run_cl('mantle_addons/newspawnmenu/controls/check_box.lua')
Mantle.run_cl('mantle_addons/newspawnmenu/controls/num_slider.lua')
Mantle.run_cl('mantle_addons/newspawnmenu/controls/text_entry.lua')
Mantle.run_cl('mantle_addons/newspawnmenu/controls/button.lua')
Mantle.run_cl('mantle_addons/newspawnmenu/controls/color_picker.lua')
Mantle.run_cl('mantle_addons/newspawnmenu/controls/rope_select.lua')
Mantle.run_cl('mantle_addons/newspawnmenu/controls/mat_select.lua')
Mantle.run_cl('mantle_addons/newspawnmenu/controls/prop_select.lua')
Mantle.run_cl('mantle_addons/newspawnmenu/controls/key_binder.lua')
Mantle.run_cl('mantle_addons/newspawnmenu/controls/combo_box_multi.lua')
Mantle.run_cl('mantle_addons/newspawnmenu/controls/list_box.lua')
Mantle.run_cl('mantle_addons/newspawnmenu/controls/material_gallery.lua')
Mantle.run_cl('mantle_addons/newspawnmenu/controls/tool_presets.lua')
Mantle.run_cl('mantle_addons/newspawnmenu/controls/add_control.lua')

Mantle.run_cl('mantle_addons/newspawnmenu/ui/init.lua')
Mantle.run_cl('mantle_addons/newspawnmenu/settings/init.lua')

Mantle.run_cl('mantle_addons/newspawnmenu/tabs/props.lua')
Mantle.run_cl('mantle_addons/newspawnmenu/tabs/weapons.lua')
Mantle.run_cl('mantle_addons/newspawnmenu/tabs/entities.lua')
Mantle.run_cl('mantle_addons/newspawnmenu/tabs/vehicles.lua')
Mantle.run_cl('mantle_addons/newspawnmenu/tabs/npcs.lua')
Mantle.run_cl('mantle_addons/newspawnmenu/tabs/effects.lua')

Mantle.run_cl('mantle_addons/newspawnmenu/compatibility/init.lua')
