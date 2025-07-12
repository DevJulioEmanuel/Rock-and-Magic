extends CharacterBody2D

@export_category("Variables")
@export var _move_speed : float = 65.0
@export var _acceleration : float = 0.4
@export var _friction : float = 0.3
var ultima_tecla
var atacando=false
var isdead: bool = false

func _ready() -> void:
	$AnimatedSprite2D.play("parado_down")
	
func _physics_process(_delta: float) -> void:
	if isdead:
		return
	if atacando:
		if not $AnimatedSprite2D.is_playing():
			atacando = false
		move_and_slide()
		return
	_move()
	move_and_slide()

	if Input.is_action_just_pressed("action"):
		_action()
		
func die() -> void:
	if not isdead:
		$AnimatedSprite2D.play("death")
	isdead = true
		
func _action() -> void:
	atacando = true
	velocity.x = 0
	velocity.y = 0
	match ultima_tecla:
		"down":
			$AnimatedSprite2D.play("atack_down")
		"up":
			$AnimatedSprite2D.play("atack_up")
		"right":
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("atack_right")
		"left":
			$AnimatedSprite2D.flip_h = true
			$AnimatedSprite2D.play("atack_right")
			
		
func _move() -> void:
	var _direction: Vector2 = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	).normalized()

	if _direction != Vector2.ZERO:
		velocity.x = lerp(velocity.x, _direction.x * _move_speed, _acceleration)
		velocity.y = lerp(velocity.y, _direction.y * _move_speed, _acceleration)

		# Animação baseada na direção
		if _direction.x < 0:
			$AnimatedSprite2D.flip_h = true
			ultima_tecla = "left"
			$AnimatedSprite2D.play("left")	
		elif _direction.x > 0:
			$AnimatedSprite2D.flip_h = false
			ultima_tecla = "right"
			$AnimatedSprite2D.play("right")
		elif _direction.y < 0:
			$AnimatedSprite2D.play("up")
			ultima_tecla = "up"
		elif _direction.y > 0:
			$AnimatedSprite2D.play("down")
			ultima_tecla = "down"

	else:
		velocity.x = lerp(velocity.x, 0.0 , _friction)
		velocity.y = lerp(velocity.y, 0.0, _friction)
		if ultima_tecla == "left":
			$AnimatedSprite2D.flip_h = true
			$AnimatedSprite2D.play("parado_left")
		elif  ultima_tecla == "right":
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("parado_right")
		elif  ultima_tecla == "up":
			$AnimatedSprite2D.play("parado_up")
		elif  ultima_tecla == "down":
			$AnimatedSprite2D.play("parado_down")
