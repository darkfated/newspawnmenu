local controls = NewSpawnMenu.controls

local math_floor = math.floor
local math_abs = math.abs

local RADIUS = 12
local PAD = 12
local LERP_SNAP = 0.005

local PANEL = {}

local function findChoice(self, text, data, exact)
    for index, choice in ipairs(self.choices or {}) do
        if choice.text == text then
            if exact then
                if choice.data == data then return index end
            elseif data == nil or choice.data == data then
                return index
            end
        end
    end
end

local function findValueChoice(self, value)
    for index, choice in ipairs(self.choices or {}) do
        if choice.data != nil and tostring(choice.data) == value then
            return index, choice
        end
    end

    for index, choice in ipairs(self.choices or {}) do
        if choice.text == value then
            return index, choice
        end
    end
end

local function choiceAt(self, index)
    return self.choices and self.choices[index] or nil
end

local function applySelected(self, index, choice)
    if index then
        self.selected = choice.text
        self.selectedIndex = index
    else
        self.selected = nil
        self.selectedIndex = nil
    end
end

local function sortChoices(self)
    local selectedText = self.selected

    table.sort(self.choices, function(a, b)
        return tostring(a.text) < tostring(b.text)
    end)

    if !selectedText then return end

    for index, choice in ipairs(self.choices) do
        if choice.text == selectedText then
            self.selectedIndex = index
            return
        end
    end
end

local function approach(current, target, speed, ft)
    if current == target then return current end

    local value = Mantle.func.approachExp(current or 0, target, speed, ft)
    if math_abs(value - target) < LERP_SNAP then return target end

    return value
end

local function roundedRect(w, h, color, outline)
    local shape = RNDX.Rect(0, 0, w, h)
        :Rad(RADIUS)
        :Color(color)

    if outline then shape:Outline(1) end

    shape:Draw()
end

local function paintButton(combo, button, w, h)
    local ft = FrameTime()

    combo.hoverAnim = approach(combo.hoverAnim or 0, button:IsHovered() and 1 or 0, 12, ft)
    combo._focusLerp = approach(combo._focusLerp or 0, combo.opened and 1 or 0, 10, ft)

    roundedRect(w, h, Mantle.color.focus_panel)

    if combo.hoverAnim > 0.01 then
        local hv = Mantle.color.hover_overlay
        roundedRect(w, h, Color(hv.r, hv.g, hv.b, math_floor(hv.a * combo.hoverAnim)))
    end

    if combo._focusLerp > 0.01 then
        local theme = Mantle.color.theme
        roundedRect(w, h, Color(theme.r, theme.g, theme.b, math_floor(60 * combo._focusLerp)))
        roundedRect(w, h, Color(theme.r, theme.g, theme.b, math_floor(160 * combo._focusLerp)), true)
    end

    local text, col
    if combo.selected then
        text = combo.selected
        col = Mantle.color.theme
    else
        text = combo.placeholder or ''
        col = Mantle.color.gray
    end

    draw.SimpleText(text, combo:GetFont() or controls.controlFont(16), PAD, h * 0.5, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

function PANEL:Init()
    self.BaseClass.Init(self)
    self.m_bDoSort = true
    self.btn.Paint = function(button, w, h)
        paintButton(self, button, w, h)
    end
end

function PANEL:SetValue(value)
    applySelected(self, findValueChoice(self, value))
end

function PANEL:ConVarStringThink()
    if !self.m_strConVar then return end

    local convar = GetConVar(self.m_strConVar)
    if !convar then return end

    local index, choice = findValueChoice(self, convar:GetString())
    if index then
        if self.selectedIndex != index or self.selected != choice.text then
            applySelected(self, index, choice)
        end
    elseif self.selected or self.selectedIndex then
        applySelected(self)
    end
end

function PANEL:Think()
    self.BaseClass.Think(self)
    self:ConVarStringThink()
end

function PANEL:SetSortItems(state)
    self.m_bDoSort = not not state

    if self.m_bDoSort then
        sortChoices(self)
    end
end

function PANEL:GetSortItems()
    return self.m_bDoSort == true
end

function PANEL:AddChoice(text, data, select)
    local index = self.BaseClass.AddChoice(self, text, data)

    if self.m_bDoSort then
        sortChoices(self)
        index = findChoice(self, text, data, true) or index
    end

    if select then
        self:SelectChoice(select == true and index or select)
    else
        self:ConVarStringThink()
    end

    return index
end

function PANEL:AddOption(text, data)
    return self:AddChoice(text, data)
end

function PANEL:AddItem(text, data)
    return self:AddChoice(text, data)
end

function PANEL:GetOptionText(index)
    local choice = choiceAt(self, index)
    return choice and choice.text or nil
end

function PANEL:GetOptionData(index)
    local choice = choiceAt(self, index)
    return choice and choice.data or nil
end

function PANEL:GetSelectedID()
    return self.selectedIndex
end

function PANEL:GetSelected()
    return self.selected, self:GetOptionData(self.selectedIndex or 0)
end

function PANEL:ChooseOption(value, index)
    index = index or findChoice(self, value)
    if !index then return end

    self:SelectChoice(index)
end

function PANEL:ChooseOptionID(index)
    self:SelectChoice(index)
end

function PANEL:RemoveChoice(index)
    if !isnumber(index) or !self.choices or !self.choices[index] then return end

    self:CloseMenu()

    local choice = table.remove(self.choices, index)

    if self.selectedIndex == index then
        applySelected(self)
    elseif self.selectedIndex and self.selectedIndex > index then
        self.selectedIndex = self.selectedIndex - 1
    end

    return choice.text, choice.data
end

function PANEL:Clear()
    self:CloseMenu()

    self.choices = {}
    self.selected = nil
    self.selectedIndex = nil
end

function PANEL:SetConVar(name)
    self.m_strConVar = name
    self:ConVarStringThink()
end

function PANEL:GetConVar()
    return self.m_strConVar
end

function PANEL:SetHeaderHeight(height)
    self.m_iHeaderHeight = height
    self:SetTall(height)
end

function PANEL:GetHeaderHeight()
    return self.m_iHeaderHeight or self:GetTall()
end

function PANEL:SetFont(font)
    self.m_Font = font
end

function PANEL:GetFont()
    return self.m_Font
end

vgui.Register('NewSpawnMenu.ComboBox', PANEL, 'MantleComboBox')

function controls.ComboBox(panel, label, convar)
    local combobox = vgui.Create('NewSpawnMenu.ComboBox')
    combobox:SetPlaceholder('')

    if convar then
        combobox:SetConVar(convar)
    end

    combobox.OnSelect = function(index, value, data)
        if !combobox.m_strConVar then return end
        RunConsoleCommand(combobox.m_strConVar, tostring(data or value))
    end

    return controls.addLabeledControl(panel, combobox, label, controls.metrics.rowHeight)
end
