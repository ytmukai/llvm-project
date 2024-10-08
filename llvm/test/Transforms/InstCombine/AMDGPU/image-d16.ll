; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -mtriple=amdgcn--amdpal -mcpu=gfx700 -S -passes=instcombine %s | FileCheck --check-prefixes=GFX7 %s
; RUN: opt -mtriple=amdgcn--amdpal -mcpu=gfx810 -S -passes=instcombine %s | FileCheck --check-prefixes=GFX81PLUS %s
; RUN: opt -mtriple=amdgcn--amdpal -mcpu=gfx900 -S -passes=instcombine %s | FileCheck --check-prefixes=GFX81PLUS %s
; RUN: opt -mtriple=amdgcn--amdpal -mcpu=gfx1010 -S -passes=instcombine %s | FileCheck --check-prefixes=GFX81PLUS %s

define amdgpu_ps half @image_sample_2d_fptrunc_to_d16(<8 x i32> inreg %rsrc, <4 x i32> inreg %samp, float %s, float %t) {
; GFX7-LABEL: @image_sample_2d_fptrunc_to_d16(
; GFX7-NEXT:  main_body:
; GFX7-NEXT:    [[TEX:%.*]] = call float @llvm.amdgcn.image.sample.lz.2d.f32.f32.v8i32.v4i32(i32 1, float [[S:%.*]], float [[T:%.*]], <8 x i32> [[RSRC:%.*]], <4 x i32> [[SAMP:%.*]], i1 false, i32 0, i32 0)
; GFX7-NEXT:    [[TEX_HALF:%.*]] = fptrunc float [[TEX]] to half
; GFX7-NEXT:    ret half [[TEX_HALF]]
;
; GFX81PLUS-LABEL: @image_sample_2d_fptrunc_to_d16(
; GFX81PLUS-NEXT:  main_body:
; GFX81PLUS-NEXT:    [[TEX:%.*]] = call half @llvm.amdgcn.image.sample.lz.2d.f16.f32.v8i32.v4i32(i32 1, float [[S:%.*]], float [[T:%.*]], <8 x i32> [[RSRC:%.*]], <4 x i32> [[SAMP:%.*]], i1 false, i32 0, i32 0)
; GFX81PLUS-NEXT:    ret half [[TEX]]
;
main_body:
  %tex = call float @llvm.amdgcn.image.sample.lz.2d.f32.f32.v8i32.v4i32(i32 1, float %s, float %t, <8 x i32> %rsrc, <4 x i32> %samp, i1 false, i32 0, i32 0)
  %tex_half = fptrunc float %tex to half
  ret half %tex_half
}

define amdgpu_ps half @image_sample_2d_v2f32(<8 x i32> inreg %rsrc, <4 x i32> inreg %samp, float %s, float %t) {
; GFX7-LABEL: @image_sample_2d_v2f32(
; GFX7-NEXT:  main_body:
; GFX7-NEXT:    [[TEX:%.*]] = call <2 x float> @llvm.amdgcn.image.sample.lz.2d.v2f32.f32.v8i32.v4i32(i32 3, float [[S:%.*]], float [[T:%.*]], <8 x i32> [[RSRC:%.*]], <4 x i32> [[SAMP:%.*]], i1 false, i32 0, i32 0)
; GFX7-NEXT:    [[TEX_2_HALF:%.*]] = fptrunc <2 x float> [[TEX]] to <2 x half>
; GFX7-NEXT:    [[TEX_HALF_0:%.*]] = extractelement <2 x half> [[TEX_2_HALF]], i64 0
; GFX7-NEXT:    [[TEX_HALF_1:%.*]] = extractelement <2 x half> [[TEX_2_HALF]], i64 1
; GFX7-NEXT:    [[ADDF_SUM_0:%.*]] = fadd half [[TEX_HALF_0]], [[TEX_HALF_1]]
; GFX7-NEXT:    ret half [[ADDF_SUM_0]]
;
; GFX81PLUS-LABEL: @image_sample_2d_v2f32(
; GFX81PLUS-NEXT:  main_body:
; GFX81PLUS-NEXT:    [[TEX:%.*]] = call <2 x half> @llvm.amdgcn.image.sample.lz.2d.v2f16.f32.v8i32.v4i32(i32 3, float [[S:%.*]], float [[T:%.*]], <8 x i32> [[RSRC:%.*]], <4 x i32> [[SAMP:%.*]], i1 false, i32 0, i32 0)
; GFX81PLUS-NEXT:    [[TEX_HALF_0:%.*]] = extractelement <2 x half> [[TEX]], i64 0
; GFX81PLUS-NEXT:    [[TEX_HALF_1:%.*]] = extractelement <2 x half> [[TEX]], i64 1
; GFX81PLUS-NEXT:    [[ADDF_SUM_0:%.*]] = fadd half [[TEX_HALF_0]], [[TEX_HALF_1]]
; GFX81PLUS-NEXT:    ret half [[ADDF_SUM_0]]
;
main_body:
  %tex = call <2 x float> @llvm.amdgcn.image.sample.lz.2d.v2f32.f32.v8i32.v4i32(i32 3, float %s, float %t, <8 x i32> %rsrc, <4 x i32> %samp, i1 false, i32 0, i32 0)
  %tex_2_half = fptrunc <2 x float> %tex to <2 x half>
  %tex_half_0 = extractelement <2 x half> %tex_2_half, i64 0
  %tex_half_1 = extractelement <2 x half> %tex_2_half, i64 1
  %addf_sum.0 = fadd half %tex_half_0, %tex_half_1
  ret half %addf_sum.0
}

define amdgpu_ps half @image_sample_2d_v3f32(<8 x i32> inreg %rsrc, <4 x i32> inreg %samp, float %s, float %t) {
; GFX7-LABEL: @image_sample_2d_v3f32(
; GFX7-NEXT:  main_body:
; GFX7-NEXT:    [[TEX:%.*]] = call <3 x float> @llvm.amdgcn.image.sample.lz.2d.v3f32.f32.v8i32.v4i32(i32 7, float [[S:%.*]], float [[T:%.*]], <8 x i32> [[RSRC:%.*]], <4 x i32> [[SAMP:%.*]], i1 false, i32 0, i32 0)
; GFX7-NEXT:    [[TEX_3_HALF:%.*]] = fptrunc <3 x float> [[TEX]] to <3 x half>
; GFX7-NEXT:    [[TEX_HALF_0:%.*]] = extractelement <3 x half> [[TEX_3_HALF]], i64 0
; GFX7-NEXT:    [[TEX_HALF_1:%.*]] = extractelement <3 x half> [[TEX_3_HALF]], i64 1
; GFX7-NEXT:    [[TEX_HALF_2:%.*]] = extractelement <3 x half> [[TEX_3_HALF]], i64 2
; GFX7-NEXT:    [[ADDF_SUM_0:%.*]] = fadd half [[TEX_HALF_0]], [[TEX_HALF_1]]
; GFX7-NEXT:    [[ADDF_SUM_1:%.*]] = fadd half [[ADDF_SUM_0]], [[TEX_HALF_2]]
; GFX7-NEXT:    ret half [[ADDF_SUM_1]]
;
; GFX81PLUS-LABEL: @image_sample_2d_v3f32(
; GFX81PLUS-NEXT:  main_body:
; GFX81PLUS-NEXT:    [[TEX:%.*]] = call <3 x half> @llvm.amdgcn.image.sample.lz.2d.v3f16.f32.v8i32.v4i32(i32 7, float [[S:%.*]], float [[T:%.*]], <8 x i32> [[RSRC:%.*]], <4 x i32> [[SAMP:%.*]], i1 false, i32 0, i32 0)
; GFX81PLUS-NEXT:    [[TEX_HALF_0:%.*]] = extractelement <3 x half> [[TEX]], i64 0
; GFX81PLUS-NEXT:    [[TEX_HALF_1:%.*]] = extractelement <3 x half> [[TEX]], i64 1
; GFX81PLUS-NEXT:    [[TEX_HALF_2:%.*]] = extractelement <3 x half> [[TEX]], i64 2
; GFX81PLUS-NEXT:    [[ADDF_SUM_0:%.*]] = fadd half [[TEX_HALF_0]], [[TEX_HALF_1]]
; GFX81PLUS-NEXT:    [[ADDF_SUM_1:%.*]] = fadd half [[ADDF_SUM_0]], [[TEX_HALF_2]]
; GFX81PLUS-NEXT:    ret half [[ADDF_SUM_1]]
;
main_body:
  %tex = call <3 x float> @llvm.amdgcn.image.sample.lz.2d.v3f32.f32.v8i32.v4i32(i32 7, float %s, float %t, <8 x i32> %rsrc, <4 x i32> %samp, i1 false, i32 0, i32 0)
  %tex_3_half = fptrunc <3 x float> %tex to <3 x half>
  %tex_half_0 = extractelement <3 x half> %tex_3_half, i64 0
  %tex_half_1 = extractelement <3 x half> %tex_3_half, i64 1
  %tex_half_2 = extractelement <3 x half> %tex_3_half, i64 2
  %addf_sum.0 = fadd half %tex_half_0, %tex_half_1
  %addf_sum.1 = fadd half %addf_sum.0, %tex_half_2
  ret half %addf_sum.1
}

define amdgpu_ps half @image_sample_2d_v4f32(<8 x i32> inreg %rsrc, <4 x i32> inreg %samp, float %s, float %t) {
; GFX7-LABEL: @image_sample_2d_v4f32(
; GFX7-NEXT:  main_body:
; GFX7-NEXT:    [[TEX:%.*]] = call <4 x float> @llvm.amdgcn.image.sample.lz.2d.v4f32.f32.v8i32.v4i32(i32 15, float [[S:%.*]], float [[T:%.*]], <8 x i32> [[RSRC:%.*]], <4 x i32> [[SAMP:%.*]], i1 false, i32 0, i32 0)
; GFX7-NEXT:    [[TEX_4_HALF:%.*]] = fptrunc <4 x float> [[TEX]] to <4 x half>
; GFX7-NEXT:    [[TEX_HALF_0:%.*]] = extractelement <4 x half> [[TEX_4_HALF]], i64 0
; GFX7-NEXT:    [[TEX_HALF_1:%.*]] = extractelement <4 x half> [[TEX_4_HALF]], i64 1
; GFX7-NEXT:    [[TEX_HALF_2:%.*]] = extractelement <4 x half> [[TEX_4_HALF]], i64 2
; GFX7-NEXT:    [[TEX_HALF_3:%.*]] = extractelement <4 x half> [[TEX_4_HALF]], i64 3
; GFX7-NEXT:    [[ADDF_SUM_0:%.*]] = fadd half [[TEX_HALF_0]], [[TEX_HALF_1]]
; GFX7-NEXT:    [[ADDF_SUM_1:%.*]] = fadd half [[TEX_HALF_2]], [[TEX_HALF_3]]
; GFX7-NEXT:    [[ADDF_SUM_2:%.*]] = fadd half [[ADDF_SUM_0]], [[ADDF_SUM_1]]
; GFX7-NEXT:    ret half [[ADDF_SUM_2]]
;
; GFX81PLUS-LABEL: @image_sample_2d_v4f32(
; GFX81PLUS-NEXT:  main_body:
; GFX81PLUS-NEXT:    [[TEX:%.*]] = call <4 x half> @llvm.amdgcn.image.sample.lz.2d.v4f16.f32.v8i32.v4i32(i32 15, float [[S:%.*]], float [[T:%.*]], <8 x i32> [[RSRC:%.*]], <4 x i32> [[SAMP:%.*]], i1 false, i32 0, i32 0)
; GFX81PLUS-NEXT:    [[TEX_HALF_0:%.*]] = extractelement <4 x half> [[TEX]], i64 0
; GFX81PLUS-NEXT:    [[TEX_HALF_1:%.*]] = extractelement <4 x half> [[TEX]], i64 1
; GFX81PLUS-NEXT:    [[TEX_HALF_2:%.*]] = extractelement <4 x half> [[TEX]], i64 2
; GFX81PLUS-NEXT:    [[TEX_HALF_3:%.*]] = extractelement <4 x half> [[TEX]], i64 3
; GFX81PLUS-NEXT:    [[ADDF_SUM_0:%.*]] = fadd half [[TEX_HALF_0]], [[TEX_HALF_1]]
; GFX81PLUS-NEXT:    [[ADDF_SUM_1:%.*]] = fadd half [[TEX_HALF_2]], [[TEX_HALF_3]]
; GFX81PLUS-NEXT:    [[ADDF_SUM_2:%.*]] = fadd half [[ADDF_SUM_0]], [[ADDF_SUM_1]]
; GFX81PLUS-NEXT:    ret half [[ADDF_SUM_2]]
;
main_body:
  %tex = call <4 x float> @llvm.amdgcn.image.sample.lz.2d.v4f32.f32.v8i32.v4i32(i32 15, float %s, float %t, <8 x i32> %rsrc, <4 x i32> %samp, i1 false, i32 0, i32 0)
  %tex_4_half = fptrunc <4 x float> %tex to <4 x half>
  %tex_half_0 = extractelement <4 x half> %tex_4_half, i64 0
  %tex_half_1 = extractelement <4 x half> %tex_4_half, i64 1
  %tex_half_2 = extractelement <4 x half> %tex_4_half, i64 2
  %tex_half_3 = extractelement <4 x half> %tex_4_half, i64 3
  %addf_sum.0 = fadd half %tex_half_0, %tex_half_1
  %addf_sum.1 = fadd half %tex_half_2, %tex_half_3
  %addf_sum.2 = fadd half %addf_sum.0, %addf_sum.1
  ret half %addf_sum.2
}

define amdgpu_ps half @image_gather4_2d_v4f32(<8 x i32> inreg %rsrc, <4 x i32> inreg %samp, half %s, half %t) {
; GFX7-LABEL: @image_gather4_2d_v4f32(
; GFX7-NEXT:  main_body:
; GFX7-NEXT:    [[TEX:%.*]] = call <4 x float> @llvm.amdgcn.image.gather4.2d.v4f32.f16.v8i32.v4i32(i32 1, half [[S:%.*]], half [[T:%.*]], <8 x i32> [[RSRC:%.*]], <4 x i32> [[SAMP:%.*]], i1 false, i32 0, i32 0)
; GFX7-NEXT:    [[TEX_4_HALF:%.*]] = fptrunc <4 x float> [[TEX]] to <4 x half>
; GFX7-NEXT:    [[TEX_HALF_0:%.*]] = extractelement <4 x half> [[TEX_4_HALF]], i64 0
; GFX7-NEXT:    [[TEX_HALF_1:%.*]] = extractelement <4 x half> [[TEX_4_HALF]], i64 1
; GFX7-NEXT:    [[TEX_HALF_2:%.*]] = extractelement <4 x half> [[TEX_4_HALF]], i64 2
; GFX7-NEXT:    [[TEX_HALF_3:%.*]] = extractelement <4 x half> [[TEX_4_HALF]], i64 3
; GFX7-NEXT:    [[ADDF_SUM_0:%.*]] = fadd half [[TEX_HALF_0]], [[TEX_HALF_1]]
; GFX7-NEXT:    [[ADDF_SUM_1:%.*]] = fadd half [[TEX_HALF_2]], [[TEX_HALF_3]]
; GFX7-NEXT:    [[ADDF_SUM_2:%.*]] = fadd half [[ADDF_SUM_0]], [[ADDF_SUM_1]]
; GFX7-NEXT:    ret half [[ADDF_SUM_2]]
;
; GFX81PLUS-LABEL: @image_gather4_2d_v4f32(
; GFX81PLUS-NEXT:  main_body:
; GFX81PLUS-NEXT:    [[TEX:%.*]] = call <4 x half> @llvm.amdgcn.image.gather4.2d.v4f16.f16.v8i32.v4i32(i32 1, half [[S:%.*]], half [[T:%.*]], <8 x i32> [[RSRC:%.*]], <4 x i32> [[SAMP:%.*]], i1 false, i32 0, i32 0)
; GFX81PLUS-NEXT:    [[TEX_HALF_0:%.*]] = extractelement <4 x half> [[TEX]], i64 0
; GFX81PLUS-NEXT:    [[TEX_HALF_1:%.*]] = extractelement <4 x half> [[TEX]], i64 1
; GFX81PLUS-NEXT:    [[TEX_HALF_2:%.*]] = extractelement <4 x half> [[TEX]], i64 2
; GFX81PLUS-NEXT:    [[TEX_HALF_3:%.*]] = extractelement <4 x half> [[TEX]], i64 3
; GFX81PLUS-NEXT:    [[ADDF_SUM_0:%.*]] = fadd half [[TEX_HALF_0]], [[TEX_HALF_1]]
; GFX81PLUS-NEXT:    [[ADDF_SUM_1:%.*]] = fadd half [[TEX_HALF_2]], [[TEX_HALF_3]]
; GFX81PLUS-NEXT:    [[ADDF_SUM_2:%.*]] = fadd half [[ADDF_SUM_0]], [[ADDF_SUM_1]]
; GFX81PLUS-NEXT:    ret half [[ADDF_SUM_2]]
;
main_body:
  %tex = call <4 x float> @llvm.amdgcn.image.gather4.2d.v4f32.f16.v8i32.v4i32(i32 1, half %s, half %t, <8 x i32> %rsrc, <4 x i32> %samp, i1 false, i32 0, i32 0)
  %tex_4_half = fptrunc <4 x float> %tex to <4 x half>
  %tex_half_0 = extractelement <4 x half> %tex_4_half, i64 0
  %tex_half_1 = extractelement <4 x half> %tex_4_half, i64 1
  %tex_half_2 = extractelement <4 x half> %tex_4_half, i64 2
  %tex_half_3 = extractelement <4 x half> %tex_4_half, i64 3
  %addf_sum.0 = fadd half %tex_half_0, %tex_half_1
  %addf_sum.1 = fadd half %tex_half_2, %tex_half_3
  %addf_sum.2 = fadd half %addf_sum.0, %addf_sum.1
  ret half %addf_sum.2
}

define amdgpu_ps half @load_1d(i16 %s, <8 x i32> inreg %rsrc) {
; GFX7-LABEL: @load_1d(
; GFX7-NEXT:    [[S_FLOAT:%.*]] = call float @llvm.amdgcn.image.load.1d.f32.i16.v8i32(i32 1, i16 [[S:%.*]], <8 x i32> [[RSRC:%.*]], i32 0, i32 0)
; GFX7-NEXT:    [[S_HALF:%.*]] = fptrunc float [[S_FLOAT]] to half
; GFX7-NEXT:    ret half [[S_HALF]]
;
; GFX81PLUS-LABEL: @load_1d(
; GFX81PLUS-NEXT:    [[S_FLOAT:%.*]] = call half @llvm.amdgcn.image.load.1d.f16.i16.v8i32(i32 1, i16 [[S:%.*]], <8 x i32> [[RSRC:%.*]], i32 0, i32 0)
; GFX81PLUS-NEXT:    ret half [[S_FLOAT]]
;
  %s_float = call float @llvm.amdgcn.image.load.1d.f32.i16.v8i32(i32 1, i16 %s, <8 x i32> %rsrc, i32 0, i32 0)
  %s_half = fptrunc float %s_float to half
  ret half %s_half
}

define amdgpu_ps half @load_1d_v2(i16 %s, <8 x i32> inreg %rsrc) {
; GFX7-LABEL: @load_1d_v2(
; GFX7-NEXT:    [[V2_FLOAT:%.*]] = call <2 x float> @llvm.amdgcn.image.load.1d.v2f32.i16.v8i32(i32 3, i16 [[S:%.*]], <8 x i32> [[RSRC:%.*]], i32 0, i32 0)
; GFX7-NEXT:    [[V2_HALF:%.*]] = fptrunc <2 x float> [[V2_FLOAT]] to <2 x half>
; GFX7-NEXT:    [[S0:%.*]] = extractelement <2 x half> [[V2_HALF]], i64 0
; GFX7-NEXT:    [[S1:%.*]] = extractelement <2 x half> [[V2_HALF]], i64 1
; GFX7-NEXT:    [[ADDF_SUM_0:%.*]] = fadd half [[S0]], [[S1]]
; GFX7-NEXT:    ret half [[ADDF_SUM_0]]
;
; GFX81PLUS-LABEL: @load_1d_v2(
; GFX81PLUS-NEXT:    [[V2_FLOAT:%.*]] = call <2 x half> @llvm.amdgcn.image.load.1d.v2f16.i16.v8i32(i32 3, i16 [[S:%.*]], <8 x i32> [[RSRC:%.*]], i32 0, i32 0)
; GFX81PLUS-NEXT:    [[S0:%.*]] = extractelement <2 x half> [[V2_FLOAT]], i64 0
; GFX81PLUS-NEXT:    [[S1:%.*]] = extractelement <2 x half> [[V2_FLOAT]], i64 1
; GFX81PLUS-NEXT:    [[ADDF_SUM_0:%.*]] = fadd half [[S0]], [[S1]]
; GFX81PLUS-NEXT:    ret half [[ADDF_SUM_0]]
;
  %v2_float = call <2 x float> @llvm.amdgcn.image.load.1d.v2f32.i16.v8i32(i32 3, i16 %s, <8 x i32> %rsrc, i32 0, i32 0)
  %v2_half = fptrunc <2 x float> %v2_float to <2 x half>
  %s0 = extractelement <2 x half> %v2_half, i64 0
  %s1 = extractelement <2 x half> %v2_half, i64 1
  %addf_sum.0 = fadd half %s0, %s1
  ret half %addf_sum.0
}

define amdgpu_ps half @load_1d_v3(i16 %s, <8 x i32> inreg %rsrc) {
; GFX7-LABEL: @load_1d_v3(
; GFX7-NEXT:    [[V3_FLOAT:%.*]] = call <3 x float> @llvm.amdgcn.image.load.1d.v3f32.i16.v8i32(i32 7, i16 [[S:%.*]], <8 x i32> [[RSRC:%.*]], i32 0, i32 0)
; GFX7-NEXT:    [[V3_HALF:%.*]] = fptrunc <3 x float> [[V3_FLOAT]] to <3 x half>
; GFX7-NEXT:    [[S0:%.*]] = extractelement <3 x half> [[V3_HALF]], i64 0
; GFX7-NEXT:    [[S1:%.*]] = extractelement <3 x half> [[V3_HALF]], i64 1
; GFX7-NEXT:    [[S2:%.*]] = extractelement <3 x half> [[V3_HALF]], i64 2
; GFX7-NEXT:    [[ADDF_SUM_0:%.*]] = fadd half [[S0]], [[S1]]
; GFX7-NEXT:    [[ADDF_SUM_1:%.*]] = fadd half [[S2]], [[ADDF_SUM_0]]
; GFX7-NEXT:    ret half [[ADDF_SUM_1]]
;
; GFX81PLUS-LABEL: @load_1d_v3(
; GFX81PLUS-NEXT:    [[V3_FLOAT:%.*]] = call <3 x half> @llvm.amdgcn.image.load.1d.v3f16.i16.v8i32(i32 7, i16 [[S:%.*]], <8 x i32> [[RSRC:%.*]], i32 0, i32 0)
; GFX81PLUS-NEXT:    [[S0:%.*]] = extractelement <3 x half> [[V3_FLOAT]], i64 0
; GFX81PLUS-NEXT:    [[S1:%.*]] = extractelement <3 x half> [[V3_FLOAT]], i64 1
; GFX81PLUS-NEXT:    [[S2:%.*]] = extractelement <3 x half> [[V3_FLOAT]], i64 2
; GFX81PLUS-NEXT:    [[ADDF_SUM_0:%.*]] = fadd half [[S0]], [[S1]]
; GFX81PLUS-NEXT:    [[ADDF_SUM_1:%.*]] = fadd half [[S2]], [[ADDF_SUM_0]]
; GFX81PLUS-NEXT:    ret half [[ADDF_SUM_1]]
;
  %v3_float = call <3 x float> @llvm.amdgcn.image.load.1d.v3f32.i16.v8i32(i32 7, i16 %s, <8 x i32> %rsrc, i32 0, i32 0)
  %v3_half = fptrunc <3 x float> %v3_float to <3 x half>
  %s0 = extractelement <3 x half> %v3_half, i64 0
  %s1 = extractelement <3 x half> %v3_half, i64 1
  %s2 = extractelement <3 x half> %v3_half, i64 2
  %addf_sum.0 = fadd half %s0, %s1
  %addf_sum.1 = fadd half %s2, %addf_sum.0
  ret half %addf_sum.1
}

define amdgpu_ps half @load_1d_v4(i16 %s, <8 x i32> inreg %rsrc) {
; GFX7-LABEL: @load_1d_v4(
; GFX7-NEXT:    [[V4_FLOAT:%.*]] = call <4 x float> @llvm.amdgcn.image.load.1d.v4f32.i16.v8i32(i32 15, i16 [[S:%.*]], <8 x i32> [[RSRC:%.*]], i32 0, i32 0)
; GFX7-NEXT:    [[V4_HALF:%.*]] = fptrunc <4 x float> [[V4_FLOAT]] to <4 x half>
; GFX7-NEXT:    [[S0:%.*]] = extractelement <4 x half> [[V4_HALF]], i64 0
; GFX7-NEXT:    [[S1:%.*]] = extractelement <4 x half> [[V4_HALF]], i64 1
; GFX7-NEXT:    [[S2:%.*]] = extractelement <4 x half> [[V4_HALF]], i64 2
; GFX7-NEXT:    [[S3:%.*]] = extractelement <4 x half> [[V4_HALF]], i64 3
; GFX7-NEXT:    [[ADDF_SUM_0:%.*]] = fadd half [[S0]], [[S1]]
; GFX7-NEXT:    [[ADDF_SUM_1:%.*]] = fadd half [[S2]], [[S3]]
; GFX7-NEXT:    [[ADDF_SUM_2:%.*]] = fadd half [[ADDF_SUM_0]], [[ADDF_SUM_1]]
; GFX7-NEXT:    ret half [[ADDF_SUM_2]]
;
; GFX81PLUS-LABEL: @load_1d_v4(
; GFX81PLUS-NEXT:    [[V4_FLOAT:%.*]] = call <4 x half> @llvm.amdgcn.image.load.1d.v4f16.i16.v8i32(i32 15, i16 [[S:%.*]], <8 x i32> [[RSRC:%.*]], i32 0, i32 0)
; GFX81PLUS-NEXT:    [[S0:%.*]] = extractelement <4 x half> [[V4_FLOAT]], i64 0
; GFX81PLUS-NEXT:    [[S1:%.*]] = extractelement <4 x half> [[V4_FLOAT]], i64 1
; GFX81PLUS-NEXT:    [[S2:%.*]] = extractelement <4 x half> [[V4_FLOAT]], i64 2
; GFX81PLUS-NEXT:    [[S3:%.*]] = extractelement <4 x half> [[V4_FLOAT]], i64 3
; GFX81PLUS-NEXT:    [[ADDF_SUM_0:%.*]] = fadd half [[S0]], [[S1]]
; GFX81PLUS-NEXT:    [[ADDF_SUM_1:%.*]] = fadd half [[S2]], [[S3]]
; GFX81PLUS-NEXT:    [[ADDF_SUM_2:%.*]] = fadd half [[ADDF_SUM_0]], [[ADDF_SUM_1]]
; GFX81PLUS-NEXT:    ret half [[ADDF_SUM_2]]
;
  %v4_float = call <4 x float> @llvm.amdgcn.image.load.1d.v4f32.i16.v8i32(i32 15, i16 %s, <8 x i32> %rsrc, i32 0, i32 0)
  %v4_half = fptrunc <4 x float> %v4_float to <4 x half>
  %s0 = extractelement <4 x half> %v4_half, i64 0
  %s1 = extractelement <4 x half> %v4_half, i64 1
  %s2 = extractelement <4 x half> %v4_half, i64 2
  %s3 = extractelement <4 x half> %v4_half, i64 3
  %addf_sum.0 = fadd half %s0, %s1
  %addf_sum.1 = fadd half %s2, %s3
  %addf_sum.2 = fadd half %addf_sum.0, %addf_sum.1
  ret half %addf_sum.2
}

define amdgpu_ps half @load_2dmsaa(<8 x i32> inreg %rsrc, i32 %s, i32 %t, i32 %fragid) {
; GFX7-LABEL: @load_2dmsaa(
; GFX7-NEXT:  main_body:
; GFX7-NEXT:    [[S_FLOAT:%.*]] = call float @llvm.amdgcn.image.msaa.load.x.2dmsaa.f32.i32.v8i32(i32 1, i32 [[S:%.*]], i32 [[T:%.*]], i32 [[FRAGID:%.*]], <8 x i32> [[RSRC:%.*]], i32 0, i32 0)
; GFX7-NEXT:    [[S_HALF:%.*]] = fptrunc float [[S_FLOAT]] to half
; GFX7-NEXT:    ret half [[S_HALF]]
;
; GFX81PLUS-LABEL: @load_2dmsaa(
; GFX81PLUS-NEXT:  main_body:
; GFX81PLUS-NEXT:    [[S_FLOAT:%.*]] = call half @llvm.amdgcn.image.msaa.load.x.2dmsaa.f16.i32.v8i32(i32 1, i32 [[S:%.*]], i32 [[T:%.*]], i32 [[FRAGID:%.*]], <8 x i32> [[RSRC:%.*]], i32 0, i32 0)
; GFX81PLUS-NEXT:    ret half [[S_FLOAT]]
;
main_body:
  %s_float = call float @llvm.amdgcn.image.msaa.load.x.2dmsaa.f32.i32.v8i32(i32 1, i32 %s, i32 %t, i32 %fragid, <8 x i32> %rsrc, i32 0, i32 0)
  %s_half = fptrunc float %s_float to half
  ret half %s_half
}

define amdgpu_ps half @load_2dmsaa_v2(<8 x i32> inreg %rsrc, i32 %s, i32 %t, i32 %fragid) {
; GFX7-LABEL: @load_2dmsaa_v2(
; GFX7-NEXT:  main_body:
; GFX7-NEXT:    [[V2_FLOAT:%.*]] = call <2 x float> @llvm.amdgcn.image.msaa.load.x.2dmsaa.v2f32.i32.v8i32(i32 3, i32 [[S:%.*]], i32 [[T:%.*]], i32 [[FRAGID:%.*]], <8 x i32> [[RSRC:%.*]], i32 0, i32 0)
; GFX7-NEXT:    [[V2_HALF:%.*]] = fptrunc <2 x float> [[V2_FLOAT]] to <2 x half>
; GFX7-NEXT:    [[S0:%.*]] = extractelement <2 x half> [[V2_HALF]], i64 0
; GFX7-NEXT:    [[S1:%.*]] = extractelement <2 x half> [[V2_HALF]], i64 1
; GFX7-NEXT:    [[ADDF_SUM_0:%.*]] = fadd half [[S0]], [[S1]]
; GFX7-NEXT:    ret half [[ADDF_SUM_0]]
;
; GFX81PLUS-LABEL: @load_2dmsaa_v2(
; GFX81PLUS-NEXT:  main_body:
; GFX81PLUS-NEXT:    [[V2_FLOAT:%.*]] = call <2 x half> @llvm.amdgcn.image.msaa.load.x.2dmsaa.v2f16.i32.v8i32(i32 3, i32 [[S:%.*]], i32 [[T:%.*]], i32 [[FRAGID:%.*]], <8 x i32> [[RSRC:%.*]], i32 0, i32 0)
; GFX81PLUS-NEXT:    [[S0:%.*]] = extractelement <2 x half> [[V2_FLOAT]], i64 0
; GFX81PLUS-NEXT:    [[S1:%.*]] = extractelement <2 x half> [[V2_FLOAT]], i64 1
; GFX81PLUS-NEXT:    [[ADDF_SUM_0:%.*]] = fadd half [[S0]], [[S1]]
; GFX81PLUS-NEXT:    ret half [[ADDF_SUM_0]]
;
main_body:
  %v2_float = call <2 x float> @llvm.amdgcn.image.msaa.load.x.2dmsaa.v2f32.i32.v8i32(i32 3, i32 %s, i32 %t, i32 %fragid, <8 x i32> %rsrc, i32 0, i32 0)
  %v2_half = fptrunc <2 x float> %v2_float to <2 x half>
  %s0 = extractelement <2 x half> %v2_half, i64 0
  %s1 = extractelement <2 x half> %v2_half, i64 1
  %addf_sum.0 = fadd half %s0, %s1
  ret half %addf_sum.0
}

define amdgpu_ps half @load_2dmsaa_v3(<8 x i32> inreg %rsrc, i32 %s, i32 %t, i32 %fragid) {
; GFX7-LABEL: @load_2dmsaa_v3(
; GFX7-NEXT:  main_body:
; GFX7-NEXT:    [[V3_FLOAT:%.*]] = call <3 x float> @llvm.amdgcn.image.msaa.load.x.2dmsaa.v3f32.i32.v8i32(i32 7, i32 [[S:%.*]], i32 [[T:%.*]], i32 [[FRAGID:%.*]], <8 x i32> [[RSRC:%.*]], i32 0, i32 0)
; GFX7-NEXT:    [[V3_HALF:%.*]] = fptrunc <3 x float> [[V3_FLOAT]] to <3 x half>
; GFX7-NEXT:    [[S0:%.*]] = extractelement <3 x half> [[V3_HALF]], i64 0
; GFX7-NEXT:    [[S1:%.*]] = extractelement <3 x half> [[V3_HALF]], i64 1
; GFX7-NEXT:    [[S2:%.*]] = extractelement <3 x half> [[V3_HALF]], i64 2
; GFX7-NEXT:    [[ADDF_SUM_0:%.*]] = fadd half [[S0]], [[S1]]
; GFX7-NEXT:    [[ADDF_SUM_1:%.*]] = fadd half [[S2]], [[ADDF_SUM_0]]
; GFX7-NEXT:    ret half [[ADDF_SUM_1]]
;
; GFX81PLUS-LABEL: @load_2dmsaa_v3(
; GFX81PLUS-NEXT:  main_body:
; GFX81PLUS-NEXT:    [[V3_FLOAT:%.*]] = call <3 x half> @llvm.amdgcn.image.msaa.load.x.2dmsaa.v3f16.i32.v8i32(i32 7, i32 [[S:%.*]], i32 [[T:%.*]], i32 [[FRAGID:%.*]], <8 x i32> [[RSRC:%.*]], i32 0, i32 0)
; GFX81PLUS-NEXT:    [[S0:%.*]] = extractelement <3 x half> [[V3_FLOAT]], i64 0
; GFX81PLUS-NEXT:    [[S1:%.*]] = extractelement <3 x half> [[V3_FLOAT]], i64 1
; GFX81PLUS-NEXT:    [[S2:%.*]] = extractelement <3 x half> [[V3_FLOAT]], i64 2
; GFX81PLUS-NEXT:    [[ADDF_SUM_0:%.*]] = fadd half [[S0]], [[S1]]
; GFX81PLUS-NEXT:    [[ADDF_SUM_1:%.*]] = fadd half [[S2]], [[ADDF_SUM_0]]
; GFX81PLUS-NEXT:    ret half [[ADDF_SUM_1]]
;
main_body:
  %v3_float = call <3 x float> @llvm.amdgcn.image.msaa.load.x.2dmsaa.v3f32.i32.v8i32(i32 7, i32 %s, i32 %t, i32 %fragid, <8 x i32> %rsrc, i32 0, i32 0)
  %v3_half = fptrunc <3 x float> %v3_float to <3 x half>
  %s0 = extractelement <3 x half> %v3_half, i64 0
  %s1 = extractelement <3 x half> %v3_half, i64 1
  %s2 = extractelement <3 x half> %v3_half, i64 2
  %addf_sum.0 = fadd half %s0, %s1
  %addf_sum.1 = fadd half %s2, %addf_sum.0
  ret half %addf_sum.1
}

define amdgpu_ps half @load_2dmsaa_v4(<8 x i32> inreg %rsrc, i32 %s, i32 %t, i32 %fragid) {
; GFX7-LABEL: @load_2dmsaa_v4(
; GFX7-NEXT:  main_body:
; GFX7-NEXT:    [[V4_FLOAT:%.*]] = call <4 x float> @llvm.amdgcn.image.msaa.load.x.2dmsaa.v4f32.i32.v8i32(i32 15, i32 [[S:%.*]], i32 [[T:%.*]], i32 [[FRAGID:%.*]], <8 x i32> [[RSRC:%.*]], i32 0, i32 0)
; GFX7-NEXT:    [[V4_HALF:%.*]] = fptrunc <4 x float> [[V4_FLOAT]] to <4 x half>
; GFX7-NEXT:    [[S0:%.*]] = extractelement <4 x half> [[V4_HALF]], i64 0
; GFX7-NEXT:    [[S1:%.*]] = extractelement <4 x half> [[V4_HALF]], i64 1
; GFX7-NEXT:    [[S2:%.*]] = extractelement <4 x half> [[V4_HALF]], i64 2
; GFX7-NEXT:    [[S3:%.*]] = extractelement <4 x half> [[V4_HALF]], i64 3
; GFX7-NEXT:    [[ADDF_SUM_0:%.*]] = fadd half [[S0]], [[S1]]
; GFX7-NEXT:    [[ADDF_SUM_1:%.*]] = fadd half [[S2]], [[S3]]
; GFX7-NEXT:    [[ADDF_SUM_2:%.*]] = fadd half [[ADDF_SUM_0]], [[ADDF_SUM_1]]
; GFX7-NEXT:    ret half [[ADDF_SUM_2]]
;
; GFX81PLUS-LABEL: @load_2dmsaa_v4(
; GFX81PLUS-NEXT:  main_body:
; GFX81PLUS-NEXT:    [[V4_FLOAT:%.*]] = call <4 x half> @llvm.amdgcn.image.msaa.load.x.2dmsaa.v4f16.i32.v8i32(i32 15, i32 [[S:%.*]], i32 [[T:%.*]], i32 [[FRAGID:%.*]], <8 x i32> [[RSRC:%.*]], i32 0, i32 0)
; GFX81PLUS-NEXT:    [[S0:%.*]] = extractelement <4 x half> [[V4_FLOAT]], i64 0
; GFX81PLUS-NEXT:    [[S1:%.*]] = extractelement <4 x half> [[V4_FLOAT]], i64 1
; GFX81PLUS-NEXT:    [[S2:%.*]] = extractelement <4 x half> [[V4_FLOAT]], i64 2
; GFX81PLUS-NEXT:    [[S3:%.*]] = extractelement <4 x half> [[V4_FLOAT]], i64 3
; GFX81PLUS-NEXT:    [[ADDF_SUM_0:%.*]] = fadd half [[S0]], [[S1]]
; GFX81PLUS-NEXT:    [[ADDF_SUM_1:%.*]] = fadd half [[S2]], [[S3]]
; GFX81PLUS-NEXT:    [[ADDF_SUM_2:%.*]] = fadd half [[ADDF_SUM_0]], [[ADDF_SUM_1]]
; GFX81PLUS-NEXT:    ret half [[ADDF_SUM_2]]
;
main_body:
  %v4_float = call <4 x float> @llvm.amdgcn.image.msaa.load.x.2dmsaa.v4f32.i32.v8i32(i32 15, i32 %s, i32 %t, i32 %fragid, <8 x i32> %rsrc, i32 0, i32 0)
  %v4_half = fptrunc <4 x float> %v4_float to <4 x half>
  %s0 = extractelement <4 x half> %v4_half, i64 0
  %s1 = extractelement <4 x half> %v4_half, i64 1
  %s2 = extractelement <4 x half> %v4_half, i64 2
  %s3 = extractelement <4 x half> %v4_half, i64 3
  %addf_sum.0 = fadd half %s0, %s1
  %addf_sum.1 = fadd half %s2, %s3
  %addf_sum.2 = fadd half %addf_sum.0, %addf_sum.1
  ret half %addf_sum.2
}

declare float @llvm.amdgcn.image.sample.lz.2d.f32.f32(i32, float, float, <8 x i32>, <4 x i32>, i1, i32, i32) #0
declare <2 x float> @llvm.amdgcn.image.sample.lz.2d.v2f32.f32(i32, float, float, <8 x i32>, <4 x i32>, i1, i32, i32) #0
declare <3 x float> @llvm.amdgcn.image.sample.lz.2d.v3f32.f32(i32, float, float, <8 x i32>, <4 x i32>, i1, i32, i32) #0
declare <4 x float> @llvm.amdgcn.image.sample.lz.2d.v4f32.f32(i32, float, float, <8 x i32>, <4 x i32>, i1, i32, i32) #0

declare <4 x float> @llvm.amdgcn.image.gather4.2d.v4f32.f16(i32, half, half, <8 x i32>, <4 x i32>, i1, i32, i32) #0

declare float @llvm.amdgcn.image.load.1d.f32.i16(i32, i16, <8 x i32>, i32, i32) #0
declare <2 x float> @llvm.amdgcn.image.load.1d.v2f32.i16(i32, i16, <8 x i32>, i32, i32) #0
declare <3 x float> @llvm.amdgcn.image.load.1d.v3f32.i16(i32, i16, <8 x i32>, i32, i32) #0
declare <4 x float> @llvm.amdgcn.image.load.1d.v4f32.i16(i32, i16, <8 x i32>, i32, i32) #0

declare float @llvm.amdgcn.image.msaa.load.x.2dmsaa.f32.i32(i32, i32, i32, i32, <8 x i32>, i32, i32) #0
declare <2 x float> @llvm.amdgcn.image.msaa.load.x.2dmsaa.v2f32.i32(i32, i32, i32, i32, <8 x i32>, i32, i32) #0
declare <3 x float> @llvm.amdgcn.image.msaa.load.x.2dmsaa.v3f32.i32(i32, i32, i32, i32, <8 x i32>, i32, i32) #0
declare <4 x float> @llvm.amdgcn.image.msaa.load.x.2dmsaa.v4f32.i32(i32, i32, i32, i32, <8 x i32>, i32, i32) #0

attributes #0 = { nounwind readonly willreturn}

