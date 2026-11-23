local bridge = {}
NewSpawnMenu.compatibility.bridge = bridge

local function isEnabled()
    local convar = GetConVar('newspawnmenu_on')
    return convar and convar:GetBool()
end

function bridge.bind()
    if !isEnabled() then return end

    if !IsValid(NewSpawnMenu.menu) then
        if !hook.Run('SpawnMenuEnabled') then return end
        NewSpawnMenu.CreateMenu()
    end

    if !IsValid(NewSpawnMenu.menu) then return end
    if g_SpawnMenu == NewSpawnMenu.menu then return end

    g_SpawnMenu = NewSpawnMenu.menu
end

function bridge.release()
    if IsValid(NewSpawnMenu.menu) then NewSpawnMenu.menu:Remove() end

    NewSpawnMenu.main = nil
    NewSpawnMenu.tools = nil
    g_SpawnMenu = nil
end

hook.Add('PostReloadToolsMenu', 'NewSpawnMenu.Bridge', function()
    bridge.bind()
end)

cvars.AddChangeCallback('newspawnmenu_on', function(_, _, value)
    if value == '1' then
        bridge.bind()
    else
        bridge.release()
        RunConsoleCommand('spawnmenu_reload')
    end
end, 'NewSpawnMenu.Bridge')

timer.Simple(0, bridge.bind)
