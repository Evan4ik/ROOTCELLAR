extends WalkerE

func _doPattern() -> void:
	if (targets.size() < 1):
		var i = 0
		
		if ($mesh/stem.visible):
			$anim.stop() 
			$anim.play("digin")
		
		while(i < 180 and targets.size() < 1):
			self.rotation_degrees.y += 2.0
			i += 1
			await get_tree().create_timer(0.01).timeout
		self.rotation_degrees.y = 0.0
	if (targets.size() >= 1):
		while(anim): await get_tree().create_timer(0.05).timeout
		if (chase == null): chase = targets[0]
		$anim.play("walk")
		var i = 0
		while(i < 500 and !anim):
			if (self.global_position.distance_to(chase.global_position) > maxDistance):
				targets.erase(chase)
				chase = null
				break
			
			var oldRot = self.rotation_degrees
			
			self.look_at(chase.global_transform.origin, Vector3.UP)
			var targetRot = self.rotation_degrees
			targetRot.y += 180
			targetRot *= Vector3(0, 1.0, 0.0)
			self.rotation_degrees = oldRot
			
			$mesh/head.look_at(chase.global_transform.origin, Vector3.UP)
			$mesh/head.rotation_degrees.y += 180
			
			self.rotation_degrees.y = rad_to_deg(lerp_angle(deg_to_rad(self.rotation_degrees.y), deg_to_rad(targetRot.y), 0.025))
			
			var targetPos = ($target.global_transform.origin - self.global_transform.origin).normalized() * speed
			var dif = int(abs(oldRot.y - targetRot.y)) % 360
			
			if (dif > 150 and dif < 300): targetPos *= 0.01
			
			velocity = targetPos
			move_and_slide()
			i += 1
			await get_tree().create_timer(0.01).timeout
	await get_tree().create_timer(0.01).timeout
	if (hp <= 0): return
	_doPattern()
