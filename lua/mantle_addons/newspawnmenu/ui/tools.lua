local convar_newspawnmenu_search_panel = CreateClientConVar('newspawnmenu_search_panel', 1, true, false)
local convar_newspawnmenu_compact_tools = CreateClientConVar('newspawnmenu_compact_tools', 0, true, false)
local convar_newspawnmenu_toolname_left = CreateClientConVar('newspawnmenu_toolname_left', 0, true, false)
local convar_newspawnmenu_contrast_tools = CreateClientConVar('newspawnmenu_contrast_tools', 1, true, false)

local PANEL = {}

function PANEL:Init()
    self.toolsByMode = {}
    NewSpawnMenu.tools = self

    NewSpawnMenu.api.tools.install(self)

    self.categoryTabs = vgui.Create('MantleTabs', self)
    self.categoryTabs:Dock(FILL)

    local activeTool = GetConVar('gmod_toolmode'):GetString()

    for index, toolCategory in ipairs(spawnmenu.GetTools()) do
        self:BuildCategory(index, toolCategory)
    end

    if activeTool != '' and IsValid(NewSpawnMenu.menu) then
        NewSpawnMenu.menu.StartupTool = { Name = activeTool }
    end
end

function PANEL:BuildCategory(index, toolCategory)
    local categoryContent = vgui.Create('Panel', self.categoryTabs)
    categoryContent:Dock(FILL)
    categoryContent.ItemName = toolCategory.Name

    local tabId = self.categoryTabs:AddTab(toolCategory.Label, categoryContent, Material(toolCategory.Icon))
    local tabData = self.categoryTabs.tabs[tabId]

    local leftPanel = vgui.Create('Panel', categoryContent)
    leftPanel:Dock(LEFT)
    leftPanel:SetWide(math.max(200, NewSpawnMenu.menu:GetWide() * 0.12))

    local spTools = vgui.Create('MantleScrollPanel', leftPanel)
    spTools:Dock(FILL)

    local toolContent = vgui.Create('Panel', categoryContent)
    toolContent:Dock(FILL)

    self:RegisterToolPanel(index, categoryContent, toolContent, tabData and tabData._btn)

    local function buildTools(filter)
        spTools:Clear()

        local isCompactTools = convar_newspawnmenu_compact_tools:GetBool()
        local isToolnameLeft = convar_newspawnmenu_toolname_left:GetBool()
        local textFont = 'Fated.' .. math.floor(16 * GetConVar('newspawnmenu_scale'):GetFloat())

        for _, groupTools in ipairs(toolCategory.Items) do
            local categoryName = language.GetPhrase(groupTools.Text or groupTools.ItemName or '')
            if categoryName[1] == '#' then categoryName = categoryName:sub(2) end

            local category = vgui.Create('MantleCategory', spTools)
            category:Dock(TOP)
            category:DockMargin(0, 0, 0, 0)
            if !isToolnameLeft then category:SetCenterText(true) end
            category:SetText(categoryName)
            category:SetActive(true)

            for _, toolGroup in ipairs(groupTools) do
                local toolName = language.GetPhrase(toolGroup.Text or toolGroup.ItemName or '')
                if toolName[1] == '#' then toolName = toolName:sub(2) end

                if !string.find(utf8.lower(toolName), utf8.lower(filter), 1, true) then continue end

                local btnTool = vgui.Create('MantleBtn', category)
                btnTool:Dock(TOP)
                btnTool:DockMargin(0, 0, 0, 0)
                btnTool:SetTall(isCompactTools and 26 or 34)
                btnTool:SetTxt('')
                btnTool.Paint = function(s, w, h)
                    local toolMode = GetConVar('gmod_toolmode'):GetString()
                    local isContrastTools = convar_newspawnmenu_contrast_tools:GetBool()
                    local col = Mantle.color.theme
                    if toolMode != toolGroup.ItemName then
                        col = s:IsHovered() and isContrastTools and Mantle.color.text or Mantle.color.gray
                    end

                    if isContrastTools then
                        RNDX.Rect(4, 4, w - 8, h - 8)
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

                btnTool.DoClick = function()
                    Mantle.func.sound()
                    spawnmenu.ActivateTool(toolGroup.ItemName)
                end

                btnTool.DoRightClick = function()
                    Mantle.func.sound()
                    local menu = Mantle.ui.derma_menu()
                    menu:AddOption(language.GetPhrase('#spawnmenu.menu.copy'), function()
                        SetClipboardText(toolGroup.ItemName)
                    end, 'icon16/page_copy.png')
                end

                self.toolsByMode[toolGroup.ItemName] = toolGroup

                category:AddItem(btnTool)
            end
        end
    end

    buildTools('')

    if convar_newspawnmenu_search_panel:GetBool() then
        local searchBox = vgui.Create('MantleEntry', leftPanel)
        searchBox:Dock(TOP)
        searchBox:DockMargin(0, 0, 0, 4)
        searchBox:SetPlaceholder(language.GetPhrase('#spawnmenu.quick_filter'))
        searchBox.textEntry:SetUpdateOnType(true)
        searchBox.textEntry.OnValueChange = function(_, text)
            buildTools(text)
        end
    end
end

function PANEL:ShowControlPanel(controlPanel)
    if !IsValid(self.activeContent) or !IsValid(controlPanel) then return false end

    self.activeContent:Clear()

    controlPanel:SetParent(self.activeContent)
    controlPanel:Dock(FILL)
    spawnmenu.SetActiveControlPanel(controlPanel)

    self.activeControlPanel = controlPanel
    self.activeContent:InvalidateLayout(true)

    return true
end

function PANEL:Paint(w, h)
    NewSpawnMenu.PanelPaint(w, h)
end

vgui.Register('NewSpawnMenu.Tools', PANEL, 'EditablePanel')
