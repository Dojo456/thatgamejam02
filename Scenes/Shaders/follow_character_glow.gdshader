shader_type canvas_item;

// make editable uniforms to define outline color & width
// outline color should be HDR based (ie: components above 1)
uniform vec4 outline_color : source_color = vec4(0.0, 2, 2, 1.0);
uniform float outline_width = 2.0;

void vertex() {
	// Called for every vertex the material is visible on.
}


void fragment() {
	// Called for every pixel the material is visible on.
	vec4 tex_color = texture(TEXTURE, UV); // get pixel color
	float outline = 0.0; // tracks opaque pixels nearby
	
	// Check neighbouring two pixels in each direction 
	for (float x = -outline_width; x <= outline_width; x += 1.0) {
		for (float y = -outline_width; y <= outline_width; y += 1.0) {
			vec2 offset = vec2(x, y) * TEXTURE_PIXEL_SIZE;
			float alpha = texture(TEXTURE, UV + offset).a;
			outline = max(outline, alpha);
		}
	}
	// draw outline on transparent pixel that's also an outline
	if (tex_color.a == 0.0 && outline > 0.0) {
		COLOR = outline_color;
	} 
	else {
		COLOR = tex_color;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
