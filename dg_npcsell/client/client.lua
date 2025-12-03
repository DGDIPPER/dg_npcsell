lib.locale()

local function openSellAmountMenu(item, price)
    local input = lib.inputDialog(("Sell %s"):format(item), {
        { type = 'number', label = "Amount to Sell", min = 1, required = true }
    })

    if not input then return end
    local amount = tonumber(input[1])

    TriggerServerEvent('dg_npcsell:SellItem', item, amount)
end

local function openSellMenu()
    local options = {}

    for item, price in pairs(Config.SellItems) do
        options[#options + 1] = {
            title = item,
            description = ("$%s each"):format(price),
            image = ("nui://ox_inventory/web/images/%s.png"):format(item), -- OX INVENTORY IMAGE
            onSelect = function()
                openSellAmountMenu(item, price)
            end
        }
    end

    lib.registerContext({
        id = 'dg_sellnpc_main',
        title = 'Sell Items',
        options = options
    })

    lib.showContext('dg_sellnpc_main')
end

CreateThread(function()
    RequestModel(Config.PedModel)
    while not HasModelLoaded(Config.PedModel) do Wait(10) end

    local ped = CreatePed(
        0,
        Config.PedModel,
        Config.PedCoords.x,
        Config.PedCoords.y,
        Config.PedCoords.z - 1.0,
        Config.PedCoords.w,
        false,
        true
    )

    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    -- OX TARGET SUPPORT
    if Config.UseOxTarget and GetResourceState("ox_target") == "started" then
        exports.ox_target:addLocalEntity(ped, {
            {
                name = "dg_sell_menu",
                icon = "fa-solid fa-dollar-sign",
                label = "Sell Items",
                onSelect = openSellMenu
            }
        })
    else
        -- Fallback E interaction
        local pos = vector3(Config.PedCoords.x, Config.PedCoords.y, Config.PedCoords.z)

        CreateThread(function()
            while true do
                local sleep = 1000
                local playerPos = GetEntityCoords(PlayerPedId())

                if #(playerPos - pos) < 2.0 then
                    sleep = 0
                    DrawText3D(pos.x, pos.y, pos.z + 1.0, "[E] Sell Items")

                    if IsControlJustReleased(0, 38) then
                        openSellMenu()
                    end
                end

                Wait(sleep)
            end
        end)
    end
end)

function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextColour(255, 255, 255, 215)
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end
