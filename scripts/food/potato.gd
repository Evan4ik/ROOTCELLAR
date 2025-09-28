extends Food

func togglePassive(setOn:bool = !is_processing()):
	if (usedPassive == setOn): return
	var weapon = player.weapon
	if (weapon == null): return
	
	if(setOn): 
		weapon.rangeMultiplier *= passiveAmt
		usedPassive = true
	else: 
		weapon.rangeMultiplier /= passiveAmt
		usedPassive = false

func _active() ->void:
	var weapon = player.weapon
	if (weapon == null): return
	
	weapon.rangeMultiplier *= activeAmt
