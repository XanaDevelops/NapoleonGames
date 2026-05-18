# ==============================================================================
# vfx_effect_data.gd
# RECURSO BASE FINAL: Plantilla neutral optimizada para Godot 4.
# ==============================================================================
class_name VFXEffectData
extends Resource

enum EmissionPosition { BOTTOM_VERTEX, CENTER }
enum MovementDirection { UP, DOWN, ALL_DIRECTIONS }



@export_category("1. Configuración del Shader")
@export var shader: Shader
@export var effect_intensity: float = 1.0

@export_group("Colores del Shader")
@export var core_color: Color = Color.WHITE
@export var mid_color: Color = Color.WHITE
@export var edge_color: Color = Color.WHITE

@export_group("Distorsión y Forma (Shader)")
@export var flame_squash_factor: float = 1.0 
@export var wave_speed: float = 0.0          
@export var wave_amplitude: float = 0.0
@export var wave_frequency: float = 0.0
@export var pointy_top: bool = true          

@export_category("2. Textura y Color de Partículas")
@export var particle_texture: Texture2D
@export var color_ramp: Gradient
@export var particle_base_size: float = 4.0  
@export var scale_multiplier: float = 1.0    

@export_category("3. Físicas y Movimiento")
@export var gravity: Vector3 = Vector3(0, 0, 0) 
@export var initial_velocity_min: float = 0.0
@export var initial_velocity_max: float = 0.0
@export var movement_spread: float = 15.0 # Controla la dispersión hacia los lados

@export_category("4. Turbulencia (Convección)")
@export var use_turbulence: bool = false     
@export var turbulence_strength: float = 0.0

@export_category("5. Geometría y Comportamiento")
@export var emission_position: EmissionPosition = EmissionPosition.CENTER 
@export var movement_direction: MovementDirection = MovementDirection.ALL_DIRECTIONS
@export var duration: float = 1.0
