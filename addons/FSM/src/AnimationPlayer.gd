@tool
@icon("../utils/FSM.png")
# clase de animation Player modificada para usarla de FSM
class_name FSM
extends AnimationPlayer

var states: Dictionary = {}

@export var current_state : State
@onready var player: CharacterBody2D = owner

func _ready():
	if Engine.is_editor_hint():
		
		# si no esta creada la libreria, la creo (esto es cuando creo el nodo,
		# la libreria de animaciones no se crea hasta crear una animacion, por lo que 
		#  tiraba error
		if not has_animation_library(""):
			add_animation_library("", AnimationLibrary.new())

		var libreriaAnimaciones = get_animation_library("")
		
		# conecto la libreria con las funciones que modificaran los nodos Stados
		libreriaAnimaciones.animation_added.connect(agregar_estado)
		libreriaAnimaciones.animation_removed.connect(eliminar_estado)
		libreriaAnimaciones.animation_renamed.connect(renombrar_estado)
		
		# para mostrar scrip cuando modifico las animaciones
		libreriaAnimaciones.animation_changed.connect(mostrarScript)
		# animation_list_changed.connect(modificarEstados)
		return
		
	# esto es para el funcionamiento del FSM ingame, ago la coneccion de los estados
	# para poder usar la funcion de cambio y seteo el estado de inicio 
	for child in get_children():
		if child is State:
			child.cambiarEstado.connect(cambiarEstado)
			child.player = player
			states[child.name] = child
	
	current_state.entrar()
	play(current_state.name)

func _physics_process(_delta):
	if Engine.is_editor_hint(): return
		
	# reviso si tengo que cambiar de estado
	current_state.revisar()
	# ejecuto el estado
	current_state.ejecutar()

	player.move_and_slide()

# Maneja el cambio de estado
func cambiarEstado(new_state_name: StringName) -> void:
	if Engine.is_editor_hint(): return
	
	var new_state : State = states.get(new_state_name)
	if new_state != null and new_state != current_state:
		# ejecuto la salida
		current_state.salir()
		# cambio de estado
		current_state = new_state
		# ejecuto la entrada
		new_state.entrar()
		play(new_state_name) # ejecuto la animacion
		
	else:
		push_warning("El estado no existe o es el que ya se encuentra")


#################################################
# Funciones para la creacion del FSM y su visor #
#################################################

# Crea el Nodo Estado (State) cuando se crea una animacion 
func agregar_estado(animacion : StringName) -> void:
	# salteo el RESET
	if (animacion == "RESET"):
		return
	
	var nuevoNodo = Node.new()
	nuevoNodo.name =  animacion
	# le cargo el scrip para el FSM
	var script = GDScript.new()
	script.source_code = "extends State"
	script.resource_name = animacion
	script.reload() 
	nuevoNodo.set_script(script)
	# agrego el nodo y le seteo el owner para que aparesca
	add_child(nuevoNodo)
	nuevoNodo.set_owner(get_tree().get_edited_scene_root())

# Elimino el Nodo Estado (State) cuando se elimina una animacion
func eliminar_estado(animacion : StringName) -> void:
	
	remove_child(get_node(str(animacion)))

# cambio el nombre del Nodo Estado (State) cuando se cambia el nombre de una animacion
func renombrar_estado(nombreAnimacion: StringName, 
nuevoNombreAnimacion: StringName) -> void:
	
	var nodoEstado = get_node(str(nombreAnimacion))
	nodoEstado.name = nuevoNombreAnimacion
	# actualizo el nombre del script
	var script = nodoEstado.get_script()
	script.resource_name = nuevoNombreAnimacion
	script.reload() 
	nodoEstado.set_script(script)

# pasa los conectores que sean por animacion
func conectoresPorAnimaciones()-> Array:
	
	var listaConectores = []
	var animaciones = get_animation_list()
	for nombreAnimacion in animaciones:
		
		var animacion : Animation = get_animation(nombreAnimacion)
		var track_idx = animacion.find_track(name + ":",Animation.TYPE_METHOD)
		# verifijo que haya pista, y que la misma llame al metodo cambiarEstado
		if (track_idx != -1 
		and animacion.method_track_get_name(track_idx,0) == "cambiarEstado") :
			listaConectores.append([
				nombreAnimacion, # en donde estoy
				animacion.method_track_get_params(track_idx,0)[0], # a donde voy
				animacion.track_get_key_time(track_idx,0) # condicion de salida (tiempo)
			])
	return listaConectores

# para que seleccione y muestre automaticamente el scrip del estado que modifico
func mostrarScript(animacion : StringName) -> void:
	
	# salteando el reset
	if str(animacion) == "RESET":
		return
	
	var scriptEstado : Script = get_node(str(animacion)).get_script()
	EditorInterface.edit_script(scriptEstado)
