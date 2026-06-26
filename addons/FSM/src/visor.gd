@tool
extends Control
# Visor para ver el diagrama del FSM
var conectorBase =  preload("../escenas/Conector.tscn")
var contenedorGrupo = preload("../escenas/Grupo.tscn")

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
	# nuevoVisor.panning_scheme = GraphEdit.SCROLL_PANS
	# le cambio el nombre para que lo pueda seleccionar si lo necesito
	nuevoVisor.name = "GraphEdit"
	# agrego el nodo
	add_child(nuevoVisor)

func agregarEstados(estado, grupoNombre : String):

	var nuevoEstado = GraphNode.new()
	nuevoEstado.name =  estado.name
	nuevoEstado.size = Vector2.ZERO
	nuevoEstado.title = estado.name
	nuevoEstado.z_as_relative = false
	nuevoEstado.z_index = 2
	if estado.posicionVisor == Vector2.ZERO:
		nuevoEstado.position_offset = Vector2(randf_range(0, 800), randf_range(0, 500))
	else:
		nuevoEstado.position_offset = estado.posicionVisor
	nuevoEstado.set_meta("nodo_estado", estado)
	if grupoNombre != "":
		var grupoContenedor = $GraphEdit.get_node(grupoNombre)
		grupoContenedor.agregar_estado(nuevoEstado)
	else:
		$GraphEdit.add_child(nuevoEstado)

func agregarContenedorGrupo(estado):

	var nuevoGrupo = contenedorGrupo.instantiate()
	
	nuevoGrupo.name =  estado.name
	# nuevoGrupo.size = Vector2.ZERO
	nuevoGrupo.title = estado.name
	if estado.posicionVisor == Vector2.ZERO:
		nuevoGrupo.position_offset = Vector2(randf_range(0, 800), randf_range(0, 500))
	else:
		nuevoGrupo.position_offset = estado.posicionVisor
		
	if estado.tamañoContenedor == Vector2.ZERO:
		estado.tamañoContenedor = nuevoGrupo.custom_minimum_size
		
	nuevoGrupo.size = estado.tamañoContenedor
	
	nuevoGrupo.set_meta("nodo_estado", estado)
	$GraphEdit.add_child(nuevoGrupo)

func agregarConector(EstadoInicio : String, EstadoFin : String, grupoNombre : String, 
Condicion : String, tipo :String = ""):
	
	var nuevoConector = conectorBase.instantiate()
	
	if grupoNombre != "":
		var grupoContenedor = $GraphEdit.get_node(grupoNombre)
		
		if (not grupoContenedor.verificar_existencia_estado(EstadoInicio) or
			not grupoContenedor.verificar_existencia_estado(EstadoFin)):
			printerr("No exite el estado " + EstadoInicio + " o " + EstadoFin)

		nuevoConector.EstadoInicio = grupoContenedor.obtener_estado(EstadoInicio)
		nuevoConector.EstadoFin = grupoContenedor.obtener_estado(EstadoFin)
		nuevoConector.GrupoContenedor = grupoContenedor
	
	else:
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
	
	for nodo : Node in $GraphEdit.get_children():
		if nodo is GraphNode:
			nodo.get_meta("nodo_estado").posicionVisor = nodo.position_offset
			
		if nodo is GraphFrame:
			nodo.get_meta("nodo_estado").posicionVisor = nodo.position_offset
			nodo.get_meta("nodo_estado").tamañoContenedor = nodo.size
			
			for nodoEnGrupo : Node in nodo.obtener_estados():
				if nodoEnGrupo is GraphNode:
					nodoEnGrupo.get_meta("nodo_estado").posicionVisor = nodoEnGrupo.position_offset
