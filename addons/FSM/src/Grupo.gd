@tool
@icon("../utils/GROUP.png")
class_name Grupo
extends State

var states: Dictionary = {}

## Estado de inicio
@export var current_state : State

@export var LISTA_NOMBRE_ESTADOS : Dictionary

@export_storage var tamañoContenedor = Vector2.ZERO # guarda la posicion en el visor


func _ready():

	if Engine.is_editor_hint():
		child_order_changed.connect(_actualizar_lista_estado)
	else:
		# Hago la coneccion de los estados
		# para poder usar la funcion de cambio y seteo el estado de inicio 
		for child in get_children():
			if child is State:
				child.cambiarEstado.connect(cambiarEstadoEnGrupo)
				states[child.name] = child
		current_state.entrar()

func entrar_grupo() -> void:
	pass

func revisar_grupo() -> void:
	pass

func ejecutar_grupo() -> void:
	pass

func entrar() -> void:
	entrar_grupo()
	current_state.entrar()

func revisar() -> void:
	revisar_grupo()
	current_state.revisar()

func ejecutar() -> void:
	ejecutar_grupo()
	current_state.ejecutar()
 

# Maneja el cambio de estado
func cambiarEstadoEnGrupo(new_state_name: StringName) -> void:
	
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
		if estado is not State:
			continue
		LISTA_NOMBRE_ESTADOS[estado.name] = estado.name
