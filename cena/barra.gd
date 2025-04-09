class_name Barra
extends Sprite2D

@export var velocidade: float;
@export var limite: float
func _process(delta) -> void:
	self.position.y = fmod(self.position.y+velocidade * delta,limite);
	
	var scale;
	scale = (self.position.y)/400
	self.scale = Vector2(scale,scale);
