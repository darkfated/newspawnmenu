local PANEL = {}

function PANEL:Init()
    self.ContentType = 'prop'
end

vgui.Register('NewSpawnMenu.Tabs.Props', PANEL, 'NewSpawnMenu.Content')
