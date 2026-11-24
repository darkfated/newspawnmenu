local content = NewSpawnMenu.content
local spawnlist = NewSpawnMenu.spawnlist

local items = {}
spawnlist.items = items

local function modelName(path)
    local name = string.GetFileFromFilename(tostring(path or '')):gsub('%.[mM][dD][lL]$', '')

    return name != '' and name or tostring(path or '')
end

local function bodyGroups(object)
    local body = tostring(object.body or object.BodyGroups or ''):gsub('B', '')
    if body:len() != 9 then body = '000000000' end

    return body
end

local function makeModel(object)
    local model = object.model
    if !isstring(model) or model == '' then return end

    local skin = tonumber(object.skin or 0) or 0
    local body = bodyGroups(object)
    local name = language.GetPhrase(object.nicename or modelName(model))

    local tabl = {
        IconOverride = object.material,
        Model = model,
        model = model,
        Skin = skin,
        BodyGroups = body,
        AdminOnly = object.admin == true,
        _spawnType = 'model',
        _model = model,
        _skin = skin,
        _body = body,
        _creatorOverride = skin .. ' ' .. body
    }

    return {
        name = name,
        contentType = 'prop',
        itemIndex = model,
        tabl = tabl,
        icon = object.icon or 'icon16/brick.png',
        tooltip = modelName(model)
    }
end

local function makeClass(object)
    local spawnType = object.type
    local class = object.spawnname
    if !isstring(class) or class == '' then return end

    local name = language.GetPhrase(object.nicename or class)
    local admin = object.admin == true

    local tabl = {
        ClassName = class,
        PrintName = name,
        IconOverride = object.material,
        material = object.material,
        AdminOnly = admin,
        admin = admin,
        Weapons = object.weapon,
        _spawnType = spawnType,
        _class = class,
        _weapons = object.weapon
    }

    return {
        name = name,
        contentType = spawnType,
        itemIndex = class,
        tabl = tabl,
        icon = object.icon or 'icon16/brick.png',
        tooltip = tostring(object.nicename or class)
    }
end

function items.make(object)
    if !istable(object) or object.type == 'header' then return end

    if object.type == 'model' then return makeModel(object) end

    if object.type == 'entity' or object.type == 'vehicle' or object.type == 'npc' or object.type == 'weapon' then
        return makeClass(object)
    end
end

function items.spawn(tabl)
    local spawnType = tabl._spawnType

    if spawnType == 'model' then
        RunConsoleCommand('gm_spawn', tabl._model or tabl.model, tabl._skin or 0, tabl._body or '')
        return
    end

    local class = tabl._class or tabl.ClassName
    if !isstring(class) or class == '' then return end

    if spawnType == 'entity' then
        RunConsoleCommand('gm_spawnsent', class)
    elseif spawnType == 'vehicle' then
        RunConsoleCommand('gm_spawnvehicle', class)
    elseif spawnType == 'npc' then
        local weapon = table.Random(tabl._weapons or {}) or ''
        local override = GetConVarString('gmod_npcweapon')
        if isstring(override) and override != '' then weapon = override end

        RunConsoleCommand('gmod_spawnnpc', class, weapon)
    elseif spawnType == 'weapon' then
        RunConsoleCommand('gm_giveswep', class)
    end
end

function items.spawnMiddle(tabl)
    if tabl._spawnType != 'weapon' then return end

    local class = tabl._class or tabl.ClassName
    if isstring(class) and class != '' then
        RunConsoleCommand('gm_spawnswep', class)
    end
end

function items.apply(btn, desc)
    btn.contentType = desc.contentType
    content.applyItemVisual(btn, desc.itemIndex, desc.tabl, desc.contentType)

    if isstring(desc.tooltip) and desc.tooltip != '' then
        btn:SetTooltip(desc.tooltip)
    end
end

function items.job(desc, grid)
    return {
        grid = grid,
        name = desc.name,
        tabl = desc.tabl,
        itemIndex = desc.itemIndex,
        onCard = function(btn)
            items.apply(btn, desc)
        end
    }
end
