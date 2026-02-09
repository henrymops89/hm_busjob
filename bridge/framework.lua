-- ════════════════════════════════════════════════════════════════════════════════════
-- FRAMEWORK BRIDGE - Multi-Framework Support (QBox, QBCore, ESX)
-- ════════════════════════════════════════════════════════════════════════════════════

-- ════════════════════════════════════════════════════════════════════════════════════
-- AUTO-DETECTION
-- ════════════════════════════════════════════════════════════════════════════════════

if Config.Framework == 'auto' then
    if GetResourceState('qbx_core') == 'started' or GetResourceState('qbx_core') == 'starting' then
        Config.Framework = 'qbox'
        if Config.Debug then
            print('^2[HM BusJob]^7 Framework Auto-detected: ^3QBox^7')
        end
    elseif GetResourceState('qb-core') == 'started' or GetResourceState('qb-core') == 'starting' then
        Config.Framework = 'qbcore'
        if Config.Debug then
            print('^2[HM BusJob]^7 Framework Auto-detected: ^3QBCore^7')
        end
    elseif GetResourceState('es_extended') == 'started' or GetResourceState('es_extended') == 'starting' then
        Config.Framework = 'esx'
        if Config.Debug then
            print('^2[HM BusJob]^7 Framework Auto-detected: ^3ESX^7')
        end
    else
        Config.Framework = 'qbcore'
        print('^3[HM BusJob]^7 No framework detected, defaulting to ^3QBCore^7')
    end
end

-- ════════════════════════════════════════════════════════════════════════════════════
-- CORE INITIALIZATION
-- ════════════════════════════════════════════════════════════════════════════════════

Framework = {}
Framework.Type = Config.Framework

if Framework.Type == 'qbox' then
    Framework.Core = exports.qbx_core
elseif Framework.Type == 'qbcore' then
    Framework.Core = exports['qb-core']:GetCoreObject()
elseif Framework.Type == 'esx' then
    Framework.Core = ESX or exports['es_extended']:getSharedObject()
end

-- ════════════════════════════════════════════════════════════════════════════════════
-- PLAYER FUNCTIONS
-- ════════════════════════════════════════════════════════════════════════════════════

--- Get player object from source
--- @param source number Player server ID
--- @return table|nil Player object
function Framework.GetPlayer(source)
    if Framework.Type == 'qbox' then
        return exports.qbx_core:GetPlayer(source)
    elseif Framework.Type == 'qbcore' then
        return Framework.Core.Functions.GetPlayer(source)
    elseif Framework.Type == 'esx' then
        if ESX.Player then
            return ESX.Player(source)
        else
            return Framework.Core.GetPlayerFromId(source)
        end
    end
end

--- Get player identifier
--- @param source number Player server ID
--- @return string|nil Identifier
function Framework.GetIdentifier(source)
    if Framework.Type == 'qbox' or Framework.Type == 'qbcore' then
        local Player = Framework.GetPlayer(source)
        return Player and Player.PlayerData.citizenid or nil
    elseif Framework.Type == 'esx' then
        local Player = Framework.GetPlayer(source)
        return Player and Player.identifier or nil
    end
end

--- Get player name
--- @param source number Player server ID
--- @return string Player name
function Framework.GetPlayerName(source)
    if Framework.Type == 'qbox' or Framework.Type == 'qbcore' then
        local Player = Framework.GetPlayer(source)
        if not Player then return 'Unknown' end
        local charinfo = Player.PlayerData.charinfo
        return ('%s %s'):format(charinfo.firstname, charinfo.lastname)
    elseif Framework.Type == 'esx' then
        local Player = Framework.GetPlayer(source)
        return Player and Player.getName() or 'Unknown'
    end
end

-- ════════════════════════════════════════════════════════════════════════════════════
-- MONEY FUNCTIONS
-- ════════════════════════════════════════════════════════════════════════════════════

--- Add money to player
--- @param source number Player server ID
--- @param amount number Amount to add
--- @param account string Account type ('cash', 'bank')
--- @return boolean Success
function Framework.AddMoney(source, amount, account)
    account = account or 'cash'
    local Player = Framework.GetPlayer(source)
    if not Player then return false end

    if Framework.Type == 'qbox' or Framework.Type == 'qbcore' then
        Player.Functions.AddMoney(account, amount)
        return true
    elseif Framework.Type == 'esx' then
        local accountType = account == 'cash' and 'money' or account
        Player.addAccountMoney(accountType, amount)
        return true
    end
end

--- Remove money from player
--- @param source number Player server ID
--- @param amount number Amount to remove
--- @param account string Account type ('cash', 'bank')
--- @return boolean Success
function Framework.RemoveMoney(source, amount, account)
    account = account or 'cash'
    local Player = Framework.GetPlayer(source)
    if not Player then return false end

    if Framework.Type == 'qbox' or Framework.Type == 'qbcore' then
        return Player.Functions.RemoveMoney(account, amount)
    elseif Framework.Type == 'esx' then
        local accountType = account == 'cash' and 'money' or account
        Player.removeAccountMoney(accountType, amount)
        return true
    end
end

--- Get player money
--- @param source number Player server ID
--- @param account string Account type ('cash', 'bank')
--- @return number Amount
function Framework.GetMoney(source, account)
    account = account or 'cash'
    local Player = Framework.GetPlayer(source)
    if not Player then return 0 end

    if Framework.Type == 'qbox' or Framework.Type == 'qbcore' then
        return Player.PlayerData.money[account] or 0
    elseif Framework.Type == 'esx' then
        local accountType = account == 'cash' and 'money' or account
        return Player.getAccount(accountType).money or 0
    end
end

-- ════════════════════════════════════════════════════════════════════════════════════
-- SERVER CALLBACKS (Server-Side Only)
-- ════════════════════════════════════════════════════════════════════════════════════

if IsDuplicityVersion() == 1 then
    
    --- Register server callback
    --- @param name string Callback name
    --- @param callback function Callback function
    function Framework.RegisterCallback(name, callback)
        if Framework.Type == 'qbox' then
            lib.callback.register(name, function(source, ...)
                local result = nil
                local function fakeCb(data)
                    result = data
                end
                callback(source, fakeCb, ...)
                return result
            end)
        elseif Framework.Type == 'qbcore' then
            Framework.Core.Functions.CreateCallback(name, callback)
        elseif Framework.Type == 'esx' then
            Framework.Core.RegisterServerCallback(name, callback)
        end
    end
    
else
    
    --- Get local player data (Client-Side Only)
    --- @return table Player data
    function Framework.GetPlayerData()
        if Framework.Type == 'qbox' then
            return exports.qbx_core:GetPlayerData()
        elseif Framework.Type == 'qbcore' then
            return Framework.Core.Functions.GetPlayerData()
        elseif Framework.Type == 'esx' then
            return Framework.Core.GetPlayerData()
        end
    end
    
    --- Trigger server callback (Client-Side Only)
    --- @param name string Callback name
    --- @param callback function Callback function
    --- @param ... any Arguments
    function Framework.TriggerCallback(name, callback, ...)
        if Framework.Type == 'qbox' then
            lib.callback(name, false, callback, ...)
        elseif Framework.Type == 'qbcore' then
            Framework.Core.Functions.TriggerCallback(name, callback, ...)
        elseif Framework.Type == 'esx' then
            Framework.Core.TriggerServerCallback(name, callback, ...)
        end
    end
    
end
