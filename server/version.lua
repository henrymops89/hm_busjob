-- ════════════════════════════════════════════════════════════════════════════════════
-- HM BUS JOB - VERSION CHECK
-- ════════════════════════════════════════════════════════════════════════════════════

local CURRENT_VERSION = '1.0.0'
local RESOURCE_NAME = GetCurrentResourceName()

CreateThread(function()
    -- Version check on startup
    PerformHttpRequest('https://api.github.com/repos/mopsscripts/hm_busjob/releases/latest', function(errorCode, resultData, resultHeaders)
        if errorCode ~= 200 then
            if Config.Debug then
                print(('[%s] ^3Unable to check for updates^0'):format(RESOURCE_NAME))
            end
            return
        end
        
        local data = json.decode(resultData)
        if not data or not data.tag_name then
            return
        end
        
        local latestVersion = data.tag_name:gsub('v', '')
        
        if latestVersion ~= CURRENT_VERSION then
            print('^3════════════════════════════════════════════════════════════════^0')
            print(('^3[%s] Update available!^0'):format(RESOURCE_NAME))
            print(('^3Current version: ^1%s^0'):format(CURRENT_VERSION))
            print(('^3Latest version: ^2%s^0'):format(latestVersion))
            print(('^3Download: ^5%s^0'):format(data.html_url))
            print('^3════════════════════════════════════════════════════════════════^0')
        else
            print(('^2[%s] You are running the latest version (%s)^0'):format(RESOURCE_NAME, CURRENT_VERSION))
        end
    end, 'GET')
end)
