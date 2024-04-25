@tool
extends EditorPlugin

var plugin_control
var FSMseleccionado = null

func _enter_tree():
	plugin_control = preload("./src/visor.gd").new()


func _exit_tree():
	remove_control_from_bottom_panel(plugin_control)
	plugin_control.free()

func _handles(object):
	if object is FSM and FSMseleccionado == null:
		_generarArbol(object)
		FSMseleccionado = object
		add_control_to_bottom_panel(plugin_control,"Visor de FSM")
		
	elif object is FSM and FSMseleccionado != object:
		plugin_control.guardarPosiciones()
		_generarArbol(object)
		FSMseleccionado = object
		
	elif not object is FSM and FSMseleccionado != null: 
		plugin_control.guardarPosiciones()
		remove_control_from_bottom_panel(plugin_control)
		FSMseleccionado = null

func _generarArbol(FSM):
	# recargo para tener el diagrama limpio
	plugin_control.recargar()
	# cargo los estados
	plugin_control.agregarEstados(FSM.get_children())
	# cargo los conectores
	var listaResumen = ""
	for estados in FSM.get_children():
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
					var salida = condicionSalida.get_slice("cambiarEstado.emit(\"", 1).get_slice("\"", 0)
					
					listaResumen += estados.name + " --> " + salida + " : " + condicion +"\n"
					plugin_control.agregarConector(estados.name, salida, condicion)
				continue
			
			# las funciones entrar, ejecutar y salir no me interesan, asi que me salgo
			if ("entrar" in funcion or "ejecutar" in funcion or "salir" in funcion) : continue
			
			# si queda alguna funcion, probablemente se maneje por señal para cambiar el estado
			if "cambiarEstado" in funcion:
				# Agrego los conectores que salen de las señales
				var condicion = funcion.strip_edges().get_slice(":", 0)
				var salida = funcion.get_slice("cambiarEstado.emit(\"", 1).get_slice("\"", 0)
				
				listaResumen += estados.name + " -S-> " + salida + " : " + condicion +"\n"
				plugin_control.agregarConector(estados.name, salida, condicion, "Señal")
	
	# Agrego los conectores que salen de la animacion
	for coneccion in FSM.conectoresPorAnimaciones():
		listaResumen += coneccion[0] + " -A-> " + coneccion[1] + " : " + str(coneccion[2]) +"s\n"
		plugin_control.agregarConector(coneccion[0], coneccion[1], str(coneccion[2])+"s", "Anim")
	
	plugin_control.listarConecciones(listaResumen)
