local controls = NewSpawnMenu.controls

local math_floor = math.floor
local math_max = math.max

local PANEL = {}

function PANEL:Init()
    self:SetMouseInputEnabled(false)
    self:SetKeyboardInputEnabled(false)

    self:SetFont(controls.controlFont(16))
    self:SetColor(Mantle.color.gray)
    self:SetAlign(TEXT_ALIGN_CENTER)
    self:SetVAlign('center')
    self.padding = 8
end

function PANEL:SetText(text)
    self.BaseClass.SetText(self, text)
    self:UpdateHeight()
end

function PANEL:SetFont(font)
    self.BaseClass.SetFont(self, font)
    self:UpdateHeight()
end

function PANEL:SetTextColor(color)
    self:SetColor(color)
end

function PANEL:GetTextColor()
    return self.color or Mantle.color.text
end

function PANEL:SetDark()
end

function PANEL:UpdateHeight(w)
    w = w or self:GetWide()
    if w <= 0 then return end
    if self._updatingHeight then return end

    local text = self:GetText() or ''
    if !self._dirty and self._lastAutoW == w and self._lastAutoText == text and self._lastAutoFont == self.font then
        return
    end

    self._updatingHeight = true

    self:SetTall(10000)
    self._dirty = true
    self:_rebuild(w, 10000)

    local lines = self._lines and #self._lines or 1
    local lineH = self._lineH or 16
    local tall = math_max(34, math_floor(lines * lineH + 16 + 0.5))

    self:SetTall(tall)
    self._dirty = true
    self:_rebuild(w, tall)

    self._lastAutoW = w
    self._lastAutoText = text
    self._lastAutoFont = self.font
    self._updatingHeight = false
end

function PANEL:PerformLayout(w, h)
    self.BaseClass.PerformLayout(self, w, h)

    if !self._updatingHeight then
        self:UpdateHeight(w)
    end
end

function PANEL:Paint(w, h)
    RNDX.Rect(0, 0, w, h)
        :Rad(14)
        :Color(Mantle.color.panel_alpha[2])
        :Shape(RNDX.SHAPE_IOS)
    :Draw()

    self.BaseClass.Paint(self, w, h)
end

vgui.Register('NewSpawnMenu.HelpLabel', PANEL, 'MantleText')
