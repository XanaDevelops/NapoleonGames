extends Node2D

@onready var sprite_overlay: Sprite2D = $SpriteOverlay
@onready var generic_particles: GPUParticles2D = $ParticulasGenericas
signal vfx_finished

func setup_vfx(
	unit_texture: Texture2D,
	effect_data: VFXEffectData,
	mask_size: float,
	mask_scale_x: float
) -> void:

	sprite_overlay.texture = unit_texture
	sprite_overlay.scale = Vector2.ONE

	var shader_material = ShaderMaterial.new()

	if effect_data.shader:
		shader_material.shader = effect_data.shader

		shader_material.set_shader_parameter("mask_size", mask_size)
		shader_material.set_shader_parameter("mask_scale_x", mask_scale_x)
		shader_material.set_shader_parameter("pointy_top", effect_data.pointy_top)

		shader_material.set_shader_parameter("effect_intensity", effect_data.effect_intensity)
		shader_material.set_shader_parameter("flame_squash_factor", effect_data.flame_squash_factor)
		shader_material.set_shader_parameter("wave_speed", effect_data.wave_speed)
		shader_material.set_shader_parameter("wave_amplitude", effect_data.wave_amplitude)
		shader_material.set_shader_parameter("wave_frequency", effect_data.wave_frequency)

		shader_material.set_shader_parameter("color_core", effect_data.core_color)
		shader_material.set_shader_parameter("color_mid", effect_data.mid_color)
		shader_material.set_shader_parameter("color_edge", effect_data.edge_color)

	sprite_overlay.material = shader_material

	var particle_process_material = ParticleProcessMaterial.new()
	generic_particles.process_material = particle_process_material

	if effect_data.particle_texture:
		generic_particles.texture = effect_data.particle_texture

		var texture_width = float(effect_data.particle_texture.get_width())

		if texture_width > 0:
			var base_particle_scale: float = (
				effect_data.particle_base_size / texture_width
			)

			particle_process_material.scale_min = base_particle_scale
			particle_process_material.scale_max = (
				base_particle_scale * effect_data.scale_multiplier
			)

	particle_process_material.particle_flag_align_y = true

	if effect_data.color_ramp:
		var gradient_texture = GradientTexture1D.new()
		gradient_texture.gradient = effect_data.color_ramp
		particle_process_material.color_ramp = gradient_texture

	particle_process_material.gravity = effect_data.gravity
	particle_process_material.initial_velocity_min = effect_data.initial_velocity_min
	particle_process_material.initial_velocity_max = effect_data.initial_velocity_max

	if effect_data.use_turbulence:
		particle_process_material.turbulence_enabled = true
		particle_process_material.turbulence_noise_strength = effect_data.turbulence_strength
		particle_process_material.turbulence_noise_scale = 6.0
		particle_process_material.turbulence_noise_speed = Vector3(0, 1.5, 0)

	match effect_data.movement_direction:

		VFXEffectData.MovementDirection.UP:
			particle_process_material.direction = Vector3(0, -1, 0)
			particle_process_material.spread = effect_data.movement_spread

		VFXEffectData.MovementDirection.DOWN:
			particle_process_material.direction = Vector3(0, 1, 0)
			particle_process_material.spread = effect_data.movement_spread

		VFXEffectData.MovementDirection.ALL_DIRECTIONS:
			particle_process_material.direction = Vector3(0, 0, 0)
			particle_process_material.spread = 180.0
			particle_process_material.gravity = Vector3.ZERO

	var final_texture_height: float = unit_texture.get_height()

	match effect_data.emission_position:

		VFXEffectData.EmissionPosition.BOTTOM_VERTEX:

			var bottom_vertex_position_y: float = (
				final_texture_height * mask_size
			)

			generic_particles.position = Vector2(
				0,
				bottom_vertex_position_y
			)

			particle_process_material.emission_shape = (
				ParticleProcessMaterial.EMISSION_SHAPE_BOX
			)

			particle_process_material.emission_box_extents = Vector3(
				final_texture_height * 0.05,
				1.0,
				1.0
			)

		VFXEffectData.EmissionPosition.CENTER:

			generic_particles.position = Vector2.ZERO

			particle_process_material.emission_shape = (
				ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
			)

			particle_process_material.emission_sphere_radius = (
				(final_texture_height * mask_size) * 0.5
			)

	var average_velocity: float = (
		effect_data.initial_velocity_min +
		effect_data.initial_velocity_max
	) / 2.0

	if average_velocity > 0.0:

		var target_distance: float = (
			(final_texture_height * mask_size) * 2.0
		)

		match effect_data.emission_position:

			VFXEffectData.EmissionPosition.CENTER:
				target_distance = final_texture_height * mask_size

		generic_particles.lifetime = (
			target_distance / average_velocity
		)

	else:
		generic_particles.lifetime = 1.0

	var audio_stream_player: AudioStreamPlayer = null

	if effect_data.get("sound_effect") and effect_data.sound_effect:

		audio_stream_player = AudioStreamPlayer.new()

		audio_stream_player.stream = effect_data.sound_effect

		audio_stream_player.volume_db = (
			effect_data.get("sound_volume_db")
			if effect_data.get("sound_volume_db") != null
			else 0.0
		)

		var pitch_randomness: float = (
			effect_data.get("sound_pitch_randomness")
			if effect_data.get("sound_pitch_randomness") != null
			else 0.1
		)

		var minimum_pitch = 1.0 - pitch_randomness
		var maximum_pitch = 1.0 + pitch_randomness

		audio_stream_player.pitch_scale = randf_range(
			minimum_pitch,
			maximum_pitch
		)

		audio_stream_player.bus = &"Master"

		add_child(audio_stream_player)

		audio_stream_player.play()

	generic_particles.emitting = true

	var main_tween = create_tween()

	main_tween.tween_interval(effect_data.duration)

	main_tween.tween_callback(func():

		particle_process_material.scale_min = 0.0
		particle_process_material.scale_max = 0.0

		if audio_stream_player and audio_stream_player.playing:

			var audio_fade_tween = create_tween()

			audio_fade_tween.tween_property(
				audio_stream_player,
				"volume_db",
				-40.0,
				0.8
			).set_trans(Tween.TRANS_SINE)
	)

	main_tween.tween_interval(0.8)
	main_tween.tween_callback(func():
		vfx_finished.emit()
		queue_free())
