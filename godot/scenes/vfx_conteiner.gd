# ==============================================================================
# vfx_container.gd
# CONTROLADOR UNIVERSAL: Instancia materiales limpios y lee el recurso genérico.
# ==============================================================================
extends Node2D

@onready var sprite_overlay: Sprite2D = $SpriteOverlay
@onready var particles: GPUParticles2D = $ParticulasGenericas

func setup_vfx(unit_texture: Texture2D, effect_data: VFXEffectData, mask_size: float, mask_scale_x: float) -> void:
	# --------------------------------------------------------------------------
	# 1. SHADER: ASIGNACIÓN DIRECTA (Escala 1:1)
	# --------------------------------------------------------------------------
	sprite_overlay.texture = unit_texture
	sprite_overlay.scale = Vector2.ONE # 1:1 porque la imagen ya viene reducida al tamaño de la celda
	
	var mat = ShaderMaterial.new()
	if effect_data.shader:
		mat.shader = effect_data.shader
		
		# Geometría del hexágono
		mat.set_shader_parameter("mask_size", mask_size)
		mat.set_shader_parameter("mask_scale_x", mask_scale_x)
		mat.set_shader_parameter("pointy_top", effect_data.pointy_top)
		
		# Intensidad y distorsión (Tu shader de ondas original)
		mat.set_shader_parameter("effect_intensity", effect_data.effect_intensity)
		mat.set_shader_parameter("flame_squash_factor", effect_data.flame_squash_factor)
		mat.set_shader_parameter("wave_speed", effect_data.wave_speed)
		mat.set_shader_parameter("wave_amplitude", effect_data.wave_amplitude)
		mat.set_shader_parameter("wave_frequency", effect_data.wave_frequency)
		
		# Colores del shader (Core, Mid, Edge)
		mat.set_shader_parameter("color_core", effect_data.core_color)
		mat.set_shader_parameter("color_mid", effect_data.mid_color)
		mat.set_shader_parameter("color_edge", effect_data.edge_color)
		
	sprite_overlay.material = mat

	# --------------------------------------------------------------------------
	# 2. PARTÍCULAS: CREACIÓN DEL MATERIAL DESDE CERO (Godot 4 Nativo)
	# --------------------------------------------------------------------------
	var pm = ParticleProcessMaterial.new()
	particles.process_material = pm # Inyectamos el material limpio para evitar basura
	
	if effect_data.particle_texture:
		particles.texture = effect_data.particle_texture
		
		# Auto-escala base para el ancho de la partícula
		var img_width = float(effect_data.particle_texture.get_width())
		if img_width > 0:
			var escala_base: float = effect_data.particle_base_size / img_width
			pm.scale_min = escala_base
			pm.scale_max = escala_base * effect_data.scale_multiplier

	# ALINEACIÓN NATIVA: Orienta el eje Y de la partícula hacia su vector de velocidad
	pm.particle_flag_align_y = true

	# Color a lo largo de la vida (Gradiente)
	if effect_data.color_ramp:
		var texture_gradient = GradientTexture1D.new()
		texture_gradient.gradient = effect_data.color_ramp
		pm.color_ramp = texture_gradient

	# Físicas, velocidad y resistencia
	pm.gravity = effect_data.gravity
	pm.initial_velocity_min = effect_data.initial_velocity_min
	pm.initial_velocity_max = effect_data.initial_velocity_max

	# Turbulencia / Convección (Efecto de viento térmico)
	if effect_data.use_turbulence:
		pm.turbulence_enabled = true
		pm.turbulence_noise_strength = effect_data.turbulence_strength
		pm.turbulence_noise_scale = 6.0
		pm.turbulence_noise_speed = Vector3(0, 1.5, 0)

	# Dirección del disparo y dispersión lateral dinámica
	match effect_data.movement_direction:
		VFXEffectData.MovementDirection.UP:
			pm.direction = Vector3(0, -1, 0)
			pm.spread = effect_data.movement_spread
		VFXEffectData.MovementDirection.DOWN:
			pm.direction = Vector3(0, 1, 0)
			pm.spread = effect_data.movement_spread
		VFXEffectData.MovementDirection.ALL_DIRECTIONS:
			pm.direction = Vector3(0, 0, 0)
			pm.spread = 180.0
			pm.gravity = Vector3.ZERO # Explosión radial pura, anula gravedad

	# --------------------------------------------------------------------------
	# 3. GEOMETRÍA: ADAPTACIÓN AL ALTO REAL DE LA TEXTURA PROPORCIONAL
	# --------------------------------------------------------------------------
	var alto_final: float = unit_texture.get_height() 
	
	match effect_data.emission_position:
		VFXEffectData.EmissionPosition.BOTTOM_VERTEX:
			# Calcula milimétricamente el pico inferior del hexágono
			var vertice_inferior_y: float = alto_final * mask_size
			particles.position = Vector2(0, vertice_inferior_y)
			
			pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
			pm.emission_box_extents = Vector3(alto_final * 0.05, 1.0, 1.0) # Caja de nacimiento adaptativa
			
		VFXEffectData.EmissionPosition.CENTER:
			# Nace en el ombligo del personaje
			particles.position = Vector2.ZERO
			pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
			pm.emission_sphere_radius = (alto_final * mask_size) * 0.5

	# --------------------------------------------------------------------------
	# NUEVO: CÁLCULO DINÁMICO DEL TIEMPO DE VIDA (LIFETIME)
	# --------------------------------------------------------------------------
	var velocidad_promedio: float = (effect_data.initial_velocity_min + effect_data.initial_velocity_max) / 2.0
	
	if velocidad_promedio > 0.0:
		# mask_size actúa como el "radio" del hexágono (del centro a la punta).
		# Por tanto, la distancia total de abajo hasta arriba es el DOBLE del radio.
		var distancia_objetivo: float = (alto_final * mask_size) * 2.0 
		
		match effect_data.emission_position:
			VFXEffectData.EmissionPosition.CENTER:
				# Si nace en el centro, entonces sí recorre solo un "radio"
				distancia_objetivo = alto_final * mask_size
				
		# Tiempo = Distancia / Velocidad
		particles.lifetime = distancia_objetivo / velocidad_promedio
	else:
		# Si la velocidad es 0, tiempo base por defecto
		particles.lifetime = 1.0

	# --------------------------------------------------------------------------
	# 4. EJECUCIÓN Y LIMPIEZA AUTOMÁTICA EN MEMORIA RAM
	# --------------------------------------------------------------------------
	particles.emitting = true
	
	var tween = create_tween()
	tween.tween_interval(effect_data.duration)
	
	# Apagado suave: las nuevas partículas nacen con tamaño cero
	tween.tween_callback(func(): pm.scale_min = 0.0; pm.scale_max = 0.0) 
	tween.tween_interval(0.8) # Margen de cortesía para que se desvanezcan las que quedan volando
	tween.tween_callback(queue_free) # Borrado absoluto del nodo para evitar lag
