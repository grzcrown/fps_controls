weapon = {}
weapon.name = nil
weapon.muzzleobj = nil
weapon.object = nil
weapon.arms = nil
weapon.magazine = nil
weapon.position = Vector3(0, 0, 0)
weapon.rotation = Vector3(0, 0, 0)
weapon.positionplus = Vector3(0, 0, 0)
weapon.rotationplus = Vector3(0, 0, 0)
weapon.zPlus = 0
weapon.rPlus = 0
weapon.acc = Vector3(0, 0, 0)
weapon.fov = 70
weapon.accurrary = 0
weapon.accurrary_anim = 0
weapon.range = 0
weapon.smooth = 0
weapon.aimspeed = 0
weapon.firerate = 0
weapon.type = 0
weapon.sound = 0
weapon.speed = 0
weapon.bullet = 0
weapon.muzzlePosition = Vector3(0, 0, 0)
weapon.attachments = {}

weapon._posOffset = Vector3(-0.22, 0.077, 0.04)
weapon._rotOffset = Vector3(-15, 169, 2)

function awake()
	toggleControl("fire", false)
	toggleControl("previous_weapon", false)
	toggleControl("next_weapon", false)
	_disableWeapon()
	_setElementDatas()
end
addEventHandler("onClientResourceStart", resourceRoot, awake)

function _setElementDatas()
	setElementData(localPlayer, "weapon:aim", false)
	setElementData(localPlayer, "aim:target", {0, 0, 0})
end

function _disableWeapon()
	local _m = dxCreateTexture("assets/images/a.png")
	local _s = dxCreateShader("assets/shader/tex.fx", 0, 0, false, "all")
	dxSetShaderValue(_s, "Tex0", _m)
	engineApplyShaderToWorldTexture(_s, "ak47")
end

function setClientWeapon(name)
	clear()
	if not (name == "none") then
	local _w = weapons[name]
		weapon.name = name
		weapon.object = createObject(_w.model, 0, 0, 0)
		weapon.camera = createObject(3930, 0, 0, 0)
		weapon.muzzleobj = createObject(3930, 0, 0, 5)
		weapon.arms = createPed(285, 0, 0, 10)
		weapon.position = _w.position
		weapon.rotation = _w.rotation
		weapon.fov = _w.idle.fov
		weapon.acc = Vector3(0, 0, 0)
		weapon.positionplus = Vector3(0, 0, 0)
		weapon.rotationplus = Vector3(0, 0, 0)
		weapon.zPlus = 0
		weapon.accurrary = _w.idle.accurrary
		weapon.accurrary_anim = _w.idle.accurrary_anim
		weapon.range = _w.idle.range
		weapon.smooth = _w.smooth
		weapon.aimspeed = _w.aimspeed
		weapon.firerate = _w.firerate
		weapon.type = _w.type
		weapon.switchable = _w.switchable
		weapon.sound = _w.sound
		weapon.magazine = _w.magazine
		weapon.speed = _w.speed
		weapon.muzzlePosition = _w.muzzleposition
		weapon.attachments = {}
		
		--attachElements(weapon.object, weapon.camera, 0.002, -0.3, 0.05, 180, 90, 270)
		exports["bones"]:attachElementToBone(
			weapon.object,
			weapon.arms,
			12, 
			weapon._posOffset.x, 
			weapon._posOffset.y, 
			weapon._posOffset.z, 
			weapon._rotOffset.x,
			weapon._rotOffset.y,
			weapon._rotOffset.z
		)
		attachElements(weapon.arms, weapon.camera, -0.13, -0.3, -0.5, 0, 0, 0)
		
		setElementCollisionsEnabled(weapon.object, false)
		setElementCollisionsEnabled(weapon.camera, false)
		setElementCollisionsEnabled(weapon.arms, false)
		setElementCollisionsEnabled(weapon.muzzleobj, false)
		setElementCollisionsEnabled(localPlayer, true)
		
		setElementCollidableWith(weapon.arms, localPlayer, false) 
		
		setElementAlpha(weapon.muzzleobj, 0)
		-- setObjectScale(weapon.muzzleobj, 0.1)
		setElementAlpha(weapon.camera, 0)
		
		setElementDoubleSided(weapon.object, false)
		setElementDoubleSided(weapon.arms, false)
		
		attachElements(weapon.muzzleobj, weapon.object, weapon.muzzlePosition)
		
		enableControls(true)
		addEventHandler("onClientRender", getRootElement(), renderWeapon)
		triggerServerEvent("onWeaponGive", resourceRoot, localPlayer, true, getElementModel(weapon.object))
		setElementDoubleSided(weapon.object, true)
		setTimer(function()
		setPedAnimation(weapon.arms, "firstperson", "idle", -1, true, false, true, false, 750)
		end, 200, 1)
	end
end

function addMagazine()
	weapon.bullet = magazines[weapon.name].maxbullet
	if not (isElement(weapon.magazine)) then
		if not (magazines[weapon.name].model == 0) then
			weapon.magazine = createObject(magazines[weapon.name].model, magazines[weapon.name].position)
			setElementCollisionsEnabled(weapon.magazine, false)
			exports["bones"]:attachElementToBone(
				weapon.magazine,
				weapon.arms,
				12, 
				weapon._posOffset.x + magazines[weapon.name].position.x, 
				weapon._posOffset.y + magazines[weapon.name].position.y, 
				weapon._posOffset.z + magazines[weapon.name].position.z, 
				weapon._rotOffset.x + magazines[weapon.name].rotation.x,
				weapon._rotOffset.y + magazines[weapon.name].rotation.y,
				weapon._rotOffset.z + magazines[weapon.name].rotation.z
			)
		end
	end
end

function addAttachment(name)
	if not (weapon.object) then return end
	weapon.attachments[#weapon.attachments + 1] = {
		model = attachments[name].model,
		type = attachments[name].type,
		position = attachments[name].position,
		object = createObject(attachments[name].model, 0, 0, 0)
	}
	setElementCollisionsEnabled(weapon.attachments[#weapon.attachments].object, false)
	attachElements(weapon.attachments[#weapon.attachments].object, weapon.arms, weapon.attachments[#weapon.attachments].position, 0, 0, 0)
	triggerServerEvent("onAttachmentGive", resourceRoot, true, localPlayer, attachments[name].model, attachments[name].position.x, attachments[name].position.y, attachments[name].position.z, #weapon.attachments)
	return #weapon.attachments
end

function removeAttachment(id)
	destroyElement(weapon.attachments[id].object)
	triggerServerEvent("onAttachmentRemove", resourceRoot, localPlayer, id)
	table.remove(weapon.attachments, id)
end

function clear()
	if isElement(weapon.object) then
		destroyElement(weapon.object)
	end
	if isElement(weapon.arms) then
		destroyElement(weapon.arms)
	end
	if isElement(weapon.muzzleobj) then
		destroyElement(weapon.muzzleobj)
	end
	if isElement(weapon.magazine) then
		destroyElement(weapon.magazine)
	end
	if isElement(weapon.camera) then
		destroyElement(weapon.camera)
	end
	for id, v in pairs(weapon.attachments) do
		removeAttachment(id)
	end
	weapon.name = nil
	weapon.muzzleobj = nil
	weapon.object = nil
	weapon.arms = nil
	weapon.magazine = nil
	weapon.camera = nil
	weapon.position = Vector3(0, 0, 0)
	weapon.rotation = Vector3(0, 0, 0)
	weapon.zPlus = 0
	weapon.rPlus = 0
	weapon.positionplus = Vector3(0, 0, 0)
	weapon.rotationplus = Vector3(0, 0, 0)
	weapon.fov = 70
	weapon.acc = Vector3(0, 0, 0)
	weapon.accurrary = 0
	weapon.accurrary_anim = 0
	weapon.range = 0
	weapon.smooth = 0
	weapon.aimspeed = 0
	weapon.firerate = 0
	weapon.type = 0
	weapon.switchable = 0
	weapon.sound = 0
	weapon.magazine = 0
	weapon.bullet = 0
	weapon.speed = 0
	weapon.attachments = {}
	weapon.muzzlePosition = Vector3(0, 0, 0)
	removeEventHandler("onClientRender", getRootElement(), renderWeapon)
	enableControls(false)
	triggerServerEvent("onWeaponGive", resourceRoot, localPlayer, false)
end

function renderWeapon()
	if (weapon.object) then
		if controls.aim == false then
			_bonePos = Vector3(getPedBonePosition(localPlayer, 4))
			_bonePos.z = _bonePos.z - 0.03
		else
			_bonePos = Vector3(getPedBonePosition(localPlayer, 3))
			_bonePos.z = _bonePos.z + 0.245 + weapon.zPlus
		end
		local _cameraRot = Vector3(getElementRotation(getCamera()))
		local _cameraPos = Vector3(getElementPosition(getCamera()))
		local _cameraMat = Matrix(_cameraPos, _cameraRot)

		_bonePos.x = _bonePos.x+weapon.position.x*math.cos(math.rad(_cameraRot.z))
		_bonePos.y = _bonePos.y+weapon.position.x*math.sin(math.rad(_cameraRot.z))
		_bonePos.z = _bonePos.z + weapon.position.z
		local _currentRotation = camera.smoothvector
		local _targetRotation = camera.vector
		local _direction = _targetRotation - _currentRotation
		local _, _, _camRot = getElementRotation(getCamera())
		_direction:cross(_targetRotation)
		_rpos = _currentRotation + _direction * deltaTime * weapon.smooth
		local _r = Vector3(findRotation3D(_bonePos.x, _bonePos.y, _bonePos.z, _rpos.x, _rpos.y, _rpos.z))
		local _currentPos = Vector3(getElementPosition(weapon.arms))
		local _newPos = _bonePos + weapon.acc + weapon.positionplus + (_cameraMat.up*(-0.05)) + (_cameraMat.forward*(0.12))
		local _newRot = Vector3(
			 _r.x + weapon.acc.y + weapon.rotationplus.y, 
			0,
			_r.z + weapon.rPlus + weapon.acc.x + weapon.rotationplus.z
			)
		setElementPosition(weapon.camera, _newPos)
		setElementRotation(weapon.camera, _newRot)
		setElementRotation(weapon.arms, _newRot)
		setElementRotation(weapon.object, _newRot)
		camera.smoothvector = _rpos
	end
end


addCommandHandler("delattachment", function(cmd, id)
	if (isPedInVehicle(localPlayer)) then return end
	removeAttachment(tonumber(id))
end)

addCommandHandler("addmagazine", function(cmd, bullet)
	if (isPedInVehicle(localPlayer)) then return end
	addMagazine(tonumber(bullet))
end)

addEventHandler("onClientPlayerWasted", root, function()
	if (source == localPlayer) then
		setClientWeapon("none")
		killTimer(controls.shootTimer)
	end
end)

setTimer(function()
	setClientWeapon("gewerth")
	addMagazine()
end, 100, 1)