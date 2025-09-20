extends Node2D

var shown:bool = false
@onready var player = get_parent().get_node("../player")

func _process(delta: float) -> void:
	if !(Input.is_action_just_pressed("foodmenu")): return
	shown = !shown
	player.set_process_input(!shown)
	$anim.play("show" if (shown) else "hide")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if !shown else Input.MOUSE_MODE_VISIBLE
	for child in $container.get_children(): child.set_physics_process(shown)
	get_tree().paused = shown
