remote = {}

function remoteAim()
	for _, v in pairs(getElementsByType("player")) do
		if v == localPlayer then
			setElementData(localPlayer, "aim:target", {camera.vector.x, camera.vector.y, camera.vector.z})
		else
			d = getElementData(v, "weapon:aim")
			if d == true then
				local vector = getElementData(v, "aim:target")
				setPedAimTarget(v, vector[1], vector[2], vector[3])
			end
		end
	end
end
addEventHandler("onClientPreRender", root, remoteAim)

function disableWeapon(player, object)
	if player == localPlayer then
		setElementAlpha(object, 0)
	end
end
addEvent("onServerWeaponCreate", true)
addEventHandler("onServerWeaponCreate", resourceRoot, disableWeapon)

function remoteShoot(player, sound, time, x, y, z, tx, ty, tz)
	if not (player == localPlayer) then
		local _startPos = Vector3(tx, ty, tz)
		local _endPos = Vector3(x, y, z)
		dxDrawMaterialLine3D(_startPos.x, _startPos.y, _startPos.z-0.1, _startPos.x, _startPos.y, _startPos.z+0.1, muzzleflash, 0.2, tocolor(255, 235, 84, 255), _endPos)
		s = playSound3D(sound, _startPos)
		light = createLight(0, _startPos, 10, 255, 235, 84)
		destroyElement(light)
		setSoundMaxDistance(s, 700)
		setTimer(function()
			fxAddBulletImpact(_endPos, 0, 0, 1, math.random(1, 5), math.random(5, 10), 1.5)
			controls.holes[#controls.holes + 1] = {_endPos, _startPos}
			s = playSound3D("assets/sounds/impact.mp3", _endPos)
			setSoundMaxDistance(s, 700)
		end, time, 1)
	end
end
addEvent("onServerShoot", true)
addEventHandler("onServerShoot", resourceRoot, remoteShoot)