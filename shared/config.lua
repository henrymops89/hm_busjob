Config = {}

-- ════════════════════════════════════════════════════════════════════════════════════
-- FRAMEWORK & SYSTEM SETTINGS
-- ════════════════════════════════════════════════════════════════════════════════════

Config.Framework = 'auto' -- 'auto', 'qbox', 'qbcore', 'esx'
Config.Inventory = 'ox_inventory' -- 'ox_inventory', 'qb-inventory', 'tgiann-inventory'
Config.Target = 'ox_target' -- 'ox_target', 'qb-target'
Config.Locale = 'de' -- 'de', 'en'
Config.Debug = true

-- ════════════════════════════════════════════════════════════════════════════════════
-- UI THEME COLORS
-- ════════════════════════════════════════════════════════════════════════════════════

Config.Theme = {
    primary = '#E8841A',      -- Orange (Bus Theme)
    accent = '#F0A030',       -- Light Orange
    error = '#FF5252',        -- Red
    success = '#69F0AE',      -- Green
    locked = '#E53935',       -- Dark Red
    salary = '#4CAF50'        -- Green
}

-- ════════════════════════════════════════════════════════════════════════════════════
-- JOB SETTINGS
-- ════════════════════════════════════════════════════════════════════════════════════

Config.JobMenuCommand = 'busjob' -- Command to open job menu
Config.JobMenuKey = 'F6' -- Key to open job menu (optional, can be nil)

Config.JobLocation = vector3(453.5, -602.4, 28.6) -- Bus depot location (Downtown LS)
Config.JobBlip = {
    enabled = true, -- ❌ DISABLED
    sprite = 513, -- Bus icon
    color = 47, -- Orange
    scale = 0.8,
    label = 'Bus Depot'
}

-- ════════════════════════════════════════════════════════════════════════════════════
-- BUS VEHICLES (Level-based)
-- ════════════════════════════════════════════════════════════════════════════════════

Config.BusModels = {
    [1] = 'tourbus',  -- Level 1: Tour Bus
    [5] = 'bus',      -- Level 5: Standard Bus
    [10] = 'coach'    -- Level 10: Luxury Coach
}

Config.BusSpawnLocation = vector4(469.9604, -592.8698, 28.4996, 160.5249) -- Spawn location for bus

-- ════════════════════════════════════════════════════════════════════════════════════
-- PROGRESSION SYSTEM
-- ════════════════════════════════════════════════════════════════════════════════════

Config.LevelSystem = {
    enabled = true,  -- ✅ ENABLED
    maxLevel = 20,
    xpPerLevel = 500, -- XP needed per level (increases by 10% each level)
    xpMultiplier = 1.1 -- XP requirement multiplier per level
}

-- XP Rewards
Config.XPRewards = {
    stopCompleted = 10,    -- XP per bus stop completed
    routeCompleted = 50,   -- XP per route completed
    passengerBonus = 5,    -- XP per passenger transported
    perfectRoute = 100     -- Bonus XP for completing route without fines
}

-- ════════════════════════════════════════════════════════════════════════════════════
-- ROUTES CONFIGURATION
-- ════════════════════════════════════════════════════════════════════════════════════

Config.Routes = {
    -- Route 1: Beach Route (Starter Route)
    {
        id = 1,
        name = 'Beach Route',
        description = 'Scenic coastal route along Vespucci Beach',
        salary = 500,
        ticketPrice = 15,
        estimatedTime = '12:00',
        requiredLevel = 1,
        requiredRoutesCompleted = 0,
        unlockMessage = 'Available from start',
        stops = {
            {coords = vector3(453.5, -602.4, 28.6), heading = 268.0, label = 'Bus Depot'},
            {coords = vector3(-265.7, -957.5, 31.2), heading = 208.0, label = 'Maze Bank Arena'},
            {coords = vector3(-1183.3, -1497.5, 4.4), heading = 125.0, label = 'Vespucci Beach'},
            {coords = vector3(-1336.8, -1146.9, 6.7), heading = 0.0, label = 'Del Perro Pier'},
            {coords = vector3(-1494.8, -670.5, 29.0), heading = 320.0, label = 'Del Perro Heights'},
            {coords = vector3(-1082.3, -266.6, 37.8), heading = 28.0, label = 'Rockford Hills'},
            {coords = vector3(-724.8, -904.5, 19.2), heading = 90.0, label = 'Little Seoul'},
            {coords = vector3(-256.8, -715.8, 33.5), heading = 160.0, label = 'Pillbox Hill'},
            {coords = vector3(265.3, -380.5, 44.8), heading = 340.0, label = 'Alta Street'},
            {coords = vector3(453.5, -602.4, 28.6), heading = 268.0, label = 'Bus Depot (Return)'}
        }
    },

    -- Route 2: City Route (Requires 5 completed routes)
    {
        id = 2,
        name = 'City Center Route',
        description = 'Downtown business district route',
        salary = 750,
        ticketPrice = 20,
        estimatedTime = '15:00',
        requiredLevel = 3,
        requiredRoutesCompleted = 5,
        unlockMessage = 'Complete 5 routes to unlock',
        stops = {
            {coords = vector3(453.5, -602.4, 28.6), heading = 268.0, label = 'Bus Depot'},
            {coords = vector3(265.3, -380.5, 44.8), heading = 340.0, label = 'Alta Street'},
            {coords = vector3(127.5, -1035.5, 29.3), heading = 160.0, label = 'Legion Square'},
            {coords = vector3(240.8, -1378.8, 33.7), heading = 230.0, label = 'Strawberry'},
            {coords = vector3(-48.8, -1445.8, 32.4), heading = 180.0, label = 'Davis'},
            {coords = vector3(-216.8, -1318.8, 30.9), heading = 270.0, label = 'Grove Street'},
            {coords = vector3(-517.8, -1223.8, 18.4), heading = 340.0, label = 'La Puerta'},
            {coords = vector3(-724.8, -904.5, 19.2), heading = 90.0, label = 'Little Seoul'},
            {coords = vector3(-256.8, -715.8, 33.5), heading = 160.0, label = 'Pillbox Hill'},
            {coords = vector3(127.5, -1035.5, 29.3), heading = 160.0, label = 'Legion Square'},
            {coords = vector3(265.3, -380.5, 44.8), heading = 340.0, label = 'Alta Street'},
            {coords = vector3(453.5, -602.4, 28.6), heading = 268.0, label = 'Bus Depot (Return)'}
        }
    }
}

-- ════════════════════════════════════════════════════════════════════════════════════
-- NPC PASSENGERS
-- ════════════════════════════════════════════════════════════════════════════════════

Config.NPCPassengers = {
    enabled = false, -- ❌ DISABLED
    minPassengers = 2,
    maxPassengers = 5,
    spawnDistance = 2.0, -- Distance from stop to spawn NPCs
    enterAnimDict = 'anim@move_m@trash',
    enterAnimName = 'pickup',
    sitAnimDict = 'anim@heists@prison_heiststation@cop_reactions',
    sitAnimName = 'cop_b_idle',
    despawnDelay = 3000 -- ms to wait before despawning NPCs after stop
}

-- ════════════════════════════════════════════════════════════════════════════════════
-- CAMERA ANIMATIONS
-- ════════════════════════════════════════════════════════════════════════════════════

Config.CameraAnimations = {
    enabled = false, -- ❌ DISABLED
    duration = 3000, -- Duration in ms
    fov = 50.0,
    offsetX = 5.0,
    offsetY = 5.0,
    offsetZ = 2.0
}

-- ════════════════════════════════════════════════════════════════════════════════════
-- FINES & PENALTIES
-- ════════════════════════════════════════════════════════════════════════════════════

Config.Fines = {
    speeding = {
        enabled = false, -- ❌ DISABLED
        speedLimit = 80.0, -- km/h (will be converted from mph)
        fineAmount = 50,
        cooldown = 10000 -- ms between fines
    },
    crashing = {
        enabled = false, -- ❌ DISABLED
        minDamage = 100.0, -- Minimum damage to trigger fine
        fineAmount = 100,
        cooldown = 5000 -- ms between fines
    }
}

-- ════════════════════════════════════════════════════════════════════════════════════
-- MARKERS & BLIPS
-- ════════════════════════════════════════════════════════════════════════════════════

Config.Markers = {
    busStop = {
        type = 1, -- Cylinder
        size = {x = 3.0, y = 3.0, z = 1.0},
        color = {r = 232, g = 132, b = 26, a = 100},
        bobUpAndDown = false,
        faceCamera = false,
        rotate = false
    },
    depot = {
        type = 1,
        size = {x = 2.0, y = 2.0, z = 1.0},
        color = {r = 232, g = 132, b = 26, a = 150},
        bobUpAndDown = true,
        faceCamera = false,
        rotate = false
    }
}

Config.Blips = {
        depot = {
        sprite = 513,
        color = 5,
        scale = 0.8,
        name = "Bus Depot"
    },
    busStop = {
        sprite = 513,
        color = 47,
        scale = 0.6,
        route = true,
        routeColor = 47
    }
}

-- ════════════════════════════════════════════════════════════════════════════════════
-- NOTIFICATIONS
-- ════════════════════════════════════════════════════════════════════════════════════

Config.Notifications = {
    useBuiltIn = false, -- Use built-in UI notifications
    useOxLib = true,    -- Use ox_lib notifications
    duration = 5000     -- Duration in ms
}

-- ════════════════════════════════════════════════════════════════════════════════════
-- NPC PED CONFIGURATION
-- ════════════════════════════════════════════════════════════════════════════════════

Config.DepotPed = {
    enabled = false, -- ❌ DISABLED
    model = 'cs_bankman', -- NPC model (cs_bankman, ig_floyd, s_m_m_dockwork_01, etc.)
    coords = vector3(453.5, -602.4, 28.6),
    heading = 90.0,
    animation = {
        dict = 'amb@world_human_clipboard@male@idle_a',
        name = 'idle_c'
    }
}
