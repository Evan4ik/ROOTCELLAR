extends CharacterBody3D
class_name Enemy

@export var hp:float = 5.0
@export var defense:float = 0.0

@export var hitPath:String = "hit"

var hitTime:int = 0

func hit(damage):
	hitTime += 25
	doHitAnim()
	hitEffects()
	hp -= damage
	if (hp <= 0): die()

func hitEffects() -> void: pass
func die() -> void: pass

func doHitAnim():
	var i:int = 0
	while(i < hitTime):
		get_node(hitPath).visible = true
		await get_tree().create_timer(0.01).timeout
		i += 1
	hitTime = 0
	get_node(hitPath).visible = false
