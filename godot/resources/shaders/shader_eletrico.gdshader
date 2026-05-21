shader_type canvas_item;

uniform vec4 color_core : source_color = vec4(0.8, 0.95, 1.0, 1.0);
uniform vec4 color_mid  : source_color = vec4(0.0, 0.8,  1.0, 1.0);
uniform vec4 color_edge : source_color = vec4(0.0, 0.2,  1.0, 1.0);

uniform float wave_speed          = 10.0;
uniform float wave_amplitude      = 0.03;
uniform float wave_frequency      = 15.0;
uniform float flame_squash_factor = 1.0;
uniform float effect_intensity : hint_range(0.0, 1.0) = 1.0;

uniform bool  pointy_top   = true;
uniform float mask_size    : hint_range(0.1, 1.0) = 0.5;
uniform float mask_scale_x : hint_range(0.5, 2.0) = 1.0;

float random(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
    vec2 distorted_uv = UV;

   
    float shake_x = (random(vec2(TIME * 20.0, 0.0)) - 0.5) * wave_amplitude * effect_intensity;
    float shake_y = (random(vec2(0.0, TIME * 20.0)) - 0.5) * wave_amplitude * effect_intensity;
    distorted_uv += vec2(shake_x, shake_y);
    distorted_uv  = clamp(distorted_uv, vec2(0.001), vec2(0.999)); 

    vec4 tex_color = texture(TEXTURE, distorted_uv);

   
    vec2  center          = vec2(0.5, 0.5);
    float dist_from_center = distance(distorted_uv, center);

    float raw_wave  = sin(dist_from_center * wave_frequency - TIME * wave_speed);
    float wave_norm = (raw_wave + 1.0) * 0.5;
    float wave_mask = pow(wave_norm, 4.0);

    
    vec4 electric_color = mix(color_edge, color_mid,  smoothstep(0.0, 0.5, wave_norm));
    electric_color       = mix(electric_color, color_core, smoothstep(0.5, 1.0, wave_norm));

   
    vec4 wave_glow      = electric_color * 2.5 * wave_mask;
   
    vec4 background_tint = electric_color * 0.35;

    vec4 final_color = tex_color
                     + (background_tint * effect_intensity)
                     + (wave_glow       * effect_intensity);
    final_color.a = tex_color.a;

    
    vec2 adjusted_uv = UV - vec2(0.5);
    adjusted_uv.x *= mask_scale_x;
    vec2  p    = abs(adjusted_uv);
    float mask = 0.0;

    if (pointy_top) {
        float q = p.y + p.x * 0.57735026919;
        mask = (p.x <= mask_size && q <= mask_size) ? 1.0 : 0.0;
    } else {
        float q = p.x + p.y * 0.57735026919;
        mask = (p.y <= mask_size && q <= mask_size) ? 1.0 : 0.0;
    }

    COLOR = vec4(final_color.rgb, tex_color.a * mask);
}