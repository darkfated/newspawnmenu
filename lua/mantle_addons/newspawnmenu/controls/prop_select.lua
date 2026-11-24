local controls = NewSpawnMenu.controls

function controls.PropSelect(panel, label, convar, mdlList, height)
    local PropSelect = vgui.Create('PropSelect')
    PropSelect:SetConVar(convar or '')
    PropSelect.Paint = function(_, w, h)
        controls.paintPanel(w, h)
    end
    PropSelect.List.Paint = nil
    PropSelect.Label:SetText(label or '')
    PropSelect.Label:SetFont(controls.controlFont(16))
    PropSelect.Label:SetTextColor(Mantle.color.text)
    PropSelect.Label:SetDark(false)
    PropSelect.Height = height or 2

    local firstKey, firstVal = next(mdlList)

    if istable(firstVal) and isstring(firstVal.model) then
        local tmp = {}

        for k, v in SortedPairsByMemberValue(mdlList, 'model') do
            tmp[k] = v.model:lower() .. (v.skin or 0)
        end

        for k, v in SortedPairsByValue(tmp) do
            v = mdlList[k]
            PropSelect:AddModelEx(k, v.model, v.skin or 0)
        end
    else
        for k, v in SortedPairs(mdlList) do
            PropSelect:AddModel(k, v)
        end
    end

    return panel:AddPanel(PropSelect)
end
