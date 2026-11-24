local convar_wizard = CreateClientConVar('newspawnmenu_theme_wizard', 1, true, false)
local wizard

function NewSpawnMenu.OpenThemeWizard()
    if !convar_wizard:GetBool() or !IsValid(NewSpawnMenu.menu) then return end
    if IsValid(wizard) then return end

    local panel = vgui.Create('Panel', NewSpawnMenu.menu)
    wizard = panel
    panel:SetZPos(100)
    panel:SetSize(400, 200)
    panel:Center()
    panel:SetMouseInputEnabled(true)
    panel:DockPadding(12, 12, 12, 12)
    panel.Paint = function(_, w, h)
        NewSpawnMenu.PanelPaint(w, h)
    end

    local text = vgui.Create('MantleText', panel)
    text:Dock(TOP)
    text:DockMargin(0, -6, 0, 0)
    text:SetTall(60)
    text:SetFont('Fated.16')
    text:SetColor(Mantle.color.text)
    text:SetText(NewSpawnMenu.settings.L('wizard_text_1'))
    text:SetVAlign(TEXT_ALIGN_CENTER)

    local combo = NewSpawnMenu.settings.themeCombo()
    combo:SetParent(panel)
    combo:Dock(TOP)
    combo:DockMargin(0, 0, 0, 4)

    local hint = vgui.Create('MantleText', panel)
    hint:Dock(TOP)
    hint:SetTall(20)
    hint:SetFont('Fated.16')
    hint:SetColor(Mantle.color.gray)
    hint:SetText(NewSpawnMenu.settings.L('wizard_text_2'))
    hint:SetAlign(TEXT_ALIGN_CENTER)
    hint:SetVAlign(TEXT_ALIGN_CENTER)

    local ready = vgui.Create('MantleBtn', panel)
    ready:Dock(BOTTOM)
    ready:SetTxt(NewSpawnMenu.settings.L('wizard_ready'))
    ready.DoClick = function()
        Mantle.func.sound()
        RunConsoleCommand('newspawnmenu_theme_wizard', '0')
        if IsValid(panel) then panel:Remove() end
    end

    panel.OnRemove = function()
        wizard = nil
    end
end
