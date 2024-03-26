shader_type spatial;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture;

uniform vec4 color1 : source_color;
uniform vec4 color2 : source_color;

void vertex() {
	POSITION = vec4(UV*2.0-1.0, 0.0, 1.0);
}

void fragment() {
	vec4 original = texture(SCREEN_TEXTURE, SCREEN_UV);
	float depthRaw = texture(DEPTH_TEXTURE, SCREEN_UV).x;
    vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depthRaw*depthRaw);
    vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);	
    view.xyz /= view.w;	
	vec3 worldPos = (INV_VIEW_MATRIX * vec4(view.xyz,1.0)).xyz;
	float x = (worldPos.y/10.0)+1.0;
	
	float t = clamp(x*x*x,0.0,1.0);
	if(depthRaw == 1.0){
		t= 0.0;
	}
	ALPHA = 1.0-t;
	ALBEDO = (color1+(color2*sqrt(SCREEN_UV.y))).xyz;
	
	
	
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
