class_name Captador
extends Area2D

@export var cor: String = "verde";
@export var gravando: bool = false;

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
signal pressionado
signal erro
signal gravar

func _ready() -> void:
	anim.play(cor)
	
func _process(delta) -> void:
	if Input.is_action_just_pressed(cor):
		anim.play(cor+"_pressionado")
		if gravando:
			gravar.emit(cor)
			return
		var area = self.get_overlapping_areas()
		if area.size() == 0:
			erro.emit(10);
			return
		
		pressionado.emit(self,area[0])
		
	if not Input.is_action_pressed(cor) and not anim.animation == cor:
		anim.play(cor)
