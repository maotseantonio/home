// Generated by mpv-libretro

//!PARAM BEAM_MAX_WIDTH
//!DESC     Custom [If   BP=0.00] MAX BEAM WIDTH
//!TYPE CONSTANT float
//!MINIMUM 0
//!MAXIMUM 1
1

//!PARAM BEAM_MIN_WIDTH
//!DESC     Custom [If   BP=0.00] MIN BEAM WIDTH
//!TYPE CONSTANT float
//!MINIMUM 0
//!MAXIMUM 1
1

//!PARAM BEAM_PROFILE
//!DESC   BEAM PROFILE (BP)
//!TYPE CONSTANT float
//!MINIMUM 0
//!MAXIMUM 2
0

//!PARAM COLOR_BOOST
//!DESC     Custom [If   BP=0.00] COLOR BOOST
//!TYPE CONSTANT float
//!MINIMUM 1
//!MAXIMUM 2
1.3

//!PARAM CRT_ANTI_RINGING
//!DESC   ANTI RINGING
//!TYPE CONSTANT float
//!MINIMUM 0
//!MAXIMUM 1
1

//!PARAM CRT_HYLLIAN
//!DESC [CRT-HYLLIAN PARAMS]
//!TYPE CONSTANT float
//!MINIMUM 0
//!MAXIMUM 0
0

//!PARAM HFILTER_PROFILE
//!DESC   HORIZONTAL FILTER PROFILE [ HERMITE | CATMULL-ROM ]
//!TYPE CONSTANT float
//!MINIMUM 0
//!MAXIMUM 1
0

//!PARAM InputGamma
//!DESC   INPUT GAMMA
//!TYPE CONSTANT float
//!MINIMUM 0
//!MAXIMUM 5
2.4

//!PARAM MASK_INTENSITY
//!DESC   MASK INTENSITY
//!TYPE CONSTANT float
//!MINIMUM 0
//!MAXIMUM 1
0.7

//!PARAM OutputGamma
//!DESC   OUTPUT GAMMA
//!TYPE CONSTANT float
//!MINIMUM 0
//!MAXIMUM 5
2.2

//!PARAM PHOSPHOR_LAYOUT
//!DESC   PHOSPHOR LAYOUT
//!TYPE CONSTANT float
//!MINIMUM 0
//!MAXIMUM 24
4

//!PARAM SCANLINES_STRENGTH
//!DESC     Custom [If   BP=0.00] SCANLINES STRENGTH
//!TYPE CONSTANT float
//!MINIMUM 0
//!MAXIMUM 1
0.58

//!PARAM SHARPNESS_HACK
//!DESC   SHARPNESS_HACK
//!TYPE CONSTANT float
//!MINIMUM 1
//!MAXIMUM 4
1

//!PARAM VSCANLINES
//!DESC   VERTICAL SCANLINES [ OFF | ON ]
//!TYPE CONSTANT float
//!MINIMUM 0
//!MAXIMUM 1
0

//!HOOK MAIN
//!COMPONENTS 4
//!DESC sRGB to linear RGB
//!SAVE MAIN_RGB
//!BIND HOOKED

vec4 hook() {
	return linearize(HOOKED_tex(HOOKED_pos));
}

//!HOOK MAIN
//!COMPONENTS 4
//!DESC crt-hyllian.slang
//!WIDTH OUTPUT.width 1 *
//!HEIGHT OUTPUT.height 1 *
//!BIND MAIN_RGB
//!BIND HOOKED

vec4 vertex_gl_Position;
struct _param_ {
    float BEAM_PROFILE;
    float HFILTER_PROFILE;
    float BEAM_MIN_WIDTH;
    float BEAM_MAX_WIDTH;
    float SCANLINES_STRENGTH;
    float COLOR_BOOST;
    float SHARPNESS_HACK;
    float PHOSPHOR_LAYOUT;
    float MASK_INTENSITY;
    float CRT_ANTI_RINGING;
    float InputGamma;
    float OutputGamma;
    float VSCANLINES;
} param = _param_(float(BEAM_PROFILE), float(HFILTER_PROFILE), float(BEAM_MIN_WIDTH), float(BEAM_MAX_WIDTH), float(SCANLINES_STRENGTH), float(COLOR_BOOST), float(SHARPNESS_HACK), float(PHOSPHOR_LAYOUT), float(MASK_INTENSITY), float(CRT_ANTI_RINGING), float(InputGamma), float(OutputGamma), float(VSCANLINES));
struct _global_ {
    mat4 MVP;
    vec4 OutputSize;
    vec4 OriginalSize;
    vec4 SourceSize;
} global = _global_(mat4(1.), vec4(target_size, 1. / target_size.x, 1. / target_size.y), vec4(MAIN_RGB_size, MAIN_RGB_pt), vec4(MAIN_RGB_size, MAIN_RGB_pt));
vec4 Position = vec4(HOOKED_pos, 0., 1.);
vec2 TexCoord = HOOKED_pos;
vec2 vTexCoord;
void vertex_main() {
    vertex_gl_Position = global.MVP * Position;
    vTexCoord = TexCoord * 1.0001;
}

vec4 FragColor;
#define Source MAIN_RGB_raw
vec3 fragment_mask_weights(vec2 coord, float mask_intensity, int phosphor_layout) {
    vec3 weights = vec3(1., 1., 1.);
    float on = 1.;
    float off = 1. - mask_intensity;
    vec3 red = vec3(on, off, off);
    vec3 green = vec3(off, on, off);
    vec3 blue = vec3(off, off, on);
    vec3 magenta = vec3(on, off, on);
    vec3 yellow = vec3(on, on, off);
    vec3 cyan = vec3(off, on, on);
    vec3 black = vec3(off, off, off);
    vec3 white = vec3(on, on, on);
    int w, z = 0;
    vec3 aperture_weights = mix(magenta, green, floor(mod(coord.x, 2.)));
    if (phosphor_layout == 0) return weights; else if (phosphor_layout == 1) {
        weights = aperture_weights;
        return weights;
    } else if (phosphor_layout == 2) {
        vec3 inverse_aperture = mix(green, magenta, floor(mod(coord.x, 2.)));
        weights = mix(aperture_weights, inverse_aperture, floor(mod(coord.y, 2.)));
        return weights;
    } else if (phosphor_layout == 3) {
        vec3 slotmask[3][4] = { { magenta, green, black, black }, { magenta, green, magenta, green }, { black, black, magenta, green } };
        w = int(floor(mod(coord.y, 3.)));
        z = int(floor(mod(coord.x, 4.)));
        weights = slotmask[w][z];
        return weights;
    } else if (phosphor_layout == 4) {
        weights = mix(yellow, blue, floor(mod(coord.x, 2.)));
        return weights;
    } else if (phosphor_layout == 5) {
        vec3 inverse_aperture = mix(blue, yellow, floor(mod(coord.x, 2.)));
        weights = mix(mix(yellow, blue, floor(mod(coord.x, 2.))), inverse_aperture, floor(mod(coord.y, 2.)));
        return weights;
    } else if (phosphor_layout == 6) {
        vec3 ap4[4] = vec3[](red, green, blue, black);
        z = int(floor(mod(coord.x, 4.)));
        weights = ap4[z];
        return weights;
    } else if (phosphor_layout == 7) {
        vec3 ap3[5] = vec3[](red, magenta, blue, green, green);
        z = int(floor(mod(coord.x, 5.)));
        weights = ap3[z];
        return weights;
    } else if (phosphor_layout == 8) {
        vec3 big_ap[7] = vec3[](red, red, yellow, green, cyan, blue, blue);
        w = int(floor(mod(coord.x, 7.)));
        weights = big_ap[w];
        return weights;
    } else if (phosphor_layout == 9) {
        vec3 big_ap_rgb[4] = vec3[](red, yellow, cyan, blue);
        w = int(floor(mod(coord.x, 4.)));
        weights = big_ap_rgb[w];
        return weights;
    } else if (phosphor_layout == 10) {
        vec3 big_ap_rbg[4] = vec3[](red, magenta, cyan, green);
        w = int(floor(mod(coord.x, 4.)));
        weights = big_ap_rbg[w];
        return weights;
    } else if (phosphor_layout == 11) {
        vec3 delta1[2][4] = { { red, green, blue, black }, { blue, black, red, green } };
        w = int(floor(mod(coord.y, 2.)));
        z = int(floor(mod(coord.x, 4.)));
        weights = delta1[w][z];
        return weights;
    } else if (phosphor_layout == 12) {
        vec3 delta[2][4] = { { red, yellow, cyan, blue }, { cyan, blue, red, yellow } };
        w = int(floor(mod(coord.y, 2.)));
        z = int(floor(mod(coord.x, 4.)));
        weights = delta[w][z];
        return weights;
    } else if (phosphor_layout == 13) {
        vec3 delta[4][4] = { { red, yellow, cyan, blue }, { red, yellow, cyan, blue }, { cyan, blue, red, yellow }, { cyan, blue, red, yellow } };
        w = int(floor(mod(coord.y, 4.)));
        z = int(floor(mod(coord.x, 4.)));
        weights = delta[w][z];
        return weights;
    } else if (phosphor_layout == 14) {
        vec3 slotmask[3][6] = { { magenta, green, black, black, black, black }, { magenta, green, black, magenta, green, black }, { black, black, black, magenta, green, black } };
        w = int(floor(mod(coord.y, 3.)));
        z = int(floor(mod(coord.x, 6.)));
        weights = slotmask[w][z];
        return weights;
    } else if (phosphor_layout == 15) {
        vec3 slot2[4][8] = { { red, yellow, cyan, blue, red, yellow, cyan, blue }, { red, yellow, cyan, blue, black, black, black, black }, { red, yellow, cyan, blue, red, yellow, cyan, blue }, { black, black, black, black, red, yellow, cyan, blue } };
        w = int(floor(mod(coord.y, 4.)));
        z = int(floor(mod(coord.x, 8.)));
        weights = slot2[w][z];
        return weights;
    } else if (phosphor_layout == 16) {
        vec3 slotmask[3][4] = { { yellow, blue, black, black }, { yellow, blue, yellow, blue }, { black, black, yellow, blue } };
        w = int(floor(mod(coord.y, 3.)));
        z = int(floor(mod(coord.x, 4.)));
        weights = slotmask[w][z];
        return weights;
    } else if (phosphor_layout == 17) {
        vec3 slot2[4][10] = { { red, magenta, blue, green, green, red, magenta, blue, green, green }, { black, blue, blue, green, green, red, red, black, black, black }, { red, magenta, blue, green, green, red, magenta, blue, green, green }, { red, red, black, black, black, black, blue, blue, green, green } };
        w = int(floor(mod(coord.y, 4.)));
        z = int(floor(mod(coord.x, 10.)));
        weights = slot2[w][z];
        return weights;
    } else if (phosphor_layout == 18) {
        vec3 slot2[4][10] = { { red, yellow, green, blue, blue, red, yellow, green, blue, blue }, { black, green, green, blue, blue, red, red, black, black, black }, { red, yellow, green, blue, blue, red, yellow, green, blue, blue }, { red, red, black, black, black, black, green, green, blue, blue } };
        w = int(floor(mod(coord.y, 4.)));
        z = int(floor(mod(coord.x, 10.)));
        weights = slot2[w][z];
        return weights;
    } else if (phosphor_layout == 19) {
        vec3 slot[6][14] = { { red, red, yellow, green, cyan, blue, blue, red, red, yellow, green, cyan, blue, blue }, { red, red, yellow, green, cyan, blue, blue, red, red, yellow, green, cyan, blue, blue }, { red, red, yellow, green, cyan, blue, blue, black, black, black, black, black, black, black }, { red, red, yellow, green, cyan, blue, blue, red, red, yellow, green, cyan, blue, blue }, { red, red, yellow, green, cyan, blue, blue, red, red, yellow, green, cyan, blue, blue }, { black, black, black, black, black, black, black, black, red, red, yellow, green, cyan, blue } };
        w = int(floor(mod(coord.y, 6.)));
        z = int(floor(mod(coord.x, 14.)));
        weights = slot[w][z];
        return weights;
    } else if (phosphor_layout == 20) {
        vec3 tatemask[4][4] = { { green, magenta, green, magenta }, { black, blue, green, red }, { green, magenta, green, magenta }, { green, red, black, blue } };
        w = int(floor(mod(coord.y, 4.)));
        z = int(floor(mod(coord.x, 4.)));
        weights = tatemask[w][z];
        return weights;
    } else if (phosphor_layout == 21) {
        vec3 slot[4][8] = { { red, green, blue, black, red, green, blue, black }, { red, green, blue, black, black, black, black, black }, { red, green, blue, black, red, green, blue, black }, { black, black, black, black, red, green, blue, black } };
        w = int(floor(mod(coord.y, 4.)));
        z = int(floor(mod(coord.x, 8.)));
        weights = slot[w][z];
        return weights;
    } else if (phosphor_layout == 22) {
        vec3 bw3[3] = vec3[](black, white, white);
        z = int(floor(mod(coord.x, 3.)));
        weights = bw3[z];
        return weights;
    } else if (phosphor_layout == 23) {
        vec3 bw4[4] = vec3[](black, black, white, white);
        z = int(floor(mod(coord.x, 4.)));
        weights = bw4[z];
        return weights;
    } else if (phosphor_layout == 24) {
        vec3 shadow[6][10] = { { green, cyan, blue, blue, blue, red, red, red, yellow, green }, { green, cyan, blue, blue, blue, red, red, red, yellow, green }, { green, cyan, blue, blue, blue, red, red, red, yellow, green }, { red, red, red, yellow, green, green, cyan, blue, blue, blue }, { red, red, red, yellow, green, green, cyan, blue, blue, blue }, { red, red, red, yellow, green, green, cyan, blue, blue, blue } };
        w = int(floor(mod(coord.y, 6.)));
        z = int(floor(mod(coord.x, 10.)));
        weights = shadow[w][z];
        return weights;
    } else return weights;
}

vec3 fragment_mask_weights_alpha(vec2 coord, float mask_intensity, int phosphor_layout, out float alpha) {
    vec3 weights = vec3(1., 1., 1.);
    float on = 1.;
    float off = 1. - mask_intensity;
    vec3 red = vec3(on, off, off);
    vec3 green = vec3(off, on, off);
    vec3 blue = vec3(off, off, on);
    vec3 magenta = vec3(on, off, on);
    vec3 yellow = vec3(on, on, off);
    vec3 cyan = vec3(off, on, on);
    vec3 black = vec3(off, off, off);
    vec3 white = vec3(on, on, on);
    int w, z = 0;
    alpha = 1.;
    vec3 aperture_weights = mix(magenta, green, floor(mod(coord.x, 2.)));
    if (phosphor_layout == 0) return weights; else if (phosphor_layout == 1) {
        weights.rgb = aperture_weights;
        alpha = 3. / 6.;
        return weights;
    } else if (phosphor_layout == 2) {
        vec3 inverse_aperture = mix(green, magenta, floor(mod(coord.x, 2.)));
        weights = mix(aperture_weights, inverse_aperture, floor(mod(coord.y, 2.)));
        alpha = 6. / 12.;
        return weights;
    } else if (phosphor_layout == 3) {
        vec3 slotmask[3][4] = { { magenta, green, black, black }, { magenta, green, magenta, green }, { black, black, magenta, green } };
        w = int(floor(mod(coord.y, 3.)));
        z = int(floor(mod(coord.x, 4.)));
        weights = slotmask[w][z];
        alpha = 12. / 36.;
        return weights;
    } else if (phosphor_layout == 4) {
        weights = mix(yellow, blue, floor(mod(coord.x, 2.)));
        alpha = 3. / 6.;
        return weights;
    } else if (phosphor_layout == 5) {
        vec3 inverse_aperture = mix(blue, yellow, floor(mod(coord.x, 2.)));
        weights = mix(mix(yellow, blue, floor(mod(coord.x, 2.))), inverse_aperture, floor(mod(coord.y, 2.)));
        alpha = 6. / 12.;
        return weights;
    } else if (phosphor_layout == 6) {
        vec3 ap4[4] = vec3[](red, green, blue, black);
        z = int(floor(mod(coord.x, 4.)));
        weights = ap4[z];
        alpha = 3. / 12.;
        return weights;
    } else if (phosphor_layout == 7) {
        vec3 ap3[5] = vec3[](red, magenta, blue, green, green);
        z = int(floor(mod(coord.x, 5.)));
        weights = ap3[z];
        alpha = 6. / 15.;
        return weights;
    } else if (phosphor_layout == 8) {
        vec3 big_ap[7] = vec3[](red, red, yellow, green, cyan, blue, blue);
        w = int(floor(mod(coord.x, 7.)));
        weights = big_ap[w];
        alpha = 8. / 18.;
        return weights;
    } else if (phosphor_layout == 9) {
        vec3 big_ap_rgb[4] = vec3[](red, yellow, cyan, blue);
        w = int(floor(mod(coord.x, 4.)));
        weights = big_ap_rgb[w];
        alpha = 6. / 12.;
        return weights;
    } else if (phosphor_layout == 10) {
        vec3 big_ap_rbg[4] = vec3[](red, magenta, cyan, green);
        w = int(floor(mod(coord.x, 4.)));
        weights = big_ap_rbg[w];
        alpha = 6. / 12.;
        return weights;
    } else if (phosphor_layout == 11) {
        vec3 delta1[2][4] = { { red, green, blue, black }, { blue, black, red, green } };
        w = int(floor(mod(coord.y, 2.)));
        z = int(floor(mod(coord.x, 4.)));
        weights = delta1[w][z];
        alpha = 6. / 24.;
        return weights;
    } else if (phosphor_layout == 12) {
        vec3 delta[2][4] = { { red, yellow, cyan, blue }, { cyan, blue, red, yellow } };
        w = int(floor(mod(coord.y, 2.)));
        z = int(floor(mod(coord.x, 4.)));
        weights = delta[w][z];
        alpha = 12. / 24.;
        return weights;
    } else if (phosphor_layout == 13) {
        vec3 delta[4][4] = { { red, yellow, cyan, blue }, { red, yellow, cyan, blue }, { cyan, blue, red, yellow }, { cyan, blue, red, yellow } };
        w = int(floor(mod(coord.y, 4.)));
        z = int(floor(mod(coord.x, 4.)));
        weights = delta[w][z];
        alpha = 24. / 48.;
        return weights;
    } else if (phosphor_layout == 14) {
        vec3 slotmask[3][6] = { { magenta, green, black, black, black, black }, { magenta, green, black, magenta, green, black }, { black, black, black, magenta, green, black } };
        w = int(floor(mod(coord.y, 3.)));
        z = int(floor(mod(coord.x, 6.)));
        weights = slotmask[w][z];
        alpha = 12. / 54.;
        return weights;
    } else if (phosphor_layout == 15) {
        vec3 slot2[4][8] = { { red, yellow, cyan, blue, red, yellow, cyan, blue }, { red, yellow, cyan, blue, black, black, black, black }, { red, yellow, cyan, blue, red, yellow, cyan, blue }, { black, black, black, black, red, yellow, cyan, blue } };
        w = int(floor(mod(coord.y, 4.)));
        z = int(floor(mod(coord.x, 8.)));
        weights = slot2[w][z];
        alpha = 36. / 96.;
        return weights;
    } else if (phosphor_layout == 16) {
        vec3 slotmask[3][4] = { { yellow, blue, black, black }, { yellow, blue, yellow, blue }, { black, black, yellow, blue } };
        w = int(floor(mod(coord.y, 3.)));
        z = int(floor(mod(coord.x, 4.)));
        weights = slotmask[w][z];
        alpha = 14. / 36.;
        return weights;
    } else if (phosphor_layout == 17) {
        vec3 slot2[4][10] = { { red, magenta, blue, green, green, red, magenta, blue, green, green }, { black, blue, blue, green, green, red, red, black, black, black }, { red, magenta, blue, green, green, red, magenta, blue, green, green }, { red, red, black, black, black, black, blue, blue, green, green } };
        w = int(floor(mod(coord.y, 4.)));
        z = int(floor(mod(coord.x, 10.)));
        weights = slot2[w][z];
        alpha = 36. / 120.;
        return weights;
    } else if (phosphor_layout == 18) {
        vec3 slot2[4][10] = { { red, yellow, green, blue, blue, red, yellow, green, blue, blue }, { black, green, green, blue, blue, red, red, black, black, black }, { red, yellow, green, blue, blue, red, yellow, green, blue, blue }, { red, red, black, black, black, black, green, green, blue, blue } };
        w = int(floor(mod(coord.y, 4.)));
        z = int(floor(mod(coord.x, 10.)));
        weights = slot2[w][z];
        alpha = 36. / 120.;
        return weights;
    } else if (phosphor_layout == 19) {
        vec3 slot[6][14] = { { red, red, yellow, green, cyan, blue, blue, red, red, yellow, green, cyan, blue, blue }, { red, red, yellow, green, cyan, blue, blue, red, red, yellow, green, cyan, blue, blue }, { red, red, yellow, green, cyan, blue, blue, black, black, black, black, black, black, black }, { red, red, yellow, green, cyan, blue, blue, red, red, yellow, green, cyan, blue, blue }, { red, red, yellow, green, cyan, blue, blue, red, red, yellow, green, cyan, blue, blue }, { black, black, black, black, black, black, black, black, red, red, yellow, green, cyan, blue } };
        w = int(floor(mod(coord.y, 6.)));
        z = int(floor(mod(coord.x, 14.)));
        weights = slot[w][z];
        alpha = 89. / 252.;
        return weights;
    } else if (phosphor_layout == 20) {
        vec3 tatemask[4][4] = { { green, magenta, green, magenta }, { black, blue, green, red }, { green, magenta, green, magenta }, { green, red, black, blue } };
        w = int(floor(mod(coord.y, 4.)));
        z = int(floor(mod(coord.x, 4.)));
        weights = tatemask[w][z];
        alpha = 18. / 48.;
        return weights;
    } else if (phosphor_layout == 21) {
        vec3 slot[4][8] = { { red, green, blue, black, red, green, blue, black }, { red, green, blue, black, black, black, black, black }, { red, green, blue, black, red, green, blue, black }, { black, black, black, black, red, green, blue, black } };
        w = int(floor(mod(coord.y, 4.)));
        z = int(floor(mod(coord.x, 8.)));
        weights = slot[w][z];
        alpha = 21. / 96.;
        return weights;
    } else if (phosphor_layout == 22) {
        vec3 bw3[3] = vec3[](black, white, white);
        z = int(floor(mod(coord.x, 3.)));
        weights = bw3[z];
        alpha = 2. / 3.;
        return weights;
    } else if (phosphor_layout == 23) {
        vec3 bw4[4] = vec3[](black, black, white, white);
        z = int(floor(mod(coord.x, 4.)));
        weights = bw4[z];
        alpha = 0.5;
        return weights;
    } else if (phosphor_layout == 24) {
        vec3 shadow[6][10] = { { green, cyan, blue, blue, blue, red, red, red, yellow, green }, { green, cyan, blue, blue, blue, red, red, red, yellow, green }, { green, cyan, blue, blue, blue, red, red, red, yellow, green }, { red, red, red, yellow, green, green, cyan, blue, blue, blue }, { red, red, red, yellow, green, green, cyan, blue, blue, blue }, { red, red, red, yellow, green, green, cyan, blue, blue, blue } };
        w = int(floor(mod(coord.y, 6.)));
        z = int(floor(mod(coord.x, 10.)));
        weights = shadow[w][z];
        alpha = 72. / 180.;
        return weights;
    } else return weights;
}

mat4x4 fragment_get_hfilter_profile() {
    float bf = 0.;
    float cf = 0.;
    if (param.HFILTER_PROFILE == 1) {
        bf = 0.;
        cf = 0.5;
    }
    return mat4x4((-bf - 6. * cf) / 6., (3. * bf + 12. * cf) / 6., (-3. * bf - 6. * cf) / 6., bf / 6., (12. - 9. * bf - 6. * cf) / 6., (-18. + 12. * bf + 6. * cf) / 6., 0., (6. - 2. * bf) / 6., -(12. - 9. * bf - 6. * cf) / 6., (18. - 15. * bf - 12. * cf) / 6., (3. * bf + 6. * cf) / 6., bf / 6., (bf + 6. * cf) / 6., -cf, 0., 0.);
}

vec4 fragment_get_beam_profile() {
    vec4 bp = vec4(param.SCANLINES_STRENGTH, param.BEAM_MIN_WIDTH, param.BEAM_MAX_WIDTH, param.COLOR_BOOST);
    if (param.BEAM_PROFILE == 1) bp = vec4(0.62, 1., 1., 1.4);
    if (param.BEAM_PROFILE == 2) bp = vec4(0.72, 1., 1., 1.2);
    return bp;
}

void fragment_main() {
    vec4 profile = fragment_get_beam_profile();
    vec2 TextureSize = mix(vec2(global.SourceSize.x * param.SHARPNESS_HACK, global.SourceSize.y), vec2(global.SourceSize.x, global.SourceSize.y * param.SHARPNESS_HACK), param.VSCANLINES);
    vec2 dx = mix(vec2(1. / TextureSize.x, 0.), vec2(0., 1. / TextureSize.y), param.VSCANLINES);
    vec2 dy = mix(vec2(0., 1. / TextureSize.y), vec2(1. / TextureSize.x, 0.), param.VSCANLINES);
    vec2 pix_coord = vTexCoord.xy * TextureSize + vec2(-0.5, 0.5);
    vec2 tc = mix((floor(pix_coord) + vec2(0.5, 0.5)) / TextureSize, (floor(pix_coord) + vec2(1.5, -0.5)) / TextureSize, param.VSCANLINES);
    vec2 fp = mix(fract(pix_coord), fract(pix_coord.yx), param.VSCANLINES);
    vec3 c00 = pow(texture(Source, tc - dx - dy).xyz, vec3(param.InputGamma, param.InputGamma, param.InputGamma));
    vec3 c01 = pow(texture(Source, tc - dy).xyz, vec3(param.InputGamma, param.InputGamma, param.InputGamma));
    vec3 c02 = pow(texture(Source, tc + dx - dy).xyz, vec3(param.InputGamma, param.InputGamma, param.InputGamma));
    vec3 c03 = pow(texture(Source, tc + 2. * dx - dy).xyz, vec3(param.InputGamma, param.InputGamma, param.InputGamma));
    vec3 c10 = pow(texture(Source, tc - dx).xyz, vec3(param.InputGamma, param.InputGamma, param.InputGamma));
    vec3 c11 = pow(texture(Source, tc).xyz, vec3(param.InputGamma, param.InputGamma, param.InputGamma));
    vec3 c12 = pow(texture(Source, tc + dx).xyz, vec3(param.InputGamma, param.InputGamma, param.InputGamma));
    vec3 c13 = pow(texture(Source, tc + 2. * dx).xyz, vec3(param.InputGamma, param.InputGamma, param.InputGamma));
    mat4x4 invX = fragment_get_hfilter_profile();
    mat4x3 color_matrix0 = mat4x3(c00, c01, c02, c03);
    mat4x3 color_matrix1 = mat4x3(c10, c11, c12, c13);
    vec4 invX_Px = vec4(fp.x * fp.x * fp.x, fp.x * fp.x, fp.x, 1.) * invX;
    vec3 color0 = color_matrix0 * invX_Px;
    vec3 color1 = color_matrix1 * invX_Px;
    vec3 min_sample0 = min(c01, c02);
    vec3 max_sample0 = max(c01, c02);
    vec3 min_sample1 = min(c11, c12);
    vec3 max_sample1 = max(c11, c12);
    vec3 aux = color0;
    color0 = clamp(color0, min_sample0, max_sample0);
    color0 = mix(aux, color0, param.CRT_ANTI_RINGING * step(0., (c00 - c01) * (c02 - c03)));
    aux = color1;
    color1 = clamp(color1, min_sample1, max_sample1);
    color1 = mix(aux, color1, param.CRT_ANTI_RINGING * step(0., (c10 - c11) * (c12 - c13)));
    float pos0 = fp.y;
    float pos1 = 1 - fp.y;
    vec3 lum0 = mix(vec3(profile.y), vec3(profile.z), color0);
    vec3 lum1 = mix(vec3(profile.y), vec3(profile.z), color1);
    vec3 d0 = 4. * profile.x * pos0 / (lum0 * lum0 + 0.0000001);
    vec3 d1 = 4. * profile.x * pos1 / (lum1 * lum1 + 0.0000001);
    d0 = exp(-d0 * d0);
    d1 = exp(-d1 * d1);
    vec3 color = profile.w * (color0 * d0 + color1 * d1);
    vec2 mask_coords = vTexCoord.xy * global.OutputSize.xy;
    mask_coords = mix(mask_coords.xy, mask_coords.yx, param.VSCANLINES);
    color.rgb *= fragment_mask_weights(mask_coords, param.MASK_INTENSITY, int(param.PHOSPHOR_LAYOUT));
    color = pow(color, vec3(1. / param.OutputGamma, 1. / param.OutputGamma, 1. / param.OutputGamma));
    FragColor = vec4(color, 1.);
}

vec4 hook() {
    vertex_main();
    fragment_main();
    return delinearize(FragColor);
}
