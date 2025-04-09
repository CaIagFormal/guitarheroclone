class_name Nota
extends Area2D

@export var cor: String;
@export var velocidade: float;
@export var targetx: float;
@export var gravando: bool;

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
signal fora_da_tela

func _ready() -> void:
	anim.play(cor)
	if gravando:
		anim.self_modulate.a = 0.75

func _process(delta) -> void:
	self.position.y += velocidade * delta;
	self.calcx()
	
	var scale;
	scale = (self.position.y)/400
	self.scale = Vector2(scale,scale);
	
	if self.position.y > 640:
		fora_da_tela.emit(100)
		set_process(false)
		queue_free()

func atingida() -> void:
	set_process(false)
	queue_free()

func calcx() -> void:
	self.position.x = ((self.position.y/600)*(self.targetx-640))+640
