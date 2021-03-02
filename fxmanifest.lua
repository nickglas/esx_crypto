fx_version 'bodacious'

game 'gta5'

description 'ESX Crypto'

server_scripts {
	'config.lua',
	'server/main.lua',
	'@mysql-async/lib/MySQL.lua'
}

client_scripts {
	'config.lua',
	'client/main.lua'
}
