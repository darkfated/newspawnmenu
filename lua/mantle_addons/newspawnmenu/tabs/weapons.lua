local PANEL = {}

function PANEL:Init()
    self.ContentType = 'weapon'

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

        local name = language.GetPhrase(wep.PrintName or wep.Name or wep.ClassName or k)
        local btn = self:AddItem(name, wep.Category, wep, nil, customIcons[wep.Category] or 'icon16/gun.png')

        NewSpawnMenu.content.applyItemVisual(btn, k, wep, 'weapon')
    end
end

vgui.Register('NewSpawnMenu.Tabs.Weapons', PANEL, 'NewSpawnMenu.Content')

NewSpawnMenu.CreateTab(2, '#spawnmenu.category.weapons', 'icon16/gun.png', 'NewSpawnMenu.Tabs.Weapons')
