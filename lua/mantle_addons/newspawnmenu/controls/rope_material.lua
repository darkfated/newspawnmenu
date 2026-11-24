local controls = NewSpawnMenu.controls

local PANEL = {}

function PANEL:Init()
    self:SetItemWidth(0.14)
    self:SetItemHeight(0.3)
    self:SetAutoHeight(true)
    self.List.Paint = nil

    local mats = list.Get('RopeMaterials')

    for k, v in pairs(mats) do
        self:AddMaterial(k, v)
    end
end

function PANEL:Paint(w, h)
    controls.paintPanel(w, h)
end

vgui.Register('NSM.RopeMaterial', PANEL, 'MatSelect')
