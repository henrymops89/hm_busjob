-- ════════════════════════════════════════════════════════════════════════════════════
-- HM BUS JOB - ROUTE SYSTEM
-- ════════════════════════════════════════════════════════════════════════════════════

stopCheckpoints = {} -- GLOBAL
routeCompleteRewards = { -- GLOBAL
    money = 0,
    xp = 0,
    fines = 0
}

-- ════════════════════════════════════════════════════════════════════════════════════
-- START ROUTE
-- ════════════════════════════════════════════════════════════════════════════════════

function StartRoute()
    print('[HM BUS JOB] StartRoute() called')
    print('[HM BUS JOB] currentRoute: ' .. tostring(currentRoute))
    print('[HM BUS JOB] currentBus: ' .. tostring(currentBus))
    
    if not currentRoute or not currentBus then
        print('[HM BUS JOB] ❌ Missing currentRoute or currentBus!')
        return
    end
    
    print('[HM BUS JOB] ✅ Starting route: ' .. currentRoute.name)
    print('[HM BUS JOB] Route has ' .. #currentRoute.stops .. ' stops')
    
    isJobActive = true
    currentStopIndex = 1
    routeCompleteRewards = {
        money = currentRoute.salary,
        xp = Config.XPRewards.routeCompleted,
        fines = 0
    }
    
    lib.notify({title='Bus Job',description=L('route_started', currentRoute.name),type='success'})
    
    -- Create route blips
    print('[HM BUS JOB] Creating route blips...')
    CreateRouteBlips()
    
    -- Start monitoring
    print('[HM BUS JOB] Starting route monitoring...')
    MonitorRoute()
    
    -- Go to first stop
    print('[HM BUS JOB] Going to first stop...')
    GoToNextStop()
    
    print('[HM BUS JOB] ✅ StartRoute() completed!')
end

-- ════════════════════════════════════════════════════════════════════════════════════
-- STOP NAVIGATION
-- ════════════════════════════════════════════════════════════════════════════════════

function GoToNextStop()
    print('[HM BUS JOB] GoToNextStop() called')
    print('[HM BUS JOB] currentStopIndex: ' .. currentStopIndex)
    print('[HM BUS JOB] Total stops: ' .. (currentRoute and #currentRoute.stops or 0))
    
    if not currentRoute or currentStopIndex > #currentRoute.stops then
        print('[HM BUS JOB] ❌ No route or stop index too high!')
        return
    end
    
    local stop = currentRoute.stops[currentStopIndex]
    print('[HM BUS JOB] Current stop: ' .. stop.label)
    print('[HM BUS JOB] Stop coords: ' .. stop.coords.x .. ', ' .. stop.coords.y .. ', ' .. stop.coords.z)
    
    -- Create checkpoint
    print('[HM BUS JOB] Creating checkpoint...')
    local checkpoint = CreateCheckpoint(
        47, -- Checkpoint type (cylinder)
        stop.coords.x,
        stop.coords.y,
        stop.coords.z,
        stop.coords.x,
        stop.coords.y,
        stop.coords.z,
        5.0, -- Diameter
        255, 165, 0, 150, -- Orange color
        0
    )
    
    stopCheckpoints[currentStopIndex] = checkpoint
    print('[HM BUS JOB] Checkpoint created: ' .. checkpoint)
    
    -- Set waypoint
    print('[HM BUS JOB] Setting waypoint...')
    SetNewWaypoint(stop.coords.x, stop.coords.y)
    
    -- Create blip
    print('[HM BUS JOB] Creating blip...')
    local blip = AddBlipForCoord(stop.coords.x, stop.coords.y, stop.coords.z)
    SetBlipSprite(blip, Config.Blips.busStop.sprite)
    SetBlipColour(blip, Config.Blips.busStop.color)
    SetBlipScale(blip, Config.Blips.busStop.scale)
    SetBlipRoute(blip, Config.Blips.busStop.route)
    SetBlipRouteColour(blip, Config.Blips.busStop.routeColor)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(stop.label)
    EndTextCommandSetBlipName(blip)
    routeBlips[currentStopIndex] = blip
    print('[HM BUS JOB] Blip created: ' .. blip)
    
    lib.notify({
        title = 'Bus Job',
        description = L('go_to_stop', stop.label),
        type = 'info',
        duration = 5000
    })
    
    print('[HM BUS JOB] ✅ GoToNextStop() completed!')
    
    -- Monitor arrival
    MonitorStopArrival(stop)
end

-- ════════════════════════════════════════════════════════════════════════════════════
-- STOP ARRIVAL MONITORING
-- ════════════════════════════════════════════════════════════════════════════════════

function MonitorStopArrival(stop)
    CreateThread(function()
        while isJobActive and currentStopIndex <= #currentRoute.stops do
            local ped = PlayerPedId()
            local pedCoords = GetEntityCoords(ped)
            local distance = #(pedCoords - stop.coords)
            
            -- Check if player is in bus
            local vehicle = GetVehiclePedIsIn(ped, false)
            if vehicle ~= currentBus then
                Wait(1000)
                goto continue
            end
            
            -- Check if at stop
            if distance < 5.0 then
                -- Stop arrived
                OnStopArrival(stop)
                break
            end
            
            ::continue::
            Wait(100)
        end
    end)
end

-- ════════════════════════════════════════════════════════════════════════════════════
-- STOP COMPLETION
-- ════════════════════════════════════════════════════════════════════════════════════

function OnStopArrival(stop)
    -- Remove checkpoint
    if stopCheckpoints[currentStopIndex] then
        DeleteCheckpoint(stopCheckpoints[currentStopIndex])
        stopCheckpoints[currentStopIndex] = nil
    end
    
    -- Remove blip
    if routeBlips[currentStopIndex] then
        RemoveBlip(routeBlips[currentStopIndex])
        routeBlips[currentStopIndex] = nil
    end
    
    lib.notify({title='Bus Job',description=L('stop_reached', stop.label),type='success'})
    
    -- Show progress text
    local progress = string.format('%d/%d', currentStopIndex, #currentRoute.stops)
    lib.notify({
        title = L('route_progress'),
        description = progress,
        type = 'info',
        duration = 3000
    })
    
    -- Spawn passengers if enabled
    if Config.NPCPassengers.enabled then
        SpawnPassengers(stop)
    end
    
    -- Wait a bit
    Wait(3000)
    
    -- Add XP for stop
    routeCompleteRewards.xp = routeCompleteRewards.xp + Config.XPRewards.stopCompleted
    
    -- Move to next stop
    currentStopIndex = currentStopIndex + 1
    
    if currentStopIndex <= #currentRoute.stops then
        GoToNextStop()
    else
        -- All stops completed - return to depot for payout
        ReturnToDepot()
    end
end

-- ════════════════════════════════════════════════════════════════════════════════════
-- RETURN TO DEPOT
-- ════════════════════════════════════════════════════════════════════════════════════

function ReturnToDepot()
    if not isJobActive then
        return
    end
    
    lib.notify({
        title = L('job_title'),
        description = L('return_to_depot'),
        type = 'success',
        duration = 8000
    })
    
    -- Create checkpoint at depot
    local depotCoords = Config.JobLocation
    local checkpoint = CreateCheckpoint(
        47, -- Checkpoint type (cylinder)
        depotCoords.x,
        depotCoords.y,
        depotCoords.z,
        depotCoords.x,
        depotCoords.y,
        depotCoords.z,
        5.0, -- Diameter
        255, 165, 0, 150, -- Orange color
        0
    )
    
    -- Create blip for depot
    local blip = AddBlipForCoord(depotCoords.x, depotCoords.y, depotCoords.z)
    SetBlipSprite(blip, 513)
    SetBlipColour(blip, 47)
    SetBlipScale(blip, 0.8)
    SetBlipRoute(blip, true)
    SetBlipRouteColour(blip, 47)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName('Bus Depot (Return)')
    EndTextCommandSetBlipName(blip)
    
    -- Set waypoint
    SetNewWaypoint(depotCoords.x, depotCoords.y)
    
    -- Monitor arrival at depot
    CreateThread(function()
        if Config.Debug then
            print('[HM BUS JOB] ReturnToDepot monitoring thread started')
        end
        
        while isJobActive do
            local ped = PlayerPedId()
            local pedCoords = GetEntityCoords(ped)
            local distance = #(pedCoords - depotCoords)
            
            -- Check if player is in bus
            local vehicle = GetVehiclePedIsIn(ped, false)
            if vehicle ~= currentBus then
                Wait(1000)
                goto continue
            end
            
            -- Check if at depot
            if distance < 10.0 then
                if Config.Debug then
                    print('[HM BUS JOB] Player arrived at depot (distance: ' .. string.format("%.2f", distance) .. 'm) - calling CompleteRoute()')
                end
                
                -- Arrived at depot - complete route
                DeleteCheckpoint(checkpoint)
                RemoveBlip(blip)
                
                -- Delete bus automatically
                if currentBus and DoesEntityExist(currentBus) then
                    if Config.Debug then
                        print('[HM BUS JOB] Auto-deleting bus at depot')
                    end
                    DeleteEntity(currentBus)
                    currentBus = nil
                end
                
                CompleteRoute()
                break
            end
            
            ::continue::
            Wait(100)
        end
        
        if Config.Debug then
            print('[HM BUS JOB] ReturnToDepot monitoring thread ended')
        end
    end)
end

-- ════════════════════════════════════════════════════════════════════════════════════
-- ROUTE COMPLETION
-- ════════════════════════════════════════════════════════════════════════════════════

function CompleteRoute()
    if Config.Debug then
        print('[HM BUS JOB] CompleteRoute() called')
    end
    
    if not isJobActive then
        if Config.Debug then
            print('[HM BUS JOB] CompleteRoute() aborted - isJobActive already false')
        end
        return
    end
    
    if Config.Debug then
        print('[HM BUS JOB] Processing route completion...')
    end
    
    -- Calculate final rewards
    local finalMoney = math.max(0, routeCompleteRewards.money - routeCompleteRewards.fines)
    local finalXP = routeCompleteRewards.xp
    
    -- Bonus for perfect route (no fines)
    if routeCompleteRewards.fines == 0 then
        finalXP = finalXP + Config.XPRewards.perfectRoute
        lib.notify({title='Bus Job',description=L('perfect_route_bonus'),type='success'})
    end
    
    -- Send to server
    local success = lib.callback.await('hm_busjob:completeRoute', false, {
        routeId = currentRoute.id,
        money = finalMoney,
        xp = finalXP,
        fines = routeCompleteRewards.fines
    })
    
    if success then
        lib.notify({
            title = 'Bus Job',
            description = L('route_completed', finalMoney, finalXP),
            type = 'success',
            duration = 8000
        })
    end
    
    -- Cleanup
    CleanupRoute()
    
    if Config.Debug then
        print('[HM BUS JOB] CompleteRoute() finished - isJobActive should now be: ' .. tostring(isJobActive))
    end
end

-- ════════════════════════════════════════════════════════════════════════════════════
-- ROUTE CANCELLATION
-- ════════════════════════════════════════════════════════════════════════════════════

function CancelRoute()
    if not isJobActive then
        return
    end
    
    lib.notify({title='Bus Job',description=L('route_cancelled'),type='error'})
    CleanupRoute()
end

-- ════════════════════════════════════════════════════════════════════════════════════
-- CLEANUP
-- ════════════════════════════════════════════════════════════════════════════════════

function CleanupRoute()
    if Config.Debug then
        print('[HM BUS JOB] CleanupRoute() called - Setting isJobActive = false')
    end
    
    isJobActive = false
    currentRoute = nil
    currentRouteIndex = 0
    currentStopIndex = 0
    
    -- Remove all checkpoints
    for _, checkpoint in pairs(stopCheckpoints) do
        DeleteCheckpoint(checkpoint)
    end
    stopCheckpoints = {}
    
    -- Remove all blips
    for _, blip in pairs(routeBlips) do
        RemoveBlip(blip)
    end
    routeBlips = {}
    
    -- Despawn all passengers
    DespawnAllPassengers()
    
    -- Reset rewards
    routeCompleteRewards = {
        money = 0,
        xp = 0,
        fines = 0
    }
    
    if Config.Debug then
        print('[HM BUS JOB] CleanupRoute() completed - isJobActive is now: ' .. tostring(isJobActive))
    end
end

-- ════════════════════════════════════════════════════════════════════════════════════
-- ROUTE BLIPS
-- ════════════════════════════════════════════════════════════════════════════════════

function CreateRouteBlips()
    -- Create blips for all stops (dim color for future stops)
    for i, stop in ipairs(currentRoute.stops) do
        if i > 1 then -- Skip first stop (already created)
            local blip = AddBlipForCoord(stop.coords.x, stop.coords.y, stop.coords.z)
            SetBlipSprite(blip, Config.Blips.busStop.sprite)
            SetBlipColour(blip, 2) -- Dim color
            SetBlipScale(blip, 0.5)
            SetBlipAlpha(blip, 128)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(stop.label)
            EndTextCommandSetBlipName(blip)
            routeBlips[i] = blip
        end
    end
end

-- ════════════════════════════════════════════════════════════════════════════════════
-- ROUTE MONITORING
-- ════════════════════════════════════════════════════════════════════════════════════

function MonitorRoute()
    CreateThread(function()
        while isJobActive do
            Wait(1000)
            
            -- Check if player is still in bus
            local ped = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(ped, false)
            
            if vehicle ~= currentBus then
                -- Player left bus - give warning
                lib.notify({title='Bus Job',description=L('return_to_bus'),type='error'})
            end
        end
    end)
end
