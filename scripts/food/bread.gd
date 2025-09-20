extends Food

func _process(delta: float) -> void:
	usedPassive = true
	player.changeHp(passiveAmt, -1)
	set_process(false)

func _active():
	player.changeHp(activeAmt, 0)

func getDisplayNumbers():
	var ret:Array = [ int(passiveAmt), int(activeAmt)]
	return addMultColors(ret)
