extends Node

var EP_GetAllEstaciones_State : int = 0
var EP_GetAllEstaciones_RequestType : int = ENUMS.EP_RequestType.From_Simulado
var currntSitio : GDs_Data_Sitio = GDs_Data_Sitio.new()
var camMode : int = ENUMS.Cam_Mode.sky
var currntIdSitio : int = -1
var dataReady : bool
var popUpOpened: bool
var panelErrorOpened: bool
var menuUIOptionIsOpened : bool
