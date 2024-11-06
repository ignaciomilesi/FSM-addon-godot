@icon("../utils/FSM.png")
class_name FSM
extends Node

var ciclos: Array[Ciclo]= []

@onready var player: CharacterBody2D = owner

func _ready():

	# Cargo los ciclos
	for child in get_children():
		if child is Ciclo:
			ciclos.append(child)
	

func _physics_process(_delta):
	
	for ciclo in ciclos:
		ciclo.ejecutar()

	player.move_and_slide()
