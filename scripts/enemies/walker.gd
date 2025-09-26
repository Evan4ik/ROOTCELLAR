class_name  WalkerE
extends Enemy

@export var speed:float = 2.5
@export var maxDistance:float = 35.0


@export var targetedNodes:PackedStringArray = ["player"]
var targets:Array = []
var chase:Node3D = null

var anim:bool = false

func _ready() -> void: 
	targets = [].duplicate()
	$vision.area_entered.connect(see)
	_doPattern()

func _doPattern() -> void:
	await get_tree().create_timer(0.01).timeout
	if (hp <= 0): return
	_doPattern()

func die():
	if (hp < -100): return
	hp = -150
	anim = true
	$anim.stop()
	
	$anim.play("die")
	$phit/coll.disabled = true
	
	while($anim.is_playing()): await get_tree().create_timer(0.01).timeout
	self.queue_free()

func see(area) -> void:
	if (area == null or !is_instance_valid(area) or !targetedNodes.has(area.name) or targets.has(area.get_parent())): return
	var target = area.get_parent()
	var targetPos = target.global_transform.origin
	$viewray.target_position = $viewray.to_local(targetPos)
	anim = true
	
	await get_tree().create_timer(0.01).timeout
	if($viewray.get_collider() == null or $viewray.get_collider() != target): return
	targets.append(target)
	
	$anim.play("spot")
	var i = 0
	
	
	var rot = self.rotation_degrees
	self.look_at(targetPos, Vector3.UP)
	self.rotation_degrees *= Vector3(0, 1.0, 0) 
	self.rotation_degrees += Vector3.UP * 180.0
	var targetRot = self.rotation_degrees
	self.rotation_degrees = rot
	
	while(i < 50):
		self.rotation_degrees = lerp(self.rotation_degrees, targetRot, 0.15)
		i += 1
		await get_tree().create_timer(0.01).timeout
	await get_tree().create_timer(0.35).timeout
	anim = false

func hitEffects() -> void:
	see(get_node("/root/World/player/player"))
