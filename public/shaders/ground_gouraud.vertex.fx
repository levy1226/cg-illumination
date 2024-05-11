#version 300 es
precision highp float;

// Attributes
in vec3 position;
in vec2 uv;

// Uniforms
uniform mat4 world;
uniform mat4 view;
uniform mat4 projection;
uniform vec3 camera_position;
uniform int num_lights;
uniform vec3 light_positions[8];
uniform vec3 light_colors[8];
uniform sampler2D heightmap;
uniform vec2 ground_size;
uniform float height_scalar;
uniform float mat_shininess;
uniform vec2 texture_scale;

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

    // Pass vertex texcoord onto the fragment shader
    model_uv = uv;

    // Compute vertex normal (approximated using heightmap)
    float dx = texture(heightmap, uv + vec2(texture_scale.x, 0.0)).r - texture(heightmap, uv - vec2(texture_scale.x, 0.0)).r;
    float dy = texture(heightmap, uv + vec2(0.0, texture_scale.y)).r - texture(heightmap, uv - vec2(0.0, texture_scale.y)).r;
    vec3 tangent = vec3(2.0 * ground_size.x / texture_scale.x, 0.0, dx * height_scalar);
    vec3 bitangent = vec3(0.0, 2.0 * ground_size.y / texture_scale.y, dy * height_scalar);
    vertex_normal = normalize(cross(tangent, bitangent));

    // Compute direction from vertex to camera
    vertex_view_dir = normalize(camera_position - world_pos.xyz);

    // Calculate lighting for each light source
    diffuse_illum = vec3(0.0);
    specular_illum = vec3(0.0);
    for (int i = 0; i < num_lights; ++i) {
        // Compute direction from vertex to light
        vertex_light_dir = normalize(light_positions[i] - world_pos.xyz);

        // Compute diffuse and specular contributions
        float diffuse_factor = max(dot(vertex_normal, vertex_light_dir), 0.0);
        vec3 reflected_light_dir = reflect(-vertex_light_dir, vertex_normal);
        float specular_factor = pow(max(dot(reflected_light_dir, vertex_view_dir), 0.0), mat_shininess);

        // Accumulate illumination
        diffuse_illum += diffuse_factor * light_colors[i];
        specular_illum += specular_factor * light_colors[i];
    }

    // Transform and project vertex from 3D world-space to 2D screen-space
    gl_Position = projection * view * world_pos;
}
