extends Control 

@onready var tile_info: Control = $ScrollContainer/HBoxContainer/TileInfo
@onready var unit_info: Control = $ScrollContainer/HBoxContainer/UnitInfo
func _setup_layout() -> void:
    #hbox.custom_minimum_size = size
    tile_info.custom_minimum_size = size
    
    

func _ready() -> void:
    await get_tree().process_frame
    await get_tree().process_frame
    _setup_pages()

func _setup_pages() -> void:
    var page_width = size.x
    var page_height = size.y
    
    tile_info.custom_minimum_size = Vector2(page_width, page_height)
    unit_info.custom_minimum_size = Vector2(page_width, page_height)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func paint_tile_info(dict: Dictionary) -> void:
    tile_info.paint(dict)

    
    
func paint_unit_info(dict: Dictionary) -> void:
    unit_info.paint(dict)
    pass
    
