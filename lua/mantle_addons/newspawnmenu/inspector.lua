local PANEL = {}

function PANEL:Init()
    self.panel = nil
    -- NewSpawnMenu.menu:StartFocus(self)

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
        -- NewSpawnMenu.menu:EndFocus(self)
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

    local startTime = SysTime()
    local startAngles = self.ModelPanel.currentAngles
    local startZoom = self.ModelPanel.currentZoom

    local animateOpen = function()
        local progress = (SysTime() - startTime) * 2
        if progress < 1 then
            local eased = Mantle.func.easeInOutCubic(progress)

            self.ModelPanel.currentAngles = Angle(
                startAngles.p + (self.ModelPanel.targetAngles.p - startAngles.p) * eased,
                startAngles.y + (self.ModelPanel.targetAngles.y - startAngles.y) * eased,
                startAngles.r + (self.ModelPanel.targetAngles.r - startAngles.r) * eased
            )

            self.ModelPanel.currentZoom = startZoom + (self.ModelPanel.targetZoom - startZoom) * eased
        else
            self.ModelPanel.currentAngles = self.ModelPanel.targetAngles
            self.ModelPanel.currentZoom = self.ModelPanel.targetZoom
            hook.Remove('Think', 'SpawnMenuInspectorOpen')
        end
    end

    hook.Add('Think', 'SpawnMenuInspectorOpen', animateOpen)

    local campos = self.ModelPanel.m_vecModelOrigin + Vector(50, 50, 25)
    self.ModelPanel:SetCamPos(campos)
    self.ModelPanel:SetLookAt(self.ModelPanel.m_vecModelOrigin)
end

function PANEL:SetPan(pan)
    self.panel = pan
end

function PANEL:PerformLayout(w, h)
    self.BackBtn:SetPos(w - self.BackBtn:GetWide() - 8, 8)
end

vgui.Register('NewSpawnMenu.Inspector', PANEL, 'Panel')
