extends CharacterBody2D

var _play_ref = null
var SPEED = 20

func _physics_process(_delta: float) -> void:
	
	if _play_ref != null and not _play_ref.isdead:
		var _direction: Vector2 = global_position.direction_to(_play_ref.global_position)
		var _distance: float = global_position.distance_to(_play_ref.global_position)
		velocity = _direction * SPEED
		$AnimatedSprite2D.play("move")
		move_and_slide()
		if _distance < 15:
			_play_ref.die()
	else:
		$AnimatedSprite2D.play("idle")
		
	



func _on_detection_area_body_entered(_body:CharacterBody2D) -> void:
	if _body.is_in_group("character"):
		_play_ref = _body


func _on_detection_area_body_exited(_body:CharacterBody2D) -> void:
	if _body.is_in_group("character"):
		_play_ref = null
	pass # Replace with function body.
