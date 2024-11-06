# clase de para definir los ciclos
@icon("../utils/CICLO.png")
class_name Ciclo
extends Node

var states: Dictionary = {}

@export var current_state : State
@export var animaciones : AnimationPlayer

@onready var player: CharacterBody2D = owner

func _ready():

		# Hago la coneccion de los estados
		# para poder usar la funcion de cambio y seteo el estado de inicio 
	for child in get_children():
		if child is State:
			child.cambiarEstado.connect(cambiarEstado)
			child.player = player
			states[child.name] = child
	
	current_state.entrar()

func ejecutar():
	# reviso si tengo que cambiar de estado
	current_state.revisar()
	# ejecuto el estado
	current_state.ejecutar()

# Maneja el cambio de estado
func cambiarEstado(new_state_name: StringName) -> void:
	
	var new_state : State = states.get(new_state_name)
	if new_state != null and new_state != current_state:
		# ejecuto la salida
		current_state.salir()
		# cambio de estado
		current_state = new_state
		# ejecuto la entrada
		new_state.entrar()
		
	else:
		push_warning("El estado no existe o es el que ya se encuentra")
