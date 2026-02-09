fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'MopsScripts <henry.mops89@gmail.com>'
description 'HM Bus Job - Professional Bus Driver Job System'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua',
    'shared/locale.lua',
    'locales/*.lua'
}

client_scripts {
    'bridge/framework.lua',
    'bridge/inventory.lua',
    'bridge/utils.lua',
    'client/main.lua',
    'client/vehicle.lua',
    'client/route.lua',
    'client/passengers.lua',
    'client/ped.lua',
    'client/debug.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'bridge/framework.lua',
    'bridge/inventory.lua',
    'bridge/utils.lua',
    'server/main.lua',
    'server/version.lua',
    'server/leaderboard.lua',
    'server/logging.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}
