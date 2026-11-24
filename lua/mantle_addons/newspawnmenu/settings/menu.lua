local L = NewSpawnMenu.settings.L

function NewSpawnMenu.settings.buildMenu(pan)
    pan:Help(L('help_apply_settings'))
    pan:CheckBox(L('checkbox_enable_menu'), 'newspawnmenu_on')
    pan:CheckBox(L('checkbox_close_on_spawn'), 'newspawnmenu_close_on_spawn')
    pan:NumSlider(L('scale'), 'newspawnmenu_scale', 0.8, 1.2, 2)
    pan:CheckBox(L('checkbox_itemname_left'), 'newspawnmenu_itemname_left')
    pan:CheckBox(L('checkbox_default_spawnlist'), 'newspawnmenu_default_spawnlist')

    pan:ComboBoxMulti(L('checkbox_mode'), {
        [L('checkbox_mode_0')] = {
            newspawnmenu_mode = 0
        },
        [L('checkbox_mode_1')] = {
            newspawnmenu_mode = 1
        },
        [L('checkbox_mode_2')] = {
            newspawnmenu_mode = 2
        }
    })

    pan:Button(L('button_recreate_menu'), 'newspawnmenu_remove')

    pan:CheckBox(L('checkbox_blur'), 'newspawnmenu_blur')
    pan:CheckBox(L('checkbox_opt'), 'newspawnmenu_opt')
end
