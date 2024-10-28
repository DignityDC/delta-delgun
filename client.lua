local deleteGunEnabled = false
local currentEntity = nil

RegisterCommand(Config.Command, function()
    if deleteGunEnabled or IsPedArmed(PlayerPedId(), 4) then
        TriggerServerEvent('delta-delgun:toggleDelGun')
    else
        lib.notify({ title = 'Error', description = 'You must have a weapon equipped to enable the delete gun!', type = 'error' })
    end
end, false)

RegisterNetEvent('delta-delgun:toggleDelGunR', function(permissionGranted)
    if not permissionGranted then
        lib.notify({ title = 'Error', description = 'You do not have permission to use this command!', type = 'error' })
        return
    end

    deleteGunEnabled = not deleteGunEnabled
    lib.notify({ title = 'Delete Gun', description = deleteGunEnabled and 'Enabled' or 'Disabled', type = deleteGunEnabled and 'success' or 'info' })

    if deleteGunEnabled and not IsPedArmed(PlayerPedId(), 4) then
        DisableDeleteGun("Weapon is no longer equipped")
    end
end)

CreateThread(function()
    while true do
        Wait(Config.CheckInterval)

        if deleteGunEnabled then
            local playerPed = PlayerPedId()
            if not IsPedArmed(playerPed, 4) then
                DisableDeleteGun("Weapon is no longer equipped")
            elseif IsPedInAnyVehicle(playerPed, false) then
                DisableDeleteGun("Player entered a vehicle")
            elseif IsPlayerFreeAiming(PlayerId()) then
                local entity = GetMainEntity(PlayerId())
                if entity then
                    local entityType = GetEntityType(entity)
                    HighlightEntity(entity, entityType)
                    DrawLaserPointer(entity)

                    if Config.AimToDelete or IsControlJustPressed(1, 24) then
                        local entityModel = GetEntityModel(entity)
                        local displayName = nil
                        if entityType == "vehicle" then
                            displayName = GetDisplayNameFromVehicleModel(entityModel) or "Unknown Vehicle"
                        elseif entityType == "ped" then
                            displayName = "Ped " .. tostring(entityModel)
                        elseif entityType == "object" then
                            displayName = tostring(entityModel)
                        else
                            displayName = "Unknown Entity"
                        end

                        if DeleteEntity(entity, entityType) then
                            lib.notify({
                                title = 'Delete Gun',
                                description = 'Entity deleted: ' .. displayName,
                                type = 'success'
                            })
                        end
                    end
                else
                    RemoveHighlight()
                end
            else
                RemoveHighlight()
            end
        end
    end
end)


function DisableDeleteGun(reason)
    deleteGunEnabled = false
    RemoveHighlight()
    lib.notify({ title = 'Delete Gun', description = 'Disabled: ' .. reason, type = 'info' })
end

function GetMainEntity(player)
    local entity = nil
    local hit, aimedEntity = GetEntityPlayerIsFreeAimingAt(player)
    
    if hit and DoesEntityExist(aimedEntity) then
        if IsEntityAVehicle(aimedEntity) then
            entity = aimedEntity
        else
            local parentVehicle = GetVehiclePedIsIn(aimedEntity, false)
            if DoesEntityExist(parentVehicle) then
                entity = parentVehicle
            else
                entity = aimedEntity
            end
        end
    end

    if entity and DoesEntityExist(entity) and not IsPedAPlayer(entity) then
        return entity
    end

    return nil
end

function GetEntityType(entity)
    if IsEntityAPed(entity) then
        return "ped"
    elseif IsEntityAVehicle(entity) then
        return "vehicle"
    elseif IsEntityAnObject(entity) then
        return "object"
    else
        return "unknown"
    end
end

function HighlightEntity(entity, entityType)
    if currentEntity ~= entity then
        if currentEntity then
            if GetEntityType(currentEntity) ~= "ped" then
                SetEntityDrawOutline(currentEntity, false)
            end
        end
        currentEntity = entity
        if entityType ~= "ped" then
            SetEntityDrawOutline(entity, true)
            SetEntityDrawOutlineColor(Config.EntityOutlineColor.r, Config.EntityOutlineColor.g, Config.EntityOutlineColor.b, Config.EntityOutlineColor.a)
        end
    end
end

function RemoveHighlight()
    if currentEntity then
        if GetEntityType(currentEntity) ~= "ped" then
            SetEntityDrawOutline(currentEntity, false)
        end
        currentEntity = nil
    end
end

function DeleteEntity(entity, entityType)
    if DoesEntityExist(entity) then
        SetEntityAsMissionEntity(entity, true, true)

        if entityType == "ped" and not IsPedAPlayer(entity) then
            DeletePed(entity)
            return not DoesEntityExist(entity)
        elseif entityType == "vehicle" then
            DeleteVehicle(entity)
            return not DoesEntityExist(entity)
        elseif entityType == "object" then
            DeleteObject(entity)
            return not DoesEntityExist(entity)
        else
            DeleteEntity(entity)
            return not DoesEntityExist(entity)
        end
    end
    return false
end

function DrawLaserPointer(entity)
    if entity then
        local playerPed = PlayerPedId()
        local weaponHash = GetSelectedPedWeapon(playerPed)

        if weaponHash ~= nil and weaponHash ~= GetHashKey('WEAPON_UNARMED') then
            local weaponBone = GetPedBoneIndex(playerPed, 0x6F06)
            local weaponPos = GetWorldPositionOfEntityBone(playerPed, weaponBone)
            local entityCoords = GetEntityCoords(entity)
            DrawLine(weaponPos.x, weaponPos.y, weaponPos.z, entityCoords.x, entityCoords.y, entityCoords.z, Config.EntityOutlineColor.r, Config.EntityOutlineColor.g, Config.EntityOutlineColor.b, Config.EntityOutlineColor.a)
        end
    end
end
