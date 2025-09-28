extends Node2D

func _ready() -> void: 
	$text.size = Vector2.ZERO
	self.visible = false
	set_process(false)

var anim:bool = false

var tagsc = preload("res://scenes/ui/desctag.tscn")

func showDesc(text: String, tags:Dictionary[String, String]) -> void:
	if (text == $text.text): return
	set_process(true)
	anim = true
	self.visible = true
	self.global_transform.origin = get_global_mouse_position()
	$text.text = str(text)
	$bg.size = $text.size
	
	for tag in $text/tags.get_children(): tag.queue_free()
	$text/tags.columns = 1 if (tags.size() < 2) else 2
	for tag in tags:
		var inst = tagsc.instantiate()
		$text/tags.add_child(inst)
		inst.self_modulate = tags[tag]
		inst.get_node('text').text = tag
	
	await get_tree().create_timer(0.01).timeout
	var i:int = 0
	while($text.get_child(0, true).visible and i < 350):
		if ($text.text != text): 
			anim = false
			return
		
		$text.get_child(0, true).modulate.a = 0.0
		$text.size += Vector2.ONE * 16.0
		$text.size.x = min($text.size.x, 256.0)
		
		self.global_transform.origin = get_global_mouse_position() + Vector2.RIGHT * 3.0
		self.position.y -= $text.size.y / 2.0
		
		$text/tags.size.x = min($text.size.x, 205)
		$bg.size = $text.size
		await get_tree().create_timer(0.001).timeout
		i += 1
	anim = false

func hideDesc() -> void:
	if (anim or !self.visible): return
	$text.text = ""
	var text = str($text.text)
	anim = true
	self.visible = true
	$bg.size = $text.size
	await get_tree().create_timer(0.01).timeout
	var i:int = 0
	while(i < 50):
		if (text != $text.text):
			anim = false 
			return
		$text.get_child(0, true).modulate.a = 0.0
		$text.size = lerp($text.size, Vector2.ZERO, 0.35)
		$bg.size = $text.size
		
		self.global_transform.origin = get_global_mouse_position() + Vector2.RIGHT * 3.0
		self.position.y -= $text.size.y / 2.0
		
		await get_tree().create_timer(0.01).timeout
		i += 1
	$text.text = ""
	self.visible = false
	anim = false
	set_process(false)

func _process(delta: float) -> void:
	if (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED or !self.visible): set_process(false)
	self.global_transform.origin = get_global_mouse_position() + Vector2.RIGHT * 3.0
	self.position.y -= $text.size.y / 2.0
