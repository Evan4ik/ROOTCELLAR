extends ColorRect

var currentFood:Food = null
@onready var description = get_tree().get_first_node_in_group("descriptionman")
var mouseIn:bool = false
var stopped:bool = false

func _ready() -> void:
	set_process(false)
	set_physics_process(false)
	if (currentFood == null): return
	self.mouse_entered.connect(mouse.bind(true) )
	self.mouse_exited.connect(mouse.bind(false))
	currentFood.togglePassive(true)

func mouse(inside):
	if (stopped): return
	mouseIn = inside
	set_process(inside)
	
	if (inside):
		var desc = currentFood.getDescription() 
		description.showDesc(desc[0], desc[1])
	elif(!inside):description.hideDesc()

func _process(delta: float) -> void:
	if (!mouseIn): return
	
	if (Input.is_action_just_pressed("click")): consume()
	if (Input.is_action_pressed("grab")): throw()

func consume():
	currentFood._active()
	self.visible = false
	currentFood.togglePassive(false)
	await get_tree().create_timer(0.1).timeout
	description.hideDesc()
	self.free()

func throw():
	set_process(false)
	stopped = true
	
	var player = get_tree().get_first_node_in_group("player")
	currentFood.get_parent().remove_child(currentFood)
	player.get_parent().add_child(currentFood)
	var target = player.camray.get_node("holdtarget")
	var pos = target.position.z
	target.position.z = -1.0
	currentFood.global_transform.origin = target.global_transform.origin
	target.position.z = pos
	currentFood.freeze = false
	self.visible = false
	currentFood.togglePassive(false)
	
	await get_tree().create_timer(0.1).timeout
	description.hideDesc()
	self.free()

func _physics_process(delta: float) -> void:
	if (currentFood == null): set_physics_process(false)
	currentFood.rotation_degrees += Vector3(60.0, 60.0, 0.0) * delta
