@tool
extends EditorPlugin

var plugin_control
var Cicloseleccionado = null

# Dock reference.
var dock

func _enter_tree():
	plugin_control = preload("./src/visor.gd").new()
	
	dock = EditorDock.new()
	dock.title = "Visor de FSM"
	dock.default_slot = EditorDock.DOCK_SLOT_RIGHT_UL
	var dock_content = plugin_control
	dock.add_child(dock_content)
	add_dock(dock)
	

func _exit_tree():
	if dock:
		if dock.is_inside_tree():
			remove_dock(dock)
		dock.queue_free()
		dock = null
	#remove_control_from_bottom_panel(plugin_control)
	#plugin_control.free()
	

func _handles(object):
	"""
	if  object is State:
		EditorInterface.edit_script(object.get_script())
	"""
	return object is Ciclo

func _make_visible(visible: bool) -> void:
	if visible:
		if not dock.is_inside_tree():
			add_dock(dock) # Lo muestra de forma segura
	else:
		if dock.is_inside_tree():
			remove_dock(dock) # Lo oculta limpiamente

func _edit(object: Object) -> void:
	
	if object is Ciclo and Cicloseleccionado == null:
		_generarArbol(object)
		Cicloseleccionado = object
		# add_dock(dock)
		#add_control_to_bottom_panel(plugin_control,"Visor de FSM")
		
	elif object is Ciclo and Cicloseleccionado != object:
		plugin_control.guardarPosiciones()
		_generarArbol(object)
		Cicloseleccionado = object
		
	elif not object is Ciclo and Cicloseleccionado != null: 
		plugin_control.guardarPosiciones()
		# remove_dock(dock)
		#remove_control_from_bottom_panel(plugin_control)
		Cicloseleccionado = null

func _generarArbol(Ciclo):
	# recargo para tener el diagrama limpio
	plugin_control.recargar()
	
	
	# cargo los estados
	for nodo : Node in Ciclo.get_children():
		if nodo is Grupo:
			plugin_control.agregarContenedorGrupo(nodo)
			for estado : Node in nodo.get_children():
				if estado is State:
					plugin_control.agregarEstados(estado, nodo.name)
		
		elif nodo is State:
			plugin_control.agregarEstados(nodo, "")
	

	# cargo los conectores
	var listaResumen = ""
	for nodo : Node in Ciclo.get_children():
		if (nodo is not Grupo) and (nodo is not State):
			continue
		
		_agregarConector(nodo, "", listaResumen)
		
		if nodo is Grupo:
			for estado : Node in nodo.get_children():
				if estado is State:
					_agregarConector(estado, nodo.name, listaResumen)


	plugin_control.listarConecciones(listaResumen)

func _agregarConector(estados : Node, grupoNombre : String, listaResumen : String):
	var script : Script = estados.get_script()
	var codigoScript : String = script.source_code.strip_escapes()

	# separo el script en sus funciones
	for funcion in codigoScript.split("func",false):
		
		# en la funcion revisar, extraigo las condiciones y salidas
		if ("revisar" in funcion):
			if "if" not in funcion : continue
		
			for condicionSalida in funcion.split("if",false):
				# Agrego los conectores que salen del revisar
				if "cambiarEstado" not in condicionSalida : continue
				
				var condicion = condicionSalida.strip_edges().get_slice(":", 0)
				var salida 
				if ("LISTA_ESTADOS" in condicionSalida):
					salida = condicionSalida.get_slice("cambiarEstado.emit(LISTA_ESTADOS.", 1).get_slice(")", 0)
				else:
					salida = condicionSalida.get_slice("cambiarEstado.emit(\"", 1).get_slice("\"", 0)
				
				listaResumen += estados.name + " --> " + salida + " : " + condicion +"\n"
				plugin_control.agregarConector(estados.name, salida, grupoNombre, condicion)
			continue
		
		# las funciones entrar, ejecutar y salir no me interesan, asi que me salgo
		if ("entrar" in funcion or "ejecutar" in funcion or "salir" in funcion) : continue
		
		# si queda alguna funcion, probablemente se maneje por señal para cambiar el estado
		if "cambiarEstado" in funcion:
			# Agrego los conectores que salen de las señales
			var condicion = funcion.strip_edges().get_slice(":", 0)
			var salida = funcion.get_slice("cambiarEstado.emit(\"", 1).get_slice("\"", 0)
			
			listaResumen += estados.name + " -S-> " + salida + " : " + condicion +"\n"
			plugin_control.agregarConector(estados.name, salida, grupoNombre, condicion, "Señal")
