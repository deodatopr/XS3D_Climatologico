class_name GDs_Graficadora_Manager extends Node

@export_group("INTERNAL REFERENCES")
@export var graficadora : GDs_Graficadora
@export var graficadoraDropdowns : GDs_Graficadora_Dropdowns
@export var graficadora_UI_Interact : GDs_Graficadora_UI_Interact
@export var graficadora_anim_loading : GDs_Graficadora_Anim_Loading

func Initialize(_dataService : GDs_DataService_Manager, _barraMenus : GDs_BarraMenus):
	graficadora.Initialize(_dataService,graficadora_anim_loading)
	graficadoraDropdowns.Initialize()
	graficadora_UI_Interact.Initialize(_dataService,_barraMenus)
