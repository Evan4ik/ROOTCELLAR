extends ColorRect

var currentFood:Food = null
@onready var description = get_tree().get_first_node_in_group("descriptionman")
var mouseIn:bool = false
var stopped:bool = false

var noInteract:bool = false

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
	
	if (Input.is_action_just_pressed("click")): 
		if (doing or noInteract): return
		var mode = get_parent().get_parent().mode
		if (mode == 0): consume()
		else: slice()
	if (Input.is_action_pressed("grab")): throw()

var doing:bool = false

func consume():
	
	var i:int = 0
	while(Input.is_action_pressed("click")):
		if (i >= 40): break
		self.scale = lerp(self.scale, Vector2.ONE * 0.5, 0.05)
		i += 1
		await get_tree().create_timer(0.01).timeout
	if (i < 40):
		i = 0
		while(i < 20):
			self.scale = lerp(self.scale, Vector2.ONE, 0.15)
			i += 1
			await get_tree().create_timer(0.01).timeout
		return
	
	currentFood._active()
	currentFood.togglePassive(false)
	
	i = 0
	
	
	if ("Sliced" in currentFood.foodName and !("eaten") in currentFood.modifiers): 
		currentFood.modifiers.append("eaten")
		while(i < 20):
			self.scale = lerp(self.scale, Vector2.ONE, 0.15)
			i += 1
			await get_tree().create_timer(0.01).timeout
		return
	
	while(i < 20):
		description.hideDesc()
		self.scale = lerp(self.scale, Vector2.ZERO, 0.25)
		self.position.y += 1.0
		i += 1
		await get_tree().create_timer(0.01).timeout
	description.hideDesc()
	self.free()

func slice():
	doing = true
	var i:int = 0
	while(i < 80):
		self.rotation_degrees = lerp(self.rotation_degrees, 360.0, 0.085)
		print(i)
		i += 1
		if (i == 20): 
			for child in currentFood.get_node("mesh").get_children(): child.visible = child.name == "sliced"
			if(currentFood.descriptionMods.has("sliced")): currentFood.foodDescription = currentFood.descriptionMods["sliced"]
			currentFood.foodName = "Sliced " + currentFood.foodName
			mouse(true)
		await get_tree().create_timer(0.01).timeout
	get_parent().get_parent().refreshFood(true)
	doing = false

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

func reRot() -> void:
	var i = 0
	while(i < 150):
		if (self.is_physics_processing()): return
		currentFood.rotation_degrees = lerp(currentFood.rotation_degrees, Vector3.ZERO, 0.05)
		i += 1
		await get_tree().create_timer(0.01).timeout
