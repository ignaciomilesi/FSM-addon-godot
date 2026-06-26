@tool
# clase de para definir los ciclos
@icon("../utils/CICLO.png")
class_name Ciclo
extends Node

var states: Dictionary = {}

@export_category("Estados")
## Estado en ejecucion
@export var current_state : State

@export var LISTA_NOMBRE_ESTADOS : Dictionary

@export_category("Animaciones")
## Nodo con las animaciones del estado
@export var animaciones : AnimationPlayer:
	set(valor):
		if valor == null :
			LISTA_NOMBRE_ANIMACIONES.clear()
			animaciones.animation_list_changed.disconnect(_actualizar_lista_de_animaciones)
			animaciones = null
		else:
			animaciones = valor
			var lista = animaciones.get_animation_list()
			for ani in lista:
				LISTA_NOMBRE_ANIMACIONES[ani]=ani
			animaciones.animation_list_changed.connect(_actualizar_lista_de_animaciones)
			

func _actualizar_lista_de_animaciones() -> void:
	LISTA_NOMBRE_ANIMACIONES.clear()
	var lista = animaciones.get_animation_list()
	for ani in lista:
		LISTA_NOMBRE_ANIMACIONES[ani]=ani

@export var LISTA_NOMBRE_ANIMACIONES : Dictionary

@onready var player: CharacterBody2D = owner

func _ready():

	if Engine.is_editor_hint():
		child_order_changed.connect(_actualizar_lista_estado)
	else:
		# Hago la coneccion de los estados
		# para poder usar la funcion de cambio y seteo el estado de inicio 
		for child in get_children():
			if child is State:
				child.cambiarEstado.connect(cambiarEstado)
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


func _actualizar_lista_estado() -> void:
	
	var estados : Array[Node] = get_children()
	
	LISTA_NOMBRE_ESTADOS.clear()
	
	for estado in estados:
		if estado is not State and estado is not Grupo:
			continue
		LISTA_NOMBRE_ESTADOS[estado.name] = estado.name
