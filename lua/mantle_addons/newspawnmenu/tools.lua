local convar_newspawnmenu_search_panel = CreateClientConVar('newspawnmenu_search_panel', 1, true, false)
local convar_newspawnmenu_compact_tools = CreateClientConVar('newspawnmenu_compact_tools', 0, true, false)
local convar_newspawnmenu_toolname_left = CreateClientConVar('newspawnmenu_toolname_left', 0, true, false)
local convar_newspawnmenu_contrast_tools = CreateClientConVar('newspawnmenu_contrast_tools', 1, true, false)
local PANEL = {}

function PANEL:Init()
    self:DockPadding(8, 8, 8, 8)

    self.categoryTabs = vgui.Create('MantleTabs', self)
    self.categoryTabs:Dock(FILL)

    local tools = spawnmenu.GetTools()
    local activeTool = GetConVar('gmod_toolmode'):GetString()
    local foundActiveTool = false
    local textFont = 'Fated.' .. math.floor(16 * GetConVar('newspawnmenu_scale'):GetFloat())

    for k, toolCategory in ipairs(tools) do
        local categoryContent = vgui.Create('Panel', self.categoryTabs)
        categoryContent:Dock(FILL)
        self.categoryTabs:AddTab(toolCategory.Label, categoryContent, Material(toolCategory.Icon))

        local leftPanel = vgui.Create('Panel', categoryContent)
        leftPanel:Dock(LEFT)
        leftPanel:DockMargin(0, 0, 8, 0)
        leftPanel:SetWide(math.max(200, NewSpawnMenu.menu:GetWide() * 0.115))

        local spTools = vgui.Create('MantleScrollPanel', leftPanel)
        spTools:Dock(FILL)

        local toolContent = vgui.Create('Panel', categoryContent)
        toolContent:Dock(FILL)

        local function BuildTools(filter)
            spTools:Clear()

            local isCompactTools = convar_newspawnmenu_compact_tools:GetBool()
            local isToolnameLeft = convar_newspawnmenu_toolname_left:GetBool()

            for i, groupTools in ipairs(toolCategory.Items) do
                local category = vgui.Create('MantleCategory', spTools)
                category:Dock(TOP)
                if !isToolnameLeft then
                    category:SetCenterText(true)
                end

                local categoryName = language.GetPhrase(groupTools.Text)
                if categoryName[1] == '#' then
                    categoryName = string.sub(categoryName, 2)
                end

                category:SetText(categoryName)
                category:SetActive(true)

                for n, toolGroup in ipairs(groupTools) do
                    local toolName = language.GetPhrase(toolGroup.Text)
                    if toolName[1] == '#' then
                        toolName = string.sub(toolName, 2)
                    end

                    if !string.find(utf8.lower(toolName), utf8.lower(filter), 1, true) then
                        continue
                    end

                    local btnTool = vgui.Create('MantleBtn', category)
                    btnTool:Dock(TOP)
                    btnTool:SetTall(isCompactTools and 26 or 34)
                    btnTool:SetTxt('')
                    btnTool.Paint = function(s, w, h)
                        local convarTool = GetConVar('gmod_toolmode'):GetString()
                        local isContrastTools = convar_newspawnmenu_contrast_tools:GetBool()
                        local col = Mantle.color.theme
                        if convarTool != toolGroup.ItemName then
                            col = s:IsHovered() and isContrastTools and Mantle.color.text or Mantle.color.gray
                        end

                        if isContrastTools then
                            RNDX().Rect(4, 4, w - 8, h - 8)
                                :Rad(32)
                                :Color(Mantle.color.panel_alpha[2])
                                :Shape(RNDX.SHAPE_IOS)
                            :Draw()
                        end

                        if isToolnameLeft then
                            draw.SimpleText(toolName, textFont, isContrastTools and 12 or 8, h * 0.5, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                        else
                            draw.SimpleText(toolName, textFont, w * 0.5, h * 0.5, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                        end
                    end

                    local function createContent(boolCommand)
                        local cnt = vgui.Create('NewSpawnMenu.ControlPanel', toolContent)
                        cnt:Dock(FILL)
                        pcall(function()
                            if boolCommand then
                                LocalPlayer():ConCommand(toolGroup.Command)
                            end
                            toolGroup.CPanelFunction(cnt, toolGroup)
                        end)
                    end

                    btnTool.DoClick = function()
                        Mantle.func.sound()

                        toolContent:Clear()
                        createContent(true)
                    end
                    btnTool.DoRightClick = function()
                        Mantle.func.sound()
                        local dm = Mantle.ui.derma_menu()
                        dm:AddOption('#spawnmenu.menu.copy', function()
                            SetClipboardText(toolGroup.ItemName)
                        end, 'icon16/page_copy.png')
                    end

                    if toolGroup.ItemName == activeTool and !foundActiveTool then
                        foundActiveTool = true
                        createContent()
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
            searchBox:SetTall(26)
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
