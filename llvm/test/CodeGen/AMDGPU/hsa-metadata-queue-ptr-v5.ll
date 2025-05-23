; RUN: opt -mtriple=amdgcn-amd-amdhsa -mcpu=gfx700 -passes=amdgpu-attributor -o %t.gfx7.bc %s
; RUN: opt -mtriple=amdgcn-amd-amdhsa -mcpu=gfx803 -passes=amdgpu-attributor -o %t.gfx8.bc %s
; RUN: opt -mtriple=amdgcn-amd-amdhsa -mcpu=gfx900 -passes=amdgpu-attributor -o %t.gfx9.bc %s
; xUN: llc -mtriple=amdgcn-amd-amdhsa -mcpu=gfx700 -filetype=obj < %t.gfx7.bc | llvm-readelf --notes - | FileCheck --check-prefixes=CHECK,PRE-GFX9  %s
; xUN: llc -mtriple=amdgcn-amd-amdhsa -mcpu=gfx803 -filetype=obj < %t.gfx8.bc | llvm-readelf --notes - | FileCheck --check-prefixes=CHECK,PRE-GFX9  %s
; xUN: llc -mtriple=amdgcn-amd-amdhsa -mcpu=gfx900 -filetype=obj < %t.gfx9.bc | llvm-readelf --notes - | FileCheck --check-prefixes=CHECK,GFX9  %s
; xUN: llc -mtriple=amdgcn-amd-amdhsa -mcpu=gfx700 < %t.gfx7.bc | FileCheck --check-prefixes=CHECK,PRE-GFX9 %s
; RUN: llc -mtriple=amdgcn-amd-amdhsa -mcpu=gfx803 < %t.gfx8.bc | FileCheck --check-prefixes=CHECK,PRE-GFX9 %s
; xUN: llc -mtriple=amdgcn-amd-amdhsa -mcpu=gfx900 < %t.gfx9.bc | FileCheck --check-prefixes=CHECK,GFX9 %s


; On gfx8, the queue ptr is required for this addrspacecast on cov4
; CHECK: - .args:

; PRE-GFX9: .value_kind:     hidden_private_base
; PRE-GFX9: .value_kind:     hidden_shared_base

; GFX9-NOT: hidden_queue_ptr
; GFX9-NOT: hidden_private_base
; GFX9-NOT: hidden_shared_base

; CHECK-LABEL:		.name:           addrspacecast_requires_queue_ptr
define amdgpu_kernel void @addrspacecast_requires_queue_ptr(ptr addrspace(5) %ptr.private, ptr addrspace(3) %ptr.local) {
  %flat.private = addrspacecast ptr addrspace(5) %ptr.private to ptr
  %flat.local = addrspacecast ptr addrspace(3) %ptr.local to ptr
  store volatile i32 1, ptr %flat.private
  store volatile i32 2, ptr %flat.local
  ret void
}

; CHECK: - .args:
; PRE-GFX9:		hidden_shared_base
; GFX9-NOT:		hidden_shared_base
; CHECK-LABEL:		.name:          is_shared_requires_queue_ptr
define amdgpu_kernel void @is_shared_requires_queue_ptr(ptr %ptr) {
  %is.shared = call i1 @llvm.amdgcn.is.shared(ptr %ptr)
  %zext = zext i1 %is.shared to i32
  store volatile i32 %zext, ptr addrspace(1) poison
  ret void
}

; CHECK: - .args:
; PRE-GFX9:		hidden_private_base
; GFX9-NOT:		hidden_private_base
; CHECK-LABEL:		.name:           is_private_requires_queue_ptr
define amdgpu_kernel void @is_private_requires_queue_ptr(ptr %ptr) {
  %is.private = call i1 @llvm.amdgcn.is.private(ptr %ptr)
  %zext = zext i1 %is.private to i32
  store volatile i32 %zext, ptr addrspace(1) poison
  ret void
}

; CHECK: - .args:

; PRE-GFX9:		hidden_queue_ptr
; GFX9-NOT:		hidden_queue_ptr
; CHECK-LABEL:		.name:           trap_requires_queue_ptr
define amdgpu_kernel void @trap_requires_queue_ptr() {
  call void @llvm.trap()
  unreachable
}

; CHECK: - .args:

; PRE-GFX9:		hidden_queue_ptr
; GFX9-NOT:		hidden_queue_ptr
; CHECK-LABEL:		.name:           debugtrap_requires_queue_ptr
define amdgpu_kernel void @debugtrap_requires_queue_ptr() {
  call void @llvm.debugtrap()
  unreachable
}

; CHECK: - .args:

; PRE-GFX9:		hidden_queue_ptr
; GFX9-NOT:		hidden_queue_ptr
; CHECK-LABEL:		.name:           ubsantrap_requires_queue_ptr
define amdgpu_kernel void @ubsantrap_requires_queue_ptr() {
  call void @llvm.ubsantrap(i8 0)
  unreachable
}

; CHECK: - .args:
; CHECK:		hidden_queue_ptr
; CHECK-LABEL:		.name:           amdgcn_queue_ptr_requires_queue_ptr
define amdgpu_kernel void @amdgcn_queue_ptr_requires_queue_ptr(ptr addrspace(1) %ptr)  {
  %queue.ptr = call ptr addrspace(4) @llvm.amdgcn.queue.ptr()
  %implicitarg.ptr = call ptr addrspace(4) @llvm.amdgcn.implicitarg.ptr()
  %dispatch.ptr = call ptr addrspace(4) @llvm.amdgcn.dispatch.ptr()
  %dispatch.id = call i64 @llvm.amdgcn.dispatch.id()
  %queue.load = load volatile i8, ptr addrspace(4) %queue.ptr
  %implicitarg.load = load volatile i8, ptr addrspace(4) %implicitarg.ptr
  %dispatch.load = load volatile i8, ptr addrspace(4) %dispatch.ptr
  store volatile i64 %dispatch.id, ptr addrspace(1) %ptr
  ret void
}


declare noalias ptr addrspace(4) @llvm.amdgcn.queue.ptr()
declare noalias ptr addrspace(4) @llvm.amdgcn.implicitarg.ptr()
declare i64 @llvm.amdgcn.dispatch.id()
declare noalias ptr addrspace(4) @llvm.amdgcn.dispatch.ptr()
declare i1 @llvm.amdgcn.is.shared(ptr)
declare i1 @llvm.amdgcn.is.private(ptr)
declare void @llvm.trap()
declare void @llvm.debugtrap()
declare void @llvm.ubsantrap(i8 immarg)

!llvm.module.flags = !{!0}
!0 = !{i32 1, !"amdhsa_code_object_version", i32 500}
