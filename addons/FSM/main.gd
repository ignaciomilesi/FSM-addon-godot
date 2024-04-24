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
	plugin_control.recargar()
	plugin_control.agregarEstados(FSM.get_children())
	var listaResumen = ""
	for estados in FSM.get_children():
		var script : Script = estados.get_script()
		var codigoScript : String = script.source_code.strip_escapes()
		
		if not "revisar():" in codigoScript : continue
			
		var codigoEnRevisar = codigoScript.get_slice("revisar():", 1)
		
		if not "if" in codigoEnRevisar : continue
			
		for condicionSalida in codigoEnRevisar.split("if",false):
			if (condicionSalida.length() == 0 or 
			not "cambiarEstado" in condicionSalida) : continue
			
			var condicion = condicionSalida.strip_edges().get_slice(":", 0)
			var salida = condicionSalida.get_slice("cambiarEstado.emit(\"", 1).get_slice("\"", 0)
			
			listaResumen += estados.name + " -> " + salida + " : " + condicion +"\n"
			plugin_control.agregarConector(estados.name, salida, condicion)
	plugin_control.listarConecciones(listaResumen)

