local controls = NewSpawnMenu.controls

local PANEL = {}

function PANEL:Init()
    self:SetFont(controls.controlFont(16))
    self:SetTextColor(Mantle.color.text)
    self:SetPaintBackgroundEnabled(false)
    self:HideWang()
    self:SetTall(controls.metrics.rowHeight)
end

function PANEL:Paint(w, h)
    controls.paintField(w, h)

    local inset = controls.metrics.radius * 0.6
    draw.SimpleText(
        self:GetText(),
        self:GetFont(),
        inset,
        h * 0.5,
        self:IsEnabled() and Mantle.color.text or Mantle.color.gray,
        TEXT_ALIGN_LEFT,
        TEXT_ALIGN_CENTER
    )
end

vgui.Register('NewSpawnMenu.NumberWang', PANEL, 'DNumberWang')

function controls.NumberWang(panel, label, convar, min, max, decimals)
    local wang = vgui.Create('NewSpawnMenu.NumberWang')
    wang:SetMinMax(min or 0, max or 100)

    if decimals != nil then
        wang:SetDecimals(decimals)
    end

    if convar then
        wang:SetConVar(convar)
    end

    wang:SizeToContents()

    return controls.addLabeledControl(panel, wang, label, controls.metrics.rowHeight)
end
