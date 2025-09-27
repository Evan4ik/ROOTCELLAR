extends Node

var brick = preload("res://scenes/brick.tscn")
var exitInst = preload("res://scenes/structures/exit.tscn")

var noise:FastNoiseLite = FastNoiseLite.new()
var r:RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	r.randomize()

func generate() ->void:
	destroy()
	
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.115
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 5.0
	
	var size:PackedInt32Array = [r.randi_range(24, 64), r.randi_range(32, 64)]
	#size = [15, 32]
	if (size[0] > 150): size[0] = 150
	if(size[1] > 150): size[1] = 150
	
	var cutOff:float = 0.05
	
	noise.seed = r.randf_range(-99900.0, 99900.0)
	
	var image = noise.get_image(size[0], size[1])
	var noise_texture = ImageTexture.create_from_image(image)
	
	var map:Array = []
	var spawnRegion:Array = [[int(round(size[1] / 2.0) - 1), int(round(size[1] / 2.0)), int(round(size[1] / 2.0) + 1)],  [int(round(size[0] / 2.0) - 1), int(round(size[0] / 2.0)), int(round(size[0] / 2.0) + 1)]]
	
	"""map = [
		[1,0,0,0,0,0,0,0],
		[0,0,1,1,1,1,1,1],
		[0,1,0,0,0,1,0,0],
		[1,0,0,0,0,0,0,0]
	]
	size = [8, 4]"""
	
	var groups = []
	var excludeTiles = [spawnRegion.duplicate()]
	
	for y in range(size[1]):  #generate map and groups
		map.append([])
		for x in range(size[0]):
			var height = noise.get_noise_2d(x,y)
			var edge = (y == 0 or y == size[1] - 1) or (x == 0 or x == size[0] - 1)
			var almostEdge = ((y == 1 or y == size[1] - 2) or (x == 1 or x == size[0] - 2)) and r.randi_range(0, 100) > 70
			var ceilingTile =  (height < cutOff) and !edge and !almostEdge 
			
			for eTile in excludeTiles:
				if !(eTile[0].has(y) and eTile[1].has(x)): continue
				ceilingTile = true
				break
			
			map[y].append(0 if (ceilingTile) else 1)
			if (!ceilingTile) or (x <= 1 or x >= size[0] - 2) or (y <= 1 or y >= size[1] - 2): continue
			
			var tile:Array = [x, y]
			
			var idx = -1
			var i:int = 0
			for group in groups:
				i += 1
				
				var hasSelf = !group.has(tile)
				var hasNeighbour1 = !group.has([x + 1, y])
				var hasNeighbour2 = !group.has([x - 1, y])
				var hasNeighbour3 = !group.has([x, y - 1])
				var hasNeighbour4 = !group.has([x, y + 1])
				
				if (hasSelf and hasNeighbour1 and hasNeighbour2 and hasNeighbour3 and hasNeighbour4 ): continue
				idx = i - 1
				break
			if (idx < 0): 
				idx = groups.size()
				groups.append([])
				groups[idx].append(tile)
				await get_tree().create_timer(0.01).timeout
			var neighbours = getNeighbours(tile, [size[0], size[1]], noise, cutOff, groups[idx], excludeTiles)
			groups[idx].append_array(neighbours)
			
	#merge groups with duplicate elements
	
	var i:int = 0
	while(i < groups.size()):
		var cGroup = groups[i]
		for tile in cGroup:
			var matchGroup
			for group in groups:
				if (group == cGroup): continue
				if !(group.has(tile)): continue
				matchGroup = group
				break
			if (matchGroup == null): continue
			print("found match")
			cGroup.append_array(matchGroup)
			groups.erase(matchGroup)
			groups[i] = cGroup
			i -= 1
			break
		i += 1
	
	
	
	print("all groups:" + str(groups.size()))
	
	groups.sort_custom(sizeSort)
	for group in groups: print(group.size())

	
	var connectedGroups:PackedInt32Array = []
	
	if (groups.size() > 1):#create bridges
		i = 1
		while(i < groups.size()):
			var connectTo = groups[i]
			if (connectTo.size() < 260):
				i += 1 
				continue
			
			var start = connectTo[r.randi_range(0, connectTo.size() - 1)]
			
			var xHit = boreInDirection(start, map, connectTo, 0, -1, groups)
			var xHit2 = boreInDirection(start, map, connectTo, 0, 1, groups)
			var yHit =  boreInDirection(start, map, connectTo, 1, 1, groups)
			var yHit2 = boreInDirection(start, map, connectTo, 1, -1, groups)
			
			var hitsA = [xHit, xHit2, yHit, yHit2]
			
			var order = [0, 1, 2, 3]
			var hitDir = [Vector2(0, -1), Vector2(0, 1), Vector2(1, 1), Vector2(1, -1)]
			order.shuffle()
			var j:int = 0
			
			while(j < order.size()):
				var h = order[j]
				if(hitsA[h][0] >= 0) and (hitsA[h][1] == 0 or !connectedGroups.has(hitsA[h][1])): 
					map = boreDirection(start, map, hitDir[h].x, hitDir[h].y, hitsA[h][0])
					connectedGroups.append(hitsA[h][1])
				j += 1
			i += 1
	var startIndeces = []
	for idx in groups: startIndeces.append(groups.find(idx))
	var startIndex = startIndeces[r.randi_range(0, startIndeces.size() - 1)]
	while(groups[startIndex].size() < 2):
		startIndeces.erase(startIndex)
		startIndex = startIndeces[r.randi_range(0, startIndeces.size() - 1)]
	var gEx = groups[startIndex].duplicate()
	var exit = gEx[r.randi_range(0, gEx.size() - 1)]
	
	while(exit[0] <= 2 or exit[0] >= size[0] - 2) or (exit[1] <= 2 or exit[1] >= size[1] - 2):
		gEx.erase(exit)
		if (gEx.size() < 1):
			startIndeces.erase(startIndex)
			startIndex = startIndeces[r.randi_range(0, startIndeces.size() - 1)]
			gEx = groups[startIndex].duplicate()
		exit = gEx[r.randi_range(0, gEx.size() - 1)]
	
	print(exit)
	
	
	for y in range(size[1]):
		for x in range(size[0]):
			
			if (y == round(size[1] / 2) and x == round(size[0] / 2)): 
				get_node("../player").position = Vector3(x, 2.0, y)
				get_node("../ui/map/viewport/mapcam").global_transform.origin = get_node("../player").position + (Vector3.UP * 15.0)
			
			if (exit[0] == x and exit[1] == y):
				var eInst = exitInst.instantiate()
				self.add_child(eInst)
				
				eInst.position = Vector3(x, -0.68, y)
				continue
			
			
			if (map[y][x] == 0): continue
			
			var inst = brick.instantiate()
			self.add_child(inst)
			
			var tileHigh = 0.0
			
			inst.position = Vector3(x, tileHigh, y)
			inst.scale.y = 3.0
	
			
			#await get_tree().create_timer(0.01).timeout
	
func destroy() ->void: for child in self.get_children(): child.queue_free()

func getNeighbours(tile:Array , map:Array, noiseMap, cutOff:float, allNeighbours:Array, excludeTiles:Array) -> Array:
	
	tile = tile.duplicate()
	var neighbours:Array = [].duplicate()
	var x = tile[0]
	var y = tile[1]
	
	
	if (x > 1 and !allNeighbours.has([x -1, y]) and (noise.get_noise_2d(x - 1,y) < cutOff or excludeTileCheck([x -1, y], excludeTiles)) )  : neighbours.append([x -1, y])
	if (x < map[0] - 1 and !allNeighbours.has([x + 1, y]) and (noise.get_noise_2d(x + 1,y) < cutOff or excludeTileCheck([x +1, y], excludeTiles)) ): neighbours.append([x + 1, y])
	if (y > 1 and !allNeighbours.has([x, y - 1]) and (noise.get_noise_2d(x,y - 1) < cutOff or excludeTileCheck([x, y - 1], excludeTiles)) ): neighbours.append([x, y - 1])
	if (y < map[1] - 1 and !allNeighbours.has([x, y + 1]) and (noise.get_noise_2d(x,y + 1) < cutOff or excludeTileCheck([x, y + 1], excludeTiles)) ): neighbours.append([x, y + 1])
	
	return neighbours

func excludeTileCheck(tile:Array, excludeTiles:Array):
	var x = tile[0]
	var y= tile[1]
	
	for eTile in excludeTiles:
		if !(eTile[0].has(y) and eTile[1].has(x)): continue
		return true
	return false

func boreInDirection(tile:Array, map:Array, group:Array, direction:int, mult:int = 1, allGroups:Array = []) -> Array:
	var tTile = tile.duplicate(true)
	var isHit:int = -1
	var hitGroup = []
	
	var lastTile = [-1, -1]
	
	while( (tTile[direction] > 2) if (mult < 0) else (tTile[direction] < (map[0].size() if (direction == 0) else map.size() )  - 2)  ):
		var y = tTile[1]
		var x = tTile[0]
		if (map[y][x] == 0 and !group.has(tTile)):
			var tileH = [x, y]
			for hGroup in allGroups:
				if !(hGroup.has(tileH)): continue
				hitGroup = hGroup
			if (hitGroup.size() > 2): 
				isHit = tTile[direction]
				break
				
		lastTile = tTile.duplicate()
		tTile[direction] += mult
		
		if (tTile == lastTile): break
	return [isHit, allGroups.find(hitGroup)]

func boreDirection(tile:Array, map:Array, direction:int, mult:int = 1, limit:int = 0) -> Array:
	var tTile = tile.duplicate(true)
	var newMap:Array = map.duplicate()
	
	var oppositeDir = 0 if (direction == 1) else 1
	var lastTile = [-1, -1]
	
	while( (tTile[direction] > 1) if (mult < 0) else (tTile[direction] < (map[0].size() if (direction == 0) else map.size() )  - 2)  ):
		var y = tTile[1]
		var x = tTile[0]
		newMap[y][x] = 0
		if (r.randi_range(0, 100) > 50 and y > 1 and y < map.size() - 2 and x > 1 and x < map[0].size() - 2): newMap[ (y + r.randi_range(-1, 1)) if (oppositeDir == 1) else y][(x + r.randi_range(-1, 1)) if (oppositeDir == 0) else x] = 0
		if (tTile[direction] == limit): break
		
		lastTile = tTile.duplicate()
		tTile[direction] += mult
		
	return newMap

func sizeSort(a, b) -> bool:
	if a.size() > b.size():
		return true
	return false
