weapons = {
	["gewerth"] = {
		model = 7441,
		position = Vector3(0, 0, 0.2),
		rotation = Vector3(0, 0, 0),
		aim = {
			position = Vector2(-0.102, 0.0375),
			fov = 40,
			accurrary = {20 - 2, 20 + 2, 20, 20 + 10},
			accurrary_anim = {-10, 10, 4, 20},
			range = 600
		},
		idle = {
			position = Vector2(0, 0),
			fov = 70,
			accurrary = {-20, 20, -20, 20},
			accurrary_anim = {-30, 30, 0, 35},
			range = 500
		},
		walk = {
			position = Vector2(0, 0),
			fov = 70,
			accurrary = {-40, 40, -40, 40},
			accurrary_anim = {-50, 50, 0, 50},
			range = 300
		},
		run = {
			position = Vector2(0, -0.07),
			fov = 80,
		},
		smooth = 0.012,
		aimspeed = 350,
		type = "semi",
		switchable = false,
		firerate = 100,
		sound = "assets/sounds/ak47.mp3",
		magazine = "magazine:gewerth",
		speed = 1.0,
		runspeed = 1.4,
		muzzleposition = Vector3(0.1, 1.3, -0.058)
	}
}

magazines = {
	["gewerth"] = {
		model = 7452,
		position = Vector3(0.076, -0.01, 0.32),
		rotation = Vector3(0, 0, 0),
		maxbullet = 15,
		reloadanim = "reload",
		reloadtime = 2660,
		magStart = 1000,
		magStop = 2000
	}
}

attachments = {

}