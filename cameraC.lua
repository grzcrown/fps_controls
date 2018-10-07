camera = {} 
camera.dist = 5
camera.speed = 4 
camera.x = math.rad(60) 
camera.y = math.rad(60) 
camera.z = math.rad(15) 
camera.maxZ = math.rad(85) 
camera.minZ = math.rad(-45)
camera.vector = Vector3(0, 0, 0)
camera.smoothvector = Vector3(0, 0, 0)
camera.rotx = 0
camera.roty = 0
camera.w = nil
camera.bullet = nil

function drawData()
	dxDrawRectangle(screen.x - 200, 5, 195, 70, tocolor(0, 0, 0, 150))
	dxDrawText("Ammo: "..tostring(weapon.bullet), screen.x - 180 + 1, 10 + 1, 1, 1, tocolor(0, 0, 0, 255), 1.3)
	dxDrawText("Ammo: "..tostring(weapon.bullet), screen.x - 180, 10, 1, 1, tocolor(255, 255, 255, 255), 1.3)
	dxDrawText("Weapon: "..tostring(weapon.name), screen.x - 180 + 1, 30 + 1, 1, 1, tocolor(0, 0, 0, 255), 1.3)
	dxDrawText("Weapon: "..tostring(weapon.name), screen.x - 180, 30, 1, 1, tocolor(255, 255, 255, 255), 1.3)
	dxDrawText("Type: "..tostring(weapon.type), screen.x - 180 + 1, 50 + 1, 1, 1, tocolor(0, 0, 0, 255), 1.3)
	dxDrawText("Type: "..tostring(weapon.type), screen.x - 180, 50, 1, 1, tocolor(255, 255, 255, 255), 1.3)
end
--addEventHandler("onClientRender", root, drawData)

function renderCamera_foot() 
    local _playerPos = Vector3(getElementPosition(localPlayer))
	local _cameraRot = Vector3(getElementRotation(getCamera()))
	_bonePosition = Vector3(getPedBonePosition(localPlayer, 3))
	_bonePosition.z = _bonePosition.z + 0.46
    local _camDist = camera.dist 
    local _cosZ = math.cos(camera.z) 
    camera.vector = Vector3(
		_playerPos.x + math.cos(camera.x)*_camDist*_cosZ, 
		_playerPos.y + math.sin(camera.y)*_camDist*_cosZ, 
		_playerPos.z + math.sin(camera.z)*_camDist
	) 
    setCameraMatrix(_bonePosition, camera.vector, 0, weapon.fov)
end

function moveCamera_foot(curX, curY, absX, absY) 
	local _valid = isChatBoxInputActive() or isCursorShowing() or isConsoleActive() or isMTAWindowActive()
	if _valid == true then return end
    local diffX = curX - 0.5 
    local diffY = curY - 0.5 
    local camX = camera.x - diffX*camera.speed 
    local camY = camera.y - diffX*camera.speed 
    local camZ = camera.z - (diffY*camera.speed)/math.pi 
    if(camZ > camera.maxZ)then 
        camZ = camera.maxZ 
    end 
    if(camZ < camera.minZ)then 
        camZ = camera.minZ 
    end 
    camera.x = camX 
    camera.y = camY 
    camera.z = camZ 
end

function renderCamera_vehicle(deltaTime)
	local _playerRot = Vector3(getElementRotation(localPlayer))
	local _playerPos = Vector3(getElementPosition(localPlayer))
	local _playerMat = Matrix(_playerPos, _playerRot)
	
	local _headPos = Vector3(getPedBonePosition(localPlayer, 8))
	_headPos.z = _headPos.z + 0.15

	_playerPos.z = _playerPos.z + 0.15
	if (getPedOccupiedVehicle(localPlayer)) then
		_fov = 70+(getElementSpeed(getPedOccupiedVehicle(localPlayer), 1)/10)
	else
		_fov = 70
	end
	
	_playerRot.z = _playerRot.z + 90 - camera.rotx
	_playerRot.x = -_playerRot.x - camera.roty
	
	x = _playerPos.x+15*math.cos(math.rad(_playerRot.z))*math.cos(math.rad(_playerRot.x))
	y = _playerPos.y+15*math.sin(math.rad(_playerRot.z))*math.cos(math.rad(_playerRot.x))
	z = _playerPos.z+15*math.sin(math.rad(_playerRot.x))
	
    local _currentPos = camera.smoothvector
	local _targetPos = Vector3(x, y, z)
    local _direction = _targetPos - _currentPos
    _direction:cross(_targetPos)
	_directPos = _currentPos + _direction * deltaTime * 0.005
	
	camera.smoothvector = _directPos
	
	setCameraMatrix(_headPos, _directPos, _playerRot.y, _fov)
end

function moveCamera_vehicle(curX, curY, absX, absY)
	local _valid = isChatBoxInputActive() or isCursorShowing() or isConsoleActive() or isMTAWindowActive()
	if _valid == true then return end
	camera.rotx = camera.rotx + ((curX-0.5)*200)
	camera.roty = camera.roty + ((curY-0.5)*100)
	
	if camera.roty >= 70 then camera.roty = 70 end
	if camera.roty <= -70 then camera.roty = -70 end
end

function toggleCamera(state, type)
	if type  == "foot" then
		if state == true then
			if (camera.w) then
				setClientWeapon(camera.w)
				addMagazine()
				weapon.bullet = camera.bullet
				camera.w = nil
				camera.bullet = nil
			end
			addEventHandler("onClientRender", getRootElement(), renderCamera_foot)
			addEventHandler("onClientCursorMove", getRootElement(), moveCamera_foot)
			removeEventHandler("onClientPreRender", getRootElement(), renderCamera_vehicle)
			removeEventHandler("onClientCursorMove", getRootElement(), moveCamera_vehicle)
			setElementAlpha(localPlayer, 0)
			setNearClipDistance(0.1)
			setRenderControlsEnabled(true)
		else
			removeEventHandler("onClientRender", getRootElement(), renderCamera_foot)
			removeEventHandler("onClientCursorMove", getRootElement(), moveCamera_foot)
			removeEventHandler("onClientPreRender", getRootElement(), renderCamera_vehicle)
			removeEventHandler("onClientCursorMove", getRootElement(), moveCamera_vehicle)
			setElementAlpha(localPlayer, 255)
			setNearClipDistance(0.3)
			setRenderControlsEnabled(false)
		end
	elseif type == "vehicle" then
		if state == true then
			if (weapon.name) then
				camera.w = weapon.name
				camera.bullet = weapon.bullet
				setClientWeapon("none")
			end
			setRenderControlsEnabled(false)
			addEventHandler("onClientPreRender", getRootElement(), renderCamera_vehicle)
			addEventHandler("onClientCursorMove", getRootElement(), moveCamera_vehicle)
			removeEventHandler("onClientRender", getRootElement(), renderCamera_foot)
			removeEventHandler("onClientCursorMove", getRootElement(), moveCamera_foot)
			setElementAlpha(localPlayer, 0)
			setNearClipDistance(0.1)
		else
			setRenderControlsEnabled(true)
			removeEventHandler("onClientPreRender", getRootElement(), renderCamera_vehicle)
			removeEventHandler("onClientCursorMove", getRootElement(), moveCamera_vehicle)
			removeEventHandler("onClientRender", getRootElement(), renderCamera_foot)
			removeEventHandler("onClientCursorMove", getRootElement(), moveCamera_foot)
			setElementAlpha(localPlayer, 255)
			setNearClipDistance(0.3)
		end
	end
end

addEventHandler("onClientVehicleEnter", getRootElement(),
function(player, seat)
	if player == localPlayer then
		toggleCamera(true, "vehicle")
	end
end)

addEventHandler("onClientVehicleExit", getRootElement(),
function(player)
	if player == localPlayer then
		toggleCamera(true, "foot")
	end
end)

toggleCamera(true, "foot")
