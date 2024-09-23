extends Node

class_name GDs_SITIO

#Datos llenados con custom resource (CR_LocalSitios)
var IdLocal : int
var IdSitio : int
var Estructura : int
var NombreEstructura : String
var Abreviacion : String
var Direccion : String
var NvlNormal : String
var NvlPreventivo : String
var NvlCritico : String
var LvlSitio : PackedScene
var LvlDisponible : bool
var LvlUnSoloSentido : bool

#Datos llenados con endpoint GetAllSitios (versión reducida)
var Enlace : bool
var Voltaje : String
var Fecha : String
var NvlValor : String
var NvlValorFloat : float

#Datos extra calculados con funciones locales
var NvlNormalCompleto : String
var NvlPreventivoCompleto : String
var NvlCriticoCompleto : String
var estaEnNivelCritico : bool
var estaEnNivelPreventivo : bool
var NvlValor01 : float

