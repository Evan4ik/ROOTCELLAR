extends Food

func togglePassive(setOn:bool = !is_processing()):
	if (usedPassive): return
	var weapon = player.weapon
	if (weapon == null): return
	
	if(setOn): weapon.get_node("range").scale *= passiveAmt
	else: weapon.get_node("range").scale /= passiveAmt

func _active() ->void:
	var weapon = player.weapon
	if (weapon == null): return
	
	weapon.get_node("range").scale *= activeAmt
