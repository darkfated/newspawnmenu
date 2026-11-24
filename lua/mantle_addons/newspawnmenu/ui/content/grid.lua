local math_floor = math.floor

local PANEL = {}

function PANEL:Init()
    self.BaseClass.Init(self)
    self.gap = 8
    self.minItemSize = 100
    self.preferredCols = 8
    self.fallbackCols = 6
    self._itemSize = 100
    self._batchDepth = 0
end

function PANEL:InvalidateLayout(layoutNow)
    if self._batchDepth > 0 then return end

    self.BaseClass.InvalidateLayout(self, layoutNow)
end

function PANEL:BeginBatch()
    self._batchDepth = self._batchDepth + 1
end

function PANEL:EndBatch()
    if self._batchDepth == 0 then return end

    self._batchDepth = self._batchDepth - 1
    if self._batchDepth == 0 then self.BaseClass.InvalidateLayout(self, true) end
end

function PANEL:Configure(preferredCols, fallbackCols, gap, minItemSize)
    self.preferredCols = math.max(1, math_floor(preferredCols or 8))
    self.fallbackCols = math.max(1, math_floor(fallbackCols or self.preferredCols))
    self.gap = math.max(0, math_floor(gap or 8))
    self.minItemSize = math.max(1, math_floor(minItemSize or 100))
    self:InvalidateLayout(true)
end

function PANEL:PerformLayout()
    local availW = math.max(1, self:GetWide())
    local gap = self.gap
    local minItemSize = self.minItemSize
    local cols = self.preferredCols

    if math_floor(availW / cols) - gap < minItemSize then
        cols = self.fallbackCols
    end

    while cols > 1 and math_floor(availW / cols) - gap < minItemSize do
        cols = cols - 1
    end

    local cellW = math.max(gap + 1, math_floor(availW / cols))
    local itemSize = math.max(1, cellW - gap)

    self._itemSize = itemSize
    self:SetCols(cols)
    self:SetColWide(cellW)
    self:SetRowHeight(cellW)

    local i = 0
    for _, item in ipairs(self.Items or {}) do
        if IsValid(item) and item:IsVisible() then
            item:SetPos((i % cols) * cellW, math_floor(i / cols) * cellW)

            if item:GetWide() != itemSize or item:GetTall() != itemSize then
                item:SetSize(itemSize, itemSize)
            end

            i = i + 1
        end
    end

    self:SetTall(math.ceil(i / cols) * cellW)
end

vgui.Register('NewSpawnMenu.ContentGrid', PANEL, 'DGrid')
