class_name Rock
extends Sprite2D

@onready var barra: AnimatedSprite2D = $barra

func medidor(vida: String):
	barra.play(vida)
