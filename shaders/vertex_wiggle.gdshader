shader_type spatial;
render_mode world_vertex_coords;

uniform vec3 color: source_color;
uniform sampler2D tex: filter_nearest;

uniform float influence: hint_range(0.0, 1.0) = 1.0;
group_uniforms displacement_parameters;
uniform vec3 max_displacement;

uniform float displacement_speed: hint_range(0, 200) = 0.25;

uniform sampler3D x_noise;
uniform sampler3D y_noise;
uniform sampler3D z_noise;

void vertex() {

	float adjusted_time = TIME * displacement_speed;

	vec3 displacement = vec3(0);

	displacement.x = texture(x_noise, VERTEX.xyz + adjusted_time).x;
	displacement.y = texture(y_noise, VERTEX.xyz + adjusted_time).y;
	displacement.z = texture(z_noise, VERTEX.xyz + adjusted_time).z;
	displacement -= 0.5;
	VERTEX += displacement * max_displacement * influence;
}

void fragment() {
	ALBEDO = texture(tex, UV).rgb * color;
}
