@tool
extends Control
# Visor para ver el diagrama del FSM
var conectorBase =  preload("../escenas/Conector.tscn")

# creamos un visor limpio para agregar  los estados
func recargar():
	# reviso y eliminino el visor viejo
	if has_node("GraphEdit"):
		var visor = $GraphEdit
		remove_child(visor)
	
	var nuevoVisor = GraphEdit.new()
	# para que el visor ocupe toda la pantalla 
	nuevoVisor.set_anchors_preset(Control.PRESET_FULL_RECT) 
	# escondo el minimapa, grilla y menu de botones
	nuevoVisor.minimap_enabled = false
	nuevoVisor.show_grid = false
	nuevoVisor.show_menu = false
	# para que la rueda no haga zoom
	nuevoVisor.panning_scheme = GraphEdit.SCROLL_PANS
	# le cambio el nombre para que lo pueda seleccionar si lo necesito
	nuevoVisor.name = "GraphEdit"
	# agrego el nodo
	add_child(nuevoVisor)

func agregarEstados(listaEstados):
	for estado in listaEstados:
		var nuevoEstado = GraphNode.new()
		nuevoEstado.name =  estado.name
		nuevoEstado.size = Vector2.ZERO
		nuevoEstado.title = estado.name
		if estado.posicionVisor == Vector2.ZERO:
			nuevoEstado.position_offset = Vector2(randf_range(0, 800), randf_range(0, 500))
		else:
			nuevoEstado.position_offset = estado.posicionVisor
		nuevoEstado.set_meta("nodo_estado", estado)
		$GraphEdit.add_child(nuevoEstado)

func agregarConector(EstadoInicio : String, EstadoFin : String,
Condicion : String, tipo :String = ""):
	
	var nuevoConector = conectorBase.instantiate()
	
	if (not $GraphEdit.has_node(EstadoInicio) or
	not $GraphEdit.has_node(EstadoFin)):
		printerr("No exite el estado " + EstadoInicio + " o " + EstadoFin)

	nuevoConector.EstadoInicio = $GraphEdit.get_node(EstadoInicio)
	nuevoConector.EstadoFin = $GraphEdit.get_node(EstadoFin)
	
	nuevoConector.set_tipo_conector(tipo)
	nuevoConector.set_label_condicion(Condicion)
	
	$GraphEdit.add_child(nuevoConector)

func listarConecciones(nuevaLista):
	var lista = Label.new()
	lista.set_anchors_preset(Control.PRESET_TOP_LEFT)
	lista.text = nuevaLista
	
	$GraphEdit.add_child(lista)

func guardarPosiciones():
	for estado in $GraphEdit.get_children():
		if estado is GraphNode:
			estado.get_meta("nodo_estado").posicionVisor = estado.position_offset


