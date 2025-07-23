shader_type canvas_item;

uniform sampler2D noise : source_color;
uniform sampler2D variance : source_color;

void fragment() {
	vec4 noise_val = texture(noise, SCREEN_UV + texture(variance, SCREEN_UV + vec2(sin(TIME), cos(TIME)) / 100.0).rg);
	COLOR = noise_val;
	COLOR.rgb += vec3(sin(TIME)) * noise_val.r / 10.0;
}