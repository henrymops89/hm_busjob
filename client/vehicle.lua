-- ════════════════════════════════════════════════════════════════════════════════════
-- HM BUS JOB - VEHICLE SYSTEM
-- ════════════════════════════════════════════════════════════════════════════════════

-- ════════════════════════════════════════════════════════════════════════════════════
-- BUS SPAWNING
-- ════════════════════════════════════════════════════════════════════════════════════

function SpawnBus()
    if currentBus then
        lib.notify({title='Bus Job',description=L('bus_already_spawned'),type='error'})
        return
    end
    
    if not currentRoute then
        lib.notify({title='Bus Job',description=L('no_route_selected'),type='error'})
        return
    end
    
    -- Get player stats to determine bus model
    local playerStats = lib.callback.await('hm_busjob:getPlayerStats', false)
    local busModel = GetBusModelForLevel(playerStats.level)
    
    -- Request model
    local modelHash = GetHashKey(busModel)
    RequestModel(modelHash)
    
    while not HasModelLoaded(modelHash) do
        Wait(100)
    end
    
    -- Check if spawn location is clear
    if not IsSpawnPointClear(Config.BusSpawnLocation, 3.0) then
        lib.notify({title='Bus Job',description=L('spawn_blocked'),type='error'})
        SetModelAsNoLongerNeeded(modelHash)
        return
    end
    
    -- Spawn bus
    currentBus = CreateVehicle(
        modelHash,
        Config.BusSpawnLocation.x,
        Config.BusSpawnLocation.y,
        Config.BusSpawnLocation.z,
        Config.BusSpawnLocation.w,
        true,
        false
    )
    
    -- Set vehicle properties
    SetVehicleNumberPlateText(currentBus, 'BUS' .. math.random(100, 999))
    SetVehicleEngineOn(currentBus, false, false, false)
    SetVehicleFuelLevel(currentBus, 100.0)
    DecorSetFloat(currentBus, '_FUEL_LEVEL', 100.0)
    SetModelAsNoLongerNeeded(modelHash)
    
    -- Give keys
    TriggerEvent('vehiclekeys:client:SetOwner', GetVehicleNumberPlateText(currentBus))
    
    -- Set blip on bus
    local blip = AddBlipForEntity(currentBus)
    SetBlipSprite(blip, 513)
    SetBlipColour(blip, 47)
    SetBlipDisplay(blip, 2)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(L('your_bus'))
    EndTextCommandSetBlipName(blip)
    
    lib.notify({title='Bus Job',description=L('bus_spawned'),type='success'})
    
    -- Wait for player to enter
    CreateThread(function()
        while currentBus and DoesEntityExist(currentBus) do
            local ped = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(ped, false)
            
            if vehicle == currentBus then
                StartRoute()
                break
            end
            
            Wait(1000)
        end
    end)
end

-- ════════════════════════════════════════════════════════════════════════════════════
-- BUS RETURN
-- ════════════════════════════════════════════════════════════════════════════════════

function ReturnBus()
    if not currentBus or not DoesEntityExist(currentBus) then
        lib.notify({title='Bus Job',description=L('no_bus_spawned'),type='error'})
        return
    end
    
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    local depotCoords = Config.JobLocation
    local distance = #(pedCoords - depotCoords)
    
    if distance > 10.0 then
        lib.notify({title='Bus Job',description=L('too_far_from_depot'),type='error'})
        return
    end
    
    if isJobActive then
        -- Confirm cancellation
        local alert = lib.alertDialog({
            header = L('cancel_route'),
            content = L('cancel_route_confirm'),
            centered = true,
            cancel = true
        })
        
        if alert == 'cancel' then
            return
        end
        
        CancelRoute()
    end
    
    -- Despawn all passengers before deleting bus
    DespawnAllPassengers()
    
    -- Delete bus
    if DoesEntityExist(currentBus) then
        DeleteEntity(currentBus)
    end
    
    currentBus = nil
    lib.notify({title='Bus Job',description=L('bus_returned'),type='success'})
end

-- ════════════════════════════════════════════════════════════════════════════════════
-- HELPER FUNCTIONS
-- ════════════════════════════════════════════════════════════════════════════════════

function GetBusModelForLevel(level)
    local selectedModel = Config.BusModels[1] -- Default to lowest tier
    
    for requiredLevel, model in pairs(Config.BusModels) do
        if level >= requiredLevel then
            selectedModel = model
        end
    end
    
    return selectedModel
end

function IsSpawnPointClear(coords, radius)
    local vehicles = GetGamePool('CVehicle')
    
    for _, vehicle in ipairs(vehicles) do
        local vehCoords = GetEntityCoords(vehicle)
        local distance = #(vector3(coords.x, coords.y, coords.z) - vehCoords)
        
        if distance < radius then
            return false
        end
    end
    
    return true
end

-- ════════════════════════════════════════════════════════════════════════════════════
-- VEHICLE MONITORING
-- ════════════════════════════════════════════════════════════════════════════════════

CreateThread(function()
    while true do
        Wait(1000)
        
        if currentBus and DoesEntityExist(currentBus) then
            -- Check if bus is destroyed
            if GetEntityHealth(currentBus) <= 0 then
                lib.notify({title='Bus Job',description=L('bus_destroyed'),type='error'})
                CancelRoute()
                currentBus = nil
            end
        elseif currentBus and not DoesEntityExist(currentBus) then
            -- Bus was deleted
            lib.notify({title='Bus Job',description=L('bus_lost'),type='error'})
            CancelRoute()
            currentBus = nil
        end
    end
end)
