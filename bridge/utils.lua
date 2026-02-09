-- ════════════════════════════════════════════════════════════════════════════════════
-- UTILS BRIDGE - Notifications, Progress, Input, etc.
-- ════════════════════════════════════════════════════════════════════════════════════

Utils = {}

-- ════════════════════════════════════════════════════════════════════════════════════
-- NOTIFICATION FUNCTIONS
-- ════════════════════════════════════════════════════════════════════════════════════

--- Send notification to player
--- @param source number|nil Player server ID (nil for client-side)
--- @param title string Notification title
--- @param description string Notification description
--- @param type string Notification type ('info', 'success', 'error', 'warning')
--- @param duration number|nil Duration in ms
function Utils.Notify(source, title, description, type, duration)
    type = type or 'info'
    duration = duration or Config.Notifications.duration
    
    if IsDuplicityVersion() == 1 then
        -- Server-side
        if Config.Notifications.useOxLib then
            TriggerClientEvent('ox_lib:notify', source, {
                title = title,
                description = description,
                type = type,
                duration = duration
            })
        elseif Config.Notifications.useBuiltIn then
            TriggerClientEvent('hm_busjob:client:notify', source, {
                title = title,
                description = description,
                type = type,
                duration = duration
            })
        end
    else
        -- Client-side
        if Config.Notifications.useOxLib then
            lib.notify({
                title = title,
                description = description,
                type = type,
                duration = duration
            })
        elseif Config.Notifications.useBuiltIn then
            SendNUIMessage({
                action = 'showNotification',
                data = {
                    title = title,
                    description = description,
                    type = type,
                    duration = duration
                }
            })
        end
    end
end

-- ════════════════════════════════════════════════════════════════════════════════════
-- PROGRESS BAR (Client-Side Only)
-- ════════════════════════════════════════════════════════════════════════════════════

if IsDuplicityVersion() ~= 1 then
    
    --- Show progress bar
    --- @param label string Progress label
    --- @param duration number Duration in ms
    --- @param options table|nil Progress options
    --- @return boolean Success
    function Utils.Progress(label, duration, options)
        options = options or {}
        
        if lib.progressBar then
            return lib.progressBar({
                duration = duration,
                label = label,
                useWhileDead = options.useWhileDead or false,
                canCancel = options.canCancel or false,
                disable = options.disable or {
                    move = true,
                    car = true,
                    combat = true
                },
                anim = options.anim,
                prop = options.prop
            })
        end
        
        return true
    end
    
    --- Show progress circle
    --- @param duration number Duration in ms
    --- @param options table|nil Progress options
    --- @return boolean Success
    function Utils.ProgressCircle(duration, options)
        options = options or {}
        
        if lib.progressCircle then
            return lib.progressCircle({
                duration = duration,
                position = options.position or 'bottom',
                useWhileDead = options.useWhileDead or false,
                canCancel = options.canCancel or false,
                disable = options.disable or {
                    move = true,
                    car = true,
                    combat = true
                },
                anim = options.anim,
                prop = options.prop
            })
        end
        
        return true
    end
    
end

-- ════════════════════════════════════════════════════════════════════════════════════
-- TARGET SYSTEM (Client-Side Only)
-- ════════════════════════════════════════════════════════════════════════════════════

if IsDuplicityVersion() ~= 1 then
    
    --- Add target zone
    --- @param name string Zone name
    --- @param coords vector3 Zone coordinates
    --- @param options table Target options
    function Utils.AddTargetZone(name, coords, options)
        if Config.Target == 'ox_target' then
            exports.ox_target:addSphereZone({
                coords = coords,
                radius = options.radius or 2.0,
                options = options.options,
                debug = Config.Debug
            })
        elseif Config.Target == 'qb-target' then
            exports['qb-target']:AddBoxZone(name, coords, options.size or 2.0, options.size or 2.0, {
                name = name,
                heading = options.heading or 0.0,
                debugPoly = Config.Debug,
                minZ = coords.z - 1.0,
                maxZ = coords.z + 1.0
            }, {
                options = options.options,
                distance = options.distance or 2.5
            })
        end
    end
    
    --- Remove target zone
    --- @param name string Zone name
    function Utils.RemoveTargetZone(name)
        if Config.Target == 'ox_target' then
            exports.ox_target:removeZone(name)
        elseif Config.Target == 'qb-target' then
            exports['qb-target']:RemoveZone(name)
        end
    end
    
end
