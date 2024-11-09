shader_type canvas_item;

uniform float range : hint_range(0.0, 0.1, 0.005)= 0.05;
uniform float noiseQuality : hint_range(0.0, 300.0, 0.1)= 250.0;
uniform float noiseIntensity : hint_range(-0.6, 0.6, 0.0010)= 0.004;
uniform float offsetIntensity : hint_range(-0.1, 0.1, 0.001) = 0.03;
uniform float colorOffsetIntensity : hint_range(0.0, 5.0, 0.001) = 0.9;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;
float rand(vec2 co)
{
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}
float verticalBar(float pos, float UVY, float offset)
{
    float edge0 = (pos - range);
    float edge1 = (pos + range);

    float x = smoothstep(edge0, pos, UVY) * offset;
    x -= smoothstep(pos, edge1, UVY) * offset;
    return x;
}
const float saturation = 0.2;
void fragment()
{
	vec2 uv = UV;
	float UVY = uv.y;
	UVY *= noiseQuality;
	UVY = float(int(UVY)) * (1.0 / noiseQuality);
	float noise = rand(vec2(0.00001 * TIME, UVY)) - 0.5;
	uv.x += noise * noiseIntensity;
	vec2 offsetR = vec2(0.009 * sin(TIME), 0.0) * colorOffsetIntensity;
	vec2 offsetG = vec2(0.0073 * cos(TIME), 0.0) * colorOffsetIntensity;
	float r = texture(TEXTURE, uv + offsetR).r;
	float ra = texture(TEXTURE, uv + offsetR).a;
	float g = texture(TEXTURE, uv + offsetG).g;
	float ga = texture(TEXTURE, uv + offsetG).a;
	float b = texture(TEXTURE, uv).b;
	vec4 tex = vec4(r, g, b, 1.0);
	COLOR.rgb = tex.rgb;
	if (COLOR.a  == 0.) {
		COLOR.a = ga + ra;
	}
}