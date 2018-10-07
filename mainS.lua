function _spawn()
	for _, _p in pairs(getElementsByType("player")) do
		spawnPlayer(_p, 0, 0, 3)
		fadeCamera(_p, true)
	end
end
addEventHandler("onResourceStart", resourceRoot, _spawn)