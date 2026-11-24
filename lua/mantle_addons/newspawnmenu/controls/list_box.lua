local controls = NewSpawnMenu.controls

local function styleColumnLabel(label)
    if !IsValid(label) then return end

    label:SetFont(controls.controlFont(14))
    label:SetTextColor(Mantle.color.text)
    label:SetDark(false)
end

local function styleLine(line)
    line.Paint = function(self, w, h)
        if self:IsLineSelected() then
            RNDX.Rect(0, 0, w, h)
                :Rad(8)
                :Color(Mantle.color.focus_panel)
            :Draw()
        elseif self:IsHovered() then
            RNDX.Rect(0, 0, w, h)
                :Rad(8)
                :Color(Mantle.color.hover_overlay)
            :Draw()
        end
    end

    for _, label in pairs(line.Columns or {}) do
        styleColumnLabel(label)
    end
end

local function styleVBar(vbar)
    if !IsValid(vbar) then return end

    vbar:SetHideButtons(true)
    vbar.Paint = function() return true end

    if IsValid(vbar.btnGrip) then
        vbar.btnGrip.Paint = function(_, w, h)
            RNDX.Rect(0, 0, w, h)
                :Rad(4)
                :Color(Mantle.color.focus_panel)
            :Draw()
        end
    end
end

function controls.ListBox(panel, data)
    if data.height then
        local ctrl = vgui.Create('DListView')
        ctrl:SetMultiSelect(false)
        ctrl:SetHeaderHeight(28)
        ctrl:SetTall(data.height)
        ctrl:SetDataHeight(30)
        controls.paintContainer(ctrl)
        styleVBar(ctrl.VBar)

        local column = ctrl:AddColumn(data.label or 'unknown')
        if IsValid(column) and IsValid(column.Header) then
            column.Header:SetFont(controls.controlFont(14))
            column.Header:SetTextColor(Mantle.color.gray)
            column.Header.Paint = function(self, w, h)
                draw.SimpleText(self:GetText(), controls.controlFont(14), 10, h * 0.5, Mantle.color.gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
        end

        if data.options then
            for k, v in pairs(data.options) do
                local line = ctrl:AddLine(k)
                line.data = v
                styleLine(line)

                if controls.anyConvarMatches(line.data) then
                    line:SetSelected(true)
                end
            end
        end

        ctrl:SortByColumn(1, false)

        function ctrl:OnRowSelected(LineID, Line)
            controls.applyConvarTable(Line.data)
        end

        return panel:AddPanel(ctrl)
    end

    return controls.ComboBoxMulti(panel, data.label, data.options)
end
