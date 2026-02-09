-- ════════════════════════════════════════════════════════════════════════════════════
-- HM BUS JOB - DEBUG COMMANDS
-- ════════════════════════════════════════════════════════════════════════════════════

RegisterCommand('busjob_debug', function()
    print('═══════════════════════════════════════')
    print('HM BUS JOB DEBUG INFO')
    print('═══════════════════════════════════════')
    
    -- Check if config is loaded
    if Config then
        print('✅ Config loaded')
        print('   Framework: ' .. (Config.Framework or 'nil'))
        print('   Debug: ' .. tostring(Config.Debug))
        print('   DepotPed enabled: ' .. tostring(Config.DepotPed and Config.DepotPed.enabled))
    else
        print('❌ Config NOT loaded')
    end
    
    -- Check if depot ped exists
    if depotPed then
        print('✅ Depot Ped exists: ' .. tostring(depotPed))
        print('   Does exist: ' .. tostring(DoesEntityExist(depotPed)))
        if DoesEntityExist(depotPed) then
            local coords = GetEntityCoords(depotPed)
            print('   Coords: ' .. coords.x .. ', ' .. coords.y .. ', ' .. coords.z)
        end
    else
        print('❌ Depot Ped is nil')
    end
    
    -- Check current route
    print('')
    print('Current Job Status:')
    print('   isJobActive: ' .. tostring(isJobActive))
    print('   currentRoute: ' .. tostring(currentRoute))
    print('   currentBus: ' .. tostring(currentBus))
    if currentRoute then
        print('   Route Name: ' .. currentRoute.name)
        print('   Route ID: ' .. currentRoute.id)
    end
    
    -- Check player location
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    print('')
    print('Player Location:')
    print('   Coords: ' .. coords.x .. ', ' .. coords.y .. ', ' .. coords.z)
    
    local depotDist = #(coords - vector3(453.5, -602.4, 28.6))
    print('   Distance to depot: ' .. depotDist .. 'm')
    
    print('═══════════════════════════════════════')
end, false)

-- Teleport to depot command
RegisterCommand('busjob_goto', function()
    local ped = PlayerPedId()
    SetEntityCoords(ped, 453.5, -602.4, 28.6)
    print('[HM BUS JOB] Teleported to depot')
end, false)

-- Force spawn depot ped
RegisterCommand('busjob_spawnped', function()
    local modelHash = GetHashKey('cs_bankman')
    RequestModel(modelHash)
    
    while not HasModelLoaded(modelHash) do
        Wait(100)
    end
    
    if depotPed and DoesEntityExist(depotPed) then
        DeleteEntity(depotPed)
        print('[HM BUS JOB] Deleted old ped')
    end
    
    depotPed = CreatePed(4, modelHash, 453.5, -602.4, 28.6, 90.0, false, true)
    
    SetEntityAsMissionEntity(depotPed, true, true)
    SetPedFleeAttributes(depotPed, 0, false)
    SetPedDiesWhenInjured(depotPed, false)
    SetEntityInvincible(depotPed, true)
    FreezeEntityPosition(depotPed, true)
    SetBlockingOfNonTemporaryEvents(depotPed, true)
    
    SetModelAsNoLongerNeeded(modelHash)
    
    print('[HM BUS JOB] Spawned depot ped: ' .. tostring(depotPed))
    
    -- Setup target
    if Config.Target == 'ox_target' then
        exports.ox_target:addLocalEntity(depotPed, {
            {
                name = 'busjob_menu',
                icon = 'fas fa-clipboard',
                label = 'Open Job Menu',
                onSelect = function()
                    print('[HM BUS JOB] Opening menu...')
                    OpenJobMenu()
                end
            },
            {
                name = 'busjob_spawn',
                icon = 'fas fa-bus',
                label = 'Spawn Bus',
                canInteract = function()
                    local can = not isJobActive and currentRoute ~= nil
                    print('[HM BUS JOB] Can spawn bus: ' .. tostring(can))
                    return can
                end,
                onSelect = function()
                    print('[HM BUS JOB] Spawning bus...')
                    SpawnBus()
                end
            }
        })
        print('[HM BUS JOB] ox_target added to ped')
    end
end, false)

-- Force start route (for testing)
RegisterCommand('busjob_startroute', function()
    if not currentRoute then
        print('[HM BUS JOB] ❌ No route selected! Use /busjob menu first')
        return
    end
    
    if not currentBus then
        print('[HM BUS JOB] ❌ No bus spawned! Spawning bus now...')
        SpawnBus()
        Wait(2000)
    end
    
    print('[HM BUS JOB] ✅ Starting route: ' .. currentRoute.name)
    print('[HM BUS JOB] Stops: ' .. #currentRoute.stops)
    
    StartRoute()
    
    print('[HM BUS JOB] ✅ Route started! Check your map for waypoints!')
end, false)
