shader_type spatial;

uniform vec3 albedo : source_color;
uniform vec3 albedo2 : source_color;
uniform float metallic : hint_range(0.0,1.0) = 0;
uniform float roughness : hint_range(0.0,1.0) = 0.02;
uniform float specular : hint_range(0.0,1.0) = 0.5;
uniform vec3 emission : source_color;
uniform vec3 emission2 : source_color;
uniform float fresnel_amount : hint_range(0.0,100.0) = 15;
uniform sampler2D wave;
uniform sampler2D texture_normal;
uniform sampler2D texture_normal2;
uniform sampler2D heat_texture;
uniform sampler2D heat_texture2;

uniform vec2 wave_direction = vec2(2.0,0.0);
uniform vec2 wave_direction2 = vec2(0.0,1.0);
uniform float time_scale : hint_range(0.0,0.2,0.005) = 0.02;
uniform float noise_scale = 15.0;
uniform float height_scale = 0.15;

uniform vec4 color_deep : source_color;
uniform vec4 color_shallow : source_color;
uniform float beers_law = 2.0;
uniform float depth_offset = -0.75;

varying float height;
varying vec3 world_position;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear;
uniform sampler2D SCREEN_TEXTURE : hint_depth_texture, filter_linear;

float fresnel(float amount, vec3 normal, vec3 view){
	return pow((1.0 - clamp(dot(normalize(normal),normalize(view)),0.0,1.0)),amount);
}

void edge(float depth){
	depth = 2.0 * depth -1.0;
	//return near * far / (far + depth * (near - far));
}

void vertex(){
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	height = texture(wave, world_position.xz / noise_scale + TIME * time_scale).r;
	VERTEX.y += height * height_scale;
}

void fragment() {
	float depth_texture = texture(DEPTH_TEXTURE, SCREEN_UV).r * 2.0 - 1.0;
	float depth = PROJECTION_MATRIX[3][2] / (depth_texture + PROJECTION_MATRIX[2][2]);
	float depth_blend = exp((depth+VERTEX.z + depth_offset) * -beers_law);
	depth_blend = clamp(1.0 - depth_blend, 0.0, 1.0);	
	float depth_blend_power = clamp(pow(depth_blend, 2.5), 0.0, 1.0);

	vec3 screen_color = textureLod(SCREEN_TEXTURE, SCREEN_UV, depth_blend_power * 2.5).rgb;
	vec3 depth_color = mix(color_shallow.rgb, color_deep.rgb, depth_blend_power);
	vec3 color = mix(screen_color * depth_color, depth_color * 0.25, depth_blend_power * 0.5);
	
	
	vec2 time = (TIME * wave_direction) * time_scale;
	vec2 time2 = (TIME * wave_direction2) * time_scale;
	
	vec3 normal_blend = mix(texture(texture_normal,world_position.xz/noise_scale + time).rgb , texture(texture_normal2,world_position.xz/noise_scale + time2).rgb , 0.5);
	
	float fresnel = fresnel(fresnel_amount, NORMAL, VIEW);
	
	vec3 heat = texture(heat_texture,world_position.xz / noise_scale + (TIME * wave_direction * time_scale)).rgb * emission.rgb;
	vec3 heat2 = texture(heat_texture2,world_position.xz / noise_scale + (TIME * wave_direction2 * time_scale)).rgb * emission2.rgb;
	
	vec3 surface_color = mix(albedo, albedo2, fresnel);
	vec3 emission_color = mix(heat, heat2, 0.5);
	ALBEDO = surface_color; //mix(surface_color, color, 0.75);
	METALLIC = metallic;
	ROUGHNESS = roughness;
	EMISSION = emission_color.rgb * 5.0;
	//SPECULAR = specular;
	NORMAL_MAP = normal_blend;
}
