extends Food

var mIdx:Dictionary[String, int] = {}

func readyArgs() -> void: set_process(true)

func togglePassive(setOn:bool = !is_processing()):
	if (!mIdx.has(player.weapon.weaponName)):
		mIdx[player.weapon.weaponName] = player.weapon.damageMultipliers.size()
		player.weapon.damageMultipliers.append(0.0)
	
	if (setOn): player.weapon.damageMultipliers[mIdx[player.weapon.weaponName]] = pMultiplier * passiveAmt
	else:
		player.weapon.damageMultipliers.remove_at(mIdx[player.weapon.weaponName])
		mIdx.erase(player.weapon.weaponName)

func _process(delta: float) -> void:
	var max:float = startTime * 2
	var current:float = life + startTime
	
	var perc:float = 1.0 - (current / max)
	if (current < 1): perc = -1.0
	
	passiveAmt = perc * 1.5
	activeAmt = (5.0 * perc) + 5.0 

func moldify(rot = false): pass

func getDisplayNumbers():
	var ret:Array = [ round(passiveAmt * pMultiplier * 100) / 100.0, round(activeAmt * aMultiplier * 100) / 100.0]
	return addMultColors(ret)

func _active():
	
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if (enemy.global_transform.origin.distance_to(player.global_transform.origin) > 7.0): continue
		enemy.hit(activeAmt * aMultiplier)
