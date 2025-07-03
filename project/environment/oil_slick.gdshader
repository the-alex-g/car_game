shader_type canvas_item;

void fragment() {
	if (COLOR.a > 0.0) {
		COLOR.rgb = vec3(1.0);
	}
}