shader_type canvas_item;

uniform vec4 border_color : source_color = vec4(0.831, 0.686, 0.216, 1.0); 
uniform float border_width : hint_range(0.0, 0.1) = 0.03;
uniform float corner_radius : hint_range(0.0, 0.5) = 0.05;

void fragment() {
    vec2 uv = UV;
    vec4 tex = texture(TEXTURE, uv);
    
   
    float left   = uv.x;
    float right  = 1.0 - uv.x;
    float top    = uv.y;
    float bottom = 1.0 - uv.y;
    
    float min_dist = min(min(left, right), min(top, bottom));
    
   
    vec2 corner_uv = abs(uv - 0.5) - (0.5 - corner_radius);
    float corner_dist = length(max(corner_uv, vec2(0.0))) - corner_radius;
    
    if (corner_dist > 0.0) {
        discard;
    }
    
 
    if (min_dist < border_width) {
        COLOR = border_color;
    } else {
        COLOR = tex;
    }
}