-- ════════════════════════════════════════════════════════════════════════════════════
-- HM BUS JOB - SERVER MAIN
-- ════════════════════════════════════════════════════════════════════════════════════

local playerData = {} -- Cache for player stats

-- ════════════════════════════════════════════════════════════════════════════════════
-- DATABASE INITIALIZATION
-- ════════════════════════════════════════════════════════════════════════════════════

CreateThread(function()
    -- Create table if not exists
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS hm_busjob_players (
            identifier VARCHAR(50) PRIMARY KEY,
            level INT DEFAULT 1,
            experience INT DEFAULT 0,
            routes_done INT DEFAULT 0,
            total_earned INT DEFAULT 0,
            last_played TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )
    ]])
    
    if Config.Debug then
        print('[HM BUS JOB] Database initialized')
    end
end)

-- ════════════════════════════════════════════════════════════════════════════════════
-- PLAYER DATA LOADING
-- ════════════════════════════════════════════════════════════════════════════════════

function LoadPlayerData(source)
    local player = Framework.GetPlayer(source)
    if not player then return nil end
    
    local identifier = player.PlayerData.citizenid or player.PlayerData.identifier
    
    -- Check if player exists in database
    local result = MySQL.query.await('SELECT * FROM hm_busjob_players WHERE identifier = ?', {identifier})
    
    if result and #result > 0 then
        -- Player exists, load data
        playerData[source] = result[1]
    else
        -- Create new player entry
        MySQL.insert.await('INSERT INTO hm_busjob_players (identifier) VALUES (?)', {identifier})
        
        playerData[source] = {
            identifier = identifier,
            level = 1,
            experience = 0,
            routes_done = 0,
            total_earned = 0
        }
    end
    
    if Config.Debug then
        print(('[HM BUS JOB] Loaded data for %s (Level %d, XP %d)'):format(identifier, playerData[source].level, playerData[source].experience))
    end
    
    return playerData[source]
end

function SavePlayerData(source)
    if not playerData[source] then return end
    
    local data = playerData[source]
    
    MySQL.update.await([[
        UPDATE hm_busjob_players 
        SET level = ?, experience = ?, routes_done = ?, total_earned = ?
        WHERE identifier = ?
    ]], {
        data.level,
        data.experience,
        data.routes_done,
        data.total_earned,
        data.identifier
    })
    
    if Config.Debug then
        print(('[HM BUS JOB] Saved data for %s'):format(data.identifier))
    end
end

-- ════════════════════════════════════════════════════════════════════════════════════
-- PLAYER CONNECT/DISCONNECT
-- ════════════════════════════════════════════════════════════════════════════════════

RegisterNetEvent('QBCore:Server:PlayerLoaded', function(Player)
    local source = Player.PlayerData.source
    LoadPlayerData(source)
end)

RegisterNetEvent('esx:playerLoaded', function(playerId, xPlayer)
    LoadPlayerData(playerId)
end)

AddEventHandler('playerDropped', function()
    local source = source
    if playerData[source] then
        SavePlayerData(source)
        playerData[source] = nil
    end
end)

-- ════════════════════════════════════════════════════════════════════════════════════
-- CALLBACKS
-- ════════════════════════════════════════════════════════════════════════════════════

lib.callback.register('hm_busjob:getPlayerStats', function(source)
    if not playerData[source] then
        LoadPlayerData(source)
    end
    
    local data = playerData[source]
    
    if not data then
        return nil
    end
    
    if Config.Debug then
        print(('[HM BUS JOB] Sending stats to %s: Level %d, XP %d, Routes %d'):format(
            data.identifier,
            data.level,
            data.experience,
            data.routes_done
        ))
    end
    
    -- Convert database column names to camelCase for NUI
    return {
        level = data.level or 1,
        experience = data.experience or 0,
        routesDone = data.routes_done or 0,
        totalEarned = data.total_earned or 0
    }
end)

lib.callback.register('hm_busjob:completeRoute', function(source, data)
    if not playerData[source] then
        return false
    end
    
    local player = Framework.GetPlayer(source)
    if not player then return false end
    
    -- Find route by ID (not index!)
    local route = nil
    for _, r in ipairs(Config.Routes) do
        if r.id == data.routeId then
            route = r
            break
        end
    end
    
    if not route then
        if Config.Debug then
            print(('[HM BUS JOB] Invalid route ID: %d'):format(data.routeId))
        end
        return false
    end
    
    -- Validate rewards
    local money = math.max(0, math.floor(data.money or 0))
    local xp = math.max(0, math.floor(data.xp or 0))
    local fines = math.max(0, math.floor(data.fines or 0))
    
    -- Add money
    if money > 0 then
        player.Functions.AddMoney('cash', money, 'bus-job-route-completed')
    end
    
    -- Add XP and check for level up
    AddExperience(source, xp)
    
    -- Update stats
    local oldRoutesDone = playerData[source].routes_done
    playerData[source].routes_done = playerData[source].routes_done + 1
    playerData[source].total_earned = playerData[source].total_earned + money
    
    if Config.Debug then
        print(('[HM BUS JOB] Routes Done: %d → %d'):format(oldRoutesDone, playerData[source].routes_done))
    end
    
    -- Save to database
    SavePlayerData(source)
    
    if Config.Debug then
        print(('[HM BUS JOB] %s completed route %s - $%d, %d XP, $%d fines'):format(
            playerData[source].identifier,
            route.name,
            money,
            xp,
            fines
        ))
    end
    
    return true
end)

-- ════════════════════════════════════════════════════════════════════════════════════
-- EXPERIENCE & LEVELING
-- ════════════════════════════════════════════════════════════════════════════════════

function AddExperience(source, amount)
    if not playerData[source] then 
        if Config.Debug then
            print('[HM BUS JOB] ❌ AddExperience() - No playerData for source ' .. source)
        end
        return 
    end
    
    local oldLevel = playerData[source].level
    local oldXP = playerData[source].experience
    playerData[source].experience = playerData[source].experience + amount
    
    if Config.Debug then
        print(('[HM BUS JOB] AddExperience() - Added %d XP (Total: %d → %d)'):format(
            amount,
            oldXP,
            playerData[source].experience
        ))
    end
    
    -- Check for level up
    local leveledUp = false
    while true do
        local requiredXP = GetRequiredXPForLevel(playerData[source].level)
        
        if Config.Debug then
            print(('[HM BUS JOB] Level %d - Current XP: %d / Required: %d'):format(
                playerData[source].level,
                playerData[source].experience,
                requiredXP
            ))
        end
        
        if playerData[source].experience >= requiredXP then
            -- Level up!
            playerData[source].experience = playerData[source].experience - requiredXP
            playerData[source].level = playerData[source].level + 1
            leveledUp = true
            
            if Config.Debug then
                print(('[HM BUS JOB] ✅ LEVEL UP! %d → %d (Remaining XP: %d)'):format(
                    oldLevel,
                    playerData[source].level,
                    playerData[source].experience
                ))
            end
            
            -- Notify player (using English as server doesn't have Locale)
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'Level Up!', -- Will be translated client-side if needed
                description = 'You reached level ' .. playerData[source].level .. '!',
                type = 'success',
                duration = 8000
            })
            
            if Config.Debug then
                print(('[HM BUS JOB] %s leveled up to %d'):format(playerData[source].identifier, playerData[source].level))
            end
        else
            if Config.Debug and not leveledUp then
                print(('[HM BUS JOB] No level up - need %d more XP'):format(requiredXP - playerData[source].experience))
            end
            break
        end
        
        -- Max level check
        if playerData[source].level >= Config.LevelSystem.maxLevel then
            playerData[source].experience = 0
            if Config.Debug then
                print('[HM BUS JOB] Max level reached - XP reset to 0')
            end
            break
        end
    end
    
    return playerData[source].level > oldLevel
end

function GetRequiredXPForLevel(level)
    if not Config.LevelSystem.enabled then
        return 999999999
    end
    
    -- XP needed to reach the NEXT level
    -- If player is level 1, this calculates XP needed to reach level 2
    local baseXP = Config.LevelSystem.xpPerLevel
    local multiplier = Config.LevelSystem.xpMultiplier
    
    -- level = current level, so we calculate for (level) not (level - 1)
    return math.floor(baseXP * (multiplier ^ (level - 1)))
end

-- ════════════════════════════════════════════════════════════════════════════════════
-- ADMIN COMMANDS
-- ════════════════════════════════════════════════════════════════════════════════════

lib.addCommand('busjob_resetstats', {
    help = 'Reset your bus job stats',
    restricted = 'group.admin'
}, function(source, args)
    if not playerData[source] then
        LoadPlayerData(source)
    end
    
    playerData[source].level = 1
    playerData[source].experience = 0
    playerData[source].routes_done = 0
    playerData[source].total_earned = 0
    
    SavePlayerData(source)
    
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Bus Job',
        description = 'Stats reset successfully',
        type = 'success'
    })
end)

lib.addCommand('busjob_setlevel', {
    help = 'Set bus job level',
    params = {
        { name = 'level', type = 'number', help = 'Level to set' }
    },
    restricted = 'group.admin'
}, function(source, args)
    if not playerData[source] then
        LoadPlayerData(source)
    end
    
    local level = math.max(1, math.min(args.level, Config.LevelSystem.maxLevel))
    playerData[source].level = level
    playerData[source].experience = 0
    
    SavePlayerData(source)
    
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Bus Job',
        description = ('Level set to %d'):format(level),
        type = 'success'
    })
end)

lib.addCommand('busjob_addxp', {
    help = 'Add XP to bus job',
    params = {
        { name = 'amount', type = 'number', help = 'XP amount to add' }
    },
    restricted = 'group.admin'
}, function(source, args)
    if not playerData[source] then
        LoadPlayerData(source)
    end
    
    AddExperience(source, args.amount)
    SavePlayerData(source)
    
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Bus Job',
        description = ('Added %d XP'):format(args.amount),
        type = 'success'
    })
end)

-- ════════════════════════════════════════════════════════════════════════════════════
-- EXPORTS
-- ════════════════════════════════════════════════════════════════════════════════════

exports('GetPlayerData', function(source)
    return playerData[source]
end)

exports('AddExperience', AddExperience)
exports('GetRequiredXPForLevel', GetRequiredXPForLevel)
