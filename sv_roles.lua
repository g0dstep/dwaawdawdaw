-- roles_sv.lua
-- Server-seitiges System für Rollen/Jobs

-- Netzwerk-Strings für die Kommunikation zwischen Client und Server
util.AddNetworkString("ROLES_RequestRoles")
util.AddNetworkString("ROLES_SendRoles")
util.AddNetworkString("ROLES_CreateRole")
util.AddNetworkString("ROLES_UpdateRole")
util.AddNetworkString("ROLES_DeleteRole")
util.AddNetworkString("ROLES_GetFactions")
util.AddNetworkString("ROLES_SendFactions")
util.AddNetworkString("ROLES_PlayerSetRole")
util.AddNetworkString("ROLES_GetSpawnpoints")
util.AddNetworkString("ROLES_SendSpawnpoints")
util.AddNetworkString("ROLES_AddSpawnpoint")
util.AddNetworkString("ROLES_RemoveSpawnpoint")

-- Stellen wir sicher, dass ROLES-Tabelle existiert
ROLES = ROLES or {}

-- Stellen Sie sicher, dass die Datenbanktabelle existiert
hook.Add("Initialize", "ROLES_CreateTable", function()
    -- Warten auf die Datenbankverbindung (falls benötigt)
    timer.Simple(1, function()
        DB:Query([[
            CREATE TABLE IF NOT EXISTS roles (
                id INTEGER PRIMARY KEY AUTO_INCREMENT,
                name VARCHAR(64) NOT NULL,
                team_id INTEGER NOT NULL,
                faction_id INTEGER NOT NULL,
                color VARCHAR(32) DEFAULT '255,255,255',
                model VARCHAR(255) DEFAULT 'models/player/Group01/male_01.mdl',
                health INTEGER DEFAULT 100,
                armor INTEGER DEFAULT 0,
                weapons TEXT DEFAULT '[]',
                FOREIGN KEY (faction_id) REFERENCES factions(id) ON DELETE CASCADE
            )
        ]], function()
            print("[ROLES] Tabelle erfolgreich erstellt oder bereits vorhanden.")
            
            -- Standardrollen erstellen, falls noch keine vorhanden sind
            DB:Query("SELECT COUNT(*) as count FROM roles", function(data)
                if data and data[1] and tonumber(data[1].count) == 0 then
                    CreateDefaultRoles()
                else
                    -- Bei Serverstart Rollen in Teams laden
                    LoadRolesIntoTeams()
                end
            end)
        end)

        DB:Query([[
            CREATE TABLE IF NOT EXISTS role_spawnpoints (
                id INTEGER PRIMARY KEY AUTO_INCREMENT,
                role_id INTEGER NOT NULL,
                pos_x FLOAT NOT NULL,
                pos_y FLOAT NOT NULL,
                pos_z FLOAT NOT NULL,
                angle_x FLOAT DEFAULT 0,
                angle_y FLOAT DEFAULT 0,
                angle_z FLOAT DEFAULT 0,
                FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
            )
        ]], function()
            print("[ROLES] Spawnpoint table created successfully")
        end)
    end)
end)

-- Erstelle Standardrollen
function CreateDefaultRoles()
    local defaultRoles = {
        {name = "Admin", team_id = 1, faction_id = 1, color = "255,0,0"},
        {name = "Moderator", team_id = 2, faction_id = 1, color = "0,0,255"},
        {name = "Spieler", team_id = 3, faction_id = 2, color = "0,255,0"}
    }
    
    for _, role in ipairs(defaultRoles) do
        DB:Query(string.format(
            "INSERT INTO roles (name, team_id, faction_id, color) VALUES ('%s', %d, %d, '%s')",
            DB:Escape(role.name), role.team_id, role.faction_id, DB:Escape(role.color)
        ))
    end
    
    print("[ROLES] Standardrollen wurden erstellt.")
    
    -- Nach dem Erstellen der Standardrollen in Teams laden
    timer.Simple(0.5, function()
        LoadRolesIntoTeams()
    end)
end

-- Lädt alle Rollen und erstellt entsprechende Teams
function LoadRolesIntoTeams()
    DB:Query("SELECT * FROM roles", function(data)
        if not data then return end
        
        for _, role in ipairs(data) do
            -- Farbe parsen
            local r, g, b = 255, 255, 255
            if role.color then
                r, g, b = string.match(role.color, "(%d+),(%d+),(%d+)")
                r, g, b = tonumber(r) or 255, tonumber(g) or 255, tonumber(b) or 255
            end
            
            -- Team erstellen
            team.SetUp(role.team_id, role.name, Color(r, g, b))
            print("[ROLES] Team geladen: " .. role.name .. " (ID: " .. role.team_id .. ", Farbe: " .. r .. "," .. g .. "," .. b .. ")")
        end
        
        print("[ROLES] Alle Teams wurden geladen.")
    end)
end

-- Hilfsfunktion für das Escapen von SQL-Strings
function DB:Escape(str)
    if not str then return "NULL" end
    return "'" .. string.gsub(str, "'", "''") .. "'"
end

-- Handler für Rollenanfragen
net.Receive("ROLES_RequestRoles", function(len, ply)
    DB:Query("SELECT * FROM roles", function(roles)
        DB:Query("SELECT id, name FROM factions", function(factions)
            net.Start("ROLES_SendRoles")
            net.WriteTable(roles or {})
            net.WriteTable(factions or {})
            net.Send(ply)
        end)
    end)
end)

-- Handler für Fraktionsabfragen (für Dropdowns)
net.Receive("ROLES_GetFactions", function(len, ply)
    DB:Query("SELECT id, name FROM factions", function(data)
        net.Start("ROLES_SendFactions")
        net.WriteTable(data or {})
        net.Send(ply)
    end)
end)

-- Handler für Rollenerstellen
-- Handler für Rollenerstellen
net.Receive("ROLES_CreateRole", function(len, ply)
    -- Only admins can create roles
    if not ply:IsAdmin() then return end
    
    local name = net.ReadString()
    local teamID = net.ReadInt(32)
    local factionID = net.ReadInt(32)
    local color = net.ReadColor()
    local model = net.ReadString()
    local health = net.ReadInt(32)
    local armor = net.ReadInt(32)
    local weapons = net.ReadString()
    
    local colorStr = string.format("%d,%d,%d", color.r, color.g, color.b)
    
    -- Check if team_id is already used
    DB:Query("SELECT * FROM roles WHERE team_id = " .. teamID, function(result)
        if result and #result > 0 then
            ply:ChatPrint("Die Team-ID " .. teamID .. " ist bereits vergeben. Bitte wähle eine andere.")
            return
        end
        
        -- Add new role with health, armor, and weapons
        DB:Query(string.format(
            "INSERT INTO roles (name, team_id, faction_id, color, model, health, armor, weapons) VALUES (%s, %d, %d, %s, %s, %d, %d, %s)",
            DB:Escape(name), teamID, factionID, DB:Escape(colorStr), DB:Escape(model), health, armor, DB:Escape(weapons)
        ), function()
            -- Create team
            team.SetUp(teamID, name, color)
            
            ply:ChatPrint("Rolle '" .. name .. "' erfolgreich erstellt mit Team-ID " .. teamID)
            print("[ROLES] Neue Rolle erstellt: " .. name .. " (Team-ID: " .. teamID .. ")")
        end)
    end)
end)


-- Handler für Rollenaktualisierung
net.Receive("ROLES_UpdateRole", function(len, ply)
    -- Nur Admins können Rollen bearbeiten
    if not ply:IsAdmin() then return end
    
    local id = net.ReadInt(32)
    local newName = net.ReadString()
    local newTeamID = net.ReadInt(32)
    local newFactionID = net.ReadInt(32)
    local newColor = net.ReadColor()
    local newModel = net.ReadString()
    local newHealth = net.ReadInt(32)
    local newArmor = net.ReadInt(32)
    local newWeapons = net.ReadString()
    
    local colorStr = string.format("%d,%d,%d", newColor.r, newColor.g, newColor.b)
    
    -- Zuerst die alte Team-ID abrufen
    DB:Query("SELECT team_id FROM roles WHERE id = " .. id, function(oldData)
        if not oldData or #oldData == 0 then return end
        
        local oldTeamID = oldData[1].team_id
        
        -- Überprüfe, ob die neue team_id bereits verwendet wird (außer von der aktuellen Rolle)
        DB:Query("SELECT * FROM roles WHERE team_id = " .. newTeamID .. " AND id != " .. id, function(result)
            if result and #result > 0 then
                -- Team-ID bereits vorhanden, wähle eine neue
                ply:ChatPrint("Die Team-ID " .. newTeamID .. " ist bereits vergeben. Bitte wähle eine andere.")
                return
            end
            
            -- Aktualisiere die Rolle
            DB:Query(string.format(
                "UPDATE roles SET name = %s, team_id = %d, faction_id = %d, color = %s, model = %s, health = %d, armor = %d, weapons = %s WHERE id = %d",
                DB:Escape(newName), newTeamID, newFactionID, DB:Escape(colorStr), DB:Escape(newModel), newHealth, newArmor, DB:Escape(newWeapons), id
            ), function()
                -- Team aktualisieren - Direkt die neue Farbe aus dem Client-Input verwenden
                team.SetUp(newTeamID, newName, newColor)
                
                ply:ChatPrint("Rolle '" .. newName .. "' erfolgreich aktualisiert.")
                print("[ROLES] Rolle aktualisiert: " .. newName .. " (Team-ID: " .. newTeamID .. ", Farbe: " .. newColor.r .. "," .. newColor.g .. "," .. newColor.b .. ", Modell: " .. newModel .. ")")
                
                -- Wenn sich die Team-ID geändert hat, alle Spieler mit der alten ID auf die neue umstellen
                if oldTeamID ~= newTeamID then
                    for _, player in ipairs(player.GetAll()) do
                        if player:Team() == oldTeamID then
                            player:SetTeam(newTeamID)
                            -- Auch das Modell aktualisieren
                            player:SetModel(newModel)
                        end
                    end
                else
                    -- Modell für alle Spieler in diesem Team aktualisieren
                    for _, player in ipairs(player.GetAll()) do
                        if player:Team() == newTeamID then
                            player:SetModel(newModel)
                        end
                    end
                end
            end)
        end)
    end)
end)

net.Receive("ROLES_GetSpawnpoints", function(len, ply)
    local roleID = net.ReadInt(32)
    
    DB:Query("SELECT * FROM role_spawnpoints WHERE role_id = " .. roleID, function(result)
        net.Start("ROLES_SendSpawnpoints")
        net.WriteTable(result or {})
        net.Send(ply)
    end)
end)

-- Handler for adding a spawnpoint
net.Receive("ROLES_AddSpawnpoint", function(len, ply)
    if not ply:IsAdmin() then return end
    
    local roleID = net.ReadInt(32)
    local pos = net.ReadVector()
    local ang = net.ReadAngle()
    
    DB:Query(string.format(
        "INSERT INTO role_spawnpoints (role_id, pos_x, pos_y, pos_z, angle_x, angle_y, angle_z) VALUES (%d, %f, %f, %f, %f, %f, %f)",
        roleID, pos.x, pos.y, pos.z, ang.x, ang.y, ang.z
    ), function()
        ply:ChatPrint("Spawnpunkt hinzugefügt!")
    end)
end)

-- Handler for removing a spawnpoint
net.Receive("ROLES_RemoveSpawnpoint", function(len, ply)
    if not ply:IsAdmin() then return end
    
    local spawnpointID = net.ReadInt(32)
    
    DB:Query("DELETE FROM role_spawnpoints WHERE id = " .. spawnpointID, function()
        ply:ChatPrint("Spawnpunkt entfernt!")
    end)
end)

-- Handler für Rollenlöschen
net.Receive("ROLES_DeleteRole", function(len, ply)
    -- Nur Admins können Rollen löschen
    if not ply:IsAdmin() then return end
    
    local id = net.ReadInt(32)
    
    -- Überprüfen, ob die Rolle eine der Standardrollen ist
    if id == 1 or id == 2 or id == 3 then
        ply:ChatPrint("Die Standardrollen können nicht gelöscht werden!")
        return
    end
    
    -- Team-ID abrufen, bevor die Rolle gelöscht wird
    DB:Query("SELECT team_id FROM roles WHERE id = " .. id, function(data)
        if not data or #data == 0 then return end
        
        local teamID = data[1].team_id
        
        -- Rolle löschen
        DB:Query("DELETE FROM roles WHERE id = " .. id, function()
            ply:ChatPrint("Rolle erfolgreich gelöscht.")
            print("[ROLES] Rolle gelöscht (ID: " .. id .. ", Team-ID: " .. teamID .. ")")
            
            -- Alle Spieler aus diesem Team in das Standardteam (3: Spieler) setzen
            for _, player in ipairs(player.GetAll()) do
                if player:Team() == teamID then
                    player:SetTeam(3)
                end
            end
        end)
    end)
end)

-- Handler für Spielerrolle setzen