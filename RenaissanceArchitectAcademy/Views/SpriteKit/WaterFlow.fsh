// WaterFlow.fsh — Renaissance watercolor water flow shader
// Applied via fillShader on ribbon-shaped SKShapeNode rivers
//
// Built-in uniforms from SpriteKit:
//   u_time        — elapsed seconds (auto-incremented)
//   v_tex_coord   — normalized UV (0..1) within node bounding box
//
// Custom uniforms:
//   u_base_color  — vec3 RGB water color (e.g. renaissanceBlue)
//   u_flow_angle  — float radians, direction water flows

void main() {
    vec2 uv = v_tex_coord;

    // Rotate UV to align flow with river direction
    float ca = cos(u_flow_angle);
    float sa = sin(u_flow_angle);
    vec2 flowUV = vec2(
        uv.x * ca - uv.y * sa,
        uv.x * sa + uv.y * ca
    );

    // Slow scrolling along flow direction — gentle watercolor drift
    float flow = flowUV.x + u_time * 0.08;

    // Two sine ripple layers — mimics watercolor brush wash
    float ripple1 = sin(flow * 12.0 + flowUV.y * 4.0) * 0.04;
    float ripple2 = sin(flow * 7.0 - flowUV.y * 6.0 + 1.5) * 0.03;

    // Subtle brightness variation
    float brightness = 1.0 + ripple1 + ripple2;

    // Edge fade — soft watercolor bleed at river boundaries
    float edgeFade = smoothstep(0.0, 0.12, uv.y) * smoothstep(1.0, 0.88, uv.y);

    vec4 color = vec4(u_base_color * brightness, 0.5 * edgeFade);

    gl_FragColor = color * SKDefaultShading();
}
