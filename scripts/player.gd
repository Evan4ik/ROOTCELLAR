extends CharacterBody3D

@export var hp:int = 4.0
@export var maxHp:int = 4.0
var temporaryHps:Dictionary[int, int] = {}

@export var speed:float = 1.0
@export var iFrames:float = 0.5

@onready var camera = $cameraviewport/viewport/camera
@onready var camray:RayCast3D = camera.get_node("camray")
@onready var description = get_tree().get_first_node_in_group("descriptionman")

@onready var weapon:Weapon

func _ready() -> void: 
	$cameraviewport.visible = true
	$player.area_entered.connect(area)
	refreshHp()
	if (camera.get_node('wield').get_child_count() > 0): weapon = camera.get_node("wield").get_child(0)

var camBob:float = 0.0

func get_input(delta:float) -> void:
	delta *= 100.0
	if Input.is_action_pressed("up"): velocity -= basis.z * speed * delta
	if Input.is_action_pressed("down"): velocity += basis.z * speed * delta
	if Input.is_action_pressed("left"): velocity -= basis.x * speed * delta
	if Input.is_action_pressed("right"): velocity += basis.x * speed * delta
	velocity.y -= 1.0
	
	if Input.is_action_pressed("ui_up"): $cameratar.rotation_degrees.x = clamp($cameratar.rotation_degrees.x + 1.5, -75, 75)
	if Input.is_action_pressed("ui_down"): $cameratar.rotation_degrees.x = clamp($cameratar.rotation_degrees.x - 1.5, -75, 75)
	if Input.is_action_pressed("ui_left"): self.rotation_degrees.y += 2.15
	if Input.is_action_pressed("ui_right"): self.rotation_degrees.y -= 2.15 


	var hasInput = abs(velocity.x) > 1.1 or abs(velocity.z) > 1.1
	if (hasInput):
		camBob += 0.1
	else: camBob = 0
	$cameratar.position.y = lerp($cameratar.position.y, 0.4 + sin(camBob) * 0.045, 0.15)
	camera.get_node("wield").position.y = -$cameratar.position.y
	
	if Input.is_action_pressed("ui_end"): Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Input.is_action_pressed("click") and weapon != null: weapon.swing()

func _input(event: InputEvent) -> void:
	if (event is InputEventMouseButton) and (event.button_index == 4 or event.button_index == 5):
		var mult = 1 if (event.button_index == 5) else -1
		camray.get_node("holdtarget").position.z = clamp(camray.get_node("holdtarget").position.z + 0.1 * mult, -4.0, -1.2)
	
	if !(event is InputEventMouseMotion) or  Input.is_action_pressed("ui_end"): return
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	self.rotation_degrees.y -= event.relative.x
	
	$cameratar.rotation_degrees.x = clamp($cameratar.rotation_degrees.x - event.relative.y, -75, 75)

func _process(delta: float) -> void:
	get_input(delta)
	camera.global_transform.origin = $cameratar.global_transform.origin
	camera.global_rotation = $cameratar.global_rotation
	
	if(Input.mouse_mode == Input.MOUSE_MODE_CAPTURED): 
		if (camray.get_collider() != null): ray()
		elif(camray.get_collider() == null and description.visible): unGrab()
		
	velocity /= 1.115
	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider is RigidBody3D:
			collider.apply_central_impulse(-collision.get_normal() * 3)
 
var hpBar = preload('res://scenes/ui/hpbar.tscn')
@onready var hpIcon = get_node("../ui/hp")

func refreshHp():
	var amt = 64.0 / (maxHp if (maxHp > hp) else hp)
	var oldAmount = hpIcon.get_node("bg2/container").get_child_count()
	for thing in hpIcon.get_node("bg2/container").get_children(): thing.queue_free()
	hpIcon.get_node("hp").text = str(hp)
	
	var textColor = "#000000"
	if (hp == 1): textColor = "#670001"
	elif(temporaryHps.size() > 0): textColor = "ffdc00"
	hpIcon.get_node("hp").set("theme_override_colors/font_outline_color", Color(textColor))
	
	var i = hp
	while(i > 0):
		var inst = hpBar.instantiate()
		hpIcon.get_node("bg2/container").add_child(inst)
		inst.custom_minimum_size.y = amt
		
		var color = "#ff5c5c"
		if (temporaryHps.has(i)): color = "#ffcf3b"
		
		inst.modulate = color
		
		i -= 1
		if(i >= oldAmount): animBar(inst)

func animBar(bar):
	var i = 0
	var scaleY = bar.custom_minimum_size.y 
	bar.custom_minimum_size.y = 0.0
	await get_tree().create_timer(0.15).timeout
	while(i < 20):
		if (!is_instance_valid(bar)): return
		bar.custom_minimum_size.y = lerp(bar.custom_minimum_size.y ,scaleY, 0.15)
		i += 1
		await get_tree().create_timer(0.01).timeout

var cd:bool = false


func changeHp(amt:int, temporary:int = -1):
	if (cd and amt < 0): return
	cd = true
	
	if (temporary >= 0):
		var i = 0
		while(i < abs(amt)):
			hp += 1
			temporaryHps[hp] = temporary
			i += 1
	elif(temporary == -1):
		if (temporaryHps.has(hp) and amt < 0): temporaryHps.erase(hp)
		hp = min(hp + amt, maxHp)
	else: maxHp += amt
	
	
	refreshHp()
	await get_tree().create_timer(iFrames).timeout
	cd = false

func area(area):
	if (area == null or !is_instance_valid(area)): return
	if (area.name == "phit"): 
		area.get_node("coll").disabled = true
		changeHp(-1)
		await get_tree().create_timer(iFrames + 0.05).timeout
		area.get_node("coll").disabled = false

func ray():
	var collider = camray.get_collider()
	if (collider == null or !is_instance_valid(collider)): return
	
	if ("foodarea" in collider.name):
		var desc = collider.get_parent().getDescription()
		
		if Input.is_action_just_pressed("pickup"): 
			collectFood(collider.get_parent())
			unGrab()
		elif Input.is_action_just_pressed("grab"):
			description.hideDesc()
			var target = camray.get_collision_point()
			doHold(collider.get_parent())
		elif(!Input.is_action_pressed("grab")): description.showDesc(desc[0], desc[1])
	elif("exitarea" in collider.name):
		if (Input.is_action_just_pressed("pickup")):
			get_node("../map").generate()
	elif(description.visible): unGrab()

func unGrab(): description.hideDesc()

func doHold(obj):
	while(Input.is_action_pressed("grab")):
		
		var target = camray.get_node("holdtarget").global_transform.origin
		obj.linear_velocity = ((target - obj.global_transform.origin) * 5.0) + (velocity / 1.15)
		await get_tree().create_timer(0.01).timeout
		
		
		if (Input.is_action_pressed("throw")):
			obj.linear_velocity = (obj.global_transform.origin - self.global_transform.origin) * 10.0
			Input.action_release("throw")
			Input.action_release("grab")

var foodRect = preload("res://scenes/ui/foodrect.tscn")

func collectFood(obj:RigidBody3D):
	var foodContainer = description.get_node("../foodcontainer/container")
	var inst = foodRect.instantiate()
	inst.currentFood = obj
	foodContainer.add_child(inst)
	
	obj.freeze = true
	obj.get_parent().remove_child(obj)
	inst.get_node("render/camera").add_child(obj)
	obj.freeze = true
	obj.linear_velocity = Vector3.ZERO
	await get_tree().create_timer(0.01).timeout
	obj.set_deferred("freeze", true)
	#obj.position.z = -2.0
	obj.position = Vector3.FORWARD * 2.0
	obj.rotation_degrees = Vector3(15.0, 15.0, 0.0)
