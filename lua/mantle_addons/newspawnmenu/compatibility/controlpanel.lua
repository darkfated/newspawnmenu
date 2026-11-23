local compatibility = NewSpawnMenu.compatibility
local defaultGet = controlpanel.Get
local defaultClear = controlpanel.Clear

NewSpawnMenu.controlPanels = {}

local function isEnabled()
    local convar = GetConVar('newspawnmenu_on')
    return convar and convar:GetBool()
end

local function shouldRecreate(panel)
    if !IsValid(panel) or panel:IsMarkedForDeletion() then return true end

    local parent = panel:GetParent()
    while IsValid(parent) do
        if parent:IsMarkedForDeletion() then return true end
        parent = parent:GetParent()
    end

    return false
end

function controlpanel.Get(name)
    if !isEnabled() then return defaultGet(name) end

    local panels = NewSpawnMenu.controlPanels
    local cp = panels[name]

    if shouldRecreate(cp) then
        cp = vgui.Create('NewSpawnMenu.ControlPanel')
        if !cp then return defaultGet(name) end

        cp:SetVisible(false)
        cp.Name = name
        panels[name] = cp
    end

    return cp
end

function controlpanel.Clear()
    defaultClear()

    for name, cp in pairs(NewSpawnMenu.controlPanels) do
        if IsValid(cp) then cp:Remove() end
        NewSpawnMenu.controlPanels[name] = nil
    end
end

compatibility.controlpanel = true
