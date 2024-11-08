extends Node

var EP_GetAllEstaciones_State : int = 0
var EP_GetAllEstaciones_RequestType : int = ENUMS.EP_RequestType.From_EP
var currntSitio : GDs_Data_Estacion = GDs_Data_Estacion.new()
var camMode : int = ENUMS.Cam_Mode.sky
var currntIdSitio : int
var dataReady : bool
var popUpOpened: bool
