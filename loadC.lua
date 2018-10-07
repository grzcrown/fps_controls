models = {
	{"arm", 285, false},
	{"arm_2", 7425, false},
	{"ak47_simple", 7421, false},
	{"ak47_tactical", 7422, false},
	{"sniper", 7423, true},
	{"sight_1", 7440, true},
	{"ak47_tactical_magazine", 7450, true},
	{"ak47_simple_magazine", 7451, true},
	{"gewerth", 7441, true},
	{"gewerth_mag", 7452, true}
}
function loadModels()
	local txd = engineLoadTXD("assets/models/textures.txd")
	for _, v in pairs(models) do
		engineImportTXD(txd, v[2])
		engineReplaceModel(engineLoadDFF("assets/models/"..v[1]..".dff"), v[2], v[3])
	end
	local _anims = engineLoadIFP("assets/anim/firstperson.ifp", "firstperson")
end
addEventHandler("onClientResourceStart", resourceRoot, loadModels)