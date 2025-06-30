shader_type canvas_item;

uniform sampler2D damage : source_color;
uniform bool destroyed = false;
uniform vec3 chassis_color : source_color = vec3(0.4, 0.4, 1.0);

float average(vec4 vector) {
	return (vector.r + vector.b + vector.g) / 3.0;
}

void fragment() {
	vec4 color = texture(damage, UV);

	if (COLOR.a > 0.9 && average(COLOR) < 0.5) {
		COLOR.rgb = chassis_color * average(COLOR) * 2.5;
	}

	if (color.a < 0.001 || color.r >= color.b) {
		COLOR.a = 0.0;
	} else {
		float percent_damaged = color.r / color.b;
		COLOR.rgb *= 1.0 - percent_damaged;
	}

	if (destroyed) {
		COLOR.rgb *= average(COLOR);
	}
}
