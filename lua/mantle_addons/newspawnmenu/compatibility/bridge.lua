local bridge = {}
NewSpawnMenu.compatibility.bridge = bridge

local function isEnabled()
    local convar = GetConVar('newspawnmenu_on')
    return convar and convar:GetBool()
end

function bridge.bind()
    if !isEnabled() then return end

    local previous = g_SpawnMenu

    if !IsValid(NewSpawnMenu.menu) then
        if !hook.Run('SpawnMenuEnabled') then return end
        NewSpawnMenu.CreateMenu()
    end

    if !IsValid(NewSpawnMenu.menu) then return end

    if IsValid(previous) and previous != NewSpawnMenu.menu then previous:Remove() end
    if g_SpawnMenu == NewSpawnMenu.menu then return end

    g_SpawnMenu = NewSpawnMenu.menu
end

function bridge.release()
    local menu = NewSpawnMenu.menu

    if IsValid(menu) then menu:Remove() end

    if g_SpawnMenu == menu or !IsValid(g_SpawnMenu) then
        g_SpawnMenu = nil
    end

    NewSpawnMenu.menu = nil
    NewSpawnMenu.main = nil
    NewSpawnMenu.tools = nil
end

function bridge.rebuild()
    bridge.release()
    RunConsoleCommand('spawnmenu_reload')
end

hook.Add('PostReloadToolsMenu', 'NewSpawnMenu.Bridge', function()
    bridge.bind()
end)

cvars.AddChangeCallback('newspawnmenu_on', function()
    bridge.rebuild()
end, 'NewSpawnMenu.Bridge')

timer.Simple(0, bridge.bind)
