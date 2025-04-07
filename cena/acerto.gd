extends AnimatedSprite2D
	
func _on_animation_finished() -> void:
	set_process(false)
	queue_free()
