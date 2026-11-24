local controls = NewSpawnMenu.controls

function controls.PropSelect(panel, label, convar, mdlList, height)
    mdlList = mdlList or {}

    local ctrl = vgui.Create('PropSelect')
    ctrl:SetConVar(convar or '')
    controls.stylePicker(ctrl)
    ctrl.Label:SetText(label or '')
    ctrl.Label:SetFont(controls.controlFont(16))
    ctrl.Label:SetTextColor(Mantle.color.text)
    ctrl.Label:SetDark(false)
    ctrl.Height = height or 2

    local _, firstVal = next(mdlList)

    if istable(firstVal) and isstring(firstVal.model) then
        local tmp = {}

        for k, v in SortedPairsByMemberValue(mdlList, 'model') do
            tmp[k] = v.model:lower() .. (v.skin or 0)
        end

        for k, v in SortedPairsByValue(tmp) do
            v = mdlList[k]
            ctrl:AddModelEx(k, v.model, v.skin or 0)
        end
    else
        for k, v in SortedPairs(mdlList) do
            ctrl:AddModel(k, v)
        end
    end

    return panel:AddPanel(ctrl)
end
