local convar_newspawnmenu_close_on_spawn = CreateClientConVar('newspawnmenu_close_on_spawn', 0, true, false)
local convar_newspawnmenu_mode = GetConVar('newspawnmenu_mode')
local PANEL = {}

function PANEL:Init()
    self.items = {}
    self.func = nil
    self.funcPaint = nil

    self.left = vgui.Create('MantleTabs', self)
    self.left:Dock(FILL)
    self.left:SetTabStyle('classic')
end

function PANEL:AddItem(name, category, tabl, itemIndex, categoryIcon)
    if !category then
        category = 'Other'
    end

    local menuW = NewSpawnMenu.menu:GetWide()
    local menuScale = GetConVar('newspawnmenu_scale'):GetFloat()
    local itemSize = menuW * 0.0825 - 8

    if !self.items[category] then
        local categorySp = vgui.Create('MantleScrollPanel')

        local itemsCols = (menuW * (0.65 + (convar_newspawnmenu_mode:GetInt() == 1 and 0.25 or 0)) - 12 - 240) / (itemSize)
        print(itemsCols)
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
        Mantle.func.sound('UI/buttonclick.wav')
        self.func(tabl, itemIndex)

        if convar_newspawnmenu_close_on_spawn:GetBool() then
            NewSpawnMenu.menu:Close()
        end
    end

    panelItem.DoRightClick = function()
        Mantle.func.sound()
        local dm = Mantle.ui.derma_menu()

        local className = tabl.ClassName
        local targetCopy = className and className or tabl.Class
        if targetCopy then
            dm:AddOption('#spawnmenu.menu.copy', function()
                SetClipboardText(targetCopy)
            end, 'icon16/page_copy.png')
        end

        local itemMdl = tabl.Model

        if !itemMdl then
            local wepTabl = weapons.Get(className)
            if wepTabl then
                itemMdl = wepTabl.WorldModel and wepTabl.WorldModel or wepTabl.ViewModel
            end
        end

        if itemMdl then
            dm:AddOption(Mantle.lang.get('newspawnmenu', 'inspect'), function()
                self.left:SetVisible(false)

                local inspector = vgui.Create('NewSpawnMenu.Inspector', self)
                inspector:Dock(FILL)
                inspector:SetModel(itemMdl)
                inspector:SetPan(self)
            end, 'icon16/camera.png')
        end
    end

    self.items[category].grid:AddItem(panelItem)

    return panelItem
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
