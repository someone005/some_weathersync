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

        Citizen.Wait(3000)
    end
end)

RegisterNetEvent('some_weathersync:UpdateWeather')
AddEventHandler('some_weathersync:UpdateWeather', function(weather)
    setWeather = weather
end)
