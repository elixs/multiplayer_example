shader_type canvas_item;

uniform float radius = 0.5;
uniform float roll_speed = 0.1; // Higher default for fast rolling
uniform float edge_warp_reduction : hint_range(0.0, 1.0) = 0.6; // 0.0 = full 3D warp, 1.0 = flat 2D
instance uniform vec2 texture_offset = vec2(0.0);
uniform sampler2D outline_texture : filter_nearest; 

void fragment() {
    vec2 uv = UV - 0.5;
    
    if (length(uv) < radius) {
        float z = sqrt(radius * radius - dot(uv, uv));
        
        // standard 3D spherical projection
        vec2 spherical_uv = uv + (texture_offset * roll_speed * (radius / (z + 8.0)));
        
        // flat 2D translation projection
        vec2 flat_uv = uv + (texture_offset * roll_speed);
        
        // Linear blend between 3D sphere and flat movement to reduce edge warping
        vec2 final_uv = mix(spherical_uv, flat_uv, edge_warp_reduction);
        
        // Wrap coordinates so the high-res texture loops cleanly
        vec2 wrapped_uv = fract(final_uv + 0.5);
        
        vec4 dung_color = texture(TEXTURE, wrapped_uv);
		vec4 outline_color = texture(outline_texture, UV);
		
		COLOR = mix(dung_color, outline_color, outline_color.a);
    } else {
        vec4 outline_color = texture(outline_texture, UV);
        COLOR = outline_color;
    }
}
