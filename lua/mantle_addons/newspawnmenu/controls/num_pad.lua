local PANEL = {}

AccessorFunc(PANEL, 'm_ConVar1', 'ConVar1')
AccessorFunc(PANEL, 'm_ConVar2', 'ConVar2')

local function paintBtn(btn)
    btn:SetFont('Fated.16')
    btn:SetTextColor(Mantle.color.gray)
    btn.Paint = function(_, w, h)
        RNDX.Rect(0, 0, w, h)
            :Rad(12)
            :Color(Mantle.color.panel_alpha[1])
        :Draw()
    end
end

function PANEL:Init()
    self.NumPad1 = vgui.Create('DBinder', self)
    paintBtn(self.NumPad1)
    self.Label1 = vgui.Create('DLabel', self)
    self.Label1:SetFont('Fated.16')
    self.Label1:SetTextColor(Mantle.color.text)
    self.Label1:SetDark(true)

    self.NumPad2 = vgui.Create('DBinder', self)
    paintBtn(self.NumPad2)
    self.Label2 = vgui.Create('DLabel', self)
    self.Label2:SetFont('Fated.16')
    self.Label2:SetTextColor(Mantle.color.text)
    self.Label2:SetDark(true)

    self:SetHeight(200)
end

function PANEL:SetLabel1(txt)
    if !txt then return end
    self.Label1:SetText(txt)
end

function PANEL:SetLabel2(txt)
    if !txt then return end
    self.Label2:SetText(txt)
end

function PANEL:SetConVar1(cvar)
    self.NumPad1:SetConVar(cvar)
    self.m_ConVar1 = cvar
end

function PANEL:SetConVar2(cvar)
    self.NumPad2:SetConVar(cvar)
    self.m_ConVar2 = cvar
end

function PANEL:GetValue1()
    if !self.m_ConVar1 or !IsValid(self.NumPad1) then return KEY_NONE end
    return self.NumPad1:GetValue()
end

function PANEL:GetValue2()
    if !self.m_ConVar2 or !IsValid(self.NumPad2) then return KEY_NONE end
    return self.NumPad2:GetValue()
end

function PANEL:PerformLayout()
    self:SetTall(80)

    self.NumPad1:InvalidateLayout(true)
    self.NumPad1:SetSize(100, 50)

    if self.m_ConVar2 then
        self.NumPad2:InvalidateLayout(true)
        self.NumPad2:SetSize(100, 50)
    end

    if !self.m_ConVar2 then
        self.Label1:SizeToContents()

        self.NumPad2:SetVisible(false)
        self.Label2:SetVisible(false)

        self.NumPad1:CenterHorizontal(0.5)
        self.NumPad1:AlignTop(30)

        self.Label1:CenterHorizontal()
        self.Label1:AlignTop(0)
    else
        self.Label1:SizeToContents()
        self.Label2:SizeToContents()

        self.NumPad2:SetVisible(true)
        self.Label2:SetVisible(true)

        self.NumPad1:CenterHorizontal(0.25)
        self.Label1:CenterHorizontal(0.25)
        self.NumPad1:AlignTop(30)

        self.NumPad2:CenterHorizontal(0.75)
        self.Label2:CenterHorizontal(0.75)
        self.NumPad2:AlignTop(30)
        self.Label2:AlignTop(0)
    end
end

vgui.Register('NSM.CtrlNumPad', PANEL, 'Panel')
