NewSpawnMenu = {
    tabs = {},
    convar = {},
    controls = {}
}

Mantle.run_cl('utils.lua')
Mantle.run_sv('utils.lua')
Mantle.run_cl('menu.lua')
Mantle.run_cl('main.lua')

Mantle.run_cl('controls/shared.lua')
Mantle.run_cl('controls/rope_material.lua')
Mantle.run_cl('controls/num_pad.lua')
Mantle.run_cl('controls/help.lua')
Mantle.run_cl('controls/control_help.lua')
Mantle.run_cl('controls/check_box.lua')
Mantle.run_cl('controls/num_slider.lua')
Mantle.run_cl('controls/text_entry.lua')
Mantle.run_cl('controls/button.lua')
Mantle.run_cl('controls/color_picker.lua')
Mantle.run_cl('controls/rope_select.lua')
Mantle.run_cl('controls/mat_select.lua')
Mantle.run_cl('controls/prop_select.lua')
Mantle.run_cl('controls/key_binder.lua')
Mantle.run_cl('controls/combo_box_multi.lua')
Mantle.run_cl('controls/list_box.lua')
Mantle.run_cl('controls/material_gallery.lua')
Mantle.run_cl('controls/tool_presets.lua')
Mantle.run_cl('controls/add_control.lua')

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
