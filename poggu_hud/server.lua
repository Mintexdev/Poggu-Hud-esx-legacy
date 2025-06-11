local ESX = exports['es_extended']:getSharedObject()

function getAccounts(data, xPlayer)
    local result = {}
    for i = 1, #data do
        local accountType = data[i]
        if accountType ~= 'money' then
            if accountType == 'black_money' and not Config.showBlackMoney then
                result[i] = nil
            else
                result[i] = xPlayer.getAccount(accountType).money
            end
        else
            result[i] = xPlayer.getMoney()
        end
    end
    return result
end

function tableIncludes(table, data)
    for _, v in pairs(table) do
        if v == data then
            return true
        end
    end
    return false
end

local allowedGrades = {
    'boss',
    'underboss'
}

RegisterNetEvent('poggu_hud:retrieveData', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then return end

    local money, bank, black_money = table.unpack(getAccounts({'money', 'bank', 'black_money'}, xPlayer))

    if tableIncludes(allowedGrades, xPlayer.job.grade_name) then
        TriggerEvent('esx_society:getSociety', xPlayer.job.name, function(data)
            if data then
                TriggerEvent('esx_addonaccount:getSharedAccount', data.account, function(account)
                    local society = account.money
                    TriggerClientEvent('poggu_hud:retrieveData', src, {
                        cash = money,
                        bank = bank,
                        black_money = black_money,
                        society = society
                    })
                end)
            else
                TriggerClientEvent('poggu_hud:retrieveData', src, {
                    cash = money,
                    bank = bank,
                    black_money = black_money,
                    society = nil
                })
            end
        end)
    else
        TriggerClientEvent('poggu_hud:retrieveData', src, {
            cash = money,
            bank = bank,
            black_money = black_money,
            society = nil
        })
    end
end)

ESX.RegisterServerCallback('poggu_hud:retrieveData', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then return cb({}) end

    local money, bank, black_money = table.unpack(getAccounts({'money', 'bank', 'black_money'}, xPlayer))

    if tableIncludes(allowedGrades, xPlayer.job.grade_name) then
        TriggerEvent('esx_society:getSociety', xPlayer.job.name, function(data)
            if data then
                TriggerEvent('esx_addonaccount:getSharedAccount', data.account, function(account)
                    cb({
                        cash = money,
                        bank = bank,
                        black_money = black_money,
                        society = account.money
                    })
                end)
            else
                cb({
                    cash = money,
                    bank = bank,
                    black_money = black_money,
                    society = nil
                })
            end
        end)
    else
        cb({
            cash = money,
            bank = bank,
            black_money = black_money,
            society = nil
        })
    end
end)
