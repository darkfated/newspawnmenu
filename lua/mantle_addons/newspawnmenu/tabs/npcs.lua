local PANEL = {}

function PANEL:Init()
    self.ContentType = 'npc'

    self:AddFunc(function(tabl, itemIndex)
        local weapon = table.Random(tabl.Weapons or {}) or ''

        local cvar = GetConVar('gmod_npcweapon')
        if cvar and cvar:GetString() != '' then
            weapon = cvar:GetString()
        end

        RunConsoleCommand('gmod_spawnnpc', itemIndex, weapon)
    end)

    self.ToolMode = 2

    local npcs = list.Get('NPC')
    local customIcons = list.Get('ContentCategoryIcons')

    for k, npc in pairs(npcs) do
        local name = language.GetPhrase(npc.Name or k)
        local btn = self:AddItem(name, npc.Category, npc, k, customIcons[npc.Category] or 'icon16/monkey.png')

        NewSpawnMenu.content.applyItemVisual(btn, k, npc, 'npc')
    end
end

vgui.Register('NewSpawnMenu.Tabs.NPCS', PANEL, 'NewSpawnMenu.Content')

NewSpawnMenu.CreateTab(4, '#spawnmenu.category.npcs', 'icon16/monkey.png', 'NewSpawnMenu.Tabs.NPCS')
