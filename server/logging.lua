-- ════════════════════════════════════════════════════════════════════════════════════
-- HM BUS JOB - LOGGING SYSTEM
-- ════════════════════════════════════════════════════════════════════════════════════

-- Discord webhook URL (optional - set in config)
local WEBHOOK_URL = nil -- Set this to your Discord webhook URL

-- ════════════════════════════════════════════════════════════════════════════════════
-- LOG ROUTE COMPLETION
-- ════════════════════════════════════════════════════════════════════════════════════

function LogRouteCompletion(source, routeData)
    if not Config.Debug then return end
    
    local player = Framework.GetPlayer(source)
    if not player then return end
    
    local playerName = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname
    local identifier = player.PlayerData.citizenid or player.PlayerData.identifier
    
    local logMessage = string.format(
        '[ROUTE COMPLETED] %s (%s) completed route "%s" - Earned: $%d, XP: %d, Fines: $%d',
        playerName,
        identifier,
        routeData.routeName,
        routeData.money,
        routeData.xp,
        routeData.fines or 0
    )
    
    print(logMessage)
    
    -- Send to Discord if webhook is configured
    if WEBHOOK_URL then
        SendDiscordLog('Route Completed', logMessage, 3066993) -- Green color
    end
    
    -- Save to database log table (optional)
    SaveToDatabase('route_completed', {
        identifier = identifier,
        player_name = playerName,
        route_name = routeData.routeName,
        money_earned = routeData.money,
        xp_earned = routeData.xp,
        fines = routeData.fines or 0,
        timestamp = os.time()
    })
end

-- ════════════════════════════════════════════════════════════════════════════════════
-- LOG LEVEL UP
-- ════════════════════════════════════════════════════════════════════════════════════

function LogLevelUp(source, oldLevel, newLevel)
    if not Config.Debug then return end
    
    local player = Framework.GetPlayer(source)
    if not player then return end
    
    local playerName = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname
    local identifier = player.PlayerData.citizenid or player.PlayerData.identifier
    
    local logMessage = string.format(
        '[LEVEL UP] %s (%s) reached level %d (from %d)',
        playerName,
        identifier,
        newLevel,
        oldLevel
    )
    
    print(logMessage)
    
    if WEBHOOK_URL then
        SendDiscordLog('Level Up', logMessage, 15844367) -- Gold color
    end
end

-- ════════════════════════════════════════════════════════════════════════════════════
-- LOG ADMIN ACTION
-- ════════════════════════════════════════════════════════════════════════════════════

function LogAdminAction(source, action, details)
    local player = Framework.GetPlayer(source)
    if not player then return end
    
    local playerName = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname
    local identifier = player.PlayerData.citizenid or player.PlayerData.identifier
    
    local logMessage = string.format(
        '[ADMIN ACTION] %s (%s) performed: %s - Details: %s',
        playerName,
        identifier,
        action,
        details
    )
    
    print(logMessage)
    
    if WEBHOOK_URL then
        SendDiscordLog('Admin Action', logMessage, 15158332) -- Red color
    end
end

-- ════════════════════════════════════════════════════════════════════════════════════
-- DISCORD WEBHOOK
-- ════════════════════════════════════════════════════════════════════════════════════

function SendDiscordLog(title, message, color)
    if not WEBHOOK_URL then return end
    
    local embed = {
        {
            ['title'] = title,
            ['description'] = message,
            ['color'] = color,
            ['footer'] = {
                ['text'] = 'HM Bus Job - ' .. os.date('%Y-%m-%d %H:%M:%S')
            }
        }
    }
    
    PerformHttpRequest(WEBHOOK_URL, function(err, text, headers)
        -- Callback (optional)
    end, 'POST', json.encode({
        username = 'HM Bus Job',
        embeds = embed
    }), {
        ['Content-Type'] = 'application/json'
    })
end

-- ════════════════════════════════════════════════════════════════════════════════════
-- DATABASE LOGGING (OPTIONAL)
-- ════════════════════════════════════════════════════════════════════════════════════

function SaveToDatabase(logType, data)
    -- Create logs table if not exists
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS hm_busjob_logs (
            id INT AUTO_INCREMENT PRIMARY KEY,
            log_type VARCHAR(50),
            identifier VARCHAR(50),
            player_name VARCHAR(100),
            data TEXT,
            timestamp INT,
            INDEX idx_log_type (log_type),
            INDEX idx_identifier (identifier),
            INDEX idx_timestamp (timestamp)
        )
    ]])
    
    -- Insert log entry
    MySQL.insert.await('INSERT INTO hm_busjob_logs (log_type, identifier, player_name, data, timestamp) VALUES (?, ?, ?, ?, ?)', {
        logType,
        data.identifier,
        data.player_name,
        json.encode(data),
        data.timestamp
    })
end

-- ════════════════════════════════════════════════════════════════════════════════════
-- EXPORTS
-- ════════════════════════════════════════════════════════════════════════════════════

exports('LogRouteCompletion', LogRouteCompletion)
exports('LogLevelUp', LogLevelUp)
exports('LogAdminAction', LogAdminAction)
