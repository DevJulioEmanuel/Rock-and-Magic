extends CharacterBody2D
class_name npc_clover

const DIALOG_SCREEN: PackedScene = preload("res://Scenes/Controls/dialog_screen.tscn")

var dialog_data: Dictionary = {
	0: {
		"title": "Clover",
		"dialog": "Olá Luis!",
		"faceset": "res://Assets/Sprites/NPCS/Clover/faceset.png"
	},
	1: {
		"title": "Clover",
		"dialog": "Eu estava vindo para minha casa e vi um monstro no caminho",
		"faceset": "res://Assets/Sprites/NPCS/Clover/faceset.png"
	},
	2: {
		"title": "Clover",
		"dialog": "Ele é verde, e gosmento. Estddddddddddddddddddddddddddddddsaava indo em direção a sua casa.",
		"faceset": "res://Assets/Sprites/NPCS/Clover/faceset.png"
	},
	3: {
		"title": "Clover",
		"dialog": "Sei que você é corajoso, por isso te darei essa espada que meu pai tem. Vai lá verificar e depois me fala comigo.",
		"faceset": "res://Assets/Sprites/NPCS/Clover/faceset.png"
	},
}

@export_category("Objects")
@export var hud: CanvasLayer = null
func _ready() -> void:
	$DialogInteragir.hide()
	
func _process(delta: float) -> void:
	dialog()

func dialog() -> void:
	if Input.is_action_just_pressed("Interagir") and global.player_in_npc==true:
		if MissionManager.missions["mission_1"].status == "active":
			MissionManager.complete_mission("mission_1")

		if hud.get_node_or_null("DialogScreen") == null:
			var new_dialog: DialogScreen = DIALOG_SCREEN.instantiate()
			new_dialog.name = "DialogScreen" 
			new_dialog.data = dialog_data
			hud.add_child(new_dialog)

func ativarLabel() -> void:
	$DialogInteragir.show()
	global.player_in_npc = true
	
func desativarLabel() -> void:
	$DialogInteragir.hide()
	global.player_in_npc = false
	
