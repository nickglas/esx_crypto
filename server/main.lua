ESX = nil
local loadedWallet = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterCommand("fill", function(source,args)

  local amount = tonumber(args[1])
  local counter = 0

  while counter < amount do
    generateRandomWalletBatch()
    counter = counter + 1
  end

end)

function getWallet(address)
   local result = MySQL.Sync.fetchAll(
      "SELECT * FROM crypto_wallets WHERE `address` = @addr",
      {["addr"] = address}
    )
  return result[1]
end

function getWalletFromSource(source)
  local id = getIdentifier(source)
    result = MySQL.Sync.fetchAll(
      "SELECT * FROM crypto_wallets WHERE `userId` = @id",
      {["id"] = id}
    )
    return result[1]
end

RegisterServerEvent("getUserWallet")
AddEventHandler("getUserWallet", function(param)
    wallet = getWallet(source)
    return wallet
end)

ESX.RegisterServerCallback('esx_crypto:getPlayerWallet', function(source, cb )
    wallet = getWalletFromSource(source)
    print("got wallet: " .. wallet.address)
    cb(wallet)
end)


function deleteWallet(source,wallet)
  local result = MySQL.Sync.fetchAll("DELETE FROM crypto_wallets where `address` = @addr",
  {["addr"] = wallet.address }
  )

  local exists = walletExists(source,wallet.address)
  print(exists)
  if exist == true then
    TriggerClientEvent("output", source, "removing address failed")
  else
    TriggerClientEvent("output", source, "removed address succesfully")
  end
end

function walletExists(address)
  local result
  print("searching for address " .. address)
    result = MySQL.Sync.fetchAll(
      "SELECT * FROM crypto_wallets WHERE `address` = @addr",
      {["addr"] = address}
    )
  if (#result > 0) then -- check if rows length is more than zero
    return true
  else 
    return false
  end

end

function getIdentifier(source)
  local identifiers = GetPlayerIdentifier(source, steam)
  return identifiers
end

function printWalletDetails(source,wallet)
  TriggerClientEvent("output", source, 
  "wallet details for wallet:\n" 
  .. "address: " .. wallet.address .. "\n"
  .. "name: " .. wallet.name .. "\n"
  .. "amount of btc: " .. wallet.amountOfBtc .. "\n"
  )
end

function userHasAddress(source)
  local identifier = getIdentifier(source)

  local result = MySQL.Sync.fetchAll("SELECT * FROM crypto_wallets WHERE `userId` = @id",
  {["id"] = identifier})

  if #result > 0 then
    print("returning true")
    return true
  else
    print("returning false")
    return false
  end
end

function generateRandomAddress()

  --get all the wallets from the database
  local allWallets = getAllWalletAddresses()

  while true do
    local text = ""
    local size = getTableLenght(Config.AddressCharacters)
    local alreadyExists = false

      for i = 1, Config.AddressLength, 1 
      do
        local randomNumber = math.random(1,size) 
        text = text .. tostring(Config.AddressCharacters[randomNumber]) 
      end

      for i, v in ipairs(allWallets) do
        if v == text then
          alreadyExists = true
        end
      end

      if alreadyExists == false then
        return text
      end

  end
end

function getAllWalletAddresses()
  local result = MySQL.Sync.fetchAll("SELECT address from crypto_wallets")
  return result
end

function getWalletAddress(source)
  local identifier = getIdentifier(source)
  local result = MySQL.Sync.fetchAll("SELECT address from crypto_wallets WHERE `userId` = @src",
  {["src"] = identifier})

  if next(result) == nil then
    return nil
  else
    return result[1].address
  end
end

function getTableLenght(Table)
  local c = 0
  for _ in pairs(Table) do 
    c = c + 1 
  end
  return c
end

function updateCoins(configURL)
  
  print("[CRYPTO] updating crypto prices")

  PerformHttpRequest(configURL, function (errorCode, resultData, resultHeaders)
    --if error
    if errorCode ~= 200 then
      print("[CRYPTO] error fetching crypto data")
      return
    end

    local JsonData = json.decode(resultData)

    for i, v in ipairs(JsonData) do

      local coin = v
      local dbcoin = getCoin(coin)

      if dbcoin ~= nil then
        --update
        if dbcoin.price == coin.current_price then
          print("[CRYPTO] no update for coin " .. coin.id)
        else
          print("[CRYPTO] new update for " .. coin.id .. " new price is " .. coin.current_price .. " " .. Config.Currency)
          TriggerClientEvent("output", -1, "new update for " .. coin.id .. " new price is " .. coin.current_price .. " " .. Config.Currency)
          updateCoin(coin)
        end
      else
        --doesnt exists
        print("[CRYPTO] new coin found: " .. coin.id .. " with price " .. coin.current_price .. " " .. Config.Currency)
        insertCoin(coin)
      end
    end

  end)

end

RegisterCommand("qqq", function(source,args)
  local wallet = getWallet(args[1])
  print(wallet.address)
  for k, v in pairs(wallet) do
    print(k)
  end
end)



function calculateCoinAmount(price, coin)
  local priceInt = tonumber(price)
  local coinInt = tonumber(coin.price)
  local amountOfCoin = priceInt / coinInt
  return amountOfCoin
end

function calculateSellTotal(coin, amount)
  print("calculating sell total")
  local amountInt = tonumber(amount)
  local coinInt = tonumber(coin.price)
  local price = amountInt * coinInt
  return price
end

function getWalletCoinAmount(coin,wallet)
  local db_amount = 0
  for k, v in pairs(wallet) do
    local curr_field = k
    if curr_field == coin.symbol then
      db_amount = v
      break
    end
  end
  return db_amount
end

function addCoinsToWallet(wallet, coin, amount)

  local db_amount = getWalletCoinAmount(coin,wallet)

  print(db_amount)
  print(amount)

  local new_amount = db_amount + amount
  print(new_amount)

  local sqlString = "UPDATE crypto_wallets SET ".. coin.symbol .." = ".. new_amount .." WHERE `address` = '" .. wallet.address .. "'"
  print(sqlString)
  local result = MySQL.Sync.fetchAll(sqlString)
end

function removeCoinsFromWallet(wallet,coin, amount)
  local db_amount = getWalletCoinAmount(coin,wallet)

  local new_amount = db_amount - amount

  local sqlString = "UPDATE crypto_wallets SET ".. coin.symbol .." = ".. new_amount .." WHERE `address` = '" .. wallet.address .. "'"
  print(sqlString)
  local result = MySQL.Sync.fetchAll(sqlString)
end

function insertCoin(coin)
  local result = MySQL.Sync.fetchAll("INSERT INTO crypto_coins (id,symbol,price) VALUES(@i,@s,@p)",
  {["i"] = coin.id, ["s"] = coin.symbol, ["p"] = coin.current_price})
end

function updateCoin(coin)
  local result = MySQL.Sync.fetchAll("UPDATE crypto_coins SET `price` = @price WHERE `id` = @coinId",
  {["price"] = coin.current_price, ["coinId"] = coin.id})
end

function getCoin(coin)
  local result = MySQL.Sync.fetchAll("SELECT * FROM crypto_coins WHERE `id` = @coinId",
  {["coinId"] = coin.id})
  return result[1]
end

function getCoinFromId(id)
  local result = MySQL.Sync.fetchAll("SELECT * FROM crypto_coins WHERE `id` = @coinId",
  {["coinId"] = id})
  return result[1]
end

ESX.RegisterServerCallback('esx_crypto:getCoinDetails', function(source, cb)
  coins = getAllCoins()
  cb(coins)
end)

function getAllCoins()
  local result = MySQL.Sync.fetchAll("SELECT * FROM crypto_coins")
  return result
end

ESX.RegisterServerCallback('esx_crypto:getAllCoins', function(source, cb)
  coins = getAllCoins()
  cb(coins)
end)

function insertTransaction(fromWallet,toWallet,amount,type)
  local result = MySQL.Sync.fetchAll("INSERT INTO crypto_transactions(fromWallet,toWallet,amount,type) VALUES(@fWallet,@tWallet,@am,@typ)",
  {["fWallet"] = fromWallet, ["tWallet"] = toWallet, ["am"] = amount, ["typ"] = type})
end

ESX.RegisterServerCallback('esx_crypto:buyCoin',function(source,cb,coin,amount)          
  print("called")  
  local dbCoin = getCoin(coin)
  local xPlayer = ESX.GetPlayerFromId(source)
  local playerMoney = xPlayer.getAccount('bank').money
  local wallet = getWalletFromSource(source)

  if amount > playerMoney then
    cb("You dont have enough money to buy this coin")
    return
  end



  local coinAmount = calculateCoinAmount(amount, dbCoin)
  
  

  addCoinsToWallet(wallet,dbCoin,coinAmount)
  removeMoneyFromBank(xPlayer, amount)
  insertTransaction("BrokerWallet", wallet.address,amount,"BUY")

  cb("Succesfully added " .. coinAmount .. " to wallet " .. wallet.address)
end)

ESX.RegisterServerCallback('esx_crypto:sellCoin',function(source,cb,coin,amount)          
  
  local dbCoin = getCoin(coin)
  local xPlayer = ESX.GetPlayerFromId(source)
  local playerMoney = xPlayer.getAccount('bank').money
  local wallet = getWalletFromSource(source)
  local db_amount = getWalletCoinAmount(coin,wallet)

  print(dbCoin.id)
  print(playerMoney)
  print(wallet.address)
  print(db_amount)
  print(amount)

  if amount > db_amount then
    cb("You dont have " .. amount .. " " .. coin.id)
    return
  end
  
  local amountOfMoney = calculateSellTotal(dbCoin, amount)
  print(amountOfMoney)
  removeCoinsFromWallet(wallet,coin,amount)
  addMoneyToBank(xPlayer, amountOfMoney)
  insertTransaction(wallet.address,"BrokerWallet",amount,"SELL")


  cb("Succesfully sold " .. amount .. " " .. coin.symbol)
end)

ESX.RegisterServerCallback('esx_crypto:checkWalletExistence',function(source,cb)          
    local hasWallet = userHasAddress(source)
    print(hasWallet)
    cb(hasWallet)
end)

ESX.RegisterServerCallback('esx_crypto:getAccountSecrets', function(source,cb)
    local wallet = getWalletFromSource(source)
    cb(wallet.secret)
end)

ESX.RegisterServerCallback('esx_crypto:generateRandomWallet',function(source,cb, pin)          
  local hasWallet = userHasAddress(source)
  if hasWallet == true then
    cb("You already have a wallet... if this is a error contact the server admin!")
  end 

  local walletAddress = generateRandomAddress()
  local secret = generateWalletSecret()
  insertNewAddress(source, walletAddress, secret, pin)

  cb("Successfully generated new address: " .. walletAddress)
end)

function generateRandomWalletBatch()
 
  local walletAddress = generateRandomAddress()
  local secret = generateWalletSecret()
  local pin = "5838"
  local source = "b@tch"

  insertNewAddress(source,walletAddress, secret, pin)

end

RegisterCommand("transfer", function(source,args)
  local result = transferFunds(args[1],args[2],args[3])
  print(result)
end)

ESX.RegisterServerCallback('esx_crypto:getMyWallet', function(source,cb)
  local wallet = getWalletFromSource(source)
  cb(wallet)
end)

ESX.RegisterServerCallback('esx_crypto:transferFunds',function(source,cb, fromWallet, toWallet, coin, amount)
  local result = transferFunds(fromWallet,toWallet,coin,amount)
  cb(result)
end)

ESX.RegisterServerCallback('esx_crypto:checkAmount', function(source,cb,coin,amount)
  local wallet = getWalletFromSource(source)
  local result = CheckBalance(wallet,coin,amount)
  cb(result)
 end)

ESX.RegisterServerCallback('esx_crypto:checkWalletExists', function(source,cb,address)
  print("testing existence")
  local wallet = walletExists(address)
  if wallet == true then
    cb(true)
  else
    cb(false)
  end
 end)

function CheckBalance(wallet, coin, amount)
  local db_coin = getWalletCoinAmount(coin,wallet)
  
  if amount > db_coin then
    return false
  else
    return true
  end
  
end

ESX.RegisterServerCallback('esx_crypto:checkPin',function(source,cb, pin)          
  local wallet = getWalletFromSource(source)
  local result = checkPin(wallet,pin)
  cb(result)
end)

function transferFunds(fromWalletAddress, toWalletAddress, coin, amount)
  
  if fromWalletAddress == toWalletAddress then
    return "you can not transfer coins to you own account"
  end

  amount = tonumber(amount)
  local  Fwallet = getWallet(fromWalletAddress)

 
  local db_coin_amount = getWalletCoinAmount(coin,Fwallet)

  print(db_coin_amount)

  if amount > db_coin_amount then
    return "you dont have have " .. amount .. " of " .. coin.symbol .. " in your wallet"
  end

  local  Twallet = getWallet(toWalletAddress)
  insertTransaction(fromWalletAddress,toWalletAddress,amount,"TRANSFER")
  removeCoinsFromWallet(Fwallet, coin, amount)
  addCoinsToWallet(Twallet, coin, amount)

  return "successfully transfered " .. amount .. " of " .. coin.symbol .. " to wallet " .. toWalletAddress
end

function checkPin(wallet, pin)
  if wallet.pin == pin then 
    return true
  else
    return false
  end
end

function updateBtcPrice()
	SetTimeout(60000, function()
    updateBtc()
	end)
end

function insertNewAddress(source, walletAddress, secret, pin)
  local identifiers = getIdentifier(source)
  local secretText = secretWordsToString(secret)
  print(secretText)
  local result = MySQL.Async.fetchAll("INSERT INTO crypto_wallets (address,btc,pin,secret,userId) VALUES (@add, @btc,@p,@secret, @uId)",
  {["@add"] = walletAddress , ["@btc"] = 0 , ["@uId"] = identifiers , ["@p"] = pin, ["@secret"] = secretText})
end

function generateWalletSecret()
  local words = {}
    local size = getTableLenght(Config.RandomWords)

      for i = 1, Config.SecretWordLength, 1 
      do
        while true do
          local randomNumber = math.random(1,size) 
          local word = Config.RandomWords[randomNumber]

          local wordsExist = false
          for i, v in ipairs(words) do
            if v == word then
              alreadyExists = true
            end
          end

          if wordsExist == false then
            table.insert(words, word)
            break
          end

        end
      end
  return words
end

function secretWordsToString(words)
  local text = ""
  for i, v in ipairs(words) do
    text = text .. " " .. v
  end
  return text
end

function buildApiQuery(coins,currency)
  local url = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=".. currency .."&ids="
  for i, v in ipairs(coins) do
    url = url .. v .. "%2C"
  end       
  url = url .. "&order=market_cap_desc&sparkline=false" 
  print(url)
  return url   
end

Citizen.CreateThread(function()
  local config = buildApiQuery(Config.Coins,Config.Currency)
  while true do
    updateCoins(config)
    Citizen.Wait(Config.UpdateTimer)
  end
end)

function removeMoneyFromBank(player, amount)
  player.removeAccountMoney('bank', amount)
end

function addMoneyToBank(player, amount)
  player.addAccountMoney('bank', amount)
end