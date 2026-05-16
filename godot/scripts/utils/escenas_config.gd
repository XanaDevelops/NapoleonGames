class_name EscenasConfig
extends Object


const MAPA_ESCENAS: Dictionary[String, String] = {
	"inicio": "res://scenes/inicio.tscn",
	"login": "res://scenes/login.tscn",
	"registro": "res://scenes/registro.tscn",
	"perfil": "res://scenes/perfil.tscn",
	"mapas":"res://scenes/selector_de_mapas.tscn",
	"ejercitos":"res://scenes/creacio_de_exercits.tscn",
	"oponente":"res://scenes/selector_de_oponente.tscn",
	"juego":"res://scenes/ingame/game_scene.tscn",
	"finalizacion":"res://scenes/pantalla_finalitzacio.tscn"
}


const SECCIONES_POR_ESCENA: Dictionary[String, String] = {
	"inicio": "menus",
	"login": "areas_sociales",
	"registro": "areas_sociales",
	"perfil": "areas_sociales",
	"mapas": "menus",
	"ejercitos": "ejercitos",
	"oponente": "menus",
	"juego": "",
	"finalizacion": "" 
}


const MUSIC_SERIES_FOLDERS: Dictionary[String, String] = {
	"menus": "res://assets/musica/menus/",
	"areas_sociales": "res://assets/musica/areas_sociales/",
	"ejercitos":"res://assets/musica/ejercito/"
}
