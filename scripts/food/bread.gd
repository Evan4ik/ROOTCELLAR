extends Food

func _process(delta: float) -> void:
	usedPassive = true
	player.changeHp(passiveAmt, -1)
	set_process(false)

func _active():
	player.changeHp(ceil(activeAmt), 0)

func getDisplayNumbers():
	var ret:Array = [ ceil(passiveAmt * pMultiplier), ceil(activeAmt * aMultiplier)]
	return addMultColors(ret)
