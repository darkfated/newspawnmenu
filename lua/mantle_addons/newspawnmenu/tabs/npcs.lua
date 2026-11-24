local PANEL = {}

local function spawnNPC(class, data)
    local weapon = table.Random((istable(data) and data.Weapons) or {}) or ''

    local cvar = GetConVar('gmod_npcweapon')
    if cvar and cvar:GetString() != '' then
        weapon = cvar:GetString()
    end

    RunConsoleCommand('gmod_spawnnpc', class, weapon)
end

function PANEL:Init()
    self.ContentType = 'npc'

    self:AddFunc(function(tabl, itemIndex)
        spawnNPC(itemIndex, tabl)
    end)

    NewSpawnMenu.content.populate.build(self, {
        hook = 'PopulateNPCs',
        list = 'NPC',
        contentType = 'npc',
        icon = 'icon16/monkey.png',
        nameKeys = { 'Name' },
        onClick = spawnNPC
    })
end

vgui.Register('NewSpawnMenu.Tabs.NPCS', PANEL, 'NewSpawnMenu.Content')

NewSpawnMenu.CreateTab(4, '#spawnmenu.category.npcs', 'icon16/monkey.png', 'NewSpawnMenu.Tabs.NPCS')
