extends Control
class_name DialogScreen

var step: float = 0.03
var id: int = 0
var data: Dictionary = {}
var boolDialog = true
@export_category("Objects")
@export var _name: Label = null
@export var dialog: RichTextLabel = null
@export var faceset: TextureRect = null

func _ready() -> void:
	global.dialog_active = true
	initialize_dialog()

func _process(_delta: float) -> void:
	if Input.is_action_pressed("ui_accept") and dialog.visible_ratio<1:
		step = 0.01
		return
	if Input.is_action_just_pressed("Interagir"):
		id += 1
		if id == data.size():
			queue_free()
			global.dialog_active = false
			return
		initialize_dialog() 

func initialize_dialog() -> void:
	_name.text = data[id]["title"]
	dialog.text = data[id]["dialog"]
	faceset.texture = load(data[id]["faceset"])
	dialog.visible_characters = 0
	while dialog.visible_ratio < 1:
		await get_tree().create_timer(step).timeout
		dialog.visible_characters += 1
