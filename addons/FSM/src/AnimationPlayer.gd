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
		animation_list_changed.connect(modificarEstados)
		return
		
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

# Maneja la generacion o eliminacion de nodos al crear o eliminar animaciones
func modificarEstados():
	if not Engine.is_editor_hint(): return
	
	var animaciones = get_animation_list()
	var nodosEstados = get_children()

	# se agrego una animacion
	if animaciones.size() > nodosEstados.size():
		for animacion in animaciones:
			var estadoNoExiste = true
			
			#reviso que ya no exista el nodo
			for estado in nodosEstados:
				if animacion == estado.name:
					estadoNoExiste = false
					break
					
			if estadoNoExiste:
				# creo el nodo y le coloco el nombre
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
		return
		
	# se elimino una animacion
	elif animaciones.size() < nodosEstados.size():
		
		for estado in nodosEstados:
			
			if not(estado is State):
				continue
				
			var animacionNoExiste = true
			for animacion in animaciones:
			
			#reviso que ya no exista el nodo
				if estado.name == animacion:
					animacionNoExiste = false
					break
			
			if animacionNoExiste:
				remove_child(estado)
		return
		
		
	# cambio el nombre una animacion
	elif animaciones.size() == nodosEstados.size():

		for i in range(nodosEstados.size()-1,-1,-1):
			if not(nodosEstados[i] is State):
				nodosEstados.pop_at(i)
				continue
				
			for j in range(animaciones.size()-1,-1,-1):
			
				if nodosEstados[i].name == animaciones[j]:
					nodosEstados.pop_at(i)
					animaciones.remove_at(j)
					break
		nodosEstados[0].name = animaciones[0]
		# actualizo el nombre del script
		var script = nodosEstados[0].get_script()
		script.resource_name = animaciones[0]
		script.reload() 
		nodosEstados[0].set_script(script)
		return

func conectoresPorAnimaciones():
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

