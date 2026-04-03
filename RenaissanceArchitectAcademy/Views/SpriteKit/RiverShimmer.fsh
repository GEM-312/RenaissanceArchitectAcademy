// RiverShimmer.fsh — Subtle animated ripple overlay for painted terrain rivers
// Applied via fillShader on transparent ribbons placed over river paths.
// Produces NO solid color — only shimmer/ripple that brightens painted water underneath.
//
// Built-in: u_time, v_tex_coord
// Custom:   u_flow_angle (radians), u_intensity (0.0-1.0)

void main() {
    vec2 uv = v_tex_coord;

    // Rotate UV to align with river flow direction
    float ca = cos(u_flow_angle);
    float sa = sin(u_flow_angle);
    vec2 flowUV = vec2(
        uv.x * ca - uv.y * sa,
        uv.x * sa + uv.y * ca
    );

    // Layer 1: Slow broad ripples
    float ripple1 = sin(flowUV.x * 8.0 + u_time * 0.5 + flowUV.y * 3.0) * 0.5 + 0.5;

    // Layer 2: Faster fine ripples
    float ripple2 = sin(flowUV.x * 18.0 + u_time * 1.2 - flowUV.y * 5.0 + 2.0) * 0.5 + 0.5;

    // Layer 3: Diagonal shimmer — specular highlights on water surface
    float shimmer = sin((flowUV.x + flowUV.y) * 25.0 + u_time * 0.8) * 0.5 + 0.5;
    shimmer = pow(shimmer, 4.0);  // Sharpen to bright peaks

    // Combine layers
    float combined = ripple1 * 0.3 + ripple2 * 0.2 + shimmer * 0.5;

    // Edge fade — soft falloff at river boundaries
    float edgeFade = smoothstep(0.0, 0.15, uv.y) * smoothstep(1.0, 0.85, uv.y);
    float flowEdge = smoothstep(0.0, 0.05, uv.x) * smoothstep(1.0, 0.95, uv.x);
    float fade = edgeFade * flowEdge;

    // Output: mostly transparent with bright shimmer peaks
    // Additive blend on node → brightens painted river underneath
    float alpha = combined * fade * u_intensity * 0.18;

    gl_FragColor = vec4(1.0, 1.0, 1.0, alpha) * SKDefaultShading();
}
