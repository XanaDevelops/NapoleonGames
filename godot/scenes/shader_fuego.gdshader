shader_type canvas_item;

uniform vec4 color_core : source_color = vec4(1.0, 0.9, 0.0, 1.0); 
uniform vec4 color_mid : source_color = vec4(1.0, 0.4, 0.0, 1.0);  
uniform vec4 color_edge : source_color = vec4(0.8, 0.1, 0.0, 1.0); 

uniform float wave_speed = 7.0;
uniform float wave_amplitude = 0.05;
uniform float wave_frequency = 13.0;

uniform float flame_squash_factor = 2.2; 
uniform float core_size : hint_range(0.0, 1.0) = 0.12; 
uniform float mid_size  : hint_range(0.0, 1.0) = 0.40; 
uniform float edge_size : hint_range(0.0, 1.0) = 0.65; 

uniform float effect_intensity : hint_range(0.0, 1.0) = 0.0;
uniform bool pointy_top = true; 

// === NUEVOS CONTROLES DE CALIBRACIÓN PARA TU TABLERO ===
uniform float mask_size : hint_range(0.1, 1.0) = 0.5;      // Escala general del hexágono
uniform float mask_scale_x : hint_range(0.5, 2.0) = 1.0;   // Ajusta el ancho si se ve estirado

void fragment() {
 
    vec2 distorted_uv = UV;
    float wobble_mask = 1.0 - UV.y; 
    distorted_uv.x += sin(distorted_uv.y * wave_frequency + TIME * wave_speed) * (wave_amplitude * wobble_mask) * effect_intensity;
    
    vec4 tex_color = texture(TEXTURE, distorted_uv);
    
  
    vec2 flame_center = vec2(0.5, 1.0);
    vec2 scaled_uv = distorted_uv;
    scaled_uv.x = (scaled_uv.x - 0.5) * flame_squash_factor + 0.5;
    
    float dist_from_center = distance(scaled_uv, flame_center);
    
    vec4 radial_color = mix(color_core, color_mid, smoothstep(core_size, mid_size, dist_from_center));
    radial_color = mix(radial_color, color_edge, smoothstep(mid_size, edge_size, dist_from_center));
    
    vec4 fire_color = mix(tex_color, tex_color * radial_color * 2.0, effect_intensity);
    
    // 3. MÁSCARA HEXAGONAL AJUSTABLE
    // Centramos la UV en (0,0)
    vec2 adjusted_uv = UV - vec2(0.5);
    
    // Multiplicamos el eje X por nuestro factor para ensanchar o estrechar el hexágono
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
    
    COLOR = vec4(fire_color.rgb, tex_color.a * mask);
}