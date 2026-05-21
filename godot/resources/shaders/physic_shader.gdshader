shader_type canvas_item;


uniform vec4 color_core : source_color = vec4(1.0, 0.9, 0.9, 1.0); 
uniform vec4 color_mid  : source_color = vec4(1.0, 0.0, 0.0, 1.0); 
uniform vec4 color_edge : source_color = vec4(1.0, 0.8, 0.8, 1.0); 

uniform float wave_speed       = 0.5;  
uniform float wave_amplitude   = 0.05; 
uniform float wave_frequency   = 8.0;  
uniform float flame_squash_factor = 1.0;
uniform float effect_intensity : hint_range(0.0, 1.0) = 1.0;


uniform bool  pointy_top = true;
uniform float mask_size  : hint_range(0.1, 1.0) = 0.5;
uniform float mask_scale_x : hint_range(0.5, 2.0) = 1.0;

float random(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

float noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);
    vec2 u = f * f * (3.0 - 2.0 * f);
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

void fragment() {
    vec2 uv = UV;
    vec4 tex_clean = texture(TEXTURE, uv);

   
    float time_beat = fract(TIME * wave_speed);
    float pulse1 = exp(-time_beat * 15.0); 
    float pulse2 = exp(-(time_beat - 0.25) * 15.0) * step(0.25, time_beat); 
    float beat = (pulse1 + pulse2 * 0.6) * effect_intensity;

  
    vec2 center = vec2(0.5, 0.5);
    vec2 dir_from_center = uv - center;
  
    vec2 distorted_uv = uv - (dir_from_center * beat * wave_amplitude);
    
    vec4 tex_d = texture(TEXTURE, distorted_uv);
    float dist_from_center = distance(distorted_uv, center);

    
    vec3 blood_base = mix(tex_d.rgb, tex_d.rgb * color_mid.rgb * 2.0, effect_intensity * 0.8);

    
    float core_gradient = smoothstep(0.5, 0.0, dist_from_center);
    vec3 core_glow = tex_d.rgb * color_core.rgb * core_gradient * beat * 1.5;

    vec3 final_rgb = blood_base + core_glow;

  
    float n1 = noise(distorted_uv * wave_frequency);
    float n2 = noise(distorted_uv * wave_frequency * 1.5 + vec2(1.2, 3.4)) * 0.5;
    float noise_sum = clamp((n1 + n2) / 1.5, 0.0, 1.0);
    float veins_raw = 1.0 - abs(noise_sum * 2.0 - 1.0);
    
    float veins_sharp = smoothstep(0.4, 1.0, veins_raw); 
    float active_veins = veins_sharp * smoothstep(0.0, 0.8, dist_from_center) * (beat + 0.5);

    vec3 vein_color = color_edge.rgb * 1.5;
    final_rgb = mix(final_rgb, vein_color, clamp(active_veins * effect_intensity, 0.0, 1.0));

    
    vec2 adjusted_uv = distorted_uv - vec2(0.5);
    adjusted_uv.x *= mask_scale_x;
    vec2 p = abs(adjusted_uv);
    float mask = 0.0;
    
    if (pointy_top) {
        float q = p.y + p.x * 0.57735026919;
        mask = (p.x <= mask_size && q <= mask_size) ? 1.0 : 0.0;
    } else {
        float q = p.x + p.y * 0.57735026919;
        mask = (p.y <= mask_size && q <= mask_size) ? 1.0 : 0.0;
    }

    COLOR = vec4(final_rgb, tex_d.a * mask);
}