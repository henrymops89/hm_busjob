-- ════════════════════════════════════════════════════════════════════════════════════
-- HM BUS JOB - NPC PASSENGERS (DISABLED)
-- ════════════════════════════════════════════════════════════════════════════════════
-- 
-- NPC Passenger system has been disabled.
-- Functions are kept as empty stubs to prevent errors.
--
-- ════════════════════════════════════════════════════════════════════════════════════

-- Empty global table
spawnedPassengers = {}

-- ════════════════════════════════════════════════════════════════════════════════════
-- EMPTY FUNCTIONS (No-op)
-- ════════════════════════════════════════════════════════════════════════════════════

function SpawnPassengers(stop)
    -- NPC system disabled
    if Config.Debug then
        print('[HM BUS JOB] NPC Passengers disabled (Config.NPCPassengers.enabled = false)')
    end
end

function DespawnAllPassengers()
    -- NPC system disabled
    spawnedPassengers = {}
end

function DespawnPassengersAtStop(numToRemove)
    -- NPC system disabled
end

function GetRandomPointNearStop(coords)
    return coords
end
