local PANEL = {}

function PANEL:Init()
    self.panel = nil
    self._openAnim = nil

    self.ModelPanel = vgui.Create('DModelPanel', self)
    self.ModelPanel:Dock(FILL)
    self.ModelPanel:SetFOV(40)

    self.ModelPanel.targetAngles = Angle(0, 0, 0)
    self.ModelPanel.currentAngles = Angle(0, 0, 0)
    self.ModelPanel.targetZoom = 1
    self.ModelPanel.currentZoom = 1
    self.ModelPanel.m_vecModelOrigin = Vector(0, 0, 0)
    self.ModelPanel.isDragging = false
    self.ModelPanel.lastMouseX = 0
    self.ModelPanel.lastMouseY = 0

    self.ModelPanel.OnMousePressed = function(panel, mouseCode)
        if mouseCode == MOUSE_LEFT then
            panel.isDragging = true
            panel.lastMouseX, panel.lastMouseY = gui.MousePos()
            panel:MouseCapture(true)
        end
    end

    self.ModelPanel.OnMouseReleased = function(panel, mouseCode)
        if mouseCode == MOUSE_LEFT then
            panel.isDragging = false
            panel:MouseCapture(false)
        end
    end

    self.ModelPanel.OnCursorMoved = function(panel, x, y)
        if !panel.isDragging then return end

        local mouseX, mouseY = gui.MousePos()
        local deltaX = mouseX - panel.lastMouseX
        local deltaY = mouseY - panel.lastMouseY

        panel.targetAngles = panel.targetAngles + Angle(deltaY * 0.5, -deltaX * 0.5, 0)
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
        entity:SetPos(panel.m_vecModelOrigin)

        local campos = panel.m_vecModelOrigin + Vector(panel.currentZoom * 50, panel.currentZoom * 50, panel.currentZoom * 25)
        panel:SetCamPos(campos)
        panel:SetLookAt(panel.m_vecModelOrigin)
    end

    self.ModelPanel.OnMouseWheeled = function(panel, delta)
        panel.targetZoom = math.Clamp(panel.targetZoom + delta * 0.1, 0.1, 5)
        return true
    end

    self.BackBtn = vgui.Create('MantleBtn', self)
    local backText = Mantle.lang.get('newspawnmenu', 'back')
    surface.SetFont('Fated.16')
    self.BackBtn:SetWide(surface.GetTextSize(backText) + 16, 52)
    self.BackBtn:SetTxt(backText)
    self.BackBtn.DoClick = function()
        self.panel.left:SetVisible(true)
        self:Remove()
    end
end

function PANEL:SetModel(mdl)
    self.ModelPanel:SetModel(mdl)

    if !self.ModelPanel.Entity then return end

    local entity = self.ModelPanel.Entity
    local min, max = entity:GetRenderBounds()
    self.ModelPanel.m_vecModelOrigin = (min + max) * 0.5

    self.ModelPanel.targetAngles = Angle(0, 0, 0)
    self.ModelPanel.currentAngles = Angle(10, 45, 0)
    self.ModelPanel.targetZoom = 1
    self.ModelPanel.currentZoom = 0.5

    self._openAnim = {
        startTime = SysTime(),
        startAngles = self.ModelPanel.currentAngles:Copy(),
        startZoom = self.ModelPanel.currentZoom
    }

    local campos = self.ModelPanel.m_vecModelOrigin + Vector(50, 50, 25)
    self.ModelPanel:SetCamPos(campos)
    self.ModelPanel:SetLookAt(self.ModelPanel.m_vecModelOrigin)
end

function PANEL:Think()
    if !IsValid(self.ModelPanel) then return end

    local anim = self._openAnim
    if !anim then return end

    local progress = (SysTime() - anim.startTime) * 2
    if progress >= 1 then
        self.ModelPanel.currentAngles = self.ModelPanel.targetAngles:Copy()
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
    self.BackBtn:SetPos(w - self.BackBtn:GetWide() - 8, 8)
end

vgui.Register('NewSpawnMenu.Inspector', PANEL, 'Panel')
