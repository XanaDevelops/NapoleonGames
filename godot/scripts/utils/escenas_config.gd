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
	"resumen":"res://scenes/pantalla_resumen.tscn",
	"juego":"res://scenes/ingame/game_scene.tscn",
	"finalizacion":"res://scenes/pantalla_finalitzacio.tscn",
	"server": "res://scenes/server/server_scene.tscn",
	"exit_game":"res://scenes/exit_game.tscn"
}


const SECCIONES_POR_ESCENA: Dictionary[String, String] = {
	"inicio": "menus",
	"login": "areas_sociales",
	"registro": "areas_sociales",
	"perfil": "areas_sociales",
	"mapas": "menus",
	"ejercitos": "ejercitos",
	"oponente": "menus",
	"resumen":"menus",
	"juego": "",
	"finalizacion": "",
	"server": ""
}


const MUSIC_SERIES_FOLDERS: Dictionary[String, String] = {
	"menus": "res://assets/musica/menus/",
	"areas_sociales": "res://assets/musica/areas_sociales/",
	"ejercitos":"res://assets/musica/ejercito/"
}

const SFX_PATHS: Dictionary[String, String] = {
	"card_deal": "res://assets/sonidos/despligue_cartas.wav", 
	"sword_swing": "res://assets/sonidos/viento.wav",
	"sword_clash": "res://assets/sonidos/golpe_espada.wav",
	"coin_flip": "res://assets/sonidos/moneda.wav",
	"victory_sound": "res://assets/sonidos/victory_sound.mp3"
}
