local api = {}
NewSpawnMenu.api.menu = api

local function createToolStub(menu)
    local stub = vgui.Create('EditablePanel', menu)
    stub:SetVisible(false)
    function stub:GetToolPanel() end
    return stub
end

local function createCreationStub(menu)
    local stub = vgui.Create('EditablePanel', menu)
    stub:SetVisible(false)
    function stub:GetCreationTab() end
    function stub:GetCreationTabs() return {} end
    function stub:SwitchToName() return false end
    return stub
end

function api.install(menu)
    function menu:Open()
        if !IsValid(self) then return end

        RestoreCursorPosition()
        self:SetHangOpen(false)

        if IsValid(g_ContextMenu) and g_ContextMenu:IsVisible() then
            g_ContextMenu:Close()
        end

        if self:IsVisible() then return end

        CloseDermaMenus()
        self:SetVisible(true)
        self:SetKeyboardInputEnabled(false)
        self:SetMouseInputEnabled(true)

        achievements.SpawnMenuOpen()

        local startupTool = self.StartupTool
        if !startupTool and IsValid(NewSpawnMenu.tools) then
            local activeTool = GetConVar('gmod_toolmode')
            activeTool = activeTool and activeTool:GetString() or ''
            if activeTool != '' then startupTool = { Name = activeTool } end
        end

        if startupTool and startupTool.Name then
            if ispanel(startupTool) and startupTool.SetSelected then
                startupTool:SetSelected(true)
            end

            spawnmenu.ActivateTool(startupTool.Name, true)
            self.StartupTool = nil
        end
    end

    function menu:Close()
        if self:GetHangOpen() then
            self:SetHangOpen(false)
            return
        end

        if self:IsVisible() then RememberCursorPosition() end

        CloseDermaMenus()
        self:SetKeyboardInputEnabled(false)
        self:SetMouseInputEnabled(false)
        self:SetVisible(false)
    end

    function menu:SetHangOpen(state)
        self.HangOpen = state and true or false
    end

    function menu:GetHangOpen()
        return self.HangOpen == true
    end

    function menu:StartFocus(panel)
        self.Focus = panel
        self:SetHangOpen(true)
        self:SetKeyboardInputEnabled(true)
    end

    function menu:EndFocus(panel)
        if self.Focus != panel then return end
        self.Focus = nil
        self:SetKeyboardInputEnabled(false)
    end

    menu.StartKeyFocus = menu.StartFocus
    menu.EndKeyFocus = menu.EndFocus

    function menu:GetToolMenu()
        if IsValid(NewSpawnMenu.tools) then return NewSpawnMenu.tools end
        if !IsValid(self.toolMenuStub) then self.toolMenuStub = createToolStub(self) end
        return self.toolMenuStub
    end

    function menu:GetCreationMenu()
        if IsValid(NewSpawnMenu.main) then return NewSpawnMenu.main end
        if !IsValid(self.creationMenuStub) then self.creationMenuStub = createCreationStub(self) end
        return self.creationMenuStub
    end

    function menu:OpenCreationMenuTab(name)
        local creationMenu = self:GetCreationMenu()
        if creationMenu.SwitchToName then return creationMenu:SwitchToName(name) end
        return false
    end
end
