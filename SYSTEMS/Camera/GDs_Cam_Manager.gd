class_name GDs_Cam_Manager extends Node

@export_group("Components")
@export var movement : GDs_CamMovement
@export var pivot_movement : Node3D
@export var cam : Camera3D

@export_group("Configurations")
@export_range(5,15) var speed_Pan : float = 10
@export_range(0.5,2) var speed_RotHor : float = 1

func _ready():
	Initialize()

func Initialize():
	movement.Initialize(cam,pivot_movement,speed_Pan, speed_RotHor)
