-- roles_menu.cl
-- Frontend-Menü für das Roles System (unabhängig vom Faction System)

-- Erstelle eine Schriftart für das Menü
surface.CreateFont("RolesText", {
    font = "Arial",
    size = 18,
    weight = 500,
    antialias = true
})

-- Initialisiere das ROLES-Table
ROLES = ROLES or {}
ROLES.Config = ROLES.Config or {}
ROLES.Config.Colors = ROLES.Config.Colors or {}
ROLES.Config.OpenMenuKey = KEY_F7 -- Standard-Taste zum Öffnen des Menüs

function OpenRolesMenu()
    if IsValid(ROLES.Menu) then
        ROLES.Menu:AlphaTo(0, 0.3, 0, function()
            if IsValid(ROLES.Menu) then
                ROLES.Menu:Remove()
            end
        end)
        return
    end

    local rolesColors = ROLES.Config.Colors
    ROLES.Menu = vgui.Create("DFrame")
    local menu = ROLES.Menu
    local screenW, screenH = ScrW(), ScrH()

    menu:SetSize(screenW * 0.7, screenH * 0.8)
    menu:Center()
    menu:SetTitle("")
    menu:SetDraggable(false)
    menu:ShowCloseButton(true)
    menu:MakePopup()
    menu:SetAlpha(0)
    menu:AlphaTo(255, 0.3, 0)

    menu.Paint = function(self, w, h)
        Derma_DrawBackgroundBlur(self, 0)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
        draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50, 120))
    end

    local oldClose = menu.Close
    menu.Close = function(self)
        menu:AlphaTo(0, 0.3, 0, function()
            if IsValid(menu) then
                oldClose(self)
            end
        end)
    end

    local buttonWidth = menu:GetWide() * 0.2
    local buttonPanel = vgui.Create("DFrame", menu)
    buttonPanel:SetPos(10, 10)
    buttonPanel:SetSize(buttonWidth, menu:GetTall() - 20)
    buttonPanel:SetTitle("")
    buttonPanel:SetDraggable(false)
    buttonPanel:ShowCloseButton(false)
    buttonPanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(40, 40, 40, 180))
        surface.SetDrawColor(255, 255, 255, 100)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
    end

    local contentPanel = vgui.Create("DFrame", menu)
    contentPanel:SetPos(buttonWidth + 20, 10)
    contentPanel:SetSize(menu:GetWide() - buttonWidth - 30, menu:GetTall() - 20)
    contentPanel:SetTitle("")
    contentPanel:SetDraggable(false)
    contentPanel:ShowCloseButton(false)
    contentPanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(40, 40, 40, 180))
        surface.SetDrawColor(255, 255, 255, 100)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
    end

    local contentContainer = vgui.Create("DScrollPanel", contentPanel)
    contentContainer:Dock(FILL)

    local buttonHeight = 40
    local buttonSpacing = 10
    local yOffset = 10

    local createButton = vgui.Create("DButton", buttonPanel)
    createButton:SetPos(10, yOffset)
    createButton:SetSize(buttonWidth - 20, buttonHeight)
    createButton:SetText("Erstellen")
    createButton:SetFont("RolesText")
    createButton:SetTextColor(Color(255, 255, 255))
    createButton.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255, 10))
        surface.SetDrawColor(255, 255, 255, 100)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
    end
    createButton.DoClick = function()
        contentContainer:Clear()
    
        local titleLabel = vgui.Create("DLabel", contentContainer)
        titleLabel:SetText("Neue Rolle erstellen")
        titleLabel:SetFont("DermaLarge")
        titleLabel:SetTextColor(Color(255, 255, 255))
        titleLabel:Dock(TOP)
        titleLabel:DockMargin(0, 0, 0, 10)
        titleLabel:SetContentAlignment(5)
        
        -- Name eingeben
        local nameLabel = vgui.Create("DLabel", contentContainer)
        nameLabel:SetText("Rollenname:")
        nameLabel:SetTextColor(Color(255, 255, 255))
        nameLabel:Dock(TOP)
        nameLabel:DockMargin(5, 5, 0, 0)
        
        local nameEntry = vgui.Create("DTextEntry", contentContainer)
        nameEntry:SetPlaceholderText("Rollenname eingeben")
        nameEntry:SetFont("RolesText")
        nameEntry:Dock(TOP)
        nameEntry:DockMargin(5, 5, 5, 10)
        
        -- Job-Nummer eingeben
        local jobNumLabel = vgui.Create("DLabel", contentContainer)
        jobNumLabel:SetText("Team-ID (Nummer für team.SetUp):")
        jobNumLabel:SetTextColor(Color(255, 255, 255))
        jobNumLabel:Dock(TOP)
        jobNumLabel:DockMargin(5, 5, 0, 0)
        
        local jobNumEntry = vgui.Create("DNumberWang", contentContainer)
        jobNumEntry:SetMin(1)
        jobNumEntry:SetMax(999)
        jobNumEntry:SetValue(100)
        jobNumEntry:Dock(TOP)
        jobNumEntry:DockMargin(5, 5, 5, 10)
        
        -- Fraktion auswählen
        local factionLabel = vgui.Create("DLabel", contentContainer)
        factionLabel:SetText("Fraktion:")
        factionLabel:SetTextColor(Color(255, 255, 255))
        factionLabel:Dock(TOP)
        factionLabel:DockMargin(5, 5, 0, 0)
        
        local factionCombo = vgui.Create("DComboBox", contentContainer)
        factionCombo:Dock(TOP)
        factionCombo:DockMargin(5, 5, 5, 10)
        
        -- Farbe auswählen
        local colorLabel = vgui.Create("DLabel", contentContainer)
        colorLabel:SetText("Farbe (für team.SetUp):")
        colorLabel:SetTextColor(Color(255, 255, 255))
        colorLabel:Dock(TOP)
        colorLabel:DockMargin(5, 5, 0, 0)
        
        local colorMixer = vgui.Create("DColorMixer", contentContainer)
        colorMixer:Dock(TOP)
        colorMixer:SetPalette(true)
        colorMixer:SetAlphaBar(false)
        colorMixer:SetWangs(true)
        colorMixer:DockMargin(5, 5, 5, 10)
        colorMixer:SetTall(150)

        local modelLabel = vgui.Create("DLabel", contentContainer)
        modelLabel:SetText("Spielermodell:")
        modelLabel:SetTextColor(Color(255, 255, 255))
        modelLabel:Dock(TOP)
        modelLabel:DockMargin(5, 5, 0, 0)

        local modelEntry = vgui.Create("DTextEntry", contentContainer)
        modelEntry:SetPlaceholderText("z.B. models/player/group01/male_01.mdl")
        modelEntry:SetFont("RolesText")
        modelEntry:Dock(TOP)
        modelEntry:DockMargin(5, 5, 5, 10)
        modelEntry:SetValue("models/player/Group01/male_01.mdl")

        -- Model-Vorschau erstellen
        local modelPreview = vgui.Create("DModelPanel", contentContainer)
        modelPreview:Dock(TOP)
        modelPreview:DockMargin(5, 5, 5, 10)
        modelPreview:SetTall(200)
        modelPreview:SetModel("models/player/Group01/male_01.mdl")
        modelPreview:SetCamPos(Vector(50, 0, 60))
        modelPreview:SetLookAt(Vector(0, 0, 60))

        -- Model Preview aktualisieren, wenn sich der Text ändert
        modelEntry.OnChange = function()
            local modelPath = modelEntry:GetValue()
            if modelPath and modelPath ~= "" then
                modelPreview:SetModel(modelPath)
            end
        end
        
        local healthLabel = vgui.Create("DLabel", contentContainer)
        healthLabel:SetText("Gesundheit:")
        healthLabel:SetTextColor(Color(255, 255, 255))
        healthLabel:Dock(TOP)
        healthLabel:DockMargin(5, 10, 0, 0)

        local healthSlider = vgui.Create("DNumSlider", contentContainer)
        healthSlider:SetText("")
        healthSlider:SetMin(1)
        healthSlider:SetMax(500)
        healthSlider:SetDecimals(0)
        healthSlider:SetValue(role and role.health or 100) -- Default 100 for new roles
        healthSlider:Dock(TOP)
        healthSlider:DockMargin(5, 5, 5, 10)

        -- Armor configuration
        local armorLabel = vgui.Create("DLabel", contentContainer)
        armorLabel:SetText("Rüstung:")
        armorLabel:SetTextColor(Color(255, 255, 255))
        armorLabel:Dock(TOP)
        armorLabel:DockMargin(5, 5, 0, 0)

        local armorSlider = vgui.Create("DNumSlider", contentContainer)
        armorSlider:SetText("")
        armorSlider:SetMin(0)
        armorSlider:SetMax(255)
        armorSlider:SetDecimals(0)
        armorSlider:SetValue(role and role.armor or 0) -- Default 0 for new roles
        armorSlider:Dock(TOP)
        armorSlider:DockMargin(5, 5, 5, 10)

        -- Weapons configuration
        local weaponsLabel = vgui.Create("DLabel", contentContainer)
        weaponsLabel:SetText("Waffen:")
        weaponsLabel:SetTextColor(Color(255, 255, 255))
        weaponsLabel:Dock(TOP)
        weaponsLabel:DockMargin(5, 5, 0, 0)

        local weaponsList = vgui.Create("DListView", contentContainer)
        weaponsList:Dock(TOP)
        weaponsList:SetTall(150)
        weaponsList:DockMargin(5, 5, 5, 10)
        weaponsList:AddColumn("Waffen-Klasse")
        weaponsList:SetMultiSelect(true)

        -- Fill weapons list with all available weapons
        local allWeapons = list.Get("Weapon")
        local selectedWeapons = {}

        -- If editing, parse the existing weapons
        if role and role.weapons then
            selectedWeapons = util.JSONToTable(role.weapons) or {}
        end

        for class, _ in pairs(allWeapons) do
            local line = weaponsList:AddLine(class)
            if table.HasValue(selectedWeapons, class) then
                weaponsList:SelectItem(line)
            end
        end

        -- Add weapon button
        local addWeaponEntry = vgui.Create("DTextEntry", contentContainer)
        addWeaponEntry:SetPlaceholderText("Waffenklasse eingeben...")
        addWeaponEntry:Dock(TOP)
        addWeaponEntry:DockMargin(5, 0, 5, 0)

        local addWeaponButton = vgui.Create("DButton", contentContainer)
        addWeaponButton:SetText("Waffe hinzufügen")
        addWeaponButton:Dock(TOP)
        addWeaponButton:DockMargin(5, 5, 5, 10)
        addWeaponButton.DoClick = function()
            local weaponClass = addWeaponEntry:GetValue()
            if weaponClass and weaponClass ~= "" then
                weaponsList:AddLine(weaponClass)
                addWeaponEntry:SetValue("")
            end
        end

        -- Spawn points configuration
        local spawnpointsLabel = vgui.Create("DLabel", contentContainer)
        spawnpointsLabel:SetText("Spawnpunkte:")
        spawnpointsLabel:SetTextColor(Color(255, 255, 255))
        spawnpointsLabel:Dock(TOP)
        spawnpointsLabel:DockMargin(5, 15, 0, 0)

        local spawnpointsList = vgui.Create("DListView", contentContainer)
        spawnpointsList:Dock(TOP)
        spawnpointsList:SetTall(150)
        spawnpointsList:DockMargin(5, 5, 5, 5)
        spawnpointsList:AddColumn("ID")
        spawnpointsList:AddColumn("Position")
        spawnpointsList:AddColumn("Blickwinkel")
        spawnpointsList:SetMultiSelect(false)

        -- Load spawn points if editing
        if role then
            net.Start("ROLES_GetSpawnpoints")
            net.WriteInt(role.id, 32)
            net.SendToServer()
        end

        -- Add spawn point button
        local addSpawnButton = vgui.Create("DButton", contentContainer)
        addSpawnButton:SetText("Aktuellen Standort als Spawnpunkt hinzufügen")
        addSpawnButton:Dock(TOP)
        addSpawnButton:DockMargin(5, 5, 5, 10)
        addSpawnButton.DoClick = function()
            if not role or not role.id then
                notification.AddLegacy("Erst die Rolle speichern, bevor Spawnpunkte hinzugefügt werden!", NOTIFY_ERROR, 3)
                return
            end
            
            local pos = LocalPlayer():GetPos()
            local ang = LocalPlayer():EyeAngles()
            
            net.Start("ROLES_AddSpawnpoint")
            net.WriteInt(role.id, 32)
            net.WriteVector(pos)
            net.WriteAngle(ang)
            net.SendToServer()
            
            -- Refresh the list
            net.Start("ROLES_GetSpawnpoints")
            net.WriteInt(role.id, 32)
            net.SendToServer()
        end

        -- Remove spawn point button
        local removeSpawnButton = vgui.Create("DButton", contentContainer)
        removeSpawnButton:SetText("Ausgewählten Spawnpunkt entfernen")
        removeSpawnButton:Dock(TOP)
        removeSpawnButton:DockMargin(5, 5, 5, 20)
        removeSpawnButton.DoClick = function()
            local selectedLine = spawnpointsList:GetSelectedLine()
            if not selectedLine then return end
            
            local spawnpointID = spawnpointsList:GetLine(selectedLine):GetValue(1)
            
            net.Start("ROLES_RemoveSpawnpoint")
            net.WriteInt(spawnpointID, 32)
            net.SendToServer()
            
            -- Refresh the list
            net.Start("ROLES_GetSpawnpoints")
            net.WriteInt(role.id, 32)
            net.SendToServer()
        end

        -- Receive spawn points from server
        net.Receive("ROLES_SendSpawnpoints", function()
            local spawnpoints = net.ReadTable() or {}
            
            spawnpointsList:Clear()
            for _, sp in ipairs(spawnpoints) do
                spawnpointsList:AddLine(
                    sp.id, 
                    string.format("%.1f, %.1f, %.1f", sp.pos_x, sp.pos_y, sp.pos_z),
                    string.format("%.1f, %.1f, %.1f", sp.angle_x, sp.angle_y, sp.angle_z)
                )
            end
        end)

        -- Speichern-Button
        local saveButton = vgui.Create("DButton", contentContainer)
        saveButton:SetText("Rolle erstellen")
        saveButton:SetFont("RolesText")
        saveButton:Dock(TOP)
        saveButton:SetTall(40)
        saveButton:DockMargin(5, 10, 5, 5)
        saveButton:SetTextColor(Color(255, 255, 255))
        saveButton.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(40, 160, 40, 200))
        end
        
        -- Fraktionen vom Server abrufen
        net.Start("ROLES_GetFactions")
        net.SendToServer()
        
        net.Receive("ROLES_SendFactions", function()
            local factions = net.ReadTable() or {}
            factionCombo:Clear()
            
            for _, faction in ipairs(factions) do
                factionCombo:AddChoice(faction.name, faction.id)
            end
            
            if #factions > 0 then
                factionCombo:ChooseOptionID(1)
            end
        end)
        
        saveButton.DoClick = function()
            local name = nameEntry:GetText()
            local teamID = jobNumEntry:GetValue()
            local _, factionID = factionCombo:GetSelected()
            local color = colorMixer:GetColor()
            local model = modelEntry:GetText()
            local health = healthSlider:GetValue()
            local armor = armorSlider:GetValue()
            
            local selectedWeapons = {}
            for _, line in pairs(weaponsList:GetSelected()) do
                table.insert(selectedWeapons, line:GetValue(1))
            end
            local weaponsJSON = util.TableToJSON(selectedWeapons)

            if name == "" then
                notification.AddLegacy("Bitte gib einen Namen ein!", NOTIFY_ERROR, 3)
                surface.PlaySound("buttons/button10.wav")
                return
            end
            
            if not factionID then
                notification.AddLegacy("Bitte wähle eine Fraktion aus!", NOTIFY_ERROR, 3)
                surface.PlaySound("buttons/button10.wav")
                return
            end
            
            net.Start("ROLES_CreateRole")
            net.WriteString(name)
            net.WriteInt(teamID, 32)
            net.WriteInt(factionID, 32)
            net.WriteColor(color)
            net.WriteString(model)  -- Sende das Modell an den Server
            net.WriteInt(health, 32)
            net.WriteInt(armor, 32)
            net.WriteString(weaponsJSON)
            net.SendToServer()
            
            notification.AddLegacy("Rolle erstellt!", NOTIFY_GENERIC, 3)
            surface.PlaySound("buttons/button15.wav")
            
            timer.Simple(0.3, function()
                OpenRolesMenu()
            end)
        end
    end
    
    yOffset = yOffset + buttonHeight + buttonSpacing

    -- Rollen vom Server abrufen
    net.Start("ROLES_RequestRoles")
    net.SendToServer()
    
    net.Receive("ROLES_SendRoles", function()
        local roles = net.ReadTable()
        local factionNames = net.ReadTable() or {}
        
        -- Fraktions-ID zu Namen Lookup erstellen
        local factionLookup = {}
        for _, faction in pairs(factionNames) do
            factionLookup[faction.id] = faction.name
        end
        
        for _, role in ipairs(roles) do
            local btn = vgui.Create("DButton", buttonPanel)
            btn:SetPos(10, yOffset)
            btn:SetSize(buttonWidth - 20, buttonHeight)
            btn:SetText(role.name)
            btn:SetFont("RolesText")
            
            -- Farbe parsen
            local r, g, b = 255, 255, 255
            if role.color then
                r, g, b = string.match(role.color, "(%d+),(%d+),(%d+)")
                r, g, b = tonumber(r) or 255, tonumber(g) or 255, tonumber(b) or 255
            end
            
            btn:SetTextColor(Color(r, g, b))
            
            btn.Paint = function(self, w, h)
                draw.RoundedBox(4, 0, 0, w, h, Color(r, g, b, 20))
                surface.SetDrawColor(r, g, b, 180)
                surface.DrawOutlinedRect(0, 0, w, h, 2)
            end
            
            btn.DoClick = function()
                contentContainer:Clear()
                
                local editLabel = vgui.Create("DLabel", contentContainer)
                editLabel:SetText("Rolle bearbeiten:")
                editLabel:SetFont("DermaLarge")
                editLabel:SetTextColor(Color(255, 255, 255))
                editLabel:Dock(TOP)
                editLabel:DockMargin(0, 0, 0, 10)
                editLabel:SetContentAlignment(5)
                
                -- Name eingeben
                local nameLabel = vgui.Create("DLabel", contentContainer)
                nameLabel:SetText("Rollenname:")
                nameLabel:SetTextColor(Color(255, 255, 255))
                nameLabel:Dock(TOP)
                nameLabel:DockMargin(5, 5, 0, 0)
                
                local nameEntry = vgui.Create("DTextEntry", contentContainer)
                nameEntry:SetText(role.name)
                nameEntry:SetFont("RolesText")
                nameEntry:Dock(TOP)
                nameEntry:DockMargin(5, 5, 5, 10)
                
                -- Job-Nummer eingeben
                local jobNumLabel = vgui.Create("DLabel", contentContainer)
                jobNumLabel:SetText("Team-ID (Nummer für team.SetUp):")
                jobNumLabel:SetTextColor(Color(255, 255, 255))
                jobNumLabel:Dock(TOP)
                jobNumLabel:DockMargin(5, 5, 0, 0)
                
                local jobNumEntry = vgui.Create("DNumberWang", contentContainer)
                jobNumEntry:SetMin(1)
                jobNumEntry:SetMax(999)
                jobNumEntry:SetValue(role.team_id or 100)
                jobNumEntry:Dock(TOP)
                jobNumEntry:DockMargin(5, 5, 5, 10)
                
                -- Fraktion auswählen
                local factionLabel = vgui.Create("DLabel", contentContainer)
                factionLabel:SetText("Fraktion:")
                factionLabel:SetTextColor(Color(255, 255, 255))
                factionLabel:Dock(TOP)
                factionLabel:DockMargin(5, 5, 0, 0)
                
                local factionCombo = vgui.Create("DComboBox", contentContainer)
                factionCombo:Dock(TOP)
                factionCombo:DockMargin(5, 5, 5, 10)
                
                -- Farbe bearbeiten
                local colorLabel = vgui.Create("DLabel", contentContainer)
                colorLabel:SetText("Farbe (für team.SetUp):")
                colorLabel:SetTextColor(Color(255, 255, 255))
                colorLabel:Dock(TOP)
                colorLabel:DockMargin(5, 5, 0, 0)
                
                local colorMixer = vgui.Create("DColorMixer", contentContainer)
                colorMixer:Dock(TOP)
                colorMixer:SetPalette(true)
                colorMixer:SetAlphaBar(false)
                colorMixer:SetWangs(true)
                colorMixer:DockMargin(5, 5, 5, 10)
                colorMixer:SetTall(150)
                colorMixer:SetColor(Color(r, g, b))

                local modelLabel = vgui.Create("DLabel", contentContainer)
                modelLabel:SetText("Spielermodell:")
                modelLabel:SetTextColor(Color(255, 255, 255))
                modelLabel:Dock(TOP)
                modelLabel:DockMargin(5, 5, 0, 0)

                local modelEntry = vgui.Create("DTextEntry", contentContainer)
                modelEntry:SetPlaceholderText("z.B. models/player/group01/male_01.mdl")
                modelEntry:SetFont("RolesText")
                modelEntry:Dock(TOP)
                modelEntry:DockMargin(5, 5, 5, 10)
                modelEntry:SetValue(role.model or "models/player/Group01/male_01.mdl")

                -- Model-Vorschau erstellen
                local modelPreview = vgui.Create("DModelPanel", contentContainer)
                modelPreview:Dock(TOP)
                modelPreview:DockMargin(5, 5, 5, 10)
                modelPreview:SetTall(200)
                modelPreview:SetModel(role.model or "models/player/Group01/male_01.mdl")
                modelPreview:SetCamPos(Vector(50, 0, 60))
                modelPreview:SetLookAt(Vector(0, 0, 60))

                -- Model Preview aktualisieren, wenn sich der Text ändert
                modelEntry.OnChange = function()
                    local modelPath = modelEntry:GetValue()
                    if modelPath and modelPath ~= "" then
                        modelPreview:SetModel(modelPath)
                    end
                end
                
                local healthLabel = vgui.Create("DLabel", contentContainer)
                healthLabel:SetText("Gesundheit:")
                healthLabel:SetTextColor(Color(255, 255, 255))
                healthLabel:Dock(TOP)
                healthLabel:DockMargin(5, 10, 0, 0)

                local healthSlider = vgui.Create("DNumSlider", contentContainer)
                healthSlider:SetText("")
                healthSlider:SetMin(1)
                healthSlider:SetMax(500)
                healthSlider:SetDecimals(0)
                healthSlider:SetValue(role and role.health or 100) -- Default 100 for new roles
                healthSlider:Dock(TOP)
                healthSlider:DockMargin(5, 5, 5, 10)

                -- Armor configuration
                local armorLabel = vgui.Create("DLabel", contentContainer)
                armorLabel:SetText("Rüstung:")
                armorLabel:SetTextColor(Color(255, 255, 255))
                armorLabel:Dock(TOP)
                armorLabel:DockMargin(5, 5, 0, 0)

                local armorSlider = vgui.Create("DNumSlider", contentContainer)
                armorSlider:SetText("")
                armorSlider:SetMin(0)
                armorSlider:SetMax(255)
                armorSlider:SetDecimals(0)
                armorSlider:SetValue(role and role.armor or 0) -- Default 0 for new roles
                armorSlider:Dock(TOP)
                armorSlider:DockMargin(5, 5, 5, 10)

                -- Weapons configuration
                local weaponsLabel = vgui.Create("DLabel", contentContainer)
                weaponsLabel:SetText("Waffen:")
                weaponsLabel:SetTextColor(Color(255, 255, 255))
                weaponsLabel:Dock(TOP)
                weaponsLabel:DockMargin(5, 5, 0, 0)

                local weaponsList = vgui.Create("DListView", contentContainer)
                weaponsList:Dock(TOP)
                weaponsList:SetTall(150)
                weaponsList:DockMargin(5, 5, 5, 10)
                weaponsList:AddColumn("Waffen-Klasse")
                weaponsList:SetMultiSelect(true)

                -- Fill weapons list with all available weapons
                local allWeapons = list.Get("Weapon")
                local selectedWeapons = {}

                -- If editing, parse the existing weapons
                if role and role.weapons then
                    selectedWeapons = util.JSONToTable(role.weapons) or {}
                end

                for class, _ in pairs(allWeapons) do
                    local line = weaponsList:AddLine(class)
                    if table.HasValue(selectedWeapons, class) then
                        weaponsList:SelectItem(line)
                    end
                end

                -- Add weapon button
                local addWeaponEntry = vgui.Create("DTextEntry", contentContainer)
                addWeaponEntry:SetPlaceholderText("Waffenklasse eingeben...")
                addWeaponEntry:Dock(TOP)
                addWeaponEntry:DockMargin(5, 0, 5, 0)

                local addWeaponButton = vgui.Create("DButton", contentContainer)
                addWeaponButton:SetText("Waffe hinzufügen")
                addWeaponButton:Dock(TOP)
                addWeaponButton:DockMargin(5, 5, 5, 10)
                addWeaponButton.DoClick = function()
                    local weaponClass = addWeaponEntry:GetValue()
                    if weaponClass and weaponClass ~= "" then
                        weaponsList:AddLine(weaponClass)
                        addWeaponEntry:SetValue("")
                    end
                end

                -- Spawn points configuration
                local spawnpointsLabel = vgui.Create("DLabel", contentContainer)
                spawnpointsLabel:SetText("Spawnpunkte:")
                spawnpointsLabel:SetTextColor(Color(255, 255, 255))
                spawnpointsLabel:Dock(TOP)
                spawnpointsLabel:DockMargin(5, 15, 0, 0)

                local spawnpointsList = vgui.Create("DListView", contentContainer)
                spawnpointsList:Dock(TOP)
                spawnpointsList:SetTall(150)
                spawnpointsList:DockMargin(5, 5, 5, 5)
                spawnpointsList:AddColumn("ID")
                spawnpointsList:AddColumn("Position")
                spawnpointsList:AddColumn("Blickwinkel")
                spawnpointsList:SetMultiSelect(false)

                -- Load spawn points if editing
                if role then
                    net.Start("ROLES_GetSpawnpoints")
                    net.WriteInt(role.id, 32)
                    net.SendToServer()
                end

                -- Add spawn point button
                local addSpawnButton = vgui.Create("DButton", contentContainer)
                addSpawnButton:SetText("Aktuellen Standort als Spawnpunkt hinzufügen")
                addSpawnButton:Dock(TOP)
                addSpawnButton:DockMargin(5, 5, 5, 10)
                addSpawnButton.DoClick = function()
                    if not role or not role.id then
                        notification.AddLegacy("Erst die Rolle speichern, bevor Spawnpunkte hinzugefügt werden!", NOTIFY_ERROR, 3)
                        return
                    end
                    
                    local pos = LocalPlayer():GetPos()
                    local ang = LocalPlayer():EyeAngles()
                    
                    net.Start("ROLES_AddSpawnpoint")
                    net.WriteInt(role.id, 32)
                    net.WriteVector(pos)
                    net.WriteAngle(ang)
                    net.SendToServer()
                    
                    -- Refresh the list
                    net.Start("ROLES_GetSpawnpoints")
                    net.WriteInt(role.id, 32)
                    net.SendToServer()
                end

                -- Remove spawn point button
                local removeSpawnButton = vgui.Create("DButton", contentContainer)
                removeSpawnButton:SetText("Ausgewählten Spawnpunkt entfernen")
                removeSpawnButton:Dock(TOP)
                removeSpawnButton:DockMargin(5, 5, 5, 20)
                removeSpawnButton.DoClick = function()
                    local selectedLine = spawnpointsList:GetSelectedLine()
                    if not selectedLine then return end
                    
                    local spawnpointID = spawnpointsList:GetLine(selectedLine):GetValue(1)
                    
                    net.Start("ROLES_RemoveSpawnpoint")
                    net.WriteInt(spawnpointID, 32)
                    net.SendToServer()
                    
                    -- Refresh the list
                    net.Start("ROLES_GetSpawnpoints")
                    net.WriteInt(role.id, 32)
                    net.SendToServer()
                end

                -- Receive spawn points from server
                net.Receive("ROLES_SendSpawnpoints", function()
                    local spawnpoints = net.ReadTable() or {}
                    
                    spawnpointsList:Clear()
                    for _, sp in ipairs(spawnpoints) do
                        spawnpointsList:AddLine(
                            sp.id, 
                            string.format("%.1f, %.1f, %.1f", sp.pos_x, sp.pos_y, sp.pos_z),
                            string.format("%.1f, %.1f, %.1f", sp.angle_x, sp.angle_y, sp.angle_z)
                        )
                    end
                end)

                -- Speichern-Button
                local saveButton = vgui.Create("DButton", contentContainer)
                saveButton:SetText("Änderungen speichern")
                saveButton:SetFont("RolesText")
                saveButton:Dock(TOP)
                saveButton:SetTall(40)
                saveButton:DockMargin(5, 10, 5, 5)
                saveButton:SetTextColor(Color(255, 255, 255))
                saveButton.Paint = function(self, w, h)
                    draw.RoundedBox(0, 0, 0, w, h, Color(40, 160, 40, 200))
                end
                
                -- Löschen-Button
                local deleteButton = vgui.Create("DButton", contentContainer)
                deleteButton:SetText("Rolle löschen")
                deleteButton:SetFont("RolesText")
                deleteButton:Dock(TOP)
                deleteButton:SetTall(40)
                deleteButton:DockMargin(5, 5, 5, 5)
                deleteButton:SetTextColor(Color(255, 255, 255))
                deleteButton.Paint = function(self, w, h)
                    draw.RoundedBox(0, 0, 0, w, h, Color(180, 40, 40, 200))
                end
                
                -- Fraktionen abrufen
                net.Start("ROLES_GetFactions")
                net.SendToServer()
                
                net.Receive("ROLES_SendFactions", function()
                    local factions = net.ReadTable() or {}
                    factionCombo:Clear()
                    
                    local selectedIndex = 1
                    for i, faction in ipairs(factions) do
                        factionCombo:AddChoice(faction.name, faction.id)
                        
                        if faction.id == role.faction_id then
                            selectedIndex = i
                        end
                    end
                    
                    if #factions > 0 then
                        factionCombo:ChooseOptionID(selectedIndex)
                    end
                end)
                
                saveButton.DoClick = function()
                    local newName = nameEntry:GetText()
                    local newTeamID = jobNumEntry:GetValue()
                    local _, newFactionID = factionCombo:GetSelected()
                    local newColor = colorMixer:GetColor()
                    local newModel = modelEntry:GetValue()
                    local health = healthSlider:GetValue()
                    local armor = armorSlider:GetValue()
                    
                    local selectedWeapons = {}
                    for _, line in pairs(weaponsList:GetSelected()) do
                        table.insert(selectedWeapons, line:GetValue(1))
                    end
                    local weaponsJSON = util.TableToJSON(selectedWeapons)

                    if newName == "" then
                        notification.AddLegacy("Der Name darf nicht leer sein!", NOTIFY_ERROR, 3)
                        surface.PlaySound("buttons/button10.wav")
                        return
                    end
                    
                    net.Start("ROLES_UpdateRole")
                    net.WriteInt(role.id, 32)
                    net.WriteString(newName)
                    net.WriteInt(newTeamID, 32)
                    net.WriteInt(newFactionID, 32)
                    net.WriteColor(newColor)
                    net.WriteString(newModel)  -- Das Modell an den Server senden
                    net.WriteInt(health, 32)
                    net.WriteInt(armor, 32)
                    net.WriteString(weaponsJSON)
                    net.SendToServer()
                    
                    notification.AddLegacy("Änderungen gespeichert!", NOTIFY_GENERIC, 3)
                    surface.PlaySound("buttons/button15.wav")
                    
                    timer.Simple(0.3, function()
                        OpenRolesMenu()
                    end)
                end
                
                deleteButton.DoClick = function()
                    -- Überprüfen, ob die Rollen-ID 1, 2 oder 3 ist
                    if role.id == 1 or role.id == 2 or role.id == 3 then
                        notification.AddLegacy("Diese Rolle kann nicht gelöscht werden!", NOTIFY_ERROR, 3)
                        surface.PlaySound("buttons/button10.wav")
                        return
                    end
                    
                    -- Rolle löschen
                    net.Start("ROLES_DeleteRole")
                    net.WriteInt(role.id, 32)
                    net.SendToServer()
                    
                    notification.AddLegacy("Rolle gelöscht!", NOTIFY_GENERIC, 3)
                    surface.PlaySound("buttons/button15.wav")
                    
                    timer.Simple(0.3, function()
                        OpenRolesMenu()
                    end)
                end
            end
            
            yOffset = yOffset + buttonHeight + buttonSpacing
        end
    end)
end

-- Tastenkürzel zum Öffnen des Menüs
hook.Add("PlayerButtonDown", "ROLES_KeybindCheck", function(ply, button)
    if CLIENT then
        if (IsFirstTimePredicted()) then
            if button == ROLES.Config.OpenMenuKey then
                OpenRolesMenu()
            end
        end
    end
end)

-- Aktiviere Rollenmenü mit Konsolenbefehl
concommand.Add("roles_menu", function()
    OpenRolesMenu()
end)
