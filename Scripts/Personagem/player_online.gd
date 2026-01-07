extends CharacterBody2D

var target_position := Vector2.ZERO
var speed_interpolation = 15.0
var meu_id_rede = 0
var is_attacking = false

@onready var sfx_ataque = $"SfxHit-Ar"
@onready var sfx_hit = $"SfxHit-Corpo"


func _ready():
	target_position = global_position
	$AnimatedSprite2D.animation_finished.connect(_on_animation_finished)


func setup_inicial(pos_x, pos_y):
	global_position = Vector2(pos_x, pos_y)
	target_position = Vector2(pos_x, pos_y)

func mover_para(novo_x, novo_y, anim_nome, flip):
	target_position = Vector2(novo_x, novo_y)
	
	if is_attacking:
		return 

	if $AnimatedSprite2D.animation != anim_nome:
		$AnimatedSprite2D.play(anim_nome)

	if not is_attacking:
		$AnimatedSprite2D.flip_h = flip

func atacar(dir):
	is_attacking = true 
	sfx_ataque.pitch_scale = randf_range(0.9, 1.1)
	sfx_ataque.play()
	
	if dir == "down":
		$AnimatedSprite2D.play("atack_down")
	elif dir == "up":
		$AnimatedSprite2D.play("atack_up")
	elif dir == "right":
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.play("atack_right")
	elif dir == "left":
		$AnimatedSprite2D.flip_h = true 
		$AnimatedSprite2D.play("atack_right")

func aplicar_knockback(direcao: Vector2):
	sfx_hit.pitch_scale = randf_range(1.0, 1.2)
	sfx_hit.play()
	spawnar_sangue()
	modulate = Color.RED
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)


func _on_animation_finished():
	if "atack" in $AnimatedSprite2D.animation:
		is_attacking = false
		$AnimatedSprite2D.play("idle") 

func morrer():
	$AnimatedSprite2D.play("death")
	await get_tree().create_timer(2.0).timeout
	queue_free() 

func set_nome(novo_nome):
	$NomeLabel.text = novo_nome 
	
func spawnar_sangue():
	var sangue = CPUParticles2D.new()

	sangue.amount = 18
	sangue.one_shot = true
	sangue.explosiveness = 0.5
	sangue.lifetime = 0.3
	sangue.z_index = 100 

	sangue.direction = Vector2(0, 0)
	sangue.spread = 180.0
	sangue.gravity = Vector2(0, 0) 
	sangue.initial_velocity_min = 100.0
	sangue.initial_velocity_max = 200.0

	sangue.scale_amount_min = 2.0 
	sangue.scale_amount_max = 2.0
	sangue.color = Color(1, 0, 0, 1)
	
	sangue.global_position = global_position

	get_tree().root.add_child(sangue)
	sangue.emitting = true
	sangue.finished.connect(sangue.queue_free)
	
func animar_cura():
	modulate = Color(1.5, 1.5, 0, 1)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.4)
	print("on_jogador_pintou")

func _process(delta):
	global_position = global_position.lerp(target_position, delta * speed_interpolation)
