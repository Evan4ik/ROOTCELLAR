extends Food


var mIdx:Dictionary[String, int] = {}

func togglePassive(setOn:bool = !is_processing()):
	if (usedPassive): return
	if (!mIdx.has(player.weapon.weaponName)):
		mIdx[player.weapon.weaponName] = player.weapon.rangeMultipliers.size()
		player.weapon.rangeMultipliers.append(0.0)
	
	
	
	if (setOn): 
		var totalRange = 0.0
		for mult in player.weapon.rangeMultipliers: totalRange += mult
		player.weapon.rangeMultipliers[mIdx[player.weapon.weaponName]] = (totalRange * pMultiplier * passiveAmt) - totalRange
	else:
		player.weapon.rangeMultipliers.remove_at(mIdx[player.weapon.weaponName])
		mIdx.erase(player.weapon.weaponName)


func _active() ->void:
	var weapon = player.weapon
	if (weapon == null): return
	
	weapon.rangeMultiplier *= activeAmt
