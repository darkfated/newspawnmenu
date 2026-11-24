local convar_close_on_spawn = CreateClientConVar('newspawnmenu_close_on_spawn', 0, true, false)
local convar_mode = GetConVar('newspawnmenu_mode')
local math_floor = math.floor

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

    local isWide = convar_mode:GetInt() == 1
    local gap = 8
    local preferredCols = isWide and 8 or 6
    local fallbackCols = isWide and 6 or 4

    if !self.items[category] then
        local categorySp = vgui.Create('MantleScrollPanel')

        categorySp.grid = vgui.Create('NewSpawnMenu.ContentGrid', categorySp)
        categorySp.grid:Dock(TOP)

        self.items[category] = categorySp
        self.left:AddTab(category, self.items[category], Material(categoryIcon))
    end

    local grid = self.items[category].grid
    grid:Configure(preferredCols, fallbackCols, gap, 100)

    local panelItem = vgui.Create('Button')
    panelItem:SetSize(grid._itemSize or 100, grid._itemSize or 100)
    panelItem:SetText('')
    panelItem.anim_scale = 1
    panelItem.anim_target = 1
    panelItem.anim_speed = 10

    panelItem.Paint = function(btn, w, h)
        local dt = FrameTime()

        btn.anim_scale = Mantle.func.approachExp(btn.anim_scale, btn.anim_target, btn.anim_speed, dt)
        local eased = Mantle.func.easeOutCubic(btn.anim_scale)
        local scale = eased
        local scaledW, scaledH = w * scale, h * scale
        local offsetX, offsetY = (w - scaledW) * 0.5, (h - scaledH) * 0.5

        RNDX.Rect(offsetX, offsetY, scaledW, scaledH)
            :Rad(32)
            :Color(Mantle.color.panel_alpha[1])
            :Shape(RNDX.SHAPE_IOS)
        :Draw()

        if self.funcPaint then
            self.funcPaint(name, itemIndex, tabl, scaledW, scaledH, btn)
        else
            self:PaintItem(name, itemIndex, tabl, scaledW, scaledH, btn)
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

function PANEL:PaintItem(name, itemIndex, tabl, w, h, btn)
    local scale = btn.anim_scale
    local offset = (1 - scale) * 0.5
    local scaledW = w * scale
    local scaledH = h * scale
    local x = offset * w
    local y = offset * h
    local mat = btn.mat or btn.icon
    local fontI = math_floor(14 * GetConVar('newspawnmenu_scale'):GetFloat())
    local textFont = 'Fated.' .. fontI
    local isNameLeft = GetConVar('newspawnmenu_itemname_left'):GetBool()

    if mat then
        if !NewSpawnMenu.convar.opt then
            RNDX.Rect(0, 0, w, h)
                :Rad(32)
                :Material(mat)
                :Shape(RNDX.SHAPE_IOS)
            :Draw()

            RNDX.Rect(0, 0, w, h)
                :Rad(24)
                :Shape(RNDX.SHAPE_IOS)
                :KBlur(4, 2)
            :Draw()
        end

        render.PushFilterMag(TEXFILTER.ANISOTROPIC)
        render.PushFilterMin(TEXFILTER.ANISOTROPIC)
            RNDX.Rect(x, y, scaledW, scaledH)
                :Rad(24)
                :Material(mat)
                :Shape(RNDX.SHAPE_IOS)
            :Draw()
        render.PopFilterMin()
        render.PopFilterMag()
    end

    RNDX.Rect(0, h - fontI * 2, w, fontI * 2)
        :Radii(0, 0, 24, 24)
        :Color(Mantle.color.panel_alpha[2])
        :Shape(RNDX.SHAPE_IOS)
    :Draw()
    if isNameLeft then
        draw.SimpleText(name, textFont, 8, h - fontI * 0.5 - 1, Mantle.color.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
    else
        draw.SimpleText(name, textFont, w * 0.5, h - fontI * 0.5 - 1, Mantle.color.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
    end
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
