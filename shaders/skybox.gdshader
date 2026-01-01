/** thanks to https://kelvinvanhoorn.com/2024/12/07/skybox-tutorial-godot **/

shader_type sky;

group_uniforms Directions;
uniform vec3 sun_dir;
uniform vec3 moon_dir;

group_uniforms SkyGradients;
/** The gradient texture that is sampled using the Sun-Zenith angle */
uniform sampler2D sun_zenith_gradient : source_color, repeat_disable;
/** The gradient texture that is sampled using the View-Zenith angle */
uniform sampler2D view_zenith_gradient : source_color, repeat_disable;
/** The gradient texture that is sampled using the Sun-View angle */
uniform sampler2D sun_view_gradient : source_color, repeat_disable;

group_uniforms Sun;
uniform float sun_radius : hint_range(0, 1) = 0.05;
uniform vec3 sun_color : source_color = vec3(1.0, 1.0, 1.0);

float get_sun_mask(float sun_view_dot, float radius) {
	float step_radius = 1.0 - radius * radius;
	return step(step_radius, sun_view_dot);
}

void sky() {
	vec3 view_dir = EYEDIR;

	/** from guide
	"While I've been talking about angles all this time we're actually only going to calculate
	the dot product between the different directions. Mathematically this corresponds to the
	cosine of the angle between the directions (if both vectors are normalized). For our use case this
	is fine, though you should note that the cosine of an angle isn't linear (it flattens near 0° and 180°).
	**/
	float sun_view_dot = dot(sun_dir, view_dir);
	float sun_zenith_dot = sun_dir.y;
	float view_zenith_dot = view_dir.y;
	float sun_moon_dot = dot(sun_dir, moon_dir);

	float sun_view_dot01 = (sun_view_dot + 1.0) * 0.5;
	float sun_zenith_dot01 = (sun_zenith_dot + 1.0) * 0.5;

	// sky colors
	vec3 sun_zenith_color = texture(sun_zenith_gradient, vec2(sun_zenith_dot01, 0.5)).rgb;
	vec3 view_zenith_color = texture(view_zenith_gradient, vec2(sun_zenith_dot01, 0.5)).rgb;
	float vz_mask = pow(clamp(1.0 - view_zenith_dot, 0.0, 1.0), 4);
	vec3 sun_view_color = texture(sun_view_gradient, vec2(sun_zenith_dot01, 0.5)).rgb;
	float sv_mask = pow(clamp(sun_view_dot, 0.0, 1.0), 4);

	float sun_mask = get_sun_mask(sun_view_dot, sun_radius);
	vec3 sun_output = sun_color * sun_mask;
	vec3 sky_output = sun_zenith_color + (vz_mask * view_zenith_color) + (sv_mask * sun_view_color);
	vec3 output = sky_output + sun_output;
	COLOR = output;
}