RegisterServerEvent('delta-delgun:toggleDelGun')
AddEventHandler('delta-delgun:toggleDelGun', function()
    local src = source
    local permissionGranted = IsPlayerAceAllowed(src, Config.Permission)
    TriggerClientEvent('delta-delgun:toggleDelGunR', src, permissionGranted)
end)

local function animetteyep(text, delay)
    for _, line in ipairs(text) do
        print(line)
        Citizen.Wait(delay)
    end
end

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() == resourceName) then
        Citizen.Wait(2000)

        local asciiArt = {
            "\x1b[34m _/_/_/    _/_/_/_/  _/    _/_/_/_/_/    _/_/ \x1b[0m",
            "\x1b[36m _/    _/  _/        _/        _/      _/    _/ \x1b[0m",
            "\x1b[34m _/    _/  _/_/_/    _/        _/      _/_/_/_/ \x1b[0m",
            "\x1b[36m _/    _/  _/        _/        _/      _/    _/ \x1b[0m",
            "\x1b[34m _/_/_/    _/_/_/_/  _/_/_/_/  _/      _/    _/ \x1b[0m"
        }

        print("\n")

        animetteyep(asciiArt, 300)

        local white = "\x1b[37m"
        local green = "\x1b[32m"
        local yellow = "\x1b[33m"

        print(white .. "\nDelta Delete Gun created by Delta Studios ©")
        print(green .. "Join our Discord: https://discord.gg/AxNsZJ99KM")
        print(yellow .. "#----------------------------------------------------------#")
        print(green .. "#   Script successfully loaded. Type /delgun to toggle.    #")
        print(yellow .. "#----------------------------------------------------------#")

        print("\x1b[0m") 
    end
end)
