Config = {}

--location options
Config.Location = vector3(253.95,207.55,106.29)
Config.Distance = 8

--address options
Config.AddressLength = 16
Config.AddressCharacters = {
"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
"1","2","3","4","5","6","7","8","9"
}

--secret options
Config.SecretWordLength = 10
Config.RandomWords = {
  "fang",
  "heavenly",
  "theory",
  "accidental",
  "crate",
  "pear",
  "string",
  "past",
  "simplistic",
  "unadvised",
  "obnoxious",
  "multiply",
  "real",
  "puzzling",
  "stereotyped",
  "dirt",
  "invite",
  "pastoral",
  "faithful",
  "sweet",
  "kick",
  "late",
  "zesty",
  "infamous",
  "honey",
  "discovery",
  "important",
  "pinch",
  "rake",
  "bore",
  "icicle",
  "fair",
  "leg",
  "delirious",
  "hop",
  "middle",
  "fuel",
  "overwrought",
  "haunt",
  "quince",
  "smelly",
  "question",
  "agreeable",
  "labored",
  "shape",
  "hour",
  "orange",
  "healthy",
  "ethereal",
  "applaud",
  "peaceful",
  "fire",
  "willing",
  "oceanic",
  "airport",
  "knowing",
  "tick",
  "panicky",
  "strap",
  "vagabond",
  "old-fashioned",
  "good",
  "messy",
  "ludicrous",
  "camera",
  "hang",
  "rail",
  "step",
  "claim",
  "destroy",
  "rotten",
  "shoes",
  "creature",
  "possessive",
  "thing",
  "mug",
  "scandalous",
  "butter",
  "fretful",
  "cover",
  "ladybug",
  "glib",
  "science",
  "advertisement",
  "spoil",
  "stomach",
  "satisfy",
  "matter",
  "mindless",
  "warn",
  "ignore",
  "quill",
  "lethal",
  "soup",
  "lacking",
  "beginner",
  "imported",
  "surround",
  "arrogant",
  "yarn",
  "mourn",
  "sheep",
  "fresh",
  "abortive",
  "lunchroom",
  "bump",
  "carpenter",
  "functional",
  "station",
  "badge",
  "thundering",
  "animal",
  "history",
  "roof",
  "chubby",
  "rhyme",
  "defiant",
  "relation",
  "tender",
  "vase",
  "title",
  "pest",
  "skip",
  "awful",
  "gigantic",
  "whispering",
  "unsuitable",
  "wrong",
  "sniff",
  "fierce",
  "change",
  "volcano",
  "borrow",
  "dolls",
  "ill-informed",
  "abrupt",
  "blink",
  "itchy",
  "pencil",
  "ghost",
  "stain",
  "cuddly",
  "chop",
  "cold",
  "general",
  "chew",
  "sable",
  "measure",
  "zoo",
  "harm",
  "promise",
  "deranged",
  "unarmed",
  "race",
  "sweltering",
  "squeak",
  "statuesque",
  "remove",
  "furtive",
  "hug",
  "grab",
  "cagey",
  "pie",
  "discover",
  "wholesale",
  "vein",
  "airplane",
  "stove",
  "ambiguous",
  "bomb",
  "toothbrush",
  "industry",
  "alert",
  "muscle",
  "juice",
  "snobbish",
  "boorish",
  "gratis",
  "minister",
  "mouth",
  "futuristic",
  "cumbersome",
  "synonymous",
  "next",
  "massive",
  "wealth",
  "phobic",
  "reflect",
  "spiders",
  "books",
  "wrench",
  "helpless",
  "caption",
  "cub",
  "x-ray",
  "nose",
  "drag",
  "vulgar",
  "flavor",
  "boring"
}

--transaction options
--Do not touch this address
Config.BrokerWallet = "BrokerWallet"


Config.BtcPrice = nil

--Updatetimer in mili seconds. 
Config.UpdateTimer = 120000
Config.useEsxDrugs = true

--API settings
--you can add any other coin you want to use in the database. look at the documentation which coins are supported and what their id is
--when adding new coins, dont forget to also add them to the database file or database table directly
Config.Coins = {
  "bitcoin",
  "ethereum",
  "cardano"
}

--you can use your wanted currency look at the supported documentation
--https://api.coingecko.com/api/v3/simple/supported_vs_currencies
Config.Currency = "eur"

--Temp values DO NOT TOUCH
Config.TempAddress = ""