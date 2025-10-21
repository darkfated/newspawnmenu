local PANEL = {}

function PANEL:Init()
    self:DockPadding(8, 8, 8, 8)

    self.categoryTabs = vgui.Create('MantleTabs', self)
    self.categoryTabs:Dock(FILL)

    local tools = spawnmenu.GetTools()

    for k, toolCategory in ipairs(tools) do
        local categoryContent = vgui.Create('Panel', self.categoryTabs)
        categoryContent:Dock(FILL)
        self.categoryTabs:AddTab(toolCategory.Label, categoryContent)

        local panelTools = vgui.Create('MantleScrollPanel', categoryContent)
        panelTools:Dock(LEFT)
        panelTools:DockMargin(0, 0, 8, 0)
        panelTools:SetWide(Mantle.func.sw * 0.1)

        local toolContent = vgui.Create('Panel', categoryContent)
        toolContent:Dock(FILL)

        for i, groupTools in ipairs(toolCategory.Items) do
            local category = vgui.Create('MantleCategory', panelTools)
            category:Dock(TOP)
            category:SetCenterText(true)
            category:SetText(groupTools.Text)
            category:SetActive(true)

            for n, toolGroup in ipairs(groupTools) do
                local btnTool = vgui.Create('MantleBtn', category)
                btnTool:Dock(TOP)
                btnTool:SetTall(40)
                btnTool:SetTxt('')
                btnTool.Paint = function(_, w, h)
                    local convarTool = GetConVar('gmod_toolmode'):GetString()
                    local col = convarTool == toolGroup.ItemName and Mantle.color.theme or Mantle.color.gray

                    draw.SimpleText(toolGroup.Text, 'Fated.16', w * 0.5, h * 0.5, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
                btnTool.DoClick = function()
                    Mantle.func.sound()
                    LocalPlayer():ConCommand(toolGroup.Command)

                    toolContent:Clear()
                    local cnt = vgui.Create('NewSpawnMenu.ControlPanel', toolContent)
                    cnt:Dock(FILL)
                    toolGroup.CPanelFunction(cnt)
                end

                category:AddItem(btnTool)
            end
        end
    end
end

function PANEL:Paint(w, h)
    NewSpawnMenu.PanelPaint(w, h)
end

vgui.Register('NewSpawnMenu.Tools', PANEL, 'EditablePanel')
