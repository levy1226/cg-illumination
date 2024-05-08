#version 300 es
precision highp float;

// Attributes
in vec3 position;
in vec3 normal;
in vec2 uv;

// Uniforms
// projection 3D to 2D
uniform mat4 world;
uniform mat4 view;
uniform mat4 projection;
// height displacement
uniform vec2 ground_size;
uniform float height_scalar;
uniform sampler2D heightmap;
// material
uniform float mat_shininess;
uniform vec2 texture_scale;
// camera
uniform vec3 camera_position;
// lights
uniform int num_lights;
uniform vec3 light_positions[8];
uniform vec3 light_colors[8]; // Ip

// Output
out vec2 model_uv;
out vec3 diffuse_illum;
out vec3 specular_illum;

void main() {
    // Get initial position of vertex (prior to height displacement)
    vec4 world_pos = world * vec4(position, 1.0);

    // Compute vertex normal
    vec3 world_normal = normalize(normal);

    // Compute diffuse and specular illumination per vertex
    diffuse_illum = vec3(0.0);
    specular_illum = vec3(0.0);
    for (int i = 0; i < num_lights; ++i) {
        // Calculate light direction
        vec3 light_dir = normalize(light_positions[i] - world_pos.xyz);
        
        // Calculate diffuse component
        float diffuse_factor = max(dot(world_normal, light_dir), 0.0);
        diffuse_illum += diffuse_factor * light_colors[i];
        
        // Calculate specular component (Phong lighting model)
        vec3 view_dir = normalize(camera_position - world_pos.xyz);
        vec3 reflect_dir = reflect(-light_dir, world_normal);
        float spec_angle = max(dot(view_dir, reflect_dir), 0.0);
        float specular_factor = pow(spec_angle, mat_shininess);
        specular_illum += specular_factor * light_colors[i];
    }

    // Pass vertex texcoord onto the fragment shader
    model_uv = uv;

    // Transform and project vertex from 3D world-space to 2D screen-space
    gl_Position = projection * view * world_pos;
}
