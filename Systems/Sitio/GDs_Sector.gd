class_name GDs_Sector extends Node

@export var orquestrator : GDs_Orquestrator_Sector

func Initialize(_datService : GDs_DataService_Manager):
	orquestrator.Initialize(_datService)
