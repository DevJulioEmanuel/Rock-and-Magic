extends Camera2D

var shake_force = 0.0

func _process(delta):	
	if shake_force > 0:
		shake_force = lerp(shake_force, 0.0, 5.0 * delta)
		offset = Vector2(randf_range(-shake_force, shake_force), randf_range(-shake_force, shake_force))

func aplicar_shake(forca: float):
	shake_force = forca
