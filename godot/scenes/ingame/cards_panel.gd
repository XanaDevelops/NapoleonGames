extends Control 

@onready var tile_info: Control = $MarginContainer/TabContainer/TileInfo
@onready var unit_info: Control = $MarginContainer/TabContainer/UnitInfo
@onready var tabs: TabContainer =$MarginContainer/TabContainer


func _ready() -> void:
    await get_tree().process_frame

    _setup_pages()

func _setup_pages() -> void:
    var page_width = size.x
    var page_height = size.y
    
    tile_info.custom_minimum_size = Vector2(page_width, page_height)
    unit_info.custom_minimum_size = Vector2(page_width, page_height)


func paint_tile_info(dict: Dictionary) -> void:
    tabs.visible = true
    tile_info.paint(dict)
    tabs.set_tab_hidden(1, true)
    tabs.current_tab = 0
    
func paint_unit_info(dict: Dictionary) -> void:
    tabs.visible = true
    unit_info.paint(dict)
    tabs.set_tab_hidden(1, false)
    tabs.current_tab = 0


func clear() -> void:
    tabs.visible = false
    
