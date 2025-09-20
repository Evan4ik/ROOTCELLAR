extends Food

var generating:bool = false
var regenTime:float = 1.0

func togglePassive(setOn:bool = !is_processing()):
	if (usedPassive): return
	set_process(setOn)
	
	if (setOn): player.speed /= 2.0
	else: player.speed *= 2.0

func _process(delta: float) -> void:
	if generating: return
	generating = true
	while(regenTime > 0):
		if (!self.is_processing()): 
			generating = false
			return
		regenTime -= 0.1
		await get_tree().create_timer(0.05).timeout
	player.changeHp(passiveAmt, 0)
	regenTime = 60.0
	generating = false

func _active():
	player.changeHp(activeAmt, 0)

func getDisplayNumbers():
	var ret:Array = [ int(passiveAmt), int(activeAmt)]
	return addMultColors(ret)
