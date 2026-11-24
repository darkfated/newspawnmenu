local spawnlist = NewSpawnMenu.spawnlist
local items = spawnlist.items

local catalog = {}
spawnlist.catalog = catalog

local ICONS = {
    custom = 'icon16/folder.png',
    addon = 'icon16/folder_brick.png',
    games = 'icon16/folder_database.png',
    addons = 'icon16/folder_database.png',
    folder = 'icon16/folder.png'
}

local ROOTS = {
    { key = 'your', title = '#spawnmenu.category.your_spawnlists', icon = ICONS.custom },
    { key = 'addon', title = '#spawnmenu.category.addon_spawnlists', icon = ICONS.addon },
    { key = 'games', title = '#spawnmenu.category.games', icon = ICONS.games },
    { key = 'addons', title = '#spawnmenu.category.addons', icon = ICONS.addons }
}

function catalog.availableRoots()
    local result = {}
    local custom = spawnmenu.GetPropTable and spawnmenu.GetPropTable() or {}
    local addonList = spawnmenu.GetCustomPropTable and spawnmenu.GetCustomPropTable() or {}

    if next(custom) then result[#result + 1] = ROOTS[1] end
    if next(addonList) then result[#result + 1] = ROOTS[2] end

    result[#result + 1] = ROOTS[3]

    for _, addon in pairs(engine.GetAddons() or {}) do
        if istable(addon) and addon.downloaded and addon.mounted and (tonumber(addon.models) or 0) > 0 then
            result[#result + 1] = ROOTS[4]
            break
        end
    end

    return result
end

local TAB_CACHE = {}
local FOLDER_CACHE = {}

local phrase = NewSpawnMenu.util.phrase

local function normalizePath(path)
    path = tostring(path or 'models'):gsub('\\', '/'):gsub('/+', '/')

    return path:gsub('/$', '')
end

local function ensureSection(map, sections, title, icon)
    title = phrase(title, 'Other')

    local section = map[title]
    if section then return section end

    section = {
        title = title,
        icon = icon,
        items = {}
    }

    map[title] = section
    sections[#sections + 1] = section

    return section
end

local function isVisible(info)
    local needsApp = info.needsapp
    if isstring(needsApp) and needsApp != '' and !IsMounted(needsApp) then return false end

    return true
end

local function buildItemSections(info, title, icon)
    local map = {}
    local sections = {}
    local section

    for _, object in SortedPairs(info.contents or {}) do
        if istable(object) then
            if object.type == 'header' then
                local header = tostring(object.text or '')
                if header != '' then section = ensureSection(map, sections, header, icon) end
            else
                local desc = items.make(object)
                if desc then
                    if !isstring(desc.icon) or desc.icon == '' then desc.icon = icon end

                    section = section or ensureSection(map, sections, title, icon)
                    section.items[#section.items + 1] = desc
                end
            end
        end
    end

    for i = #sections, 1, -1 do
        if #sections[i].items == 0 then table.remove(sections, i) end
    end

    return sections
end

local function spawnlistTabs(source, rootKey, icon)
    local result = {}
    local byParent = {}
    local seen = {}

    for _, info in pairs(source or {}) do
        if istable(info) then
            local parentId = tonumber(info.parentid) or 0
            byParent[parentId] = byParent[parentId] or {}
            byParent[parentId][#byParent[parentId] + 1] = info
        end
    end

    local function sortInfo(a, b)
        local left = phrase(a.name, '')
        local right = phrase(b.name, '')
        if left != right then return left < right end

        return tostring(a.id or '') < tostring(b.id or '')
    end

    for _, list in pairs(byParent) do table.sort(list, sortInfo) end

    local function visit(info, ancestors)
        local key = rootKey .. ':' .. tostring(info.id or info.name or 'unknown')
        if seen[key] or !isVisible(info) then return end
        seen[key] = true

        local title = phrase(info.name, 'Other')
        local path = table.Copy(ancestors)
        path[#path + 1] = title

        local display = #path > 1 and table.concat(path, ' / ') or title
        local listIcon = isstring(info.icon) and info.icon != '' and info.icon or icon
        local sections = buildItemSections(info, title, listIcon)

        if #sections > 0 then
            result[#result + 1] = {
                key = key,
                title = display,
                icon = listIcon,
                kind = 'items',
                sections = sections
            }
        end

        for _, child in ipairs(byParent[tonumber(info.id) or -1] or {}) do
            if child != info then visit(child, path) end
        end
    end

    for _, info in ipairs(byParent[0] or {}) do visit(info, {}) end

    return result
end

local function gameTabs()
    local result = {}
    local games = table.Copy(engine.GetGames() or {})

    games[#games + 1] = { title = 'All', folder = 'GAME', mounted = true }
    games[#games + 1] = { title = "Garry's Mod", folder = 'garrysmod', mounted = true }

    local entries = {}
    for _, game in pairs(games) do
        if istable(game) and game.mounted and isstring(game.folder) and game.folder != '' then
            entries[#entries + 1] = game
        end
    end

    table.sort(entries, function(a, b)
        return tostring(a.title or a.folder) < tostring(b.title or b.folder)
    end)

    for index, game in ipairs(entries) do
        local pathId = game.folder
        local tab = {
            key = 'games:' .. index .. ':' .. pathId,
            title = tostring(game.title or pathId),
            icon = ICONS.games,
            kind = 'folders',
            pathId = pathId,
            root = 'models'
        }

        if catalog.hasFolders(tab) then result[#result + 1] = tab end
    end

    return result
end

local function addonTabs()
    local result = {}
    local addons = {}

    for _, addon in pairs(engine.GetAddons() or {}) do
        if istable(addon) and addon.downloaded and addon.mounted and (tonumber(addon.models) or 0) > 0 and isstring(addon.title) then
            addons[#addons + 1] = addon
        end
    end

    table.sort(addons, function(a, b)
        return tostring(a.title) < tostring(b.title)
    end)

    for index, addon in ipairs(addons) do
        local pathId = addon.title
        local tab = {
            key = 'addons:' .. index .. ':' .. pathId,
            title = addon.title .. ' (' .. addon.models .. ')',
            icon = ICONS.addons,
            kind = 'folders',
            pathId = pathId,
            root = 'models'
        }

        if catalog.hasFolders(tab) then result[#result + 1] = tab end
    end

    return result
end

function catalog.tabs(rootKey)
    if TAB_CACHE[rootKey] then return TAB_CACHE[rootKey] end

    local tabs

    if rootKey == 'your' then
        tabs = spawnlistTabs(spawnmenu.GetPropTable and spawnmenu.GetPropTable() or {}, rootKey, ICONS.custom)
    elseif rootKey == 'addon' then
        tabs = spawnlistTabs(spawnmenu.GetCustomPropTable and spawnmenu.GetCustomPropTable() or {}, rootKey, ICONS.addon)
    elseif rootKey == 'games' then
        tabs = gameTabs()
    elseif rootKey == 'addons' then
        tabs = addonTabs()
    else
        tabs = {}
    end

    TAB_CACHE[rootKey] = tabs

    return tabs
end

local function folderHasModels(folder)
    local files = file.Find(normalizePath(folder.path) .. '/*.mdl', folder.pathId)

    return istable(files) and #files > 0
end

function catalog.folders(tab)
    local pathId = tab.pathId
    local root = normalizePath(tab.root)
    local cacheKey = tostring(pathId or '') .. '|' .. root
    local cached = FOLDER_CACHE[cacheKey]

    if cached then return cached end
    local candidates = {
        { title = 'models', path = root, pathId = pathId }
    }

    local _, dirs = file.Find(root .. '/*', pathId)

    for _, name in ipairs(dirs or {}) do
        candidates[#candidates + 1] = {
            title = name,
            path = root .. '/' .. name,
            pathId = pathId
        }
    end

    table.sort(candidates, function(a, b)
        if a.path == root then return true end
        if b.path == root then return false end

        return a.title < b.title
    end)

    local result = {}

    for _, folder in ipairs(candidates) do
        if folderHasModels(folder) then result[#result + 1] = folder end
    end

    FOLDER_CACHE[cacheKey] = result

    return result
end

function catalog.hasFolders(tab)
    return #catalog.folders(tab) > 0
end

function catalog.models(folder)
    local path = normalizePath(folder.path)
    local files = file.Find(path .. '/*.mdl', folder.pathId)
    local sections = {}
    local section = {
        title = folder.title,
        icon = ICONS.folder,
        items = {}
    }

    sections[#sections + 1] = section

    table.sort(files or {}, function(a, b)
        return a:lower() < b:lower()
    end)

    for _, fileName in ipairs(files or {}) do
        local desc = items.make({
            type = 'model',
            model = path .. '/' .. fileName
        })

        if desc then
            desc.icon = ICONS.folder
            section.items[#section.items + 1] = desc
        end
    end

    if #section.items == 0 then return {} end

    return sections
end

function catalog.invalidate()
    TAB_CACHE = {}
    FOLDER_CACHE = {}
end
