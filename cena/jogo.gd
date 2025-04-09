extends Node2D

@onready var captadores: Array[Captador] = [$c_verde,$c_vermelho,$c_amarelo,$c_azul,$c_laranja]
@export var cena_de_acerto: PackedScene
@export var cena_de_nota: PackedScene
@export var cena_de_barra: PackedScene
@onready var sfx_erro: AudioStreamPlayer = $erro

var pontos: int = 0
var vida: float = 3.0
var velocidade: float = 400.0
var combo: int = 0
@onready var txt_pontos: Label = $pontos
@onready var txt_desvio: Label = $desvio
@onready var txt_combo: Combo = $combo
@onready var rock: Rock = $rock
@onready var prox_nota: Timer = $prox_nota
@onready var musica: AudioStreamPlayer = $musica

var cores: Array[String] = ["verde","vermelho","amarelo","azul","laranja"]
var chart: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://musica/chart.json"))
var c_index: int = 0
var no_delay_inicial: bool = true;

@export var gravando: bool = false;
var ultimo_ms: int = Time.get_ticks_msec();
var chart_rec: Dictionary

const sfx_erro_lista = [preload("res://sfx/GP_Bad_Note_1.wav"),
						preload("res://sfx/GP_Bad_Note_2.wav"),
						preload("res://sfx/GP_Bad_Note_3.wav"),
						preload("res://sfx/GP_Bad_Note_4.wav"),
						preload("res://sfx/GP_Bad_Note_5.wav"),
						preload("res://sfx/GP_Bad_Note_6.wav")]

func _ready() -> void:
	
	var barra: Barra
	var batidas_tela: float = 640/velocidade*chart["bpm"]/60
	var limite: float = 640+640/batidas_tela
	
	no_delay_inicial = true;
	prox_nota.start(1)
	
	for i in range(floor(batidas_tela)+1):
		barra = cena_de_barra.instantiate()
		barra.position = Vector2(640,i*640/batidas_tela)
		barra.velocidade = velocidade
		barra.limite = limite
		add_child(barra)
		
	if gravando:
		chart_rec = {"bpm":160,"notas":[]};
		chart_rec["notas"] = []
		for captador in captadores:
			captador.gravando = true;
			captador.gravar.connect(gravar)
		return
	for captador in captadores:
		captador.gravando = false
		captador.pressionado.connect(acerto)
		captador.erro.connect(erro)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("gravando_saida"):
		print(chart_rec)

func crianota(cor,velocidade):
	var nota: Nota = cena_de_nota.instantiate()
	nota.cor = cor
	nota.targetx = captadores[cores.find(cor)].position.x
	nota.calcx()
	nota.position.y = 0
	nota.velocidade = velocidade
	nota.gravando = gravando
	if not gravando:
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
	
	var diff: int = captador.position.y - nota.position.y
	
	var pts
	if abs(diff)<50:
		var qtd = (50-abs(diff))/20
		pts = (qtd*qtd)+80
	else:
		pts = 80
	txt_desvio.text = str(diff/velocidade*1000)+"ms "+str(pts)+"pts"
	mudarpontos(pts)

func erro(deduc: int):
	sfx_erro.stream = sfx_erro_lista[randi_range(0,5)]
	sfx_erro.play()
	txt_desvio.text = "... "+str(deduc)+"pts"
	mudarpontos(-deduc)

func mudarpontos(qtd: int):
	pontos += qtd
	var sign: int = abs(qtd)/qtd
	if sign == 1:
		vida += 1
		combo += 1
	elif vida < 1:
		vida -= 0.1
	elif qtd < 100:
		vida -= 0.25
	else:
		vida -= 0.5
		
	if sign == -1:
		combo = 0
	if vida>6:
		vida = 6
	elif vida<0:
		game_over()
		return
		
	if pontos < 0:
		pontos = 0
	txt_pontos.text = str(pontos).pad_zeros(5)
	txt_combo.text = str(combo)+"x Combo"
	txt_combo.setcombo(combo)
	rock.medidor(str(int(round(vida))))

func game_over():
	musica.stop()
	prox_nota.stop()
	for child in get_children():
		child.set_process(false)
	
func _on_timer_timeout() -> void:
	if no_delay_inicial==true:
		no_delay_inicial = false
		musica.play()
		ultimo_ms = Time.get_ticks_msec(); # apenas usado em gravacao
		prox_nota.start(chart["notas"][c_index][1]-600/velocidade)
		return
	
	if c_index==chart["notas"].size():
		#game_over()
		return
		
	crianota(cores[int(chart["notas"][c_index][0])],velocidade)
	if chart["notas"][c_index][1] == 0: # dupla/tripla
		c_index+=1;
		_on_timer_timeout()
		return
	c_index+=1;
	
	if c_index==chart["notas"].size():
		prox_nota.start(5)
		return
		
	prox_nota.start(chart["notas"][c_index][1])

func gravar(cor: String) -> void:
	chart_rec["notas"].append([cores.find(cor),(float((Time.get_ticks_msec()-ultimo_ms)/10)/100)])
	ultimo_ms = Time.get_ticks_msec();
