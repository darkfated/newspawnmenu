local controls = NewSpawnMenu.controls

local PANEL = {}

function PANEL:Init()
    controls.stylePicker(self)
    self:SetItemWidth(0.14)
    self:SetItemHeight(0.3)
    self:SetAutoHeight(true)

    for k, v in pairs(list.Get('RopeMaterials') or {}) do
        self:AddMaterial(k, v)
    end
end

vgui.Register('NSM.RopeMaterial', PANEL, 'MatSelect')
