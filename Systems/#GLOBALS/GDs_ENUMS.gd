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
	From_Debug_Random,
	From_Debug_Error
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

enum Dbg_ModoLluvia
{
	SinLLuvia,
	LLuviaModerada,
	LluviaIntensa
}

enum Dbg_Temperatura
{
	Normal,
	Calida
}

enum Dbg_Alarmas
{
	Normal,
	Prev,
	Critico
}

enum Dbg_Bateria
{
	_100,
	_75,
	_50,
	_25,
	_0
}
