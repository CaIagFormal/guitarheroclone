extends Node2D

@onready var captadores: Array[Captador] = [$c_verde,$c_vermelho,$c_amarelo,$c_azul,$c_laranja]
@export var cena_de_acerto: PackedScene
@export var cena_de_nota: PackedScene
@onready var sfx_erro: AudioStreamPlayer = $erro

var pontos: int = 0
var vida: float = 3.0
@onready var txt_pontos: Label = $pontos
@onready var rock: Rock = $rock
@onready var timer: Timer = $timer
@onready var musica: AudioStreamPlayer = $musica

var cores: Array[String] = ["verde","vermelho","amarelo","azul","laranja"]

const sfx_erro_lista = [preload("res://sfx/GP_Bad_Note_1.wav"),
						preload("res://sfx/GP_Bad_Note_2.wav"),
						preload("res://sfx/GP_Bad_Note_3.wav"),
						preload("res://sfx/GP_Bad_Note_4.wav"),
						preload("res://sfx/GP_Bad_Note_5.wav"),
						preload("res://sfx/GP_Bad_Note_6.wav")]

func _ready() -> void:
	for captador in captadores:
		captador.pressionado.connect(acerto)
		captador.erro.connect(erro)
	timer.start();

func crianota(cor,velocidade):
	var nota: Nota = cena_de_nota.instantiate()
	nota.cor = cor
	nota.targetx = captadores[cores.find(cor)].position.x
	nota.calcx()
	nota.position.y = 0
	nota.velocidade = velocidade
	nota.fora_da_tela.connect(erro)
	add_child(nota)
	return nota

func acerto(captador: Captador,nota: Nota):
	if not nota.cor == captador.cor:
		return
	nota.atingida()
	
	var acerto: AnimatedSprite2D = cena_de_acerto.instantiate()
	acerto.position = captador.position
	acerto.position.y -= 45
	add_child(acerto)
	acerto.play("default")
	
	mudarpontos(100)

func erro(deduc: int):
	sfx_erro.stream = sfx_erro_lista[randi_range(0,5)]
	sfx_erro.play()
	mudarpontos(-deduc)

func mudarpontos(qtd: int):
	pontos += qtd
	var sign: int = abs(qtd)/qtd
	if sign == 1:
		vida += 1
	elif vida < 1:
		vida -= 0.1
	elif qtd < 100:
		vida -= 0.25
	else:
		vida -= 0.5
	
	if vida>6:
		vida = 6
	elif vida<0:
		game_over()
		return
		
	if pontos < 0:
		pontos = 0
	txt_pontos.text = str(pontos).pad_zeros(5)
	
	rock.medidor(str(int(round(vida))))

func game_over():
	musica.stop()
	timer.stop()
	for child in get_children():
		child.set_process(false)
	set_process(true)
	
func _on_timer_timeout() -> void:
	for a in range(randi_range(1,3)):
		crianota(cores[randi_range(0,4)],200.0)
	timer.start(randf_range(0,1))
