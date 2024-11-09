shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}
uniform sampler3D NOISE;
void fragment() {
	float noiseValue = texture(NOISE, vec3(UV, sin(TIME * 0.04) * 0.25 + 0.5)).x;
	noiseValue = noiseValue * noiseValue;
	vec3 tex = texture(TEXTURE, UV).rgb;
	if (noiseValue > 0.1) {
    	COLOR.rgb = tex.rgb * noiseValue;
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
