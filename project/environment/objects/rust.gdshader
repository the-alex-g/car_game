shader_type canvas_item;

uniform float rust_cutoff = 0.3;
uniform sampler2D noise;
uniform vec3 rust_color : source_color;
instance uniform vec2 noise_offset = vec2(0.0);

bool is_grey(vec3 color, float delta) {
	return abs(color.r - color.g) < delta && abs(color.g - color.b) < delta;
}

float distance_from_center(vec2 uv) {
	vec2 offset = uv - vec2(0.5);
	return length(offset);
}

float get_rust_strength(vec2 uv) {
	float base = texture(noise, (uv + noise_offset) / 5.0).r;
	base *= sin(distance_from_center(uv) * PI);
	return base;
}

void fragment() {
	if (COLOR.a > 0.5 && is_grey(COLOR.rgb, 0.2)) {
		float rust_strength = get_rust_strength(UV);
		if (rust_strength > rust_cutoff) {
			COLOR.rgb = mix(COLOR.rgb, rust_color, rust_strength - rust_cutoff);
		}
	}
}