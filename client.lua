local setHour, setMinute, setWeather = 12, 00, nil
local beginSync = false

Citizen.CreateThread(function()
    while true do

        if not beginSync then
            TriggerServerEvent('some_weathersync:beginUpdate')
            beginSync = true
        end

        ClearOverrideWeather()
        ClearWeatherTypePersist()
        SetWeatherTypePersist(setWeather)
        SetWeatherTypeNow(setWeather)
        SetWeatherTypeNowPersist(setWeather)

        NetworkOverrideClockTime(setHour, setMinute, 0)

        Citizen.Wait(3000)
    end
end)

RegisterNetEvent('some_weathersync:UpdateTime')
AddEventHandler('some_weathersync:UpdateTime', function(hour, minute)
    setHour = hour
    setMinute = minute
end)

RegisterNetEvent('some_weathersync:UpdateWeather')
AddEventHandler('some_weathersync:UpdateWeather', function(weather)
    setWeather = weather
end)