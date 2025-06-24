shader_type canvas_item;

uniform sampler2D damage;
uniform bool destroyed = false;

void fragment() {
	vec4 color = texture(damage, UV);
	if (color.a < 0.001 || color.r >= color.b) {
		COLOR.a = 0.0;
	} else {
		float percent_damaged = color.r / color.b;
		COLOR.rgb *= 1.0 - percent_damaged;
	}
	
	if (destroyed) {
		COLOR.rgb *= (COLOR.r + COLOR.b + COLOR.g) / 3.0;
	}
}
