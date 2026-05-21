shader_type canvas_item;

uniform bool pointy_top = true;
uniform float mask_size : hint_range(0.1, 1.0) = 0.5;
uniform float mask_scale_x : hint_range(0.5, 2.0) = 1.0;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    
    vec2 adjusted_uv = UV - vec2(0.5);
    
    adjusted_uv.x *= mask_scale_x;
    vec2 p = abs(adjusted_uv);
    
    float mask = 0.0;
    
    if (pointy_top) {
        
        float q = p.y + p.x * 0.57735026919;
        mask = (p.x <= mask_size * 0.8660254 && q <= mask_size) ? 1.0 : 0.0;
    } else {
        
        float q = p.x + p.y * 0.57735026919;
        mask = (p.y <= mask_size * 0.8660254 && q <= mask_size) ? 1.0 : 0.0;
    }

    COLOR = vec4(tex.rgb, tex.a * mask);
}