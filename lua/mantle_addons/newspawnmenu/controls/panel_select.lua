local controls = NewSpawnMenu.controls

local PANEL = {}

function PANEL:Paint(w, h)
    controls.paintPanel(w, h)
end

vgui.Register('NewSpawnMenu.PanelSelect', PANEL, 'DPanelSelect')

function controls.PanelSelect(panel)
    local panelSelect = vgui.Create('NewSpawnMenu.PanelSelect')
    panelSelect:SetTall(96)

    return panel:AddPanel(panelSelect)
end
