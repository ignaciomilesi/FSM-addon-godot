# Clase de los estados que utiliza el FSM
@icon("../utils/STATE.png")
class_name State
extends Node

@export var posicionVisor = Vector2.ZERO # guarda la posicion en el visor
var player: CharacterBody2D


signal cambiarEstado(new_state_name: StringName)
 
func entrar() -> void:
	pass

func revisar() -> void:
	pass

func ejecutar() -> void:
	pass
 
func salir() -> void:
	pass
