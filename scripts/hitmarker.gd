extends Node3D

func start(doneDamage:float, baseDmg:float) -> void:
	var damageMult:float = (baseDmg / doneDamage) 
	var scaleMult:float = 0.5 / damageMult
	self.scale = Vector3.ONE * scaleMult
	
	var modulate:Color = Color(1.0, min(1.0 * damageMult, 1.0), min(1.0 * damageMult, 1.0), 1.0)
	$vis.modulate = modulate
	
	$vis/viewport/text.text = str(doneDamage)
	$anim.play("start")
	await get_tree().create_timer(0.9).timeout
	self.queue_free()
	
	
