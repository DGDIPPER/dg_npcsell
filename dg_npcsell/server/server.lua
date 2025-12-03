RegisterNetEvent('dg_npcsell:SellItem', function(item, amount)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end

    item = tostring(item)
    amount = tonumber(amount)

    if not Config.SellItems[item] then return end

    local price = Config.SellItems[item]
    local count = exports.ox_inventory:Search(src, 'count', item)

    if count < amount then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Not Enough Items',
            description = "You do not have enough of that item.",
            type = 'error'
        })
        return
    end

    -- Remove items
    exports.ox_inventory:RemoveItem(src, item, amount)

    -- Pay the player
    local payment = amount * price
    player.Functions.AddMoney('cash', payment, 'sold-items')

    TriggerClientEvent('ox_lib:notify', src, {
        title = "Sale Complete",
        description = ("You earned $%s"):format(payment),
        type = 'success'
    })
end)
