local function disable()
    hook.Remove('OnGamemodeLoaded', 'CreateMenuBar')

    if !menubar then return end

    function menubar.Init() end
    function menubar.ParentTo() end
    function menubar.IsParent() return false end

    if IsValid(menubar.Control) then menubar.Control:Remove() end
    menubar.Control = nil
end

disable()
hook.Add('OnGamemodeLoaded', 'NewSpawnMenu.NoMenuBar', disable)
timer.Simple(0, disable)
