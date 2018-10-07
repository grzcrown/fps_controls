controls = {}
controls.aim = false
controls.canaim = false
controls.sprint = false
controls.move = false
controls.fire = false
controls.cansprint = false
controls.shootTimer = nil
controls.holes = {}

screen = Vector2(guiGetScreenSize())
muzzleflash = dxCreateTexture("assets/images/flash.png")
hole = dxCreateTexture("assets/images/hole.png")

function renderControls()
	local _states = getKeyState("w") or getKeyState("a") or getKeyState("s") or getKeyState("d")
	if _states == false then
		local _, _, _rot = getElementRotation(getCamera())
		setElementRotation(localPlayer, 0, 0, _rot, "default", true)
	elseif controls.aim == true or controls.fire == true then
		local _, _, _rot = getElementRotation(getCamera())
		setElementRotation(localPlayer, 0, 0, _rot, "default", true)
		setElementData(localPlayer, "aim:target", {camera.smoothvector.x, camera.smoothvector.y, camera.smoothvector.z})
	end
end

function setRenderControlsEnabled(state)
	if state == true then
		addEventHandler("onClientPreRender", root, renderControls)
	else
		removeEventHandler("onClientPreRender", root, renderControls)
	end
end

addEventHandler("onClientRender", root, 
function()
	for _, v in pairs(controls.holes) do
		dxDrawMaterialLine3D(v[1].x, v[1].y, v[1].z + 0.05, v[1].x, v[1].y, v[1].z - 0.05, hole, 0.1, tocolor(255, 255, 255, 255), v[2])
	end
	if #controls.holes > 200 then
		table.remove(controls.holes, 1)
	end
end)

function switch()
	if weapon.switchable == false then return end
	if weapon.type == "auto" then
		weapon.type = "semi"
	elseif weapon.type == "semi" then
		weapon.type = "auto"
	end
end

function aim(_, s)
	if controls.sprint == true then return end
	if s == "down" then
		if controls.aim == false then
			controls.aim = true
			controls.canaim = true
			animate(weapon.position.x, weapons[weapon.name].aim.position.x, 4, weapon.aimspeed, function(v)
				if controls.canaim == true then
					weapon.position.x = v
				end
			end)
			animate(weapon.zPlus, weapons[weapon.name].aim.position.y, 4, weapon.aimspeed, function(v)
				if controls.canaim == true then
					weapon.zPlus = v
				end
			end)
			animate(weapon.fov, weapons[weapon.name].aim.fov, 4, weapon.aimspeed, function(v)
				if controls.canaim == true then
					weapon.fov = v
				end
			end)
		end
		setElementData(localPlayer, "weapon:aim", true)
	else
		if controls.aim == true then
			controls.canaim = false
			animate(weapon.position.x, 0, 4, weapon.aimspeed, function(v)
				if controls.canaim == false then
					weapon.position.x = v
				end
			end)
			animate(weapon.fov, 70, 4, weapon.aimspeed, function(v)
				if controls.canaim == false then
					weapon.fov = v
				end
			end)
			animate(weapon.zPlus, 0, 4, weapon.aimspeed, function(v)
				if controls.canaim == false then
					weapon.zPlus = v
				end
			end, function()
				controls.aim = false
				setElementData(localPlayer, "weapon:aim", false)
			end)
			unbindKey("mouse2", "both", aim)
			setTimer(function()
				bindKey("mouse2", "both", aim)
			end, weapon.aimspeed, 1)
		end
	end
end

function sprint(_, s)
	if s == "down" then
		if controls.aim == true then
			animate(weapons[weapon.name].aim.position.x, 0, 4, weapon.aimspeed, function(v)
				weapon.position.x = v
			end)
			animate(weapons[weapon.name].aim.fov, weapons[weapon.name].run.fov, 4, weapon.aimspeed, function(v)
				weapon.fov = v
			end)
			animate(weapons[weapon.name].aim.position.y, 0, 4, weapon.aimspeed, function(v)
				weapon.zPlus = v
			end, function()
				controls.aim = false
			end)
			setControlState("aim_weapon", false)
			toggleControl("aim_weapon", false)
		end
		if controls.fire == true then
			controls.fire = false
			setControlState("aim_weapon", false)
		end
		controls.sprint = true
		controls.cansprint = true
		animate(weapon.rPlus, 90, 4, 750, function(v)
			if controls.cansprint == true then
				weapon.rPlus = v
			end
		end)
		animate(weapon.fov, weapons[weapon.name].run.fov, 4, 500, function(v)
			weapon.fov = v
		end)
		setGameSpeed(weapons[weapon.name].runspeed)
		toggleControl("left", false)
		toggleControl("right", false)
		toggleControl("backwards", false)
	else
		controls.cansprint = false
		animate(weapon.rPlus, 0, 4, 400, function(v)
			if controls.cansprint == false then
				weapon.rPlus = v
			end
		end, function()
			controls.sprint = false
			toggleControl("aim_weapon", true)
		end)
		animate(weapon.fov, weapons[weapon.name].idle.fov, 4, 500, function(v)
			weapon.fov = v
		end)
		setGameSpeed(weapons[weapon.name].speed)
		toggleControl("left", true)
		toggleControl("right", true)
		toggleControl("backwards", true)
	end
end

function shoot()
	if weapon.bullet == 0 then return end
	if controls.sprint == true then return end
	if isPlayerDead(localPlayer) then return end
	local _bAllValid = getKeyState("w") or getKeyState("a") or getKeyState("s") or getKeyState("d")
	if _bAllValid == true then
		_accurrary = weapons[weapon.name].walk.accurrary
		_accurrary_anim = weapons[weapon.name].walk.accurrary_anim
		_range = weapons[weapon.name].walk.range
	else
		_accurrary = weapons[weapon.name].idle.accurrary
		_accurrary_anim = weapons[weapon.name].idle.accurrary_anim
		_range = weapons[weapon.name].idle.range
	end
	
	if controls.aim == true then
		_accurrary = weapons[weapon.name].aim.accurrary
		_accurrary_anim = weapons[weapon.name].aim.accurrary_anim
		_range = weapons[weapon.name].aim.range
	end
	
	local _muzzlePos = Vector3(getElementPosition(weapon.muzzleobj))
	local _targetPos = Vector3(getWorldFromScreenPosition(screen.x/2 + math.random(_accurrary[1], _accurrary[2]), screen.y/2 + math.random(_accurrary[3], _accurrary[4]), _range))
	light = createLight(0, _muzzlePos, 10, 255, 235, 84)
	setTimer(function()
		destroyElement(light)
	end, 50, 1)
	dxDrawMaterialLine3D(_muzzlePos.x, _muzzlePos.y, _muzzlePos.z-0.1, _muzzlePos.x, _muzzlePos.y, _muzzlePos.z+0.1, muzzleflash, 0.2, tocolor(255, 235, 84, 255), _targetPos)
	
	animate(0, math.random(_accurrary_anim[1], _accurrary_anim[2])/1000, 4, math.random(50, 100), function(v)
		weapon.acc.x = v
	end, function()
		animate(weapon.acc.x, 0, 4, 100, function(v)
			weapon.acc.x = v
		end)
	end)
	
	animate(0, math.random(_accurrary_anim[1], _accurrary_anim[2])/1000, 4, math.random(50, 100), function(v)
		weapon.acc.y = v
	end, function()
		animate(weapon.acc.y, 0, 4, 100, function(v)
			weapon.acc.y = v
		end)
	end)
	
	animate(0, math.random(_accurrary_anim[3], _accurrary_anim[4])/1000, 4, math.random(50, 100), function(v)
		weapon.acc.z = v
	end, function()
		animate(weapon.acc.z, 0, 4, 100, function(v)
			weapon.acc.z = v
		end)
	end)
	
	playSound(weapons[weapon.name].sound)
	
	_muzzlePos.z = _muzzlePos.z + 0.1
	
	local hit, hx, hy, hz = processLineOfSight(_muzzlePos, _targetPos, true, true, true, false, false)
	if (hit) then
		_d = getDistanceBetweenPoints3D(_muzzlePos, hx, hy, hz)
		local _t = 50*(_d/30)
		if _t <= 50 then
			_t = 50
		end
		triggerServerEvent("onClientShoot", resourceRoot, localPlayer, weapons[weapon.name].sound, _t, hx, hy, hz, _muzzlePos.x, _muzzlePos.y, _muzzlePos.z)
	else
		_d = 1500
		local _t = 50*(_d/30)
		if _t <= 50 then
			_t = 50
		end
		triggerServerEvent("onClientShoot", resourceRoot, localPlayer, weapons[weapon.name].sound, _t, 0, 0, 0, _muzzlePos.x, _muzzlePos.y, _muzzlePos.z)
	end
	local _t = 50*(_d/30)
	if _t <= 50 then
		_t = 50
	end
	setTimer(function()
		local hit, hx, hy, hz, element = processLineOfSight(_muzzlePos, _targetPos, true, true, true, false, false)
		if (hit) then
			fxAddBulletImpact(hx, hy, hz, 0, 0, 1, math.random(1, 5), math.random(5, 10), 1.5)
			controls.holes[#controls.holes + 1] = {Vector3(hx, hy, hz), _muzzlePos}
			s = playSound3D("assets/sounds/impact.mp3", hx, hy, hz)
			setSoundMaxDistance(s, 700)
			if (element) then
				if getElementType(element) == "ped" then
					killPed(element)
				elseif getElementType(element) == "player" then
					triggerServerEvent("onPlayerHitKill", resourceRoot, element)
				end
			end
		end
	end, _t, 1)

	local camX = camera.x - math.random(_accurrary_anim[1], _accurrary_anim[2])/2000*camera.speed 
	local camY = camera.y - math.random(_accurrary_anim[1], _accurrary_anim[2])/2000*camera.speed 
	local camZ = camera.z + (math.random(_accurrary_anim[3], _accurrary_anim[4])/2000*camera.speed)/math.pi 
	if(camZ > camera.maxZ)then 
		camZ = camera.maxZ 
	end 
	if(camZ < camera.minZ)then 
		camZ = camera.minZ 
	end 
	camera.x = camX 
	camera.y = camY 
	camera.z = camZ
	weapon.bullet = weapon.bullet - 1
end

function fire(_, s)
	if s == "down" and weapon.bullet == 0 then
		playSound("assets/sounds/impact.mp3")
	end
	if (isPlayerDead(localPlayer)) then killTimer(controls.shootTimer) return end
	if controls.sprint == true then killTimer(controls.shootTimer) return end
	if weapon.type == "auto" then
		if s == "down" then
			shoot()
			controls.shootTimer = setTimer(shoot, weapon.firerate, 0)
			setControlState("aim_weapon", true)
			setElementData(localPlayer, "weapon:aim", true)
			controls.fire = true
		else
			killTimer(controls.shootTimer)
			if controls.aim == false then
				setControlState("aim_weapon", false)
				setElementData(localPlayer, "weapon:aim", false)
			end
			controls.fire = false
		end
	elseif weapon.type == "semi" then
		if s == "down" then
			shoot()
		end
	end
end

function reload()
	enableControls(false)
	setPedAnimation(weapon.arms, "firstperson", magazines[weapon.name].reloadanim, -1, false, false, true, false, -1)
	playSound("assets/sounds/ak47_reload.mp3")
	
	setTimer(function()
		exports["bones"]:detachElementFromBone(weapon.magazine)
		exports["bones"]:attachElementToBone(
			weapon.magazine,
			weapon.arms,
			11,
			
			0.1,
			0,
			0.1,
			
			90,
			0,
			0
		)
	end, magazines[weapon.name].magStart, 1)

	setTimer(function()
		exports["bones"]:detachElementFromBone(weapon.magazine)
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
	end, magazines[weapon.name].magStop, 1)
	
	setTimer(function()
		addMagazine()
		enableControls(true)
		setPedAnimation(weapon.arms, "firstperson", "idle", -1, true, false, true, false, -1)
	end, magazines[weapon.name].reloadtime, 1)
end

function enableControls(state)
	if state == true then
		bindKey("mouse1", "both", fire)
		bindKey("mouse2", "both", aim)
		bindKey("lshift", "both", sprint)
		bindKey("r", "down", reload)
		bindKey("x", "down", switch)
	else
		unbindKey("mouse1", "both", fire)
		unbindKey("mouse2", "both", aim)
		unbindKey("lshift", "both", sprint)
		unbindKey("r", "down", reload)
		unbindKey("x", "down", switch)
	end
end