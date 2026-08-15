local PANEL = {}

function PANEL:Init()
    self:AddFunc(function(tabl)
        RunConsoleCommand('gm_giveswep', tabl.ClassName)
    end)

    self:AddFuncMiddle(function(tabl)
        RunConsoleCommand('gm_spawnswep', tabl.ClassName)
    end)

    self.ToolMode = 3

    local weps = list.Get('Weapon')
    local customIcons = list.Get('ContentCategoryIcons')

    for k, wep in pairs(weps) do
        if !wep.Spawnable then
            continue
        end

        local btn = self:AddItem(language.GetPhrase(wep.PrintName or wep.Name or wep.ClassName or k), wep.Category, wep, nil, customIcons[wep.Category] or 'icon16/gun.png')

        local matName = wep.IconOverride or 'entities/' .. wep.ClassName .. '.png'
        local mat = Material(matName)

        if mat:IsError() then
            matName = matName:Replace('entities/', 'vgui/entities/'):Replace('.png', '')
            mat = Material(matName)
        end

        if !mat:IsError() then
            btn.mat = mat
        end
    end
end

vgui.Register('NewSpawnMenu.Tabs.Weapons', PANEL, 'NewSpawnMenu.Content')

NewSpawnMenu.CreateTab(2, '#spawnmenu.category.weapons', 'icon16/gun.png', 'NewSpawnMenu.Tabs.Weapons')
