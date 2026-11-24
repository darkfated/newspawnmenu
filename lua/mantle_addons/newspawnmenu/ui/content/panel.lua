local convar_close_on_spawn = CreateClientConVar('newspawnmenu_close_on_spawn', 0, true, false)
local convar_scale = GetConVar('newspawnmenu_scale')
local convar_name_left = GetConVar('newspawnmenu_itemname_left')
local math_floor = math.floor
local math_abs = math.abs

local mat_admin = Material('icon16/shield.png')
local mat_npc_weapon = Material('icon16/monkey.png')
local mat_npc_weapon_on = Material('icon16/monkey_tick.png')
local text_shadow = Color(0, 0, 0, 200)

local CARD_TIME_BUDGET = 0.012
local CARD_MIN_BATCH = 64
local CARD_MAX_BATCH = 1024
local ANIM_EPSILON = 0.001
local CARD_FONT_SIZE = 14

local function tabMaterial(icon)
    if !isstring(icon) or icon == '' then return nil end

    local mat = Material(icon)
    if !mat or mat:IsError() then return nil end

    return mat
end

local function phrase(value, fallback)
    if !isstring(value) or value == '' then return fallback or 'Other' end
    if !value:StartsWith('#') then return value end

    local translated = language.GetPhrase(value)
    if !isstring(translated) or translated == '' or translated == value then return fallback or value end

    return translated
end

local function configureGrid(grid)
    grid:Configure(7, 6, 8, 96)
end

local function makeGrid(panel)
    local grid = vgui.Create('NewSpawnMenu.ContentGrid')
    grid:Dock(TOP)

    if IsValid(panel) then
        panel:ConfigureGrid(grid)
    else
        configureGrid(grid)
    end

    return grid
end

local function makeSection(parent, title, panel)
    local section = vgui.Create('MantleCategory')
    section:Dock(TOP)
    section:DockMargin(8, 0, 8, 6)
    section:SetText(title)
    section:SetActive(true)

    parent:AddItem(section)

    local grid = makeGrid(panel)
    section:AddItem(grid)

    return grid
end

local function ensureBucketScroll(bucket)
    if IsValid(bucket.scroll) then return bucket.scroll end

    bucket.scroll = vgui.Create('MantleScrollPanel', bucket.panel)
    bucket.scroll:Dock(FILL)

    return bucket.scroll
end

local function ensureScroll(categoryData)
    if IsValid(categoryData.scroll) then return categoryData.scroll end

    if IsValid(categoryData.tabs) and categoryData.tabsData[1] then
        return ensureBucketScroll(categoryData.tabsData[1])
    end

    categoryData.scroll = vgui.Create('MantleScrollPanel', categoryData.holder)
    categoryData.scroll:Dock(FILL)

    return categoryData.scroll
end

local function ensureTabs(categoryData)
    if IsValid(categoryData.tabs) then return categoryData.tabs end

    if IsValid(categoryData.scroll) then
        categoryData.scroll:Remove()
        categoryData.scroll = nil
    end

    local tabs = vgui.Create('MantleTabs', categoryData.holder)
    tabs:Dock(FILL)
    tabs:DockMargin(0, 0, 0, 0)
    tabs:SetTabStyle('classic')
    tabs:SetClassicTabWidth(240)

    categoryData.tabs = tabs
    categoryData.tabsData = {}

    return tabs
end

local function ensureBucketSection(bucket, title, panel)
    title = phrase(title, 'Other')

    local section = bucket.sections[title]
    if section then return section end

    section = {
        title = title,
        grid = makeSection(ensureBucketScroll(bucket), title, panel)
    }

    bucket.sections[title] = section

    return section
end

local function createCategory(panel, category, icon)
    local holder = vgui.Create('Panel')
    local categoryData = {
        holder = holder,
        sections = {},
        tabsData = {}
    }

    panel.items[category] = categoryData
    categoryData.tabId = panel:EnsureLeft():AddTab(phrase(category, 'Other'), holder, tabMaterial(icon))

    return categoryData
end

local function ensureCategory(panel, category, icon)
    if !isstring(category) or category == '' then category = 'Other' end

    return panel.items[category] or createCategory(panel, category, icon)
end

local PANEL = {}

function PANEL:Init()
    self.items = {}
    self.func = nil
    self.funcMiddle = nil
    self.funcPaintOver = nil
    self._cardQueue = { items = {}, head = 1 }
    self._animCards = {}
end

function PANEL:ConfigureGrid(grid)
    configureGrid(grid)
end

function PANEL:EnsureLeft(force)
    if !force and IsValid(self.left) then return self.left end

    if IsValid(self.left) then self.left:Remove() end

    self.left = vgui.Create('MantleTabs', self)
    self.left:Dock(FILL)
    self.left:SetTabStyle('classic')
    self.left:SetClassicTabWidth(240)

    return self.left
end

function PANEL:OnRemove()
    self:ClearCardQueue()
end

function PANEL:Think()
    self:ProcessCardQueue()
    self:ProcessCardAnimations()
end

function PANEL:AddCategory(category, icon)
    return ensureCategory(self, category, icon)
end

function PANEL:CreateTabBucket(tabs, title, icon)
    if !IsValid(tabs) then return end

    local panelTab = vgui.Create('Panel')

    local bucket = {
        panel = panelTab,
        title = phrase(title, 'Other'),
        sections = {}
    }

    bucket.id = tabs:AddTab({ title = bucket.title }, panelTab, tabMaterial(icon))

    return bucket
end

function PANEL:AddTabBucket(categoryData, title, icon)
    if !istable(categoryData) then categoryData = ensureCategory(self, categoryData, icon) end

    local tabs = ensureTabs(categoryData)
    local bucket = self:CreateTabBucket(tabs, title, icon)
    if !bucket then return end

    categoryData.tabsData[#categoryData.tabsData + 1] = bucket

    if #categoryData.tabsData == 1 then tabs:SetActiveTab(bucket.id, true) end

    return bucket
end

function PANEL:AddSectionGrid(bucket, title)
    return ensureBucketSection(bucket, title, self).grid
end

function PANEL:AddLazySection(bucket, title, onExpand)
    local section = vgui.Create('MantleCategory')
    section:Dock(TOP)
    section:DockMargin(8, 0, 8, 6)
    section:SetText(phrase(title, 'Other'))
    section:SetActive(false)

    ensureBucketScroll(bucket):AddItem(section)

    local loaded = false
    local doClick = section.header.DoClick

    section.header.DoClick = function()
        if !loaded then
            loaded = true

            local grid = makeGrid(self)
            section:AddItem(grid)

            if onExpand then onExpand(section, grid) end
        end

        doClick()
    end

    return section
end

function PANEL:ClearCardQueue()
    self._cardQueue = { items = {}, head = 1 }
    self._animCards = {}
end

function PANEL:SetCardTarget(btn, target)
    if !IsValid(btn) then return end

    btn.anim_target = target

    if !btn._animQueued then
        btn._animQueued = true
        self._animCards[#self._animCards + 1] = btn
    end
end

function PANEL:ProcessCardAnimations()
    local cards = self._animCards
    if #cards == 0 then return end

    local dt = FrameTime()

    for i = #cards, 1, -1 do
        local btn = cards[i]

        if IsValid(btn) then
            local scale = Mantle.func.approachExp(btn.anim_scale, btn.anim_target, btn.anim_speed, dt)
            btn.anim_scale = scale

            if IsValid(btn.modelIcon) then btn:_syncModelIcon() end

            if math_abs(scale - btn.anim_target) < ANIM_EPSILON then
                btn.anim_scale = btn.anim_target
                btn._animQueued = false
                table.remove(cards, i)
            end
        else
            table.remove(cards, i)
        end
    end
end

function PANEL:QueueCard(job)
    local queue = self._cardQueue
    queue.items[#queue.items + 1] = job
end

function PANEL:ProcessCardQueue()
    local queue = self._cardQueue
    local deadline = SysTime() + CARD_TIME_BUDGET
    local count = 0
    local grids = {}

    while count < CARD_MAX_BATCH do
        local job = queue.items[queue.head]
        if !job then
            if queue.head > 1 then
                queue.items = {}
                queue.head = 1
            end

            break
        end

        queue.items[queue.head] = nil
        queue.head = queue.head + 1

        local grid = job.grid
        if !IsValid(grid) then continue end

        if !grids[grid] then
            grids[grid] = true
            grid:BeginBatch()
        end

        local btn = self:CreateCard(grid, job.name, job.tabl, job.itemIndex)
        if job.onCard then job.onCard(btn) end

        count = count + 1
        if count >= CARD_MIN_BATCH and SysTime() >= deadline then break end
    end

    for grid in pairs(grids) do
        if IsValid(grid) then grid:EndBatch() end
    end
end

function PANEL:CreateCard(grid, name, tabl, itemIndex)
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

        btn.modelIcon:SetPos(math_floor((w - scaledW) * 0.5), math_floor((h - scaledH) * 0.5))
        btn.modelIcon:SetSize(math.ceil(scaledW), math.ceil(scaledH))
    end

    panelItem.SetModelFallback = function(btn, model, skin, bodyGroups)
        if !isstring(model) or model == '' then return end

        if IsValid(btn.modelIcon) then btn.modelIcon:Remove() end

        local icon = vgui.Create('ModelImage', btn)
        icon:SetMouseInputEnabled(false)
        icon:SetKeyboardInputEnabled(false)

        local groups = tostring(bodyGroups or '000000000')
        if groups:len() != 9 then groups = '000000000' end

        icon:SetModel(model, skin or 0, groups)

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
            :Rad(24)
            :Color(Mantle.color.panel_alpha[1])
            :Shape(RNDX.SHAPE_IOS)
        :Draw()

        self:PaintItem(name, itemIndex, tabl, scaledW, scaledH, btn, offsetX, offsetY)
    end

    panelItem.PaintOver = function(btn, w, h)
        local scale = btn.anim_scale
        local scaledW, scaledH = w * scale, h * scale

        self:PaintOverlay(
            name, itemIndex, tabl,
            scaledW, scaledH, btn,
            (w - scaledW) * 0.5, (h - scaledH) * 0.5
        )
    end

    panelItem.OnCursorEntered = function(btn)
        if !btn:IsDown() then self:SetCardTarget(btn, 0.95) end
    end

    panelItem.OnCursorExited = function(btn)
        if !btn:IsDown() then self:SetCardTarget(btn, 1) end
    end

    panelItem.OnDepressed = function(btn)
        self:SetCardTarget(btn, 0.89)
    end

    panelItem.OnReleased = function(btn)
        self:SetCardTarget(btn, btn:IsHovered() and 0.95 or 1)
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

    panelItem.DoRightClick = function(btn)
        Mantle.func.sound()
        NewSpawnMenu.content.openItemMenu(self, name, itemIndex, tabl, btn.contentType or self.ContentType)
    end

    grid:AddItem(panelItem)

    return panelItem
end

function PANEL:AddItem(name, category, tabl, itemIndex, categoryIcon)
    if !isstring(category) or category == '' then category = 'Other' end

    local categoryData = ensureCategory(self, category, categoryIcon)
    local subRaw = istable(tabl) and isstring(tabl.SubCategory) and tabl.SubCategory or ''
    local sectionTitle = phrase(subRaw, phrase(category, 'Other'))
    local grid = categoryData.sections[subRaw]

    if !grid then
        grid = makeSection(ensureScroll(categoryData), sectionTitle, self)
        categoryData.sections[subRaw] = grid
    end

    return self:CreateCard(grid, name, tabl, itemIndex)
end

function PANEL:PaintItem(name, itemIndex, tabl, w, h, btn, offsetX, offsetY)
    local ox = offsetX or 0
    local oy = offsetY or 0
    local mat = btn.mat or btn.icon
    if !mat then return end

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

function PANEL:PaintOverlay(name, itemIndex, tabl, w, h, btn, offsetX, offsetY)
    local ox = offsetX or 0
    local oy = offsetY or 0
    local fontI = math_floor(CARD_FONT_SIZE * convar_scale:GetFloat())
    local textFont = 'Fated.' .. fontI
    local isNameLeft = convar_name_left:GetBool()

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

    local text = tostring(name or '')
    surface.SetFont(textFont)
    local textW, textH = surface.GetTextSize(text)
    local labelH = textH + 6

    RNDX.Rect(ox, oy + h - labelH, w, labelH)
        :Radii(0, 0, 24, 24)
        :Color(Mantle.color.panel_alpha[2])
        :Shape(RNDX.SHAPE_IOS)
    :Draw()

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

    local textY = oy + h - math_floor((labelH - textH) * 0.5)

    render.SetScissorRect(sx, sy, ex, ey, true)
        draw.SimpleText(text, textFont, ox + textX + 1, textY + 1, text_shadow, textAlign, TEXT_ALIGN_BOTTOM)
        draw.SimpleText(text, textFont, ox + textX, textY, Mantle.color.text, textAlign, TEXT_ALIGN_BOTTOM)
    render.SetScissorRect(0, 0, 0, 0, false)

    if self.funcPaintOver then
        self.funcPaintOver(name, itemIndex, tabl, w, h, btn, ox, oy)
    end
end

function PANEL:AddFunc(func)
    self.func = func
end

function PANEL:AddFuncMiddle(func)
    self.funcMiddle = func
end

function PANEL:AddFuncPaintOver(func)
    self.funcPaintOver = func
end

vgui.Register('NewSpawnMenu.Content', PANEL, 'Panel')
