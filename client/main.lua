ESX              = nil
local PlayerData = {}
local isNear = false	
local ped = PlayerPedId()
local menuOpen = false
local Player_Data
local xPlayer = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer   
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)

Citizen.CreateThread(function()
	local location = Config.Location
	while true do
		Citizen.Wait(1)
		if isNear then
			local player = PlayerPedId()
			local coords = GetEntityCoords(player)
			Draw3DText(location.x,location.y,location.z,"Press ~y~[E]~w~ to access crypto account",0.4)

			--checking for keypress and player within a meter
			if Vdist(GetEntityCoords(ped), Config.Location) < 1 and IsControlJustReleased(1,38) and menuOpen == false then
				openMainCryptoMenu()
			end

			if menuOpen == true then
				if Vdist(GetEntityCoords(ped), Config.Location) > 1 then
					menuOpen = false
					closeAllMenus()
				end
			end

		end
	end
end)

Citizen.CreateThread(function()
	local ped = PlayerPedId()
	while true do
		local coords = GetEntityCoords(ped)
		Citizen.Wait(100)
		if Vdist(coords, Config.Location) < Config.Distance then
			isNear = true;
		else
			isNear = false;
		end
	end
end)




function Draw3DText(x,y,z,text,scale)
	local onScreen, _x, _y = World3dToScreen2d(x,y,z)
	local pX,pY,pZ = table.unpack(GetGameplayCamCoords())
	SetTextScale(scale,scale)
	SetTextFont(4)
	SetTextProportional(1)
	SetTextEntry("STRING")
	SetTextCentre(true)
	SetTextColour(255,255,255,215)
	AddTextComponentString(text)
	DrawText(_x,_y)
	local factor = (string.len(text)) / 700
	
end


RegisterNetEvent("output")
AddEventHandler("output", function (args)
  TriggerEvent("chatMessage", "[CRYPTO]", {0,255,0}, args)
end)


function openMainCryptoMenu()
	menuOpen = true
	ESX.TriggerServerCallback('esx_crypto:checkWalletExistence', function(result)
		
		local menuElements = {}

		--if wallet does exits
		if result == true then
			table.insert(menuElements, {label = ('Open Wallet'), value = 'open_wallet'})
		else
			table.insert(menuElements, {label = ('Generate new wallet'), value = 'generate_wallet'})
		end
			table.insert(menuElements, {label = ('Check bitcoin price'), value = 'check_btc'})



		ESX.UI.Menu.Open( 'default', GetCurrentResourceName(), 'crypto_main', -- Replace the menu name
		{
			title    = ('Crypto options'),
			align = 'center', -- Menu position
			elements = menuElements
		},
		function(data, menu) -- This part contains the code that executes when you press enter
			if data.current.value == 'open_wallet' then
					openCryptoWalletMenu()
			end
 
			if data.current.value == 'check_btc' then
				openCryptoCoinMenu()
			end  
			if data.current.value == 'generate_wallet' then
				openCryptoPasswordMenu()
			end     
		end,
		function(data, menu) -- This part contains the code  that executes when the return key is pressed.
				closeAllMenus() -- Close the menu
		end)
	end)
end

function openCryptoPasswordMenu()
	ESX.ShowHelpNotification('pin must be between 4 and 6 numbers')
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'CreatePassword',
  {
    title = ('Please enter a pincode for your account')
  },

  function(data, menu)

		data.value = data.value:gsub("%s+", "")
		pinLength = string.len (data.value)

    local amount = tonumber(data.value)
    if amount == nil or amount <= 0 then
      ESX.ShowNotification('Invalid amount')
    else

		if pinLength < 4 then
			ESX.ShowNotification('pincode length is to short')
			return
		end
		
		if pinLength > 6 then
			ESX.ShowNotification('pincode length is to long')
			return
		end

		ESX.TriggerServerCallback('esx_crypto:generateRandomWallet', function(result)
			ESX.ShowNotification(result)
			menu.close()
			openCryptoWalletSecretMenu()
		end, data.value)

    end
  end,
  function(data, menu)
    menu.close()
  end)
end

function openCryptoWalletMenu()
	ESX.TriggerServerCallback('esx_crypto:getPlayerWallet', function(wallet)
		print("We have wallet "  .. wallet.address)
				ESX.UI.Menu.Open( 'default', GetCurrentResourceName(), 'crypto_wallet_details', -- Replace the menu name
				{
					title    = ('Crypto wallet of ' .. GetPlayerName(PlayerId()) ),
					align = 'center', -- Menu position
					elements = { -- Contains menu elements
						{label = ('address: ' .. wallet.address) , value = 'none'},
						{label = ('btc: ' .. wallet.btc), value = 'none'},
						{label = ('eth: ' .. wallet.eth), value = 'none'},
						{label = ('ada: ' .. wallet.ada), value = 'none'},

						{label = ('Actions'), value = 'actions'},

					}
				},
				function(data, menu) -- This part contains the code that executes when you press enter
					if data.current.value == 'actions' then
						openCryptoCoinActions()
					end   
				end,
				function(data, menu) -- This part contains the code  that executes when the return key is pressed.
						closeMenu('crypto_wallet_details')
				end
			)
	end)
end

function openCryptoWalletSecretMenu()
	print("trying to open the menu")
	ESX.TriggerServerCallback('esx_crypto:getAccountSecrets', function(secrets)
		menuElements = {}
	
		table.insert(menuElements, {label = '<span style="color:green;">'..(secrets)..'</span>', value = 'none'})
		table.insert(menuElements, {label = '<span style="color:red;">'..('CLOSE(i understand that i dont get to see these words again)') ..'</span>', value = 'done'})

		ESX.UI.Menu.Open( 'default', GetCurrentResourceName(), 'cryptoSecrets', -- Replace the menu name
			{
				title    = ('Copy the recovery phrase(you see these words only one time)'),
				align = 'center', -- Menu position
				elements = menuElements
			},
			function(data, menu) -- This part contains the code that executes when you press enter
				if data.current.value == 'done' then
					print("close button pressed")
					closeAllMenus()
				end   
			end
		)
	end)
end

function openCryptoCoinMenu()
	ESX.TriggerServerCallback('esx_crypto:getCoinDetails', function(coins)

				local menuElements = {}

				for i, v in ipairs(coins) do
					table.insert(menuElements, {label = (v.id .. " price: " .. DetermineSymbol() .. v.price) , value = 'none'})
				end

				ESX.UI.Menu.Open( 'default', GetCurrentResourceName(), 'crypto_coin_btc_details', -- Replace the menu name
				{
					title    = ('Coin prices'),
					align = 'center', -- Menu position
					elements = menuElements
				},
				function(data, menu) -- This part contains the code that executes when you press enter
					if data.current.value == 'test' then
						-- Here the action when field 1 is selected
					end   
				end,
				function(data, menu) -- This part contains the code  that executes when the return key is pressed.
						closeMenu('crypto_coin_btc_details')
				end
			)
	end)
end




function openCryptoCoinActions()
	ESX.TriggerServerCallback('esx_crypto:getAllCoins', function(coins)
		local elements = {
			head = { ('Coin'), ('Price'), ('Action') },
			rows = {}
		}
		
		for i, v in ipairs(coins) do
			table.insert(elements.rows, {
				data = v,
				cols = {
					v.id,
					v.price,
					'{{' .. ('Buy') .. '|buy_coin}} {{' .. ('Sell') .. '|sell_coin}} {{' .. ('Transfer') .. '|transfer_coins}}'
				}
			})
    end
	
		ESX.UI.Menu.Open('list', GetCurrentResourceName(), 'asdvdrfgtdfg', elements, function(data, menu)
			if data.value == 'buy_coin' then
				menu.close()
				openCryptoCoinBuyCoinAction(data.data)
			elseif data.value == 'sell_coin' then
				menu.close()
				openCryptoSellBuyCoinAction(data.data)
			elseif data.value == 'sell_all_coins' then
				ESX.ShowHelpNotification('not implemented yet', true, 500)
			elseif data.value == 'transfer_coins' then 
				menu.close()
				openCryptoTransferAction(data.data)
			end
		end, function(data, menu)
			menu.close()
		end)
	end)
end

function openCryptoTransferAction(coin)
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'transferAmount',
  {
    title = ('How much ' .. coin.symbol .. ' do you want to transfer?')
  },
  function(data, menu)

    local amount = tonumber(data.value)
    if amount == nil or amount <= 0 then
      ESX.ShowNotification('Invalid amount')
    else

		ESX.TriggerServerCallback('esx_crypto:checkAmount', function(result)
			if result == true then
				openCryptoTransferWalletAction(coin,amount)
			else
				ESX.ShowHelpNotification('you dont have ' .. amount .. ' of ' .. coin.symbol)
			end
		end , coin, amount)
		
    end
  end,
  function(data, menu)
		menu.close()
  end)
end

function openCryptoTransferWalletAction(coin, amount)
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'transferAmountAddress',
  {
    title = ('What is the receivers address?')
  },
  function(data, menu)
		local address = data.value
    if address == nil then
      ESX.ShowNotification('Invalid address')
    else

		ESX.TriggerServerCallback('esx_crypto:checkWalletExists', function(result)

			if result == true then

				ESX.TriggerServerCallback('esx_crypto:getMyWallet' , function(wallet)
					ESX.TriggerServerCallback('esx_crypto:transferFunds' , function(transferResult)
						ESX.ShowNotification(transferResult)
						restartMainMenu()
					end, wallet.address, address, coin, amount)
				end)

			else
				ESX.ShowHelpNotification('This is not a valid address')
			end
		end , address)

    end
  end,
  function(data, menu)
		menu.close()
  end)
end

function openCryptoCoinBuyCoinAction(coin)
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'buyCoinAction',
  {
    title = ('How much money do you want to convert to ' .. coin.id)
  },
  function(data, menu)

    local amount = tonumber(data.value)
    if amount == nil or amount <= 0 then
      ESX.ShowNotification('Invalid amount')
    else

		ESX.TriggerServerCallback('esx_crypto:buyCoin', function(result)
			ESX.ShowNotification(result)
			restartMainMenu()
		end , coin, amount)

    end
  end,
  function(data, menu)
		menu.close()
  end)
end


function openCryptoSellBuyCoinAction(coin)
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'sellCoinAction',
  {
    title = ('How much ' .. coin.id .. ' do you want to sell')
  },
		function(data, menu)
			local amount = tonumber(data.value)
			print(amount)
			if amount == nil or amount <= 0 then
				print("invalid amount")
				ESX.ShowNotification('Invalid amount')
			else

				ESX.TriggerServerCallback('esx_crypto:sellCoin', function(result)
					print("test")
					ESX.ShowNotification("test")
					ESX.ShowNotification(result)
				end , coin, amount)

			end
		end,
  function(data, menu)
    menu.close()
  end)
end

function openCheckPinMenu()
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'sellCoinAction',
  {
    title = ('Please enter your pin code')
  },
		function(data, menu)

			if data.value == nil then
				ESX.ShowNotification('Invalid amount')
				return
			end

			local input_length = getStringLength(data.value)
			if input_length < 4 then
				ESX.ShowNotification('pin is to short')
				return
			end
			
			if input_length > 6 then
				ESX.ShowNotification('pin is to large')
				return
			end

			ESX.TriggerServerCallback('esx_crypto:checkPin', function(result)
				return result
			end , data.value)

		end,
  function(data, menu)
    menu.close()
  end)
end

function generateRandomWallet()
	ESX.TriggerServerCallback('esx_crypto:generateRandomWallet', function(result)
		ESX.ShowNotification(result)
	end)
end

function closeMenu(name)
	menuOpen = false
	ESX.UI.Menu.Close('default', 'esx_crypto', name)
end

function closeAllMenus()
	menuOpen = false
	ESX.UI.Menu.CloseAll()
end

function restartMainMenu()
	closeAllMenus()
	openMainCryptoMenu()
end

function DetermineSymbol()
  local s = Config.Currency
  if s == "eur" then
		print("euro")
    return "€"
  end
  if s == "usd" then
		print("usd")
    return "$"
  end
end

function getStringLength(value)
	value = value:gsub("%s+", "")
	length = string.len (value)
	return tonumber(length)
end