local QBCore = exports['qb-core']:GetCoreObject()

local allowTowingBoats = false -- Set to true if you want to be able to tow boats.
local allowTowingPlanes = false -- Set to true if you want to be able to tow planes.
local allowTowingHelicopters = false -- Set to true if you want to be able to tow helicopters.
local allowTowingTrains = false -- Set to true if you want to be able to tow trains.
local allowTowingTrailers = true -- Disables trailers. NOTE: THIS ALSO DISABLES THE AIRTUG, TOWTRUCK, SADLER, AND ANY OTHER VEHICLE THAT IS IN THE UTILITY CLASS.

local currentlyTowedVehicle = nil

RegisterCommand("tow", function()
    TriggerEvent("tow")
end, false)

function isTargetVehicleATrailer(modelHash)
    return GetVehicleClassFromName(modelHash) == 11
end

local xoff = 0.0
local yoff = 0.0
local zoff = 0.0

function isVehicleATowTruck(vehicle)
    local isValid = false
    for model, posOffset in pairs(allowedTowModels) do
        if IsVehicleModel(vehicle, model) then
            xoff = posOffset.x
            yoff = posOffset.y
            zoff = posOffset.z
            isValid = true
            break
        end
    end
    return isValid
end

RegisterNetEvent('tow')
AddEventHandler('tow', function()
    local playerped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerped, true)
    local isVehicleTow = isVehicleATowTruck(vehicle)

    if isVehicleTow then
        local coordA = GetEntityCoords(playerped, 1)
        local coordB = GetOffsetFromEntityInWorldCoords(playerped, 0.0, 5.0, 0.0)
        local targetVehicle = getVehicleInDirection(coordA, coordB)

        Citizen.CreateThread(function()
            while true do
                Citizen.Wait(0)
                isVehicleTow = isVehicleATowTruck(vehicle)
                local roll = GetEntityRoll(GetVehiclePedIsIn(PlayerPedId(), true))
                if IsEntityUpsidedown(GetVehiclePedIsIn(PlayerPedId(), true)) and isVehicleTow or roll > 70.0 or roll < -70.0 then
                    DetachEntity(currentlyTowedVehicle, false, false)
                    currentlyTowedVehicle = nil
                    lib.notify({
                        title = 'BSRP FreeRoam - Tow',
                        description = 'Tow Service: Looks like the cables holding on the vehicle have broken!',
                        type = 'error',
                        position = 'center-left'
                    })
                end
            end
        end)

        if currentlyTowedVehicle == nil then
            if targetVehicle ~= 0 then
                local targetVehicleLocation = GetEntityCoords(targetVehicle, true)
                local towTruckVehicleLocation = GetEntityCoords(vehicle, true)
                local distanceBetweenVehicles = GetDistanceBetweenCoords(targetVehicleLocation, towTruckVehicleLocation, false)

                if distanceBetweenVehicles > 12.0 then
                    lib.notify({
                        title = 'BSRP FreeRoam - Tow',
                        description = 'Tow Service: Your cables can\'t reach this far. Move your tow truck closer to the vehicle.',
                        type = 'inform',
                        position = 'center-left'
                    })
                else
                    local targetModelHash = GetEntityModel(targetVehicle)
                    if not ((not allowTowingBoats and IsThisModelABoat(targetModelHash)) or
                            (not allowTowingHelicopters and IsThisModelAHeli(targetModelHash)) or
                            (not allowTowingPlanes and IsThisModelAPlane(targetModelHash)) or
                            (not allowTowingTrains and IsThisModelATrain(targetModelHash)) or
                            (not allowTowingTrailers and isTargetVehicleATrailer(targetModelHash))) then
                        if not IsPedInAnyVehicle(playerped, true) then
                            if vehicle ~= targetVehicle and IsVehicleStopped(vehicle) then
                                QBCore.Functions.Progressbar("towing_vehicle", "Loading vehicle onto flatbed...", 5000, false, true, {
                                    disableMovement = true,
                                    disableCarMovement = true,
                                    disableMouse = false,
                                    disableCombat = true,
                                }, {}, {}, {}, function() -- Done
                                    AttachEntityToEntity(targetVehicle, vehicle, GetEntityBoneIndexByName(vehicle, 'bodyshell'), 0.0 + xoff, -1.5 + yoff, 0.0 + zoff, 0, 0, 0, 1, 1, 0, 1, 0, 1)
                                    currentlyTowedVehicle = targetVehicle
                                    lib.notify({
                                        title = 'BSRP FreeRoam - Tow',
                                        description = 'Tow Service: Vehicle has been loaded onto the flatbed.',
                                        type = 'success',
                                        position = 'center-left'
                                    })
                                end, function() -- Cancel
                                    lib.notify({
                                        title = 'BSRP FreeRoam - Tow',
                                        description = 'Tow Service: Loading canceled.',
                                        type = 'error',
                                        position = 'center-left'
                                    })
                                end)
                            else
                                lib.notify({
                                    title = 'BSRP FreeRoam - Tow',
                                    description = 'Tow Service: There is currently no vehicle on the flatbed.',
                                    type = 'inform',
                                    position = 'center-left'
                                })
                            end
                        else
                            lib.notify({
                                title = 'BSRP FreeRoam - Tow',
                                description = 'Tow Service: You need to be outside of your vehicle to load or unload vehicles.',
                                type = 'inform',
                                position = 'center-left'
                            })
                        end
                    else
                        lib.notify({
                            title = 'BSRP FreeRoam - Tow',
                            description = 'Tow Service: Your tow truck is not equipped to tow this vehicle.',
                            type = 'inform',
                            position = 'center-left'
                        })
                    end
                end
            else
                lib.notify({
                    title = 'BSRP FreeRoam - Tow',
                    description = 'Tow Service: No towable vehicle detected.',
                    type = 'inform',
                    position = 'center-left'
                })
            end
        elseif IsVehicleStopped(vehicle) then
            QBCore.Functions.Progressbar("unloading_vehicle", "Unloading vehicle from flatbed...", 5000, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {}, {}, {}, function() -- Done
                DetachEntity(currentlyTowedVehicle, false, false)
                local vehiclesCoords = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, -12.0, 0.0)
                SetEntityCoords(currentlyTowedVehicle, vehiclesCoords["x"], vehiclesCoords["y"], vehiclesCoords["z"], 1, 0, 0, 1)
                SetVehicleOnGroundProperly(currentlyTowedVehicle)
                currentlyTowedVehicle = nil
                lib.notify({
                    title = 'BSRP FreeRoam - Tow',
                    description = 'Tow Service: Vehicle has been unloaded from the flatbed.',
                    type = 'inform',
                    position = 'center-left'
                })
            end, function() -- Cancel
                lib.notify({
                    title = 'BSRP FreeRoam - Tow',
                    description = 'Tow Service: Unloading canceled.',
                    type = 'error',
                    position = 'center-left'
                })
            end)
        end
    else
        lib.notify({
            title = 'BSRP FreeRoam - Tow',
            description = 'Tow Service: Your vehicle is not registered as an official tow truck.',
            type = 'inform',
            position = 'center-left'
        })
    end
end)

function getVehicleInDirection(coordFrom, coordTo)
    local rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10, PlayerPedId(), 0)
    local a, b, c, d, vehicle = GetRaycastResult(rayHandle)
    return vehicle
end
