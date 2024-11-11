shader_type canvas_item;

uniform sampler2D glitch;
uniform vec2 scale = vec2(1.0, 1.0);
uniform bool global_uv;

void fragment() {
	vec2 puv = round((UV * scale) / TEXTURE_PIXEL_SIZE + 0.5) * TEXTURE_PIXEL_SIZE + 0.2;
	if (dot(COLOR.rgb - vec3(1.), COLOR.rgb - vec3(1.)) < 0.01){
		COLOR.rgb = texture(glitch, puv).rgb * 2.0;
	} else {
		COLOR.rgb *= 2.;
	}
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
