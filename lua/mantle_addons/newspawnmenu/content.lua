local PANEL = {}

function PANEL:Init()
    self.items = {}
    self.func = nil
    self.funcPaint = nil

    self.left = vgui.Create('MantleTabs', self)
    self.left:Dock(FILL)
    self.left:SetTabStyle('classic')
end

local itemSize = Mantle.func.sw * 0.07
local itemsCols = Mantle.func.sw * 0.5 / (itemSize + 8)

function PANEL:AddItem(name, category, tabl, itemIndex, categoryIcon)
    if !category then
        category = 'Other'
    end

    if !self.items[category] then
        local categorySp = vgui.Create('MantleScrollPanel')

        categorySp.grid = vgui.Create('DGrid', categorySp)
        categorySp.grid:Dock(TOP)
        categorySp.grid:SetCols(itemsCols)
        categorySp.grid:SetColWide(itemSize + 8)
        categorySp.grid:SetRowHeight(itemSize + 8)

        self.items[category] = categorySp

        self.left:AddTab(category, self.items[category], Material(categoryIcon))
    end

    local panelItem = vgui.Create('Button')
    panelItem:SetSize(itemSize, itemSize)
    panelItem:SetText('')

    panelItem.anim_scale = 1
    panelItem.anim_target = 1
    panelItem.anim_speed = 8
    panelItem.is_pressed = false

    panelItem.Paint = function(btn, w, h)
        if !btn:IsDown() and btn.anim_target != 1 then
            btn.anim_target = 1
        end

        RNDX().Rect(0, 0, w, h)
            :Rad(32)
            :Color(Mantle.color.panel_alpha[1])
            :Shape(RNDX.SHAPE_IOS)
        :Draw()

        self.funcPaint(name, itemIndex, tabl, w, h, btn)
    end

    panelItem.Think = function(btn)
        local dt = FrameTime()
        btn.anim_scale = Mantle.func.approachExp(btn.anim_scale, btn.anim_target, btn.anim_speed, dt)

        if btn:IsDown() and btn.anim_target != 0.9 then
            btn.anim_target = 0.9
        end
    end

    panelItem.DoClick = function(btn)
        print(123)
        Mantle.func.sound('UI/buttonclick.wav')
        self.func(tabl, itemIndex)
    end

    self.items[category].grid:AddItem(panelItem)
end

function PANEL:AddFunc(func)
    self.func = func
end

function PANEL:AddFuncPaint(func)
    self.funcPaint = func
end

vgui.Register('NewSpawnMenu.Content', PANEL, 'Panel')

function NewSpawnMenu.CreateTab(id, name, icon, panel)
    NewSpawnMenu.tabs[id] = {
        name = name,
        icon = icon,
        panel = panel
    }
end
