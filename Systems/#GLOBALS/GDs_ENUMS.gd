extends Node

enum EP_GetAllEstaciones
{
	None,
	Success,
	Error
}

enum EP_RequestType
{
	From_EP,
	From_Simulado
}

enum EP_RequestResult
{
	Success,
	Error_NoData,
	Error_LastData
}

enum Estado
{
	Mexico,
	Michoacan
}

enum Cam_Mode
{
	sky,
	fly
}

enum ModoDatos
{
	Endpoint,
	Simulado
}

enum LluviaIntsdad
{
	Nada,
	Moderada,
	Intensa
}

enum Temperatura
{
	Normal,
	Calida,
	Alta
}

enum Alarmas
{
	Normal,
	Prev,
	Critico
}

enum Bateria
{
	_100,
	_75,
	_50,
	_25,
	_0
}
