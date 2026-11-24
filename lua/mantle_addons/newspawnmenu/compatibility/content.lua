local compatibility = NewSpawnMenu.compatibility

local cache = {}
local baseDoClick = vgui.GetControlTable('DTreeNode') and vgui.GetControlTable('DTreeNode').DoClick

local function phrase(value, fallback)
    if !isstring(value) or value == '' then return fallback end
    if !value:StartsWith('#') then return value end

    local translated = language.GetPhrase(value)
    if !isstring(translated) or translated == '' or translated == value then return fallback or value end

    return translated
end

local function iconEntry(icon, category, subCategory)
    if !IsValid(icon) or icon:GetName() != 'ContentIcon' then return end

    local class = icon:GetSpawnName()
    if !isstring(class) or class == '' then return end

    return {
        name = phrase(icon.m_NiceName, class),
        category = category,
        subCategory = subCategory,
        class = class,
        material = icon.m_MaterialName,
        admin = icon:GetAdminOnly() == true,
        contentType = icon:GetContentType(),
        onClick = icon.DoClick,
        openMenuExtra = icon.OpenMenuExtra,
        openMenu = icon.OpenMenu
    }
end

local function collectContainer(container, category, subCategory, result, seen)
    if !IsValid(container) or !IsValid(container.IconList) then return end

    for _, icon in ipairs(container.IconList:GetChildren()) do
        local entry = iconEntry(icon, category, subCategory)
        if entry then
            local key = category .. '|' .. subCategory .. '|' .. entry.class
            if !seen[key] then
                seen[key] = true
                result[#result + 1] = entry
            end
        end
    end
end

local function visitNode(node, category, subCategory, categoryIcon, result, seen, depth)
    if !IsValid(node) or depth > 6 then return end

    local title = phrase(node:GetText())
    if !isstring(title) or title == '' then return end

    local nodeIcon = node:GetIcon()
    if !isstring(nodeIcon) or nodeIcon == '' then nodeIcon = categoryIcon end

    local nextCategory = category or title
    local nextSubCategory = category and (subCategory == '' and title or subCategory .. ' / ' .. title) or ''
    local nextIcon = category and categoryIcon or nodeIcon

    if isfunction(node.DoPopulate) then node:DoPopulate() end

    collectContainer(node.PropPanel or node.itemsPanel, nextCategory, nextSubCategory, result, seen)

    local fn = node.DoClick
    if category and !isfunction(node.DoPopulate) and isfunction(fn) and fn != baseDoClick then
        local key = nextCategory .. '|' .. nextSubCategory .. '|action:' .. title
        if !seen[key] then
            seen[key] = true
            result[#result + 1] = {
                name = title,
                category = nextCategory,
                subCategory = nextSubCategory,
                class = '',
                material = nodeIcon or 'icon16/cog.png',
                admin = false,
                contentType = 'action',
                onClick = function() fn(node) end,
                action = true
            }
        end
    end

    for _, child in ipairs(node:GetChildNodes() or {}) do
        visitNode(child, nextCategory, nextSubCategory, nextIcon, result, seen, depth + 1)
    end
end

function compatibility.populate(hookName)
    if cache[hookName] then return cache[hookName] end

    local result = {}
    if !vgui.GetControlTable('SpawnmenuContentPanel') then
        cache[hookName] = result
        return result
    end

    local host = vgui.Create('SpawnmenuContentPanel')
    if !IsValid(host) then
        cache[hookName] = result
        return result
    end

    host:SetVisible(false)
    host:CallPopulateHook(hookName)

    local tree = host.ContentNavBar and host.ContentNavBar.Tree
    if IsValid(tree) then
        local seen = {}
        for _, node in ipairs(tree:Root():GetChildNodes() or {}) do
            visitNode(node, nil, '', nil, result, seen, 0)
        end
    end

    host:Remove()
    cache[hookName] = result

    return result
end

function compatibility.invalidateContent()
    cache = {}
end

hook.Add('GameContentChanged', 'NewSpawnMenu.CompatibilityContent', compatibility.invalidateContent)
