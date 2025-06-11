local ESX = exports['es_extended']:getSharedObject()
local lastJob = nil
local isAmmoboxShown = false
local PlayerData = ESX.GetPlayerData()

CreateThread(function()
    Wait(3000)
    SendNUIMessage({
        action = 'initGUI',
        data = {
            whiteMode = Config.enableWhiteBackgroundMode,
            enableAmmo = Config.enableAmmoBox,
            colorInvert = Config.disableIconColorInvert
        }
    })
end)

RegisterNetEvent('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob', function(job)
    if PlayerData then
        PlayerData.job = job
    end
end)

RegisterNetEvent('poggu_hud:retrieveData', function(data)
    SendNUIMessage({
        action = 'setMoney',
        cash = data.cash,
        bank = data.bank,
        black_money = data.black_money,
        society = data.society
    })
end)

RegisterNetEvent('poggu_hud:showAlert', function(message, time, color)
    SendNUIMessage({
        action = 'showAlert',
        message = message,
        time = time,
        color = color
    })
end)

CreateThread(function()
    while true do
        Wait(5000)
        ESX.TriggerServerCallback('poggu_hud:retrieveData', function(data)
            SendNUIMessage({
                action = 'setMoney',
                cash = data.cash,
                bank = data.bank,
                black_money = data.black_money,
                society = data.society
            })
        end)
    end
end)

CreateThread(function()
    while true do
        Wait(9000)
        if PlayerData and PlayerData.job then
            local jobName = PlayerData.job.label .. ' - ' .. PlayerData.job.grade_label
            if lastJob ~= jobName then
                lastJob = jobName
                SendNUIMessage({
                    action = 'setJob',
                    data = jobName
                })
            end
        end
    end
end)

CreateThread(function()
    while true do
        Wait(200)
        if Config.enableAmmoBox then
            local playerPed = PlayerPedId()
            local weapon, hash = GetCurrentPedWeapon(playerPed, true)
            if weapon then
                isAmmoboxShown = true
                local _, ammoInClip = GetAmmoInClip(playerPed, hash)
                SendNUIMessage({
                    action = 'setAmmo',
                    data = ammoInClip .. '/' .. (GetAmmoInPedWeapon(playerPed, hash) - ammoInClip)
                })
            elseif isAmmoboxShown then
                isAmmoboxShown = false
                SendNUIMessage({
                    action = 'hideAmmobox'
                })
            end
        end
    end
end)

local isMenuPaused = false

local function menuPaused()
    SendNUIMessage({
        action = 'disableHud',
        data = isMenuPaused
    })
end

CreateThread(function()
    while true do
        Wait(1)
        if IsPauseMenuActive() then
            if not isMenuPaused then
                isMenuPaused = true
                menuPaused()
            end
        elseif isMenuPaused then
            isMenuPaused = false
            menuPaused()
        end

        if IsControlJustPressed(1, 311) then
            SendNUIMessage({
                action = 'showAdvanced'
            })
        end
    end
end)
