local controls = NewSpawnMenu.controls

local PANEL = {}

local function configureBinder(binder)
    binder:SetFont(controls.controlFont(16))
    binder:SetText('')

    binder.UpdateText = function(self)
        local key = input.GetKeyName(self:GetSelectedNumber()) or '#dbinder.none'
        self._displayText = language.GetPhrase(key)
    end

    binder.DoClick = function(self)
        self._displayText = language.GetPhrase('#dbinder.press_a_key')
        input.StartKeyTrapping()
        self.Trapping = true
    end

    binder:UpdateText()

    binder.Paint = function(self, w, h)
        controls.paintField(w, h)
        draw.SimpleText(
            self._displayText or '',
            self:GetFont(),
            w * 0.5,
            h * 0.5,
            Mantle.color.text,
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER
        )
    end

    binder.DoRightClick = function()
        local menu = Mantle.ui.derma_menu()

        menu:AddOption(language.GetPhrase('#tool.reset_to_default'), function()
            if IsValid(binder) and binder:GetDefaultNumber() != 0 then
                binder:SetValue(binder:GetDefaultNumber())
            end
        end)

        menu:AddOption(language.GetPhrase('#tool.clear'), function()
            if IsValid(binder) then binder:SetValue(0) end
        end)
    end
end

local function makeLabel(parent)
    local label = vgui.Create('MantleText', parent)
    label:SetFont(controls.controlFont(16))
    label:SetColor(Mantle.color.text)
    label:SetAlign(TEXT_ALIGN_CENTER)
    label:SetVAlign('center')
    label.padding = 0
    label:SetMouseInputEnabled(false)

    return label
end

local function setLabel(panel, index, txt)
    if !txt then return end

    panel['Label' .. index]:SetText(language.GetPhrase(txt))
end

local function setConVar(panel, index, cvar)
    panel['NumPad' .. index]:SetConVar(cvar)
    panel['m_ConVar' .. index] = cvar
end

local function place(binder, label, cx, binderW)
    label:SetPos(cx - binderW * 0.5, 4)
    label:SetSize(binderW, 24)
    binder:SetPos(cx - binderW * 0.5, 38)
    binder:SetSize(binderW, 34)
    binder:InvalidateLayout(true)
end

function PANEL:Init()
    self.NumPad1 = vgui.Create('DBinder', self)
    configureBinder(self.NumPad1)

    self.Label1 = makeLabel(self)

    self.NumPad2 = vgui.Create('DBinder', self)
    configureBinder(self.NumPad2)

    self.Label2 = makeLabel(self)
end

function PANEL:SetLabel1(txt)
    setLabel(self, 1, txt)
end

function PANEL:SetLabel2(txt)
    setLabel(self, 2, txt)
end

function PANEL:SetConVar1(cvar)
    setConVar(self, 1, cvar)
end

function PANEL:SetConVar2(cvar)
    setConVar(self, 2, cvar)
end

function PANEL:GetConVar1()
    return self.m_ConVar1
end

function PANEL:GetConVar2()
    return self.m_ConVar2
end

function PANEL:GetValue1()
    if !self.m_ConVar1 or !IsValid(self.NumPad1) then return KEY_NONE end
    return self.NumPad1:GetValue()
end

function PANEL:GetValue2()
    if !self.m_ConVar2 or !IsValid(self.NumPad2) then return KEY_NONE end
    return self.NumPad2:GetValue()
end

function PANEL:PerformLayout(w, h)
    self:SetTall(76)

    local binderW = math.min(160, math.max(100, w * 0.28))

    if !self.m_ConVar2 then
        place(self.NumPad1, self.Label1, w * 0.5, binderW)
        self.NumPad2:SetVisible(false)
        self.Label2:SetVisible(false)
    else
        place(self.NumPad1, self.Label1, w * 0.25, binderW)
        place(self.NumPad2, self.Label2, w * 0.75, binderW)
        self.NumPad2:SetVisible(true)
        self.Label2:SetVisible(true)
    end
end

vgui.Register('NSM.CtrlNumPad', PANEL, 'Panel')
