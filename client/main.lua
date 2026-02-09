-- ════════════════════════════════════════════════════════════════════════════════════
-- HM BUS JOB - CLIENT MAIN
-- ════════════════════════════════════════════════════════════════════════════════════

-- Simple locale function (temporary)
local PlayerData = {}
isJobActive = false -- GLOBAL
currentBus = nil -- GLOBAL  
currentRoute = nil -- GLOBAL
currentRouteIndex = 0
currentStopIndex = 0 -- GLOBAL
routeBlips = {} -- GLOBAL for route.lua
stopMarkers = {} -- GLOBAL
spawnedPassengers = {} -- GLOBAL

-- ════════════════════════════════════════════════════════════════════════════════════
-- INITIALIZATION
-- ════════════════════════════════════════════════════════════════════════════════════

CreateThread(function()
    -- Wait for player to load
    while not LocalPlayer.state.isLoggedIn do
        Wait(100)
    end
    
    Wait(1000) -- Extra wait for framework to fully load
    
    -- Get player data from framework
    PlayerData = Framework.GetPlayerData()
    
    if not PlayerData then
        -- Retry getting player data
        Wait(2000)
        PlayerData = Framework.GetPlayerData()
    end
    
    -- Create job blip
    if Config.JobBlip.enabled then
        CreateJobBlip()
    end
    
    -- Setup job location interaction
    SetupJobLocation()
    
    if Config.Debug then
        print('[HM BUS JOB] Client initialized')
        if PlayerData and PlayerData.charinfo then
            print('[HM BUS JOB] Player loaded: ' .. PlayerData.charinfo.firstname .. ' ' .. PlayerData.charinfo.lastname)
        end
    end
end)

-- ════════════════════════════════════════════════════════════════════════════════════
-- JOB BLIP
-- ════════════════════════════════════════════════════════════════════════════════════

function CreateJobBlip()
    local blip = AddBlipForCoord(Config.JobLocation.x, Config.JobLocation.y, Config.JobLocation.z)
    SetBlipSprite(blip, Config.JobBlip.sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, Config.JobBlip.scale)
    SetBlipColour(blip, Config.JobBlip.color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(Config.JobBlip.label)
    EndTextCommandSetBlipName(blip)
end

-- ════════════════════════════════════════════════════════════════════════════════════
-- JOB LOCATION INTERACTION
-- ════════════════════════════════════════════════════════════════════════════════════

function SetupJobLocation()
    -- Target interaction is now handled by the depot ped in client/ped.lua
    -- This function is kept for backwards compatibility
    if Config.Debug then
        print('[HM BUS JOB] Job location setup - using depot ped for interactions')
    end
end

-- ════════════════════════════════════════════════════════════════════════════════════
-- MENU SYSTEM
-- ════════════════════════════════════════════════════════════════════════════════════

function OpenJobMenu()
    if Config.Debug then
        print('[HM BUS JOB] OpenJobMenu() called - isJobActive = ' .. tostring(isJobActive))
    end
    
    if isJobActive then
        lib.notify({
            title = L('job_title'),
            description = L('error_already_working'),
            type = 'error'
        })
        if Config.Debug then
            print('[HM BUS JOB] Menu blocked - job is active')
        end
        return
    end
    
    -- Request player stats from server
    local playerStats = lib.callback.await('hm_busjob:getPlayerStats', false)
    
    if Config.Debug then
        print('[HM BUS JOB] Received player stats:')
        if playerStats then
            print('  Level: ' .. playerStats.level)
            print('  XP: ' .. playerStats.experience)
            print('  Routes Done: ' .. playerStats.routesDone)
            print('  Total Earned: $' .. playerStats.totalEarned)
        else
            print('  ❌ Stats are nil!')
        end
    end
    
    if not playerStats then
        lib.notify({
            title = L('job_title'),
            description = L('error_loading_data'),
            type = 'error'
        })
        return
    end
    
    if Config.Debug then
        print('[HM BUS JOB] Opening NUI with SetNuiFocus(true, true)')
    end
    
    -- Open NUI
    SetNuiFocus(true, true)
    
    if Config.Debug then
        print('[HM BUS JOB] SetNuiFocus called - NUI should have focus now')
    end
    
    -- Get player name safely
    local playerName = 'Unknown'
    if PlayerData and PlayerData.charinfo then
        playerName = PlayerData.charinfo.firstname .. ' ' .. PlayerData.charinfo.lastname
    end
    
    if Config.Debug then
        print('[HM BUS JOB] Sending openMenu message to NUI...')
    end
    
    SendNUIMessage({
        action = 'openMenu',
        playerData = {
            name = playerName,
            level = playerStats.level,
            experience = playerStats.experience,
            routesDone = playerStats.routesDone,
            totalEarned = playerStats.totalEarned
        },
        routes = Config.Routes,
        selectedRoute = currentRouteIndex,
        theme = Config.Theme,
        locale = {
            unknown_player = L('unknown_player'),
            start_route_btn = L('start_route_btn'),
            -- NUI labels
            route_name = L('nui_route_name'),
            salary = L('nui_salary'),
            stops = L('nui_stops'),
            workers = L('nui_workers'),
            est_time = L('nui_est_time'),
            payment = L('nui_payment'),
            route_locked = L('nui_route_locked'),
            to_unlock = L('nui_to_unlock'),
            level_required = L('nui_level_required'),
            routes_progress = L('nui_routes_progress'),
            locked = L('nui_locked'),
            selected = L('nui_selected'),
            select = L('nui_select')
        }
    })
    
    if Config.Debug then
        print('[HM BUS JOB] SendNUIMessage called - NUI should open now')
        print('[HM BUS JOB] If NUI does not open, check F8 for JavaScript errors')
    end
end

function CloseJobMenu()
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'closeMenu'
    })
end

-- ════════════════════════════════════════════════════════════════════════════════════
-- NUI CALLBACKS
-- ════════════════════════════════════════════════════════════════════════════════════

RegisterNUICallback('closeMenu', function(data, cb)
    if Config.Debug then
        print('[HM BUS JOB] NUI closeMenu callback received')
    end
    
    -- Just close NUI focus, don't send message back to NUI (would create loop)
    SetNuiFocus(false, false)
    
    cb('ok')
end)

RegisterNUICallback('selectRoute', function(data, cb)
    local routeId = data.routeId
    
    -- Find route in config
    local route = nil
    for _, r in ipairs(Config.Routes) do
        if r.id == routeId then
            route = r
            break
        end
    end
    
    if not route then
        cb({ success = false, message = 'Invalid route' })
        return
    end
    
    -- Check if route is locked
    local playerStats = lib.callback.await('hm_busjob:getPlayerStats', false)
    
    if not playerStats then
        cb({ success = false, message = 'Error loading player data' })
        return
    end
    
    if playerStats.level < route.requiredLevel then
        cb({ success = false, message = 'Level too low' })
        return
    end
    
    if playerStats.routesDone < route.requiredRoutesCompleted then
        cb({ success = false, message = 'Not enough routes completed' })
        return
    end
    
    -- Select route
    currentRoute = route
    currentRouteIndex = routeId
    
    lib.notify({
        title = L('job_title'),
        description = L('route_selected', route.name),
        type = 'success'
    })
    cb({ success = true })
end)

RegisterNUICallback('startRoute', function(data, cb)
    if not currentRoute then
        cb({ success = false, message = 'No route selected' })
        return
    end
    
    CloseJobMenu()
    
    -- Notify to spawn bus
    lib.notify({
        title = L('job_title'),
        description = L('go_to_depot'),
        type = 'info'
    })
    
    cb({ success = true })
end)

-- ════════════════════════════════════════════════════════════════════════════════════
-- COMMAND & KEYBIND
-- ════════════════════════════════════════════════════════════════════════════════════

RegisterCommand(Config.JobMenuCommand, function()
    if Config.Debug then
        print('[HM BUS JOB] Command /busjob executed - calling OpenJobMenu()')
    end
    OpenJobMenu()
end, false)

if Config.JobMenuKey then
    RegisterKeyMapping(Config.JobMenuCommand, 'Open Bus Job Menu', 'keyboard', Config.JobMenuKey)
end

-- ════════════════════════════════════════════════════════════════════════════════════
-- EXPORTS
-- ════════════════════════════════════════════════════════════════════════════════════

exports('OpenJobMenu', OpenJobMenu)
exports('IsJobActive', function() return isJobActive end)
exports('GetCurrentRoute', function() return currentRoute end)
