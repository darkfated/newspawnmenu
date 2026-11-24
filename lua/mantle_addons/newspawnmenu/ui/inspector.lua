local PANEL = {}

local function cross(a, b)
    return Vector(
        a.y * b.z - a.z * b.y,
        a.z * b.x - a.x * b.z,
        a.x * b.y - a.y * b.x
    )
end

local function buttonWidth(text)
    surface.SetFont('Fated.16')
    local w = surface.GetTextSize(text)

    return w + 16
end

function PANEL:Init()
    self.panel = nil
    self._openAnim = nil
    self._defaultAngles = Angle(0, 0, 0)
    self._defaultZoom = 1

    self.ModelPanel = vgui.Create('DModelPanel', self)
    self.ModelPanel:Dock(FILL)
    self.ModelPanel:SetFOV(40)

    self.ModelPanel.targetAngles = Angle(0, 0, 0)
    self.ModelPanel.currentAngles = Angle(0, 0, 0)
    self.ModelPanel.targetZoom = 1
    self.ModelPanel.currentZoom = 1
    self.ModelPanel.m_vecModelOrigin = Vector(0, 0, 0)
    self.ModelPanel.panOffset = Vector(0, 0, 0)
    self.ModelPanel.rotating = false
    self.ModelPanel.panning = false
    self.ModelPanel.lastMouseX = 0
    self.ModelPanel.lastMouseY = 0

    self.ModelPanel.OnMousePressed = function(panel, mouseCode)
        if mouseCode != MOUSE_LEFT and mouseCode != MOUSE_RIGHT then return end

        if mouseCode == MOUSE_LEFT then
            panel.rotating = true
        else
            panel.panning = true
        end

        panel.lastMouseX, panel.lastMouseY = gui.MousePos()
        panel:MouseCapture(true)
    end

    self.ModelPanel.OnMouseReleased = function(panel, mouseCode)
        if mouseCode == MOUSE_LEFT then
            panel.rotating = false
        elseif mouseCode == MOUSE_RIGHT then
            panel.panning = false
        end

        if !panel.rotating and !panel.panning then panel:MouseCapture(false) end
    end

    self.ModelPanel.OnCursorMoved = function(panel, x, y)
        if !panel.rotating and !panel.panning then return end

        local mouseX, mouseY = gui.MousePos()
        local deltaX = mouseX - panel.lastMouseX
        local deltaY = mouseY - panel.lastMouseY

        if panel.rotating then
            panel.targetAngles = panel.targetAngles + Angle(deltaY * 0.5, -deltaX * 0.5, 0)
        else
            local forward = Vector(-50, -50, -25)
            forward:Normalize()

            local right = cross(forward, Vector(0, 0, 1))
            right:Normalize()

            local up = cross(right, forward)
            up:Normalize()

            local scale = 0.18 * panel.currentZoom
            panel.panOffset = panel.panOffset + right * (deltaX * scale) - up * (deltaY * scale)
        end

        panel.lastMouseX, panel.lastMouseY = mouseX, mouseY
    end

    self.ModelPanel.LayoutEntity = function(panel, entity)
        local dt = FrameTime()

        panel.currentAngles.p = Mantle.func.approachExp(
            panel.currentAngles.p,
            panel.targetAngles.p,
            8,
            dt
        )
        panel.currentAngles.y = Mantle.func.approachExp(
            panel.currentAngles.y,
            panel.targetAngles.y,
            8,
            dt
        )
        panel.currentAngles.r = Mantle.func.approachExp(
            panel.currentAngles.r,
            panel.targetAngles.r,
            8,
            dt
        )

        panel.currentZoom = Mantle.func.approachExp(
            panel.currentZoom,
            panel.targetZoom,
            6,
            dt
        )

        entity:SetAngles(panel.currentAngles)
        entity:SetPos(panel.m_vecModelOrigin + panel.panOffset)

        local campos = panel.m_vecModelOrigin + Vector(panel.currentZoom * 50, panel.currentZoom * 50, panel.currentZoom * 25)
        panel:SetCamPos(campos)
        panel:SetLookAt(panel.m_vecModelOrigin)
    end

    self.ModelPanel.OnMouseWheeled = function(panel, delta)
        panel.targetZoom = math.Clamp(panel.targetZoom + delta * 0.1, 0.1, 5)
        return true
    end

    self.Hint = vgui.Create('MantleText', self)
    self.Hint:SetText(Mantle.lang.get('newspawnmenu', 'inspect_hint'))
    self.Hint:SetFont('Fated.14')
    self.Hint:SetColor(Mantle.color.text)
    self.Hint:SetVAlign(TEXT_ALIGN_CENTER)
    self.Hint:SetMouseInputEnabled(false)

    self.BackBtn = vgui.Create('MantleBtn', self)
    local backText = Mantle.lang.get('newspawnmenu', 'back')
    self.BackBtn:SetWide(buttonWidth(backText), 52)
    self.BackBtn:SetTxt(backText)
    self.BackBtn.DoClick = function()
        if IsValid(self.panel) and IsValid(self.panel.left) then
            self.panel.left:SetVisible(true)
        end

        self:Remove()
    end

    self.ResetBtn = vgui.Create('MantleBtn', self)
    local resetText = Mantle.lang.get('newspawnmenu', 'inspect_reset')
    self.ResetBtn:SetWide(buttonWidth(resetText), 52)
    self.ResetBtn:SetTxt(resetText)
    self.ResetBtn.DoClick = function()
        self:ResetView()
    end
end

function PANEL:SetModel(mdl)
    self.ModelPanel.panOffset = Vector(0, 0, 0)
    self.ModelPanel:SetModel(mdl)

    if !self.ModelPanel.Entity then return end

    local entity = self.ModelPanel.Entity
    local min, max = entity:GetRenderBounds()
    self.ModelPanel.m_vecModelOrigin = (min + max) * 0.5

    local defaultAngles = self._defaultAngles
    self.ModelPanel.targetAngles = Angle(defaultAngles.p, defaultAngles.y, defaultAngles.r)
    self.ModelPanel.currentAngles = Angle(10, 45, 0)
    self.ModelPanel.targetZoom = self._defaultZoom
    self.ModelPanel.currentZoom = 0.5

    local current = self.ModelPanel.currentAngles
    self._openAnim = {
        startTime = SysTime(),
        startAngles = Angle(current.p, current.y, current.r),
        startZoom = self.ModelPanel.currentZoom
    }

    local campos = self.ModelPanel.m_vecModelOrigin + Vector(50, 50, 25)
    self.ModelPanel:SetCamPos(campos)
    self.ModelPanel:SetLookAt(self.ModelPanel.m_vecModelOrigin)
end

function PANEL:ResetView()
    if !IsValid(self.ModelPanel) then return end

    local defaultAngles = self._defaultAngles
    self.ModelPanel.targetAngles = Angle(defaultAngles.p, defaultAngles.y, defaultAngles.r)
    self.ModelPanel.currentAngles = Angle(defaultAngles.p, defaultAngles.y, defaultAngles.r)
    self.ModelPanel.targetZoom = self._defaultZoom
    self.ModelPanel.currentZoom = self._defaultZoom
    self.ModelPanel.panOffset = Vector(0, 0, 0)
    self._openAnim = nil
end

function PANEL:Think()
    if !IsValid(self.ModelPanel) then return end

    local anim = self._openAnim
    if !anim then return end

    local progress = (SysTime() - anim.startTime) * 2
    if progress >= 1 then
        local target = self.ModelPanel.targetAngles
        self.ModelPanel.currentAngles = Angle(target.p, target.y, target.r)
        self.ModelPanel.currentZoom = self.ModelPanel.targetZoom
        self._openAnim = nil

        return
    end

    local eased = Mantle.func.easeInOutCubic(progress)
    local startAngles = anim.startAngles
    local targetAngles = self.ModelPanel.targetAngles

    self.ModelPanel.currentAngles = Angle(
        startAngles.p + (targetAngles.p - startAngles.p) * eased,
        startAngles.y + (targetAngles.y - startAngles.y) * eased,
        startAngles.r + (targetAngles.r - startAngles.r) * eased
    )
    self.ModelPanel.currentZoom = anim.startZoom + (self.ModelPanel.targetZoom - anim.startZoom) * eased
end

function PANEL:SetPan(pan)
    self.panel = pan
end

function PANEL:PerformLayout(w, h)
    local x = w - self.BackBtn:GetWide() - 8

    self.BackBtn:SetPos(x, 8)
    self.ResetBtn:SetPos(x - self.ResetBtn:GetWide() - 6, 8)
    self.Hint:SetPos(8, h - 28)
    self.Hint:SetSize(w - 16, 24)
end

function PANEL:OnRemove()
    if IsValid(self.ModelPanel) then self.ModelPanel:MouseCapture(false) end

    if self.BaseClass and self.BaseClass.OnRemove then self.BaseClass.OnRemove(self) end
end

vgui.Register('NewSpawnMenu.Inspector', PANEL, 'Panel')
