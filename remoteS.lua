server = {}
server.weapons = {}
server.attachments = {}

function kill(element)
	killPlayer(element)
end
addEvent("onPlayerHitKill", true)
addEventHandler("onPlayerHitKill", resourceRoot, kill)

function addWeaponS(player, state, id)
	if state == true then
		giveWeapon(player, 30, 30, true)
		server.weapons[#server.weapons + 1] = createObject(id, 0, 0, 0)
		local x = -0.2
		local y = 0.15
		local z = -0.1
		
		local rx = 170
		local ry = 0
		local rz = 180
		exports["bones"]:attachElementToBone(server.weapons[#server.weapons],player,12,x,y,z,rx,ry,rz)
		setElementData(player, "server:weapon", server.weapons[#server.weapons])
		triggerClientEvent("onServerWeaponCreate", resourceRoot, player, server.weapons[#server.weapons])
	else
		takeWeapon(player, 30, 30)
		local _weapon = getElementData(player, "server:weapon")
		if isElement(_weapon) then
			destroyElement(_weapon)
		end
	end
end
addEvent("onWeaponGive", true)
addEventHandler("onWeaponGive", resourceRoot, addWeaponS)

function addAttachmentS(state, player, id, x, y, z, id)
	if state == true then
		local _weapon = getElementData(player, "server:weapon")
		server.attachments[#server.attachments + 1] = createObject(id, 0, 0, 0)
		setElementCollisionsEnabled(server.attachments[#server.attachments], false)
		attachElements(server.attachments[#server.attachments], _weapon, x, y, z)
		setElementData(player, "weapon:attachment_"..tostring(id), #server.attachments)
		triggerClientEvent("onServerWeaponCreate", resourceRoot, player, server.attachments[#server.attachments])
	end
end
addEvent("onAttachmentGive", true)
addEventHandler("onAttachmentGive", resourceRoot, addAttachmentS)

function destroyAttachmentS(player, id)
	local _id = getElementData(player, "weapon:attachment_"..tostring(id))
	destroyElement(server.attachments[_id])
	table.remove(server.attachments, _id)
end
addEvent("onAttachmentRemove", true)
addEventHandler("onAttachmentRemove", resourceRoot, destroyAttachmentS)

function remoteShoot(player, sound, time, x, y, z, tx, ty, tz)
	triggerClientEvent("onServerShoot", resourceRoot, player, sound, time, x, y, z, tx, ty, tz)
end
addEvent("onClientShoot", true)
addEventHandler("onClientShoot", resourceRoot, remoteShoot)