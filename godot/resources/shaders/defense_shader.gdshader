shader_type canvas_item;

uniform vec4 color_core : source_color = vec4(0.9, 0.97, 1.0,  1.0); 
uniform vec4 color_mid  : source_color = vec4(0.3, 0.7,  1.0,  1.0); 
uniform vec4 color_edge : source_color = vec4(0.0, 0.2,  0.85, 1.0); 

uniform float wave_speed          = 1.2;  
uniform float wave_amplitude      = 0.08; 
uniform float wave_frequency      = 6.0;  
uniform float flame_squash_factor = 1.0;  
uniform float effect_intensity : hint_range(0.0, 1.0) = 1.0;

uniform bool  pointy_top   = true;        
uniform float mask_size    : hint_range(0.1, 1.0) = 0.5;
uniform float mask_scale_x : hint_range(0.5, 2.0) = 1.0;

void fragment() {
    vec2 uv = UV;
    vec4 tex_clean = texture(TEXTURE, uv);

    vec2 p = uv - vec2(0.5);
    p.x *= mask_scale_x;

    
    vec2 ap = abs(p);
    float hex_d;
    if (pointy_top) {
        float q = ap.y + ap.x * 0.57735026919;
        hex_d = max(ap.x, q) / mask_size;
    } else {
        float q = ap.x + ap.y * 0.57735026919;
        hex_d = max(ap.y, q) / mask_size;
    }

    
    float top = -p.y * 1.2;
    float sides = abs(p.x);
    float bottom = p.y + (p.x * p.x) * 2.5;
    float shield_d = max(max(sides, top), bottom) / mask_size;

   
    float ring_time   = 1.0;
    float total_time  = ring_time * 3.0 + 0.5;
    float t           = mod(TIME * wave_speed, total_time);

    vec3  shield_rgb  = vec3(0.0);
    float shield_glow = 0.0;

    float center_area = clamp(1.0 - shield_d * 4.0, 0.0, 1.0);

    
    float t1 = clamp(t, 0.0, ring_time) / ring_time;               
    float ease1 = 1.0 - pow(1.0 - t1, 2.0); 
    
    float r1 = mix(0.0, 0.35, ease1); 
    float g1 = smoothstep(wave_amplitude, 0.0, abs(shield_d - r1)) * (1.0 - t1);
    float fill1 = smoothstep(r1, r1 - 0.08, shield_d) * 0.25 * (1.0 - t1);
    
    vec3  c1 = mix(color_edge.rgb, color_mid.rgb, t1);
    shield_rgb  += c1 * (g1 + fill1);
    shield_glow  = max(shield_glow, g1 + fill1);
    
    
    shield_rgb  += color_core.rgb * smoothstep(0.35, 0.0, t1) * center_area * 2.5;

    
    float t2 = clamp(t - ring_time, 0.0, ring_time) / ring_time;
    float ease2 = 1.0 - pow(1.0 - t2, 2.0);
    
    float r2 = mix(0.35, 0.70, ease2);        
    float g2 = smoothstep(wave_amplitude, 0.0, abs(shield_d - r2)) * (1.0 - t2);
    float fill2 = smoothstep(r2, r2 - 0.08, shield_d) * 0.25 * (1.0 - t2);
    
    vec3  c2 = mix(color_mid.rgb, color_core.rgb, t2); 
    shield_rgb  += c2 * (g2 + fill2);
    shield_glow  = max(shield_glow, g2 + fill2);

    
    float t3 = clamp(t - ring_time * 2.0, 0.0, ring_time) / ring_time;
    float ease3 = 1.0 - pow(1.0 - t3, 2.0);
    
    float r3 = mix(0.70, 1.00, ease3);                             
    float g3 = smoothstep(wave_amplitude, 0.0, abs(shield_d - r3)) * (1.0 - t3);
    float fill3 = smoothstep(r3, r3 - 0.08, shield_d) * 0.25 * (1.0 - t3);
    
    vec3  c3 = color_core.rgb; 
    shield_rgb  += c3 * (g3 + fill3);
    shield_glow  = max(shield_glow, g3 + fill3);

    
    float burst_t    = clamp(t - ring_time * 3.0, 0.0, 0.5) / 0.5; 
    float burst_fade = sin(burst_t * 3.14159);                        
    float burst_area = clamp(1.0 - shield_d, 0.0, 1.0);                
    float burst      = burst_fade * burst_area;

    shield_rgb  += color_core.rgb * burst * 5.0;   
    shield_rgb  += color_mid.rgb  * burst * 2.0;   
    shield_glow  = max(shield_glow, burst * 0.95);

    
    vec3 final_rgb = clamp(tex_clean.rgb + shield_rgb * effect_intensity, 0.0, 1.0);

    
    float mask = (hex_d <= 1.0) ? 1.0 : 0.0;

    float final_alpha = max(tex_clean.a, shield_glow * effect_intensity * 0.9);
    COLOR = vec4(final_rgb, final_alpha * mask);
}