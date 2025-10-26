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

function PANEL:AddItem(name, category, tabl, itemIndex)
    if !self.items[category] then
        local categorySp = vgui.Create('MantleScrollPanel')

        categorySp.grid = vgui.Create('DGrid', categorySp)
        categorySp.grid:Dock(TOP)
        categorySp.grid:SetCols(itemsCols)
        categorySp.grid:SetColWide(itemSize + 8)
        categorySp.grid:SetRowHeight(itemSize + 8)

        self.items[category] = categorySp

        self.left:AddTab(category, self.items[category])
    end

    local panelItem = vgui.Create('Button')
    panelItem:SetSize(itemSize, itemSize)
    panelItem:SetText('')
    panelItem.Paint = function(_, w, h)
        RNDX().Rect(0, 0, w, h)
            :Rad(32)
            :Color(Mantle.color.panel_alpha[1])
            :Shape(RNDX.SHAPE_IOS)
        :Draw()

        self.funcPaint(name, itemIndex, tabl, w, h)
    end
    panelItem.DoClick = function()
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
