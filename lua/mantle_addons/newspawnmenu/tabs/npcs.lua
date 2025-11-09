local PANEL = {}
local math_floor = math.floor

function PANEL:Init()
    self:AddFunc(function(tabl, itemIndex)
        RunConsoleCommand('gmod_spawnnpc', itemIndex)
    end)

    local fontI = math_floor(14 * GetConVar('newspawnmenu_scale'):GetFloat())
    local textFont = 'Fated.' .. fontI
    local isNameLeft = GetConVar('newspawnmenu_itemname_left'):GetBool()

    self:AddFuncPaint(function(name, itemIndex, tabl, w, h, btn)
        local scale = btn.anim_scale
        local offset = (1 - scale) * 0.5
        local scaledW = w * scale
        local scaledH = h * scale
        local x = offset * w
        local y = offset * h

        if btn.mat then
            if !NewSpawnMenu.convar.opt then
                RNDX().Rect(0, 0, w, h)
                    :Rad(32)
                    :Material(btn.mat)
                    :Shape(RNDX.SHAPE_IOS)
                :Draw()

                RNDX().Rect(0, 0, w, h)
                    :Rad(24)
                    :Shape(RNDX.SHAPE_IOS)
                    :Blur(2, 8)
                :Draw()
            end

            render.PushFilterMag(TEXFILTER.ANISOTROPIC)
            render.PushFilterMin(TEXFILTER.ANISOTROPIC)
                RNDX().Rect(x, y, scaledW, scaledH)
                    :Rad(24)
                    :Material(btn.mat)
                    :Shape(RNDX.SHAPE_IOS)
                :Draw()
            render.PopFilterMin()
            render.PopFilterMag()
        end

        RNDX().Rect(0, h - fontI * 2, w, fontI * 2)
            :Radii(0, 0, 24, 24)
            :Color(Mantle.color.panel_alpha[2])
            :Shape(RNDX.SHAPE_IOS)
        :Draw()
        if isNameLeft then
            draw.SimpleText(name, textFont, 8, h - fontI * 0.5 - 1, Mantle.color.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
        else
            draw.SimpleText(name, textFont, w * 0.5, h - fontI * 0.5 - 1, Mantle.color.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
        end
    end)

    local npcs = list.Get('NPC')
    local customIcons = list.Get('ContentCategoryIcons')

    for k, npc in pairs(npcs) do
        local btn = self:AddItem(npc.Name, npc.Category, npc, k, customIcons[npc.Category] or 'icon16/monkey.png')

        local matName = npc.IconOverride or 'entities/' .. k .. '.png'
        local mat = Material(matName)

        if mat:IsError() then
            matName = matName:Replace('entities/', 'vgui/entities/'):Replace('.png', '')
            mat = Material(matName)
        end

        if !mat:IsError() then
            btn.mat = mat
        end
    end
end

vgui.Register('NewSpawnMenu.Tabs.NPCS', PANEL, 'NewSpawnMenu.Content')

NewSpawnMenu.CreateTab(4, '#spawnmenu.category.npcs', 'icon16/monkey.png', 'NewSpawnMenu.Tabs.NPCS')
