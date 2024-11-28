extends Node

var tower_data = {
	"archer_tower_lvl_1":{
		"damage": 50,
		"rof" : 1.5,
		"range":400,
		"type": "projectile",
		"cost": 150,
		"upgrade_cost": 250,
		"upgrade_to":"archer_tower_lvl_2"
		},
	"mage_tower_lvl_1":{
		"damage": 25,
		"rof" : 4,
		"range":500,
		"type": "area",
		"effect_radius": 75.0,
		"cost": 250,
		"upgrade_cost": 350,
		"upgrade_to":"mage_tower_lvl_2"
		},
	"archer_tower_lvl_2":{
		"damage": 75,
		"rof" : 1,
		"range":450,
		"type": "projectile",
		"upgrade_cost": 150,
		"upgrade_to":"archer_tower_lvl_3"
		},
	"mage_tower_lvl_2":{
		"damage": 50,
		"rof" : 3.5,
		"range":600,
		"type": "area",
		"effect_radius":75.0,
		"upgrade_cost": 300,
		"upgrade_to":"mage_tower_lvl_2"
		},
	"archer_tower_lvl_3":{
		"damage": 100,
		"rof" : 0.5,
		"range":500,
		"type": "projectile",
		"upgrade_cost": 300},
	"mage_tower_lvl_3":{
		"damage": 110,
		"rof" : 3,
		"range":650,
		"type": "area",
		"effect_radius": 75.0,
		"upgrade_cost": 500}}
