local L = NewSpawnMenu.settings.L

function NewSpawnMenu.settings.buildTools(pan)
    pan:Help(L('help_apply_settings'))
    pan:CheckBox(L('checkbox_enable_search'), 'newspawnmenu_search_panel')
    pan:CheckBox(L('checkbox_compact_tools'), 'newspawnmenu_compact_tools')
    pan:CheckBox(L('checkbox_toolname_left'), 'newspawnmenu_toolname_left')

    pan:Button(L('button_recreate_menu'), 'newspawnmenu_remove')

    pan:CheckBox(L('checkbox_contrast_tools'), 'newspawnmenu_contrast_tools')
end
