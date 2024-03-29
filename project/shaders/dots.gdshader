shader_type spatial;
render_mode unshaded;


uniform sampler2D texture_dots : source_color,filter_nearest,repeat_enable;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 original = texture(texture_dots, FRAGCOORD.xy/8.0);
	ALBEDO = original.rgb;
	ALPHA = original.a;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
