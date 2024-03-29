// NOTE: Shader automatically converted from Godot Engine 4.2.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;
uniform vec4 albedo : source_color;

uniform float point_size : hint_range(0,128);
uniform float roughness : hint_range(0,1);
uniform float specular;
uniform float metallic;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

uniform vec3 origin;
uniform vec3 ripple_color: source_color;
uniform float start_time;


void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
}






void fragment() {
	
	ALBEDO = albedo.rgb;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	SPECULAR = specular;
	//ripple effect
	vec3 global_pos = (INV_VIEW_MATRIX * vec4(VERTEX,1.0)).xyz;
	float dist = length(global_pos - origin);
	float t = 5.0*(TIME-start_time)-dist;
	t = t* abs(t);
	float y = 0.0;
	if(t> 0.0 && t<1.0){
		y = 1.0;
	}
	ALBEDO = ripple_color*y + ALBEDO*(1.0-y);
}
