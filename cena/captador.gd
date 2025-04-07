class_name Captador
extends Area2D

@export var cor: String = "verde";

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
signal pressionado
signal erro

func _ready() -> void:
	anim.play(cor)
	
func _process(delta) -> void:
	if Input.is_action_just_pressed(cor):
		anim.play(cor+"_pressionado")
		var area = self.get_overlapping_areas()
		if area.size() == 0:
			erro.emit(10);
			return
		
		pressionado.emit(self,area[0])
		
	if not Input.is_action_pressed(cor) and not anim.animation == cor:
		anim.play(cor)
