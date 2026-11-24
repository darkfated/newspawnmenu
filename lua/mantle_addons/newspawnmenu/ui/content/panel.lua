local convar_close_on_spawn = CreateClientConVar('newspawnmenu_close_on_spawn', 0, true, false)
local convar_mode = GetConVar('newspawnmenu_mode')
local math_floor = math.floor

local mat_admin = Material('icon16/shield.png')
local mat_npc_weapon = Material('icon16/monkey.png')
local mat_npc_weapon_on = Material('icon16/monkey_tick.png')
local text_shadow = Color(0, 0, 0, 200)

local function tabMaterial(icon)
    if !isstring(icon) or icon == '' then return nil end

    local mat = Material(icon)
    if !mat or mat:IsError() then return nil end

    return mat
end

local function makeGrid()
    local grid = vgui.Create('NewSpawnMenu.ContentGrid')
    grid:Dock(TOP)

    return grid
end

local function configureGrid(grid)
    local isWide = convar_mode:GetInt() == 1

    grid:Configure(isWide and 8 or 6, isWide and 6 or 4, 8, 100)
end

local function makeSection(parent, title)
    local section = vgui.Create('MantleCategory')
    section:Dock(TOP)
    section:DockMargin(8, 0, 8, 6)
    section:SetText(title)
    section:SetActive(true)

    parent:AddItem(section)

    local grid = makeGrid()
    section:AddItem(grid)

    return grid
end

local PANEL = {}

function PANEL:Init()
    self.items = {}
    self.func = nil
    self.funcMiddle = nil
    self.funcTool = nil
    self.funcPaint = nil

    self.left = vgui.Create('MantleTabs', self)
    self.left:Dock(FILL)
    self.left:SetTabStyle('classic')
end

function PANEL:AddItem(name, category, tabl, itemIndex, categoryIcon)
    if !category then
        category = 'Other'
    end

    local categoryData = self.items[category]
    if !categoryData then
        local holder = vgui.Create('Panel')
        local scroll = vgui.Create('MantleScrollPanel', holder)

        scroll:Dock(FILL)

        categoryData = {
            holder = holder,
            scroll = scroll,
            sections = {}
        }

        self.items[category] = categoryData
        self.left:AddTab(language.GetPhrase(category), holder, tabMaterial(categoryIcon))
    end

    local subRaw = istable(tabl) and isstring(tabl.SubCategory) and tabl.SubCategory or ''
    local sectionTitle = subRaw != '' and language.GetPhrase(subRaw) or language.GetPhrase(category)
    local section = categoryData.sections[subRaw]

    if !section then
        section = makeSection(categoryData.scroll, sectionTitle)
        categoryData.sections[subRaw] = section
    end

    local grid = section

    configureGrid(grid)

    local panelItem = vgui.Create('Button')
    panelItem:SetSize(grid._itemSize or 100, grid._itemSize or 100)
    panelItem:SetText('')
    panelItem.anim_scale = 1
    panelItem.anim_target = 1
    panelItem.anim_speed = 10

    panelItem._syncModelIcon = function(btn)
        if !IsValid(btn.modelIcon) then return end

        local scale = btn.anim_scale or 1
        local w, h = btn:GetSize()
        local scaledW, scaledH = w * scale, h * scale
        local offsetX, offsetY = (w - scaledW) * 0.5, (h - scaledH) * 0.5
        local fontI = math_floor(14 * GetConVar('newspawnmenu_scale'):GetFloat())
        local labelH = fontI * 2
        local pad = 6
        local availW = scaledW - pad * 2
        local availH = scaledH - labelH - pad * 2
        local size = math_floor(math.max(1, math.min(availW, availH)))

        btn.modelIcon:SetPos(
            math_floor(offsetX + (scaledW - size) * 0.5),
            math_floor(offsetY + (scaledH - labelH - size) * 0.5)
        )
        btn.modelIcon:SetSize(size, size)
    end

    panelItem.SetModelFallback = function(btn, model, skin, bodyGroups)
        if !isstring(model) or model == '' then return end

        if IsValid(btn.modelIcon) then
            btn.modelIcon:Remove()
        end

        local icon = vgui.Create('ModelImage', btn)
        icon:SetMouseInputEnabled(false)
        icon:SetKeyboardInputEnabled(false)

        local groups = tostring(bodyGroups or '000000000')
        if groups:len() != 9 then
            groups = '000000000'
        end

        icon:SetModel(model, skin or 0, groups)
        if icon.RebuildSpawnIcon then
            icon:RebuildSpawnIcon()
        end

        btn.modelIcon = icon
        btn:_syncModelIcon()
    end

    panelItem.OnSizeChanged = function(btn)
        btn:_syncModelIcon()
    end

    panelItem.Paint = function(btn, w, h)
        local scale = btn.anim_scale
        local scaledW, scaledH = w * scale, h * scale
        local offsetX, offsetY = (w - scaledW) * 0.5, (h - scaledH) * 0.5

        RNDX.Rect(offsetX, offsetY, scaledW, scaledH)
            :Rad(32)
            :Color(Mantle.color.panel_alpha[1])
            :Shape(RNDX.SHAPE_IOS)
        :Draw()

        if self.funcPaint then
            self.funcPaint(name, itemIndex, tabl, scaledW, scaledH, btn, offsetX, offsetY)
        else
            self:PaintItem(name, itemIndex, tabl, scaledW, scaledH, btn, offsetX, offsetY)
        end
    end

    panelItem.Think = function(btn)
        local dt = FrameTime()

        if btn:IsHovered() and !btn:IsDown() then
            btn.anim_target = 0.95
        elseif btn:IsDown() then
            btn.anim_target = 0.89
        else
            btn.anim_target = 1
        end

        btn.anim_scale = Mantle.func.approachExp(btn.anim_scale, btn.anim_target, btn.anim_speed, dt)

        if IsValid(btn.modelIcon) then btn:_syncModelIcon() end
    end

    panelItem.DoClick = function()
        if !self.func then return end

        Mantle.func.sound('UI/buttonclick.wav')
        self.func(tabl, itemIndex)

        if convar_close_on_spawn:GetBool() then
            NewSpawnMenu.menu:Close()
        end
    end

    panelItem.DoMiddleClick = function()
        if !self.funcMiddle then return end

        Mantle.func.sound('UI/buttonclick.wav')
        self.funcMiddle(tabl)

        if convar_close_on_spawn:GetBool() then
            NewSpawnMenu.menu:Close()
        end
    end

    panelItem.DoRightClick = function()
        Mantle.func.sound()
        NewSpawnMenu.content.openItemMenu(self, name, itemIndex, tabl, self.ContentType)
    end

    grid:AddItem(panelItem)

    return panelItem
end

function PANEL:PaintItem(name, itemIndex, tabl, w, h, btn, offsetX, offsetY)
    local ox = offsetX or 0
    local oy = offsetY or 0
    local mat = btn.mat or btn.icon
    local fontI = math_floor(14 * GetConVar('newspawnmenu_scale'):GetFloat())
    local textFont = 'Fated.' .. fontI
    local isNameLeft = GetConVar('newspawnmenu_itemname_left'):GetBool()

    if mat then
        if !NewSpawnMenu.convar.opt then
            RNDX.Rect(ox, oy, w, h)
                :Rad(24)
                :Shape(RNDX.SHAPE_IOS)
                :KBlur(4, 2)
            :Draw()
        end

        render.PushFilterMag(TEXFILTER.ANISOTROPIC)
        render.PushFilterMin(TEXFILTER.ANISOTROPIC)
            RNDX.Rect(ox, oy, w, h)
                :Rad(24)
                :Material(mat)
                :Shape(RNDX.SHAPE_IOS)
            :Draw()
        render.PopFilterMin()
        render.PopFilterMag()
    end

    if btn.adminOnly then
        surface.SetMaterial(mat_admin)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRect(ox + 6, oy + 6, 14, 14)
    end

    if btn.npcWeapon then
        local active = GetConVarString('gmod_npcweapon') == btn.spawnName
        surface.SetMaterial(active and mat_npc_weapon_on or mat_npc_weapon)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRect(ox + w - 20, oy + 6, 14, 14)
    end

    local labelH = fontI * 2

    RNDX.Rect(ox, oy + h - labelH, w, labelH)
        :Radii(0, 0, 24, 24)
        :Color(Mantle.color.panel_alpha[2])
        :Shape(RNDX.SHAPE_IOS)
    :Draw()

    local text = tostring(name or '')
    surface.SetFont(textFont)
    local textW = select(1, surface.GetTextSize(text))
    local maxW = w - 16
    local textX, textAlign

    if textW > maxW then
        textAlign = TEXT_ALIGN_LEFT
        textX = 8

        if btn:IsHovered() then
            local scrollPad = math.min(40, w * 0.45)
            local scrollW = math.max(1, w - scrollPad * 2)
            local mx = btn:ScreenToLocal(gui.MouseX(), gui.MouseY()) - ox
            local progress = math.Clamp((mx - scrollPad) / scrollW, 0, 1)

            textX = textX - progress * (textW - maxW)
        end
    elseif isNameLeft then
        textAlign = TEXT_ALIGN_LEFT
        textX = 8
    else
        textAlign = TEXT_ALIGN_CENTER
        textX = w * 0.5
    end

    local sx, sy = btn:LocalToScreen(ox + 6, oy + h - labelH)
    local ex, ey = btn:LocalToScreen(ox + w - 6, oy + h)

    render.SetScissorRect(sx, sy, ex, ey, true)
        draw.SimpleText(text, textFont, ox + textX + 1, oy + h - fontI * 0.5, text_shadow, textAlign, TEXT_ALIGN_BOTTOM)
        draw.SimpleText(text, textFont, ox + textX, oy + h - fontI * 0.5 - 1, Mantle.color.text, textAlign, TEXT_ALIGN_BOTTOM)
    render.SetScissorRect(0, 0, 0, 0, false)
end

function PANEL:AddFunc(func)
    self.func = func
end

function PANEL:AddFuncMiddle(func)
    self.funcMiddle = func
end

function PANEL:AddFuncTool(func)
    self.funcTool = func
end

function PANEL:AddFuncPaint(func)
    self.funcPaint = func
end

vgui.Register('NewSpawnMenu.Content', PANEL, 'Panel')
