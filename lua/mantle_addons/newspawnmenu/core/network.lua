util.AddNetworkString('NewSpawnMenu-F1')

hook.Add('ShowHelp', 'NewSpawnMenu', function(pl)
    local t = CurTime()
    if t - (pl.lastTimeF1 and pl.lastTimeF1 or 0) < 0.2 then return end
    pl.lastTimeF1 = t

    net.Start('NewSpawnMenu-F1')
    net.Send(pl)

    return false
end)
