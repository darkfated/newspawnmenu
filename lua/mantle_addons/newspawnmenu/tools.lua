local convar_newspawnmenu_search_panel = CreateClientConVar('newspawnmenu_search_panel', 1, true, false)
local PANEL = {}

function PANEL:Init()
    self:DockPadding(8, 8, 8, 8)

    self.categoryTabs = vgui.Create('MantleTabs', self)
    self.categoryTabs:Dock(FILL)

    local tools = spawnmenu.GetTools()

    for k, toolCategory in ipairs(tools) do
        local categoryContent = vgui.Create('Panel', self.categoryTabs)
        categoryContent:Dock(FILL)
        self.categoryTabs:AddTab(toolCategory.Label, categoryContent, Material(toolCategory.Icon))

        local leftPanel = vgui.Create('Panel', categoryContent)
        leftPanel:Dock(LEFT)
        leftPanel:DockMargin(0, 0, 8, 0)
        leftPanel:SetWide(Mantle.func.sw * 0.1)

        local spTools = vgui.Create('MantleScrollPanel', leftPanel)
        spTools:Dock(FILL)

        local toolContent = vgui.Create('Panel', categoryContent)
        toolContent:Dock(FILL)

        local function BuildTools(filter)
            spTools:Clear()

            for i, groupTools in ipairs(toolCategory.Items) do
                local category = vgui.Create('MantleCategory', spTools)
                category:Dock(TOP)
                category:SetCenterText(true)
                category:SetText(groupTools.Text)
                category:SetActive(true)

                for n, toolGroup in ipairs(groupTools) do
                    if !string.find(string.lower(toolGroup.Text), string.lower(filter)) then
                        continue
                    end

                    local btnTool = vgui.Create('MantleBtn', category)
                    btnTool:Dock(TOP)
                    btnTool:SetTall(36)
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
                        pcall(function()
                            toolGroup.CPanelFunction(cnt, toolGroup)
                        end)
                    end
                    btnTool.DoRightClick = function()
                        Mantle.func.sound()
                        local dm = Mantle.ui.derma_menu()
                        dm:AddOption('#spawnmenu.menu.copy', function()
                            SetClipboardText(toolGroup.ItemName)
                        end, 'icon16/page_copy.png')
                    end

                    category:AddItem(btnTool)
                end
            end
        end

        BuildTools('')

        if convar_newspawnmenu_search_panel:GetBool() then
            local searchBox = vgui.Create('MantleEntry', leftPanel)
            searchBox:Dock(TOP)
            searchBox:DockMargin(0, 0, 0, 4)
            searchBox:SetPlaceholder('#spawnmenu.quick_filter')
            searchBox.textEntry.OnValueChange = function(_, text)
                BuildTools(text)
            end
        end
    end
end

function PANEL:Paint(w, h)
    NewSpawnMenu.PanelPaint(w, h)
end

vgui.Register('NewSpawnMenu.Tools', PANEL, 'EditablePanel')
