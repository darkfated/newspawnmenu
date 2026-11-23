local api = {}
NewSpawnMenu.api.tools = api

function api.install(panel)
    panel.toolPanels = {}

    function panel:GetToolPanel(id)
        return self.toolPanels[id]
    end

    function panel:GetToolPanels()
        return self.toolPanels
    end

    function panel:RegisterToolPanel(id, toolPanel, contentPanel, tabButton)
        self.toolPanels[id] = toolPanel

        if toolPanel.ItemName then self.toolPanels[toolPanel.ItemName] = toolPanel end

        if IsValid(tabButton) then
            toolPanel.PropertySheetTab = tabButton
        else
            local stub = vgui.Create('Panel', panel)
            stub:SetVisible(false)
            stub.DoClick = function()
                if IsValid(panel.categoryTabs) then panel.categoryTabs:SetActiveTab(id) end
            end
            toolPanel.PropertySheetTab = stub
        end

        if !IsValid(self.activeContent) then self.activeContent = contentPanel end

        function toolPanel:SetActive(controlPanel)
            if !IsValid(controlPanel) or !IsValid(contentPanel) then return end

            if self.activeControlPanel == controlPanel and controlPanel:GetParent() == contentPanel then
                controlPanel:SetVisible(true)
                panel.activeContent = contentPanel
                return
            end

            for _, child in ipairs(contentPanel:GetChildren()) do
                child:SetVisible(false)
            end

            if controlPanel:GetParent() != contentPanel then
                controlPanel:SetParent(contentPanel)
            end

            controlPanel:SetVisible(true)
            controlPanel:Dock(FILL)
            contentPanel:InvalidateLayout(true)

            self.activeControlPanel = controlPanel
            panel.activeContent = contentPanel
        end

        function toolPanel:SetActiveToolText(name)
            self.activeToolName = name
        end
    end
end
