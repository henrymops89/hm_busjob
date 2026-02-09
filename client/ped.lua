-- ════════════════════════════════════════════════════════════════════════════════════
-- HM BUS JOB - NPC PED SYSTEM
-- ════════════════════════════════════════════════════════════════════════════════════

depotPed = nil -- GLOBAL for debugging
local pedModel = Config.DepotPed.model
local pedCoords = Config.DepotPed.coords
local pedHeading = Config.DepotPed.heading
local pedAnim = Config.DepotPed.animation

-- ════════════════════════════════════════════════════════════════════════════════════
-- SPAWN DEPOT PED
-- ════════════════════════════════════════════════════════════════════════════════════

CreateThread(function()
    -- Check if ped is enabled
    if not Config.DepotPed.enabled then
        return
    end
    
    -- Wait for game to load
    while not NetworkIsPlayerActive(PlayerId()) do
        Wait(100)
    end
    
    -- Load model
    local modelHash = GetHashKey(pedModel)
    RequestModel(modelHash)
    
    while not HasModelLoaded(modelHash) do
        Wait(100)
    end
    
    -- Spawn ped
    depotPed = CreatePed(
        4, -- Ped type (4 = mission ped)
        modelHash,
        pedCoords.x,
        pedCoords.y,
        pedCoords.z - 1.0, -- Adjust Z to be on ground
        pedHeading,
        false, -- Not networked
        true   -- Blink
    )
    
    -- Set ped properties
    SetEntityAsMissionEntity(depotPed, true, true)
    SetPedFleeAttributes(depotPed, 0, false)
    SetPedDiesWhenInjured(depotPed, false)
    SetPedCanPlayAmbientAnims(depotPed, true)
    SetPedCanRagdollFromPlayerImpact(depotPed, false)
    SetEntityInvincible(depotPed, true)
    FreezeEntityPosition(depotPed, true)
    SetBlockingOfNonTemporaryEvents(depotPed, true)
    
    -- Play idle animation
    if pedAnim and pedAnim.dict and pedAnim.name then
        RequestAnimDict(pedAnim.dict)
        while not HasAnimDictLoaded(pedAnim.dict) do
            Wait(100)
        end
        TaskPlayAnim(depotPed, pedAnim.dict, pedAnim.name, 8.0, 8.0, -1, 1, 0, false, false, false)
    end
    
    SetModelAsNoLongerNeeded(modelHash)
    
    -- Setup target interaction
    SetupPedTarget()
    
    if Config.Debug then
        print('[HM BUS JOB] Depot NPC spawned at ' .. pedCoords)
    end
end)

-- ════════════════════════════════════════════════════════════════════════════════════
-- TARGET INTERACTION
-- ════════════════════════════════════════════════════════════════════════════════════

function SetupPedTarget()
    if not depotPed or not DoesEntityExist(depotPed) then
        return
    end
    
    if Config.Target == 'ox_target' then
        -- Add target to the ped entity
        exports.ox_target:addLocalEntity(depotPed, {
            {
                name = 'busjob_menu',
                icon = 'fas fa-clipboard',
                label = L('open_job_menu'),
                distance = 3.0,
                onSelect = function()
                    OpenJobMenu()
                end
            },
            {
                name = 'busjob_spawn',
                icon = 'fas fa-bus',
                label = L('spawn_bus'),
                distance = 3.0,
                canInteract = function()
                    return not isJobActive and currentRoute ~= nil
                end,
                onSelect = function()
                    SpawnBus()
                end
            },
            {
                name = 'busjob_return',
                icon = 'fas fa-hand-holding',
                label = L('return_bus'),
                distance = 3.0,
                canInteract = function()
                    return isJobActive and currentBus ~= nil
                end,
                onSelect = function()
                    ReturnBus()
                end
            }
        })
    elseif Config.Target == 'qb-target' then
        exports['qb-target']:AddTargetEntity(depotPed, {
            options = {
                {
                    icon = 'fas fa-clipboard',
                    label = L('open_job_menu'),
                    action = function()
                        OpenJobMenu()
                    end
                },
                {
                    icon = 'fas fa-bus',
                    label = L('spawn_bus'),
                    canInteract = function()
                        return not isJobActive and currentRoute ~= nil
                    end,
                    action = function()
                        SpawnBus()
                    end
                },
                {
                    icon = 'fas fa-hand-holding',
                    label = L('return_bus'),
                    canInteract = function()
                        return isJobActive and currentBus ~= nil
                    end,
                    action = function()
                        ReturnBus()
                    end
                }
            },
            distance = 2.5
        })
    end
end

-- ════════════════════════════════════════════════════════════════════════════════════
-- CLEANUP ON RESOURCE STOP
-- ════════════════════════════════════════════════════════════════════════════════════

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    
    -- Delete ped
    if depotPed and DoesEntityExist(depotPed) then
        DeleteEntity(depotPed)
    end
end)

-- ════════════════════════════════════════════════════════════════════════════════════
-- PED MONITORING (respawn if deleted)
-- ════════════════════════════════════════════════════════════════════════════════════

CreateThread(function()
    while true do
        Wait(5000) -- Check every 5 seconds
        
        if not depotPed or not DoesEntityExist(depotPed) then
            -- Ped was deleted, respawn
            if Config.Debug then
                print('[HM BUS JOB] Depot NPC was deleted, respawning...')
            end
            
            local modelHash = GetHashKey(pedModel)
            RequestModel(modelHash)
            
            while not HasModelLoaded(modelHash) do
                Wait(100)
            end
            
            depotPed = CreatePed(4, modelHash, pedCoords.x, pedCoords.y, pedCoords.z - 1.0, pedHeading, false, true)
            
            SetEntityAsMissionEntity(depotPed, true, true)
            SetPedFleeAttributes(depotPed, 0, false)
            SetPedDiesWhenInjured(depotPed, false)
            SetPedCanPlayAmbientAnims(depotPed, true)
            SetPedCanRagdollFromPlayerImpact(depotPed, false)
            SetEntityInvincible(depotPed, true)
            FreezeEntityPosition(depotPed, true)
            SetBlockingOfNonTemporaryEvents(depotPed, true)
            
            RequestAnimDict(pedAnim.dict)
            while not HasAnimDictLoaded(pedAnim.dict) do
                Wait(100)
            end
            TaskPlayAnim(depotPed, pedAnim.dict, pedAnim.name, 8.0, 8.0, -1, 1, 0, false, false, false)
            
            SetModelAsNoLongerNeeded(modelHash)
            SetupPedTarget()
        end
    end
end)
