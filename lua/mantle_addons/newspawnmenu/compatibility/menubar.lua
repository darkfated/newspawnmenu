local hookTable = hook.GetTable()
local originalHook = hookTable and hookTable.OnGamemodeLoaded and hookTable.OnGamemodeLoaded.CreateMenuBar

local originalInit, originalParentTo, originalIsParent
local disabled = false

local function isEnabled()
    local convar = GetConVar('newspawnmenu_on')
    return convar and convar:GetBool()
end

local function capture()
    if !menubar or originalInit then return end

    originalInit = menubar.Init
    originalParentTo = menubar.ParentTo
    originalIsParent = menubar.IsParent
end

local function disable()
    if disabled or !isEnabled() then return end

    capture()
    hook.Remove('OnGamemodeLoaded', 'CreateMenuBar')

    if !menubar then return end

    menubar.Init = function() end
    menubar.ParentTo = function() end
    menubar.IsParent = function() return false end

    if IsValid(menubar.Control) then menubar.Control:Remove() end
    menubar.Control = nil

    disabled = true
end

local function restore()
    if !disabled then return end

    disabled = false

    if menubar then
        if originalInit then menubar.Init = originalInit end
        if originalParentTo then menubar.ParentTo = originalParentTo end
        if originalIsParent then menubar.IsParent = originalIsParent end
    end

    if originalHook then hook.Add('OnGamemodeLoaded', 'CreateMenuBar', originalHook) end
end

disable()
hook.Add('OnGamemodeLoaded', 'NewSpawnMenu.NoMenuBar', disable)
timer.Simple(0, disable)

cvars.AddChangeCallback('newspawnmenu_on', function(_, _, value)
    if value == '1' then
        disable()
    else
        restore()
    end
end, 'NewSpawnMenu.MenuBar')
