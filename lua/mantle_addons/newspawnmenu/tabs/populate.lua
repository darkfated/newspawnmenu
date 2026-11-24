local populate = {}
NewSpawnMenu.content.populate = populate

local function listEntries(options)
    local result = {}

    for class, data in pairs(list.Get(options.list) or {}) do
        if !options.filter or options.filter(class, data) then
            local name = ''
            for _, key in ipairs(options.nameKeys or { 'PrintName', 'Name' }) do
                if isstring(data[key]) and data[key] != '' then
                    name = data[key]
                    break
                end
            end

            result[#result + 1] = {
                name = language.GetPhrase(name != '' and name or class),
                category = data.Category or 'Other',
                subCategory = data.SubCategory or '',
                class = class,
                material = data.IconOverride,
                admin = data.AdminOnly == true,
                contentType = options.contentType,
                data = data,
                onClick = function()
                    options.onClick(class, data)
                end
            }
        end
    end

    return result
end

local function sortEntries(a, b)
    if a.category != b.category then return a.category < b.category end
    if a.subCategory != b.subCategory then return a.subCategory < b.subCategory end
    if a.action != b.action then return b.action == true end

    return a.name < b.name
end

local function addEntry(panel, entry, options, seen)
    local key = tostring(entry.category) .. '|' .. tostring(entry.subCategory) .. '|' .. tostring(entry.class)
    if seen[key] then return end
    seen[key] = true

    local class = entry.class or ''
    local contentType = entry.contentType or options.contentType
    local tabl = table.Copy(entry.data or {})

    tabl.PrintName = entry.name
    tabl.Name = entry.name
    tabl.ClassName = class
    tabl.SpawnName = class
    tabl.Category = entry.category
    tabl.SubCategory = entry.subCategory
    tabl.AdminOnly = entry.admin == true

    if entry.material then tabl.IconOverride = entry.material end

    tabl._onClick = entry.onClick
    tabl._openMenuExtra = entry.openMenuExtra
    tabl._openMenu = entry.openMenu
    tabl._contentType = contentType

    local categoryIcon = list.GetEntry('ContentCategoryIcons', entry.category) or options.icon
    local itemIndex = class != '' and class or 'action:' .. entry.name
    local btn = panel:AddItem(entry.name, entry.category, tabl, itemIndex, categoryIcon)

    NewSpawnMenu.content.applyItemVisual(btn, itemIndex, tabl, contentType)
end

function populate.build(panel, options)
    local entries = table.Copy(NewSpawnMenu.compatibility.populate(options.hook))
    local classes = {}

    for _, entry in ipairs(entries) do
        classes[entry.class] = true
    end

    for _, entry in ipairs(listEntries(options)) do
        if !classes[entry.class] then
            classes[entry.class] = true
            entries[#entries + 1] = entry
        end
    end

    table.sort(entries, sortEntries)

    local seen = {}
    for _, entry in ipairs(entries) do
        addEntry(panel, entry, options, seen)
    end
end
