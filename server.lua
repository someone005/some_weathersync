local syncing = true

Citizen.CreateThread(function()
    while true do

        if syncing then
            local hour, minute = os.date("%H"), os.date("%M")

            for i=1, #Config.Updates, 1 do
                local time = Config.Updates[i]
                if tonumber(hour) == tonumber(string.sub(time, 1, 2)) then
                    if tonumber(minute) == tonumber(string.sub(time, 4, 5)) then
                        Update()
                    end
                end
            end
        end
        Citizen.Wait(1000)
    end
end)

function Update()
    local link = 'http://api.weatherapi.com/v1/current.json?key=' .. Config.APIkey .. '&q=' .. Config.City .. '&aqi=no'
    PerformHttpRequest(link, function(err, result, headers)
        if checkErrorCode(err) then
            local r = '[ ' .. result .. ' ]'
            local rt = json.decode(r)
            local hour = tonumber(string.sub(rt[1].location.localtime, 12, 13))
            TriggerClientEvent('some_weathersync:UpdateTime', -1, hour, string.sub(rt[1].location.localtime, 15, 16))
            for i=1, #Config.Weathers, 1 do
                if Config.Weathers[i].code == rt[1].current.condition.code then
                    if hour >= Config.NightStart or hour <= Config.NightEnd then
                        TriggerClientEvent('some_weathersync:UpdateWeather', -1, Config.Weathers[i].night)
                    else
                        TriggerClientEvent('some_weathersync:UpdateWeather', -1, Config.Weathers[i].day)
                    end
                end
            end
        end
    end)
end

function checkErrorCode(err)
    if err == 1002 or err == 2006 then
        print('Your api key is wrong! Please fix it')
        return false
    elseif err == 1003 or err == 1006 then
        print('City name is wrong! Please fix it')
        return false
    elseif err == 1005 then
        print('Something went wrong. Please contact someone#0005. Error: 1005')
        print('Something went wrong. Please contact someone#0005. Error: 1005')
        return false
    elseif err == 2007 then
        print('Your api key has exceeded calls per month quota')
        return false
    elseif err == 2008 then
        print('Your api key has been disabled!')
        return false
    elseif err == 9999 then
        print('Something went wrong. Please contact someone#0005. Error: 9999')
        print('Something went wrong. Please contact someone#0005. Error: 9999')
        return false
    else
        return true
    end
end

RegisterCommand('syncWeather', function(source, args, raw)
    if checkPermissions(source) then
        Update()
        print('weather synced')
    end
end)

RegisterCommand('stopWeatherSync', function(source, args, raw)
    if checkPermissions(source) then
        syncing = false
        print('syncing stopped')
    end
end)

RegisterCommand('resumeWeatherSync', function(source, args, raw)
    if checkPermissions(source) then
        syncing = true
        Update()
        print('syncing resumed')
    end
end)

RegisterCommand('setSyncingCity', function(source, args, raw)
    if checkPermissions(source) then
        if args[1] then
            local cityName = ''
            if #args == 1 then
                cityName = args[1]
            else
                for i=1, #args-1, 1 do
                    cityName = cityName .. args[i] .. '_'
                end
                cityName = cityName .. args[#args]
            end
            Config.City = cityName
            Update()
            print('New city is - ' .. Config.City)
        else
            print('City name is incorrect. Skipped')
        end
    end
end)

function checkPermissions(src)
    return IsPlayerAceAllowed(src, "weatherSyncSettings")
end

RegisterServerEvent('some_weathersync:beginUpdate')
AddEventHandler('some_weathersync:beginUpdate', function(source)
    Update()
end)
