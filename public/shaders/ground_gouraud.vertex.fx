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
// material
uniform vec2 texture_scale;
uniform float mat_shininess;
// camera
uniform vec3 camera_position;
// lights
uniform int num_lights;
uniform vec3 light_positions[8];
uniform vec3 light_colors[8]; // Ip

// Output
out vec2 model_uv;
out vec3 vertex_normal;
out vec3 vertex_view_dir;
out vec3 vertex_light_dir;
out vec3 diffuse_illum;
out vec3 specular_illum;

void main() {
    // Get initial position of vertex (prior to height displacement)
    vec4 world_pos = world * vec4(position, 1.0);

    // Pass vertex normal to the fragment shader
    vertex_normal = normalize(mat3(transpose(inverse(world))) * normal);

    // Compute the view direction per vertex
    vertex_view_dir = normalize(camera_position - world_pos.xyz);

    // Compute the light direction per vertex
    vertex_light_dir = vec3(0.0);
    for (int i = 0; i < num_lights; ++i) {
        vertex_light_dir += normalize(light_positions[i] - world_pos.xyz);
    }

    // Pass vertex texcoord onto the fragment shader
    model_uv = uv;

    // Calculate diffuse and specular illumination per vertex
    diffuse_illum = vec3(0.0);
    specular_illum = vec3(0.0);
    for (int i = 0; i < num_lights; ++i) {
        // Diffuse illumination
        vec3 L = normalize(light_positions[i] - world_pos.xyz);
        float diffuse_factor = max(dot(vertex_normal, L), 0.0);
        diffuse_illum += diffuse_factor * light_colors[i];

        // Specular illumination
        vec3 H = normalize(vertex_view_dir + L);
        float specular_factor = pow(max(dot(vertex_normal, H), 0.0), mat_shininess);
        specular_illum += specular_factor * light_colors[i];
    }

    // Transform and project vertex from 3D world-space to 2D screen-space
    gl_Position = projection * view * world_pos;
}
