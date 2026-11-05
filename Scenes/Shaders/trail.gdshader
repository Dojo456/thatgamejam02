shader_type canvas_item;

uniform vec4 trail_color : source_color = vec4(0.0, 2, 2, 1.0);


void fragment() {
	// Called for every pixel the material is visible on.
	// draw a circle of radius trail_size
	if (sqrt(pow((UV.x - 0.5), 2.0) + pow((UV.y - 0.5), 2.0)) <= 0.5)
	{
		COLOR = trail_color;
	}
	else
	{
		COLOR = vec4(0);
	}
	
	//use a smoothstep to control the alpha

	
	
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
