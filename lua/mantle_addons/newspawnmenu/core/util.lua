local util = NewSpawnMenu.util

function util.phrase(value, fallback)
    if !isstring(value) or value == '' then return fallback end
    if !value:StartsWith('#') then return value end

    local translated = language.GetPhrase(value)
    if !isstring(translated) or translated == '' or translated == value then
        return fallback or value
    end

    return translated
end

function util.material(path)
    if !isstring(path) or path == '' then return nil end
    if path:StartsWith('materials/') then path = path:sub(11) end

    local mat = Material(path)
    if !mat or mat:IsError() then return nil end

    return mat
end
