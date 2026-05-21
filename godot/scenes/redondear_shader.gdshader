shader_type canvas_item;

uniform float radius : hint_range(0.0, 1.0) = 0.1;
// Nuevo parámetro para controlar qué tan suave es el borde
uniform float smoothing : hint_range(0.0, 0.1) = 0.01; 

void fragment() {
    // Obtenemos el color original de la textura
    vec4 tex_color = texture(TEXTURE, UV);
    vec2 uv = UV;
    vec2 size = vec2(1.0, 1.0);
    
    // Calculamos la distancia a la esquina más cercana
    vec2 corner_pos = min(uv, size - uv);
    
    // Si estamos dentro del área donde debería estar la curva...
    if (corner_pos.x < radius && corner_pos.y < radius) {
        vec2 dist = vec2(radius) - corner_pos;
        float current_dist = length(dist);
        
        // Usamos smoothstep para crear un difuminado suave en el borde
        // Si la distancia se acerca al radio, la opacidad baja de 1.0 a 0.0 suavemente
        float alpha_mask = 1.0 - smoothstep(radius - smoothing, radius, current_dist);
        
        // Multiplicamos la transparencia de la imagen por nuestra máscara
        tex_color.a *= alpha_mask;
    }
    
    // Aplicamos el color final
    COLOR = tex_color;
}