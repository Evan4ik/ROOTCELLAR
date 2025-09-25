extends Node2D

var shown:bool = false
@onready var player = get_parent().get_node("../player")
@export var mode:int = 0
#0: default, 1: slice


func _process(delta: float) -> void:
	if !(Input.is_action_just_pressed("foodmenu")): return
	shown = !shown
	player.set_process_input(!shown)
	$anim.play("show" if (shown) else "hide")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if !shown else Input.MOUSE_MODE_VISIBLE
	refreshFood(shown)
	get_tree().paused = shown

func refreshFood(shown: bool):
	for child in $container.get_children(): 
		child.set_physics_process(shown)
		if (!shown): child.reRot()
		
		var disabled:bool = false
		if (mode == 1): disabled = (child.currentFood == null) or ("Sliced" in child.currentFood.foodName) or (child.currentFood.get_node_or_null("mesh/sliced") == null)
		
		if (!shown): disabled = false
		
		child.modulate = Color(0.65, 0.65, 0.65, 1) if (disabled) else Color.WHITE
		child.noInteract = disabled
