shader_type canvas_item;


uniform vec4 color_core : source_color = vec4(1.0, 1.0, 1.0, 1.0);  
uniform vec4 color_mid  : source_color = vec4(1.0, 0.8, 0.2, 1.0);   
uniform vec4 color_edge : source_color = vec4(0.4, 0.3, 0.0, 1.0);   


uniform float wave_speed       = 0.5;  
uniform float wave_amplitude   = 0.01; 
uniform float wave_frequency   = 2.0;  
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

    
    float breath = sin(TIME * 2.0) * wave_amplitude * effect_intensity;
    vec2 distorted_uv = uv - vec2(0.0, breath * (1.0 - uv.y)); 
    
    vec4 tex_d = texture(TEXTURE, distorted_uv);

   
    float divine_pulse = sin(TIME * 8.0) * 0.5 + 0.5;
    divine_pulse = pow(divine_pulse, 4.0);

   
    vec2 noise_uv = distorted_uv * vec2(wave_frequency, wave_frequency * 0.2);
    noise_uv.y += TIME * wave_speed;
    
    float n1 = noise(noise_uv);
    float n2 = noise(noise_uv * 2.0 + vec2(TIME * 0.1)) * 0.5;
    float final_noise = clamp((n1 + n2) / 1.5, 0.0, 1.0);
    
    float vertical_fade = pow(distorted_uv.y, 1.2); 
    
    float light_mask = smoothstep(0.3, 1.0, final_noise) * vertical_fade * effect_intensity;

 
    float tex_lum = dot(tex_d.rgb, vec3(0.299, 0.587, 0.114));
    
   
    vec3 light_color = mix(color_mid.rgb, color_core.rgb, smoothstep(0.1, 0.6, light_mask));

    
    vec3 divine_coloring = tex_d.rgb + (light_color * tex_lum * light_mask * (4.0 + divine_pulse * 3.0));

   
    float sheen_diagonal = (distorted_uv.x + distorted_uv.y * 0.5);
    float shine_wave = sin(sheen_diagonal * 5.0 - TIME * wave_speed * 10.0) * 0.5 + 0.5;
    float sheen_mask = smoothstep(0.9, 1.0, shine_wave);
    
    vec3 surface_sheen = color_core.rgb * sheen_mask * light_mask * (3.0 + divine_pulse * 4.0);

    
    float aura_pulse = (sin(TIME * 3.0) * 0.5 + 0.5) * 0.3; 
    vec3 base_glow = color_edge.rgb * aura_pulse * vertical_fade * effect_intensity;

    vec3 final_rgb = divine_coloring + base_glow + surface_sheen;
    
    final_rgb = clamp(final_rgb, 0.0, 1.0);

  
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