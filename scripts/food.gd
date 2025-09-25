class_name Food
extends Node


enum foodCategories { FOOD_NONE, FOOD_BAKED, FOOD_NATURAL, FOOD_MEAT, FOOD_DAIRY, FOOD_SWEET, FOOD_SNACK, FOOD_LIQUID }


@export_category("Params") 
@export var foodName:String = ""
@export_multiline var foodDescription:String = ""
@export var descriptionMods:Dictionary[String, String] = {}
@export var foodCategory = foodCategories.FOOD_NONE
@export var rarity:int = 0
@export_category("Effects") 

@export var modifiers:PackedStringArray = []
@export var passiveAmt:float = 1.0
@export_multiline var passiveDesc:String = ""

@export var activeAmt:float = 1.0
@export_multiline var activeDesc:String = ""

@export var pMultiplier:float = 1.0
@export var aMultiplier:float = 1.0

@onready var description = get_tree().get_first_node_in_group("descriptionman")
@onready var player = get_tree().get_first_node_in_group("player")


var usedPassive:bool = false

func _ready() -> void: 
	set_process(false)
	if (get_node_or_null("mesh") == null): return
	$mesh.visible = true
	for child in $mesh.get_children(): child.visible = child.name == "default"

func getDisplayNumbers():
	var ret:Array = [ passiveAmt, activeAmt]
	return addMultColors(ret)

func addMultColors(ret):
	var pColor = "#ffffff"
	if (pMultiplier < 1): pColor = "#842E2E"
	elif(pMultiplier > 1): pColor = "#70FFA9"
	
	ret[0] = "[color=%s]%s[/color]" % [pColor, ret[0]]
	
	var aColor = "#ffffff"
	if (pMultiplier < 1): aColor = "#842E2E"
	elif(pMultiplier > 1): aColor = "#70FFA9"
	
	ret[1] = "[color=%s]%s[/color]" % [aColor, ret[1]]
	
	return ret

func getDescription() -> Array:
	var descStr = ""
	
	var rarityColor:Dictionary[int, String] = {0: "#FFFFFF", 1: "#88FF9B", 2: "#DA8A3B", 3: "#DB60E1"}
	descStr += "[center][font_size=32px][color=%s]%s[/color][/font_size]\n" % [rarityColor[rarity], foodName]
	
	var catColors:Dictionary = {foodCategories.FOOD_BAKED: "#ffba3e", foodCategories.FOOD_MEAT: "#B50000", foodCategories.FOOD_NATURAL: "#6dff7c", 
	foodCategories.FOOD_DAIRY: "#fff59e", foodCategories.FOOD_SWEET: "#ff79ec", foodCategories.FOOD_SNACK: "#ff6c36", foodCategories.FOOD_LIQUID: "#88C0FF"}
	var catNames:Dictionary = {foodCategories.FOOD_BAKED: "Baked", foodCategories.FOOD_MEAT: "Meaty", foodCategories.FOOD_NATURAL: "Natural", 
	foodCategories.FOOD_DAIRY: "Dairy", foodCategories.FOOD_SWEET: "Sweet", foodCategories.FOOD_SNACK: "Snack",  foodCategories.FOOD_LIQUID: "Liquid"}
	
	var tags:Dictionary[String, String] = {}
	tags[catNames[foodCategory]] = catColors[foodCategory]
	
	var lineAmount = ceil(tags.size() / 2.0) + 1
	var i = 0
	while(i < lineAmount):
		descStr += "\n"
		i += 1
		
	var displayStats = getDisplayNumbers()
	
	var passive = passiveDesc
	if ("%s" in passive): passive = passiveDesc % displayStats[0]
	
	var active = activeDesc
	if ("%s" in active): active = activeDesc % displayStats[1]
	
	if(passive != ""): descStr += "[bgcolor=#5050DF99]Held Effect:[/bgcolor]\n%s\n" % passive
	else: descStr += "\n"
	if(active != ""):descStr += "[bgcolor=#DF505099]Consumed Effect:[/bgcolor]\n%s\n\n" % active
	else: descStr += "\n"
	
	descStr += foodDescription
	
	return [descStr, tags]

func togglePassive(setOn:bool = !is_processing()):
	if (usedPassive): return
	set_process(setOn)

func _active(): pass
