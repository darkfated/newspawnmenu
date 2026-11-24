local PANEL = {}

local EFFECT_LIST = 'PostProcess'
local DEFAULT_CATEGORY_ICON = 'icon16/picture.png'

local SCRATCH = {}

function SCRATCH:Add(child)
    if ispanel(child) then
        child:SetParent(self)
        return child
    end

    return vgui.Create(child, self)
end

vgui.Register('NewSpawnMenu.EffectScratch', SCRATCH, 'Panel')

local function isEffectOn(effect)
    if effect.convars then
        for cvar, data in pairs(effect.convars) do
            if GetConVarString(cvar) != data.on then
                return false
            end
        end

        return true
    end

    if effect.convar then
        local cvar = GetConVar(effect.convar)
        return cvar and cvar:GetInt() == 1 or false
    end

    return false
end

local function toggleEffect(effect)
    if effect.convars then
        local isOn = isEffectOn(effect)

        for cvar, data in pairs(effect.convars) do
            RunConsoleCommand(cvar, isOn and (data.off or '') or data.on)
        end

        return
    end

    if !effect.convar then return end

    local cvar = GetConVar(effect.convar)
    if !cvar then return end

    RunConsoleCommand(effect.convar, cvar:GetInt() == 1 and '0' or '1')
end

local function openEffectSettings(name, effect)
    if !effect.cpanel then return end

    local title = language.GetPhrase(name)
    local cp = vgui.Create('NewSpawnMenu.ControlPanel')
    cp:SetName(title)
    effect.cpanel(cp)

    if IsValid(NewSpawnMenu.tools) and NewSpawnMenu.tools:ShowControlPanel(cp) then
        return
    end

    local frame = vgui.Create('MantleFrame')
    frame:SetSize(460, 360)
    frame:SetTitle(title)
    frame:Center()
    frame:MakePopup()
    frame:ShowAnimation()

    cp:SetParent(frame)
    cp:Dock(FILL)

    return frame
end

local function clickedCheckbox(btn)
    if !IsValid(btn) then return false end

    local rect = btn._checkboxRect
    if !rect then return false end

    local x, y = btn:ScreenToLocal(gui.MouseX(), gui.MouseY())

    return x >= rect.x and x <= rect.x + rect.w and y >= rect.y and y <= rect.y + rect.h
end

function PANEL:Init()
    self:AddFunc(function(data)
        local effect = data.effect
        if !effect then return end

        if effect.onclick then
            effect.onclick()
            return
        end

        if (effect.convar or effect.convars) and clickedCheckbox(data.btn) then
            toggleEffect(effect)
            return
        end

        if effect.cpanel then
            openEffectSettings(data.name, effect)
            return
        end

        toggleEffect(effect)
    end)

    self:AddFuncPaintOver(function(name, itemIndex, data, w, h, btn, offsetX, offsetY)
        local effect = data.effect
        if !effect or effect.onclick then return end
        if !effect.convar and !effect.convars then return end

        local x, y = (offsetX or 0) + w - 24, (offsetY or 0) + 8

        RNDX.Rect(x, y, 16, 16)
            :Rad(6)
            :Color(isEffectOn(effect) and Mantle.color.theme or Mantle.color.text)
        :Draw()

        btn._checkboxRect = { x = x, y = y, w = 16, h = 16 }
    end)

    local items = {}

    local function addItem(effect, label, icon)
        local title = language.GetPhrase(label or effect.name or '')

        table.insert(items, {
            effect = effect,
            name = title,
            title = title,
            category = language.GetPhrase(effect.category or '#spawnmenu.category.other'),
            icon = icon or effect.icon
        })
    end

    local function addFromFunc(spawnName, effect)
        local container = vgui.Create('NewSpawnMenu.EffectScratch')

        effect.func(container)

        for _, child in pairs(container:GetChildren()) do
            if !IsValid(child) or !child.ToTable then continue end

            local infoTable = {}
            child:ToTable(infoTable)

            local info = infoTable[1]
            if !istable(info) or !isstring(info.name) then continue end

            local parent = list.GetEntry(EFFECT_LIST, info.name) or effect
            local source = table.Copy(parent)
            source.convars = info.convars or source.convars

            addItem(source, info.label or info.name, info.icon)
        end

        container:Remove()
    end

    for spawnName, effect in pairs(list.Get(EFFECT_LIST)) do
        if effect.func then
            addFromFunc(spawnName, effect)
        else
            addItem(effect, spawnName)
        end
    end

    table.sort(items, function(a, b)
        if a.category != b.category then
            return a.category < b.category
        end

        return a.title < b.title
    end)

    for _, data in ipairs(items) do
        local categoryIcon = list.GetEntry('ContentCategoryIcons', data.category) or DEFAULT_CATEGORY_ICON
        local btn = self:AddItem(data.title, data.category, data, nil, categoryIcon)

        if data.icon then
            local mat = Material(data.icon)
            if !mat:IsError() then
                btn.mat = mat
            end
        end

        data.btn = btn
    end
end

vgui.Register('NewSpawnMenu.Tabs.Effects', PANEL, 'NewSpawnMenu.Content')

NewSpawnMenu.CreateTab(6, '#spawnmenu.category.postprocess', 'icon16/picture.png', 'NewSpawnMenu.Tabs.Effects')
