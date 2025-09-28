extends Node
class_name Weapon

@export var damage:float = 1.0
@export var critChance:int = 25
@export var coolDowns:Dictionary[String, float] = {"swing": 0.5, "sideswing": 0.4, "forwardswing": 0.6}

@export_category("Multipliers")
@export var rangeMultiplier:float = 1.0
@export var damageMultiplier:float = 1.0
@export var cdMultiplier:float = 1.0

var hits:Array = []

var r = RandomNumberGenerator.new()
var cd:bool = false
var currentSwing:String = ""

func _ready() -> void: 
	r.randomize()
	$range/coll.disabled = true
	$range.area_entered.connect(hit)
	$slash/slash.visible = false
	hits = [].duplicate()

func swing():
	if cd: return
	hits = [].duplicate()
	cd = true
	$range.scale = Vector3.ONE * rangeMultiplier
	$range.position.z = $range.scale.x / -1.3
	$slash.scale.z = $range.scale.x
	$slash.position.z = 0.5 - ($range.scale.x / 2.0)
	$range/coll.disabled = false
	$anim.stop()
	playSwingAnim()
	$slash/slash.rotation_degrees = Vector3(r.randf_range(-25.0, 25.0), r.randf_range(-8.0, 8.0), r.randf_range(-5.0, 5.0))
	await get_tree().create_timer(coolDowns[currentSwing] * cdMultiplier).timeout
	cd = false
	$range/coll.disabled = true

func playSwingAnim() -> void:
	var swing:String = "swing"
	
	if (Input.is_action_pressed("down")): swing = "swing"
	elif (Input.is_action_pressed("left") || Input.is_action_pressed("right")): swing = "sideswing"
	elif(Input.is_action_pressed("up")): swing = "forwardswing"
	
	currentSwing = swing
	$anim.play(swing)

var hitMarker = preload('res://scenes/hitmarker.tscn')

func hit(area: Area3D) -> void:
	if (area == null or !is_instance_valid(area) or area.name != "enemy"): return
	if (hits.has(area)): return
	
	var doneDamage = calculateHit()
	area.get_parent().hit(doneDamage)
	var inst = hitMarker.instantiate()
	area.get_parent().add_child(inst)
	inst.start(doneDamage, damage)
	
	var r= RandomNumberGenerator.new()
	r.randomize()
	
	inst.global_transform.origin = $range.global_transform.origin + Vector3(r.randf_range(-0.125, 0.125), r.randf_range(-0.15, 0.25), r.randf_range(-0.125, 0.125))
	inst.global_transform.origin += (self.global_transform.origin - inst.global_transform.origin).normalized() * 0.25
	
	hits.append(area)


func calculateHit() -> float:
	var range:PackedFloat32Array = [damage - (damage / 10.0), damage * 1.35]
	match (currentSwing):
		"sideswing": range = [damage - (damage / 10.0), damage]
		"forwardswing": range = [damage * 1.15, damage * 1.85]
	
	var calcDamage:float = round(r.randf_range(range[0], range[1]) * 10.0) / 10.0
	var r= RandomNumberGenerator.new()
	r.randomize()
	
	if (r.randi_range(0, 100) <= critChance): calcDamage *= 2.0
	
	return calcDamage * damageMultiplier
