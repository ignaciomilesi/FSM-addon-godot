# Clase de los estados que utiliza el FSM
@icon("../utils/STATE.png")

class_name State
extends Node

@export_storage var posicionVisor = Vector2.ZERO # guarda la posicion en el visor

var animaciones : AnimationPlayer
var LISTA_NOMBRE_ANIMACIONES : Dictionary 
var LISTA_ESTADOS : Dictionary 

@onready var player: CharacterBody2D = owner

signal cambiarEstado(new_state_name: StringName)

func _enter_tree() -> void:
	animaciones = get_parent().animaciones
	LISTA_NOMBRE_ANIMACIONES = get_parent().LISTA_NOMBRE_ANIMACIONES
	LISTA_ESTADOS = get_parent().LISTA_NOMBRE_ESTADOS

func _ready() -> void:
	pass
 
func entrar() -> void:
	pass

func revisar() -> void:
	pass

func ejecutar() -> void:
	pass
 
func salir() -> void:
	pass
