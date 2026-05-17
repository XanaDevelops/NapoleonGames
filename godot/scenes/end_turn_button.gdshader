shader_type canvas_item;

void fragment() {
    vec2 uv = UV - vec2(0.5);
    float dist = length(uv);
    
   
    float outer = step(dist, 0.48);
   
    float inner = step(dist, 0.38);
    
    float ring = outer - inner;
    
    vec4 outer_color = vec4(0.2, 0.5, 1.0, 1.0);   
    vec4 inner_color = vec4(0.1, 0.25, 0.6, 1.0);  
    
    COLOR = mix(vec4(0.0), inner_color, inner) + mix(vec4(0.0), outer_color, ring);
    COLOR.a = outer;
}