-- ════════════════════════════════════════════════════════════════════════════════════
-- HM BUS JOB - LEADERBOARD SYSTEM
-- ════════════════════════════════════════════════════════════════════════════════════

-- ════════════════════════════════════════════════════════════════════════════════════
-- GET LEADERBOARD
-- ════════════════════════════════════════════════════════════════════════════════════

lib.callback.register('hm_busjob:getLeaderboard', function(source, category, limit)
    limit = limit or 10
    category = category or 'level'
    
    local validCategories = {
        level = 'level',
        experience = 'experience',
        routes_done = 'routes_done',
        total_earned = 'total_earned'
    }
    
    if not validCategories[category] then
        category = 'level'
    end
    
    -- Get top players from database
    local query = string.format([[
        SELECT 
            p.identifier,
            p.level,
            p.experience,
            p.routes_done,
            p.total_earned,
            p.last_played
        FROM hm_busjob_players p
        ORDER BY p.%s DESC
        LIMIT ?
    ]], validCategories[category])
    
    local results = MySQL.query.await(query, {limit})
    
    if not results then
        return {}
    end
    
    -- Get player names from framework
    local leaderboard = {}
    
    for i, data in ipairs(results) do
        local playerName = GetPlayerNameFromIdentifier(data.identifier)
        
        table.insert(leaderboard, {
            rank = i,
            name = playerName or 'Unknown',
            level = data.level,
            experience = data.experience,
            routesDone = data.routes_done,
            totalEarned = data.total_earned,
            lastPlayed = data.last_played
        })
    end
    
    return leaderboard
end)

-- ════════════════════════════════════════════════════════════════════════════════════
-- GET PLAYER RANK
-- ════════════════════════════════════════════════════════════════════════════════════

lib.callback.register('hm_busjob:getPlayerRank', function(source, category)
    category = category or 'level'
    
    local validCategories = {
        level = 'level',
        experience = 'experience',
        routes_done = 'routes_done',
        total_earned = 'total_earned'
    }
    
    if not validCategories[category] then
        category = 'level'
    end
    
    local player = Framework.GetPlayer(source)
    if not player then return nil end
    
    local identifier = player.PlayerData.citizenid or player.PlayerData.identifier
    
    -- Get player's rank
    local query = string.format([[
        SELECT COUNT(*) + 1 as rank
        FROM hm_busjob_players
        WHERE %s > (
            SELECT %s FROM hm_busjob_players WHERE identifier = ?
        )
    ]], validCategories[category], validCategories[category])
    
    local result = MySQL.query.await(query, {identifier})
    
    if result and #result > 0 then
        return result[1].rank
    end
    
    return nil
end)

-- ════════════════════════════════════════════════════════════════════════════════════
-- HELPER FUNCTIONS
-- ════════════════════════════════════════════════════════════════════════════════════

function GetPlayerNameFromIdentifier(identifier)
    if Config.Framework == 'qbox' or Config.Framework == 'qbcore' then
        local result = MySQL.query.await('SELECT charinfo FROM players WHERE citizenid = ?', {identifier})
        
        if result and #result > 0 then
            local charinfo = json.decode(result[1].charinfo)
            if charinfo then
                return charinfo.firstname .. ' ' .. charinfo.lastname
            end
        end
    elseif Config.Framework == 'esx' then
        local result = MySQL.query.await('SELECT firstname, lastname FROM users WHERE identifier = ?', {identifier})
        
        if result and #result > 0 then
            return result[1].firstname .. ' ' .. result[1].lastname
        end
    end
    
    return 'Unknown Player'
end

-- ════════════════════════════════════════════════════════════════════════════════════
-- ADMIN COMMAND
-- ════════════════════════════════════════════════════════════════════════════════════

lib.addCommand('busjob_leaderboard', {
    help = 'View bus job leaderboard',
    params = {
        { name = 'category', type = 'string', help = 'Category (level/routes/earned)', optional = true }
    }
}, function(source, args)
    local category = args.category or 'level'
    local categoryMap = {
        level = 'level',
        routes = 'routes_done',
        earned = 'total_earned',
        xp = 'experience'
    }
    
    local actualCategory = categoryMap[category] or 'level'
    local leaderboard = lib.callback.await('hm_busjob:getLeaderboard', source, actualCategory, 10)
    
    if not leaderboard or #leaderboard == 0 then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Bus Job Leaderboard',
            description = 'No data available',
            type = 'error'
        })
        return
    end
    
    -- Format leaderboard
    local message = string.format('^3═══ Bus Job Leaderboard (%s) ═══^0\n', category:upper())
    
    for _, entry in ipairs(leaderboard) do
        if actualCategory == 'level' then
            message = message .. string.format('^2#%d^0 %s - ^5Level %d^0 (^3%d XP^0)\n', 
                entry.rank, entry.name, entry.level, entry.experience)
        elseif actualCategory == 'routes_done' then
            message = message .. string.format('^2#%d^0 %s - ^5%d routes^0\n', 
                entry.rank, entry.name, entry.routesDone)
        elseif actualCategory == 'total_earned' then
            message = message .. string.format('^2#%d^0 %s - ^5$%d^0\n', 
                entry.rank, entry.name, entry.totalEarned)
        elseif actualCategory == 'experience' then
            message = message .. string.format('^2#%d^0 %s - ^5%d XP^0 (Level %d)\n', 
                entry.rank, entry.name, entry.experience, entry.level)
        end
    end
    
    print(message)
end)
