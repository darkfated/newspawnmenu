local content = NewSpawnMenu.content

local MODEL_KEYS = {
    'Model', 'WorldModel', 'ViewModel', 'ModelName', 'Mdl',
    'model', 'worldmodel', 'viewmodel', 'modelName'
}

local CLASS_KEYS = {
    'ClassName', 'Class', 'VehicleClass', 'EntityClass', 'SpawnName',
    'spawnname', 'class', 'entityClass'
}

local function modelFromTable(t)
    if !istable(t) then return nil end

    for _, key in ipairs(MODEL_KEYS) do
        local value = t[key]
        if isstring(value) and value != '' then return value end
    end

    return nil
end

local function classFromTable(t)
    if !istable(t) then return nil end

    for _, key in ipairs(CLASS_KEYS) do
        local value = t[key]
        if isstring(value) and value != '' then return value end
    end

    return nil
end

local function registryModel(class, contentType)
    local sources = {}

    if contentType == 'weapon' then
        sources = { weapons.Get(class), list.GetEntry('Weapon', class) }
    elseif contentType == 'vehicle' then
        sources = { list.GetEntry('Vehicles', class), scripted_ents.Get(class) }
    elseif contentType == 'npc' then
        sources = { scripted_ents.Get(class), list.GetEntry('NPC', class) }
    elseif contentType == 'entity' then
        sources = { scripted_ents.Get(class), list.GetEntry('SpawnableEntities', class) }
    end

    for _, source in ipairs(sources) do
        local model = modelFromTable(source)
        if model then return model end

        local altClass = classFromTable(source)
        if altClass and altClass != class then
            local altSources = {
                scripted_ents.Get(altClass),
                list.GetEntry('Vehicles', altClass),
                list.GetEntry('Weapon', altClass),
                list.GetEntry('NPC', altClass),
                list.GetEntry('SpawnableEntities', altClass),
                weapons.Get(altClass)
            }

            for _, alt in ipairs(altSources) do
                model = modelFromTable(alt)
                if model then return model end
            end
        end
    end

    return nil
end

local function modelExists(model)
    return util.IsValidModel(model) or file.Exists(model, 'GAME')
end

local function materialFromName(name)
    if !isstring(name) or name == '' then return nil end

    local path = 'materials/' .. name
    if !file.Exists(path, 'GAME') and !file.Exists(path .. '.vmt', 'GAME') then return nil end

    local mat = Material(name)
    if !mat or mat:IsError() then return nil end

    return mat
end

local function spawniconMaterial(model)
    if !isstring(model) or model == '' then return nil end

    local relative = model:gsub('\\', '/')
    local png = relative:gsub('%.[mM][dD][lL]$', '.png')
    local png128 = relative:gsub('%.[mM][dD][lL]$', '_128.png')
    local png256 = relative:gsub('%.[mM][dD][lL]$', '_256.png')
    local png512 = relative:gsub('%.[mM][dD][lL]$', '_512.png')

    local paths = {
        'spawnicons/' .. png512,
        'spawnicons/' .. png256,
        'spawnicons/' .. png128,
        'spawnicons/' .. png,
        png
    }

    for _, path in ipairs(paths) do
        local mat = materialFromName(path)
        if mat then return mat, path end
    end

    return nil
end

function content.isNPCWeapon(class)
    if class == '' then return false end

    for _, weapon in pairs(list.Get('NPCUsableWeapons')) do
        if weapon.class == class then return true end
    end

    return false
end

function content.itemClass(itemIndex, tabl)
    local class = classFromTable(tabl) or itemIndex

    return class and tostring(class) or ''
end

function content.itemModel(itemIndex, tabl, contentType)
    local model = modelFromTable(tabl)
    if model then return model end

    local class = content.itemClass(itemIndex, tabl)
    if class == '' then return nil end

    return registryModel(class, contentType)
end

function content.applyItemVisual(btn, itemIndex, tabl, contentType)
    local class = content.itemClass(itemIndex, tabl)

    btn.adminOnly = istable(tabl) and tabl.AdminOnly == true
    btn.spawnName = class
    btn.npcWeapon = contentType == 'weapon' and content.isNPCWeapon(class)

    local source = istable(tabl) and tabl or {}
    local iconOverride = source.IconOverride or source.iconOverride or source.material or source.Material
    local names = {
        isstring(iconOverride) and iconOverride or false,
        'entities/' .. class .. '.png',
        'vgui/entities/' .. class,
        'VGUI/entities/' .. class
    }

    for _, name in ipairs(names) do
        local mat = materialFromName(name)
        if mat then
            btn.mat = mat
            return
        end
    end

    local model = content.itemModel(itemIndex, tabl, contentType)
    local spawnicon = spawniconMaterial(model)

    if spawnicon then
        btn.mat = spawnicon
        return
    end

    if isstring(model) and model != '' and modelExists(model) then
        btn.model = model

        if btn.SetModelFallback then
            btn:SetModelFallback(model, istable(tabl) and tabl.Skin or 0, istable(tabl) and tabl.BodyGroups or nil)
        end
    end
end
