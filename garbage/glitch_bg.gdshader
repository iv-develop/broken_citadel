shader_type canvas_item;


uniform sampler3D NOISE;
void fragment() {
	float noiseValue = texture(NOISE, vec3(UV * 0.5, sin(TIME * 0.04) * 0.25 + 0.5)).x;
	noiseValue = noiseValue * noiseValue;
	vec3 tex = texture(TEXTURE, UV * 0.5).rgb;
	vec3 c = texture(TEXTURE, UV).rgb;
	if (noiseValue > 0.1) {
    	COLOR.rgb = tex.rgb * noiseValue * 4.0;
		c = COLOR.rgb;
	}
	if (noiseValue > 0.2) {
		COLOR.a = 0.0;
	} else {
		COLOR.rgb = COLOR.rgb * 0.1;
	}
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
