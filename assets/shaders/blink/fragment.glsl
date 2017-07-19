vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
	vec4 pixel = Texel(texture, vec2(texture_coords.x, 1.0f - texture_coords.y));
	return vec4(255, 255, 255, pixel.a);
}
