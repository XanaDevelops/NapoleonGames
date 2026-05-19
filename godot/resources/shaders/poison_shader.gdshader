shader_type canvas_item;


uniform vec4 color_core : source_color = vec4(0.8, 1.0,  0.0, 1.0); 
uniform vec4 color_mid  : source_color = vec4(0.2, 0.85, 0.0, 1.0); 
uniform vec4 color_edge : source_color = vec4(0.0, 0.35, 0.0, 1.0); 

uniform float wave_speed       = 1.5;
uniform float wave_amplitude   = 0.03;
uniform float wave_frequency   = 6.0;
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


vec3 apply_zone_color(vec3 rgb, vec4 zone_color) {
    float lum = dot(rgb, vec3(0.299, 0.587, 0.114));
    vec3 zone = vec3(zone_color.r, zone_color.g, 0.0); 
    return lum * zone;
}

void fragment() {
    vec2 uv = UV;


    vec4 tex_clean = texture(TEXTURE, uv);

   
    float wobble = sin(uv.y * wave_frequency * 2.0 + TIME * wave_speed * 1.5)
                   * wave_amplitude * effect_intensity;
    vec2 distorted_uv = clamp(uv + vec2(wobble, 0.0), vec2(0.001), vec2(0.999));

    vec4 tex_d = texture(TEXTURE, distorted_uv);

   
    vec2 noise_uv = distorted_uv * wave_frequency;
    noise_uv.y -= TIME * wave_speed * 2.0;
    float n1 = noise(noise_uv);
    float n2 = noise(noise_uv * 1.5 + vec2(TIME, TIME * 0.5)) * 0.5;
    float final_noise = clamp((n1 + n2) / 1.5, 0.0, 1.0);

  
    vec3 zone_edge = apply_zone_color(tex_d.rgb, color_edge);
    vec3 zone_mid  = apply_zone_color(tex_d.rgb, color_mid);
    vec3 zone_core = apply_zone_color(tex_d.rgb, color_core);

  
    vec3 green_tex = mix(zone_edge, zone_mid,  smoothstep(0.2, 0.5, final_noise));
    green_tex      = mix(green_tex, zone_core, smoothstep(0.55, 0.85, final_noise));


    vec3 final_rgb = mix(tex_d.rgb, green_tex, effect_intensity);

    
    float acid_mask = smoothstep(0.6, 0.9, final_noise) * effect_intensity;
    vec3 acid_glow  = vec3(
        color_core.r * final_noise * 0.5,  
        color_core.g * final_noise * 0.8,  
        0.0                                
    );
    final_rgb = clamp(final_rgb + acid_glow * acid_mask, 0.0, 1.0);

   
    vec2 adjusted_uv = UV - vec2(0.5);
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

    COLOR = vec4(final_rgb, tex_clean.a * mask);
}