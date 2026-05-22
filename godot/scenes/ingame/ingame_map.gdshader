shader_type canvas_item;

uniform vec4 border_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float border_width : hint_range(0.0, 0.1)= 0.03;

void fragment() {
    vec2 center = vec2(0.5, 0.5);
    float dist = distance(UV, center);
    
    if (dist > 0.5) {
        discard;
    } else if (dist > 0.5 - border_width) {
        COLOR = border_color;
    }
}